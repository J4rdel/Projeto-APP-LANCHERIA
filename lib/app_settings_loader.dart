import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_config.dart';

class AppSettingsLoader {
  static const String _themeModeKey = 'theme_mode';

  /// Carrega as configurações salvas e aplica ao AppConfig
  static Future<void> applySavedSettingsToAppConfig() async {
    // Aqui você pode carregar outras configurações como nome do estabelecimento, etc.
    // Por enquanto, vamos apenas garantir que o AppConfig esteja pronto.
    final prefs = await SharedPreferences.getInstance();
    final establishmentName = prefs.getString('establishment_name');
    if (establishmentName != null) {
      AppConfig.instance.establishmentName = establishmentName;
    }
  }

  /// Constrói o ThemeData com base nas configurações (pode ser expandido no futuro)
  static Future<ThemeData> buildThemeDataFromSettings(ThemeData baseTheme, bool isDarkMode) async {
    // No futuro, isso pode buscar cores customizadas do banco de dados ou SharedPreferences
    // Por enquanto, apenas retorna o tema base
    return baseTheme;
  }
}
