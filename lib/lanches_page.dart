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
                leading: SizedBox(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: lanche.imagemUrl.isNotEmpty
                        // A API retorna uma URL, então usamos Image.network
                        ? Image.network(
                            lanche.imagemUrl,
                            fit: BoxFit.cover,
                            // Widget a ser exibido enquanto a imagem está carregando
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.deepOrange,
                                ),
                              );
                            },
                            // Widget a ser exibido em caso de erro ao carregar a imagem
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.fastfood,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                          )
                        // Caso a URL da imagem esteja vazia, exibe um ícone padrão
                        : const Icon(
                            Icons.fastfood,
                            size: 40,
                            color: Colors.grey,
                          ),
                  ),
                ),
                title: Text(
                  lanche.nome,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(lanche.descricao),
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
