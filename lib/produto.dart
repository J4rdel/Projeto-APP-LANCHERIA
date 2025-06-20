abstract class Produto {
  final String id; // Identificador único para cada produto
  final String nome;
  final double preco;
  final String? descricao;
  final String? imagemUrl;

  Produto({
    required this.id,
    required this.nome,
    required this.preco,
    this.descricao,
    this.imagemUrl,
  });

  // Um método para facilitar a exibição do preço
  String get precoFormatado => 'R\$ ${preco.toStringAsFixed(2)}';

  // Sobrescrever equality e hashCode é importante se forem usados em Maps ou Sets
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Produto && runtimeType == other.runtimeType && id == other.id;
  @override
  int get hashCode => id.hashCode;
}
