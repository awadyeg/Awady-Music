import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/downloads_repository.dart';
import 'package:awady_music/data/sources/ytstream/stream_resolver_impl.dart';
import 'package:awady_music/data/sources/ytstream/stream_resolver_provider.dart';
import 'package:awady_music/player/cast_service.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Protobuf-encoded Cast V2 message packet.
class CastMessage {
  const CastMessage({
    required this.sourceId,
    required this.destinationId,
    required this.namespace,
    required this.payloadUtf8,
  });

  final String sourceId;
  final String destinationId;
  final String namespace;
  final String payloadUtf8;

  /// Encodes this CastMessage to protobuf bytes with 4-byte big-endian framing.
  Uint8List toFramedBytes() {
    final bb = BytesBuilder()
      // Field 1: protocol_version = 0 (varint)
      ..add([0x08, 0x00]);

    // Field 2: source_id (string, tag 0x12)
    final srcBytes = utf8.encode(sourceId);
    bb.addByte(0x12);
    _writeVarint(bb, srcBytes.length);
    bb.add(srcBytes);

    // Field 3: destination_id (string, tag 0x1a)
    final dstBytes = utf8.encode(destinationId);
    bb.addByte(0x1a);
    _writeVarint(bb, dstBytes.length);
    bb.add(dstBytes);

    // Field 4: namespace (string, tag 0x22)
    final nsBytes = utf8.encode(namespace);
    bb.addByte(0x22);
    _writeVarint(bb, nsBytes.length);
    bb
      ..add(nsBytes)
      // Field 5: payload_type = 0 (STRING, tag 0x28)
      ..add([0x28, 0x00]);

    // Field 6: payload_utf8 (string, tag 0x32)
    final payloadBytes = utf8.encode(payloadUtf8);
    bb.addByte(0x32);
    _writeVarint(bb, payloadBytes.length);
    bb.add(payloadBytes);

    final msgBytes = bb.toBytes();
    final frame = Uint8List(4 + msgBytes.length);
    ByteData.view(frame.buffer).setUint32(0, msgBytes.length);
    frame.setRange(4, frame.length, msgBytes);
    return frame;
  }

  /// Parses a protobuf [CastMessage] payload (excluding the 4-byte framing).
  static CastMessage? tryParse(Uint8List payload) {
    try {
      var offset = 0;
      var sourceId = '';
      var destinationId = '';
      var namespace = '';
      var payloadUtf8 = '';

      while (offset < payload.length) {
        final tagAndType = _readVarint(payload, offset);
        offset = tagAndType.newOffset;
        final tag = tagAndType.value >> 3;
        final wireType = tagAndType.value & 0x07;

        if (wireType == 0) {
          // Varint
          final res = _readVarint(payload, offset);
          offset = res.newOffset;
        } else if (wireType == 2) {
          // Length-delimited
          final lenRes = _readVarint(payload, offset);
          offset = lenRes.newOffset;
          final len = lenRes.value;
          final strBytes = payload.sublist(offset, offset + len);
          offset += len;

          switch (tag) {
            case 2:
              sourceId = utf8.decode(strBytes, allowMalformed: true);
            case 3:
              destinationId = utf8.decode(strBytes, allowMalformed: true);
            case 4:
              namespace = utf8.decode(strBytes, allowMalformed: true);
            case 6:
              payloadUtf8 = utf8.decode(strBytes, allowMalformed: true);
          }
        } else {
          // Unsupported wire type
          break;
        }
      }

      if (sourceId.isEmpty || destinationId.isEmpty || namespace.isEmpty) {
        return null;
      }

      return CastMessage(
        sourceId: sourceId,
        destinationId: destinationId,
        namespace: namespace,
        payloadUtf8: payloadUtf8,
      );
    } on Object catch (_) {
      return null;
    }
  }

  static void _writeVarint(BytesBuilder bb, int value) {
    var v = value;
    while (v > 0x7f) {
      bb.addByte((v & 0x7f) | 0x80);
      v >>= 7;
    }
    bb.addByte(v & 0x7f);
  }

  static ({int value, int newOffset}) _readVarint(Uint8List bytes, int offset) {
    var result = 0;
    var shift = 0;
    var cur = offset;
    while (cur < bytes.length) {
      final b = bytes[cur++];
      result |= (b & 0x7f) << shift;
      if ((b & 0x80) == 0) break;
      shift += 7;
    }
    return (value: result, newOffset: cur);
  }
}

/// Local HTTP audio server streaming offline audio files and resolving streams
/// for Smart TV / Google Cast receivers on the local LAN.
class LocalAudioProxyServer {
  LocalAudioProxyServer({
    required this.downloadsRepository,
    required this.streamResolver,
  });

  final DownloadsRepository downloadsRepository;
  final StreamResolver streamResolver;

  HttpServer? _server;
  int? get port => _server?.port;

  Future<void> start() async {
    if (_server != null) return;
    _server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    _server!.listen(_handleRequest);
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  static Future<String?> getLocalIp([String? targetHost]) async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );
      String? targetPrefix;
      if (targetHost != null) {
        final lastDot = targetHost.lastIndexOf('.');
        if (lastDot > 0) {
          targetPrefix = targetHost.substring(0, lastDot + 1);
        }
      }
      // 1. Prefer an interface on the exact same /24 subnet as the target TV
      if (targetPrefix != null) {
        for (final iface in interfaces) {
          for (final addr in iface.addresses) {
            if (!addr.isLoopback && addr.address.startsWith(targetPrefix)) {
              return addr.address;
            }
          }
        }
      }
      // 2. Prefer 192.168.x.x Wi-Fi LAN addresses
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback && addr.address.startsWith('192.168.')) {
            return addr.address;
          }
        }
      }
      // 3. Fallback to any private IPv4 address
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback &&
              (addr.address.startsWith('10.') ||
                  addr.address.startsWith('172.'))) {
            return addr.address;
          }
        }
      }
      if (interfaces.isNotEmpty && interfaces.first.addresses.isNotEmpty) {
        return interfaces.first.addresses.first.address;
      }
    } on Object catch (_) {}
    return null;
  }

  Future<void> _handleRequest(HttpRequest request) async {
    try {
      request.response.headers
        ..set('Access-Control-Allow-Origin', '*')
        ..set('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS')
        ..set('Access-Control-Allow-Headers', 'Range, Content-Type');

      if (request.method == 'OPTIONS') {
        request.response.statusCode = HttpStatus.noContent;
        await request.response.close();
        return;
      }

      final path = request.uri.path;
      if (!path.startsWith('/stream/')) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }

      final rawId = path.substring('/stream/'.length);
      final trackId = rawId.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
      final localPath = await downloadsRepository.getDownloadedFilePath(
        trackId,
      );

      final rangeHeader = request.headers.value(HttpHeaders.rangeHeader);

      if (localPath != null && File(localPath).existsSync()) {
        final file = File(localPath);
        final fileLength = await file.length();

        request.response.headers.set(
          HttpHeaders.contentTypeHeader,
          'audio/mp4',
        );
        request.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');

        if (request.method == 'HEAD') {
          request.response.headers.set(
            HttpHeaders.contentLengthHeader,
            fileLength,
          );
          await request.response.close();
          return;
        }

        if (rangeHeader != null && rangeHeader.startsWith('bytes=')) {
          final match = RegExp(r'bytes=(\d+)-(\d*)').firstMatch(rangeHeader);
          if (match != null) {
            final start = int.parse(match.group(1)!);
            final end = match.group(2)?.isNotEmpty == true
                ? int.parse(match.group(2)!)
                : fileLength - 1;
            final chunkSize = (end - start) + 1;

            request.response.statusCode = HttpStatus.partialContent;
            request.response.headers.set(
              HttpHeaders.contentRangeHeader,
              'bytes $start-$end/$fileLength',
            );
            request.response.headers.set(
              HttpHeaders.contentLengthHeader,
              chunkSize,
            );
            await file.openRead(start, end + 1).pipe(request.response);
            return;
          }
        }

        request.response.headers.set(
          HttpHeaders.contentLengthHeader,
          fileLength,
        );
        await file.openRead().pipe(request.response);
        return;
      }

      // Online stream proxy
      const visionOsUa =
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
          'AppleWebKit/605.1.15 (KHTML, like Gecko) '
          'Version/17.4 Safari/605.1.15';
      final cleanVid = trackId.replaceFirst(
        RegExp('^(?:yt-|ytpl-|ytalb-)'),
        '',
      );
      final streamInfo = await streamResolver.resolve(cleanVid);
      final isVisionOs = streamInfo.url.queryParameters['c'] == 'VISIONOS';
      final client = HttpClient();
      if (isVisionOs) {
        client.userAgent = visionOsUa;
      }
      final upstreamReq = await client.openUrl(request.method, streamInfo.url);
      if (isVisionOs) {
        upstreamReq.headers.set(HttpHeaders.userAgentHeader, visionOsUa);
      }
      if (rangeHeader != null) {
        upstreamReq.headers.set(HttpHeaders.rangeHeader, rangeHeader);
      }
      final upstreamRes = await upstreamReq.close();

      request.response.statusCode = upstreamRes.statusCode;
      upstreamRes.headers.forEach((name, values) {
        final lower = name.toLowerCase();
        if (lower != 'transfer-encoding' &&
            lower != 'access-control-allow-origin') {
          for (final v in values) {
            request.response.headers.add(name, v);
          }
        }
      });
      await upstreamRes.pipe(request.response);
    } on Object catch (e) {
      Log.w('LocalAudioProxyServer error: $e');
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        await request.response.close();
      } on Object catch (_) {}
    }
  }
}

/// Connection and playback state for Google Cast / Smart TV receivers.
@immutable
class ChromecastClientState {
  const ChromecastClientState({
    this.isConnected = false,
    this.isConnecting = false,
    this.connectedDevice,
    this.currentTrack,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.errorMessage,
  });

  final bool isConnected;
  final bool isConnecting;
  final CastDevice? connectedDevice;
  final Track? currentTrack;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double volume;
  final String? errorMessage;

  ChromecastClientState copyWith({
    bool? isConnected,
    bool? isConnecting,
    CastDevice? Function()? connectedDevice,
    Track? Function()? currentTrack,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? volume,
    String? Function()? errorMessage,
  }) {
    return ChromecastClientState(
      isConnected: isConnected ?? this.isConnected,
      isConnecting: isConnecting ?? this.isConnecting,
      connectedDevice: connectedDevice != null
          ? connectedDevice()
          : this.connectedDevice,
      currentTrack: currentTrack != null ? currentTrack() : this.currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

/// Manages Google Cast V2 TLS socket connection on port 8009 and Default Media
/// Receiver (CC1AD845) session.
class ChromecastClientNotifier extends Notifier<ChromecastClientState> {
  SecureSocket? _socket;
  LocalAudioProxyServer? _proxyServer;
  Timer? _heartbeatTimer;
  int _requestId = 0;
  String? _transportId;
  int? _mediaSessionId;
  final List<int> _incomingBuffer = [];

  void _cleanup() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _socket?.destroy();
    _socket = null;
    _transportId = null;
    _mediaSessionId = null;
    _incomingBuffer.clear();
  }

  @override
  ChromecastClientState build() {
    ref.onDispose(() {
      _cleanup();
      unawaited(_proxyServer?.stop());
    });
    return const ChromecastClientState();
  }

  Future<void> connectTo(CastDevice device) async {
    _cleanup();
    state = state.copyWith(
      isConnecting: true,
      connectedDevice: () => device,
      errorMessage: () => null,
    );

    try {
      if (_proxyServer == null) {
        _proxyServer = LocalAudioProxyServer(
          downloadsRepository: ref.read(downloadsRepositoryProvider),
          streamResolver: ref.read(streamResolverProvider),
        );
        await _proxyServer!.start();
      }

      // Cast V2 TLS control port is 8009
      final port = device.port == 8008 ? 8009 : device.port;
      final socket = await SecureSocket.connect(
        device.host,
        port,
        onBadCertificate: (cert) => true,
        timeout: const Duration(seconds: 5),
      );

      _socket = socket;
      socket.listen(
        _onData,
        onDone: disconnect,
        onError: (Object err) {
          Log.w('Chromecast socket error: $err');
          disconnect();
        },
      );

      // Step 1: Connect to receiver-0
      _send(
        sourceId: 'sender-0',
        destinationId: 'receiver-0',
        namespace: 'urn:x-cast:com.google.cast.tp.connection',
        payload: {'type': 'CONNECT'},
      );

      // Step 2: Launch Default Media Receiver CC1AD845
      _send(
        sourceId: 'sender-0',
        destinationId: 'receiver-0',
        namespace: 'urn:x-cast:com.google.cast.receiver',
        payload: {
          'type': 'LAUNCH',
          'appId': 'CC1AD845',
          'requestId': ++_requestId,
        },
      );

      // Step 3: Start periodic ping and media status poll
      _heartbeatTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        _send(
          sourceId: 'sender-0',
          destinationId: 'receiver-0',
          namespace: 'urn:x-cast:com.google.cast.tp.heartbeat',
          payload: {'type': 'PING'},
        );
        if (_transportId != null && state.isPlaying) {
          _send(
            sourceId: 'sender-0',
            destinationId: _transportId!,
            namespace: 'urn:x-cast:com.google.cast.media',
            payload: {'type': 'GET_STATUS', 'requestId': ++_requestId},
          );
        }
      });

      state = state.copyWith(isConnected: true, isConnecting: false);

      // Pause local playback
      final player = ref.read(playerControllerProvider.notifier);
      await player.pauseLocalForCast();

      final ps = ref.read(playerControllerProvider);
      // If a track is currently loaded, load it on the TV
      if (ps.current != null) {
        unawaited(loadTrack(ps.current!, ps.currentTime));
      }
    } on Object catch (e) {
      Log.w('Failed to connect to Chromecast: $e');
      state = state.copyWith(
        isConnected: false,
        isConnecting: false,
        errorMessage: e.toString,
      );
    }
  }

  void _onData(Uint8List data) {
    _incomingBuffer.addAll(data);
    while (_incomingBuffer.length >= 4) {
      final view = ByteData.view(
        Uint8List.fromList(_incomingBuffer.sublist(0, 4)).buffer,
      );
      final msgLength = view.getUint32(0);
      if (_incomingBuffer.length < 4 + msgLength) break;

      final msgPayload = Uint8List.fromList(
        _incomingBuffer.sublist(4, 4 + msgLength),
      );
      _incomingBuffer.removeRange(0, 4 + msgLength);

      final msg = CastMessage.tryParse(msgPayload);
      if (msg != null) {
        _handleCastMessage(msg);
      }
    }
  }

  void _handleCastMessage(CastMessage msg) {
    try {
      final json = jsonDecode(msg.payloadUtf8);
      if (json is! Map<String, dynamic>) return;
      final type = json['type'] as String?;

      if (type == 'PING') {
        _send(
          sourceId: msg.destinationId,
          destinationId: msg.sourceId,
          namespace: 'urn:x-cast:com.google.cast.tp.heartbeat',
          payload: {'type': 'PONG'},
        );
        return;
      }

      if (type == 'RECEIVER_STATUS') {
        final status = json['status'] as Map<String, dynamic>?;
        final apps = status?['applications'] as List<dynamic>?;
        if (apps != null) {
          for (final a in apps) {
            if (a is Map<String, dynamic> && a['appId'] == 'CC1AD845') {
              final transportId = a['transportId'] as String?;
              if (transportId != null && transportId != _transportId) {
                _transportId = transportId;
                // Connect to the transportId of the Default Media Receiver
                _send(
                  sourceId: 'sender-0',
                  destinationId: transportId,
                  namespace: 'urn:x-cast:com.google.cast.tp.connection',
                  payload: {'type': 'CONNECT'},
                );
                if (state.currentTrack != null) {
                  unawaited(
                    _sendLoadToTransport(
                      transportId,
                      state.currentTrack!,
                      state.position,
                    ),
                  );
                }
              }
            }
          }
        }
      } else if (type == 'MEDIA_STATUS') {
        final statusList = json['status'] as List<dynamic>?;
        if (statusList != null && statusList.isNotEmpty) {
          final mediaStatus = statusList.first as Map<String, dynamic>;
          _mediaSessionId =
              mediaStatus['mediaSessionId'] as int? ?? _mediaSessionId;

          final playerState = mediaStatus['playerState'] as String?;
          final idleReason = mediaStatus['idleReason'] as String?;
          final currentSecs =
              (mediaStatus['currentTime'] as num?)?.toDouble() ?? 0.0;

          state = state.copyWith(
            isPlaying: playerState == 'PLAYING',
            position: Duration(milliseconds: (currentSecs * 1000).toInt()),
          );

          ref
              .read(playerControllerProvider.notifier)
              .syncRemotePlaybackState(
                isPlaying: playerState == 'PLAYING',
                position: Duration(milliseconds: (currentSecs * 1000).toInt()),
              );

          if (playerState == 'IDLE' && idleReason == 'FINISHED') {
            // Auto-advance to next track
            ref.read(playerControllerProvider.notifier).next();
          }
        }
      }
    } on Object catch (e) {
      Log.w('Error handling Cast message: $e');
    }
  }

  Future<void> loadTrack(
    Track track, [
    Duration startPos = Duration.zero,
  ]) async {
    state = state.copyWith(
      currentTrack: () => track,
      duration: Duration(seconds: track.duration),
      position: startPos,
      isPlaying: true,
    );

    final transportId = _transportId;
    if (transportId == null) {
      // Receiver app is still launching; RECEIVER_STATUS will trigger
      // _sendLoadToTransport once transportId is ready.
      _send(
        sourceId: 'sender-0',
        destinationId: 'receiver-0',
        namespace: 'urn:x-cast:com.google.cast.receiver',
        payload: {
          'type': 'LAUNCH',
          'appId': 'CC1AD845',
          'requestId': ++_requestId,
        },
      );
      return;
    }

    await _sendLoadToTransport(transportId, track, startPos);
  }

  Future<void> _sendLoadToTransport(
    String transportId,
    Track track,
    Duration startPos,
  ) async {
    final localIp =
        await LocalAudioProxyServer.getLocalIp(state.connectedDevice?.host) ??
        '127.0.0.1';
    final port = _proxyServer?.port ?? 8000;
    final streamUrl = 'http://$localIp:$port/stream/${track.id}.m4a';
    final artworkUrl =
        track.artwork?.s1000 ?? track.artwork?.s480 ?? track.artwork?.fallback;

    _send(
      sourceId: 'sender-0',
      destinationId: transportId,
      namespace: 'urn:x-cast:com.google.cast.media',
      payload: {
        'type': 'LOAD',
        'requestId': ++_requestId,
        'media': {
          'contentId': streamUrl,
          'contentType': 'audio/mp4',
          'streamType': 'BUFFERED',
          'metadata': {
            'type': 3,
            'metadataType': 3,
            'title': track.title,
            'subtitle': '${track.artist.name} • Awady Music',
            'artist': '${track.artist.name} • Awady Music',
            'albumName': (track.album?.name.isNotEmpty ?? false)
                ? '${track.album!.name} • Awady Music'
                : 'Awady Music',
            'studio': 'Awady Music',
            if (artworkUrl != null)
              'images': [
                {'url': artworkUrl},
              ],
          },
        },
        'autoplay': true,
        'currentTime': startPos.inMilliseconds / 1000.0,
      },
    );
  }

  void play() {
    if (_mediaSessionId == null) return;
    final target = _transportId ?? 'receiver-0';
    _send(
      sourceId: 'sender-0',
      destinationId: target,
      namespace: 'urn:x-cast:com.google.cast.media',
      payload: {
        'type': 'PLAY',
        'requestId': ++_requestId,
        'mediaSessionId': _mediaSessionId,
      },
    );
    state = state.copyWith(isPlaying: true);
  }

  void pause() {
    if (_mediaSessionId == null) return;
    final target = _transportId ?? 'receiver-0';
    _send(
      sourceId: 'sender-0',
      destinationId: target,
      namespace: 'urn:x-cast:com.google.cast.media',
      payload: {
        'type': 'PAUSE',
        'requestId': ++_requestId,
        'mediaSessionId': _mediaSessionId,
      },
    );
    state = state.copyWith(isPlaying: false);
  }

  void seek(Duration position) {
    if (_mediaSessionId == null) return;
    final target = _transportId ?? 'receiver-0';
    _send(
      sourceId: 'sender-0',
      destinationId: target,
      namespace: 'urn:x-cast:com.google.cast.media',
      payload: {
        'type': 'SEEK',
        'requestId': ++_requestId,
        'mediaSessionId': _mediaSessionId,
        'currentTime': position.inMilliseconds / 1000.0,
      },
    );
    state = state.copyWith(position: position);
  }

  void setVolume(double level) {
    final target = _transportId ?? 'receiver-0';
    _send(
      sourceId: 'sender-0',
      destinationId: target,
      namespace: 'urn:x-cast:com.google.cast.receiver',
      payload: {
        'type': 'SET_VOLUME',
        'requestId': ++_requestId,
        'volume': {'level': level.clamp(0.0, 1.0)},
      },
    );
    state = state.copyWith(volume: level);
  }

  void disconnect() {
    if (_transportId != null && _mediaSessionId != null) {
      _send(
        sourceId: 'sender-0',
        destinationId: _transportId!,
        namespace: 'urn:x-cast:com.google.cast.media',
        payload: {
          'type': 'STOP',
          'requestId': ++_requestId,
          'mediaSessionId': _mediaSessionId,
        },
      );
    }
    _cleanup();
    state = state.copyWith(
      isConnected: false,
      isConnecting: false,
      connectedDevice: () => null,
      currentTrack: () => null,
      isPlaying: false,
    );
  }

  void _send({
    required String sourceId,
    required String destinationId,
    required String namespace,
    required Map<String, dynamic> payload,
  }) {
    if (_socket == null) return;
    try {
      final msg = CastMessage(
        sourceId: sourceId,
        destinationId: destinationId,
        namespace: namespace,
        payloadUtf8: jsonEncode(payload),
      );
      _socket?.add(msg.toFramedBytes());
    } on Object catch (e) {
      Log.w('Failed to send CastMessage: $e');
    }
  }
}

final chromecastClientProvider =
    NotifierProvider<ChromecastClientNotifier, ChromecastClientState>(
      ChromecastClientNotifier.new,
    );
