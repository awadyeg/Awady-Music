// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'artist.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Artist {

 String get id; String get name; String? get streamId; String get handle; String? get bio;@JsonKey(readValue: _readIsVerified) bool get isVerified;@JsonKey(readValue: _readFollowerCount) int get followerCount;@JsonKey(readValue: _readTrackCount) int get trackCount;@JsonKey(readValue: _readProfilePicture) Artwork? get profilePicture;@JsonKey(readValue: _readCoverPhoto) String? get coverPhoto;
/// Create a copy of Artist
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArtistCopyWith<Artist> get copyWith => _$ArtistCopyWithImpl<Artist>(this as Artist, _$identity);

  /// Serializes this Artist to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Artist;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Artist&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.streamId, _this.streamId) || other.streamId == _this.streamId)&&(identical(other.handle, _this.handle) || other.handle == _this.handle)&&(identical(other.bio, _this.bio) || other.bio == _this.bio)&&(identical(other.isVerified, _this.isVerified) || other.isVerified == _this.isVerified)&&(identical(other.followerCount, _this.followerCount) || other.followerCount == _this.followerCount)&&(identical(other.trackCount, _this.trackCount) || other.trackCount == _this.trackCount)&&(identical(other.profilePicture, _this.profilePicture) || other.profilePicture == _this.profilePicture)&&(identical(other.coverPhoto, _this.coverPhoto) || other.coverPhoto == _this.coverPhoto));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Artist;
  return Object.hash(runtimeType,_this.id,_this.name,_this.streamId,_this.handle,_this.bio,_this.isVerified,_this.followerCount,_this.trackCount,_this.profilePicture,_this.coverPhoto);
}

@override
String toString() {
  final _this = this as Artist;
  return 'Artist(id: ${_this.id}, name: ${_this.name}, streamId: ${_this.streamId}, handle: ${_this.handle}, bio: ${_this.bio}, isVerified: ${_this.isVerified}, followerCount: ${_this.followerCount}, trackCount: ${_this.trackCount}, profilePicture: ${_this.profilePicture}, coverPhoto: ${_this.coverPhoto})';
}


}

/// @nodoc
abstract mixin class $ArtistCopyWith<$Res>  {
  factory $ArtistCopyWith(Artist value, $Res Function(Artist) _then) = _$ArtistCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? streamId, String handle, String? bio,@JsonKey(readValue: _readIsVerified) bool isVerified,@JsonKey(readValue: _readFollowerCount) int followerCount,@JsonKey(readValue: _readTrackCount) int trackCount,@JsonKey(readValue: _readProfilePicture) Artwork? profilePicture,@JsonKey(readValue: _readCoverPhoto) String? coverPhoto
});


$ArtworkCopyWith<$Res>? get profilePicture;

}
/// @nodoc
class _$ArtistCopyWithImpl<$Res>
    implements $ArtistCopyWith<$Res> {
  _$ArtistCopyWithImpl(this._self, this._then);

  final Artist _self;
  final $Res Function(Artist) _then;

/// Create a copy of Artist
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? streamId = freezed,Object? handle = null,Object? bio = freezed,Object? isVerified = null,Object? followerCount = null,Object? trackCount = null,Object? profilePicture = freezed,Object? coverPhoto = freezed,}) {
  return _then(Artist(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,streamId: freezed == streamId ? _self.streamId : streamId // ignore: cast_nullable_to_non_nullable
as String?,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,trackCount: null == trackCount ? _self.trackCount : trackCount // ignore: cast_nullable_to_non_nullable
as int,profilePicture: freezed == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as Artwork?,coverPhoto: freezed == coverPhoto ? _self.coverPhoto : coverPhoto // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Artist
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ArtworkCopyWith<$Res>? get profilePicture {
    if (_self.profilePicture == null) {
    return null;
  }

  return $ArtworkCopyWith<$Res>(_self.profilePicture!, (value) {
    return _then(_self.copyWith(profilePicture: value));
  });
}
}


/// Adds pattern-matching-related methods to [Artist].
extension ArtistPatterns on Artist {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Artist value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Artist() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Artist value)  $default,){
final _that = this;
switch (_that) {
case _Artist():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Artist value)?  $default,){
final _that = this;
switch (_that) {
case _Artist() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? streamId,  String handle,  String? bio, @JsonKey(readValue: _readIsVerified)  bool isVerified, @JsonKey(readValue: _readFollowerCount)  int followerCount, @JsonKey(readValue: _readTrackCount)  int trackCount, @JsonKey(readValue: _readProfilePicture)  Artwork? profilePicture, @JsonKey(readValue: _readCoverPhoto)  String? coverPhoto)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Artist() when $default != null:
return $default(_that.id,_that.name,_that.streamId,_that.handle,_that.bio,_that.isVerified,_that.followerCount,_that.trackCount,_that.profilePicture,_that.coverPhoto);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? streamId,  String handle,  String? bio, @JsonKey(readValue: _readIsVerified)  bool isVerified, @JsonKey(readValue: _readFollowerCount)  int followerCount, @JsonKey(readValue: _readTrackCount)  int trackCount, @JsonKey(readValue: _readProfilePicture)  Artwork? profilePicture, @JsonKey(readValue: _readCoverPhoto)  String? coverPhoto)  $default,) {final _that = this;
switch (_that) {
case _Artist():
return $default(_that.id,_that.name,_that.streamId,_that.handle,_that.bio,_that.isVerified,_that.followerCount,_that.trackCount,_that.profilePicture,_that.coverPhoto);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? streamId,  String handle,  String? bio, @JsonKey(readValue: _readIsVerified)  bool isVerified, @JsonKey(readValue: _readFollowerCount)  int followerCount, @JsonKey(readValue: _readTrackCount)  int trackCount, @JsonKey(readValue: _readProfilePicture)  Artwork? profilePicture, @JsonKey(readValue: _readCoverPhoto)  String? coverPhoto)?  $default,) {final _that = this;
switch (_that) {
case _Artist() when $default != null:
return $default(_that.id,_that.name,_that.streamId,_that.handle,_that.bio,_that.isVerified,_that.followerCount,_that.trackCount,_that.profilePicture,_that.coverPhoto);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Artist extends Artist {
  const _Artist({required this.id, required this.name, this.streamId, this.handle = '', this.bio, @JsonKey(readValue: _readIsVerified) this.isVerified = false, @JsonKey(readValue: _readFollowerCount) this.followerCount = 0, @JsonKey(readValue: _readTrackCount) this.trackCount = 0, @JsonKey(readValue: _readProfilePicture) this.profilePicture, @JsonKey(readValue: _readCoverPhoto) this.coverPhoto}): super._();
  factory _Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? streamId;
@override@JsonKey() final  String handle;
@override final  String? bio;
@override@JsonKey(readValue: _readIsVerified) final  bool isVerified;
@override@JsonKey(readValue: _readFollowerCount) final  int followerCount;
@override@JsonKey(readValue: _readTrackCount) final  int trackCount;
@override@JsonKey(readValue: _readProfilePicture) final  Artwork? profilePicture;
@override@JsonKey(readValue: _readCoverPhoto) final  String? coverPhoto;

/// Create a copy of Artist
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArtistCopyWith<_Artist> get copyWith => __$ArtistCopyWithImpl<_Artist>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ArtistToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Artist&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.streamId, streamId) || other.streamId == streamId)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.followerCount, followerCount) || other.followerCount == followerCount)&&(identical(other.trackCount, trackCount) || other.trackCount == trackCount)&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.coverPhoto, coverPhoto) || other.coverPhoto == coverPhoto));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,streamId,handle,bio,isVerified,followerCount,trackCount,profilePicture,coverPhoto);
}

@override
String toString() {
    return 'Artist(id: $id, name: $name, streamId: $streamId, handle: $handle, bio: $bio, isVerified: $isVerified, followerCount: $followerCount, trackCount: $trackCount, profilePicture: $profilePicture, coverPhoto: $coverPhoto)';
}


}

/// @nodoc
abstract mixin class _$ArtistCopyWith<$Res> implements $ArtistCopyWith<$Res> {
  factory _$ArtistCopyWith(_Artist value, $Res Function(_Artist) _then) = __$ArtistCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? streamId, String handle, String? bio,@JsonKey(readValue: _readIsVerified) bool isVerified,@JsonKey(readValue: _readFollowerCount) int followerCount,@JsonKey(readValue: _readTrackCount) int trackCount,@JsonKey(readValue: _readProfilePicture) Artwork? profilePicture,@JsonKey(readValue: _readCoverPhoto) String? coverPhoto
});


@override $ArtworkCopyWith<$Res>? get profilePicture;

}
/// @nodoc
class __$ArtistCopyWithImpl<$Res>
    implements _$ArtistCopyWith<$Res> {
  __$ArtistCopyWithImpl(this._self, this._then);

  final _Artist _self;
  final $Res Function(_Artist) _then;

/// Create a copy of Artist
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? streamId = freezed,Object? handle = null,Object? bio = freezed,Object? isVerified = null,Object? followerCount = null,Object? trackCount = null,Object? profilePicture = freezed,Object? coverPhoto = freezed,}) {
  return _then(_Artist(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,streamId: freezed == streamId ? _self.streamId : streamId // ignore: cast_nullable_to_non_nullable
as String?,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,trackCount: null == trackCount ? _self.trackCount : trackCount // ignore: cast_nullable_to_non_nullable
as int,profilePicture: freezed == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as Artwork?,coverPhoto: freezed == coverPhoto ? _self.coverPhoto : coverPhoto // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Artist
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ArtworkCopyWith<$Res>? get profilePicture {
    if (_self.profilePicture == null) {
    return null;
  }

  return $ArtworkCopyWith<$Res>(_self.profilePicture!, (value) {
    return _then(_self.copyWith(profilePicture: value));
  });
}
}

// dart format on
