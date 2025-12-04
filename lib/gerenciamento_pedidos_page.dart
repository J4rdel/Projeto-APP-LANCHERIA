import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'gerenciador_pedidos.dart';
import 'pedido.dart'; // Para o enum StatusPedido
import 'package:lancheria/pedido_detalhes_page.dart';

class GerenciamentoPedidosPage extends StatelessWidget {
  const GerenciamentoPedidosPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta as mudanças no GerenciadorPedidos
    final gerenciador = Provider.of<GerenciadorPedidos>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Pedidos'),
        backgroundColor: Colors.deepOrange,
      ),
      body: gerenciador.pedidos.isEmpty
          ? const Center(
              child: Text(
                'Nenhum pedido para gerenciar.',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: gerenciador.pedidos.length,
              itemBuilder: (context, index) {
                final pedido = gerenciador.pedidos[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 4,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: pedido.status.color, // Usando extensão
                      child: Text(
                        pedido.id.substring(3), // Ex: "001" de "PED001"
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      'Pedido #${pedido.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: ${pedido.status.displayName}',
                        ), // Usando extensão
                        Text(
                          'Total: R\$ ${pedido.valorTotal.toStringAsFixed(2)}',
                        ),
                        Text(
                          'Itens: ${pedido.itens.map((itemPedido) => itemPedido.produto.nome).join(', ')}',
                        ), // Corrigido para acessar produto.nome
                      ],
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PedidoDetalhesPage(pedido: pedido),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
