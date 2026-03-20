// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String? ?? '',
  iconUrl: json['icon_url'] as String? ?? '',
  oneWord: json['one_word'] as String? ?? '',
  role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.other,
  techStack: json['tech_stack'] as String? ?? '',
  twitterUrl: json['twitter_url'] as String? ?? '',
  githubUrl: json['github_url'] as String? ?? '',
  portfolioUrl: json['portfolio_url'] as String? ?? '',
  affiliation: json['affiliation'] as String? ?? '',
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'icon_url': instance.iconUrl,
      'one_word': instance.oneWord,
      'role': _$UserRoleEnumMap[instance.role]!,
      'tech_stack': instance.techStack,
      'twitter_url': instance.twitterUrl,
      'github_url': instance.githubUrl,
      'portfolio_url': instance.portfolioUrl,
      'affiliation': instance.affiliation,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.frontend: 'frontend',
  UserRole.backend: 'backend',
  UserRole.fullstack: 'fullstack',
  UserRole.other: 'other',
};
