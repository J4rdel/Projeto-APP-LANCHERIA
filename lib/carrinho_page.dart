import 'package:flutter/material.dart';
import 'package:lancheria/app_config.dart';
import 'package:lancheria/carrinho.dart';
import 'package:lancheria/gerenciador_pedidos.dart';
import 'package:lancheria/item_carrinho.dart'; // Adicionando o import que faltava
import 'package:lancheria/pedido.dart';
import 'package:provider/provider.dart';

class CarrinhoPage extends StatelessWidget {
  const CarrinhoPage({super.key});

  void _finalizarPedido(
    BuildContext context,
    Carrinho carrinho,
    GerenciadorPedidos gerenciadorPedidos,
  ) {
    if (carrinho.itens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seu carrinho está vazio!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Criar lista de ItemPedido a partir de ItemCarrinho
    final List<ItemPedido> itensPedido = carrinho.itens.map<ItemPedido>((
      ItemCarrinho itemCarrinho,
    ) {
      // Tipo explícito para itemCarrinho
      return ItemPedido(
        produto: itemCarrinho.produto,
        quantidade: itemCarrinho.quantidade,
        opcionaisSelecionados: itemCarrinho.opcionaisSelecionados,
      );
    }).toList();

    // Criar o Pedido
    final novoPedido = Pedido(
      // Gerar um ID único para o pedido (exemplo simples)
      id: 'PED${DateTime.now().millisecondsSinceEpoch}',
      idCliente: 'cliente_local_01', // Mock ID do cliente
      itens: itensPedido,
      valorTotal: carrinho.valorTotal,
      dataHoraPedido: DateTime.now(),
      status: StatusPedido.pendente, // Status inicial
    );

    // Adicionar ao gerenciador de pedidos
    gerenciadorPedidos.addPedido(novoPedido);

    // Limpar o carrinho
    carrinho.limparCarrinho();

    // Mostrar confirmação
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pedido Realizado!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seu pedido (ID: ${novoPedido.id}) foi enviado para o balcão.',
            ),
            const SizedBox(height: 10),
            Text(
              'Valor Total: ${AppConfig.instance.currencySymbol} ${novoPedido.valorTotal.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 10),
            const Text('Obrigado pela preferência!'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carrinho = Provider.of<Carrinho>(context);
    final gerenciadorPedidos = Provider.of<GerenciadorPedidos>(
      context,
      listen: false,
    );
    final String currency = AppConfig.instance.currencySymbol;

    return Scaffold(
      // appBar: AppBar( // O AppBar já é fornecido pela HomePage
      //   title: const Text('Meu Carrinho'),
      // ),
      body: Column(
        children: [
          Expanded(
            child: carrinho.itens.isEmpty
                ? const Center(
                    child: Text(
                      'Seu carrinho está vazio!',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: carrinho.itens.length,
                    itemBuilder: (ctx, i) {
                      final item = carrinho.itens[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: SizedBox(
                            width: 60,
                            height: 60,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: item.produto.imagemUrl.isNotEmpty
                                  ? Image.network(
                                      item.produto.imagemUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                              ),
                                            );
                                          },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.broken_image,
                                                color: Colors.grey,
                                              ),
                                    )
                                  : const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                            ),
                          ),
                          title: Text(item.produto.nome),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Qtd: ${item.quantidade} x $currency ${item.precoUnitarioComAdicionais.toStringAsFixed(2)}',
                              ),
                              if (item.opcionaisSelecionados.isNotEmpty)
                                Text(
                                  'Adicionais: ${item.opcionaisSelecionados.map((o) => o.nome).join(', ')}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$currency ${item.subtotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.orange,
                                ),
                                onPressed: () {
                                  carrinho.removerUnidade(item);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  carrinho.removerProdutoCompletamente(item);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (carrinho.itens.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$currency ${carrinho.valorTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        50,
                      ), // Botão largo
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('FINALIZAR PEDIDO'),
                    onPressed: () =>
                        _finalizarPedido(context, carrinho, gerenciadorPedidos),
                  ),
                  TextButton(
                    child: const Text(
                      'Limpar Carrinho',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    onPressed: () {
                      carrinho.limparCarrinho();
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
