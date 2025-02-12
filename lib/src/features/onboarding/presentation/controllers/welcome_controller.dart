import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocabualize/src/common/domain/entities/alert.dart';
import 'package:vocabualize/src/common/domain/entities/auth_provider.dart';
import 'package:vocabualize/src/common/domain/extensions/object_extensions.dart';
import 'package:vocabualize/src/common/domain/use_cases/alerts/get_alerts_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/authentication/sign_in_with_github_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/authentication/sign_in_with_google_use_case.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/features/onboarding/presentation/states/welcome_state.dart';
import 'package:vocabualize/src/features/onboarding/presentation/widgets/wrong_provider_dialog.dart';

final welcomeControllerProvider =
    AutoDisposeAsyncNotifierProvider<WelcomeController, WelcomeState>(() {
  return WelcomeController();
});

class WelcomeController extends AutoDisposeAsyncNotifier<WelcomeState> {
  @override
  Future<WelcomeState> build() async {
    final welcomeAlerts = await ref.watch(getAlertsUseCaseProvider(AlertPosition.welcome).future);
    return WelcomeState(
      latestAlert: welcomeAlerts.firstOrNull,
    );
  }

  Future<void> signInWithGithub(BuildContext context) {
    return _signInWithOAuth(context, AuthProvider.github);
  }

  Future<void> signInWithGoogle(BuildContext context) {
    return _signInWithOAuth(context, AuthProvider.google);
  }

  Future<void> _signInWithOAuth(
    BuildContext context,
    AuthProvider provider,
  ) async {
    state.value?.let((value) {
      state = AsyncData(value.copyWith(loadingProvider: provider));
    });
    Future<void> callback(Uri uri) async {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      ).then((_) {
        state.value?.let((value) {
          state = AsyncData(
            value.copyWith(loadingProvider: AuthProvider.none),
          );
        });
      });
    }

    AuthProvider? linkedProvider = switch (provider) {
      AuthProvider.github => await ref.read(signInWithGithubUseCaseProvider)(callback),
      AuthProvider.google => await ref.read(signInWithGoogleUseCaseProvider)(callback),
      _ => null,
    };
    if (linkedProvider != null && provider != linkedProvider && context.mounted) {
      context.showDialog(WrongProviderDialog(linkedProvider: linkedProvider));
    }
  }
}
