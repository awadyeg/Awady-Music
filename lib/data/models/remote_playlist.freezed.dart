// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'remote_playlist.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RemotePlaylist {

 String get id;@JsonKey(readValue: _readName) String get name;@JsonKey(readValue: _readOwner) Artist get owner;@JsonKey(readValue: _readIsAlbum) bool get isAlbum; String? get description; Artwork? get artwork;@JsonKey(readValue: _readTrackCount) int get trackCount;
/// Create a copy of RemotePlaylist
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemotePlaylistCopyWith<RemotePlaylist> get copyWith => _$RemotePlaylistCopyWithImpl<RemotePlaylist>(this as RemotePlaylist, _$identity);

  /// Serializes this RemotePlaylist to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RemotePlaylist;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemotePlaylist&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.owner, _this.owner) || other.owner == _this.owner)&&(identical(other.isAlbum, _this.isAlbum) || other.isAlbum == _this.isAlbum)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.artwork, _this.artwork) || other.artwork == _this.artwork)&&(identical(other.trackCount, _this.trackCount) || other.trackCount == _this.trackCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RemotePlaylist;
  return Object.hash(runtimeType,_this.id,_this.name,_this.owner,_this.isAlbum,_this.description,_this.artwork,_this.trackCount);
}

@override
String toString() {
  final _this = this as RemotePlaylist;
  return 'RemotePlaylist(id: ${_this.id}, name: ${_this.name}, owner: ${_this.owner}, isAlbum: ${_this.isAlbum}, description: ${_this.description}, artwork: ${_this.artwork}, trackCount: ${_this.trackCount})';
}


}

/// @nodoc
abstract mixin class $RemotePlaylistCopyWith<$Res>  {
  factory $RemotePlaylistCopyWith(RemotePlaylist value, $Res Function(RemotePlaylist) _then) = _$RemotePlaylistCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(readValue: _readName) String name,@JsonKey(readValue: _readOwner) Artist owner,@JsonKey(readValue: _readIsAlbum) bool isAlbum, String? description, Artwork? artwork,@JsonKey(readValue: _readTrackCount) int trackCount
});


$ArtistCopyWith<$Res> get owner;$ArtworkCopyWith<$Res>? get artwork;

}
/// @nodoc
class _$RemotePlaylistCopyWithImpl<$Res>
    implements $RemotePlaylistCopyWith<$Res> {
  _$RemotePlaylistCopyWithImpl(this._self, this._then);

  final RemotePlaylist _self;
  final $Res Function(RemotePlaylist) _then;

/// Create a copy of RemotePlaylist
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? owner = null,Object? isAlbum = null,Object? description = freezed,Object? artwork = freezed,Object? trackCount = null,}) {
  return _then(RemotePlaylist(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as Artist,isAlbum: null == isAlbum ? _self.isAlbum : isAlbum // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,artwork: freezed == artwork ? _self.artwork : artwork // ignore: cast_nullable_to_non_nullable
as Artwork?,trackCount: null == trackCount ? _self.trackCount : trackCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of RemotePlaylist
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ArtistCopyWith<$Res> get owner {
  
  return $ArtistCopyWith<$Res>(_self.owner, (value) {
    return _then(_self.copyWith(owner: value));
  });
}/// Create a copy of RemotePlaylist
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


/// Adds pattern-matching-related methods to [RemotePlaylist].
extension RemotePlaylistPatterns on RemotePlaylist {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RemotePlaylist value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RemotePlaylist() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RemotePlaylist value)  $default,){
final _that = this;
switch (_that) {
case _RemotePlaylist():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RemotePlaylist value)?  $default,){
final _that = this;
switch (_that) {
case _RemotePlaylist() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(readValue: _readName)  String name, @JsonKey(readValue: _readOwner)  Artist owner, @JsonKey(readValue: _readIsAlbum)  bool isAlbum,  String? description,  Artwork? artwork, @JsonKey(readValue: _readTrackCount)  int trackCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RemotePlaylist() when $default != null:
return $default(_that.id,_that.name,_that.owner,_that.isAlbum,_that.description,_that.artwork,_that.trackCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(readValue: _readName)  String name, @JsonKey(readValue: _readOwner)  Artist owner, @JsonKey(readValue: _readIsAlbum)  bool isAlbum,  String? description,  Artwork? artwork, @JsonKey(readValue: _readTrackCount)  int trackCount)  $default,) {final _that = this;
switch (_that) {
case _RemotePlaylist():
return $default(_that.id,_that.name,_that.owner,_that.isAlbum,_that.description,_that.artwork,_that.trackCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(readValue: _readName)  String name, @JsonKey(readValue: _readOwner)  Artist owner, @JsonKey(readValue: _readIsAlbum)  bool isAlbum,  String? description,  Artwork? artwork, @JsonKey(readValue: _readTrackCount)  int trackCount)?  $default,) {final _that = this;
switch (_that) {
case _RemotePlaylist() when $default != null:
return $default(_that.id,_that.name,_that.owner,_that.isAlbum,_that.description,_that.artwork,_that.trackCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RemotePlaylist implements RemotePlaylist {
  const _RemotePlaylist({required this.id, @JsonKey(readValue: _readName) required this.name, @JsonKey(readValue: _readOwner) required this.owner, @JsonKey(readValue: _readIsAlbum) this.isAlbum = false, this.description, this.artwork, @JsonKey(readValue: _readTrackCount) this.trackCount = 0});
  factory _RemotePlaylist.fromJson(Map<String, dynamic> json) => _$RemotePlaylistFromJson(json);

@override final  String id;
@override@JsonKey(readValue: _readName) final  String name;
@override@JsonKey(readValue: _readOwner) final  Artist owner;
@override@JsonKey(readValue: _readIsAlbum) final  bool isAlbum;
@override final  String? description;
@override final  Artwork? artwork;
@override@JsonKey(readValue: _readTrackCount) final  int trackCount;

/// Create a copy of RemotePlaylist
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemotePlaylistCopyWith<_RemotePlaylist> get copyWith => __$RemotePlaylistCopyWithImpl<_RemotePlaylist>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RemotePlaylistToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemotePlaylist&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.isAlbum, isAlbum) || other.isAlbum == isAlbum)&&(identical(other.description, description) || other.description == description)&&(identical(other.artwork, artwork) || other.artwork == artwork)&&(identical(other.trackCount, trackCount) || other.trackCount == trackCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,owner,isAlbum,description,artwork,trackCount);
}

@override
String toString() {
    return 'RemotePlaylist(id: $id, name: $name, owner: $owner, isAlbum: $isAlbum, description: $description, artwork: $artwork, trackCount: $trackCount)';
}


}

/// @nodoc
abstract mixin class _$RemotePlaylistCopyWith<$Res> implements $RemotePlaylistCopyWith<$Res> {
  factory _$RemotePlaylistCopyWith(_RemotePlaylist value, $Res Function(_RemotePlaylist) _then) = __$RemotePlaylistCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(readValue: _readName) String name,@JsonKey(readValue: _readOwner) Artist owner,@JsonKey(readValue: _readIsAlbum) bool isAlbum, String? description, Artwork? artwork,@JsonKey(readValue: _readTrackCount) int trackCount
});


@override $ArtistCopyWith<$Res> get owner;@override $ArtworkCopyWith<$Res>? get artwork;

}
/// @nodoc
class __$RemotePlaylistCopyWithImpl<$Res>
    implements _$RemotePlaylistCopyWith<$Res> {
  __$RemotePlaylistCopyWithImpl(this._self, this._then);

  final _RemotePlaylist _self;
  final $Res Function(_RemotePlaylist) _then;

/// Create a copy of RemotePlaylist
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? owner = null,Object? isAlbum = null,Object? description = freezed,Object? artwork = freezed,Object? trackCount = null,}) {
  return _then(_RemotePlaylist(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as Artist,isAlbum: null == isAlbum ? _self.isAlbum : isAlbum // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,artwork: freezed == artwork ? _self.artwork : artwork // ignore: cast_nullable_to_non_nullable
as Artwork?,trackCount: null == trackCount ? _self.trackCount : trackCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of RemotePlaylist
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ArtistCopyWith<$Res> get owner {
  
  return $ArtistCopyWith<$Res>(_self.owner, (value) {
    return _then(_self.copyWith(owner: value));
  });
}/// Create a copy of RemotePlaylist
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
