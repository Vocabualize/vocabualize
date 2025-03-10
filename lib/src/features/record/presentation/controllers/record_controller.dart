import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:log/log.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary_image.dart';
import 'package:vocabualize/src/common/domain/extensions/object_extensions.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_source_language_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_target_language_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/translator/translate_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/vocabulary/get_vocabularies_use_case.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/common/presentation/widgets/disconnected_dialog.dart';
import 'package:vocabualize/src/common/presentation/widgets/duplicate_dialog.dart';
import 'package:vocabualize/src/features/details/presentation/screens/details_screen.dart';
import 'package:vocabualize/src/features/record/domain/use_cases/get_labels_from_image_use_case.dart';
import 'package:vocabualize/src/features/record/presentation/states/record_state.dart';

final recordControllerProvider =
    AutoDisposeAsyncNotifierProvider<RecordController, RecordState>(() {
  return RecordController();
});

class RecordController extends AutoDisposeAsyncNotifier<RecordState> {
  @override
  Future<RecordState> build() async {
    final controller = await _getCameraController();
    final maxZoomLevel = await controller.getMaxZoomLevel();
    return RecordState(
      existingVocabularies: ref.watch(getVocabulariesUseCaseProvider)(),
      cameraController: controller,
      maxZoomLevel: maxZoomLevel,
      sourceLanguage: await ref.read(getSourceLanguageUseCaseProvider),
      targetLanguage: await ref.read(getTargetLanguageUseCaseProvider),
    );
  }

  // TODO: Move getCameraController to use case??
  Future<CameraController> _getCameraController() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    final cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      enableAudio: false,
    );

    await cameraController.initialize();
    await cameraController.setFlashMode(FlashMode.off);
    return cameraController;
  }

  void switchCamera() async {
    final cameras = await availableCameras();
    if (cameras.length < 2) return;
    final currentIndex = cameras.indexWhere((camera) {
      return camera.lensDirection == state.value?.cameraController.description.lensDirection;
    });
    if (currentIndex == -1) return;
    final newIndex = (currentIndex + 1) % cameras.length;
    state.valueOrNull?.cameraController.setDescription(cameras[newIndex]);
    updateZoom(1.0);
  }

  void updateZoom(double zoom) {
    state.value?.cameraController.setZoomLevel(zoom);
    update((current) {
      return current.copyWith(zoomLevel: zoom);
    });
  }

  // TODO: Move photo taking source/repo/use_cases
  Future<void> takePhotoAndScan() async {
    state.value?.let((value) async {
      try {
        final photo = await value.cameraController.takePicture();
        final data = await photo.readAsBytes();
        update((previous) => previous.copyWith(imageBytes: () => data));
        _scanForSuggestions(photo);
      } catch (e) {
        Log.error('Error taking picture.', exception: e);
      }
    });
  }

  Future<void> _scanForSuggestions(XFile file) async {
    final labels = await ref.read(getLabelsFromImageUseCaseProvider)(file);
    update((previous) => previous.copyWith(suggestions: () => labels.keys.toSet()));
  }

  void retakePhoto() {
    update((previous) {
      return previous.copyWith(
        suggestions: () => null,
        imageBytes: () => null,
      );
    });
  }

  Future<void> validateAndGoToDetails(
    BuildContext context, {
    required String source,
  }) async {
    _proceedIfNotDuplicate(context, source, () {
      state.value?.let((value) async {
        final image = value.imageBytes?.let((data) => DraftImage(content: data));
        Vocabulary draftVocabulary = Vocabulary(
          source: source,
          target: await ref.read(translateUseCaseProvider)(source),
          sourceLanguageId: value.sourceLanguage?.id ?? "",
          targetLanguageId: value.targetLanguage?.id ?? "",
          image: image ?? const FallbackImage(),
        );
        if (draftVocabulary.isValid && context.mounted) {
          context.pushNamed(
            DetailsScreen.routeName,
            arguments: DetailsScreenArguments(vocabulary: draftVocabulary),
          );
        }
      });
    });
  }

  void _proceedIfNotDuplicate(BuildContext context, String text, VoidCallback onProceed) {
    final alreadyExists = state.valueOrNull?.containsSource(text) ?? false;
    if (alreadyExists) {
      context.showDialog(DuplicateDialog(
        source: text,
        onProceed: onProceed,
      ));
    } else {
      onProceed();
    }
  }

  Future<bool> isOnlineAndShowDialogIfNot(BuildContext context) async {
    try {
      // TODO: Not only check for google, since this method's not working
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        if (context.mounted) {
          context.showDialog(const DisconnectedDialog());
        }
        return false;
      }
      return true;
    } on SocketException catch (_) {
      if (context.mounted) {
        context.showDialog(const DisconnectedDialog());
      }
      return false;
    }
  }
}
