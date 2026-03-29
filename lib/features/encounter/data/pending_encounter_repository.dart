import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/dio_client.dart';
import '../domain/encounter_model.dart';

/// ローカル保存用リポジトリのプロバイダー
final pendingEncounterRepositoryProvider = Provider<PendingEncounterRepository>(
  (ref) {
    return PendingEncounterRepository(ref.read(secureStorageProvider));
  },
);

/// 未確認すれ違いデータのローカル保存を担当するリポジトリ
/// flutter_secure_storageを使ってJSON形式で保存する
class PendingEncounterRepository {
  final FlutterSecureStorage _storage;
  static const _key = 'pending_encounters';
  static const _lastShutdownIdsKey = 'last_shutdown_encounter_user_ids';

  PendingEncounterRepository(this._storage);

  /// 未確認のすれ違いデータをローカルから取得する
  Future<List<EncounterModel>> getPending() async {
    final jsonStr = await _storage.read(key: _key);
    if (jsonStr == null) return [];

    final list = jsonDecode(jsonStr) as List;
    return list.map((e) => EncounterModel.fromJson(e)).toList();
  }

  /// すれ違いデータを1件追加してローカルに保存する
  Future<void> add(EncounterModel encounter) async {
    final current = await getPending();
    current.add(encounter);
    await _save(current);
  }

  /// ローカルの未確認データをすべてクリアする
  Future<void> clearAll() async {
    await _storage.delete(key: _key);
  }

  /// 前回終了時点の未確認ユーザーID一覧を保存する
  Future<void> saveLastShutdownEncounterUserIds(List<String> userIds) async {
    final unique = userIds.toSet().toList();
    await _storage.write(key: _lastShutdownIdsKey, value: jsonEncode(unique));
  }

  /// 前回終了時点の未確認ユーザーID一覧を取得する
  Future<Set<String>> getLastShutdownEncounterUserIds() async {
    final jsonStr = await _storage.read(key: _lastShutdownIdsKey);
    if (jsonStr == null || jsonStr.isEmpty) return <String>{};

    final list = (jsonDecode(jsonStr) as List).map((e) => e.toString());
    return list.toSet();
  }

  /// リストをJSON文字列としてセキュアストレージに書き込む
  Future<void> _save(List<EncounterModel> encounters) async {
    final jsonStr = jsonEncode(encounters.map((e) => e.toJson()).toList());
    await _storage.write(key: _key, value: jsonStr);
  }
}
