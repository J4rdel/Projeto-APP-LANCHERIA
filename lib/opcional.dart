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
      // Torna a conversão mais segura, aceitando tanto números (double/int) quanto strings.
      precoAdicional: (json['preco_adicional'] is String)
          ? (double.tryParse(json['preco_adicional']) ?? 0.0)
          : (json['preco_adicional'] as num).toDouble(),
    );
  }
}