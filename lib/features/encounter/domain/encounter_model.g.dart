// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encounter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EncounterModel _$EncounterModelFromJson(Map<String, dynamic> json) =>
    _EncounterModel(
      id: json['id'] as String,
      encounteredUser: UserModel.fromJson(
        json['encounteredUser'] as Map<String, dynamic>,
      ),
      eventId: json['eventId'] as String?,
      encounteredAt: DateTime.parse(json['encounteredAt'] as String),
      isConfirmed: json['isConfirmed'] as bool,
    );

Map<String, dynamic> _$EncounterModelToJson(_EncounterModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'encounteredUser': instance.encounteredUser,
      'eventId': instance.eventId,
      'encounteredAt': instance.encounteredAt.toIso8601String(),
      'isConfirmed': instance.isConfirmed,
    };
