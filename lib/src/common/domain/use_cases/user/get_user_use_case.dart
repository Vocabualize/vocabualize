import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/user_repository_impl.dart';
import 'package:vocabualize/src/common/domain/entities/app_user.dart';
import 'package:vocabualize/src/common/domain/repositories/user_repository.dart';

final getUserUseCaseProvider = AutoDisposeProvider((ref) {
  return GetUserUseCase(
    userRepository: ref.read(userRepositoryProvider),
  ).call();
});

class GetUserUseCase {
  final UserRepository _userRepository;

  const GetUserUseCase({
    required UserRepository userRepository,
  }) : _userRepository = userRepository;

  Future<AppUser?> call() async {
    return _userRepository.getUser();
  }
}
