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
      final mSearch = utf8.encode(
        'M-SEARCH * HTTP/1.1\r\n'
        'HOST: 239.255.255.250:1900\r\n'
        'MAN: "ssdp:discover"\r\n'
        'MX: 3\r\n'
        'ST: urn:dial-multiscreen-org:service:dial:1\r\n\r\n',
      );
      _socket?.send(mSearch, multicast, 1900);

      final ssdpSearch = utf8.encode(
        'M-SEARCH * HTTP/1.1\r\n'
        'HOST: 239.255.255.250:1900\r\n'
        'MAN: "ssdp:discover"\r\n'
        'MX: 3\r\n'
        'ST: ssdp:all\r\n\r\n',
      );
      _socket?.send(ssdpSearch, multicast, 1900);

      // Awady Connect LAN discovery broadcast
      final awadyPing = utf8.encode('AWADY_DISCOVER');
      _socket?.send(awadyPing, InternetAddress('255.255.255.255'), 8655);
    } on Object catch (e) {
      Log.w('SSDP discovery bind error: $e');
    }

    _scanTimer?.cancel();
    _scanTimer = Timer(const Duration(seconds: 4), stopDiscovery);
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
              model: 'Awady TV Receiver',
            );
            if (!state.devices.any(
              (d) => d.host == host && d.port == device.port,
            )) {
              state = state.copyWith(devices: [...state.devices, device]);
            }
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
        if (!state.devices.any((d) => d.host == host)) {
          final uri = location != null ? Uri.tryParse(location) : null;
          final port = uri?.port != null && uri!.port > 0 ? uri.port : 8008;
          final device = CastDevice(
            id: host,
            name: 'Cast Device ($host)',
            host: host,
            port: port,
          );
          state = state.copyWith(devices: [...state.devices, device]);
          if (uri != null) {
            unawaited(_fetchDeviceName(device, uri));
          }
        }
      }
    } on Object catch (_) {}
  }

  Future<void> _fetchDeviceName(CastDevice device, Uri locationUri) async {
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 2);
      final req = await client.getUrl(locationUri);
      final res = await req.close();
      if (res.statusCode == 200) {
        final body = await res.transform(utf8.decoder).join();
        final match = RegExp('<friendlyName>(.*?)</friendlyName>')
            .firstMatch(body);
        if (match != null) {
          final friendlyName = match.group(1)?.trim();
          if (friendlyName != null && friendlyName.isNotEmpty) {
            final updated = CastDevice(
              id: device.id,
              name: friendlyName,
              host: device.host,
              port: device.port,
            );
            final list = state.devices
                .map((d) => d.id == device.id ? updated : d)
                .toList();
            state = state.copyWith(devices: list);
          }
        }
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
