/// Uma classe base abstrata para representar qualquer item vendável na lancheria.
///
/// Usar uma classe base nos permite tratar Lanche, Drink e Sobremesa
/// de forma polimórfica, simplificando lógicas como a do carrinho de compras.
abstract class Produto {
  final int id;
  final String nome;
  final String descricao;
  final double preco;
  final String imagemUrl;

  Produto({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.imagemUrl,
  });
}
