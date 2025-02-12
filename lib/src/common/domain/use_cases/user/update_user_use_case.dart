import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/user_repository_impl.dart';
import 'package:vocabualize/src/common/domain/entities/app_user.dart';
import 'package:vocabualize/src/common/domain/repositories/user_repository.dart';

final updateUserUseCaseProvider = Provider<UpdateUserUseCase>((ref) {
  return UpdateUserUseCase(
    userRepository: ref.watch(userRepositoryProvider),
  );
});

class UpdateUserUseCase {
  final UserRepository _userRepository;

  const UpdateUserUseCase({
    required UserRepository userRepository,
  }) : _userRepository = userRepository;

  Future<void> call(AppUser user) async {
    await _userRepository.updateUser(user);
  }
}
