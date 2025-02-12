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
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/common/presentation/widgets/disconnected_dialog.dart';
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
    return RecordState(
      cameraController: await _getCameraController(),
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
    );

    await cameraController.initialize();
    await cameraController.setFlashMode(FlashMode.off);
    return cameraController;
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
    state = state.copyWithPrevious(const AsyncLoading());
    state.value?.let((value) async {
      final translate = ref.read(translateUseCaseProvider);
      final image = value.imageBytes?.let((data) => DraftImage(content: data));
      Vocabulary draftVocabulary = Vocabulary(
        source: source,
        target: await translate(source),
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
