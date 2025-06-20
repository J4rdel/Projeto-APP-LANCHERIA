import 'package:flutter/foundation.dart';
import 'pedido.dart';
import 'lanche.dart';
import 'drink.dart';
import 'sobremesa.dart';

class GerenciadorPedidos with ChangeNotifier {
  final List<Pedido> _pedidos = [];

  List<Pedido> get pedidos =>
      List.unmodifiable(_pedidos); // Retorna uma cópia imutável

  // Para o exemplo, vamos adicionar alguns pedidos mocados no construtor
  GerenciadorPedidos() {
    _adicionarPedidosIniciais();
  }

  void _adicionarPedidosIniciais() {
    // Exemplo de lanches para os pedidos mocados
    final produto1 = Lanche(
      id: 'L_MOCK_001',
      nome: 'X-Salada Mock',
      preco: 15.00,
    );
    final produto2 = Lanche(
      id: 'L_MOCK_002',
      nome: 'X-Bacon Mock',
      preco: 18.00,
    );
    final produto3 = Drink(
      id: 'D_MOCK_001',
      nome: 'Coca-Cola Mock',
      preco: 6.00,
    );
    final produto4 = Sobremesa(
      id: 'S_MOCK_001',
      nome: 'Pudim Mock',
      preco: 10.00,
    );

    // Pedido 1
    addPedido(
      Pedido(
        id: 'PED001',
        idCliente: 'mock_cliente_01', // Adicionado idCliente
        itens: [
          ItemPedido(produto: produto1),
          ItemPedido(produto: produto3),
        ],
        valorTotal: produto1.preco + produto3.preco,
        dataHoraPedido: DateTime.now().subtract(
          const Duration(minutes: 30),
        ), // Corrigido para dataHoraPedido
        status: StatusPedido.preparando,
        observacoesGerente: 'Sem cebola', // Corrigido para observacoesGerente
      ),
    );
    // Pedido 2
    addPedido(
      Pedido(
        id: 'PED002',
        idCliente: 'mock_cliente_02', // Adicionado idCliente
        itens: [
          ItemPedido(produto: produto2),
          ItemPedido(produto: produto1),
          ItemPedido(produto: produto4),
        ],
        valorTotal: produto2.preco + produto1.preco + produto4.preco,
        dataHoraPedido: DateTime.now().subtract(
          const Duration(minutes: 15),
        ), // Corrigido para dataHoraPedido
        status: StatusPedido.pendente,
      ),
    );

    // Pedido 3
    addPedido(
      Pedido(
        id: 'PED003',
        idCliente: 'mock_cliente_03', // Adicionado idCliente
        itens: [
          ItemPedido(produto: produto1, quantidade: 2),
          ItemPedido(produto: produto3),
        ],
        valorTotal: produto1.preco * 2 + produto3.preco,
        dataHoraPedido: DateTime.now().subtract(
          const Duration(minutes: 5),
        ), // Corrigido para dataHoraPedido
        status: StatusPedido.aCaminho,
        observacoesGerente:
            'Entregar para Maria', // Corrigido para observacoesGerente
      ),
    );
  }

  void addPedido(Pedido pedido) {
    _pedidos.add(pedido);
    notifyListeners();
  }

  // Método para atualizar um pedido existente
  void updatePedido(Pedido updatedPedido) {
    final index = _pedidos.indexWhere((p) => p.id == updatedPedido.id);
    if (index != -1) {
      _pedidos[index] = updatedPedido;
      notifyListeners();
    }
  }

  // Você pode adicionar métodos para remover pedido, filtrar por status, etc.
}
