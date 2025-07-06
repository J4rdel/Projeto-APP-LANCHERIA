import 'package:lancheria/produto.dart';

class Lanche extends Produto {
  Lanche({
    required super.id,
    required super.nome,
    required super.descricao,
    required super.preco,
    required super.imagemUrl,
  });

  factory Lanche.fromJson(Map<String, dynamic> json) {
    return Lanche(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nome: json['nome'] ?? '',
      descricao: json['descricao'] ?? '',
      preco: double.tryParse(json['preco'].toString()) ?? 0.0,
      imagemUrl: json['imagem_url'] ?? '',
    );
  }
}
