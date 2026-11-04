// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stream_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StreamInfo {

 Uri get url; DateTime get expiresAt; String? get mimeType; int? get bitrate; double? get loudnessDb;
/// Create a copy of StreamInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreamInfoCopyWith<StreamInfo> get copyWith => _$StreamInfoCopyWithImpl<StreamInfo>(this as StreamInfo, _$identity);

  /// Serializes this StreamInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StreamInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreamInfo&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.mimeType, _this.mimeType) || other.mimeType == _this.mimeType)&&(identical(other.bitrate, _this.bitrate) || other.bitrate == _this.bitrate)&&(identical(other.loudnessDb, _this.loudnessDb) || other.loudnessDb == _this.loudnessDb));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StreamInfo;
  return Object.hash(runtimeType,_this.url,_this.expiresAt,_this.mimeType,_this.bitrate,_this.loudnessDb);
}

@override
String toString() {
  final _this = this as StreamInfo;
  return 'StreamInfo(url: ${_this.url}, expiresAt: ${_this.expiresAt}, mimeType: ${_this.mimeType}, bitrate: ${_this.bitrate}, loudnessDb: ${_this.loudnessDb})';
}


}

/// @nodoc
abstract mixin class $StreamInfoCopyWith<$Res>  {
  factory $StreamInfoCopyWith(StreamInfo value, $Res Function(StreamInfo) _then) = _$StreamInfoCopyWithImpl;
@useResult
$Res call({
 Uri url, DateTime expiresAt, String? mimeType, int? bitrate, double? loudnessDb
});




}
/// @nodoc
class _$StreamInfoCopyWithImpl<$Res>
    implements $StreamInfoCopyWith<$Res> {
  _$StreamInfoCopyWithImpl(this._self, this._then);

  final StreamInfo _self;
  final $Res Function(StreamInfo) _then;

/// Create a copy of StreamInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? expiresAt = null,Object? mimeType = freezed,Object? bitrate = freezed,Object? loudnessDb = freezed,}) {
  return _then(StreamInfo(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as Uri,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,bitrate: freezed == bitrate ? _self.bitrate : bitrate // ignore: cast_nullable_to_non_nullable
as int?,loudnessDb: freezed == loudnessDb ? _self.loudnessDb : loudnessDb // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [StreamInfo].
extension StreamInfoPatterns on StreamInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreamInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreamInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreamInfo value)  $default,){
final _that = this;
switch (_that) {
case _StreamInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreamInfo value)?  $default,){
final _that = this;
switch (_that) {
case _StreamInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Uri url,  DateTime expiresAt,  String? mimeType,  int? bitrate,  double? loudnessDb)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreamInfo() when $default != null:
return $default(_that.url,_that.expiresAt,_that.mimeType,_that.bitrate,_that.loudnessDb);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Uri url,  DateTime expiresAt,  String? mimeType,  int? bitrate,  double? loudnessDb)  $default,) {final _that = this;
switch (_that) {
case _StreamInfo():
return $default(_that.url,_that.expiresAt,_that.mimeType,_that.bitrate,_that.loudnessDb);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Uri url,  DateTime expiresAt,  String? mimeType,  int? bitrate,  double? loudnessDb)?  $default,) {final _that = this;
switch (_that) {
case _StreamInfo() when $default != null:
return $default(_that.url,_that.expiresAt,_that.mimeType,_that.bitrate,_that.loudnessDb);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StreamInfo implements StreamInfo {
  const _StreamInfo({required this.url, required this.expiresAt, this.mimeType, this.bitrate, this.loudnessDb});
  factory _StreamInfo.fromJson(Map<String, dynamic> json) => _$StreamInfoFromJson(json);

@override final  Uri url;
@override final  DateTime expiresAt;
@override final  String? mimeType;
@override final  int? bitrate;
@override final  double? loudnessDb;

/// Create a copy of StreamInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreamInfoCopyWith<_StreamInfo> get copyWith => __$StreamInfoCopyWithImpl<_StreamInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StreamInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreamInfo&&(identical(other.url, url) || other.url == url)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.bitrate, bitrate) || other.bitrate == bitrate)&&(identical(other.loudnessDb, loudnessDb) || other.loudnessDb == loudnessDb));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,url,expiresAt,mimeType,bitrate,loudnessDb);
}

@override
String toString() {
    return 'StreamInfo(url: $url, expiresAt: $expiresAt, mimeType: $mimeType, bitrate: $bitrate, loudnessDb: $loudnessDb)';
}


}

/// @nodoc
abstract mixin class _$StreamInfoCopyWith<$Res> implements $StreamInfoCopyWith<$Res> {
  factory _$StreamInfoCopyWith(_StreamInfo value, $Res Function(_StreamInfo) _then) = __$StreamInfoCopyWithImpl;
@override @useResult
$Res call({
 Uri url, DateTime expiresAt, String? mimeType, int? bitrate, double? loudnessDb
});




}
/// @nodoc
class __$StreamInfoCopyWithImpl<$Res>
    implements _$StreamInfoCopyWith<$Res> {
  __$StreamInfoCopyWithImpl(this._self, this._then);

  final _StreamInfo _self;
  final $Res Function(_StreamInfo) _then;

/// Create a copy of StreamInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? expiresAt = null,Object? mimeType = freezed,Object? bitrate = freezed,Object? loudnessDb = freezed,}) {
  return _then(_StreamInfo(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as Uri,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,bitrate: freezed == bitrate ? _self.bitrate : bitrate // ignore: cast_nullable_to_non_nullable
as int?,loudnessDb: freezed == loudnessDb ? _self.loudnessDb : loudnessDb // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
