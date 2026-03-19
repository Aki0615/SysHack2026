import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// セキュアストレージのプロバイダー（トークン保存に使用）
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Dioインスタンスのプロバイダー
/// 全APIリクエストに共通のベースURLとAuthorizationヘッダーを付与する
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      // TODO: 実際のAPIサーバーURLに変更すること
      baseUrl: 'https://api.streetpass.example.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  final storage = ref.read(secureStorageProvider);

  // インターセプターで全リクエストにBearerトークンを自動付与する
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // 401エラー（認証切れ）の場合にトークンを削除してログイン画面へ戻す処理を追加可能
        handler.next(error);
      },
    ),
  );

  return dio;
});
