import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'models/audd_result_model.dart';

abstract class AuddDataSource {
  Future<AuddResultModel?> identifySong(String audioFilePath);
  Future<AuddResultModel?> identifyFromUrl(String audioUrl);
}

class AuddDataSourceImpl implements AuddDataSource {
  final Dio _dio;
  static const String _baseUrl = 'https://api.audd.io/';

  AuddDataSourceImpl()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ));

  String get _apiKey => dotenv.env['AUDD_API_KEY'] ?? 'demo';

  @override
  Future<AuddResultModel?> identifySong(String audioFilePath) async {
    try {
      final file = File(audioFilePath);
      if (!await file.exists()) return null;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(audioFilePath),
        'api_token': _apiKey,
        'return': 'spotify',
      });
      final response = await _dio.post('', data: formData);
      final result = response.data['result'] as Map<String, dynamic>?;
      if (result == null) return null;
      return AuddResultModel.fromJson(result);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuddResultModel?> identifyFromUrl(String audioUrl) async {
    try {
      final response = await _dio.post('', data: {
        'url': audioUrl,
        'api_token': _apiKey,
        'return': 'spotify',
      });
      final result = response.data['result'] as Map<String, dynamic>?;
      if (result == null) return null;
      return AuddResultModel.fromJson(result);
    } catch (_) {
      return null;
    }
  }
}
