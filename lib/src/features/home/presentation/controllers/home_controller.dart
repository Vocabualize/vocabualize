import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_google_dialog/speech_to_text_google_dialog.dart';
import 'package:vocabualize/constants/tracking_constants.dart';
import 'package:vocabualize/src/common/domain/entities/alert.dart';
import 'package:vocabualize/src/common/domain/entities/tag.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary.dart';
import 'package:vocabualize/src/common/domain/entities/vocabulary_image.dart';
import 'package:vocabualize/src/common/domain/use_cases/alerts/get_alerts_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/authentication/get_current_user_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/language/read_out_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_are_collections_enabled_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_are_images_disabled_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_source_language_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_target_language_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/tag/get_all_tags_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/tracking/track_event_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/translator/translate_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/vocabulary/get_new_vocabularies_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/vocabulary/get_vocabularies_use_case.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/features/collections/presentation/screens/collection_screen.dart';
import 'package:vocabualize/src/features/details/presentation/screens/details_screen.dart';
import 'package:vocabualize/src/features/home/presentation/extentions/date_time_extensions.dart';
import 'package:vocabualize/src/features/home/presentation/states/home_state.dart';
import 'package:vocabualize/src/common/presentation/widgets/vocabulary_info_dialog.dart';
import 'package:vocabualize/src/features/record/presentation/screens/record_screen.dart';
import 'package:vocabualize/src/common/presentation/widgets/text_input_dialog.dart';
import 'package:vocabualize/src/features/settings/presentation/screens/settings_screen.dart';

final homeControllerProvider = AutoDisposeAsyncNotifierProvider<HomeController, HomeState>(() {
  return HomeController();
});

class HomeController extends AutoDisposeAsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final streak = await ref.watch(getCurrentUserUseCaseProvider.selectAsync((u) {
      return u?.streak ?? 0;
    }));
    final lastActive = await ref.watch(getCurrentUserUseCaseProvider.selectAsync((u) {
      return u?.lastActive;
    }));
    final isStreakActive = streak > 0 && lastActive != null && lastActive.isToday();
    return HomeState(
      streak: streak,
      isStreakActive: isStreakActive,
      alerts: await ref.watch(getAlertsUseCaseProvider(AlertPosition.home).future),
      vocabularies: ref.watch(getVocabulariesUseCaseProvider)(),
      newVocabularies: ref.watch(getNewVocabulariesUseCaseProvider),
      tags: await ref.watch(getAllTagsUseCaseProvider.future),
      areCollectionsEnabled: await ref.watch(getAreCollectionsEnabledUseCaseProvider.future),
      areImagesDisabled: await ref.watch(getAreImagesDisabledUseCaseProvider.future),
    );
  }

  void goToRecordScanScreen(BuildContext context) {
    context.pushNamed(RecordScreen.routeName);
  }

  Future<void> speakAndGoToDetails(BuildContext context) async {
    final sourceLanguage = await ref.read(getSourceLanguageUseCaseProvider);

    // TODO: Replace SpeechToTextGoogleDialog with platform independent solution
    // * SpeechToTextGoogleDialog works for Android only
    await SpeechToTextGoogleDialog.getInstance().showGoogleDialog(
      onTextReceived: (text) async {
        _translateAndGoToDetails(context, text);
        ref.read(trackEventUseCaseProvider)(TrackingConstants.gatherSpeak);
      },
      locale: sourceLanguage.textToSpeechId,
    );
  }

  Future<void> writeAndGoToDetails(BuildContext context) async {
    context.showDialog(TextInputDialog(
      onCancel: context.pop,
      onSave: (text) {
        context.pop();
        _translateAndGoToDetails(context, text);
        ref.read(trackEventUseCaseProvider)(TrackingConstants.gatherWrite);
      },
    ));
  }

  Future<void> _translateAndGoToDetails(BuildContext context, String text) async {
    if (text.isEmpty) return;
    final sourceLanguage = await ref.read(getSourceLanguageUseCaseProvider);
    final targetLanguage = await ref.read(getTargetLanguageUseCaseProvider);
    Vocabulary draftVocabulary = Vocabulary(
      source: text,
      target: await ref.read(translateUseCaseProvider)(text),
      sourceLanguageId: sourceLanguage.id,
      targetLanguageId: targetLanguage.id,
      image: const FallbackImage(),
    );
    if (draftVocabulary.isValid && context.mounted) {
      context.pushNamed(
        DetailsScreen.routeName,
        arguments: DetailsScreenArguments(vocabulary: draftVocabulary),
      );
    }
  }

  void readOut(Vocabulary vocabulary) {
    ref.read(readOutUseCaseProvider)(vocabulary);
  }

  void showVocabularyInfo(BuildContext context, Vocabulary vocabulary) {
    context.showDialog(VocabularyInfoDialog(vocabulary: vocabulary));
  }

  void goToDetails(BuildContext context, Vocabulary vocabulary) {
    context.pushNamed(
      DetailsScreen.routeName,
      arguments: DetailsScreenArguments(vocabulary: vocabulary),
    );
  }

  void showSettings(BuildContext context) {
    context.pushNamed(SettingsScreen.routeName);
  }

  void goToCollection(BuildContext context, Tag tag) {
    context.pushNamed(
      CollectionScreen.routeName,
      arguments: CollectionScreenArguments(tag: tag),
    );
  }
}
