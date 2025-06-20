import 'package:flutter/material.dart';
import 'package:lancheria/lanches_page.dart';
import 'package:lancheria/drinks_page.dart';
import 'package:lancheria/sobremesas_page.dart';
import 'package:lancheria/minha_conta_page.dart';
import 'package:lancheria/gerenciamento_pedidos_page.dart';
import 'package:lancheria/app_config.dart'; // Importar AppConfig
import 'package:lancheria/carrinho_page.dart'; // Importar CarrinhoPage
import 'package:lancheria/avaliar_local_page.dart'; // Importar AvaliarLocalPage
import 'package:provider/provider.dart'; // Importar Provider
import 'package:lancheria/theme_manager.dart'; // Importar ThemeManager

enum ContentView {
  lanches,
  drinks,
  sobremesas,
  carrinho, // Nova visualização para o carrinho
  avaliarLocal,
  minhaConta,
  gestaoPedidos,
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContentView _selectedContentView = ContentView.lanches; // Default view
  late Widget _currentRightPanelContent;
  final AppConfig _appConfig =
      AppConfig.instance; // Cache da instância do AppConfig

  void _showGarcomSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Garçom chamado! Em breve alguém virá te atender.'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          // A cor do texto do SnackBarAction pode ser personalizada se necessário
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
    _currentRightPanelContent = _getPageForView(_selectedContentView);
  }

  // Retorna o widget de conteúdo para a visualização selecionada.
  // As páginas (LanchesPage, etc.) não devem ter seu próprio Scaffold aqui.
  Widget _getPageForView(ContentView view) {
    switch (view) {
      case ContentView.lanches:
        return LanchesPage(
          fetchLanches: _appConfig.getLanches, // Usar _appConfig
          onViewCart: () => _selectContentView(ContentView.carrinho),
        ); // Usar _appConfig
      case ContentView.drinks:
        return DrinksPage(
          fetchDrinks: _appConfig.getDrinks, // Usar _appConfig
          onViewCart: () => _selectContentView(ContentView.carrinho),
        );
      case ContentView.sobremesas:
        return SobremesasPage(
          fetchSobremesas: _appConfig.getSobremesas, // Usar _appConfig
          onViewCart: () => _selectContentView(ContentView.carrinho),
        );
      case ContentView.carrinho:
        return const CarrinhoPage();
      case ContentView.avaliarLocal:
        return const AvaliarLocalPage(); // Deve ser ajustada para não ter Scaffold
      case ContentView.minhaConta:
        return const MinhaContaPage(); // Deve ser ajustada para não ter Scaffold
      case ContentView.gestaoPedidos:
        return const GerenciamentoPedidosPage(); // Deve ser ajustada para não ter Scaffold
    }
  }

  // Atualiza a visualização do produto e o conteúdo do painel direito
  void _selectContentView(ContentView view) {
    setState(() {
      _selectedContentView = view;
      _currentRightPanelContent = _getPageForView(view);
    });
    // Se estiver em uma tela menor e o drawer estiver aberto, feche-o.
    // Isso é mais relevante se você usar um Drawer em vez de um painel lateral fixo.
    // if (Scaffold.of(context).isDrawerOpen) {
    //   Navigator.of(context).pop();
    // }
  }

  @override
  Widget build(BuildContext context) {
    // Acessa o ThemeManager para determinar o ícone e texto do botão de tema
    final themeManager = Provider.of<ThemeManager>(context);
    final bool isDarkMode = themeManager.themeMode == ThemeMode.dark;

    return Scaffold(
      // A cor de fundo do Scaffold virá do theme: scaffoldBackgroundColor
      appBar: AppBar(
        title: Text(
          'Cardápio ${_appConfig.establishmentName}',
        ), // Usar nome do AppConfig
        // backgroundColor e foregroundColor virão do appBarTheme no main.dart
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDarkMode
                ? 'Mudar para Tema Claro'
                : 'Mudar para Tema Escuro',
            onPressed: () {
              themeManager.toggleTheme();
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Painel Esquerdo (Navegação)
          Container(
            width: 280, // Ajuste a largura conforme necessário
            // A cor do painel lateral agora vem das cores do tema atual
            color: _appConfig.currentThemeColors.leftPanelBackgroundColor,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 16.0,
                  ),
                  child: Column(
                    children: [
                      if (_appConfig.logoAssetPath.isNotEmpty)
                        Image.asset(
                          _appConfig.logoAssetPath, // Usar logo do AppConfig
                          height: 80,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.storefront,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary
                                .withOpacity(0.7), // Cor do tema para fallback
                          ),
                        )
                      else
                        Icon(
                          Icons.storefront,
                          size: 80,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.7),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        'Bem-vindo!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary, // Usar cor primária do tema
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
                      _buildLeftPanelItem(
                        'LANCHES',
                        Icons.fastfood,
                        ContentView.lanches,
                      ),
                      _buildLeftPanelItem(
                        'DRINKS',
                        Icons.local_drink,
                        ContentView.drinks,
                      ),
                      _buildLeftPanelItem(
                        'SOBREMESAS',
                        Icons.cake,
                        ContentView.sobremesas,
                      ),
                      _buildLeftPanelItem(
                        // Item para o Carrinho
                        'CARRINHO',
                        Icons.shopping_cart_outlined,
                        ContentView.carrinho,
                      ),
                      const Divider(
                        height: 24,
                        indent: 16,
                        endIndent: 16,
                      ), // Cor e espessura do DividerTheme
                      _buildLeftPanelItem(
                        'AVALIAR LOCAL',
                        Icons.star_border_outlined,
                        ContentView.avaliarLocal,
                      ),
                      _buildLeftPanelItem(
                        'MINHA CONTA',
                        Icons.person_outline,
                        ContentView.minhaConta,
                      ),
                      _buildLeftPanelItem(
                        'GESTÃO DE PEDIDOS',
                        Icons.article_outlined,
                        ContentView.gestaoPedidos,
                      ),
                      const Divider(
                        height: 24,
                        indent: 16,
                        endIndent: 16,
                      ), // Cor e espessura do DividerTheme
                      _buildLeftPanelActionItem(
                        'CHAMAR GARÇOM',
                        Icons.notifications_active_outlined,
                        () {
                          _showGarcomSnackBar(context);
                        },
                      ),
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
              child: AnimatedSwitcher(
                // Adiciona uma transição suave ao mudar o conteúdo
                duration: const Duration(milliseconds: 300),
                child: _currentRightPanelContent, // Exibe o conteúdo dinâmico
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método unificado para construir itens do painel esquerdo que mudam o conteúdo do painel direito
  Widget _buildLeftPanelItem(String title, IconData icon, ContentView view) {
    bool isSelected = _selectedContentView == view;
    // As cores (texto, ícone, fundo selecionado) virão do ListTileTheme definido no main.dart
    return Material(
      color: Colors
          .transparent, // Deixa o ListTile controlar sua cor de fundo (incluindo selectedTileColor)
      child: ListTile(
        leading: Icon(icon, size: 26), // Cor gerenciada pelo ListTileTheme
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
            // Cor gerenciada pelo ListTileTheme (textColor para não selecionado, selectedColor para selecionado)
          ),
        ),
        onTap: () => _selectContentView(view),
        selected: isSelected,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 8.0,
        ),
      ),
    );
  }

  // Método para construir itens do painel esquerdo que executam uma ação
  Widget _buildLeftPanelActionItem(
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, size: 26), // Cor do ListTileTheme.iconColor
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
          ), // Cor do ListTileTheme.textColor
        ),
        onTap: onPressed,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 8.0,
        ),
      ),
    );
  }
}
