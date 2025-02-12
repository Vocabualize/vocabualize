import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/features/record/data/data_sources/image_labeling_data_source.dart';
import 'package:vocabualize/src/features/record/data/data_sources/remote_image_labeling_impl_data_source.dart';
import 'package:vocabualize/src/features/record/domain/repositories/image_labeling_repository.dart';

final imageLabelingRepositoryProvider = Provider<ImageLabelingRepository>((ref) {
  return ImageLabelingRepositoryImpl(
    imageLabelingDataSource: ref.watch(remoteImageLabelingDataSourceProvider),
  );
});

class ImageLabelingRepositoryImpl implements ImageLabelingRepository {
  final ImageLabelingDataSource _imageLabelingDataSource;

  const ImageLabelingRepositoryImpl({
    required ImageLabelingDataSource imageLabelingDataSource,
  }) : _imageLabelingDataSource = imageLabelingDataSource;

  @override
  Future<Map<String, double>> getLabelsFromImage(XFile file, {String? languageName}) async {
    return await _imageLabelingDataSource.getLabelsFromImage(file, languageName: languageName);
  }
}
