import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'carrinho.dart'; // Importe seu modelo de Carrinho

class CarrinhoPage extends StatelessWidget {
  const CarrinhoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta as mudanças no Carrinho
    final carrinho = Provider.of<Carrinho>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seu Pedido'),
        backgroundColor: Colors.deepOrange,
      ),
      body: carrinho.itens.isEmpty
          ? const Center(
              child: Text(
                'Seu carrinho está vazio!',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: carrinho.itens.length,
                    itemBuilder: (context, index) {
                      final lanche = carrinho.itens[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: lanche.imagemUrl != null && lanche.imagemUrl!.isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(lanche.imagemUrl!),
                                  radius: 25,
                                )
                              : const Icon(Icons.fastfood, size: 40, color: Colors.deepOrange),
                          title: Text(lanche.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(lanche.precoFormatado),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              carrinho.removerLanche(lanche);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${lanche.nome} removido do carrinho!')),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'R\$ ${carrinho.valorTotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (carrinho.itens.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pedido finalizado!')),
                              );
                              carrinho.limparCarrinho(); // Limpa o carrinho após finalizar
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Adicione itens ao carrinho para finalizar o pedido!')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Finalizar Pedido',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}