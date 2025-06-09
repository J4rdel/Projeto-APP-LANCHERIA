import 'package:flutter/foundation.dart';
import 'pedido.dart';
import 'lanche.dart'; // Para o exemplo de dados mocados

class GerenciadorPedidos with ChangeNotifier {
  final List<Pedido> _pedidos = [];

  List<Pedido> get pedidos => List.unmodifiable(_pedidos); // Retorna uma cópia imutável

  // Para o exemplo, vamos adicionar alguns pedidos mocados no construtor
  GerenciadorPedidos() {
    _adicionarPedidosIniciais();
  }

  void _adicionarPedidosIniciais() {
    // Exemplo de lanches para os pedidos mocados
    final lanche1 = Lanche(nome: 'X-Salada', preco: 15.00);
    final lanche2 = Lanche(nome: 'X-Bacon', preco: 18.00);
    final lanche3 = Lanche(nome: 'Coca-Cola', preco: 6.00);
    final lanche4 = Lanche(nome: 'Pudim', preco: 10.00);

    // Pedido 1
    addPedido(
      Pedido(
        id: 'PED001',
        idCliente: 'mock_cliente_01', // Adicionado idCliente
        itens: [ItemPedido(lanche: lanche1), ItemPedido(lanche: lanche3)], // Convertido para ItemPedido
        valorTotal: lanche1.preco + lanche3.preco,
        dataHoraPedido: DateTime.now().subtract(const Duration(minutes: 30)), // Corrigido para dataHoraPedido
        status: StatusPedido.preparando,
        observacoesGerente: 'Sem cebola', // Corrigido para observacoesGerente
      ),
    );

    // Pedido 2
    addPedido(
      Pedido(
        id: 'PED002',
        idCliente: 'mock_cliente_02', // Adicionado idCliente
        itens: [ItemPedido(lanche: lanche2), ItemPedido(lanche: lanche1), ItemPedido(lanche: lanche4)], // Convertido para ItemPedido
        valorTotal: lanche2.preco + lanche1.preco + lanche4.preco,
        dataHoraPedido: DateTime.now().subtract(const Duration(minutes: 15)), // Corrigido para dataHoraPedido
        status: StatusPedido.pendente,
      ),
    );

     // Pedido 3
    addPedido(
      Pedido(
        id: 'PED003',
        idCliente: 'mock_cliente_03', // Adicionado idCliente
        itens: [ItemPedido(lanche: lanche1, quantidade: 2), ItemPedido(lanche: lanche3)], // Convertido para ItemPedido, exemplo com quantidade
        valorTotal: lanche1.preco * 2 + lanche3.preco,
        dataHoraPedido: DateTime.now().subtract(const Duration(minutes: 5)), // Corrigido para dataHoraPedido
        status: StatusPedido.aCaminho,
        observacoesGerente: 'Entregar para Maria', // Corrigido para observacoesGerente
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