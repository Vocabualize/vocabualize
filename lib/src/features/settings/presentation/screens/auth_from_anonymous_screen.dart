import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vocabualize/constants/asset_path.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/src/common/domain/entities/auth_provider.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/features/onboarding/presentation/widgets/provider_button.dart';
import 'package:vocabualize/src/features/settings/presentation/controllers/auth_from_anonymous_controller.dart';
import 'package:vocabualize/src/features/settings/presentation/screens/settings_screen.dart';

class AuthFromAnonymousScreen extends ConsumerWidget {
  static const String routeName = "/${SettingsScreen.routeName}/AuthFromAnonymous";
  const AuthFromAnonymousScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = authFromAnonymousControllerProvider;
    final notifier = provider.notifier;

    final loadingProvider = ref.watch(
      provider.select((state) => state.valueOrNull?.loadingProvider ?? AuthProvider.none),
    );
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.surface),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.largeSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: Dimensions.extraLargeSpacing),
            Text(
              context.s.settings_sign_in_hint,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.extraExtraLargeSpacing),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    alignment: Alignment.centerRight,
                    AssetPath.mascotWaving,
                    frameBuilder: (_, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) return child;
                      return ClipRRect(
                        clipBehavior: Clip.hardEdge,
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.fastEaseInToSlowEaseOut,
                          offset: frame == null ? const Offset(1, 0) : Offset.zero,
                          child: child,
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(Dimensions.smallBorderRadius),
                    ),
                    width: Dimensions.largeBorderWidth,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.extraExtraLargeSpacing),
            ProviderButton(
              onPressed: () => ref.read(notifier).signInWithGithub(context),
              icon: SvgPicture.asset(AssetPath.icGithub),
              title: context.s.onboarding_use_github,
              isLoading: loadingProvider == AuthProvider.github,
            ),
            const SizedBox(height: Dimensions.mediumSpacing),
            ProviderButton(
              onPressed: () => ref.read(notifier).signInWithGoogle(context),
              icon: SvgPicture.asset(AssetPath.icGoogle),
              title: context.s.onboarding_use_google,
              isLoading: loadingProvider == AuthProvider.google,
            ),
            const SizedBox(height: Dimensions.extraExtraLargeSpacing),
          ],
        ),
      ),
    );
  }
}
