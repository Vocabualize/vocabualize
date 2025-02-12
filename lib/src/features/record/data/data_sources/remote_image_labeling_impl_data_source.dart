import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:log/log.dart';
import 'package:mime/mime.dart';
import 'package:vocabualize/constants/secrets/gemini_secrets.dart';
import 'package:vocabualize/src/features/record/data/data_sources/image_labeling_data_source.dart';

final remoteImageLabelingDataSourceProvider = Provider<ImageLabelingDataSource>((ref) {
  return RemoteImageLabelingDataSourceImpl();
});

class RemoteImageLabelingDataSourceImpl implements ImageLabelingDataSource {
  final _apiKey = GeminiSecrets.apiKey;
  final _baseModelsUrl = "https://generativelanguage.googleapis.com/v1beta/models";
  final _modelName = "gemini-2.0-flash-lite-preview-02-05";
  final _functionName = "generateContent";

  final _maxTokens = 512;

  final _labelsFieldName = "labels";
  final _termFieldName = "term";
  final _confidenceFieldName = "confidence";

  @override
  Future<Map<String, double>> getLabelsFromImage(XFile file, {String? languageName}) async {
    try {
      final url = "$_baseModelsUrl/$_modelName:$_functionName?key=$_apiKey";

      final imageData = await file.readAsBytes();
      final mimeType = lookupMimeType('', headerBytes: imageData) ?? "image/jpeg";
      final base64Image = base64Encode(imageData);

      final prompt = GeminiSecrets.prompt(languageName ?? "English");

      final requestBody = _buildRequestBody(
        base64Image: base64Image,
        mimeType: mimeType,
        prompt: prompt,
      );

      final inputTokenCount = _estimateTokens(prompt, includeImage: true);

      Log.hint("Request image labels using about $inputTokenCount tokens.\nPrompt:\n$prompt");

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode < 200 && response.statusCode > 299) {
        Log.error("Error getting labels from image", exception: Exception(response.body));
        return {};
      }

      return _parseResponse(response.body);
    } catch (e) {
      Log.error("Error getting labels from image", exception: e);
      return {};
    }
  }

  Map<String, dynamic> _buildRequestBody({
    required String base64Image,
    required String mimeType,
    required String prompt,
  }) {
    return {
      "contents": [
        {
          "parts": [
            {
              "inlineData": {
                "mimeType": mimeType,
                "data": base64Image,
              }
            },
            {"text": prompt},
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": _maxTokens,
        "responseMimeType": "application/json",
        "responseSchema": {
          "type": "object",
          "properties": {
            _labelsFieldName: {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  _termFieldName: {"type": "string"},
                  _confidenceFieldName: {"type": "number"}
                },
                "required": [_termFieldName, _confidenceFieldName]
              }
            }
          },
          "required": [_labelsFieldName]
        }
      }
    };
  }

  Map<String, double> _parseResponse(String responseBody) {
    final jsonResponse = jsonDecode(responseBody);
    final List? candidates = jsonResponse["candidates"];

    if (candidates == null || candidates.isEmpty) {
      Log.warning("No candidates found in response.");
      return {};
    }

    final content = candidates.first["content"];
    final List? parts = content["parts"];

    if (parts == null || parts.isEmpty) {
      Log.warning("No parts found in response.");
      return {};
    }

    final outputText = parts.first["text"];

    final outputTokenCount = _estimateTokens(outputText);
    Log.hint("Received image labels using about $outputTokenCount tokens.\nResponse:\n$outputText");

    final jsonString = _extractJsonString(outputText);
    final parsed = jsonDecode(jsonString);

    final labels = Map.fromEntries(
      (parsed[_labelsFieldName] as List).map(
        (item) => MapEntry(
          item[_termFieldName].toString(),
          (item[_confidenceFieldName] as num).toDouble(),
        ),
      ),
    );
    return labels;
  }

  String _extractJsonString(String rawResponse) {
    final startIndex = rawResponse.indexOf("{");
    final endIndex = rawResponse.lastIndexOf("}");
    return rawResponse.substring(startIndex, endIndex + 1);
  }

  int _estimateTokens(String prompt, {bool includeImage = false}) {
    final imageTokens = includeImage ? 258 : 0;
    final textTokens = prompt.length ~/ 4;
    return imageTokens + textTokens;
  }
}
