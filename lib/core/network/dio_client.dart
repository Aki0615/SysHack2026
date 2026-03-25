import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// セキュアストレージのプロバイダー（ユーザーID保存に使用）
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Dioインスタンスのプロバイダー
/// バックエンドはJWT認証未実装のため、Bearerトークンのインターセプターは無効化
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      // 実際のRenderデプロイURLに変更
      baseUrl: 'https://streetpass-backend.onrender.com',
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // ログ出力用インターセプター（デバッグ用）
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ),
  );

  return dio;
});
