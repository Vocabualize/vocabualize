import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/authentication_repository_impl.dart';
import 'package:vocabualize/src/common/domain/entities/auth_provider.dart';
import 'package:vocabualize/src/common/domain/repositories/authentication_repository.dart';

final signInWithGithubUseCaseProvider = AutoDisposeProvider((ref) {
  return _SignInWithGithubUseCase(
    authenticationRepository: ref.watch(authenticationRepositoryProvider),
  );
});

class _SignInWithGithubUseCase {
  final AuthenticationRepository _authenticationRepository;

  const _SignInWithGithubUseCase({
    required AuthenticationRepository authenticationRepository,
  }) : _authenticationRepository = authenticationRepository;

  Future<AuthProvider?> call(Future<void> Function(Uri) urlCallback) {
    return _authenticationRepository.signInWithGithub(urlCallback);
  }
}
