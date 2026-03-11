import 'package:flutter/material.dart';
import 'package:lancheria/api_service.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  final _baseUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Preenche o campo com a URL base atual
    _baseUrlController.text = ApiService.baseUrl;
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    // Atualiza a URL base no ApiService
    ApiService.baseUrl = _baseUrlController.text;

    // Mostra uma confirmação e fecha a tela
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configurações salvas!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações do App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Configurações de Conexão', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _baseUrlController,
              decoration: const InputDecoration(labelText: 'URL Base da API', hintText: 'Ex: http://192.168.1.10:3000', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _saveSettings, child: const Text('SALVAR')),
          ],
        ),
      ),
    );
  }
}