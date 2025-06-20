import 'package:flutter/material.dart';
import 'package:lancheria/drink.dart';
import 'package:lancheria/app_config.dart';
import 'package:provider/provider.dart';
import 'package:lancheria/carrinho.dart';

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
        return ListView.builder(
          itemCount: drinks.length,
          itemBuilder: (context, index) {
            final drink = drinks[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0,
              ),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 16.0,
                ), // Aumenta o padding vertical
                leading: drink.imagemUrl != null && drink.imagemUrl!.isNotEmpty
                    ? SizedBox(
                        // Usar SizedBox para restringir o tamanho da imagem
                        width: 80, // Largura aumentada
                        height: 80, // Altura aumentada
                        child: Image.asset(
                          drink.imagemUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => const Icon(
                            Icons.local_drink,
                            size: 50,
                          ), // Ícone de fallback maior
                        ),
                      )
                    : Icon(
                        Icons.local_drink,
                        size: 50,
                        color: Theme.of(
                          context,
                        ).iconTheme.color?.withOpacity(0.6),
                      ), // Ícone maior
                title: Text(
                  drink.nome,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(drink.descricao ?? 'Detalhes não disponíveis.'),
                trailing: Text(
                  '$currency ${drink.preco.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
                onTap: () {
                  Provider.of<Carrinho>(
                    context,
                    listen: false,
                  ).adicionarItem(drink);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${drink.nome} adicionado ao carrinho!'),
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
                },
              ),
            );
          },
        );
      },
    );
  }
}
