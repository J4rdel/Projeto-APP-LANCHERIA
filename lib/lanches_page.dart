import 'package:flutter/material.dart';
import 'package:lancheria/lanche.dart';
import 'package:lancheria/app_config.dart'; // Para o símbolo da moeda, se necessário
import 'package:provider/provider.dart';
import 'package:lancheria/carrinho.dart';

class LanchesPage extends StatefulWidget {
  final Future<List<Lanche>> Function() fetchLanches;
  final VoidCallback? onViewCart;

  const LanchesPage({super.key, required this.fetchLanches, this.onViewCart});

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
          return const Center(
            child: CircularProgressIndicator(color: Colors.deepOrange),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar lanches: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Nenhum lanche disponível no momento.'),
          );
        }

        final lanches = snapshot.data!;
        return ListView.builder(
          itemCount: lanches.length,
          itemBuilder: (context, index) {
            final lanche = lanches[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0,
              ),
              elevation: 2,
              // Ajuste o padding do ListTile se a imagem maior precisar de mais espaço
              // ou considere usar um Row/Column dentro do ListTile.content para mais controle.
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 16.0,
                ), // Aumenta o padding vertical
                leading:
                    lanche.imagemUrl != null && lanche.imagemUrl!.isNotEmpty
                    ? SizedBox(
                        // Usar SizedBox para restringir o tamanho da imagem
                        width: 80, // Largura aumentada
                        height: 80, // Altura aumentada
                        child: Image.asset(
                          lanche.imagemUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Icon(
                            Icons.broken_image, // Ou Icons.fastfood se preferir
                            size: 50,
                            color:
                                Theme.of(
                                  context,
                                ).iconTheme.color?.withOpacity(0.6) ??
                                Colors.grey,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.fastfood,
                        size: 50,
                        color: Theme.of(
                          context,
                        ).iconTheme.color?.withOpacity(0.6),
                      ), // Ícone maior
                title: Text(
                  lanche.nome,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(lanche.descricao ?? 'Detalhes não disponíveis.'),
                trailing: Text(
                  '$currency ${lanche.preco.toStringAsFixed(2)}',
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
                  ).adicionarItem(lanche);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${lanche.nome} adicionado ao carrinho!'),
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
