import 'package:flutter/material.dart';
import 'package:lancheria/lanche.dart';
import 'package:lancheria/app_config.dart'; // Para o símbolo da moeda, se necessário

class LanchesPage extends StatefulWidget {
  final Future<List<Lanche>> Function() fetchLanches;

  const LanchesPage({super.key, required this.fetchLanches});

  @override
  State<LanchesPage> createState() => _LanchesPageState();
}

class _LanchesPageState extends State<LanchesPage> {
  late Future<List<Lanche>> _lanchesFuture;

  @override
  void initState() {
    super.initState();
    _lanchesFuture = widget.fetchLanches();
  }

  @override
  Widget build(BuildContext context) {
    final String currency = AppConfig.instance.currencySymbol;

    return FutureBuilder<List<Lanche>>(
      future: _lanchesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar lanches: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhum lanche disponível no momento.'));
        }

        final lanches = snapshot.data!;
        return ListView.builder(
          itemCount: lanches.length,
          itemBuilder: (context, index) {
            final lanche = lanches[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              elevation: 2,
              child: ListTile(
                leading: lanche.imagemUrl != null && lanche.imagemUrl!.isNotEmpty
                    ? Image.asset(lanche.imagemUrl!, width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (ctx, err, st) => const Icon(Icons.fastfood, size: 40))
                    : const Icon(Icons.fastfood, size: 40, color: Colors.grey),
                title: Text(lanche.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(lanche.descricao ?? 'Detalhes não disponíveis.'),
                trailing: Text('$currency ${lanche.preco.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green)),
              ),
            );
          },
        );
      },
    );
  }
}
