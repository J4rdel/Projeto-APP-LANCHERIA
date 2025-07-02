import 'package:lancheria/produto.dart';

class Lanche extends Produto {
  Lanche({
    required super.id,
    required super.nome,
    required super.descricao,
    required super.preco,
    required super.imagemUrl,
  });

  /// O construtor factory `fromJson` que estava faltando.
  /// Ele pega um mapa (JSON) e cria uma instância de Lanche.
  factory Lanche.fromJson(Map<String, dynamic> json) {
    return Lanche(
      id: json['id'] as int,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      // É mais seguro converter o preço para String e depois para double,
      // pois a API pode enviar "50.00" ou 50.00.
      preco: double.parse(json['preco'].toString()),
      imagemUrl: json['imagem_url'] as String,
    );
  }
}
