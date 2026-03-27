import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../user/domain/user_model.dart';
import '../data/plaza_repository.dart';
import '../../auth/domain/auth_notifier.dart';

/// 広場画面のデータを管理するプロバイダー
final plazaNotifierProvider =
    AsyncNotifierProvider<PlazaNotifier, List<UserModel>>(PlazaNotifier.new);

/// 広場画面のデータ管理を行うNotifier
class PlazaNotifier extends AsyncNotifier<List<UserModel>> {
  @override
  FutureOr<List<UserModel>> build() async {
    return await _fetchEncounters();
  }

  /// すれ違い相手を取得
  Future<List<UserModel>> _fetchEncounters() async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) {
      return [];
    }

    try {
      final repo = ref.read(plazaRepositoryProvider);
      return await repo.fetchEncounters(user.id);
    } catch (e) {
      return [];
    }
  }

  /// データを再取得
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchEncounters);
  }

  /// ランダムに5人を取得
  List<UserModel> getRandomFive() {
    final users = state.value ?? [];
    if (users.isEmpty) return [];

    final shuffled = List<UserModel>.from(users)..shuffle();
    return shuffled.take(5).toList();
  }
}
