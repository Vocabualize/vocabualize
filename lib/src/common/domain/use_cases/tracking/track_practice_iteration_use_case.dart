import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/tracking_repository_impl.dart';
import 'package:vocabualize/src/common/domain/repositories/tracking_repository.dart';

final trackPracticeIterationUseCaseProvider = AutoDisposeProvider((ref) {
  return TrackPracticeIterationUseCase(
    trackingRepository: ref.watch(trackingRepositoryProvider),
  );
});

class TrackPracticeIterationUseCase {
  final TrackingRepository _trackingRepository;

  TrackPracticeIterationUseCase({
    required TrackingRepository trackingRepository,
  }) : _trackingRepository = trackingRepository;

  Future<void> call({required int practicedCount, required int dueCount}) async {
    await _trackingRepository.trackPracticeIteration(practicedCount, dueCount);
  }
}
