import 'package:vocabualize/src/common/domain/entities/alert.dart';

abstract interface class AlertRepository {
  Future<List<Alert>> getAlerts({required AlertPosition position});
}
