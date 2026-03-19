import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/dio_client.dart';
import '../../user/domain/user_model.dart';

/// 認証リポジトリのプロバイダー
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider), ref.read(secureStorageProvider));
});

/// 認証関連のAPI通信を担当するリポジトリ
class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  /// サインアップAPI（POST /auth/signup）
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    String? avatar,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/signup',
        data: {
          'name': name,
          'email': email,
          'password': password,
          // ignore: use_null_aware_elements
          if (avatar != null) 'avatar': avatar,
        },
      );
      // トークンをセキュアストレージに保存
      await _storage.write(key: 'auth_token', value: response.data['token']);
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw Exception('サインアップに失敗しました: ${e.message}');
    }
  }

  /// ログインAPI（POST /auth/login）
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      await _storage.write(key: 'auth_token', value: response.data['token']);
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw Exception('ログインに失敗しました: ${e.message}');
    }
  }

  /// 保存済みトークンの有無を確認する
  Future<bool> hasToken() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  /// ログアウト（トークンを削除）
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }
}
