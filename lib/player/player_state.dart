import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_state.freezed.dart';

@freezed
abstract class PlayerState with _$PlayerState {
  const factory PlayerState({
    @Default([]) List<Track> queue,
    @Default(-1) int index,
    @Default([]) List<int> history,
    @Default(false) bool isPlaying,
    @Default(false) bool buffering,
    @Default(Duration.zero) Duration currentTime,
    @Default(Duration.zero) Duration duration,
    @Default(0.85) double volume,
    @Default(false) bool muted,
    @Default(false) bool shuffle,
    @Default(RepeatMode.off) RepeatMode repeat,
    @Default(false) bool npOpen,
    @Default(false) bool queueOpen,
    String? notice,
    @Default(true) bool autoplay,
    @Default([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]) List<double> eq,
    @Default(true) bool normOn,
    @Default(4) int fadeSecs,
    DateTime? sleepAt,
    @Default([]) List<int> shuffleDeck,
  }) = _PlayerState;

  const PlayerState._();

  Track? get current =>
      index >= 0 && index < queue.length ? queue[index] : null;
}
