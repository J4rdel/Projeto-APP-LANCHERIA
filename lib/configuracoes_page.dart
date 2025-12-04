import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:lancheria/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _apiBaseUrlController;

  // Valores padrão que serão substituídos pelos valores salvos
  Color _lightPrimaryColor = Colors.deepOrange;
  Color _lightAccentColor = Colors.amber;
  Color _darkPrimaryColor = Colors.blueGrey.shade700;
  Color _darkAccentColor = Colors.tealAccent.shade400;
  String _mainFontFamily = 'Roboto';
  String _headlineFontFamily = 'RobotoSlab';

  bool _isLoading = true;

  // Lista de fontes disponíveis para escolha
  final List<String> _availableFonts = [
    'Roboto',
    'Lato',
    'Montserrat',
    'Oswald',
    'RobotoSlab',
    'Nunito',
  ];

  @override
  void initState() {
    super.initState();
    _apiBaseUrlController = TextEditingController(text: ApiService.baseUrl);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiBaseUrlController.text = prefs.getString('api_base_url') ?? ApiService.baseUrl;
      _lightPrimaryColor = Color(prefs.getInt('light_primary_color') ?? Colors.deepOrange.value);
      _lightAccentColor = Color(prefs.getInt('light_accent_color') ?? Colors.amber.value);
      _darkPrimaryColor = Color(prefs.getInt('dark_primary_color') ?? Colors.blueGrey.shade700.value);
      _darkAccentColor = Color(prefs.getInt('dark_accent_color') ?? Colors.tealAccent.shade400.value);
      _mainFontFamily = prefs.getString('main_font_family') ?? 'Roboto';
      _headlineFontFamily = prefs.getString('headline_font_family') ?? 'RobotoSlab';
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', _apiBaseUrlController.text);
    await prefs.setInt('light_primary_color', _lightPrimaryColor.value);
    await prefs.setInt('light_accent_color', _lightAccentColor.value);
    await prefs.setInt('dark_primary_color', _darkPrimaryColor.value);
    await prefs.setInt('dark_accent_color', _darkAccentColor.value);
    await prefs.setString('main_font_family', _mainFontFamily);
    await prefs.setString('headline_font_family', _headlineFontFamily);

    // Atualiza a configuração em tempo real
    ApiService.baseUrl = _apiBaseUrlController.text;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configurações salvas! Reinicie o app para aplicar todas as mudanças de tema.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _apiBaseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações do Aplicativo'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildSectionTitle('API'),
                  TextFormField(
                    controller: _apiBaseUrlController,
                    decoration: const InputDecoration(
                      labelText: 'URL Base da API',
                      hintText: 'http://seu-servidor.com',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || !Uri.parse(value).isAbsolute) {
                        return 'Por favor, insira uma URL válida.';
                      }
                      return null;
                    },
                  ),
                  const Divider(height: 32),

                  _buildSectionTitle('Tema Claro'),
                  _buildColorPicker('Cor Primária (Claro)', _lightPrimaryColor, (color) => setState(() => _lightPrimaryColor = color)),
                  _buildColorPicker('Cor de Destaque (Claro)', _lightAccentColor, (color) => setState(() => _lightAccentColor = color)),
                  const Divider(height: 32),

                  _buildSectionTitle('Tema Escuro'),
                  _buildColorPicker('Cor Primária (Escuro)', _darkPrimaryColor, (color) => setState(() => _darkPrimaryColor = color)),
                  _buildColorPicker('Cor de Destaque (Escuro)', _darkAccentColor, (color) => setState(() => _darkAccentColor = color)),
                  const Divider(height: 32),

                  _buildSectionTitle('Fontes'),
                  _buildFontPicker('Fonte Principal', _mainFontFamily, (font) => setState(() => _mainFontFamily = font!)),
                  _buildFontPicker('Fonte dos Títulos', _headlineFontFamily, (font) => setState(() => _headlineFontFamily = font!)),

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Salvar Configurações'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  Widget _buildColorPicker(String label, Color currentColor, ValueChanged<Color> onColorChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Escolha uma cor para "$label"'),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: currentColor,
                      onColorChanged: onColorChanged,
                      pickerAreaHeightPercent: 0.8,
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: currentColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontPicker(String label, String currentFont, ValueChanged<String?> onFontChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        value: currentFont,
        items: _availableFonts.map((String font) {
          return DropdownMenuItem<String>(
            value: font,
            child: Text(font, style: TextStyle(fontFamily: font, fontSize: 16)),
          );
        }).toList(),
        onChanged: onFontChanged,
      ),
    );
  }
}

class AppSettingsLoader {
  static Future<void> applySavedSettingsToAppConfig() async {
    final prefs = await SharedPreferences.getInstance();

    // API
    final apiBaseUrl = prefs.getString('api_base_url');
    if (apiBaseUrl != null) {
      ApiService.baseUrl = apiBaseUrl;
    }

    // Cores e Fontes (Aqui estamos apenas lendo. A aplicação real acontece no AppConfig/main.dart)
    // O ideal é que o AppConfig seja modificado para ler esses valores na inicialização.
    // Por simplicidade, vamos assumir que main.dart fará essa leitura.
  }

  static Future<ThemeData> buildThemeDataFromSettings(
      ThemeData baseTheme, bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    final Color primaryColor = Color(prefs.getInt(isDarkMode ? 'dark_primary_color' : 'light_primary_color') ?? baseTheme.colorScheme.primary.value);
    final Color accentColor = Color(prefs.getInt(isDarkMode ? 'dark_accent_color' : 'light_accent_color') ?? baseTheme.colorScheme.secondary.value);
    final String mainFont = prefs.getString('main_font_family') ?? 'Roboto';
    final String headlineFont = prefs.getString('headline_font_family') ?? 'RobotoSlab';

    final originalTextTheme = baseTheme.textTheme;

    return baseTheme.copyWith(
      primaryColor: primaryColor,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: primaryColor,
        secondary: accentColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: baseTheme.elevatedButtonTheme.style?.copyWith(
          backgroundColor: MaterialStateProperty.all(primaryColor),
        ),
      ),
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: primaryColor,
      ),
      textTheme: originalTextTheme.copyWith(
        bodyLarge: originalTextTheme.bodyLarge?.copyWith(fontFamily: mainFont),
        bodyMedium: originalTextTheme.bodyMedium?.copyWith(fontFamily: mainFont),
        titleLarge: originalTextTheme.titleLarge?.copyWith(fontFamily: headlineFont),
        titleMedium: originalTextTheme.titleMedium?.copyWith(fontFamily: headlineFont),
        titleSmall: originalTextTheme.titleSmall?.copyWith(fontFamily: mainFont),
        labelLarge: originalTextTheme.labelLarge?.copyWith(fontFamily: mainFont),
      ),
    );
  }
}