import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/user_model.dart';

/// ユーザーリポジトリのプロバイダー
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(dioProvider));
});

/// ユーザー情報のAPI通信を担当するリポジトリ
class UserRepository {
  final Dio _dio;

  UserRepository(this._dio);

  /// ユーザー情報を取得する（GET /users/:id）
  Future<UserModel> getUser(String id) async {
    try {
      final response = await _dio.get('/users/$id');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('ユーザー情報の取得に失敗しました: ${e.message}');
    }
  }

  /// プロフィールを更新する（PATCH /users/:id）
  Future<UserModel> updateProfile({
    required String id,
    String? name,
    String? comment,
    String? role,
    String? twitter,
    String? github,
    String? portfolio,
    String? organization,
    List<String>? techStack,
    String? avatarUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (comment != null) data['comment'] = comment;
      if (role != null) data['role'] = role;
      if (twitter != null) data['twitter'] = twitter;
      if (github != null) data['github'] = github;
      if (portfolio != null) data['portfolio'] = portfolio;
      if (organization != null) data['organization'] = organization;
      if (techStack != null) data['tech_stack'] = techStack;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;

      final response = await _dio.patch('/users/$id', data: data);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('プロフィールの更新に失敗しました: ${e.message}');
    }
  }
}
