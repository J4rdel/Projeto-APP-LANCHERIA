import 'package:flutter/material.dart';
import 'package:lancheria/sobremesa.dart';
import 'package:lancheria/app_config.dart';
import 'package:provider/provider.dart';
import 'package:lancheria/carrinho.dart';
import 'package:lancheria/produto.dart';
import 'package:lancheria/opcional.dart';

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

  void _showProductPreview(BuildContext context, Produto produto) {
    final String currency = AppConfig.instance.currencySymbol;
    final List<Opcional> opcionaisSelecionados = [];

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        // Usamos StatefulBuilder para gerenciar o estado dos checkboxes dentro do diálogo
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(produto.nome),
              contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 180,
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
                                        size: 80, color: Colors.grey),
                              )
                            : const Icon(Icons.cake,
                                size: 80, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      produto.descricao,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$currency ${produto.preco.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (produto.opcionais.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Adicionais',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      ...produto.opcionais.map((opcional) {
                        return CheckboxListTile(
                          title: Text(opcional.nome),
                          subtitle: Text(
                              '+ $currency ${opcional.precoAdicional.toStringAsFixed(2)}'),
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
                        );
                      }).toList(),
                    ],
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
                    _addToCart(context, produto,
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
                  _showProductPreview(context, sobremesa);
                },
              ),
            );
          },
        );
      },
    );
  }

  void _addToCart(BuildContext context, Produto produto,
      {List<Opcional> opcionais = const []}) {
    Provider.of<Carrinho>(context, listen: false).adicionarItem(produto, opcionais: opcionais);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${produto.nome} adicionada ao carrinho!'),
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
