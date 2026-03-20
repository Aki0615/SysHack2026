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
    // アプリ起動時にセッションの存在をチェックする
    final repo = ref.read(authRepositoryProvider);
    final hasSession = await repo.hasSession();
    if (!hasSession) return null;

    // セッションがあればユーザー情報を復元する
    final userId = await repo.getSavedUserId();
    if (userId == null) return null;

    try {
      return await repo.login(userId: userId, password: '');
    } catch (_) {
      // ユーザー情報取得に失敗した場合は未ログインとする
      return null;
    }
  }

  /// ログイン処理（ユーザーIDで認証）
  Future<void> login({required String userId, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return await repo.login(userId: userId, password: password);
    });
  }

  /// サインアップ処理
  Future<void> signUp({
    required String id,
    required String name,
    required String email,
    required String password,
    String? role,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return await repo.signUp(
        id: id,
        name: name,
        email: email,
        password: password,
        role: role,
      );
    });
  }

  /// ログアウト処理
  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AsyncValue.data(null);
  }

  /// 現在のユーザーIDを取得する
  String? get currentUserId => state.value?.id;
}
