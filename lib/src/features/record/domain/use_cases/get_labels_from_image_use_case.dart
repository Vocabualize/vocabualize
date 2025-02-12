import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/common/data/repositories/settings_repository_impl.dart';
import 'package:vocabualize/src/common/domain/repositories/settings_repository.dart';
import 'package:vocabualize/src/features/record/data/repositories/image_labeling_repository_impl.dart';
import 'package:vocabualize/src/features/record/domain/repositories/image_labeling_repository.dart';

final getLabelsFromImageUseCaseProvider = AutoDisposeProvider((ref) {
  return GetLabelsFromImageUseCase(
    imageLabelingRepository: ref.watch(imageLabelingRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
  );
});

class GetLabelsFromImageUseCase {
  final ImageLabelingRepository _imageLabelingRepository;
  final SettingsRepository _settingsRepository;

  const GetLabelsFromImageUseCase({
    required ImageLabelingRepository imageLabelingRepository,
    required SettingsRepository settingsRepository,
  })  : _imageLabelingRepository = imageLabelingRepository,
        _settingsRepository = settingsRepository;

  Future<Map<String, double>> call(XFile file) async {
    final soureLanguage = await _settingsRepository.getSourceLanguage();
    return await _imageLabelingRepository.getLabelsFromImage(
      file,
      languageName: soureLanguage.name,
    );
  }
}
