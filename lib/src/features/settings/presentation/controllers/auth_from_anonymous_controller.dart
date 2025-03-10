import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocabualize/src/common/domain/entities/auth_provider.dart';
import 'package:vocabualize/src/common/domain/use_cases/authentication/create_github_user_from_anonymous_use_case.dart';
import 'package:vocabualize/src/common/domain/use_cases/authentication/create_google_user_from_anonymous_use_case.dart';
import 'package:vocabualize/src/common/presentation/extensions/context_extensions.dart';
import 'package:vocabualize/src/features/settings/presentation/states/auth_from_anonymous_state.dart';
import 'package:vocabualize/src/features/settings/presentation/widgets/account_linking_failed_dialog.dart';

final authFromAnonymousControllerProvider =
    AsyncNotifierProvider<AuthFromAnonymousController, AuthFromAnonymousState>(() {
  return AuthFromAnonymousController();
});

class AuthFromAnonymousController extends AsyncNotifier<AuthFromAnonymousState> {
  @override
  Future<AuthFromAnonymousState> build() async {
    return const AuthFromAnonymousState();
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
    update((current) => current.copyWith(loadingProvider: provider));

    Future<void> callback(Uri uri) async {
      await launchUrl(uri).then((_) {
        update((current) => current.copyWith(loadingProvider: AuthProvider.none));
      });
    }

    await switch (provider) {
      AuthProvider.github => ref.read(createGithubUserFromAnonymousUseCaseProvider)(callback),
      AuthProvider.google => ref.read(createGooglebUserFromAnonymousUseCaseProvider)(callback),
      _ => null,
    }
        ?.then((wasSuccessful) {
      if (wasSuccessful) {
        context.pop();
      } else {
        context.showDialog(const AccountLinkingFailedDialog());
      }
    });
  }
}
