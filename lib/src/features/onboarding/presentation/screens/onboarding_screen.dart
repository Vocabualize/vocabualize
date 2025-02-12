import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/src/common/domain/use_cases/settings/set_has_seen_onboarding_use_case.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';

class OnboardingScreen extends ConsumerWidget {
  static const routeName = "/onboarding";
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void accept() async {
      await ref.read(setHasSeenOnboardingUseCaseProvider)(true).then((_) {
        context.pop();
      });
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.largeSpacing,
        ),
        child: Column(
          children: [
            Expanded(
              child: ShaderMask(
                blendMode: BlendMode.dstOut,
                shaderCallback: (Rect rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Theme.of(context).colorScheme.surface],
                    stops: const [0.9, 1.0],
                  ).createShader(rect);
                },
                child: ListView(
                  children: [
                    const SizedBox(height: Dimensions.semiUltraLargeSpacing),
                    Text(
                      context.s.onboarding_title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: Dimensions.mediumSpacing),
                    Text(
                      context.s.onboarding_description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: Dimensions.largeSpacing),
                    Text(
                      context.s.onboarding_hints,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                          ),
                    ),
                    const SizedBox(height: Dimensions.largeSpacing),
                    Text(
                      context.s.onboarding_open_source,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: Dimensions.extraLargeSpacing),
                    Text(
                      context.s.onboarding_final_words,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: Dimensions.extraExtraLargeSpacing),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Dimensions.mediumSpacing),
            ElevatedButton(
              onPressed: accept,
              child: Text(context.s.onboarding_accept_button),
            ),
            const SizedBox(height: Dimensions.extraLargeSpacing),
          ],
        ),
      ),
    );
  }
}
