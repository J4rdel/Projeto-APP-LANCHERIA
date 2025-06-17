import 'package:flutter/material.dart';
import 'package:lancheria/sobremesa.dart';
import 'package:lancheria/app_config.dart';

class SobremesasPage extends StatefulWidget {
  final Future<List<Sobremesa>> Function() fetchSobremesas;

  const SobremesasPage({super.key, required this.fetchSobremesas});

  @override
  State<SobremesasPage> createState() => _SobremesasPageState();
}

class _SobremesasPageState extends State<SobremesasPage> {
  late Future<List<Sobremesa>> _sobremesasFuture;

  @override
  void initState() {
    super.initState();
    _sobremesasFuture = widget.fetchSobremesas();
  }

  @override
  Widget build(BuildContext context) {
    final String currency = AppConfig.instance.currencySymbol;

    return FutureBuilder<List<Sobremesa>>(
      future: _sobremesasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar sobremesas: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhuma sobremesa disponível no momento.'));
        }

        final sobremesas = snapshot.data!;
        return ListView.builder(
          itemCount: sobremesas.length,
          itemBuilder: (context, index) {
            final sobremesa = sobremesas[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              elevation: 2,
              child: ListTile(
                leading: sobremesa.imagemUrl != null && sobremesa.imagemUrl!.isNotEmpty
                    ? Image.asset(sobremesa.imagemUrl!, width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (ctx, err, st) => const Icon(Icons.cake, size: 40))
                    : const Icon(Icons.cake, size: 40, color: Colors.grey),
                title: Text(sobremesa.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(sobremesa.descricao ?? 'Detalhes não disponíveis.'),
                trailing: Text('$currency ${sobremesa.preco.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green)),
              ),
            );
          },
        );
      },
    );
  }
}
