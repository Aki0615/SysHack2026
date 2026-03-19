import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../user/domain/user_model.dart';
import '../data/auth_repository.dart';

/// 認証状態を管理するプロバイダー
/// ログイン中のユーザー情報を保持し、null = 未ログインを意味する
final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(
  AuthNotifier.new,
);

/// 認証状態の管理を行うNotifier
class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  FutureOr<UserModel?> build() async {
    // アプリ起動時にトークンの存在をチェックする
    final repo = ref.read(authRepositoryProvider);
    final hasToken = await repo.hasToken();
    // トークンがなければ未ログイン（null）
    if (!hasToken) return null;
    // トークンがあればログイン済みとみなす（本来はユーザー情報取得APIを叩く）
    return null; // TODO: GET /users/me 等で復元する
  }

  /// ログイン処理
  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return await repo.login(email: email, password: password);
    });
  }

  /// サインアップ処理
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return await repo.signUp(name: name, email: email, password: password);
    });
  }

  /// ログアウト処理
  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AsyncValue.data(null);
  }
}
