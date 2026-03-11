import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:lancheria/api_service.dart';
import 'package:lancheria/auth_manager.dart';
import 'package:lancheria/gerenciador_pedidos.dart';
import 'package:lancheria/pedido.dart';

class PedidoSocketService extends ChangeNotifier {
  AuthManager? _authManager;
  GerenciadorPedidos? _gerenciadorPedidos;

  WebSocket? _socket;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  String? _connectedWsUrl;
  int _reconnectAttempt = 0;

  void updateDependencies(AuthManager authManager, GerenciadorPedidos gerenciadorPedidos) {
    if (!identical(_authManager, authManager)) {
      _authManager?.removeListener(_onAuthChanged);
      _authManager = authManager;
      _authManager?.addListener(_onAuthChanged);
    }
    _gerenciadorPedidos = gerenciadorPedidos;
    _syncConnection();
  }

  void _onAuthChanged() {
    _syncConnection();
  }

  Uri? _buildWsUriFromBackendUrl(String backendUrl) {
    final httpUri = Uri.tryParse(backendUrl);
    if (httpUri == null || !httpUri.hasScheme || !httpUri.hasAuthority) return null;
    final wsScheme = httpUri.scheme == 'https' ? 'wss' : 'ws';
    return httpUri.replace(scheme: wsScheme, path: '/ws');
  }

  void _syncConnection() {
    final auth = _authManager;
    if (auth == null) return;

    final mesaId = auth.mesaIdForDevice;
    if (mesaId == null || mesaId.isEmpty) {
      _disconnect();
      return;
    }

    final backendUrl = ApiService.baseUrl;
    final wsUri = _buildWsUriFromBackendUrl(backendUrl);
    if (wsUri == null) {
      _disconnect();
      return;
    }

    final wsUrl = wsUri.toString();
    if (_connectedWsUrl == wsUrl && _socket != null) return;

    _connect(wsUrl);
  }

  Future<void> _connect(String wsUrl) async {
    _disconnect();

    try {
      _connectedWsUrl = wsUrl;
      _socket = await WebSocket.connect(wsUrl);
      _reconnectAttempt = 0;
      _subscription = _socket!.listen(
        _handleMessage,
        onDone: _scheduleReconnect,
        onError: (_) => _scheduleReconnect(),
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_authManager?.mesaIdForDevice == null) return;
    _reconnectTimer?.cancel();
    _reconnectAttempt = (_reconnectAttempt + 1).clamp(1, 6);
    final delaySeconds = 1 << (_reconnectAttempt - 1);
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      final wsUri = _buildWsUriFromBackendUrl(ApiService.baseUrl);
      if (wsUri == null) return;
      _connect(wsUri.toString());
    });
  }

  void _disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _subscription?.cancel();
    _subscription = null;
    _socket?.close();
    _socket = null;
    _connectedWsUrl = null;
    _reconnectAttempt = 0;
  }

  StatusPedido? _parseStatus(dynamic raw) {
    final s = raw?.toString();
    if (s == null || s.isEmpty) return null;
    final normalized = s
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('_', '')
        .replaceAll('-', '');

    if (normalized == 'pendente') return StatusPedido.pendente;
    if (normalized == 'preparando') return StatusPedido.preparando;
    if (normalized == 'acaminho') return StatusPedido.aCaminho;
    if (normalized == 'entregue') return StatusPedido.entregue;
    if (normalized == 'cancelado') return StatusPedido.cancelado;
    return null;
  }

  void _handleMessage(dynamic data) {
    String? text;
    if (data is String) {
      text = data;
    } else if (data is List<int>) {
      text = utf8.decode(data);
    }
    if (text == null || text.isEmpty) return;

    dynamic decoded;
    try {
      decoded = json.decode(text);
    } catch (_) {
      return;
    }

    if (decoded is! Map<String, dynamic>) return;

    final event = (decoded['event'] ?? decoded['evento'] ?? decoded['type'] ?? decoded['tipo'])?.toString();
    if (event != null && event != 'pedido.statusAtualizado') return;

    dynamic payload = decoded['data'] ?? decoded['payload'] ?? decoded;
    if (payload is Map<String, dynamic> && payload['pedido'] is Map<String, dynamic>) {
      payload = payload['pedido'];
    }
    if (payload is! Map<String, dynamic>) return;

    final mesaIdMsg = (payload['mesaId'] ?? payload['mesa_id'])?.toString();
    final mesaIdDevice = _authManager?.mesaIdForDevice;
    if (mesaIdMsg != null && mesaIdDevice != null && mesaIdMsg.isNotEmpty && mesaIdMsg != mesaIdDevice) {
      return;
    }

    final numero = int.tryParse((payload['numero'] ?? payload['pedidoNumero'] ?? payload['pedido_numero'] ?? '').toString());
    final id = (payload['id'] ?? payload['pedidoId'] ?? payload['pedido_id'])?.toString();
    final status = _parseStatus(payload['status'] ?? payload['novoStatus'] ?? payload['statusPedido'] ?? payload['status_pedido']);

    if (status == null) return;

    final gerenciador = _gerenciadorPedidos;
    if (gerenciador == null) return;

    if (numero != null) {
      gerenciador.updateStatusByNumero(numero, status);
      return;
    }
    if (id != null && id.isNotEmpty) {
      gerenciador.updateStatusById(id, status);
    }
  }

  @override
  void dispose() {
    _authManager?.removeListener(_onAuthChanged);
    _disconnect();
    super.dispose();
  }
}

