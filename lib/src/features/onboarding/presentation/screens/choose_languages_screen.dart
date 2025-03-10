import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/common/presentation/extensions/language_extensions.dart';
import 'package:vocabualize/src/features/onboarding/presentation/controllers/choose_languages_controller.dart';
import 'package:vocabualize/src/features/onboarding/presentation/screens/welcome_screen.dart';

class ChooseLanguagesScreen extends ConsumerWidget {
  static const String routeName = "${WelcomeScreen.routeName}/ChooseLanguagesScreen";

  final void Function()? onDone;

  const ChooseLanguagesScreen({this.onDone, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.extraLargeSpacing,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Dimensions.extraExtraLargeSpacing),
              Text(
                context.s.onboarding_select_source_language_title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: Dimensions.mediumSpacing),
              const _SourceLanguageButton(),
              const SizedBox(height: Dimensions.largeSpacing),
              Text(
                context.s.onboarding_select_target_language_title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: Dimensions.mediumSpacing),
              const _TargetLanguageButton(),
              const Spacer(),
              const _DoneButton(),
              const SizedBox(height: Dimensions.extraLargeSpacing),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceLanguageButton extends ConsumerWidget {
  const _SourceLanguageButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = chooseLanguagesControllerProvider.notifier;
    final sourceLanguageName = ref.watch(chooseLanguagesControllerProvider.select((state) {
      return state.valueOrNull?.selectedSourceLanguage.localName(context);
    }));
    final hasChosenSourceLanguage = ref.watch(chooseLanguagesControllerProvider.select((state) {
      return state.valueOrNull?.hasChosenSourceLanguage ?? false;
    }));
    return OutlinedButton(
      onPressed: () => ref.read(notifier).openPickerAndSelectSourceLanguage(context),
      child: sourceLanguageName == null
          ? const CircularProgressIndicator.adaptive()
          : Text(
              hasChosenSourceLanguage ? sourceLanguageName : context.s.onboarding_select_language,
            ),
    );
  }
}

class _TargetLanguageButton extends ConsumerWidget {
  const _TargetLanguageButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = chooseLanguagesControllerProvider.notifier;
    final targetLanguageName = ref.watch(chooseLanguagesControllerProvider.select((state) {
      return state.valueOrNull?.selectedTargetLanguage.localName(context);
    }));
    final hasChosenTargetLanguage = ref.watch(chooseLanguagesControllerProvider.select((state) {
      return state.valueOrNull?.hasChosenTargetLanguage ?? false;
    }));
    return OutlinedButton(
      onPressed: () => ref.read(notifier).openPickerAndSelectTargetLanguage(context),
      child: targetLanguageName == null
          ? const CircularProgressIndicator.adaptive()
          : Text(
              hasChosenTargetLanguage ? targetLanguageName : context.s.onboarding_select_language,
            ),
    );
  }
}

class _DoneButton extends ConsumerWidget {
  const _DoneButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = chooseLanguagesControllerProvider.notifier;
    final hasChosenSourceLanguage = ref.watch(chooseLanguagesControllerProvider.select((state) {
      return state.valueOrNull?.hasChosenSourceLanguage ?? false;
    }));
    final hasChosenTargetLanguage = ref.watch(chooseLanguagesControllerProvider.select((state) {
      return state.valueOrNull?.hasChosenTargetLanguage ?? false;
    }));
    final isEnabled = hasChosenSourceLanguage && hasChosenTargetLanguage;
    return ElevatedButton(
      onPressed: isEnabled ? () => ref.read(notifier).done(context) : null,
      child: Text(context.s.onboarding_done_action),
    );
  }
}
