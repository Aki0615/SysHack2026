import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/user_model.dart';

/// ユーザーリポジトリのプロバイダー
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(dioProvider));
});

/// ユーザー情報のAPI通信を担当するリポジトリ
/// バックエンドの GET /users/:id に合わせた実装
class UserRepository {
  final Dio _dio;

  UserRepository(this._dio);

  /// ユーザー情報を取得する（GET /users/:id）
  Future<UserModel> getUser(String id) async {
    try {
      final response = await _dio.get('/users/$id');
      print('User response data: ${response.data}');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('DioException: ${e.message}, ${e.response?.data}');
      throw Exception('ユーザー情報の取得に失敗しました: ${e.message}');
    } catch (e) {
      print('Error parsing user data: $e');
      throw Exception('ユーザー情報の解析に失敗しました: $e');
    }
  }

  /// ユーザー情報を更新する（PATCH /users/:id）
  Future<UserModel> updateUser(String id, Map<String, dynamic> data) async {
    try {
      print('PATCH /users/$id with data: $data');
      final response = await _dio.patch('/users/$id', data: data);
      print('Update response status: ${response.statusCode}');
      print('Update response data: ${response.data}');

      // レスポンスがユーザーデータを含む場合はそのまま返す
      if (response.data is Map &&
          response.data.containsKey('id') &&
          response.data.containsKey('name')) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      }

      // messageのみのレスポンス（更新成功）の場合は、最新データを再取得
      return await getUser(id);
    } on DioException catch (e) {
      print('DioException: ${e.message}, ${e.response?.data}');
      throw Exception('ユーザー情報の更新に失敗しました: ${e.message}');
    } catch (e) {
      print('Error updating user: $e');
      throw Exception('ユーザー情報の更新に失敗しました: $e');
    }
  }

  /// ユーザーアカウントを削除する（DELETE /users/:id）
  Future<void> deleteUser(String id) async {
    try {
      await _dio.delete('/users/$id');
      print('User deleted: $id');
    } on DioException catch (e) {
      print('DioException: ${e.message}, ${e.response?.data}');
      throw Exception('アカウントの削除に失敗しました: ${e.message}');
    } catch (e) {
      print('Error deleting user: $e');
      throw Exception('アカウントの削除に失敗しました: $e');
    }
  }

  /// アバター画像をアップロード（POST /users/:id/avatar）
  /// Firebase Storageへアップロードされ、icon_urlが返される
  Future<String> uploadAvatar(String id, String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('ファイルが見つかりません: $imagePath');
      }

      // マルチパートフォームデータを作成
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/users/$id/avatar',
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['icon_url'] as String;
      } else {
        throw Exception('アップロードに失敗しました');
      }
    } on DioException catch (e) {
      throw Exception('アバター画像のアップロードに失敗しました: ${e.message}');
    }
  }
}
