// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Track {

 String get id; String get title;@JsonKey(readValue: _readArtist) Artist get artist; TrackSource get source; String? get streamId; bool get pending; int get duration; String? get genre;@JsonKey(readValue: _readPlayCount) int get playCount;@JsonKey(readValue: _readAlbum) AlbumRef? get album; Artwork? get artwork;@JsonKey(readValue: _readIsStreamable) bool get isStreamable;
/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackCopyWith<Track> get copyWith => _$TrackCopyWithImpl<Track>(this as Track, _$identity);

  /// Serializes this Track to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Track;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Track&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.artist, _this.artist) || other.artist == _this.artist)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.streamId, _this.streamId) || other.streamId == _this.streamId)&&(identical(other.pending, _this.pending) || other.pending == _this.pending)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.genre, _this.genre) || other.genre == _this.genre)&&(identical(other.playCount, _this.playCount) || other.playCount == _this.playCount)&&(identical(other.album, _this.album) || other.album == _this.album)&&(identical(other.artwork, _this.artwork) || other.artwork == _this.artwork)&&(identical(other.isStreamable, _this.isStreamable) || other.isStreamable == _this.isStreamable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Track;
  return Object.hash(runtimeType,_this.id,_this.title,_this.artist,_this.source,_this.streamId,_this.pending,_this.duration,_this.genre,_this.playCount,_this.album,_this.artwork,_this.isStreamable);
}

@override
String toString() {
  final _this = this as Track;
  return 'Track(id: ${_this.id}, title: ${_this.title}, artist: ${_this.artist}, source: ${_this.source}, streamId: ${_this.streamId}, pending: ${_this.pending}, duration: ${_this.duration}, genre: ${_this.genre}, playCount: ${_this.playCount}, album: ${_this.album}, artwork: ${_this.artwork}, isStreamable: ${_this.isStreamable})';
}


}

/// @nodoc
abstract mixin class $TrackCopyWith<$Res>  {
  factory $TrackCopyWith(Track value, $Res Function(Track) _then) = _$TrackCopyWithImpl;
@useResult
$Res call({
 String id, String title,@JsonKey(readValue: _readArtist) Artist artist, TrackSource source, String? streamId, bool pending, int duration, String? genre,@JsonKey(readValue: _readPlayCount) int playCount,@JsonKey(readValue: _readAlbum) AlbumRef? album, Artwork? artwork,@JsonKey(readValue: _readIsStreamable) bool isStreamable
});


$ArtistCopyWith<$Res> get artist;$AlbumRefCopyWith<$Res>? get album;$ArtworkCopyWith<$Res>? get artwork;

}
/// @nodoc
class _$TrackCopyWithImpl<$Res>
    implements $TrackCopyWith<$Res> {
  _$TrackCopyWithImpl(this._self, this._then);

  final Track _self;
  final $Res Function(Track) _then;

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? artist = null,Object? source = null,Object? streamId = freezed,Object? pending = null,Object? duration = null,Object? genre = freezed,Object? playCount = null,Object? album = freezed,Object? artwork = freezed,Object? isStreamable = null,}) {
  return _then(Track(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as Artist,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as TrackSource,streamId: freezed == streamId ? _self.streamId : streamId // ignore: cast_nullable_to_non_nullable
as String?,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as bool,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,album: freezed == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as AlbumRef?,artwork: freezed == artwork ? _self.artwork : artwork // ignore: cast_nullable_to_non_nullable
as Artwork?,isStreamable: null == isStreamable ? _self.isStreamable : isStreamable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ArtistCopyWith<$Res> get artist {
  
  return $ArtistCopyWith<$Res>(_self.artist, (value) {
    return _then(_self.copyWith(artist: value));
  });
}/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlbumRefCopyWith<$Res>? get album {
    if (_self.album == null) {
    return null;
  }

  return $AlbumRefCopyWith<$Res>(_self.album!, (value) {
    return _then(_self.copyWith(album: value));
  });
}/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ArtworkCopyWith<$Res>? get artwork {
    if (_self.artwork == null) {
    return null;
  }

  return $ArtworkCopyWith<$Res>(_self.artwork!, (value) {
    return _then(_self.copyWith(artwork: value));
  });
}
}


/// Adds pattern-matching-related methods to [Track].
extension TrackPatterns on Track {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Track value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Track() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Track value)  $default,){
final _that = this;
switch (_that) {
case _Track():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Track value)?  $default,){
final _that = this;
switch (_that) {
case _Track() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(readValue: _readArtist)  Artist artist,  TrackSource source,  String? streamId,  bool pending,  int duration,  String? genre, @JsonKey(readValue: _readPlayCount)  int playCount, @JsonKey(readValue: _readAlbum)  AlbumRef? album,  Artwork? artwork, @JsonKey(readValue: _readIsStreamable)  bool isStreamable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Track() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.source,_that.streamId,_that.pending,_that.duration,_that.genre,_that.playCount,_that.album,_that.artwork,_that.isStreamable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(readValue: _readArtist)  Artist artist,  TrackSource source,  String? streamId,  bool pending,  int duration,  String? genre, @JsonKey(readValue: _readPlayCount)  int playCount, @JsonKey(readValue: _readAlbum)  AlbumRef? album,  Artwork? artwork, @JsonKey(readValue: _readIsStreamable)  bool isStreamable)  $default,) {final _that = this;
switch (_that) {
case _Track():
return $default(_that.id,_that.title,_that.artist,_that.source,_that.streamId,_that.pending,_that.duration,_that.genre,_that.playCount,_that.album,_that.artwork,_that.isStreamable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title, @JsonKey(readValue: _readArtist)  Artist artist,  TrackSource source,  String? streamId,  bool pending,  int duration,  String? genre, @JsonKey(readValue: _readPlayCount)  int playCount, @JsonKey(readValue: _readAlbum)  AlbumRef? album,  Artwork? artwork, @JsonKey(readValue: _readIsStreamable)  bool isStreamable)?  $default,) {final _that = this;
switch (_that) {
case _Track() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.source,_that.streamId,_that.pending,_that.duration,_that.genre,_that.playCount,_that.album,_that.artwork,_that.isStreamable);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Track implements Track {
  const _Track({required this.id, required this.title, @JsonKey(readValue: _readArtist) required this.artist, this.source = TrackSource.audius, this.streamId, this.pending = false, this.duration = 0, this.genre, @JsonKey(readValue: _readPlayCount) this.playCount = 0, @JsonKey(readValue: _readAlbum) this.album, this.artwork, @JsonKey(readValue: _readIsStreamable) this.isStreamable = true});
  factory _Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey(readValue: _readArtist) final  Artist artist;
@override@JsonKey() final  TrackSource source;
@override final  String? streamId;
@override@JsonKey() final  bool pending;
@override@JsonKey() final  int duration;
@override final  String? genre;
@override@JsonKey(readValue: _readPlayCount) final  int playCount;
@override@JsonKey(readValue: _readAlbum) final  AlbumRef? album;
@override final  Artwork? artwork;
@override@JsonKey(readValue: _readIsStreamable) final  bool isStreamable;

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackCopyWith<_Track> get copyWith => __$TrackCopyWithImpl<_Track>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Track&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.source, source) || other.source == source)&&(identical(other.streamId, streamId) || other.streamId == streamId)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&(identical(other.album, album) || other.album == album)&&(identical(other.artwork, artwork) || other.artwork == artwork)&&(identical(other.isStreamable, isStreamable) || other.isStreamable == isStreamable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,artist,source,streamId,pending,duration,genre,playCount,album,artwork,isStreamable);
}

@override
String toString() {
    return 'Track(id: $id, title: $title, artist: $artist, source: $source, streamId: $streamId, pending: $pending, duration: $duration, genre: $genre, playCount: $playCount, album: $album, artwork: $artwork, isStreamable: $isStreamable)';
}


}

/// @nodoc
abstract mixin class _$TrackCopyWith<$Res> implements $TrackCopyWith<$Res> {
  factory _$TrackCopyWith(_Track value, $Res Function(_Track) _then) = __$TrackCopyWithImpl;
@override @useResult
$Res call({
 String id, String title,@JsonKey(readValue: _readArtist) Artist artist, TrackSource source, String? streamId, bool pending, int duration, String? genre,@JsonKey(readValue: _readPlayCount) int playCount,@JsonKey(readValue: _readAlbum) AlbumRef? album, Artwork? artwork,@JsonKey(readValue: _readIsStreamable) bool isStreamable
});


@override $ArtistCopyWith<$Res> get artist;@override $AlbumRefCopyWith<$Res>? get album;@override $ArtworkCopyWith<$Res>? get artwork;

}
/// @nodoc
class __$TrackCopyWithImpl<$Res>
    implements _$TrackCopyWith<$Res> {
  __$TrackCopyWithImpl(this._self, this._then);

  final _Track _self;
  final $Res Function(_Track) _then;

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? artist = null,Object? source = null,Object? streamId = freezed,Object? pending = null,Object? duration = null,Object? genre = freezed,Object? playCount = null,Object? album = freezed,Object? artwork = freezed,Object? isStreamable = null,}) {
  return _then(_Track(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as Artist,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as TrackSource,streamId: freezed == streamId ? _self.streamId : streamId // ignore: cast_nullable_to_non_nullable
as String?,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as bool,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,album: freezed == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as AlbumRef?,artwork: freezed == artwork ? _self.artwork : artwork // ignore: cast_nullable_to_non_nullable
as Artwork?,isStreamable: null == isStreamable ? _self.isStreamable : isStreamable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ArtistCopyWith<$Res> get artist {
  
  return $ArtistCopyWith<$Res>(_self.artist, (value) {
    return _then(_self.copyWith(artist: value));
  });
}/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlbumRefCopyWith<$Res>? get album {
    if (_self.album == null) {
    return null;
  }

  return $AlbumRefCopyWith<$Res>(_self.album!, (value) {
    return _then(_self.copyWith(album: value));
  });
}/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ArtworkCopyWith<$Res>? get artwork {
    if (_self.artwork == null) {
    return null;
  }

  return $ArtworkCopyWith<$Res>(_self.artwork!, (value) {
    return _then(_self.copyWith(artwork: value));
  });
}
}

// dart format on
