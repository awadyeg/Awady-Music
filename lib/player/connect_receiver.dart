import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/player/connect_protocol.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class ConnectReceiverState {
  const ConnectReceiverState({
    this.isRunning = false,
    this.port = 8654,
    this.connectedClients = 0,
    this.activeControllerName,
    this.receiverName = 'Awady TV',
    this.lastSyncTimestamp = 0,
  });

  final bool isRunning;
  final int port;
  final int connectedClients;
  final String? activeControllerName;
  final String receiverName;
  final int lastSyncTimestamp;

  ConnectReceiverState copyWith({
    bool? isRunning,
    int? port,
    int? connectedClients,
    String? Function()? activeControllerName,
    String? receiverName,
    int? lastSyncTimestamp,
  }) {
    return ConnectReceiverState(
      isRunning: isRunning ?? this.isRunning,
      port: port ?? this.port,
      connectedClients: connectedClients ?? this.connectedClients,
      activeControllerName: activeControllerName != null
          ? activeControllerName()
          : this.activeControllerName,
      receiverName: receiverName ?? this.receiverName,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
    );
  }
}

class ConnectReceiverNotifier extends Notifier<ConnectReceiverState> {
  HttpServer? _server;
  RawDatagramSocket? _udpSocket;
  final Set<WebSocket> _clients = {};
  ProviderSubscription<PlayerState>? _playerSub;

  void _cleanup() {
    _playerSub?.close();
    _playerSub = null;
    for (final client in _clients) {
      unawaited(client.close());
    }
    _clients.clear();
    _udpSocket?.close();
    _udpSocket = null;
    if (_server != null) {
      unawaited(_server!.close(force: true));
      _server = null;
    }
  }

  @override
  ConnectReceiverState build() {
    ref.onDispose(_cleanup);

    final settings = ref.watch(settingsProvider);
    final receiverName = settings.tvDeviceName.trim().isNotEmpty
        ? settings.tvDeviceName.trim()
        : 'Awady TV';

    return ConnectReceiverState(receiverName: receiverName);
  }

  Future<void> start({int port = 8654}) async {
    if (state.isRunning) return;

    try {
      try {
        _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
      } on Object catch (_) {
        _server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
      }

      final boundPort = _server?.port ?? port;
      state = state.copyWith(isRunning: true, port: boundPort);
      Log.i('Awady Connect Receiver started on port $boundPort');

      _server?.listen(_handleHttpRequest);
      await _bindUdpResponder(boundPort);
      _listenToPlayerChanges();
    } on Object catch (e) {
      Log.w('Failed to start ConnectReceiver: $e');
    }
  }

  Future<void> _bindUdpResponder(int httpPort) async {
    try {
      _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8655);
      _udpSocket?.broadcastEnabled = true;
      _udpSocket?.listen((event) {
        if (event == RawSocketEvent.read) {
          final dg = _udpSocket?.receive();
          if (dg != null) {
            final text = utf8.decode(dg.data, allowMalformed: true);
            if (text.contains('AWADY_DISCOVER')) {
              final offer = jsonEncode({
                'id': 'awady_tv_$httpPort',
                'name': state.receiverName,
                'port': httpPort,
                'model': 'Awady TV Receiver',
              });
              final payload = utf8.encode('AWADY_OFFER:$offer');
              _udpSocket?.send(payload, dg.address, dg.port);
            }
          }
        }
      });
    } on Object catch (e) {
      Log.w('UDP discovery responder bind error: $e');
    }
  }

  void _handleHttpRequest(HttpRequest request) {
    if (request.uri.path == '/connect' &&
        WebSocketTransformer.isUpgradeRequest(request)) {
      unawaited(
        WebSocketTransformer.upgrade(request).then(_handleWebSocketClient),
      );
    } else if (request.uri.path == '/info') {
      request.response
        ..headers.contentType = ContentType.json
        ..write(
          jsonEncode({
            'name': state.receiverName,
            'model': 'Awady TV Receiver',
            'version': '1.0.2',
            'port': state.port,
          }),
        );
      unawaited(request.response.close());
    } else {
      request.response.statusCode = HttpStatus.notFound;
      unawaited(request.response.close());
    }
  }

  void _handleWebSocketClient(WebSocket socket) {
    _clients.add(socket);
    state = state.copyWith(connectedClients: _clients.length);

    // Send initial player state immediately upon connection
    _sendStateUpdateTo(socket);

    socket.listen(
      (data) {
        final msg = ConnectMessage.tryDecode(data);
        if (msg == null) return;
        _handleClientMessage(msg, socket);
      },
      onDone: () {
        _clients.remove(socket);
        state = state.copyWith(
          connectedClients: _clients.length,
          activeControllerName: _clients.isEmpty ? () => null : null,
        );
      },
      onError: (_) {
        _clients.remove(socket);
        state = state.copyWith(connectedClients: _clients.length);
      },
    );
  }

  void _handleClientMessage(ConnectMessage msg, WebSocket socket) {
    final player = ref.read(playerControllerProvider.notifier);

    switch (msg.action) {
      case 'sync_queue':
        if (msg.queue != null && msg.queue!.isNotEmpty) {
          state = state.copyWith(
            activeControllerName: () => msg.senderName ?? 'Phone',
            lastSyncTimestamp: DateTime.now().millisecondsSinceEpoch,
          );
          try {
            unawaited(
              const MethodChannel('com.awady.awady_music/tv')
                  .invokeMethod<void>('bringToFront'),
            );
          } on Object catch (_) {}
          final index = msg.index ?? 0;
          player.playContext(msg.queue!, index);
          if (msg.positionMs != null && msg.positionMs! > 0) {
            player.seek(Duration(milliseconds: msg.positionMs!));
          }
          if (msg.isPlaying == false) {
            unawaited(player.toggle());
          }
        }
      case 'play':
        if (!ref.read(playerControllerProvider).isPlaying) {
          unawaited(player.toggle());
        }
      case 'pause':
        if (ref.read(playerControllerProvider).isPlaying) {
          unawaited(player.toggle());
        }
      case 'next':
        player.next();
      case 'prev':
        player.prev();
      case 'seek':
        if (msg.positionMs != null) {
          player.seek(Duration(milliseconds: msg.positionMs!));
        }
      case 'volume':
        if (msg.volume != null) {
          player.setVolume(msg.volume!);
        }
      case 'ping':
        socket.add(ConnectMessage.pong().encode());
    }
  }

  void _listenToPlayerChanges() {
    _playerSub?.close();
    _playerSub = ref.listen<PlayerState>(playerControllerProvider, (
      prev,
      next,
    ) {
      _broadcastState();
    });
  }

  void _broadcastState() {
    if (_clients.isEmpty) return;
    final ps = ref.read(playerControllerProvider);
    final msg = ConnectMessage.stateUpdate(
      isPlaying: ps.isPlaying,
      positionMs: ps.currentTime.inMilliseconds,
      durationMs: ps.duration.inMilliseconds,
      index: ps.index,
      track: ps.current,
      volume: ps.volume,
    ).encode();

    for (final socket in _clients) {
      try {
        socket.add(msg);
      } on Object catch (_) {}
    }
  }

  void _sendStateUpdateTo(WebSocket socket) {
    try {
      final ps = ref.read(playerControllerProvider);
      final msg = ConnectMessage.stateUpdate(
        isPlaying: ps.isPlaying,
        positionMs: ps.currentTime.inMilliseconds,
        durationMs: ps.duration.inMilliseconds,
        index: ps.index,
        track: ps.current,
        volume: ps.volume,
      ).encode();
      socket.add(msg);
    } on Object catch (_) {}
  }

  void stop() {
    _cleanup();
    state = state.copyWith(
      isRunning: false,
      connectedClients: 0,
      activeControllerName: () => null,
    );
  }
}

final connectReceiverProvider =
    NotifierProvider<ConnectReceiverNotifier, ConnectReceiverState>(
      ConnectReceiverNotifier.new,
    );
