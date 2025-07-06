import 'package:lancheria/produto.dart';

class Drink extends Produto {
  Drink({
    required super.id,
    required super.nome,
    required super.descricao,
    required super.preco,
    required super.imagemUrl,
  });

  factory Drink.fromJson(Map<String, dynamic> json) {
    return Drink(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nome: json['nome'] ?? '',
      descricao: json['descricao'] ?? '',
      preco: double.tryParse(json['preco'].toString()) ?? 0.0,
      imagemUrl: json['imagem'] ?? '',
    );
  }
}
