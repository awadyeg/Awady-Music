// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'artwork.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Artwork {

@JsonKey(name: '150x150') String? get s150;@JsonKey(name: '480x480') String? get s480;@JsonKey(name: '1000x1000') String? get s1000; List<String> get mirrors; String? get fallback;
/// Create a copy of Artwork
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArtworkCopyWith<Artwork> get copyWith => _$ArtworkCopyWithImpl<Artwork>(this as Artwork, _$identity);

  /// Serializes this Artwork to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Artwork;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Artwork&&(identical(other.s150, _this.s150) || other.s150 == _this.s150)&&(identical(other.s480, _this.s480) || other.s480 == _this.s480)&&(identical(other.s1000, _this.s1000) || other.s1000 == _this.s1000)&&const DeepCollectionEquality().equals(other.mirrors, _this.mirrors)&&(identical(other.fallback, _this.fallback) || other.fallback == _this.fallback));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Artwork;
  return Object.hash(runtimeType,_this.s150,_this.s480,_this.s1000,const DeepCollectionEquality().hash(_this.mirrors),_this.fallback);
}

@override
String toString() {
  final _this = this as Artwork;
  return 'Artwork(s150: ${_this.s150}, s480: ${_this.s480}, s1000: ${_this.s1000}, mirrors: ${_this.mirrors}, fallback: ${_this.fallback})';
}


}

/// @nodoc
abstract mixin class $ArtworkCopyWith<$Res>  {
  factory $ArtworkCopyWith(Artwork value, $Res Function(Artwork) _then) = _$ArtworkCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '150x150') String? s150,@JsonKey(name: '480x480') String? s480,@JsonKey(name: '1000x1000') String? s1000, List<String> mirrors, String? fallback
});




}
/// @nodoc
class _$ArtworkCopyWithImpl<$Res>
    implements $ArtworkCopyWith<$Res> {
  _$ArtworkCopyWithImpl(this._self, this._then);

  final Artwork _self;
  final $Res Function(Artwork) _then;

/// Create a copy of Artwork
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? s150 = freezed,Object? s480 = freezed,Object? s1000 = freezed,Object? mirrors = null,Object? fallback = freezed,}) {
  return _then(Artwork(
s150: freezed == s150 ? _self.s150 : s150 // ignore: cast_nullable_to_non_nullable
as String?,s480: freezed == s480 ? _self.s480 : s480 // ignore: cast_nullable_to_non_nullable
as String?,s1000: freezed == s1000 ? _self.s1000 : s1000 // ignore: cast_nullable_to_non_nullable
as String?,mirrors: null == mirrors ? _self.mirrors : mirrors // ignore: cast_nullable_to_non_nullable
as List<String>,fallback: freezed == fallback ? _self.fallback : fallback // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Artwork].
extension ArtworkPatterns on Artwork {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Artwork value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Artwork() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Artwork value)  $default,){
final _that = this;
switch (_that) {
case _Artwork():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Artwork value)?  $default,){
final _that = this;
switch (_that) {
case _Artwork() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '150x150')  String? s150, @JsonKey(name: '480x480')  String? s480, @JsonKey(name: '1000x1000')  String? s1000,  List<String> mirrors,  String? fallback)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Artwork() when $default != null:
return $default(_that.s150,_that.s480,_that.s1000,_that.mirrors,_that.fallback);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '150x150')  String? s150, @JsonKey(name: '480x480')  String? s480, @JsonKey(name: '1000x1000')  String? s1000,  List<String> mirrors,  String? fallback)  $default,) {final _that = this;
switch (_that) {
case _Artwork():
return $default(_that.s150,_that.s480,_that.s1000,_that.mirrors,_that.fallback);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '150x150')  String? s150, @JsonKey(name: '480x480')  String? s480, @JsonKey(name: '1000x1000')  String? s1000,  List<String> mirrors,  String? fallback)?  $default,) {final _that = this;
switch (_that) {
case _Artwork() when $default != null:
return $default(_that.s150,_that.s480,_that.s1000,_that.mirrors,_that.fallback);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Artwork implements Artwork {
  const _Artwork({@JsonKey(name: '150x150') this.s150, @JsonKey(name: '480x480') this.s480, @JsonKey(name: '1000x1000') this.s1000,  List<String> mirrors = const <String>[], this.fallback}): _mirrors = mirrors;
  factory _Artwork.fromJson(Map<String, dynamic> json) => _$ArtworkFromJson(json);

@override@JsonKey(name: '150x150') final  String? s150;
@override@JsonKey(name: '480x480') final  String? s480;
@override@JsonKey(name: '1000x1000') final  String? s1000;
 final  List<String> _mirrors;
@override@JsonKey() List<String> get mirrors {
  if (_mirrors is EqualUnmodifiableListView) return _mirrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mirrors);
}

@override final  String? fallback;

/// Create a copy of Artwork
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArtworkCopyWith<_Artwork> get copyWith => __$ArtworkCopyWithImpl<_Artwork>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ArtworkToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Artwork&&(identical(other.s150, s150) || other.s150 == s150)&&(identical(other.s480, s480) || other.s480 == s480)&&(identical(other.s1000, s1000) || other.s1000 == s1000)&&const DeepCollectionEquality().equals(other.mirrors, _mirrors)&&(identical(other.fallback, fallback) || other.fallback == fallback));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,s150,s480,s1000,const DeepCollectionEquality().hash(_mirrors),fallback);
}

@override
String toString() {
    return 'Artwork(s150: $s150, s480: $s480, s1000: $s1000, mirrors: $mirrors, fallback: $fallback)';
}


}

/// @nodoc
abstract mixin class _$ArtworkCopyWith<$Res> implements $ArtworkCopyWith<$Res> {
  factory _$ArtworkCopyWith(_Artwork value, $Res Function(_Artwork) _then) = __$ArtworkCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '150x150') String? s150,@JsonKey(name: '480x480') String? s480,@JsonKey(name: '1000x1000') String? s1000, List<String> mirrors, String? fallback
});




}
/// @nodoc
class __$ArtworkCopyWithImpl<$Res>
    implements _$ArtworkCopyWith<$Res> {
  __$ArtworkCopyWithImpl(this._self, this._then);

  final _Artwork _self;
  final $Res Function(_Artwork) _then;

/// Create a copy of Artwork
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? s150 = freezed,Object? s480 = freezed,Object? s1000 = freezed,Object? mirrors = null,Object? fallback = freezed,}) {
  return _then(_Artwork(
s150: freezed == s150 ? _self.s150 : s150 // ignore: cast_nullable_to_non_nullable
as String?,s480: freezed == s480 ? _self.s480 : s480 // ignore: cast_nullable_to_non_nullable
as String?,s1000: freezed == s1000 ? _self.s1000 : s1000 // ignore: cast_nullable_to_non_nullable
as String?,mirrors: null == mirrors ? _self._mirrors : mirrors // ignore: cast_nullable_to_non_nullable
as List<String>,fallback: freezed == fallback ? _self.fallback : fallback // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
