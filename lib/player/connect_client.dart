import 'dart:async';
import 'dart:io';

import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/player/cast_service.dart';
import 'package:awady_music/player/connect_protocol.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class ConnectClientState {
  const ConnectClientState({
    this.isConnected = false,
    this.isConnecting = false,
    this.targetDeviceName,
    this.targetHost,
    this.targetPort,
    this.remoteTrack,
    this.remotePosition = Duration.zero,
    this.remoteDuration = Duration.zero,
    this.remoteIsPlaying = false,
    this.remoteVolume = 1.0,
    this.remoteIndex = 0,
    this.errorMessage,
  });

  final bool isConnected;
  final bool isConnecting;
  final String? targetDeviceName;
  final String? targetHost;
  final int? targetPort;
  final Track? remoteTrack;
  final Duration remotePosition;
  final Duration remoteDuration;
  final bool remoteIsPlaying;
  final double remoteVolume;
  final int remoteIndex;
  final String? errorMessage;

  ConnectClientState copyWith({
    bool? isConnected,
    bool? isConnecting,
    String? Function()? targetDeviceName,
    String? Function()? targetHost,
    int? Function()? targetPort,
    Track? Function()? remoteTrack,
    Duration? remotePosition,
    Duration? remoteDuration,
    bool? remoteIsPlaying,
    double? remoteVolume,
    int? remoteIndex,
    String? Function()? errorMessage,
  }) {
    return ConnectClientState(
      isConnected: isConnected ?? this.isConnected,
      isConnecting: isConnecting ?? this.isConnecting,
      targetDeviceName: targetDeviceName != null
          ? targetDeviceName()
          : this.targetDeviceName,
      targetHost: targetHost != null ? targetHost() : this.targetHost,
      targetPort: targetPort != null ? targetPort() : this.targetPort,
      remoteTrack: remoteTrack != null ? remoteTrack() : this.remoteTrack,
      remotePosition: remotePosition ?? this.remotePosition,
      remoteDuration: remoteDuration ?? this.remoteDuration,
      remoteIsPlaying: remoteIsPlaying ?? this.remoteIsPlaying,
      remoteVolume: remoteVolume ?? this.remoteVolume,
      remoteIndex: remoteIndex ?? this.remoteIndex,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

class ConnectClientNotifier extends Notifier<ConnectClientState> {
  WebSocket? _socket;
  Timer? _pingTimer;

  void _cleanup() {
    _pingTimer?.cancel();
    _pingTimer = null;
    if (_socket != null) {
      unawaited(_socket!.close());
      _socket = null;
    }
  }

  @override
  ConnectClientState build() {
    ref.onDispose(_cleanup);
    return const ConnectClientState();
  }

  Future<bool> connectTo(CastDevice device) async {
    _cleanup();
    state = state.copyWith(
      isConnecting: true,
      targetDeviceName: () => device.name,
      targetHost: () => device.host,
      targetPort: () => device.port,
      errorMessage: () => null,
    );

    try {
      final wsUri = Uri.parse('ws://${device.host}:${device.port}/connect');
      final socket = await WebSocket.connect(wsUri.toString())
          .timeout(const Duration(seconds: 4));

      _socket = socket;
      state = state.copyWith(isConnected: true, isConnecting: false);

      // Listen to TV receiver state updates
      socket.listen(
        _handleIncomingMessage,
        onDone: disconnect,
        onError: (Object err) {
          Log.w('Awady Connect socket error: $err');
          disconnect();
        },
      );

      // Keepalive ping every 10s
      _pingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        send(ConnectMessage.ping());
      });

      // Pause local playback so audio streams from TV
      final player = ref.read(playerControllerProvider.notifier);
      final ps = ref.read(playerControllerProvider);
      if (ps.isPlaying) {
        await player.toggle();
      }

      // Sync current queue to the TV
      final settings = ref.read(settingsProvider);
      final senderName = settings.userName.trim().isNotEmpty
          ? settings.userName.trim()
          : 'Awady Phone';

      if (ps.queue.isNotEmpty) {
        send(
          ConnectMessage.syncQueue(
            queue: ps.queue,
            index: ps.index,
            positionMs: ps.currentTime.inMilliseconds,
            isPlaying: true,
            senderName: senderName,
          ),
        );
      }

      return true;
    } on Object catch (e) {
      Log.w('Failed to connect to Awady Connect receiver: $e');
      state = state.copyWith(
        isConnected: false,
        isConnecting: false,
        errorMessage: e.toString,
      );
      return false;
    }
  }

  void _handleIncomingMessage(dynamic raw) {
    final msg = ConnectMessage.tryDecode(raw);
    if (msg == null) return;

    if (msg.action == 'state_update') {
      state = state.copyWith(
        remoteIsPlaying: msg.isPlaying ?? state.remoteIsPlaying,
        remotePosition: msg.positionMs != null
            ? Duration(milliseconds: msg.positionMs!)
            : state.remotePosition,
        remoteDuration: msg.durationMs != null
            ? Duration(milliseconds: msg.durationMs!)
            : state.remoteDuration,
        remoteIndex: msg.index ?? state.remoteIndex,
        remoteTrack: msg.track != null ? () => msg.track : null,
        remoteVolume: msg.volume ?? state.remoteVolume,
      );
    }
  }

  void send(ConnectMessage msg) {
    if (_socket != null && state.isConnected) {
      try {
        _socket!.add(msg.encode());
      } on Object catch (e) {
        Log.w('Error sending connect message: $e');
      }
    }
  }

  void play() => send(ConnectMessage.play());
  void pause() => send(ConnectMessage.pause());
  void toggle() {
    if (state.remoteIsPlaying) {
      pause();
    } else {
      play();
    }
  }

  void next() => send(ConnectMessage.next());
  void prev() => send(ConnectMessage.prev());

  void seek(Duration pos) {
    send(ConnectMessage.seek(pos.inMilliseconds));
  }

  void setVolume(double volume) {
    send(ConnectMessage.volume(volume.clamp(0.0, 1.0)));
  }

  void disconnect() {
    _cleanup();
    state = state.copyWith(
      isConnected: false,
      isConnecting: false,
      targetDeviceName: () => null,
      targetHost: () => null,
      targetPort: () => null,
      remoteTrack: () => null,
      remoteIsPlaying: false,
    );
  }
}

final connectClientProvider =
    NotifierProvider<ConnectClientNotifier, ConnectClientState>(
      ConnectClientNotifier.new,
    );
