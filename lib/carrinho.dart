import 'package:flutter/foundation.dart';
import 'package:lancheria/item_carrinho.dart';
import 'package:lancheria/produto.dart';

class Carrinho with ChangeNotifier {
  final List<ItemCarrinho> _itens = [];

  List<ItemCarrinho> get itens => List.unmodifiable(_itens);

  double get valorTotal {
    double total = 0.0;
    for (var item in _itens) {
      total += item.subtotal;
    }
    return total;
  }

  int get quantidadeTotalItens {
    int total = 0;
    for (var item in _itens) {
      total += item.quantidade;
    }
    return total;
  }

  void adicionarItem(Produto produto) {
    // Verifica se o item já existe no carrinho
    final index = _itens.indexWhere((item) => item.produto.id == produto.id);

    if (index >= 0) {
      // Se existe, incrementa a quantidade
      _itens[index].quantidade++;
    } else {
      // Se não existe, adiciona como um novo ItemCarrinho
      _itens.add(ItemCarrinho(produto: produto, quantidade: 1));
    }
    notifyListeners();
  }

  void removerUnidade(Produto produto) {
    final index = _itens.indexWhere((item) => item.produto.id == produto.id);
    if (index >= 0) {
      if (_itens[index].quantidade > 1) {
        _itens[index].quantidade--;
      } else {
        _itens.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removerProdutoCompletamente(Produto produto) {
    _itens.removeWhere((item) => item.produto.id == produto.id);
    notifyListeners();
  }

  void limparCarrinho() {
    _itens.clear();
    notifyListeners();
  }
}
