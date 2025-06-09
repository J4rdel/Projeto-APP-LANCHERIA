import 'package:flutter/foundation.dart';
import 'lanche.dart'; // Importe seu modelo de Lanche

class Carrinho with ChangeNotifier {
  final List<Lanche> _itens = [];

  List<Lanche> get itens => List.unmodifiable(_itens); // Retorna uma cópia para evitar modificações externas

  double get valorTotal {
    double total = 0.0;
    for (var item in _itens) {
      total += item.preco;
    }
    return total;
  }

  void adicionarLanche(Lanche lanche) {
    _itens.add(lanche);
    notifyListeners(); // Notifica os widgets que estão ouvindo
  }

  void removerLanche(Lanche lanche) {
    _itens.remove(lanche);
    notifyListeners();
  }

  void limparCarrinho() {
    _itens.clear();
    notifyListeners();
  }
}