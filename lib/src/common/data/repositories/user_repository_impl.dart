import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/data_sources/remote_database_data_source.dart';
import 'package:vocabualize/src/common/domain/entities/app_user.dart';
import 'package:vocabualize/src/common/domain/repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    remoteDatabaseDataSource: ref.watch(remoteDatabaseDataSourceProvider),
  );
});

class UserRepositoryImpl implements UserRepository {
  final RemoteDatabaseDataSource _remoteDatabaseDataSource;
  const UserRepositoryImpl({
    required RemoteDatabaseDataSource remoteDatabaseDataSource,
  }) : _remoteDatabaseDataSource = remoteDatabaseDataSource;

  @override
  Future<AppUser?> getUser() {
    return _remoteDatabaseDataSource.getUser().then((user) {
      return user;
    });
  }

  @override
  Future<void> updateUser(AppUser user) {
    return _remoteDatabaseDataSource.updateUser(
      sourceLanguageId: user.sourceLanguageId,
      targetLanguageId: user.targetLanguageId,
      keepData: user.keepData,
    );
  }
}
