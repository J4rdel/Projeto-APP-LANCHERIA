// lib/models/pedido.dart
import 'package:lancheria/produto.dart'; // Importar Produto
import 'package:flutter/material.dart'; // Necessário para a cor
import 'package:lancheria/opcional.dart';

enum StatusPedido { pendente, preparando, aCaminho, entregue, cancelado }

class ItemPedido {
  final Produto produto;
  int quantidade;
  final List<Opcional> opcionaisSelecionados;
  String? observacoes; // Ex: "Sem cebola"

  ItemPedido({
    required this.produto,
    this.quantidade = 1,
    this.opcionaisSelecionados = const [],
    this.observacoes,
  });

  /// Retorna o somatório do preço de todos os adicionais selecionados.
  double get precoAdicionais {
    return opcionaisSelecionados.fold(
        0.0, (sum, item) => sum + item.precoAdicional);
  }

  /// Retorna o preço de uma unidade do produto com seus adicionais.
  double get precoUnitarioComAdicionais => produto.preco + precoAdicionais;

  /// Retorna o subtotal (preço unitário com adicionais * quantidade).
  double get subtotal => precoUnitarioComAdicionais * quantidade;
}

class Pedido {
  final String id; // ID único do pedido
  final String idCliente; // Quem fez o pedido
  final List<ItemPedido> itens;
  StatusPedido status;
  DateTime dataHoraPedido;
  DateTime? dataHoraAtualizacao; // Quando o gerente alterou pela última vez
  String? observacoesGerente; // Notas do gerente sobre o pedido
  double valorTotal; // Pode ser calculado ou salvo

  Pedido({
    required this.id,
    required this.idCliente,
    required this.itens,
    this.status = StatusPedido.pendente,
    required this.dataHoraPedido,
    this.dataHoraAtualizacao,
    this.observacoesGerente,
    required this.valorTotal,
  });

  // Método para atualizar o status do pedido
  void atualizarStatus(StatusPedido novoStatus) {
    status = novoStatus;
    dataHoraAtualizacao = DateTime.now();
    // Notificar listeners se estiver usando Provider/BLoC
  }

  // Método para calcular o valor total (se preferir calcular na hora)
  double calcularValorTotal() {
    return itens.fold(0.0, (sum, item) => sum + item.subtotal);
  }
}

// Extensão para StatusPedido para fornecer display Name e Color
extension StatusPedidoExtension on StatusPedido {
  String get displayName {
    switch (this) {
      case StatusPedido.pendente:
        return 'Pendente';
      case StatusPedido.preparando:
        return 'Preparando';
      case StatusPedido.aCaminho:
        return 'A Caminho';
      case StatusPedido.entregue:
        return 'Entregue';
      case StatusPedido.cancelado:
        return 'Cancelado';
    }
  }

  Color get color {
    switch (this) {
      case StatusPedido.pendente:
        return Colors.orange;
      case StatusPedido.preparando:
        return Colors.blue;
      case StatusPedido.aCaminho:
        return Colors.purple;
      case StatusPedido.entregue:
        return Colors.green;
      case StatusPedido.cancelado:
        return Colors.red;
    }
  }
}
