// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playlist_export.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlaylistExportTrack {

 String get title; String get artist; int get duration; String get source; String? get streamId; String? get album;
/// Create a copy of PlaylistExportTrack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaylistExportTrackCopyWith<PlaylistExportTrack> get copyWith => _$PlaylistExportTrackCopyWithImpl<PlaylistExportTrack>(this as PlaylistExportTrack, _$identity);

  /// Serializes this PlaylistExportTrack to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlaylistExportTrack;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaylistExportTrack&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.artist, _this.artist) || other.artist == _this.artist)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.streamId, _this.streamId) || other.streamId == _this.streamId)&&(identical(other.album, _this.album) || other.album == _this.album));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlaylistExportTrack;
  return Object.hash(runtimeType,_this.title,_this.artist,_this.duration,_this.source,_this.streamId,_this.album);
}

@override
String toString() {
  final _this = this as PlaylistExportTrack;
  return 'PlaylistExportTrack(title: ${_this.title}, artist: ${_this.artist}, duration: ${_this.duration}, source: ${_this.source}, streamId: ${_this.streamId}, album: ${_this.album})';
}


}

/// @nodoc
abstract mixin class $PlaylistExportTrackCopyWith<$Res>  {
  factory $PlaylistExportTrackCopyWith(PlaylistExportTrack value, $Res Function(PlaylistExportTrack) _then) = _$PlaylistExportTrackCopyWithImpl;
@useResult
$Res call({
 String title, String artist, int duration, String source, String? streamId, String? album
});




}
/// @nodoc
class _$PlaylistExportTrackCopyWithImpl<$Res>
    implements $PlaylistExportTrackCopyWith<$Res> {
  _$PlaylistExportTrackCopyWithImpl(this._self, this._then);

  final PlaylistExportTrack _self;
  final $Res Function(PlaylistExportTrack) _then;

/// Create a copy of PlaylistExportTrack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? artist = null,Object? duration = null,Object? source = null,Object? streamId = freezed,Object? album = freezed,}) {
  return _then(PlaylistExportTrack(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,streamId: freezed == streamId ? _self.streamId : streamId // ignore: cast_nullable_to_non_nullable
as String?,album: freezed == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaylistExportTrack].
extension PlaylistExportTrackPatterns on PlaylistExportTrack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaylistExportTrack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaylistExportTrack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaylistExportTrack value)  $default,){
final _that = this;
switch (_that) {
case _PlaylistExportTrack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaylistExportTrack value)?  $default,){
final _that = this;
switch (_that) {
case _PlaylistExportTrack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String artist,  int duration,  String source,  String? streamId,  String? album)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaylistExportTrack() when $default != null:
return $default(_that.title,_that.artist,_that.duration,_that.source,_that.streamId,_that.album);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String artist,  int duration,  String source,  String? streamId,  String? album)  $default,) {final _that = this;
switch (_that) {
case _PlaylistExportTrack():
return $default(_that.title,_that.artist,_that.duration,_that.source,_that.streamId,_that.album);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String artist,  int duration,  String source,  String? streamId,  String? album)?  $default,) {final _that = this;
switch (_that) {
case _PlaylistExportTrack() when $default != null:
return $default(_that.title,_that.artist,_that.duration,_that.source,_that.streamId,_that.album);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaylistExportTrack implements PlaylistExportTrack {
  const _PlaylistExportTrack({required this.title, this.artist = '', this.duration = 0, this.source = 'audius', this.streamId, this.album});
  factory _PlaylistExportTrack.fromJson(Map<String, dynamic> json) => _$PlaylistExportTrackFromJson(json);

@override final  String title;
@override@JsonKey() final  String artist;
@override@JsonKey() final  int duration;
@override@JsonKey() final  String source;
@override final  String? streamId;
@override final  String? album;

/// Create a copy of PlaylistExportTrack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaylistExportTrackCopyWith<_PlaylistExportTrack> get copyWith => __$PlaylistExportTrackCopyWithImpl<_PlaylistExportTrack>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaylistExportTrackToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaylistExportTrack&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.source, source) || other.source == source)&&(identical(other.streamId, streamId) || other.streamId == streamId)&&(identical(other.album, album) || other.album == album));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,title,artist,duration,source,streamId,album);
}

@override
String toString() {
    return 'PlaylistExportTrack(title: $title, artist: $artist, duration: $duration, source: $source, streamId: $streamId, album: $album)';
}


}

/// @nodoc
abstract mixin class _$PlaylistExportTrackCopyWith<$Res> implements $PlaylistExportTrackCopyWith<$Res> {
  factory _$PlaylistExportTrackCopyWith(_PlaylistExportTrack value, $Res Function(_PlaylistExportTrack) _then) = __$PlaylistExportTrackCopyWithImpl;
@override @useResult
$Res call({
 String title, String artist, int duration, String source, String? streamId, String? album
});




}
/// @nodoc
class __$PlaylistExportTrackCopyWithImpl<$Res>
    implements _$PlaylistExportTrackCopyWith<$Res> {
  __$PlaylistExportTrackCopyWithImpl(this._self, this._then);

  final _PlaylistExportTrack _self;
  final $Res Function(_PlaylistExportTrack) _then;

/// Create a copy of PlaylistExportTrack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? artist = null,Object? duration = null,Object? source = null,Object? streamId = freezed,Object? album = freezed,}) {
  return _then(_PlaylistExportTrack(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,streamId: freezed == streamId ? _self.streamId : streamId // ignore: cast_nullable_to_non_nullable
as String?,album: freezed == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PlaylistExport {

 String get name; String get exportedAt; List<PlaylistExportTrack> get tracks; String get app; String get type; int get version;
/// Create a copy of PlaylistExport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaylistExportCopyWith<PlaylistExport> get copyWith => _$PlaylistExportCopyWithImpl<PlaylistExport>(this as PlaylistExport, _$identity);

  /// Serializes this PlaylistExport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlaylistExport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaylistExport&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.exportedAt, _this.exportedAt) || other.exportedAt == _this.exportedAt)&&const DeepCollectionEquality().equals(other.tracks, _this.tracks)&&(identical(other.app, _this.app) || other.app == _this.app)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.version, _this.version) || other.version == _this.version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlaylistExport;
  return Object.hash(runtimeType,_this.name,_this.exportedAt,const DeepCollectionEquality().hash(_this.tracks),_this.app,_this.type,_this.version);
}

@override
String toString() {
  final _this = this as PlaylistExport;
  return 'PlaylistExport(name: ${_this.name}, exportedAt: ${_this.exportedAt}, tracks: ${_this.tracks}, app: ${_this.app}, type: ${_this.type}, version: ${_this.version})';
}


}

/// @nodoc
abstract mixin class $PlaylistExportCopyWith<$Res>  {
  factory $PlaylistExportCopyWith(PlaylistExport value, $Res Function(PlaylistExport) _then) = _$PlaylistExportCopyWithImpl;
@useResult
$Res call({
 String name, String exportedAt, List<PlaylistExportTrack> tracks, String app, String type, int version
});




}
/// @nodoc
class _$PlaylistExportCopyWithImpl<$Res>
    implements $PlaylistExportCopyWith<$Res> {
  _$PlaylistExportCopyWithImpl(this._self, this._then);

  final PlaylistExport _self;
  final $Res Function(PlaylistExport) _then;

/// Create a copy of PlaylistExport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? exportedAt = null,Object? tracks = null,Object? app = null,Object? type = null,Object? version = null,}) {
  return _then(PlaylistExport(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as String,tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<PlaylistExportTrack>,app: null == app ? _self.app : app // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaylistExport].
extension PlaylistExportPatterns on PlaylistExport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaylistExport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaylistExport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaylistExport value)  $default,){
final _that = this;
switch (_that) {
case _PlaylistExport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaylistExport value)?  $default,){
final _that = this;
switch (_that) {
case _PlaylistExport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String exportedAt,  List<PlaylistExportTrack> tracks,  String app,  String type,  int version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaylistExport() when $default != null:
return $default(_that.name,_that.exportedAt,_that.tracks,_that.app,_that.type,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String exportedAt,  List<PlaylistExportTrack> tracks,  String app,  String type,  int version)  $default,) {final _that = this;
switch (_that) {
case _PlaylistExport():
return $default(_that.name,_that.exportedAt,_that.tracks,_that.app,_that.type,_that.version);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String exportedAt,  List<PlaylistExportTrack> tracks,  String app,  String type,  int version)?  $default,) {final _that = this;
switch (_that) {
case _PlaylistExport() when $default != null:
return $default(_that.name,_that.exportedAt,_that.tracks,_that.app,_that.type,_that.version);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaylistExport implements PlaylistExport {
  const _PlaylistExport({required this.name, required this.exportedAt, required  List<PlaylistExportTrack> tracks, this.app = 'freebify', this.type = 'playlist', this.version = 1}): _tracks = tracks;
  factory _PlaylistExport.fromJson(Map<String, dynamic> json) => _$PlaylistExportFromJson(json);

@override final  String name;
@override final  String exportedAt;
 final  List<PlaylistExportTrack> _tracks;
@override List<PlaylistExportTrack> get tracks {
  if (_tracks is EqualUnmodifiableListView) return _tracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tracks);
}

@override@JsonKey() final  String app;
@override@JsonKey() final  String type;
@override@JsonKey() final  int version;

/// Create a copy of PlaylistExport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaylistExportCopyWith<_PlaylistExport> get copyWith => __$PlaylistExportCopyWithImpl<_PlaylistExport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaylistExportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaylistExport&&(identical(other.name, name) || other.name == name)&&(identical(other.exportedAt, exportedAt) || other.exportedAt == exportedAt)&&const DeepCollectionEquality().equals(other.tracks, _tracks)&&(identical(other.app, app) || other.app == app)&&(identical(other.type, type) || other.type == type)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,exportedAt,const DeepCollectionEquality().hash(_tracks),app,type,version);
}

@override
String toString() {
    return 'PlaylistExport(name: $name, exportedAt: $exportedAt, tracks: $tracks, app: $app, type: $type, version: $version)';
}


}

/// @nodoc
abstract mixin class _$PlaylistExportCopyWith<$Res> implements $PlaylistExportCopyWith<$Res> {
  factory _$PlaylistExportCopyWith(_PlaylistExport value, $Res Function(_PlaylistExport) _then) = __$PlaylistExportCopyWithImpl;
@override @useResult
$Res call({
 String name, String exportedAt, List<PlaylistExportTrack> tracks, String app, String type, int version
});




}
/// @nodoc
class __$PlaylistExportCopyWithImpl<$Res>
    implements _$PlaylistExportCopyWith<$Res> {
  __$PlaylistExportCopyWithImpl(this._self, this._then);

  final _PlaylistExport _self;
  final $Res Function(_PlaylistExport) _then;

/// Create a copy of PlaylistExport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? exportedAt = null,Object? tracks = null,Object? app = null,Object? type = null,Object? version = null,}) {
  return _then(_PlaylistExport(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as String,tracks: null == tracks ? _self._tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<PlaylistExportTrack>,app: null == app ? _self.app : app // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
