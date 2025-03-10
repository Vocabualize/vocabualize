import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/authentication_repository_impl.dart';
import 'package:vocabualize/src/common/domain/repositories/authentication_repository.dart';

final createGooglebUserFromAnonymousUseCaseProvider = Provider((ref) {
  return CreateGoogleUserFromAnonymousUseCase(
    authenticationRepository: ref.watch(authenticationRepositoryProvider),
  );
});

class CreateGoogleUserFromAnonymousUseCase {
  final AuthenticationRepository _authenticationRepository;

  const CreateGoogleUserFromAnonymousUseCase({
    required AuthenticationRepository authenticationRepository,
  }) : _authenticationRepository = authenticationRepository;

  Future<bool> call(void Function(Uri) urlCallback) async {
    return await _authenticationRepository.createGoogleUserFromAnonymous(urlCallback);
  }
}
