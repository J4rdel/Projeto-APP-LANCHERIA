import 'package:lancheria/produto.dart';

class Sobremesa extends Produto {
  Sobremesa({
    required super.id,
    required super.nome,
    required super.descricao,
    required super.preco,
    required super.imagemUrl,
  });

  /// Construtor factory para criar uma Sobremesa a partir de um JSON.
  factory Sobremesa.fromJson(Map<String, dynamic> json) {
    return Sobremesa(
      id: json['id'] as int,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      preco: double.parse(json['preco'].toString()),
      imagemUrl: json['imagem_url'] as String,
    );
  }
}
