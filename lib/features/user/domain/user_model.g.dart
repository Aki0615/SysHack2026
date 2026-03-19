// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  avatarUrl: json['avatarUrl'] as String,
  comment: json['comment'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  techStack: (json['techStack'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  twitter: json['twitter'] as String?,
  github: json['github'] as String?,
  portfolio: json['portfolio'] as String?,
  organization: json['organization'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'avatarUrl': instance.avatarUrl,
      'comment': instance.comment,
      'role': _$UserRoleEnumMap[instance.role]!,
      'techStack': instance.techStack,
      'twitter': instance.twitter,
      'github': instance.github,
      'portfolio': instance.portfolio,
      'organization': instance.organization,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.frontend: 'frontend',
  UserRole.backend: 'backend',
  UserRole.fullstack: 'fullstack',
  UserRole.other: 'other',
};
