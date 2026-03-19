import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_role.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// ユーザー情報を表現するドメインモデル（freezedで不変データクラスを生成）
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    required String email,
    required String avatarUrl,
    required String comment,
    required UserRole role,
    required List<String> techStack,
    String? twitter,
    String? github,
    String? portfolio,
    String? organization,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
