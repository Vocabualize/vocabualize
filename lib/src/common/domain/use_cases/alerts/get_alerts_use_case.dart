import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/alert_repository_impl.dart';
import 'package:vocabualize/src/common/domain/entities/alert.dart';
import 'package:vocabualize/src/common/domain/repositories/alert_repository.dart';

final getAlertsUseCaseProvider = AutoDisposeFutureProviderFamily((ref, AlertPosition position) {
  return GetAlertsUseCase(
    alertRepository: ref.watch(alertRepositoryProvider),
  ).call(position: position);
});

class GetAlertsUseCase {
  final AlertRepository _alertRepository;

  GetAlertsUseCase({
    required AlertRepository alertRepository,
  }) : _alertRepository = alertRepository;

  Future<List<Alert>> call({required AlertPosition position}) async {
    return await _alertRepository.getAlerts(position: position);
  }
}
