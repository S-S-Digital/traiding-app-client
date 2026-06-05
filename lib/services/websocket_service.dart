import 'dart:async';
import 'dart:convert';
import 'package:aspiro_trade/repositories/core/databases/storage/token_storage.dart';
import 'package:aspiro_trade/repositories/core/logs/app_logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocketService {
  WebSocketService({
    required String apiUrl,
    required TokenStorage tokenStorage,
  })  : _apiUrl = apiUrl,
        _tokenStorage = tokenStorage;

  final String _apiUrl;
  final TokenStorage _tokenStorage;
  IO.Socket? _socket;

  final _priceUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final _signalUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  // Per-user lifecycle events added backend-side (IMPL_SIGNALS): a trade closing
  // (`signal_closed`) and a live upsert of an existing signal (`signal_update`).
  final _signalClosedController = StreamController<Map<String, dynamic>>.broadcast();
  final _signalLiveUpdateController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get priceUpdates => _priceUpdateController.stream;
  /// `new_signal` — a brand new signal was created for this user.
  Stream<Map<String, dynamic>> get signalUpdates => _signalUpdateController.stream;
  /// `signal_closed` — a signal was closed (TP/SL/reversal); remove from active.
  Stream<Map<String, dynamic>> get signalClosedUpdates => _signalClosedController.stream;
  /// `signal_update` — an existing signal changed; upsert by id.
  Stream<Map<String, dynamic>> get signalLiveUpdates => _signalLiveUpdateController.stream;

  bool get isConnected => _socket?.connected ?? false;

  void connect() async {
    disconnect(); // Ensure any existing socket is completely cleaned up first

    final (accessToken, _) = await _tokenStorage.getTokens();
    if (accessToken == null) {
      talker.warning('[WS] No access token found in storage. Connection postponed.');
      return;
    }

    talker.info('[WS] Connecting to $_apiUrl...');

    try {
      _socket = IO.io(
        _apiUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(3000)
            .setAuth({'token': accessToken})
            .build(),
      );

      _socket!.onConnect((_) {
        talker.info('[WS] Connected successfully.');
        final userId = _getUserIdFromToken(accessToken);
        if (userId != null) {
          talker.debug('[WS] Subscribing to room user:$userId');
          _socket!.emit('subscribe', {'userId': userId});
        }
      });

      _socket!.onConnectError((err) {
        talker.error('[WS] Connection error: $err');
      });

      _socket!.onReconnectAttempt((attempt) {
        talker.debug('[WS] Reconnect attempt #$attempt');
      });

      _socket!.on('price_update', (data) {
        talker.debug('[WS] Price update: $data');
        if (data is Map<String, dynamic>) {
          _priceUpdateController.add(data);
        } else if (data is Map) {
          _priceUpdateController.add(Map<String, dynamic>.from(data));
        }
      });

      _socket!.on('new_signal', (data) {
        talker.info('[WS] Received new signal event: $data');
        if (data is Map<String, dynamic>) {
          _signalUpdateController.add(data);
        } else if (data is Map) {
          _signalUpdateController.add(Map<String, dynamic>.from(data));
        }
      });

      _socket!.on('signal_closed', (data) {
        talker.info('[WS] Received signal_closed event: $data');
        if (data is Map<String, dynamic>) {
          _signalClosedController.add(data);
        } else if (data is Map) {
          _signalClosedController.add(Map<String, dynamic>.from(data));
        }
      });

      _socket!.on('signal_update', (data) {
        talker.info('[WS] Received signal_update event: $data');
        if (data is Map<String, dynamic>) {
          _signalLiveUpdateController.add(data);
        } else if (data is Map) {
          _signalLiveUpdateController.add(Map<String, dynamic>.from(data));
        }
      });

      _socket!.onDisconnect((data) {
        talker.warning('[WS] Disconnected: $data');
      });

      _socket!.onError((data) {
        talker.error('[WS] Socket error: $data');
      });
    } catch (e) {
      talker.error('[WS] Failed to initialize Socket.io: $e');
    }
  }

  void disconnect() {
    if (_socket != null) {
      talker.info('[WS] Disconnecting socket...');
      _socket!.off('price_update');
      _socket!.off('new_signal');
      _socket!.off('signal_closed');
      _socket!.off('signal_update');
      _socket!.disconnect();
      _socket!.close();
      _socket = null;
    }
  }

  String? _getUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      return map['sub'] as String?;
    } catch (e) {
      talker.error('[WS] Failed to parse userId from JWT token: $e');
      return null;
    }
  }

  void dispose() {
    disconnect();
    _priceUpdateController.close();
    _signalUpdateController.close();
    _signalClosedController.close();
    _signalLiveUpdateController.close();
  }
}
