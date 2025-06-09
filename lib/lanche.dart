
class Lanche {
  final String nome;
  final double preco;
  final String? descricao;
  final String? imagemUrl; // URL da imagem do lanche

  Lanche({
    required this.nome,
    required this.preco,
    this.descricao,
    this.imagemUrl,
  });

  // Um método para facilitar a exibição
  String get precoFormatado => 'R\$ ${preco.toStringAsFixed(2)}';
}