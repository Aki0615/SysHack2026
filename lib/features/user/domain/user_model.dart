import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_role.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// DateTimeコンバーター：NULLを許容
class _DateTimeConverter implements JsonConverter<DateTime?, dynamic> {
  const _DateTimeConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) {
      try {
        return DateTime.parse(json);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  dynamic toJson(DateTime? value) => value?.toIso8601String();
}

const _dateTimeConverter = _DateTimeConverter();

/// ユーザー情報を表現するドメインモデル（freezedで不変データクラスを生成）
/// バックエンドのGoの構造体に合わせたJSONフィールド名を使用
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    @Default('') String email,

    /// アバター画像URL（バックエンド: icon_url）
    /// NULLの場合は空文字にフォールバック
    @JsonKey(name: 'icon_url') @Default('') String iconUrl,

    /// 一言コメント（バックエンド: one_word）
    /// NULLの場合は空文字にフォールバック
    @JsonKey(name: 'one_word') @Default('') String oneWord,

    /// ロール（frontend / backend / fullstack / other）
    @JsonKey(unknownEnumValue: UserRole.other)
    @Default(UserRole.other)
    UserRole role,

    /// 技術スタック（バックエンド: tech_stack、単一テキスト）
    /// NULLの場合は空文字にフォールバック
    @JsonKey(name: 'tech_stack') @Default('') String techStack,

    /// Twitter URL（バックエンド: twitter_url）
    /// NULLの場合は空文字にフォールバック
    @JsonKey(name: 'twitter_url') @Default('') String twitterUrl,

    /// GitHub URL（バックエンド: github_url）
    /// NULLの場合は空文字にフォールバック
    @JsonKey(name: 'github_url') @Default('') String githubUrl,

    /// ポートフォリオURL（バックエンド: portfolio_url）
    /// NULLの場合は空文字にフォールバック
    @JsonKey(name: 'portfolio_url') @Default('') String portfolioUrl,

    /// 所属（バックエンド: affiliation）
    /// NULLの場合は空文字にフォールバック
    @Default('') String affiliation,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // NULL値を安全に空文字列にフォールバック（すべてのフィールド）
    final data = Map<String, dynamic>.from(json);
    
    // 文字列フィールドの安全なコンバージョン
    String _toStr(dynamic value) => (value is String) ? value : (value?.toString() ?? '');
    
    data['id'] = _toStr(data['id']);
    data['name'] = _toStr(data['name']);
    data['email'] = _toStr(data['email']);
    data['icon_url'] = _toStr(data['icon_url']);
    data['one_word'] = _toStr(data['one_word']);
    data['tech_stack'] = _toStr(data['tech_stack']);
    data['twitter_url'] = _toStr(data['twitter_url']);
    data['github_url'] = _toStr(data['github_url']);
    data['portfolio_url'] = _toStr(data['portfolio_url']);
    data['affiliation'] = _toStr(data['affiliation']);

    return _$UserModelFromJson(data);
  }
}
