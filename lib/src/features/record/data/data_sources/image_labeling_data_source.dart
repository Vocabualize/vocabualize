import 'package:flutter_image_compress/flutter_image_compress.dart';

abstract interface class ImageLabelingDataSource {
  Future<Map<String, double>> getLabelsFromImage(XFile file, {String? languageName = "en"});
}
