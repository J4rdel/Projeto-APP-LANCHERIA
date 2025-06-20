import 'package:lancheria/lanche.dart';
import 'package:lancheria/drink.dart';
import 'package:lancheria/sobremesa.dart';

class MockDataService {
  static Future<List<Lanche>> fetchLanches() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simula latência
    return _lanches;
  }

  static Future<List<Drink>> fetchDrinks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _drinks;
  }

  static Future<List<Sobremesa>> fetchSobremesas() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _sobremesas;
  }

  // --- DADOS MOCKADOS INTERNOS ---
  static final List<Lanche> _lanches = [
    Lanche(
      id: 'L001',
      nome: 'X-Salada Especial',
      preco: 22.50,
      descricao:
          'Pão, hambúrguer artesanal 150g, queijo cheddar, alface, tomate, cebola roxa e molho especial da casa.',
      imagemUrl: 'assets/images/x_salada.png',
    ),
    Lanche(
      id: 'L002',
      nome: 'X-Bacon Duplo',
      preco: 28.00,
      descricao:
          'Pão brioche, dois hambúrgueres 100g, dobro de queijo prato, bacon crocante e maionese de alho.',
      imagemUrl: 'assets/images/x_bacon.png',
    ),
    Lanche(
      id: 'L003',
      nome: 'Frango Crispy',
      preco: 25.00,
      descricao:
          'Pão, filé de frango empanado super crocante, queijo suíço, alface americana e molho tártaro.',
      imagemUrl: 'assets/images/frango_crispy.png',
    ),
    Lanche(
      id: 'L004',
      nome: 'Vegetariano Gourmet',
      preco: 23.00,
      descricao:
          'Pão integral, hambúrguer de grão de bico, queijo coalho grelhado, rúcula, tomate seco e pasta de abacate.',
      imagemUrl: 'assets/images/vegetariano.png',
    ),
    Lanche(
      id: 'L005',
      nome: 'Kids Lanchinho',
      preco: 18.00,
      descricao: 'Pão, hambúrguer 90g, queijo e batata sorriso (acompanha).',
      imagemUrl: 'assets/images/kids_lanche.png',
    ),
    Lanche(
      id: 'L006',
      nome: 'X-Tudo Monstro',
      preco: 35.00,
      descricao:
          'Pão, 2x hambúrgueres 150g, ovo, bacon, calabresa, presunto, queijo, alface, tomate, milho, ervilha.',
      imagemUrl: 'assets/images/x_tudo.png',
    ), // Adicione a imagem se tiver
    Lanche(
      id: 'L007',
      nome: 'Batata Frita Simples',
      preco: 15.00,
      descricao: 'Porção generosa de batatas fritas sequinhas.',
      imagemUrl: 'assets/images/batata_frita.png',
    ), // Adicione a imagem
  ];

  static final List<Drink> _drinks = [
    Drink(
      id: 'D001',
      nome: 'Refrigerante Lata',
      preco: 6.00,
      descricao: 'Coca-Cola, Guaraná, Fanta Laranja/Uva (350ml)',
      imagemUrl: 'assets/images/refrigerante_lata.png',
    ),
    Drink(
      id: 'D002',
      nome: 'Suco Natural Laranja',
      preco: 9.00,
      descricao: 'Laranja espremida na hora (400ml)',
      imagemUrl: 'assets/images/suco_laranja.png',
    ), // Imagem específica
    Drink(
      id: 'D003',
      nome: 'Água Mineral',
      preco: 4.00,
      descricao: 'Com gás ou sem gás (500ml)',
      imagemUrl: 'assets/images/agua_mineral.png',
    ),
    Drink(
      id: 'D004',
      nome: 'Cerveja Long Neck Heineken',
      preco: 10.00,
      descricao: 'Heineken gelada (330ml)',
      imagemUrl: 'assets/images/heineken.png',
    ), // Imagem específica
    Drink(
      id: 'D005',
      nome: 'Suco de Morango',
      preco: 9.50,
      descricao: 'Polpa de morango batida com água ou leite (400ml)',
      imagemUrl: 'assets/images/suco_morango.png',
    ), // Imagem específica
  ];

  static final List<Sobremesa> _sobremesas = [
    Sobremesa(
      id: 'S001',
      nome: 'Pudim de Leite',
      preco: 12.00,
      descricao: 'Clássico pudim de leite condensado com calda de caramelo.',
      imagemUrl: 'assets/images/pudim.png',
    ),
    Sobremesa(
      id: 'S002',
      nome: 'Brownie com Sorvete',
      preco: 18.00,
      descricao:
          'Delicioso brownie de chocolate meio amargo com uma bola de sorvete de creme e calda de chocolate.',
      imagemUrl: 'assets/images/brownie_sorvete.png',
    ),
    Sobremesa(
      id: 'S003',
      nome: 'Mousse de Maracujá',
      preco: 10.00,
      descricao: 'Leve e refrescante mousse de maracujá.',
      imagemUrl: 'assets/images/mousse_maracuja.png',
    ),
    Sobremesa(
      id: 'S004',
      nome: 'Petit Gateau',
      preco: 20.00,
      descricao:
          'Bolinho quente de chocolate com recheio cremoso, acompanhado de sorvete de creme.',
      imagemUrl: 'assets/images/petit_gateau.png',
    ), // Imagem específica
  ];
}
