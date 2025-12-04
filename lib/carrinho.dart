import 'package:flutter/foundation.dart';
import 'package:lancheria/item_carrinho.dart';
import 'package:lancheria/produto.dart';
import 'package:lancheria/opcional.dart';

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

  void adicionarItem(Produto produto, {int quantidade = 1, List<Opcional> opcionais = const []}) {
    // Procura por um item idêntico (mesmo produto e mesmos adicionais)
    final index = _itens.indexWhere((item) {
      if (item.produto.id != produto.id) return false;

      // Compara os adicionais selecionados.
      // A ordem não importa, então usamos Sets.
      final idsAdicionaisAtuais =
          item.opcionaisSelecionados.map((o) => o.id).toSet();
      final idsNovosAdicionais = opcionais.map((o) => o.id).toSet();

      return setEquals(idsAdicionaisAtuais, idsNovosAdicionais);
    });

    if (index >= 0) {
      // Se um item idêntico já existe, apenas incrementa a quantidade
      _itens[index].quantidade += quantidade;
    } else {
      // Caso contrário, adiciona como um novo item no carrinho
      _itens.add(ItemCarrinho(
        produto: produto,
        quantidade: quantidade,
        opcionaisSelecionados: opcionais,
      ));
    }
    notifyListeners();
  }

  void removerUnidade(ItemCarrinho item) {
    if (item.quantidade > 1) {
      item.quantidade--;
    } else {
      // Se a quantidade for 1, remove o item completamente
      _itens.remove(item);
    }
    notifyListeners();
  }

  void removerProdutoCompletamente(ItemCarrinho item) {
    _itens.remove(item);
    notifyListeners();
  }

  void limparCarrinho() {
    _itens.clear();
    notifyListeners();
  }
}
