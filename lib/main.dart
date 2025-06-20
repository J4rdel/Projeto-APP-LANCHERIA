import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'carrinho.dart';
import 'gerenciador_pedidos.dart'; // Adicionado
import 'package:firebase_core/firebase_core.dart'; // Importar Firebase Core
import 'firebase_options.dart'; // Importar as opções de configuração do Firebase
import 'app_config.dart'; // Importar AppConfig
import 'theme_manager.dart'; // Importar ThemeManager

void main() async {
  // 1. Transforme main em async
  WidgetsFlutterBinding.ensureInitialized(); // 2. Garanta que os bindings do Flutter estão inicializados
  await Firebase.initializeApp(
    // 3. Inicialize o Firebase
    options: DefaultFirebaseOptions
        .currentPlatform, // Use as opções geradas pelo FlutterFire CLI
  );

  // Carrega o ThemeMode salvo antes de rodar o app
  final initialThemeMode = await ThemeManager.loadThemeMode();
  // Atualiza o AppConfig com o tema inicial carregado para consistência
  AppConfig.instance.updateActiveThemeMode(initialThemeMode);

  runApp(
    LancheriaApp(initialThemeMode: initialThemeMode),
  ); // Passa o tema inicial para o widget
}

class LancheriaApp extends StatelessWidget {
  final ThemeMode initialThemeMode;
  const LancheriaApp({super.key, required this.initialThemeMode});

  @override
  Widget build(BuildContext context) {
    // final AppConfig appConfig = AppConfig.instance; // appConfig será acessado dentro do Consumer se necessário ou via ThemeData
    // A instância do AppConfig é um Singleton, pode ser acessada diretamente
    // final AppConfig appConfig = AppConfig.instance; // Removido pois appConfig é acessado dentro do Consumer ou não é necessário aqui diretamente
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Carrinho()),
        ChangeNotifierProvider(create: (context) => GerenciadorPedidos()),
        ChangeNotifierProvider(
          create: (context) => ThemeManager(
            initialThemeMode,
          ), // Corrigido: Acessar initialThemeMode diretamente
        ),
      ],
      child: Consumer<ThemeManager>(
        // Usar Consumer para reconstruir MaterialApp na mudança de tema
        builder: (context, themeManager, child) {
          final AppConfig appConfig = AppConfig
              .instance; // Pode pegar a instância aqui se precisar para o title
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: appConfig.establishmentName,
            theme: _buildThemeData(
              AppConfig.lightThemeColors,
              appConfig, // appConfig ainda é útil para _buildThemeData se ele usa outras configs
            ), // Tema claro usa AppConfig.lightThemeColors
            darkTheme: _buildThemeData(
              AppConfig.darkThemeColors,
              appConfig, // Tema escuro usa AppConfig.darkThemeColors
            ),
            themeMode:
                themeManager.themeMode, // Usar o themeMode do ThemeManager
            home: const HomePage(),
          );
        },
      ),
    );
  }
}

// Função auxiliar para criar um ThemeData a partir de AppThemeColors
ThemeData _buildThemeData(AppThemeColors themeColors, AppConfig appConfig) {
  return ThemeData(
    brightness: themeColors.brightness,
    primarySwatch: _createMaterialColor(themeColors.primaryColor),
    scaffoldBackgroundColor: themeColors.scaffoldBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: themeColors.primaryColor,
      foregroundColor: themeColors.appBarTextColor,
      elevation: 4.0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: themeColors.primaryColor,
        foregroundColor: themeColors.buttonTextColor,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        color: themeColors.primaryTextColor,
        fontFamily: themeColors.mainFontFamily, // Usar a fonte principal
      ),
      bodyMedium: TextStyle(
        color: themeColors.primaryTextColor,
        fontFamily: themeColors.mainFontFamily, // Usar a fonte principal
      ),
      titleLarge: TextStyle(
        color: themeColors.primaryTextColor,
        fontWeight: FontWeight.bold,
        fontFamily: themeColors.headlineFontFamily, // Usar a fonte de título
      ),
      titleMedium: TextStyle(
        color: themeColors.primaryTextColor,
        fontFamily: themeColors.headlineFontFamily, // Usar a fonte de título
      ),
      titleSmall: TextStyle(
        color: themeColors.secondaryTextColor,
        fontFamily: themeColors.mainFontFamily,
      ),
      labelLarge: TextStyle(
        color: themeColors.buttonTextColor,
        fontFamily: themeColors.mainFontFamily,
      ),
    ),
    iconTheme: IconThemeData(color: themeColors.iconColor),
    listTileTheme: ListTileThemeData(
      iconColor: themeColors.iconColor,
      textColor: themeColors.primaryTextColor,
      selectedColor: themeColors.selectedItemTextColor,
      selectedTileColor: themeColors.selectedItemColor,
    ),
    dividerTheme: DividerThemeData(
      color: themeColors.secondaryTextColor.withOpacity(0.5),
      thickness: 1,
    ),
    colorScheme: ColorScheme(
      primary: themeColors.primaryColor,
      secondary:
          themeColors.accentColor, // accentColor é o antigo nome para secondary
      surface:
          themeColors.scaffoldBackgroundColor, // Usado por Cards, Dialogs, etc.
      background: themeColors.scaffoldBackgroundColor,
      error: Colors.red.shade700, // Defina uma cor de erro padrão
      onPrimary: themeColors
          .appBarTextColor, // Cor do texto/ícones sobre a cor primária
      onSecondary: themeColors
          .buttonTextColor, // Cor do texto/ícones sobre a cor secundária
      onSurface: themeColors
          .primaryTextColor, // Cor do texto/ícones sobre a cor de superfície
      onBackground: themeColors
          .primaryTextColor, // Cor do texto/ícones sobre a cor de fundo
      onError: Colors.white, // Cor do texto/ícones sobre a cor de erro
      brightness: themeColors.brightness,
    ),
    // Se você ainda usa accentColor diretamente em algum lugar (obsoleto):
    // accentColor: themeColors.accentColor,
  );
}

// Função auxiliar para criar um MaterialColor a partir de uma única Color
// Esta função permanece a mesma da sua versão anterior.
MaterialColor _createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}
