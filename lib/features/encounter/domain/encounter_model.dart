import 'package:freezed_annotation/freezed_annotation.dart';
import '../../user/domain/user_model.dart';

part 'encounter_model.freezed.dart';
part 'encounter_model.g.dart';

/// すれ違い通信の1件の記録を表すドメインモデル
@freezed
abstract class EncounterModel with _$EncounterModel {
  const factory EncounterModel({
    /// すれ違い記録の一意なID
    required String id,

    /// すれ違ったユーザーの情報
    required UserModel encounteredUser,

    /// イベントID（イベント中のすれ違いの場合のみ）
    String? eventId,

    /// すれ違った日時
    required DateTime encounteredAt,

    /// ユーザーがこのすれ違いを確認済みかどうか
    required bool isConfirmed,
  }) = _EncounterModel;

  factory EncounterModel.fromJson(Map<String, dynamic> json) =>
      _$EncounterModelFromJson(json);
}
