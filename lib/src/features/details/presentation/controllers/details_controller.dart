import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocabualize/src/common/domain/entities/tag.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary_image.dart';
import 'package:vocabualize/src/common/domain/extensions/object_extensions.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_are_collections_enabled_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/tag/add_or_update_tag_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/tag/get_all_tags_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/tag/get_tags_by_ids_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/translator/translate_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/vocabulary/get_new_vocabularies_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/vocabulary/get_vocabularies_use_case.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/common/presentation/widgets/start.dart';
import 'package:vocabualize/src/features/details/domain/use_cases/image/get_draft_image_use_case.dart';
import 'package:vocabualize/src/features/details/domain/use_cases/image/get_stock_images_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_are_images_disabled_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/translator/translate_to_english_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/vocabulary/delete_vocabulary_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/vocabulary/add_or_update_vocabulary_use_case.dart';
import 'package:vocabualize/src/common/domain/utils/formatter.dart';
import 'package:vocabualize/src/features/details/presentation/screens/details_screen.dart';
import 'package:vocabualize/src/features/details/presentation/states/details_state.dart';
import 'package:vocabualize/src/features/details/presentation/widgets/add_tag_dialog.dart';
import 'package:vocabualize/src/features/details/presentation/widgets/camera_gallery_dialog.dart';
import 'package:vocabualize/src/features/details/presentation/widgets/edit_source_target_dialog.dart';
import 'package:vocabualize/src/features/details/presentation/widgets/replace_vocabulary_dialog.dart';

final detailsControllerProvider =
    AutoDisposeAsyncNotifierProviderFamily<DetailsController, DetailsState, Vocabulary?>(() {
  return DetailsController();
});

class DetailsController extends AutoDisposeFamilyAsyncNotifier<DetailsState, Vocabulary?> {
  @override
  Future<DetailsState> build(Vocabulary? arg) async {
    final vocabulary = arg ?? Vocabulary();
    return DetailsState(
      vocabulary: vocabulary,
      customOrDraftImage: vocabulary.image.takeIf((i) => i is CustomImage || i is DraftImage),
      stockImages: await _getStockImages(vocabulary),
      areCollectionsEnabled: await ref.watch(getAreCollectionsEnabledUseCaseProvider.future),
      areImagesDisabled: await ref.watch(getAreImagesDisabledUseCaseProvider.future),
    );
  }

  Future<void> openEditSourceDialog(BuildContext context) async {
    state.value?.let((value) async {
      final Vocabulary? updatedVocabulary = await context.showDialog(
        EditSourceTargetDialog(
          vocabulary: value.vocabulary,
        ),
      );
      if (!context.mounted) return;
      if (updatedVocabulary == null) return;
      if (updatedVocabulary.source == value.vocabulary.source) return;
      bool? hasClickedRetranslate = await context.showDialog(
        const ReplaceVocabularyDialog(),
      );
      if (!context.mounted) return;
      if (hasClickedRetranslate == true) {
        _retranslateAndReload(context, updatedVocabulary);
      } else {
        state = AsyncData(value.copyWith(vocabulary: updatedVocabulary));
      }
    });
  }

  Future<void> _retranslateAndReload(
    BuildContext context,
    Vocabulary vocabulary,
  ) async {
    final translate = ref.read(translateUseCaseProvider);
    final retranslatedVocabulary = vocabulary.copyWith(
      target: await translate(vocabulary.source),
    );
    if (!context.mounted) return;
    context.popAndPushNamed(
      DetailsScreen.routeName,
      arguments: DetailsScreenArguments(vocabulary: retranslatedVocabulary),
    );
  }

  Future<void> openEditTargetDialog(BuildContext context) async {
    state.value?.let((value) async {
      final Vocabulary? updatedVocabulary = await context.showDialog(
        EditSourceTargetDialog(
          vocabulary: value.vocabulary,
          editTarget: true,
        ),
      );
      if (!context.mounted) return;
      if (updatedVocabulary == null) return;
      if (updatedVocabulary.target == value.vocabulary.target) return;
      state = AsyncData(value.copyWith(vocabulary: updatedVocabulary));
    });
  }

  Future<List<StockImage>> _getStockImages(Vocabulary vocabulary) async {
    final searchTerm = Formatter.filterOutArticles(
      await ref.read(
        translateToEnglishUseCaseProvider(vocabulary.source).future,
      ),
    );
    return await ref.read(getStockImagesUseCaseProvider(searchTerm).future);
  }

  void browseNext() {
    state.value?.let((value) {
      if (value.lastStockImageIndex + value.stockImagesPerPage < value.totalStockImages) {
        state = AsyncData(value.copyWith(
          firstStockImageIndex: value.firstStockImageIndex + value.stockImagesPerPage,
          lastStockImageIndex: value.lastStockImageIndex + value.stockImagesPerPage,
        ));
      } else {
        state = AsyncData(value.copyWith(
          firstStockImageIndex: 0,
          lastStockImageIndex: 6,
        ));
      }
    });
  }

  Future<void> getDraftImage(BuildContext context) async {
    state.value?.let((value) async {
      final imageSource = await context.showDialog(
        const CameraGalleryDialog(),
      );
      if (imageSource == null) return;
      if (imageSource is! ImageSource) return;
      final newImage = await ref.read(getDraftImageUseCaseProvider.future);
      final newImageFile = await newImage(imageSource: imageSource);
      newImageFile?.let((image) {
        state = AsyncData(value.copyWith(
          vocabulary: value.vocabulary.copyWith(image: image),
          customOrDraftImage: image,
        ));
      });
    });
  }

  Future<void> openPhotographerLink() async {
    state.value?.let((value) async {
      final image = value.vocabulary.image;
      if (image is! StockImage) return;
      final photographerUrl = image.photographerUrl;
      if (photographerUrl == null) return;
      await launchUrl(
        Uri.parse(photographerUrl),
        mode: LaunchMode.externalApplication,
      );
    });
  }

  void selectOrUnselectImage(VocabularyImage? image) {
    if (image == null) return;
    state.value?.let((value) {
      final newImage = value.vocabulary.image == image ? const FallbackImage() : image;
      state = AsyncData(
        value.copyWith(
          vocabulary: value.vocabulary.copyWith(image: newImage),
          customOrDraftImage: newImage.takeIf((i) => i is CustomImage || i is DraftImage),
        ),
      );
    });
  }

  Future<void> openCreateTagDialogAndSave(BuildContext context) async {
    state.value?.let((value) async {
      final String? tagName = await context.showDialog(
        const AddTagDialog(),
      );
      if (!context.mounted) return;
      if (tagName == null) return;
      if (tagName.isEmpty) return;
      final addOrUpdateTag = await ref.read(addOrUpdateTagProvider.future);
      final tagId = await addOrUpdateTag(Tag(name: tagName));
      addOrRemoveTag(tagId);
    });
  }

  Future<void> addOrRemoveTag(String? tagId) async {
    if (tagId == null) return;
    final tagIds = state.valueOrNull?.vocabulary.tagIds;
    if (tagIds == null) return;
    final updatedTagIds = switch (tagIds.contains(tagId)) {
      true => tagIds.where((id) => id != tagId).toList(),
      false => [...tagIds, tagId],
    };
    update((current) {
      return current.copyWith(
        vocabulary: current.vocabulary.copyWith(tagIds: updatedTagIds),
      );
    });
    ref.invalidate(getAllTagsUseCaseProvider);
    ref.invalidate(getTagsByIdsUseCaseProvider);
  }

  void deleteVocabulary(BuildContext context) {
    state.value?.let((value) {
      ref.read(deleteVocabularyUseCaseProvider(value.vocabulary));
      context.pop();
    });
  }

  Future<void> save(BuildContext context) async {
    state.value?.let((value) async {
      await ref.read(addOrUpdateVocabularyUseCaseProvider(value.vocabulary));
      ref.invalidate(getVocabulariesUseCaseProvider);
      ref.invalidate(getNewVocabulariesUseCaseProvider);
      if (context.mounted) {
        context.popUntilNamed(Start.routeName);
      }
    });
  }
}
