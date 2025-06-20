import 'package:lancheria/produto.dart';

class Sobremesa extends Produto {
  Sobremesa({
    required super.id,
    required super.nome,
    required super.preco,
    super.descricao,
    super.imagemUrl,
  }) : super();
}
