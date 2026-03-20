// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encounter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EncounterModel _$EncounterModelFromJson(Map<String, dynamic> json) =>
    _EncounterModel(
      id: json['id'] as String? ?? '',
      encounteredUser: EncounteredUserInfo.fromJson(
        json['encounteredUser'] as Map<String, dynamic>,
      ),
      eventId: (json['event_id'] as num?)?.toInt(),
      encounteredAt: DateTime.parse(json['encountered_at'] as String),
      isConfirmed: json['is_confirmed'] as bool? ?? false,
    );

Map<String, dynamic> _$EncounterModelToJson(_EncounterModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'encounteredUser': instance.encounteredUser,
      'event_id': instance.eventId,
      'encountered_at': instance.encounteredAt.toIso8601String(),
      'is_confirmed': instance.isConfirmed,
    };

_EncounteredUserInfo _$EncounteredUserInfoFromJson(Map<String, dynamic> json) =>
    _EncounteredUserInfo(
      id: json['id'] as String,
      name: json['name'] as String? ?? '???',
      iconUrl: json['icon_url'] as String? ?? '',
      oneWord: json['one_word'] as String? ?? '',
    );

Map<String, dynamic> _$EncounteredUserInfoToJson(
  _EncounteredUserInfo instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'icon_url': instance.iconUrl,
  'one_word': instance.oneWord,
};
