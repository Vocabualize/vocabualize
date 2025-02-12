import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vocabualize/src/common/data/data_sources/remote_database_data_source.dart';
import 'package:vocabualize/src/common/data/mappers/alert_mappers.dart';
import 'package:vocabualize/src/common/domain/entities/alert.dart';
import 'package:vocabualize/src/common/domain/repositories/alert_repository.dart';

final alertRepositoryProvider = Provider((ref) {
  return AlertRepositoryImpl(
    remoteDatabaseDataSource: ref.watch(remoteDatabaseDataSourceProvider),
  );
});

class AlertRepositoryImpl implements AlertRepository {
  final RemoteDatabaseDataSource _remoteDatabaseDataSource;

  const AlertRepositoryImpl({
    required RemoteDatabaseDataSource remoteDatabaseDataSource,
  }) : _remoteDatabaseDataSource = remoteDatabaseDataSource;

  @override
  Future<List<Alert>> getAlerts({required AlertPosition position}) async {
    final currentAppVersion = await PackageInfo.fromPlatform().then((it) => it.version);
    final now = DateTime.now();
    return await _remoteDatabaseDataSource.getAlerts().then((rdbAlerts) {
      return rdbAlerts.map((it) => it.toAlert()).nonNulls.where((it) {
        return it.enabled &&
            it.positions.contains(position) &&
            (it.appVersion == null || it.appVersion == currentAppVersion) &&
            now.isAfter(it.start) &&
            now.isBefore(it.end);
      }).toList()
        // * Sort last started first
        ..sort((a, b) => b.start.compareTo(a.start));
    });
  }
}
