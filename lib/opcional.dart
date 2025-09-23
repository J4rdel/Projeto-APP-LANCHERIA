class Opcional {
  final int id;
  final String nome;
  final double precoAdicional;

  Opcional({
    required this.id,
    required this.nome,
    required this.precoAdicional,
  });

  /// Construtor factory para criar um Opcional a partir de um JSON.
  /// Espera um campo 'preco_adicional'.
  factory Opcional.fromJson(Map<String, dynamic> json) {
    return Opcional(
      id: json['id'] as int,
      nome: json['nome'] as String,
      precoAdicional: double.parse(json['preco_adicional'].toString()),
    );
  }
}