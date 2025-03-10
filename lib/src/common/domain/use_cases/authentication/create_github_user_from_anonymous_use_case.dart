import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/authentication_repository_impl.dart';
import 'package:vocabualize/src/common/domain/repositories/authentication_repository.dart';

final createGithubUserFromAnonymousUseCaseProvider = Provider((ref) {
  return CreateGithubUserFromAnonymousUseCase(
    authenticationRepository: ref.watch(authenticationRepositoryProvider),
  );
});

class CreateGithubUserFromAnonymousUseCase {
  final AuthenticationRepository _authenticationRepository;

  const CreateGithubUserFromAnonymousUseCase({
    required AuthenticationRepository authenticationRepository,
  }) : _authenticationRepository = authenticationRepository;

  Future<bool> call(void Function(Uri) urlCallback) async {
    return await _authenticationRepository.createGithubUserFromAnonymous(urlCallback);
  }
}
