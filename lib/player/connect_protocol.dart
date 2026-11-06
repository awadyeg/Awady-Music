import 'dart:convert';

import 'package:awady_music/data/models/track.dart';
import 'package:flutter/foundation.dart';

/// Communication protocol message between Phone (controller)
/// and TV / Speaker (Awady Connect Receiver).
@immutable
class ConnectMessage {
  const ConnectMessage({
    required this.action,
    this.queue,
    this.index,
    this.positionMs,
    this.durationMs,
    this.isPlaying,
    this.volume,
    this.track,
    this.senderName,
  });

  factory ConnectMessage.syncQueue({
    required List<Track> queue,
    required int index,
    required int positionMs,
    required bool isPlaying,
    String? senderName,
  }) {
    return ConnectMessage(
      action: 'sync_queue',
      queue: queue,
      index: index,
      positionMs: positionMs,
      isPlaying: isPlaying,
      senderName: senderName,
    );
  }

  factory ConnectMessage.play() => const ConnectMessage(action: 'play');
  factory ConnectMessage.pause() => const ConnectMessage(action: 'pause');
  factory ConnectMessage.next() => const ConnectMessage(action: 'next');
  factory ConnectMessage.prev() => const ConnectMessage(action: 'prev');

  factory ConnectMessage.seek(int positionMs) {
    return ConnectMessage(action: 'seek', positionMs: positionMs);
  }

  factory ConnectMessage.volume(double volume) {
    return ConnectMessage(action: 'volume', volume: volume);
  }

  factory ConnectMessage.stateUpdate({
    required bool isPlaying,
    required int positionMs,
    required int durationMs,
    required int index,
    Track? track,
    double? volume,
  }) {
    return ConnectMessage(
      action: 'state_update',
      isPlaying: isPlaying,
      positionMs: positionMs,
      durationMs: durationMs,
      index: index,
      track: track,
      volume: volume,
    );
  }

  factory ConnectMessage.ping() => const ConnectMessage(action: 'ping');
  factory ConnectMessage.pong() => const ConnectMessage(action: 'pong');

  factory ConnectMessage.fromJson(Map<String, dynamic> json) {
    final action = json['action']?.toString() ?? '';
    List<Track>? queue;
    if (json['queue'] is List) {
      queue = (json['queue'] as List)
          .whereType<Map<String, dynamic>>()
          .map(Track.fromJson)
          .toList();
    }
    Track? track;
    if (json['track'] is Map<String, dynamic>) {
      track = Track.fromJson(json['track'] as Map<String, dynamic>);
    }

    return ConnectMessage(
      action: action,
      queue: queue,
      index: json['index'] as int?,
      positionMs: json['positionMs'] as int?,
      durationMs: json['durationMs'] as int?,
      isPlaying: json['isPlaying'] as bool?,
      volume: (json['volume'] as num?)?.toDouble(),
      track: track,
      senderName: json['senderName'] as String?,
    );
  }

  final String action;
  final List<Track>? queue;
  final int? index;
  final int? positionMs;
  final int? durationMs;
  final bool? isPlaying;
  final double? volume;
  final Track? track;
  final String? senderName;

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      if (queue != null) 'queue': queue!.map((t) => t.toJson()).toList(),
      if (index != null) 'index': index,
      if (positionMs != null) 'positionMs': positionMs,
      if (durationMs != null) 'durationMs': durationMs,
      if (isPlaying != null) 'isPlaying': isPlaying,
      if (volume != null) 'volume': volume,
      if (track != null) 'track': track!.toJson(),
      if (senderName != null) 'senderName': senderName,
    };
  }

  String encode() => jsonEncode(toJson());

  static ConnectMessage? tryDecode(dynamic raw) {
    try {
      if (raw is String) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return ConnectMessage.fromJson(decoded);
        }
      } else if (raw is Map<String, dynamic>) {
        return ConnectMessage.fromJson(raw);
      }
    } on Object catch (_) {}
    return null;
  }
}
