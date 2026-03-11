import 'package:flutter/foundation.dart';
import 'pedido.dart';

class GerenciadorPedidos with ChangeNotifier {
  final List<Pedido> _pedidos = [];

  /// Retorna uma cópia imutável da lista de pedidos para evitar modificações externas.
  List<Pedido> get pedidos => List.unmodifiable(_pedidos);

  Pedido? findById(String id) {
    final index = _pedidos.indexWhere((p) => p.id == id);
    if (index == -1) return null;
    return _pedidos[index];
  }

  void addPedido(Pedido pedido) {
    _pedidos.add(pedido);
    notifyListeners();
  }

  /// Atualiza um pedido existente na lista.
  void updatePedido(Pedido updatedPedido) {
    final index = _pedidos.indexWhere((p) => p.id == updatedPedido.id);
    if (index != -1) {
      _pedidos[index] = updatedPedido;
      notifyListeners();
    }
  }

  /// Remove um pedido da lista.
  void removePedido(String pedidoId) {
    _pedidos.removeWhere((p) => p.id == pedidoId);
    notifyListeners();
  }

  void updateStatusById(String pedidoId, StatusPedido status) {
    final pedido = findById(pedidoId);
    if (pedido == null) return;
    pedido.atualizarStatus(status);
    notifyListeners();
  }

  int? _extractNumeroFromId(String id) {
    final digits = RegExp(r'(\d+)').allMatches(id).map((m) => m.group(1)).whereType<String>().toList();
    if (digits.isEmpty) return null;
    return int.tryParse(digits.last);
  }

  void updateStatusByNumero(int numero, StatusPedido status) {
    for (final pedido in _pedidos) {
      final extracted = _extractNumeroFromId(pedido.id);
      if (extracted == numero) {
        pedido.atualizarStatus(status);
        notifyListeners();
        return;
      }
    }
  }
}
