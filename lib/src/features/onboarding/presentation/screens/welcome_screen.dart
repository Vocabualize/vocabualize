import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vocabualize/constants/asset_path.dart';
import 'package:vocabualize/constants/common_constants.dart';
import 'package:vocabualize/constants/dimensions.dart';
import 'package:vocabualize/src/common/domain/entities/auth_provider.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/common/presentation/screens/loading_screen.dart';
import 'package:vocabualize/src/common/presentation/widgets/alert_container.dart';
import 'package:vocabualize/src/features/onboarding/presentation/controllers/welcome_controller.dart';
import 'package:vocabualize/src/features/onboarding/presentation/widgets/provider_button.dart';

class WelcomeScreen extends ConsumerWidget {
  static const routeName = "/Onboarding";
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = welcomeControllerProvider;
    final notifier = welcomeControllerProvider.notifier;
    final asyncValue = ref.watch(provider);

    return asyncValue.when(
      loading: () => const LoadingScreen(),
      error: (error, stackTrace) {
        // TODO: Replace with Error widget
        return Center(child: Text(error.toString()));
      },
      data: (state) {
        final latestAlert = state.latestAlert;
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primary,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.extraLargeSpacing,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: Dimensions.extraLargeSpacing),
                  Text(
                    CommonConstants.appName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                  const SizedBox(height: Dimensions.semiSmallSpacing),
                  if (latestAlert != null) ...[
                    AlertContainer(alert: latestAlert),
                    const SizedBox(height: Dimensions.largeSpacing),
                  ],
                  Expanded(
                    child: Image.asset(
                      AssetPath.mascotIdle,
                      frameBuilder: (_, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded) return child;
                        return AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.fastOutSlowIn,
                          opacity: frame == null ? 0 : 1,
                          child: child,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: Dimensions.semiLargeSpacing),
                  ProviderButton(
                    onPressed: () => ref.read(notifier).signInWithGithub(context),
                    icon: SvgPicture.asset(AssetPath.icGithub),
                    title: context.s.onboarding_use_github,
                    isLoading: state.loadingProvider == AuthProvider.github,
                  ),
                  const SizedBox(height: Dimensions.mediumSpacing),
                  ProviderButton(
                    onPressed: () => ref.read(notifier).signInWithGoogle(context),
                    icon: SvgPicture.asset(AssetPath.icGoogle),
                    title: context.s.onboarding_use_google,
                    isLoading: state.loadingProvider == AuthProvider.google,
                  ),
                  const SizedBox(height: Dimensions.mediumSpacing),
                  OutlinedButton(
                    onPressed: ref.read(notifier).signInAnonymously,
                    child: Text(context.s.onboarding_anonymous),
                  ),
                  const SizedBox(height: Dimensions.largeSpacing),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
