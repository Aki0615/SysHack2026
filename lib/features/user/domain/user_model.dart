import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_role.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// ユーザー情報を表現するドメインモデル（freezedで不変データクラスを生成）
/// バックエンドのGoの構造体に合わせたJSONフィールド名を使用
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    @Default('') String email,

    /// アバター画像URL（バックエンド: icon_url）
    @JsonKey(name: 'icon_url') @Default('') String iconUrl,

    /// 一言コメント（バックエンド: one_word）
    @JsonKey(name: 'one_word') @Default('') String oneWord,

    /// ロール（frontend / backend / fullstack / other）
    @Default(UserRole.other) UserRole role,

    /// 技術スタック（バックエンド: tech_stack、単一テキスト）
    @JsonKey(name: 'tech_stack') @Default('') String techStack,

    /// Twitter URL（バックエンド: twitter_url）
    @JsonKey(name: 'twitter_url') @Default('') String twitterUrl,

    /// GitHub URL（バックエンド: github_url）
    @JsonKey(name: 'github_url') @Default('') String githubUrl,

    /// ポートフォリオURL（バックエンド: portfolio_url）
    @JsonKey(name: 'portfolio_url') @Default('') String portfolioUrl,

    /// 所属（バックエンド: affiliation）
    @Default('') String affiliation,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
