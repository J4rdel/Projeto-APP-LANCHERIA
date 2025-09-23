import 'package:lancheria/produto.dart';
import 'package:lancheria/opcional.dart';

class ItemCarrinho {
  final Produto produto;
  int quantidade;
  final List<Opcional> opcionaisSelecionados;

  ItemCarrinho({
    required this.produto,
    this.quantidade = 1,
    this.opcionaisSelecionados = const [],
  });

  /// Retorna o somatório do preço de todos os adicionais selecionados.
  double get precoAdicionais {
    return opcionaisSelecionados.fold(
        0.0, (sum, item) => sum + item.precoAdicional);
  }

  /// Retorna o preço de uma unidade do produto com seus adicionais.
  double get precoUnitarioComAdicionais => produto.preco + precoAdicionais;

  /// Retorna o subtotal (preço unitário com adicionais * quantidade).
  double get subtotal => precoUnitarioComAdicionais * quantidade;
}
