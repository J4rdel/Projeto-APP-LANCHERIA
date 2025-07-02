import 'package:flutter/material.dart';
import 'package:lancheria/lanche.dart';
import 'package:lancheria/drink.dart';
import 'package:lancheria/sobremesa.dart';
import 'package:lancheria/api_service.dart'; // Importe o novo serviço

// Classe para encapsular as cores de um tema específico
class AppThemeColors {
  final Color primaryColor;
  final Color accentColor; // No Flutter moderno, ColorScheme.secondary
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color appBarTextColor;
  final Color buttonTextColor;
  final Color scaffoldBackgroundColor;
  final Color
  leftPanelBackgroundColor; // Cor específica para o painel lateral da HomePage
  final Color iconColor;
  final Color selectedItemColor;
  final Color selectedItemTextColor;
  final Brightness brightness; // Essencial para ThemeData (light/dark)
  final String? mainFontFamily; // Opcional: fonte principal
  final String? headlineFontFamily; // Opcional: fonte para títulos

  const AppThemeColors({
    required this.primaryColor,
    required this.accentColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.appBarTextColor,
    required this.buttonTextColor,
    required this.scaffoldBackgroundColor,
    required this.leftPanelBackgroundColor,
    required this.iconColor,
    required this.selectedItemColor,
    required this.selectedItemTextColor,
    required this.brightness,
    this.mainFontFamily,
    this.headlineFontFamily,
  });
}

class AppConfig {
  // Construtor privado para o padrão Singleton
  AppConfig._privateConstructor();

  // Instância estática única
  static final AppConfig _instance = AppConfig._privateConstructor();

  // Acessor público para a instância
  static AppConfig get instance => _instance;

  // --- DADOS CONFIGURÁVEIS DO ESTABELECIMENTO ---
  String establishmentName = 'Lancheria Padrão';
  String logoAssetPath =
      'assets/images/logo_padrao.png'; // Caminho para a logo principal
  String currencySymbol = 'R\$';

  // Chaves de API (substitua pelas suas chaves reais ou deixe como placeholder)
  String apiKey1 = 'SUA_API_KEY_1_AQUI';
  String apiKey2 = 'SUA_API_KEY_2_AQUI';

  // Senha/PIN mestre para o gerente realizar configurações críticas (como mudar mesa)
  String gerenteMasterPin = '1234'; // Mantenha seguro em produção!

  // --- FONTES DE DADOS PARA PRODUTOS ---
  // Agora, apontam para os métodos do ApiService que buscam dados reais.
  Future<List<Lanche>> Function() getLanches = ApiService.fetchLanches;
  Future<List<Drink>> Function() getDrinks = ApiService.fetchDrinks;
  Future<List<Sobremesa>> Function() getSobremesas = ApiService.fetchSobremesas;

  // --- CONFIGURAÇÃO DE TEMAS ---
  ThemeMode activeThemeMode =
      ThemeMode.light; // Pode ser .light, .dark, ou .system

  // Definição do Tema Claro (usando as cores que você já tinha definido)
  static final AppThemeColors lightThemeColors = AppThemeColors(
    primaryColor: Colors.deepOrange,
    accentColor: Colors.amber,
    primaryTextColor: Colors.black87,
    secondaryTextColor: Colors.grey.shade700,
    appBarTextColor: Colors.white,
    buttonTextColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    leftPanelBackgroundColor: Colors.grey.shade100,
    iconColor: Colors.grey.shade700,
    selectedItemColor: Colors.deepOrange.shade700,
    selectedItemTextColor: Colors.white,
    brightness: Brightness.light,
    mainFontFamily: 'Roboto', // Exemplo
    headlineFontFamily: 'RobotoSlab', // Exemplo
  );

  // Definição do Tema Escuro (Exemplo - ajuste as cores conforme sua preferência)
  static final AppThemeColors darkThemeColors = AppThemeColors(
    primaryColor: Colors.blueGrey.shade700,
    accentColor: Colors.tealAccent.shade400,
    primaryTextColor: Colors.white.withOpacity(0.90),
    secondaryTextColor: Colors.white.withOpacity(0.70),
    appBarTextColor: Colors.white,
    buttonTextColor: Colors
        .white, // Ajustado para branco para melhor contraste com botões escuros
    scaffoldBackgroundColor: Colors.black, // Fundo realmente PRETO
    leftPanelBackgroundColor:
        Colors.grey.shade900, // Um cinza bem escuro para o painel
    iconColor: Colors.white.withOpacity(0.75),
    selectedItemColor: Colors.blueGrey.shade500,
    selectedItemTextColor: Colors.white,
    brightness: Brightness.dark,
    mainFontFamily: 'Roboto', // Exemplo
    headlineFontFamily: 'RobotoSlab', // Exemplo
  );

  // Método para obter as cores do tema ativo (útil para acesso direto fora do ThemeData)
  AppThemeColors get currentThemeColors {
    // Se activeThemeMode for system, o MaterialApp lida com isso.
    // Esta função é um atalho para quando você precisa das cores diretamente.
    // Para uma implementação completa de ThemeMode.system aqui, seria necessário detectar o tema do SO.
    return activeThemeMode == ThemeMode.dark
        ? darkThemeColors
        : lightThemeColors;
  }

  // Método para inicializar configurações (opcional, pode ser expandido no futuro)
  void initialize() {
    // Aqui você poderia carregar configurações de um arquivo, variáveis de ambiente, etc.
    // print('AppConfig inicializado para: ${instance.establishmentName}');
  }

  // Método para ser chamado pelo ThemeManager para manter AppConfig sincronizado
  void updateActiveThemeMode(ThemeMode mode) {
    activeThemeMode = mode;
    // Não é necessário notifyListeners() aqui, pois AppConfig não é um ChangeNotifier.
  }

  // --- ACESSO DIRETO ÀS CORES DO TEMA ATUAL ---
  // Estes getters fornecem acesso conveniente às cores do tema ativo (light/dark).
  // Útil se você precisar acessar uma cor do tema atual fora do contexto de um Widget
  // que tenha acesso ao ThemeData (ex: Theme.of(context).colorScheme.primary).
  Color get primaryColor => currentThemeColors.primaryColor;
  Color get accentColor => currentThemeColors.accentColor;
  Color get primaryTextColor => currentThemeColors.primaryTextColor;
  Color get secondaryTextColor => currentThemeColors.secondaryTextColor;
  Color get appBarTextColor => currentThemeColors.appBarTextColor;
  Color get buttonTextColor => currentThemeColors.buttonTextColor;
  Color get scaffoldBackgroundColor =>
      currentThemeColors.scaffoldBackgroundColor;
  Color get leftPanelBackgroundColor =>
      currentThemeColors.leftPanelBackgroundColor;
  Color get iconColor => currentThemeColors.iconColor;
  Color get selectedItemColor => currentThemeColors.selectedItemColor;
  Color get selectedItemTextColor => currentThemeColors.selectedItemTextColor;
  Brightness get brightness => currentThemeColors.brightness;
  String? get mainFontFamily => currentThemeColors.mainFontFamily;
  String? get headlineFontFamily => currentThemeColors.headlineFontFamily;
}
