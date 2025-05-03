import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceRecognitionService {
  late Interpreter _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('Assets/AiModels/mobilefacenet.tflite');
  }

  Future<List<double>> getEmbedding(File imageFile) async {
    final rawImage = img.decodeImage(await imageFile.readAsBytes());
    final resized = img.copyResize(rawImage!, width: 112, height: 112);
    final input = imageToFloat32List(resized);

    final output = List.filled(192, 0.0).reshape([1, 192]); // embedding size
    _interpreter.run(input, output);
    return List<double>.from(output[0]);
  }

  List<List<List<List<double>>>> imageToFloat32List(img.Image image) {
    return List.generate(
      1,
          (_) => List.generate(
        112,
            (y) => List.generate(
          112,
              (x) {
            final pixel = image.getPixel(x, y);
            return [
              (pixel.r - 128) / 128.0,
              (pixel.g - 128) / 128.0,
              (pixel.b - 128) / 128.0,
            ];
          },
        ),
      ),
    );
  }



  double euclideanDistance(List<double> e1, List<double> e2) {
    double sum = 0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow(e1[i] - e2[i], 2).toDouble();
    }
    return sqrt(sum);
  }

  String? matchEmbedding(
      List<double> query,
      Map<String, List<double>> knownEmbeddings,
      {double threshold = 1.0}
      ) {
    String? bestMatch;
    double minDistance = double.infinity;

    for (final entry in knownEmbeddings.entries) {
      final distance = euclideanDistance(query, entry.value);
      if (distance < minDistance) {
        minDistance = distance;
        bestMatch = entry.key;
      }
    }

    return (minDistance <= threshold) ? bestMatch : null;
  }
}
