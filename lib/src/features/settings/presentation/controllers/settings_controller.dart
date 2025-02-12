import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/main.dart';
import 'package:vocabualize/src/common/domain/entities/language.dart';
import 'package:vocabualize/src/common/domain/extensions/object_extensions.dart';
import 'package:vocabualize/src/common/domain/use_cases/authentication/get_current_user_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/authentication/sign_out_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_are_collections_enabled_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_are_images_disabled_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_gather_notification_time_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_practice_notification_time_use_dart.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_source_language_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_target_language_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_use_premium_translator_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/set_are_collections_enabled_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/set_are_images_disabled_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/set_gather_notification_time_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/set_practice_notification_time_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/set_source_language_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/set_target_language_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/set_use_premium_translator_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/user/update_user_use_case.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/common/presentation/screens/language_picker_screen.dart';
import 'package:vocabualize/src/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:vocabualize/src/features/reports/presentation/screens/report_screen.dart';
import 'package:vocabualize/src/features/settings/presentation/states/settings_state.dart';
import 'package:vocabualize/src/features/settings/presentation/widgets/keep_data_info_dialog.dart';

final settingsControllerProvider =
    AutoDisposeAsyncNotifierProvider<SettingsController, SettingsState>(() {
  return SettingsController();
});

class SettingsController extends AutoDisposeAsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() async {
    final currentUser = ref.watch(getCurrentUserUseCaseProvider).value;
    return SettingsState(
      currentUser: currentUser,
      isKeepDataEnabled: currentUser?.keepData ?? false,
      sourceLanguage: await ref.read(getSourceLanguageUseCaseProvider),
      targetLanguage: await ref.read(getTargetLanguageUseCaseProvider),
      areCollectionsEnabled: await ref.read(getAreCollectionsEnabledUseCaseProvider.future),
      areImagesDisabled: await ref.read(getAreImagesDisabledUseCaseProvider.future),
      usePremiumTranslator: await ref.read(getUsePremiumTranslatorUseCaseProvider.future),
      gatherNotificationTime: await ref.read(getGatherNotificationTimeUseCaseProvider),
      practiceNotificationTime: await ref.read(getPracticeNotificationTimeUseCaseProvider),
    );
  }

  Future<void> signIn(BuildContext context) async {
    // TODO: Implement signIn button for SettingsScreen
    // * Basically, this should be a sign out, but keep the data and save all data to a new user
    // ? What happens if user signs in with an existing account? Should we merge the data?
    await ref.watch(signOutUseCaseProvider)().whenComplete(() {
      context.pop();
    });
  }

  Future<void> signOut(BuildContext context) async {
    await ref.read(signOutUseCaseProvider)().whenComplete(() async {
      context.pop();
      ref.read(resetAllProvidersProvider)();
    });
  }

  void goToBugReport(BuildContext context) {
    context.pushNamed(ReportScreen.routeName, arguments: ReportArguments.bug());
  }

  void goToOnboarding(BuildContext context) {
    context.pushNamed(OnboardingScreen.routeName);
  }

  void showKeepDataInfoDialog(BuildContext context) {
    context.showDialog(const KeepDataInfoDialog());
  }

  Future<void> setIsKeepDataEnabled(bool isKeepDataEnabled) async {
    update((previous) => previous.copyWith(isKeepDataEnabled: isKeepDataEnabled)).then((value) {
      value.currentUser?.let((user) {
        return ref.read(updateUserUseCaseProvider)(user.copyWith(keepData: isKeepDataEnabled));
      });
    });
  }

  Future<void> selectSourceLanguage(BuildContext context) async {
    final seletectedLanguage = await context.pushNamed(LanguagePickerScreen.routeName) as Language?;
    seletectedLanguage?.let((language) async {
      await ref.read(setSourceLanguageUseCaseProvider(language));
      update((previous) {
        return previous.copyWith(sourceLanguage: language);
      });
    });
  }

  Future<void> selectTargetLanguage(BuildContext context) async {
    final seletectedLanguage = await context.pushNamed(LanguagePickerScreen.routeName) as Language?;
    seletectedLanguage?.let((language) async {
      await ref.read(setTargetLanguageUseCaseProvider(language));
      update((previous) {
        return previous.copyWith(targetLanguage: language);
      });
    });
  }

  Future<void> setAreCollectionsEnabled(bool areCollectionsEnabled) async {
    await ref.read(setAreCollectionsEnabledUseCaseProvider)(areCollectionsEnabled);
    ref.invalidate(getAreCollectionsEnabledUseCaseProvider);
    update((previous) {
      return previous.copyWith(areCollectionsEnabled: areCollectionsEnabled);
    });
  }

  Future<void> setAreImagesDisabled(bool areImagesDisabled) async {
    await ref.read(setAreImagesDisabledUseCaseProvider(areImagesDisabled).future);
    ref.invalidate(getAreImagesDisabledUseCaseProvider);
    update((previous) {
      return previous.copyWith(areImagesDisabled: areImagesDisabled);
    });
  }

  Future<void> setUsePremiumTranslator(bool usePremiumTranslator) async {
    await ref.read(setUsePremiumTranslatorUseCaseProvider(usePremiumTranslator).future);
    ref.invalidate(getUsePremiumTranslatorUseCaseProvider);
    update((previous) {
      return previous.copyWith(usePremiumTranslator: usePremiumTranslator);
    });
  }

  void openNotificationSettings() {
    AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  Future<void> selectGatherNotificationTime(BuildContext context) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: state.valueOrNull?.gatherNotificationTime ?? TimeOfDay.now(),
    );
    selectedTime?.let((time) async {
      await ref.read(setGatherNotificationTimeUseCaseProvider(time));
      update((previous) {
        return previous.copyWith(gatherNotificationTime: time);
      });
    });
  }

  Future<void> selectPracticeNotificationTime(BuildContext context) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: state.valueOrNull?.practiceNotificationTime ?? TimeOfDay.now(),
    );
    selectedTime?.let((time) async {
      await ref.read(setPracticeNotificationTimeUseCaseProvider(time));
      update((previous) {
        return previous.copyWith(practiceNotificationTime: time);
      });
    });
  }

  void toggleExperimental() {
    update((previous) {
      return previous.copyWith(showExperimental: !previous.showExperimental);
    });
  }
}
