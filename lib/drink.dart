import 'package:lancheria/produto.dart';

class Drink extends Produto {
  Drink({
    required super.id,
    required super.nome,
    required super.preco,
    super.descricao,
    super.imagemUrl,
  }) : super();
}
