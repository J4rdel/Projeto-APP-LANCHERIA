import 'package:flutter/foundation.dart';
import 'pedido.dart';

class GerenciadorPedidos with ChangeNotifier {
  final List<Pedido> _pedidos = [];

  /// Retorna uma cópia imutável da lista de pedidos para evitar modificações externas.
  List<Pedido> get pedidos => List.unmodifiable(_pedidos);

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
}
