import 'package:camera/camera.dart';

abstract interface class ImageLabelingRepository {
  Future<Map<String, double>> getLabelsFromImage(XFile file, {String? languageName});
}
