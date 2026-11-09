import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:awady_music/core/util/log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a discovered Cast / Smart TV receiver device.
@immutable
class CastDevice {
  const CastDevice({
    required this.id,
    required this.name,
    required this.host,
    this.port = 8008,
    this.model = 'Google Cast / Smart TV',
  });

  final String id;
  final String name;
  final String host;
  final int port;
  final String model;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CastDevice && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// State of the Cast subsystem.
class CastState {
  const CastState({
    this.isScanning = false,
    this.devices = const [],
    this.connectedDevice,
  });

  final bool isScanning;
  final List<CastDevice> devices;
  final CastDevice? connectedDevice;

  bool get isCasting => connectedDevice != null;

  CastState copyWith({
    bool? isScanning,
    List<CastDevice>? devices,
    CastDevice? Function()? connectedDevice,
  }) {
    return CastState(
      isScanning: isScanning ?? this.isScanning,
      devices: devices ?? this.devices,
      connectedDevice: connectedDevice != null
          ? connectedDevice()
          : this.connectedDevice,
    );
  }
}

/// Manages discovery and connection state for Cast / Chromecast devices.
class CastNotifier extends Notifier<CastState> {
  static const _channel = MethodChannel('com.awady.awady_music/cast');

  RawDatagramSocket? _socket;
  Timer? _scanTimer;

  void _cleanup() {
    _scanTimer?.cancel();
    _scanTimer = null;
    _socket?.close();
    _socket = null;
  }

  @override
  CastState build() {
    ref.onDispose(_cleanup);
    return const CastState();
  }

  /// Begins SSDP multicast discovery on the local Wi-Fi network.
  Future<void> startDiscovery() async {
    if (state.isScanning) return;
    state = state.copyWith(isScanning: true, devices: const []);

    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _socket
        ?..broadcastEnabled = true
        ..multicastLoopback = false
        ..listen((event) {
          if (event == RawSocketEvent.read) {
            final datagram = _socket?.receive();
            if (datagram != null) {
              _handleResponse(datagram);
            }
          }
        });

      final multicast = InternetAddress('239.255.255.250');
      final mSearchDial = utf8.encode(
        'M-SEARCH * HTTP/1.1\r\n'
        'HOST: 239.255.255.250:1900\r\n'
        'MAN: "ssdp:discover"\r\n'
        'MX: 3\r\n'
        'ST: urn:dial-multiscreen-org:service:dial:1\r\n\r\n',
      );
      _socket?.send(mSearchDial, multicast, 1900);

      final mSearchCast = utf8.encode(
        'M-SEARCH * HTTP/1.1\r\n'
        'HOST: 239.255.255.250:1900\r\n'
        'MAN: "ssdp:discover"\r\n'
        'MX: 3\r\n'
        'ST: urn:aca-org:service:cast:1\r\n\r\n',
      );
      _socket?.send(mSearchCast, multicast, 1900);

      // Awady Connect LAN discovery broadcast
      final awadyPing = utf8.encode('AWADY_DISCOVER');
      _socket?.send(awadyPing, InternetAddress('255.255.255.255'), 8655);
    } on Object catch (e) {
      Log.w('SSDP discovery bind error: $e');
    }

    _scanTimer?.cancel();
    _scanTimer = Timer(const Duration(seconds: 4), stopDiscovery);
  }

  void _addOrUpdateDevice(CastDevice device) {
    final list = [...state.devices];
    final idx = list.indexWhere((d) => d.host == device.host);
    if (idx >= 0) {
      if (list[idx].model != 'Awady Music' || device.model == 'Awady Music') {
        list[idx] = device;
      }
    } else {
      list.add(device);
    }
    state = state.copyWith(devices: list);
  }

  Future<void> _verifyAndAddDevice(
    String host,
    Uri? locationUri,
    int defaultPort,
  ) async {
    // 1. Try Awady Music TV on port 8654 first
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(milliseconds: 1500);
      final req = await client.getUrl(Uri.parse('http://$host:8654/info'));
      final res = await req.close().timeout(const Duration(milliseconds: 1500));
      if (res.statusCode == 200) {
        final body = await res.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        if (data is Map<String, dynamic>) {
          final device = CastDevice(
            id: host,
            name: data['name']?.toString() ?? 'Awady Music TV',
            host: host,
            port: data['port'] as int? ?? 8654,
            model: 'Awady Music',
          );
          _addOrUpdateDevice(device);
          return;
        }
      }
    } on Object catch (_) {}

    // Never accept gateway/router IP as Cast device unless it answered Awady TV
    if (host.endsWith('.1')) return;

    // 2. Verify Google Cast V2 TLS control port (8009)
    var castPortOpen = false;
    try {
      final socket = await Socket.connect(
        host,
        8009,
        timeout: const Duration(milliseconds: 1200),
      );
      socket.destroy();
      castPortOpen = true;
    } on Object catch (_) {}

    if (!castPortOpen) return;

    // 3. Fetch friendly name from DIAL/SSDP XML location
    String? friendlyName;
    if (locationUri != null) {
      try {
        final client = HttpClient()
          ..connectionTimeout = const Duration(seconds: 2);
        final req = await client.getUrl(locationUri);
        final res = await req.close().timeout(const Duration(seconds: 2));
        if (res.statusCode == 200) {
          final body = await res.transform(utf8.decoder).join();
          if (body.contains('InternetGatewayDevice') ||
              body.contains('WANDevice') ||
              body.contains('WANConnectionDevice')) {
            return;
          }
          final match = RegExp('<friendlyName>(.*?)</friendlyName>')
              .firstMatch(body);
          if (match != null) {
            final name = match.group(1)?.trim();
            if (name != null && name.isNotEmpty) {
              friendlyName = name;
            }
          }
        }
      } on Object catch (_) {}
    }

    final finalName = friendlyName ?? 'Smart TV ($host)';
    final device = CastDevice(
      id: host,
      name: finalName,
      host: host,
      port: defaultPort,
    );
    _addOrUpdateDevice(device);
  }

  void _handleResponse(Datagram datagram) {
    try {
      final msg = utf8.decode(datagram.data, allowMalformed: true);
      final host = datagram.address.address;

      if (msg.startsWith('AWADY_OFFER:')) {
        try {
          final jsonStr = msg.substring('AWADY_OFFER:'.length);
          final data = jsonDecode(jsonStr);
          if (data is Map<String, dynamic>) {
            final device = CastDevice(
              id: data['id']?.toString() ?? host,
              name: data['name']?.toString() ?? 'Awady TV',
              host: host,
              port: data['port'] as int? ?? 8654,
              model: 'Awady Music',
            );
            _addOrUpdateDevice(device);
          }
        } on Object catch (_) {}
        return;
      }

      String? location;
      String? st;
      for (final line in msg.split('\r\n')) {
        final lower = line.toLowerCase();
        if (lower.startsWith('location:')) {
          location = line.substring(9).trim();
        } else if (lower.startsWith('st:')) {
          st = line.substring(3).trim();
        }
      }

      final isDial = st != null && (st.contains('dial') || st.contains('cast'));
      if (location != null || isDial) {
        final uri = location != null ? Uri.tryParse(location) : null;
        final port = uri?.port != null && uri!.port > 0 ? uri.port : 8008;
        unawaited(_verifyAndAddDevice(host, uri, port));
      }
    } on Object catch (_) {}
  }

  /// Halts local SSDP discovery.
  void stopDiscovery() {
    _cleanup();
    if (state.isScanning) {
      state = state.copyWith(isScanning: false);
    }
  }

  /// Connects to [device].
  void connect(CastDevice device) {
    state = state.copyWith(connectedDevice: () => device);
  }

  /// Disconnects from current cast target.
  void disconnect() {
    state = state.copyWith(connectedDevice: () => null);
  }

  /// Launches native Android Media Output / Cast Settings sheet.
  Future<void> openSystemCastSettings() async {
    try {
      await _channel.invokeMethod<void>('openCastSettings');
    } on Object catch (e) {
      Log.w('Failed to open system cast settings: $e');
    }
  }
}

final castProvider = NotifierProvider<CastNotifier, CastState>(
  CastNotifier.new,
);
