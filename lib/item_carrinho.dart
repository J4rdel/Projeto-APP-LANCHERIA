import 'package:lancheria/produto.dart';

class ItemCarrinho {
  final Produto produto;
  int quantidade;

  ItemCarrinho({required this.produto, this.quantidade = 1});

  double get subtotal => produto.preco * quantidade;
}
