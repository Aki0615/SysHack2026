import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_role.dart';

part 'user_model.freezed.dart';

/// 文字列コンバーター：NULLを空文字にフォールバック
String _readString(Map<dynamic, dynamic> json, String key) {
  final value = json[key];
  if (value is String) return value;
  return value?.toString() ?? '';
}

/// ユーザー情報を表現するドメインモデル（freezedで不変データクラスを生成）
/// バックエンドのGoの構造体に合わせたJSONフィールド名を使用
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    @Default('') String email,

    /// アバター画像URL（バックエンド: icon_url）
    @Default('') String iconUrl,

    /// 一言コメント（バックエンド: one_word）
    @Default('') String oneWord,

    /// ロール（frontend / backend / fullstack / other）
    @Default(UserRole.other) UserRole role,

    /// 技術スタック（バックエンド: tech_stack）
    @Default('') String techStack,

    /// Twitter URL（バックエンド: twitter_url）
    @Default('') String twitterUrl,

    /// GitHub URL（バックエンド: github_url）
    @Default('') String githubUrl,

    /// ポートフォリオURL（バックエンド: portfolio_url）
    @Default('') String portfolioUrl,

    /// Connpassユーザー名/URL（バックエンド: connpass_username）
    @Default('') String connpassUrl,

    /// 所属（バックエンド: affiliation）
    @Default('') String affiliation,

    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserModel;

  /// カスタムfromJson: NULL値を空文字にフォールバックしてからパース
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // ロールのパース
    UserRole parseRole(dynamic value) {
      if (value == null) return UserRole.other;
      final str = value.toString().toLowerCase();
      switch (str) {
        case 'frontend':
          return UserRole.frontend;
        case 'backend':
          return UserRole.backend;
        case 'fullstack':
          return UserRole.fullstack;
        default:
          return UserRole.other;
      }
    }

    // DateTimeのパース
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    return UserModel(
      id: _readString(json, 'id'),
      name: _readString(json, 'name'),
      email: _readString(json, 'email'),
      iconUrl: _readString(json, 'icon_url'),
      oneWord: _readString(json, 'one_word'),
      role: parseRole(json['role']),
      techStack: _readString(json, 'tech_stack'),
      twitterUrl: _readString(json, 'twitter_url'),
      githubUrl: _readString(json, 'github_url'),
      portfolioUrl: _readString(json, 'portfolio_url'),
        connpassUrl: _readString(json, 'connpass_url').isNotEmpty
          ? _readString(json, 'connpass_url')
          : _readString(json, 'connpass_username'),
      affiliation: _readString(json, 'affiliation'),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }
}
