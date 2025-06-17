import 'package:flutter/material.dart';
import 'package:lancheria/drink.dart';
import 'package:lancheria/app_config.dart';

class DrinksPage extends StatefulWidget {
  final Future<List<Drink>> Function() fetchDrinks;

  const DrinksPage({super.key, required this.fetchDrinks});

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
          return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar drinks: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhum drink disponível no momento.'));
        }

        final drinks = snapshot.data!;
        return ListView.builder(
          itemCount: drinks.length,
          itemBuilder: (context, index) {
            final drink = drinks[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              elevation: 2,
              child: ListTile(
                leading: drink.imagemUrl != null && drink.imagemUrl!.isNotEmpty
                    ? Image.asset(drink.imagemUrl!, width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (ctx, err, st) => const Icon(Icons.local_drink, size: 40))
                    : const Icon(Icons.local_drink, size: 40, color: Colors.grey),
                title: Text(drink.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(drink.descricao ?? 'Detalhes não disponíveis.'),
                trailing: Text('$currency ${drink.preco.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green)),
              ),
            );
          },
        );
      },
    );
  }
}
