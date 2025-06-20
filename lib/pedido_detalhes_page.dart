import 'package:flutter/material.dart';
import 'pedido.dart'; // Importe seu modelo de Pedido
import 'gerenciador_pedidos.dart'; // Importe o gerenciador
import 'package:provider/provider.dart';

class PedidoDetalhesPage extends StatefulWidget {
  final Pedido pedido;

  const PedidoDetalhesPage({super.key, required this.pedido});

  @override
  State<PedidoDetalhesPage> createState() => _PedidoDetalhesPageState();
}

class _PedidoDetalhesPageState extends State<PedidoDetalhesPage> {
  late StatusPedido _selectedStatus; // Estado local para o status

  @override
  void initState() {
    super.initState();
    _selectedStatus =
        widget.pedido.status; // Inicializa com o status atual do pedido
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Pedido #${widget.pedido.id}'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Atual: ${widget.pedido.status.displayName}', // Usando extensão
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.pedido.status.color, // Usando extensão
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Itens:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.pedido.itens.length,
                itemBuilder: (context, index) {
                  final itemPedido = widget.pedido.itens[index];
                  return ListTile(
                    title: Text(itemPedido.produto.nome),
                    subtitle: Text(
                      'Quantidade: ${itemPedido.quantidade}  ${itemPedido.observacoes != null ? '(${itemPedido.observacoes})' : ''}',
                    ),
                    trailing: Text(
                      'R\$ ${itemPedido.subtotal.toStringAsFixed(2)}',
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: R\$ ${widget.pedido.valorTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Observações do Gerente: ${widget.pedido.observacoesGerente ?? 'Nenhuma'}', // Corrigido campo e label
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Text(
              'Alterar Status:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<StatusPedido>(
              value: _selectedStatus,
              isExpanded: true,
              icon: const Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple, fontSize: 16),
              underline: Container(height: 2, color: Colors.deepOrangeAccent),
              onChanged: (StatusPedido? newValue) {
                setState(() {
                  _selectedStatus = newValue!;
                });
              },
              items: StatusPedido.values.map<DropdownMenuItem<StatusPedido>>((
                StatusPedido status,
              ) {
                return DropdownMenuItem<StatusPedido>(
                  value: status,
                  child: Text(status.displayName), // Usando extensão
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final gerenciador = Provider.of<GerenciadorPedidos>(
                    context,
                    listen: false,
                  );
                  widget.pedido.atualizarStatus(
                    _selectedStatus,
                  ); // Atualiza o status no objeto Pedido
                  gerenciador.updatePedido(
                    widget.pedido,
                  ); // Notifica o gerenciador para reconstruir a lista

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Status do Pedido #${widget.pedido.id} atualizado para ${_selectedStatus.displayName}!',
                      ), // Usando extensão
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context); // Volta para a lista de pedidos
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Salvar Alterações',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
