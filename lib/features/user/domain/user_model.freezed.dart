// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

 String get id; String get name; String get email; String get avatarUrl; String get comment; UserRole get role; List<String> get techStack; String? get twitter; String? get github; String? get portfolio; String? get organization; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.role, role) || other.role == role)&&const DeepCollectionEquality().equals(other.techStack, techStack)&&(identical(other.twitter, twitter) || other.twitter == twitter)&&(identical(other.github, github) || other.github == github)&&(identical(other.portfolio, portfolio) || other.portfolio == portfolio)&&(identical(other.organization, organization) || other.organization == organization)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,avatarUrl,comment,role,const DeepCollectionEquality().hash(techStack),twitter,github,portfolio,organization,createdAt,updatedAt);

@override
String toString() {
  return 'UserModel(id: $id, name: $name, email: $email, avatarUrl: $avatarUrl, comment: $comment, role: $role, techStack: $techStack, twitter: $twitter, github: $github, portfolio: $portfolio, organization: $organization, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String email, String avatarUrl, String comment, UserRole role, List<String> techStack, String? twitter, String? github, String? portfolio, String? organization, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? avatarUrl = null,Object? comment = null,Object? role = null,Object? techStack = null,Object? twitter = freezed,Object? github = freezed,Object? portfolio = freezed,Object? organization = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,techStack: null == techStack ? _self.techStack : techStack // ignore: cast_nullable_to_non_nullable
as List<String>,twitter: freezed == twitter ? _self.twitter : twitter // ignore: cast_nullable_to_non_nullable
as String?,github: freezed == github ? _self.github : github // ignore: cast_nullable_to_non_nullable
as String?,portfolio: freezed == portfolio ? _self.portfolio : portfolio // ignore: cast_nullable_to_non_nullable
as String?,organization: freezed == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String avatarUrl,  String comment,  UserRole role,  List<String> techStack,  String? twitter,  String? github,  String? portfolio,  String? organization,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.avatarUrl,_that.comment,_that.role,_that.techStack,_that.twitter,_that.github,_that.portfolio,_that.organization,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String avatarUrl,  String comment,  UserRole role,  List<String> techStack,  String? twitter,  String? github,  String? portfolio,  String? organization,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.id,_that.name,_that.email,_that.avatarUrl,_that.comment,_that.role,_that.techStack,_that.twitter,_that.github,_that.portfolio,_that.organization,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String email,  String avatarUrl,  String comment,  UserRole role,  List<String> techStack,  String? twitter,  String? github,  String? portfolio,  String? organization,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.avatarUrl,_that.comment,_that.role,_that.techStack,_that.twitter,_that.github,_that.portfolio,_that.organization,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel implements UserModel {
  const _UserModel({required this.id, required this.name, required this.email, required this.avatarUrl, required this.comment, required this.role, required final  List<String> techStack, this.twitter, this.github, this.portfolio, this.organization, required this.createdAt, required this.updatedAt}): _techStack = techStack;
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String email;
@override final  String avatarUrl;
@override final  String comment;
@override final  UserRole role;
 final  List<String> _techStack;
@override List<String> get techStack {
  if (_techStack is EqualUnmodifiableListView) return _techStack;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_techStack);
}

@override final  String? twitter;
@override final  String? github;
@override final  String? portfolio;
@override final  String? organization;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.role, role) || other.role == role)&&const DeepCollectionEquality().equals(other._techStack, _techStack)&&(identical(other.twitter, twitter) || other.twitter == twitter)&&(identical(other.github, github) || other.github == github)&&(identical(other.portfolio, portfolio) || other.portfolio == portfolio)&&(identical(other.organization, organization) || other.organization == organization)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,avatarUrl,comment,role,const DeepCollectionEquality().hash(_techStack),twitter,github,portfolio,organization,createdAt,updatedAt);

@override
String toString() {
  return 'UserModel(id: $id, name: $name, email: $email, avatarUrl: $avatarUrl, comment: $comment, role: $role, techStack: $techStack, twitter: $twitter, github: $github, portfolio: $portfolio, organization: $organization, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String email, String avatarUrl, String comment, UserRole role, List<String> techStack, String? twitter, String? github, String? portfolio, String? organization, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? avatarUrl = null,Object? comment = null,Object? role = null,Object? techStack = null,Object? twitter = freezed,Object? github = freezed,Object? portfolio = freezed,Object? organization = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_UserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,techStack: null == techStack ? _self._techStack : techStack // ignore: cast_nullable_to_non_nullable
as List<String>,twitter: freezed == twitter ? _self.twitter : twitter // ignore: cast_nullable_to_non_nullable
as String?,github: freezed == github ? _self.github : github // ignore: cast_nullable_to_non_nullable
as String?,portfolio: freezed == portfolio ? _self.portfolio : portfolio // ignore: cast_nullable_to_non_nullable
as String?,organization: freezed == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
