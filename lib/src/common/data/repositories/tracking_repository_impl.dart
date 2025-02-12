import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/data_sources/remote_database_data_source.dart';
import 'package:vocabualize/src/common/data/models/rdb_practice_iteration.dart';
import 'package:vocabualize/src/common/domain/repositories/tracking_repository.dart';

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  return TrackingRepositoryImpl(
    remoteDatabaseDataSource: ref.watch(remoteDatabaseDataSourceProvider),
  );
});

class TrackingRepositoryImpl implements TrackingRepository {
  final RemoteDatabaseDataSource _remoteDatabaseDataSource;

  const TrackingRepositoryImpl({
    required RemoteDatabaseDataSource remoteDatabaseDataSource,
  }) : _remoteDatabaseDataSource = remoteDatabaseDataSource;

  @override
  Future<void> trackEvent(String name) async {
    await _remoteDatabaseDataSource.trackEvent(name);
  }

  @override
  Future<void> trackPracticeIteration(int practicedCount, int dueCount) async {
    final iteration = RdbPracticeIteration(practicedCount: practicedCount, dueCount: dueCount);
    await _remoteDatabaseDataSource.trackPracticeIteration(iteration);
  }
}
