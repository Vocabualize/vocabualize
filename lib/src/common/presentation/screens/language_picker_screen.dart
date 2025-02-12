import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:log/log.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/src/common/domain/entities/language.dart';
import 'package:vocabualize/src/common/domain/use_cases/language/get_available_languages_use_case.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/common/presentation/extensions/language_extensions.dart';

class LanguagePickerScreen extends ConsumerWidget {
  static const String routeName = "/LanguagePickerScreen";

  const LanguagePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final getAvailableLanguages = ref.watch(getAvailableLanguagesUseCaseProvider);

    void returnLanguage(Language language) {
      context.pop(language);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.s.common_select_language),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.mediumSpacing,
        ),
        child: getAvailableLanguages.when(
          loading: () {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          },
          error: (error, stackTrace) {
            Log.error(
              "Error LanguagePickerScreen: $error",
              exception: stackTrace,
            );
            // TODO: Replace with error widget
            return const Text("Error LanguagePickerScreen");
          },
          data: (List<Language> languages) {
            return GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                top: Dimensions.mediumSpacing,
                bottom: Dimensions.scrollEndSpacing,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: languages.length == 1 ? 1 : 2,
                childAspectRatio: 2 / 1,
                mainAxisSpacing: Dimensions.smallSpacing,
                crossAxisSpacing: Dimensions.smallSpacing,
              ),
              itemCount: languages.length,
              itemBuilder: (context, index) {
                return _LanguageCard(
                  language: languages.elementAt(index),
                  onClick: returnLanguage,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final Language language;
  final void Function(Language) onClick;
  const _LanguageCard({
    required this.language,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // ? enabled: languages.elementAt(index) != selectedLanguage,
      onTap: () {
        onClick(language);
      },
      tileColor: Theme.of(context).colorScheme.surface,
      titleAlignment: ListTileTitleAlignment.center,
      title: Text(language.localName(context)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.mediumBorderRadius),
      ),
    );
  }
}
