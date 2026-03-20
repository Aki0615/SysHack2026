import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/dio_client.dart';

/// 1日のすれ違い上限数
const int dailyEncounterLimit = 5;

/// 1日5人制限サービスのプロバイダー
final dailyLimitServiceProvider = Provider<DailyLimitService>((ref) {
  return DailyLimitService(ref.read(secureStorageProvider));
});

/// 今日のすれ違い件数のプロバイダー（UIで監視用）
final dailyCountProvider = Provider<int>((ref) => 0);

/// 1日5人制限を管理するサービスクラス
/// ローカルストレージに「最終すれ違い日」と「件数」を保存して日付リセットを行う
class DailyLimitService {
  final FlutterSecureStorage _storage;
  static const _dateKey = 'encounter_last_date';
  static const _countKey = 'encounter_daily_count';

  DailyLimitService(this._storage);

  /// 日付が変わっていたらカウントをリセットする
  Future<void> resetIfNewDay() async {
    final lastDate = await _storage.read(key: _dateKey);
    final today = _todayString();

    if (lastDate != today) {
      // 日付が変わっている → カウントリセット
      await _storage.write(key: _dateKey, value: today);
      await _storage.write(key: _countKey, value: '0');
    }
  }

  /// まだすれ違い可能かどうかを返す（5人未満ならtrue）
  Future<bool> canEncounter() async {
    final count = await getCurrentCount();
    return count < dailyEncounterLimit;
  }

  /// 今日のすれ違い件数を取得する
  Future<int> getCurrentCount() async {
    final countStr = await _storage.read(key: _countKey);
    return int.tryParse(countStr ?? '0') ?? 0;
  }

  /// すれ違い件数を1つ加算する
  Future<int> increment() async {
    final count = await getCurrentCount();
    final newCount = count + 1;
    await _storage.write(key: _countKey, value: newCount.toString());
    return newCount;
  }

  /// 今日の日付を「yyyy-MM-dd」形式の文字列で返す
  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
