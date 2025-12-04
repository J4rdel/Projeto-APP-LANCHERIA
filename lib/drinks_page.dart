import 'package:flutter/material.dart';
import 'package:lancheria/drink.dart';
import 'package:lancheria/app_config.dart';
import 'package:provider/provider.dart';
import 'package:lancheria/carrinho.dart';
import 'package:lancheria/produto.dart';
import 'package:lancheria/opcional.dart';
import 'product_card.dart'; // Importa o novo widget de card

class DrinksPage extends StatefulWidget {
  final Future<List<Drink>> Function() fetchDrinks;
  final VoidCallback? onViewCart;

  const DrinksPage({super.key, required this.fetchDrinks, this.onViewCart});

  @override
  State<DrinksPage> createState() => _DrinksPageState();
}

class _DrinksPageState extends State<DrinksPage> {
  late Future<List<Drink>> _drinksFuture;

  @override
  void initState() {
    super.initState();
    _drinksFuture = widget.fetchDrinks();
  }

  void _showProductPreview(BuildContext context, Produto produto) {
    final String currency = AppConfig.instance.currencySymbol;
    final List<Opcional> opcionaisSelecionados = [];
    int quantidade = 1;

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        // Usamos StatefulBuilder para gerenciar o estado dos checkboxes dentro do diálogo
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              // Aumenta o padding para dar mais espaço ao conteúdo
              contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              // Remove o título padrão para dar mais espaço vertical ao conteúdo
              title: Text(produto.nome, style: Theme.of(context).textTheme.titleLarge),
              content: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coluna da Esquerda (Imagem)
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: produto.imagemUrl.isNotEmpty
                              ? Image.network(
                                  produto.imagemUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image,
                                          size: 60, color: Colors.grey),
                                )
                              : const Icon(Icons.local_drink,
                                  size: 60, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Coluna da Direita (Detalhes)
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            produto.descricao,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$currency ${produto.preco.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Seletor de Quantidade
                          Row(
                            children: [
                              const Text('Qtd:', style: TextStyle(fontSize: 16)),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  if (quantidade > 1) {
                                    setState(() => quantidade--);
                                  }
                                },
                              ),
                              Text('$quantidade', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => setState(() => quantidade++),
                              ),
                            ],
                          ),
                          if (produto.opcionais.isNotEmpty) ...[
                            const Divider(),
                            const Text('Adicionais', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ...produto.opcionais.map((opcional) {
                              return CheckboxListTile(
                                title: Text(opcional.nome, style: const TextStyle(fontSize: 14)),
                                subtitle: Text('+ $currency ${opcional.precoAdicional.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                                value: opcionaisSelecionados.contains(opcional),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      opcionaisSelecionados.add(opcional);
                                    } else {
                                      opcionaisSelecionados.remove(opcional);
                                    }
                                  });
                                },
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              );
                            }).toList(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Fechar'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                ElevatedButton(
                  child: const Text('Adicionar ao Carrinho'),
                  onPressed: () {
                    _addToCart(context, produto, quantidade,
                        opcionais: opcionaisSelecionados);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currency = AppConfig.instance.currencySymbol;

    return FutureBuilder<List<Drink>>(
      future: _drinksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.deepOrange),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar drinks: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Nenhum drink disponível no momento.'),
          );
        }

        final drinks = snapshot.data!;
        // Substitui o ListView.builder por um que usa o ProductCard
        return ListView.separated(
          padding: const EdgeInsets.all(8.0),
          itemCount: drinks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8), // Espaçamento entre os cards
          itemBuilder: (BuildContext context, int index) {
            final drink = drinks[index];
            return GestureDetector(
              onTap: () => _showProductPreview(context, drink),
              child: ProductCard(
                imageUrl: drink.imagemUrl,
                name: drink.nome,
                description: drink.descricao,
                price: '$currency ${drink.preco.toStringAsFixed(2)}',
                onAddToCart: () {
                  _addToCart(context, drink, 1);
                },
              ),
            );
          },
        );
      },
    );
  }
  
  void _addToCart(BuildContext context, Produto produto, int quantidade,
      {List<Opcional> opcionais = const []}) {
    Provider.of<Carrinho>(context, listen: false)
        .adicionarItem(produto, quantidade: quantidade, opcionais: opcionais);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${produto.nome} adicionado ao carrinho!'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'VER CARRINHO',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            widget.onViewCart?.call();
          },
        ),
      ),
    );
  }
}
