class Sobremesa {
  final String nome;
  final double preco;
  final String? descricao;
  final String? imagemUrl; // URL da imagem da sobremesa

  Sobremesa({
    required this.nome,
    required this.preco,
    this.descricao,
    this.imagemUrl,
  });

  String get precoFormatado => 'R\$ ${preco.toStringAsFixed(2)}';
}
