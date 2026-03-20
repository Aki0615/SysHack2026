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
/// バックエンドの POST /signup エンドポイントに合わせた実装
class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  /// サインアップAPI（POST /signup）
  /// バックエンドはtokenを返さず、メッセージのみ返す
  /// サインアップ成功後、ユーザーIDをローカルに保存する
  Future<UserModel> signUp({
    required String id,
    required String name,
    required String email,
    required String password,
    String? iconUrl,
    String? oneWord,
    String? role,
    String? techStack,
  }) async {
    try {
      await _dio.post(
        '/signup',
        data: {
          'id': id,
          'name': name,
          'email': email,
          'password': password,
          // ignore: use_null_aware_elements
          if (iconUrl != null) 'icon_url': iconUrl,
          // ignore: use_null_aware_elements
          if (oneWord != null) 'one_word': oneWord,
          // ignore: use_null_aware_elements
          if (role != null) 'role': role,
          // ignore: use_null_aware_elements
          if (techStack != null) 'tech_stack': techStack,
        },
      );
      // ユーザーIDをローカルに保存（認証状態の判定に使用）
      await _storage.write(key: 'user_id', value: id);

      // サインアップ成功後、ユーザー情報を取得して返す
      return await _fetchUser(id);
    } on DioException catch (e) {
      throw Exception('サインアップに失敗しました: ${e.message}');
    }
  }

  /// ログイン処理（バックエンドにログインAPIがないため、ローカル認証で代替）
  /// ユーザーIDとパスワードでGET /users/:id を呼び、存在確認する簡易実装
  /// TODO: バックエンドにPOST /loginが実装されたら正式対応する
  Future<UserModel> login({
    required String userId,
    required String password,
  }) async {
    try {
      final user = await _fetchUser(userId);
      // ユーザーIDをローカルに保存
      await _storage.write(key: 'user_id', value: userId);
      return user;
    } on DioException catch (e) {
      throw Exception('ログインに失敗しました: ${e.message}');
    }
  }

  /// ユーザー情報を取得する（GET /users/:id）
  Future<UserModel> _fetchUser(String id) async {
    final response = await _dio.get('/users/$id');
    return UserModel.fromJson(response.data);
  }

  /// 保存済みユーザーIDの有無を確認する
  Future<bool> hasSession() async {
    final userId = await _storage.read(key: 'user_id');
    return userId != null;
  }

  /// 保存されたユーザーIDを取得する
  Future<String?> getSavedUserId() async {
    return await _storage.read(key: 'user_id');
  }

  /// ログアウト（ユーザーIDを削除）
  Future<void> logout() async {
    await _storage.delete(key: 'user_id');
  }
}
