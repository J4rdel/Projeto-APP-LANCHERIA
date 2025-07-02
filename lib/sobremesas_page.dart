import 'package:flutter/material.dart';
import 'package:lancheria/sobremesa.dart';
import 'package:lancheria/app_config.dart';
import 'package:provider/provider.dart';
import 'package:lancheria/carrinho.dart';

class SobremesasPage extends StatefulWidget {
  final Future<List<Sobremesa>> Function() fetchSobremesas;
  final VoidCallback? onViewCart;

  const SobremesasPage({
    super.key,
    required this.fetchSobremesas,
    this.onViewCart,
  });

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
          return const Center(
            child: CircularProgressIndicator(color: Colors.deepOrange),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar sobremesas: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Nenhuma sobremesa disponível no momento.'),
          );
        }

        final sobremesas = snapshot.data!;
        return ListView.builder(
          itemCount: sobremesas.length,
          itemBuilder: (context, index) {
            final sobremesa = sobremesas[index];
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
                ),
                leading: SizedBox(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: sobremesa.imagemUrl.isNotEmpty
                        // A API retorna uma URL, então usamos Image.network
                        ? Image.network(
                            sobremesa.imagemUrl,
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
                                  Icons.cake,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                          )
                        // Caso a URL da imagem esteja vazia, exibe um ícone padrão
                        : const Icon(Icons.cake, size: 40, color: Colors.grey),
                  ),
                ),
                title: Text(
                  sobremesa.nome,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                // O campo 'descricao' no modelo Sobremesa não é nulo,
                // então a verificação '??' não é necessária.
                subtitle: Text(sobremesa.descricao),
                trailing: Text(
                  '$currency ${sobremesa.preco.toStringAsFixed(2)}',
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
                  ).adicionarItem(sobremesa);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${sobremesa.nome} adicionada ao carrinho!',
                      ),
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
