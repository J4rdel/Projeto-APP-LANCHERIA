import 'package:lancheria/lanche.dart';
import 'package:lancheria/drink.dart';
import 'package:lancheria/sobremesa.dart';

class MockDataService {
  static Future<List<Lanche>> fetchLanches() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simula delay de rede
    return [
      Lanche(nome: 'X-Burger Clássico', preco: 25.00, descricao: 'Pão, carne, queijo, alface, tomate.', imagemUrl: 'assets/images/lanches/xburger.png'), // Exemplo de caminho de imagem
      Lanche(nome: 'X-Salada Especial', preco: 28.50, descricao: 'Pão, carne, queijo, ovo, bacon, salada.', imagemUrl: 'assets/images/lanches/xsalada.png'),
      Lanche(nome: 'Misto Quente', preco: 15.00, descricao: 'Pão, presunto e queijo na chapa.', imagemUrl: 'assets/images/lanches/misto.png'),
    ];
  }

  static Future<List<Drink>> fetchDrinks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      Drink(nome: 'Refrigerante Lata', preco: 7.00, descricao: 'Coca-Cola, Guaraná, Fanta.', imagemUrl: 'assets/images/drinks/refri.png'),
      Drink(nome: 'Suco Natural Laranja 500ml', preco: 10.00, descricao: 'Feito na hora com laranjas frescas.', imagemUrl: 'assets/images/drinks/suco_laranja.png'),
      Drink(nome: 'Água Mineral 500ml', preco: 5.00, descricao: 'Com ou sem gás.', imagemUrl: 'assets/images/drinks/agua.png'),
    ];
  }

  static Future<List<Sobremesa>> fetchSobremesas() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      Sobremesa(nome: 'Pudim de Leite Condensado', preco: 12.00, descricao: 'Receita tradicional da casa.', imagemUrl: 'assets/images/sobremesas/pudim.png'),
      Sobremesa(nome: 'Mousse de Maracujá', preco: 15.00, descricao: 'Cremoso e refrescante.', imagemUrl: 'assets/images/sobremesas/mousse.png'),
      Sobremesa(nome: 'Brownie com Sorvete', preco: 18.00, descricao: 'Brownie quentinho com uma bola de sorvete de creme.', imagemUrl: 'assets/images/sobremesas/brownie.png'),
    ];
  }
}
