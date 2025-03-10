import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/authentication_repository_impl.dart';
import 'package:vocabualize/src/common/domain/repositories/authentication_repository.dart';

final signInAnonymouslyUseCaseProvider = Provider((ref) {
  return SignInAnonymouslyUseCase(
    authenticationRepository: ref.watch(authenticationRepositoryProvider),
  );
});

class SignInAnonymouslyUseCase {
  final AuthenticationRepository _authenticationRepository;

  const SignInAnonymouslyUseCase({
    required AuthenticationRepository authenticationRepository,
  }) : _authenticationRepository = authenticationRepository;

  Future<String?> call() async {
    return await _authenticationRepository.signInAnonymously();
  }
}
