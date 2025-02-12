import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/domain/entities/language.dart';
import 'package:vocabualize/src/common/domain/extensions/object_extensions.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_source_language_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/get_target_language_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/set_source_language_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/set_target_language_use_case.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/common/presentation/screens/language_picker_screen.dart';
import 'package:vocabualize/src/features/onboarding/presentation/states/choose_languages_state.dart';

final chooseLanguagesControllerProvider =
    AutoDisposeAsyncNotifierProvider<ChooseLanguagesController, ChooseLanguagesState>(() {
  return ChooseLanguagesController();
});

class ChooseLanguagesController extends AutoDisposeAsyncNotifier<ChooseLanguagesState> {
  @override
  Future<ChooseLanguagesState> build() async {
    return ChooseLanguagesState(
      selectedSourceLanguage: await ref.watch(getSourceLanguageUseCaseProvider),
      selectedTargetLanguage: await ref.watch(getTargetLanguageUseCaseProvider),
    );
  }

  Future<void> openPickerAndSelectSourceLanguage(BuildContext context) async {
    final seletectedLanguage = await context.pushNamed(LanguagePickerScreen.routeName) as Language?;

    if (seletectedLanguage == null) return;

    state.value?.let((value) {
      state = AsyncData(
        value.copyWith(selectedSourceLanguage: seletectedLanguage),
      );
    });
  }

  Future<void> openPickerAndSelectTargetLanguage(BuildContext context) async {
    final seletectedLanguage = await context.pushNamed(LanguagePickerScreen.routeName) as Language?;

    if (seletectedLanguage == null) return;

    state.value?.let((value) {
      state = AsyncData(
        value.copyWith(selectedTargetLanguage: seletectedLanguage),
      );
    });
  }

  Future<void> done(BuildContext context) async {
    state.value?.let((value) async {
      await ref
          .read(setSourceLanguageUseCaseProvider(value.selectedSourceLanguage))
          .then((_) async {
        await ref
            .read(setTargetLanguageUseCaseProvider(value.selectedTargetLanguage))
            .then((_) => context.pop());
      });
    });
  }
}
