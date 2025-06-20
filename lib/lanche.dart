import 'package:lancheria/produto.dart';

class Lanche extends Produto {
  Lanche({
    required super.id,
    required super.nome,
    required super.preco,
    super.descricao,
    super.imagemUrl,
  }) : super();
}
