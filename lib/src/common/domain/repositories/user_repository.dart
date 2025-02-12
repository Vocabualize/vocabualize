import 'package:vocabualize/src/common/domain/entities/app_user.dart';

abstract interface class UserRepository {
  Future<AppUser?> getUser();
  Future<void> updateUser(AppUser user);
}
