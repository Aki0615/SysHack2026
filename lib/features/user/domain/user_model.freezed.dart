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

 String get id; String get name; String get email;/// アバター画像URL（バックエンド: icon_url）
@JsonKey(name: 'icon_url') String get iconUrl;/// 一言コメント（バックエンド: one_word）
@JsonKey(name: 'one_word') String get oneWord;/// ロール（frontend / backend / fullstack / other）
@JsonKey(unknownEnumValue: UserRole.other) UserRole get role;/// 技術スタック（バックエンド: tech_stack、単一テキスト）
@JsonKey(name: 'tech_stack') String get techStack;/// Twitter URL（バックエンド: twitter_url）
@JsonKey(name: 'twitter_url') String get twitterUrl;/// GitHub URL（バックエンド: github_url）
@JsonKey(name: 'github_url') String get githubUrl;/// ポートフォリオURL（バックエンド: portfolio_url）
@JsonKey(name: 'portfolio_url') String get portfolioUrl;/// 所属（バックエンド: affiliation）
 String get affiliation;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.oneWord, oneWord) || other.oneWord == oneWord)&&(identical(other.role, role) || other.role == role)&&(identical(other.techStack, techStack) || other.techStack == techStack)&&(identical(other.twitterUrl, twitterUrl) || other.twitterUrl == twitterUrl)&&(identical(other.githubUrl, githubUrl) || other.githubUrl == githubUrl)&&(identical(other.portfolioUrl, portfolioUrl) || other.portfolioUrl == portfolioUrl)&&(identical(other.affiliation, affiliation) || other.affiliation == affiliation)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,iconUrl,oneWord,role,techStack,twitterUrl,githubUrl,portfolioUrl,affiliation,createdAt,updatedAt);

@override
String toString() {
  return 'UserModel(id: $id, name: $name, email: $email, iconUrl: $iconUrl, oneWord: $oneWord, role: $role, techStack: $techStack, twitterUrl: $twitterUrl, githubUrl: $githubUrl, portfolioUrl: $portfolioUrl, affiliation: $affiliation, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String email,@JsonKey(name: 'icon_url') String iconUrl,@JsonKey(name: 'one_word') String oneWord,@JsonKey(unknownEnumValue: UserRole.other) UserRole role,@JsonKey(name: 'tech_stack') String techStack,@JsonKey(name: 'twitter_url') String twitterUrl,@JsonKey(name: 'github_url') String githubUrl,@JsonKey(name: 'portfolio_url') String portfolioUrl, String affiliation,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? iconUrl = null,Object? oneWord = null,Object? role = null,Object? techStack = null,Object? twitterUrl = null,Object? githubUrl = null,Object? portfolioUrl = null,Object? affiliation = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,iconUrl: null == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String,oneWord: null == oneWord ? _self.oneWord : oneWord // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,techStack: null == techStack ? _self.techStack : techStack // ignore: cast_nullable_to_non_nullable
as String,twitterUrl: null == twitterUrl ? _self.twitterUrl : twitterUrl // ignore: cast_nullable_to_non_nullable
as String,githubUrl: null == githubUrl ? _self.githubUrl : githubUrl // ignore: cast_nullable_to_non_nullable
as String,portfolioUrl: null == portfolioUrl ? _self.portfolioUrl : portfolioUrl // ignore: cast_nullable_to_non_nullable
as String,affiliation: null == affiliation ? _self.affiliation : affiliation // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String email, @JsonKey(name: 'icon_url')  String iconUrl, @JsonKey(name: 'one_word')  String oneWord, @JsonKey(unknownEnumValue: UserRole.other)  UserRole role, @JsonKey(name: 'tech_stack')  String techStack, @JsonKey(name: 'twitter_url')  String twitterUrl, @JsonKey(name: 'github_url')  String githubUrl, @JsonKey(name: 'portfolio_url')  String portfolioUrl,  String affiliation, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.iconUrl,_that.oneWord,_that.role,_that.techStack,_that.twitterUrl,_that.githubUrl,_that.portfolioUrl,_that.affiliation,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String email, @JsonKey(name: 'icon_url')  String iconUrl, @JsonKey(name: 'one_word')  String oneWord, @JsonKey(unknownEnumValue: UserRole.other)  UserRole role, @JsonKey(name: 'tech_stack')  String techStack, @JsonKey(name: 'twitter_url')  String twitterUrl, @JsonKey(name: 'github_url')  String githubUrl, @JsonKey(name: 'portfolio_url')  String portfolioUrl,  String affiliation, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.id,_that.name,_that.email,_that.iconUrl,_that.oneWord,_that.role,_that.techStack,_that.twitterUrl,_that.githubUrl,_that.portfolioUrl,_that.affiliation,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String email, @JsonKey(name: 'icon_url')  String iconUrl, @JsonKey(name: 'one_word')  String oneWord, @JsonKey(unknownEnumValue: UserRole.other)  UserRole role, @JsonKey(name: 'tech_stack')  String techStack, @JsonKey(name: 'twitter_url')  String twitterUrl, @JsonKey(name: 'github_url')  String githubUrl, @JsonKey(name: 'portfolio_url')  String portfolioUrl,  String affiliation, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.iconUrl,_that.oneWord,_that.role,_that.techStack,_that.twitterUrl,_that.githubUrl,_that.portfolioUrl,_that.affiliation,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel implements UserModel {
  const _UserModel({required this.id, required this.name, this.email = '', @JsonKey(name: 'icon_url') this.iconUrl = '', @JsonKey(name: 'one_word') this.oneWord = '', @JsonKey(unknownEnumValue: UserRole.other) this.role = UserRole.other, @JsonKey(name: 'tech_stack') this.techStack = '', @JsonKey(name: 'twitter_url') this.twitterUrl = '', @JsonKey(name: 'github_url') this.githubUrl = '', @JsonKey(name: 'portfolio_url') this.portfolioUrl = '', this.affiliation = '', @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  String email;
/// アバター画像URL（バックエンド: icon_url）
@override@JsonKey(name: 'icon_url') final  String iconUrl;
/// 一言コメント（バックエンド: one_word）
@override@JsonKey(name: 'one_word') final  String oneWord;
/// ロール（frontend / backend / fullstack / other）
@override@JsonKey(unknownEnumValue: UserRole.other) final  UserRole role;
/// 技術スタック（バックエンド: tech_stack、単一テキスト）
@override@JsonKey(name: 'tech_stack') final  String techStack;
/// Twitter URL（バックエンド: twitter_url）
@override@JsonKey(name: 'twitter_url') final  String twitterUrl;
/// GitHub URL（バックエンド: github_url）
@override@JsonKey(name: 'github_url') final  String githubUrl;
/// ポートフォリオURL（バックエンド: portfolio_url）
@override@JsonKey(name: 'portfolio_url') final  String portfolioUrl;
/// 所属（バックエンド: affiliation）
@override@JsonKey() final  String affiliation;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.oneWord, oneWord) || other.oneWord == oneWord)&&(identical(other.role, role) || other.role == role)&&(identical(other.techStack, techStack) || other.techStack == techStack)&&(identical(other.twitterUrl, twitterUrl) || other.twitterUrl == twitterUrl)&&(identical(other.githubUrl, githubUrl) || other.githubUrl == githubUrl)&&(identical(other.portfolioUrl, portfolioUrl) || other.portfolioUrl == portfolioUrl)&&(identical(other.affiliation, affiliation) || other.affiliation == affiliation)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,iconUrl,oneWord,role,techStack,twitterUrl,githubUrl,portfolioUrl,affiliation,createdAt,updatedAt);

@override
String toString() {
  return 'UserModel(id: $id, name: $name, email: $email, iconUrl: $iconUrl, oneWord: $oneWord, role: $role, techStack: $techStack, twitterUrl: $twitterUrl, githubUrl: $githubUrl, portfolioUrl: $portfolioUrl, affiliation: $affiliation, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String email,@JsonKey(name: 'icon_url') String iconUrl,@JsonKey(name: 'one_word') String oneWord,@JsonKey(unknownEnumValue: UserRole.other) UserRole role,@JsonKey(name: 'tech_stack') String techStack,@JsonKey(name: 'twitter_url') String twitterUrl,@JsonKey(name: 'github_url') String githubUrl,@JsonKey(name: 'portfolio_url') String portfolioUrl, String affiliation,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? iconUrl = null,Object? oneWord = null,Object? role = null,Object? techStack = null,Object? twitterUrl = null,Object? githubUrl = null,Object? portfolioUrl = null,Object? affiliation = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_UserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,iconUrl: null == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String,oneWord: null == oneWord ? _self.oneWord : oneWord // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,techStack: null == techStack ? _self.techStack : techStack // ignore: cast_nullable_to_non_nullable
as String,twitterUrl: null == twitterUrl ? _self.twitterUrl : twitterUrl // ignore: cast_nullable_to_non_nullable
as String,githubUrl: null == githubUrl ? _self.githubUrl : githubUrl // ignore: cast_nullable_to_non_nullable
as String,portfolioUrl: null == portfolioUrl ? _self.portfolioUrl : portfolioUrl // ignore: cast_nullable_to_non_nullable
as String,affiliation: null == affiliation ? _self.affiliation : affiliation // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
