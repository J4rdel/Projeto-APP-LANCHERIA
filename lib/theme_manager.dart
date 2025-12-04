import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_config.dart'; // Para atualizar o AppConfig

const String _kThemePreference = "theme_preference";

class ThemeManager with ChangeNotifier {
  ThemeMode _themeMode;

  ThemeManager(this._themeMode);

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return; // Evita atualizações desnecessárias

    _themeMode = mode;
    notifyListeners(); // Notifica os ouvintes (como o MaterialApp)

    // Persiste a preferência do usuário
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemePreference, mode.index);

    // Atualiza o activeThemeMode no AppConfig para que os getters de cor funcionem
    AppConfig.instance.updateActiveThemeMode(mode);
  }

  // Método conveniente para alternar entre claro e escuro
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
    // Se você quiser suportar ThemeMode.system, a lógica aqui seria mais complexa
  }

  // Carrega o ThemeMode salvo ou retorna um padrão
  static Future<ThemeMode> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_kThemePreference);
      if (themeIndex != null &&
          themeIndex >= 0 &&
          themeIndex < ThemeMode.values.length) {
        return ThemeMode.values[themeIndex];
      }
    } catch (e) {
      // Em caso de erro ao ler as preferências (ex: primeira execução, dados corrompidos)
      // print("Erro ao carregar preferência de tema: $e");
    }
    return ThemeMode.light; // Padrão se nada for salvo ou em caso de erro
  }
}
