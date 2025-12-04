import 'package:flutter/material.dart';

/// Um card reutilizável para exibir um produto no cardápio.
///
/// Este widget é projetado para ser flexível e pode ser usado para
/// lanches, bebidas, sobremesas, etc.
class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String description;
  final String price;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      clipBehavior: Clip.antiAlias, // Garante que a imagem respeite as bordas arredondadas
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem do Produto (maior)
          SizedBox(
            width: 160, // Largura aumentada para a imagem
            height: 160, // Altura aumentada para a imagem
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              // Exibe um loader enquanto a imagem carrega
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              // Exibe um ícone de erro se a imagem falhar ao carregar
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[400],
                    size: 50,
                  ),
                );
              },
            ),
          ),
          // Informações do Produto
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8.0),
                  Text(description, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(price, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        onPressed: onAddToCart,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Adicionar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}