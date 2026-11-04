// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'local_playlist.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocalPlaylist {

 String get id; String get name; List<Track> get tracks; DateTime get createdAt;
/// Create a copy of LocalPlaylist
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalPlaylistCopyWith<LocalPlaylist> get copyWith => _$LocalPlaylistCopyWithImpl<LocalPlaylist>(this as LocalPlaylist, _$identity);

  /// Serializes this LocalPlaylist to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LocalPlaylist;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalPlaylist&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.tracks, _this.tracks)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LocalPlaylist;
  return Object.hash(runtimeType,_this.id,_this.name,const DeepCollectionEquality().hash(_this.tracks),_this.createdAt);
}

@override
String toString() {
  final _this = this as LocalPlaylist;
  return 'LocalPlaylist(id: ${_this.id}, name: ${_this.name}, tracks: ${_this.tracks}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $LocalPlaylistCopyWith<$Res>  {
  factory $LocalPlaylistCopyWith(LocalPlaylist value, $Res Function(LocalPlaylist) _then) = _$LocalPlaylistCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<Track> tracks, DateTime createdAt
});




}
/// @nodoc
class _$LocalPlaylistCopyWithImpl<$Res>
    implements $LocalPlaylistCopyWith<$Res> {
  _$LocalPlaylistCopyWithImpl(this._self, this._then);

  final LocalPlaylist _self;
  final $Res Function(LocalPlaylist) _then;

/// Create a copy of LocalPlaylist
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? tracks = null,Object? createdAt = null,}) {
  return _then(LocalPlaylist(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<Track>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalPlaylist].
extension LocalPlaylistPatterns on LocalPlaylist {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalPlaylist value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalPlaylist() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalPlaylist value)  $default,){
final _that = this;
switch (_that) {
case _LocalPlaylist():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalPlaylist value)?  $default,){
final _that = this;
switch (_that) {
case _LocalPlaylist() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<Track> tracks,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalPlaylist() when $default != null:
return $default(_that.id,_that.name,_that.tracks,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<Track> tracks,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _LocalPlaylist():
return $default(_that.id,_that.name,_that.tracks,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<Track> tracks,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _LocalPlaylist() when $default != null:
return $default(_that.id,_that.name,_that.tracks,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocalPlaylist implements LocalPlaylist {
  const _LocalPlaylist({required this.id, required this.name, required  List<Track> tracks, required this.createdAt}): _tracks = tracks;
  factory _LocalPlaylist.fromJson(Map<String, dynamic> json) => _$LocalPlaylistFromJson(json);

@override final  String id;
@override final  String name;
 final  List<Track> _tracks;
@override List<Track> get tracks {
  if (_tracks is EqualUnmodifiableListView) return _tracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tracks);
}

@override final  DateTime createdAt;

/// Create a copy of LocalPlaylist
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalPlaylistCopyWith<_LocalPlaylist> get copyWith => __$LocalPlaylistCopyWithImpl<_LocalPlaylist>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocalPlaylistToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalPlaylist&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.tracks, _tracks)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_tracks),createdAt);
}

@override
String toString() {
    return 'LocalPlaylist(id: $id, name: $name, tracks: $tracks, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$LocalPlaylistCopyWith<$Res> implements $LocalPlaylistCopyWith<$Res> {
  factory _$LocalPlaylistCopyWith(_LocalPlaylist value, $Res Function(_LocalPlaylist) _then) = __$LocalPlaylistCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<Track> tracks, DateTime createdAt
});




}
/// @nodoc
class __$LocalPlaylistCopyWithImpl<$Res>
    implements _$LocalPlaylistCopyWith<$Res> {
  __$LocalPlaylistCopyWithImpl(this._self, this._then);

  final _LocalPlaylist _self;
  final $Res Function(_LocalPlaylist) _then;

/// Create a copy of LocalPlaylist
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? tracks = null,Object? createdAt = null,}) {
  return _then(_LocalPlaylist(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tracks: null == tracks ? _self._tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<Track>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
