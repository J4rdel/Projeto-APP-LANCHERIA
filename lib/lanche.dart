import 'package:lancheria/produto.dart';
import 'package:lancheria/opcional.dart';

class Lanche extends Produto {
  Lanche({
    required super.id,
    required super.nome,
    required super.descricao,
    required super.preco,
    required super.imagemUrl,
    required super.opcionais,
  });

  factory Lanche.fromJson(Map<String, dynamic> json) {
    var opcionaisList = <Opcional>[];
    if (json['opcionais'] != null && json['opcionais'] is List) {
      opcionaisList = (json['opcionais'] as List)
          .map((opcionalJson) =>
              Opcional.fromJson(opcionalJson as Map<String, dynamic>))
          .toList();
    }

    return Lanche(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nome: json['nome'] ?? '',
      descricao: json['descricao'] ?? '',
      preco: double.tryParse(json['preco'].toString()) ?? 0.0,
      imagemUrl: json['imagem_url'] ?? '',
      opcionais: opcionaisList,
    );
  }
}
