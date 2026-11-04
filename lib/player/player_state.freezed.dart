// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlayerState {

 List<Track> get queue; int get index; List<int> get history; bool get isPlaying; bool get buffering; Duration get currentTime; Duration get duration; double get volume; bool get muted; bool get shuffle; RepeatMode get repeat; bool get npOpen; bool get queueOpen; String? get notice; bool get autoplay; List<double> get eq; bool get normOn; int get fadeSecs; DateTime? get sleepAt; List<int> get shuffleDeck;
/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerStateCopyWith<PlayerState> get copyWith => _$PlayerStateCopyWithImpl<PlayerState>(this as PlayerState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PlayerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerState&&const DeepCollectionEquality().equals(other.queue, _this.queue)&&(identical(other.index, _this.index) || other.index == _this.index)&&const DeepCollectionEquality().equals(other.history, _this.history)&&(identical(other.isPlaying, _this.isPlaying) || other.isPlaying == _this.isPlaying)&&(identical(other.buffering, _this.buffering) || other.buffering == _this.buffering)&&(identical(other.currentTime, _this.currentTime) || other.currentTime == _this.currentTime)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.volume, _this.volume) || other.volume == _this.volume)&&(identical(other.muted, _this.muted) || other.muted == _this.muted)&&(identical(other.shuffle, _this.shuffle) || other.shuffle == _this.shuffle)&&(identical(other.repeat, _this.repeat) || other.repeat == _this.repeat)&&(identical(other.npOpen, _this.npOpen) || other.npOpen == _this.npOpen)&&(identical(other.queueOpen, _this.queueOpen) || other.queueOpen == _this.queueOpen)&&(identical(other.notice, _this.notice) || other.notice == _this.notice)&&(identical(other.autoplay, _this.autoplay) || other.autoplay == _this.autoplay)&&const DeepCollectionEquality().equals(other.eq, _this.eq)&&(identical(other.normOn, _this.normOn) || other.normOn == _this.normOn)&&(identical(other.fadeSecs, _this.fadeSecs) || other.fadeSecs == _this.fadeSecs)&&(identical(other.sleepAt, _this.sleepAt) || other.sleepAt == _this.sleepAt)&&const DeepCollectionEquality().equals(other.shuffleDeck, _this.shuffleDeck));
}


@override
int get hashCode {
  final _this = this as PlayerState;
  return Object.hashAll([runtimeType,const DeepCollectionEquality().hash(_this.queue),_this.index,const DeepCollectionEquality().hash(_this.history),_this.isPlaying,_this.buffering,_this.currentTime,_this.duration,_this.volume,_this.muted,_this.shuffle,_this.repeat,_this.npOpen,_this.queueOpen,_this.notice,_this.autoplay,const DeepCollectionEquality().hash(_this.eq),_this.normOn,_this.fadeSecs,_this.sleepAt,const DeepCollectionEquality().hash(_this.shuffleDeck)]);
}

@override
String toString() {
  final _this = this as PlayerState;
  return 'PlayerState(queue: ${_this.queue}, index: ${_this.index}, history: ${_this.history}, isPlaying: ${_this.isPlaying}, buffering: ${_this.buffering}, currentTime: ${_this.currentTime}, duration: ${_this.duration}, volume: ${_this.volume}, muted: ${_this.muted}, shuffle: ${_this.shuffle}, repeat: ${_this.repeat}, npOpen: ${_this.npOpen}, queueOpen: ${_this.queueOpen}, notice: ${_this.notice}, autoplay: ${_this.autoplay}, eq: ${_this.eq}, normOn: ${_this.normOn}, fadeSecs: ${_this.fadeSecs}, sleepAt: ${_this.sleepAt}, shuffleDeck: ${_this.shuffleDeck})';
}


}

/// @nodoc
abstract mixin class $PlayerStateCopyWith<$Res>  {
  factory $PlayerStateCopyWith(PlayerState value, $Res Function(PlayerState) _then) = _$PlayerStateCopyWithImpl;
@useResult
$Res call({
 List<Track> queue, int index, List<int> history, bool isPlaying, bool buffering, Duration currentTime, Duration duration, double volume, bool muted, bool shuffle, RepeatMode repeat, bool npOpen, bool queueOpen, String? notice, bool autoplay, List<double> eq, bool normOn, int fadeSecs, DateTime? sleepAt, List<int> shuffleDeck
});




}
/// @nodoc
class _$PlayerStateCopyWithImpl<$Res>
    implements $PlayerStateCopyWith<$Res> {
  _$PlayerStateCopyWithImpl(this._self, this._then);

  final PlayerState _self;
  final $Res Function(PlayerState) _then;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? queue = null,Object? index = null,Object? history = null,Object? isPlaying = null,Object? buffering = null,Object? currentTime = null,Object? duration = null,Object? volume = null,Object? muted = null,Object? shuffle = null,Object? repeat = null,Object? npOpen = null,Object? queueOpen = null,Object? notice = freezed,Object? autoplay = null,Object? eq = null,Object? normOn = null,Object? fadeSecs = null,Object? sleepAt = freezed,Object? shuffleDeck = null,}) {
  return _then(PlayerState(
queue: null == queue ? _self.queue : queue // ignore: cast_nullable_to_non_nullable
as List<Track>,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<int>,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,buffering: null == buffering ? _self.buffering : buffering // ignore: cast_nullable_to_non_nullable
as bool,currentTime: null == currentTime ? _self.currentTime : currentTime // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,shuffle: null == shuffle ? _self.shuffle : shuffle // ignore: cast_nullable_to_non_nullable
as bool,repeat: null == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as RepeatMode,npOpen: null == npOpen ? _self.npOpen : npOpen // ignore: cast_nullable_to_non_nullable
as bool,queueOpen: null == queueOpen ? _self.queueOpen : queueOpen // ignore: cast_nullable_to_non_nullable
as bool,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as String?,autoplay: null == autoplay ? _self.autoplay : autoplay // ignore: cast_nullable_to_non_nullable
as bool,eq: null == eq ? _self.eq : eq // ignore: cast_nullable_to_non_nullable
as List<double>,normOn: null == normOn ? _self.normOn : normOn // ignore: cast_nullable_to_non_nullable
as bool,fadeSecs: null == fadeSecs ? _self.fadeSecs : fadeSecs // ignore: cast_nullable_to_non_nullable
as int,sleepAt: freezed == sleepAt ? _self.sleepAt : sleepAt // ignore: cast_nullable_to_non_nullable
as DateTime?,shuffleDeck: null == shuffleDeck ? _self.shuffleDeck : shuffleDeck // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerState].
extension PlayerStatePatterns on PlayerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerState value)  $default,){
final _that = this;
switch (_that) {
case _PlayerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerState value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Track> queue,  int index,  List<int> history,  bool isPlaying,  bool buffering,  Duration currentTime,  Duration duration,  double volume,  bool muted,  bool shuffle,  RepeatMode repeat,  bool npOpen,  bool queueOpen,  String? notice,  bool autoplay,  List<double> eq,  bool normOn,  int fadeSecs,  DateTime? sleepAt,  List<int> shuffleDeck)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that.queue,_that.index,_that.history,_that.isPlaying,_that.buffering,_that.currentTime,_that.duration,_that.volume,_that.muted,_that.shuffle,_that.repeat,_that.npOpen,_that.queueOpen,_that.notice,_that.autoplay,_that.eq,_that.normOn,_that.fadeSecs,_that.sleepAt,_that.shuffleDeck);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Track> queue,  int index,  List<int> history,  bool isPlaying,  bool buffering,  Duration currentTime,  Duration duration,  double volume,  bool muted,  bool shuffle,  RepeatMode repeat,  bool npOpen,  bool queueOpen,  String? notice,  bool autoplay,  List<double> eq,  bool normOn,  int fadeSecs,  DateTime? sleepAt,  List<int> shuffleDeck)  $default,) {final _that = this;
switch (_that) {
case _PlayerState():
return $default(_that.queue,_that.index,_that.history,_that.isPlaying,_that.buffering,_that.currentTime,_that.duration,_that.volume,_that.muted,_that.shuffle,_that.repeat,_that.npOpen,_that.queueOpen,_that.notice,_that.autoplay,_that.eq,_that.normOn,_that.fadeSecs,_that.sleepAt,_that.shuffleDeck);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Track> queue,  int index,  List<int> history,  bool isPlaying,  bool buffering,  Duration currentTime,  Duration duration,  double volume,  bool muted,  bool shuffle,  RepeatMode repeat,  bool npOpen,  bool queueOpen,  String? notice,  bool autoplay,  List<double> eq,  bool normOn,  int fadeSecs,  DateTime? sleepAt,  List<int> shuffleDeck)?  $default,) {final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that.queue,_that.index,_that.history,_that.isPlaying,_that.buffering,_that.currentTime,_that.duration,_that.volume,_that.muted,_that.shuffle,_that.repeat,_that.npOpen,_that.queueOpen,_that.notice,_that.autoplay,_that.eq,_that.normOn,_that.fadeSecs,_that.sleepAt,_that.shuffleDeck);case _:
  return null;

}
}

}

/// @nodoc


class _PlayerState extends PlayerState {
  const _PlayerState({ List<Track> queue = const [], this.index = -1,  List<int> history = const [], this.isPlaying = false, this.buffering = false, this.currentTime = Duration.zero, this.duration = Duration.zero, this.volume = 0.85, this.muted = false, this.shuffle = false, this.repeat = RepeatMode.off, this.npOpen = false, this.queueOpen = false, this.notice, this.autoplay = true,  List<double> eq = const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], this.normOn = true, this.fadeSecs = 4, this.sleepAt,  List<int> shuffleDeck = const []}): _queue = queue,_history = history,_eq = eq,_shuffleDeck = shuffleDeck,super._();
  

 final  List<Track> _queue;
@override@JsonKey() List<Track> get queue {
  if (_queue is EqualUnmodifiableListView) return _queue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_queue);
}

@override@JsonKey() final  int index;
 final  List<int> _history;
@override@JsonKey() List<int> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

@override@JsonKey() final  bool isPlaying;
@override@JsonKey() final  bool buffering;
@override@JsonKey() final  Duration currentTime;
@override@JsonKey() final  Duration duration;
@override@JsonKey() final  double volume;
@override@JsonKey() final  bool muted;
@override@JsonKey() final  bool shuffle;
@override@JsonKey() final  RepeatMode repeat;
@override@JsonKey() final  bool npOpen;
@override@JsonKey() final  bool queueOpen;
@override final  String? notice;
@override@JsonKey() final  bool autoplay;
 final  List<double> _eq;
@override@JsonKey() List<double> get eq {
  if (_eq is EqualUnmodifiableListView) return _eq;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_eq);
}

@override@JsonKey() final  bool normOn;
@override@JsonKey() final  int fadeSecs;
@override final  DateTime? sleepAt;
 final  List<int> _shuffleDeck;
@override@JsonKey() List<int> get shuffleDeck {
  if (_shuffleDeck is EqualUnmodifiableListView) return _shuffleDeck;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_shuffleDeck);
}


/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerStateCopyWith<_PlayerState> get copyWith => __$PlayerStateCopyWithImpl<_PlayerState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerState&&const DeepCollectionEquality().equals(other.queue, _queue)&&(identical(other.index, index) || other.index == index)&&const DeepCollectionEquality().equals(other.history, _history)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.buffering, buffering) || other.buffering == buffering)&&(identical(other.currentTime, currentTime) || other.currentTime == currentTime)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.muted, muted) || other.muted == muted)&&(identical(other.shuffle, shuffle) || other.shuffle == shuffle)&&(identical(other.repeat, repeat) || other.repeat == repeat)&&(identical(other.npOpen, npOpen) || other.npOpen == npOpen)&&(identical(other.queueOpen, queueOpen) || other.queueOpen == queueOpen)&&(identical(other.notice, notice) || other.notice == notice)&&(identical(other.autoplay, autoplay) || other.autoplay == autoplay)&&const DeepCollectionEquality().equals(other.eq, _eq)&&(identical(other.normOn, normOn) || other.normOn == normOn)&&(identical(other.fadeSecs, fadeSecs) || other.fadeSecs == fadeSecs)&&(identical(other.sleepAt, sleepAt) || other.sleepAt == sleepAt)&&const DeepCollectionEquality().equals(other.shuffleDeck, _shuffleDeck));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,const DeepCollectionEquality().hash(_queue),index,const DeepCollectionEquality().hash(_history),isPlaying,buffering,currentTime,duration,volume,muted,shuffle,repeat,npOpen,queueOpen,notice,autoplay,const DeepCollectionEquality().hash(_eq),normOn,fadeSecs,sleepAt,const DeepCollectionEquality().hash(_shuffleDeck)]);
}

@override
String toString() {
    return 'PlayerState(queue: $queue, index: $index, history: $history, isPlaying: $isPlaying, buffering: $buffering, currentTime: $currentTime, duration: $duration, volume: $volume, muted: $muted, shuffle: $shuffle, repeat: $repeat, npOpen: $npOpen, queueOpen: $queueOpen, notice: $notice, autoplay: $autoplay, eq: $eq, normOn: $normOn, fadeSecs: $fadeSecs, sleepAt: $sleepAt, shuffleDeck: $shuffleDeck)';
}


}

/// @nodoc
abstract mixin class _$PlayerStateCopyWith<$Res> implements $PlayerStateCopyWith<$Res> {
  factory _$PlayerStateCopyWith(_PlayerState value, $Res Function(_PlayerState) _then) = __$PlayerStateCopyWithImpl;
@override @useResult
$Res call({
 List<Track> queue, int index, List<int> history, bool isPlaying, bool buffering, Duration currentTime, Duration duration, double volume, bool muted, bool shuffle, RepeatMode repeat, bool npOpen, bool queueOpen, String? notice, bool autoplay, List<double> eq, bool normOn, int fadeSecs, DateTime? sleepAt, List<int> shuffleDeck
});




}
/// @nodoc
class __$PlayerStateCopyWithImpl<$Res>
    implements _$PlayerStateCopyWith<$Res> {
  __$PlayerStateCopyWithImpl(this._self, this._then);

  final _PlayerState _self;
  final $Res Function(_PlayerState) _then;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? queue = null,Object? index = null,Object? history = null,Object? isPlaying = null,Object? buffering = null,Object? currentTime = null,Object? duration = null,Object? volume = null,Object? muted = null,Object? shuffle = null,Object? repeat = null,Object? npOpen = null,Object? queueOpen = null,Object? notice = freezed,Object? autoplay = null,Object? eq = null,Object? normOn = null,Object? fadeSecs = null,Object? sleepAt = freezed,Object? shuffleDeck = null,}) {
  return _then(_PlayerState(
queue: null == queue ? _self._queue : queue // ignore: cast_nullable_to_non_nullable
as List<Track>,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<int>,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,buffering: null == buffering ? _self.buffering : buffering // ignore: cast_nullable_to_non_nullable
as bool,currentTime: null == currentTime ? _self.currentTime : currentTime // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,shuffle: null == shuffle ? _self.shuffle : shuffle // ignore: cast_nullable_to_non_nullable
as bool,repeat: null == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as RepeatMode,npOpen: null == npOpen ? _self.npOpen : npOpen // ignore: cast_nullable_to_non_nullable
as bool,queueOpen: null == queueOpen ? _self.queueOpen : queueOpen // ignore: cast_nullable_to_non_nullable
as bool,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as String?,autoplay: null == autoplay ? _self.autoplay : autoplay // ignore: cast_nullable_to_non_nullable
as bool,eq: null == eq ? _self._eq : eq // ignore: cast_nullable_to_non_nullable
as List<double>,normOn: null == normOn ? _self.normOn : normOn // ignore: cast_nullable_to_non_nullable
as bool,fadeSecs: null == fadeSecs ? _self.fadeSecs : fadeSecs // ignore: cast_nullable_to_non_nullable
as int,sleepAt: freezed == sleepAt ? _self.sleepAt : sleepAt // ignore: cast_nullable_to_non_nullable
as DateTime?,shuffleDeck: null == shuffleDeck ? _self._shuffleDeck : shuffleDeck // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}

// dart format on
