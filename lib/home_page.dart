import 'package:flutter/material.dart';
import 'package:lancheria/lanches_page.dart';
import 'package:lancheria/drinks_page.dart';
import 'package:lancheria/sobremesas_page.dart';
import 'package:lancheria/minha_conta_page.dart';
import 'package:lancheria/gerenciamento_pedidos_page.dart';
import 'package:lancheria/app_config.dart'; // Importar AppConfig
import 'package:lancheria/avaliar_local_page.dart';



enum ProductView { lanches, drinks, sobremesas }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ProductView _selectedProductView = ProductView.lanches; // Default view
  late Widget _currentRightPanelContent;

  void _showGarcomSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Garçom chamado! Em breve alguém virá te atender.'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Inicializa o conteúdo do painel direito com a visualização padrão
    _currentRightPanelContent = _getPageForView(_selectedProductView);
  }

  // Retorna o widget de conteúdo para a visualização selecionada
  // IMPORTANTE: LanchesPage, DrinksPage, SobremesasPage idealmente não devem ter seu próprio Scaffold
  // para serem embutidas corretamente aqui. Elas devem ser widgets de conteúdo.
  Widget _getPageForView(ProductView view) {
    switch (view) {
      case ProductView.lanches:
        return LanchesPage(fetchLanches: AppConfig.instance.getLanches);
      case ProductView.drinks:
        return DrinksPage(fetchDrinks: AppConfig.instance.getDrinks);
      case ProductView.sobremesas:
        return SobremesasPage(fetchSobremesas: AppConfig.instance.getSobremesas);
    }
  }

  // Atualiza a visualização do produto e o conteúdo do painel direito
  void _selectProductView(ProductView view) {
    setState(() {
      _selectedProductView = view;
      _currentRightPanelContent = _getPageForView(view);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cardápio ${AppConfig.instance.establishmentName}'), // Usar nome do AppConfig
        backgroundColor: Colors.deepOrange,
        // Você pode adicionar um ícone de carrinho aqui depois, se desejar
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.shopping_cart),
        //     onPressed: () {
        //       Navigator.push(context, MaterialPageRoute(builder: (context) => const CarrinhoPage()));
        //     },
        //   ),
        // ],
      ),
      body: Row(
        children: [
          // Painel Esquerdo (Navegação)
          Container(
            width: 280, // Ajuste a largura conforme necessário
            color: Colors.grey[100], // Um fundo sutil para o painel
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      Image.asset(
                        AppConfig.instance.logoAssetPath, // Usar logo do AppConfig
                        height: 80,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.storefront, size: 80, color: Colors.brown), // Fallback
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Bem-vindo!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    children: [
                      _buildLeftPanelProductItem('LANCHES', Icons.fastfood, ProductView.lanches),
                      _buildLeftPanelProductItem('DRINKS', Icons.local_drink, ProductView.drinks),
                      _buildLeftPanelProductItem('SOBREMESAS', Icons.cake, ProductView.sobremesas),
                      const Divider(height: 24, thickness: 1, indent: 16, endIndent: 16),
                      _buildLeftPanelNavigationItem('AVALIAR LOCAL', Icons.star_border_outlined, () => const AvaliarLocalPage()),
                      _buildLeftPanelNavigationItem('MINHA CONTA', Icons.person_outline, () => const MinhaContaPage()),
                      _buildLeftPanelNavigationItem('GESTÃO DE PEDIDOS', Icons.article_outlined, () => const GerenciamentoPedidosPage()),
                      const Divider(height: 24, thickness: 1, indent: 16, endIndent: 16),
                      _buildLeftPanelActionItem('CHAMAR GARÇOM', Icons.notifications_active_outlined, () {
                        _showGarcomSnackBar(context);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Painel Direito (Conteúdo)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedSwitcher( // Adiciona uma transição suave ao mudar o conteúdo
                duration: const Duration(milliseconds: 300),
                child: _currentRightPanelContent, // Exibe o conteúdo dinâmico
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método para construir itens do painel esquerdo que mudam o conteúdo do painel direito
  Widget _buildLeftPanelProductItem(String title, IconData icon, ProductView view) {
    bool isSelected = _selectedProductView == view;
    return Material(
      color: isSelected ? Colors.deepOrange : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.deepOrange : Colors.grey[700], size: 26),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.deepOrange : Colors.black87,
            fontSize: 16,
          ),
        ),
        onTap: () => _selectProductView(view),
        selected: isSelected,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      ),
    );
  }

  // Método para construir itens do painel esquerdo que navegam para uma nova página
  Widget _buildLeftPanelNavigationItem(String title, IconData icon, Widget Function() pageBuilder) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[700], size: 26),
        title: Text(title, style: const TextStyle(color: Colors.black87, fontSize: 16)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => pageBuilder()),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      ),
    );
  }

  // Método para construir itens do painel esquerdo que executam uma ação
  Widget _buildLeftPanelActionItem(String title, IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[700], size: 26),
        title: Text(title, style: const TextStyle(color: Colors.black87, fontSize: 16)),
        onTap: onPressed,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      ),
    );
  }
}
