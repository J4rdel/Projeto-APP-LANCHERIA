import 'package:lancheria/produto.dart';
import 'package:lancheria/opcional.dart';

class Sobremesa extends Produto {
  Sobremesa({
    required super.id,
    required super.nome,
    required super.descricao,
    required super.preco,
    required super.imagemUrl,
    required super.opcionais,
  });

  /// Construtor factory para criar uma Sobremesa a partir de um JSON.
  factory Sobremesa.fromJson(Map<String, dynamic> json) {
    var opcionaisList = <Opcional>[];
    if (json['opcionais'] != null && json['opcionais'] is List) {
      opcionaisList = (json['opcionais'] as List)
          .map((opcionalJson) =>
              Opcional.fromJson(opcionalJson as Map<String, dynamic>))
          .toList();
    }

    return Sobremesa(
      id: json['id'] as int,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      preco: double.parse(json['preco'].toString()),
      imagemUrl: json['imagem_url'] as String,
      opcionais: opcionaisList,
    );
  }
}
