import 'package:lancheria/produto.dart';

class Drink extends Produto {
  Drink({
    required super.id,
    required super.nome,
    required super.descricao,
    required super.preco,
    required super.imagemUrl,
  });

  /// Construtor factory para criar um Drink a partir de um JSON.
  factory Drink.fromJson(Map<String, dynamic> json) {
    return Drink(
      id: json['id'] as int,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      preco: double.parse(json['preco'].toString()),
      imagemUrl: json['imagem_url'] as String,
    );
  }
}
