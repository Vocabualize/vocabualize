import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/tracking_repository_impl.dart';
import 'package:vocabualize/src/common/domain/repositories/tracking_repository.dart';

final trackEventUseCaseProvider = AutoDisposeProvider((ref) {
  return TrackEventUseCase(
    trackingRepository: ref.watch(trackingRepositoryProvider),
  );
});

class TrackEventUseCase {
  final TrackingRepository _trackingRepository;

  TrackEventUseCase({
    required TrackingRepository trackingRepository,
  }) : _trackingRepository = trackingRepository;

  Future<void> call(String name) async {
    await _trackingRepository.trackEvent(name);
  }
}
