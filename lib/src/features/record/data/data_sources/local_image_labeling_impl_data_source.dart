import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabualize/src/features/record/data/data_sources/image_labeling_data_source.dart';

final localImageLabelingDataSourceProvider = Provider<ImageLabelingDataSource>((ref) {
  return LocalImageLabelingDataSourceImpl();
});

class LocalImageLabelingDataSourceImpl implements ImageLabelingDataSource {
  @override
  Future<Map<String, double>> getLabelsFromImage(XFile file, {String? languageName}) async {
    /*
    // * Ensure that model asset is added at pubspec.yaml
    final modelPath = await _getModelPath(AssetPath.mlModel);
    final options = LocalLabelerOptions(
      modelPath: modelPath,
      confidenceThreshold: 0.1,
      maxCount: 10,
    );
    final imageLabeler = ImageLabeler(options: options);
    final inputImage = InputImage.fromFilePath(file.path);
    final proccesedlabels = await imageLabeler.processImage(inputImage);
    return Map.fromEntries(proccesedlabels.map((e) => MapEntry(e.label.trim(), e.confidence)));
    */
    return {};
  }

  /*
  Future<String> _getModelPath(String asset) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$asset';
    await Directory(p.dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );
    }
    return file.path;
  }
  */
}
