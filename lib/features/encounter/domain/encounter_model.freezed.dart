// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'encounter_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EncounterModel {

/// すれ違い記録の一意なID
 String get id;/// すれ違ったユーザーの情報
 UserModel get encounteredUser;/// イベントID（イベント中のすれ違いの場合のみ）
 String? get eventId;/// すれ違った日時
 DateTime get encounteredAt;/// ユーザーがこのすれ違いを確認済みかどうか
 bool get isConfirmed;
/// Create a copy of EncounterModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EncounterModelCopyWith<EncounterModel> get copyWith => _$EncounterModelCopyWithImpl<EncounterModel>(this as EncounterModel, _$identity);

  /// Serializes this EncounterModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EncounterModel&&(identical(other.id, id) || other.id == id)&&(identical(other.encounteredUser, encounteredUser) || other.encounteredUser == encounteredUser)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.encounteredAt, encounteredAt) || other.encounteredAt == encounteredAt)&&(identical(other.isConfirmed, isConfirmed) || other.isConfirmed == isConfirmed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,encounteredUser,eventId,encounteredAt,isConfirmed);

@override
String toString() {
  return 'EncounterModel(id: $id, encounteredUser: $encounteredUser, eventId: $eventId, encounteredAt: $encounteredAt, isConfirmed: $isConfirmed)';
}


}

/// @nodoc
abstract mixin class $EncounterModelCopyWith<$Res>  {
  factory $EncounterModelCopyWith(EncounterModel value, $Res Function(EncounterModel) _then) = _$EncounterModelCopyWithImpl;
@useResult
$Res call({
 String id, UserModel encounteredUser, String? eventId, DateTime encounteredAt, bool isConfirmed
});


$UserModelCopyWith<$Res> get encounteredUser;

}
/// @nodoc
class _$EncounterModelCopyWithImpl<$Res>
    implements $EncounterModelCopyWith<$Res> {
  _$EncounterModelCopyWithImpl(this._self, this._then);

  final EncounterModel _self;
  final $Res Function(EncounterModel) _then;

/// Create a copy of EncounterModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? encounteredUser = null,Object? eventId = freezed,Object? encounteredAt = null,Object? isConfirmed = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,encounteredUser: null == encounteredUser ? _self.encounteredUser : encounteredUser // ignore: cast_nullable_to_non_nullable
as UserModel,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,encounteredAt: null == encounteredAt ? _self.encounteredAt : encounteredAt // ignore: cast_nullable_to_non_nullable
as DateTime,isConfirmed: null == isConfirmed ? _self.isConfirmed : isConfirmed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of EncounterModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res> get encounteredUser {
  
  return $UserModelCopyWith<$Res>(_self.encounteredUser, (value) {
    return _then(_self.copyWith(encounteredUser: value));
  });
}
}


/// Adds pattern-matching-related methods to [EncounterModel].
extension EncounterModelPatterns on EncounterModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EncounterModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EncounterModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EncounterModel value)  $default,){
final _that = this;
switch (_that) {
case _EncounterModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EncounterModel value)?  $default,){
final _that = this;
switch (_that) {
case _EncounterModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  UserModel encounteredUser,  String? eventId,  DateTime encounteredAt,  bool isConfirmed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EncounterModel() when $default != null:
return $default(_that.id,_that.encounteredUser,_that.eventId,_that.encounteredAt,_that.isConfirmed);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  UserModel encounteredUser,  String? eventId,  DateTime encounteredAt,  bool isConfirmed)  $default,) {final _that = this;
switch (_that) {
case _EncounterModel():
return $default(_that.id,_that.encounteredUser,_that.eventId,_that.encounteredAt,_that.isConfirmed);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  UserModel encounteredUser,  String? eventId,  DateTime encounteredAt,  bool isConfirmed)?  $default,) {final _that = this;
switch (_that) {
case _EncounterModel() when $default != null:
return $default(_that.id,_that.encounteredUser,_that.eventId,_that.encounteredAt,_that.isConfirmed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EncounterModel implements EncounterModel {
  const _EncounterModel({required this.id, required this.encounteredUser, this.eventId, required this.encounteredAt, required this.isConfirmed});
  factory _EncounterModel.fromJson(Map<String, dynamic> json) => _$EncounterModelFromJson(json);

/// すれ違い記録の一意なID
@override final  String id;
/// すれ違ったユーザーの情報
@override final  UserModel encounteredUser;
/// イベントID（イベント中のすれ違いの場合のみ）
@override final  String? eventId;
/// すれ違った日時
@override final  DateTime encounteredAt;
/// ユーザーがこのすれ違いを確認済みかどうか
@override final  bool isConfirmed;

/// Create a copy of EncounterModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EncounterModelCopyWith<_EncounterModel> get copyWith => __$EncounterModelCopyWithImpl<_EncounterModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EncounterModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EncounterModel&&(identical(other.id, id) || other.id == id)&&(identical(other.encounteredUser, encounteredUser) || other.encounteredUser == encounteredUser)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.encounteredAt, encounteredAt) || other.encounteredAt == encounteredAt)&&(identical(other.isConfirmed, isConfirmed) || other.isConfirmed == isConfirmed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,encounteredUser,eventId,encounteredAt,isConfirmed);

@override
String toString() {
  return 'EncounterModel(id: $id, encounteredUser: $encounteredUser, eventId: $eventId, encounteredAt: $encounteredAt, isConfirmed: $isConfirmed)';
}


}

/// @nodoc
abstract mixin class _$EncounterModelCopyWith<$Res> implements $EncounterModelCopyWith<$Res> {
  factory _$EncounterModelCopyWith(_EncounterModel value, $Res Function(_EncounterModel) _then) = __$EncounterModelCopyWithImpl;
@override @useResult
$Res call({
 String id, UserModel encounteredUser, String? eventId, DateTime encounteredAt, bool isConfirmed
});


@override $UserModelCopyWith<$Res> get encounteredUser;

}
/// @nodoc
class __$EncounterModelCopyWithImpl<$Res>
    implements _$EncounterModelCopyWith<$Res> {
  __$EncounterModelCopyWithImpl(this._self, this._then);

  final _EncounterModel _self;
  final $Res Function(_EncounterModel) _then;

/// Create a copy of EncounterModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? encounteredUser = null,Object? eventId = freezed,Object? encounteredAt = null,Object? isConfirmed = null,}) {
  return _then(_EncounterModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,encounteredUser: null == encounteredUser ? _self.encounteredUser : encounteredUser // ignore: cast_nullable_to_non_nullable
as UserModel,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,encounteredAt: null == encounteredAt ? _self.encounteredAt : encounteredAt // ignore: cast_nullable_to_non_nullable
as DateTime,isConfirmed: null == isConfirmed ? _self.isConfirmed : isConfirmed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of EncounterModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res> get encounteredUser {
  
  return $UserModelCopyWith<$Res>(_self.encounteredUser, (value) {
    return _then(_self.copyWith(encounteredUser: value));
  });
}
}

// dart format on
