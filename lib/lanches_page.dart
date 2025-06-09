import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Adicionado
import 'lanche.dart'; // Adicionado
import 'carrinho.dart'; // Adicionado
import 'package:lancheria/carrinho_page.dart'; // Adicionado

class LanchesPage extends StatelessWidget {
  const LanchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de lanches com o novo modelo Lanche
    final List<Lanche> lanches = [
      Lanche(
        nome: 'X-Salada',
        preco: 15.00,
        descricao: 'Pão, hambúrguer, queijo, alface e tomate.',
        imagemUrl: '',
      ),
      Lanche(
        nome: 'X-Bacon',
        preco: 18.00,
        descricao: 'Pão, hambúrguer, queijo, bacon crocante.',
        imagemUrl: 'https://cdn.pixabay.com/photo/2018/03/24/16/09/x-burger-3257850_960_720.png', // Exemplo de imagem
      ),
      Lanche(
        nome: 'X-Frango',
        preco: 16.50,
        descricao: 'Pão, frango desfiado, queijo e catupiry.',
        imagemUrl: 'https://cdn.pixabay.com/photo/2018/03/24/16/09/x-burger-3257850_960_720.png',
      ),
      Lanche(
        nome: 'X-Calabresa',
        preco: 17.00,
        descricao: 'Pão, hambúrguer, queijo e calabresa frita.',
        imagemUrl: 'https://cdn.pixabay.com/photo/2018/03/24/16/09/x-burger-3257850_960_720.png',
      ),
      Lanche(
        nome: 'X-Tudo',
        preco: 22.00,
        descricao: 'Pão, dois hambúrgueres, ovo, bacon, queijo, alface, tomate e batata palha.',
        imagemUrl: 'https://cdn.pixabay.com/photo/2018/03/24/16/09/x-burger-3257850_960_720.png',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha seu lanche'),
        backgroundColor: Colors.deepOrange,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CarrinhoPage()),
                  );
                },
              ),
              // Exibe o número de itens no carrinho
              Positioned(
                right: 5,
                top: 5,
                child: Consumer<Carrinho>( // Correção: De CarrinhoPage para Carrinho
                  builder: (context, carrinho, child) {
                    return Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${carrinho.itens.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: lanches.length,
        itemBuilder: (context, index) {
          final lanche = lanches[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: lanche.imagemUrl != null && lanche.imagemUrl!.isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(lanche.imagemUrl!),
                      radius: 30,
                    )
                  : const Icon(Icons.fastfood, size: 50, color: Colors.deepOrange),
              title: Text(lanche.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(lanche.precoFormatado), // Exibindo o preço formatado
              trailing: IconButton(
                icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                onPressed: () {
                  // CORREÇÃO AQUI: De CarrinhoPage para Carrinho e de lanches para lanche
                  final carrinho = Provider.of<Carrinho>(context, listen: false);
                  carrinho.adicionarLanche(lanche);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${lanche.nome} adicionado ao carrinho!')),
                  );
                },
              ),
              // onTap: () {
              //   // Você pode adicionar uma tela de detalhes do lanche aqui
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(content: Text('Detalhes de ${lanche.nome}')),
              //   );
              // },
            ),
          );
        },
      ),
    );
  }
}