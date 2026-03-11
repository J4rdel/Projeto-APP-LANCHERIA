import 'package:flutter/material.dart';
import 'package:lancheria/api_service.dart';
import 'package:lancheria/auth_manager.dart';
import 'package:lancheria/home_page.dart';
import 'package:lancheria/logIn_page.dart';
import 'package:lancheria/qr_scanner_page.dart';
import 'package:provider/provider.dart';

class MesaVinculoPage extends StatefulWidget {
  const MesaVinculoPage({super.key});

  @override
  State<MesaVinculoPage> createState() => _MesaVinculoPageState();
}

class _MesaVinculoPageState extends State<MesaVinculoPage> {
  final _backendUrlController = TextEditingController();
  final _mesaIdController = TextEditingController();
  final _mesaNumeroController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _backendUrlController.text = ApiService.baseUrl;
  }

  @override
  void dispose() {
    _backendUrlController.dispose();
    _mesaIdController.dispose();
    _mesaNumeroController.dispose();
    super.dispose();
  }

  void _snack(String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _scanQr() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const QrScannerPage()),
    );
    if (!mounted || result == null) return;

    if (result['error'] != null) {
      _snack(result['error'].toString(), success: false);
      return;
    }

    final backendUrl = result['backendUrl']?.toString() ?? '';
    final mesaId = result['mesaId']?.toString() ?? '';
    final mesaNumero = result['mesaNumero']?.toString() ?? '';

    setState(() {
      _backendUrlController.text = backendUrl;
      _mesaIdController.text = mesaId;
      _mesaNumeroController.text = mesaNumero;
    });
  }

  bool _isBackendUrlValida(String url) {
    final lower = url.toLowerCase().trim();
    if (lower.contains('localhost') || lower.contains('127.0.0.1')) return false;
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }

  Future<void> _vincular() async {
    final backendUrl = _backendUrlController.text.trim();
    final mesaId = _mesaIdController.text.trim();
    final mesaNumero = int.tryParse(_mesaNumeroController.text.trim());

    if (!_isBackendUrlValida(backendUrl)) {
      _snack('backendUrl inválida. Use o IP do PC servidor (ex: http://192.168.1.100:3000).', success: false);
      return;
    }

    if (mesaNumero == null) {
      _snack('Informe o número da mesa.', success: false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      ApiService.baseUrl = backendUrl;

      String finalMesaId = mesaId;
      int finalMesaNumero = mesaNumero;

      if (finalMesaId.isEmpty) {
        final resolved = await ApiService.resolveMesaPorNumero(mesaNumero);
        finalMesaId = resolved['mesaId']?.toString() ?? '';
        finalMesaNumero = int.tryParse(resolved['mesaNumero']?.toString() ?? '') ?? mesaNumero;
      }

      if (finalMesaId.isEmpty) {
        _snack('Não foi possível resolver o mesaId.', success: false);
        return;
      }

      await ApiService.alocarMesa(finalMesaId);

      final authManager = Provider.of<AuthManager>(context, listen: false);
      await authManager.setMesaForDevice(
        backendUrl: backendUrl,
        mesaId: finalMesaId,
        mesaNumero: finalMesaNumero,
      );

      if (!mounted) return;
      _snack('Mesa vinculada com sucesso.', success: true);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      _snack('Erro ao vincular mesa: $e', success: false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vincular Tablet à Mesa')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _scanQr,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('LER QR CODE'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _backendUrlController,
                  decoration: const InputDecoration(
                    labelText: 'backendUrl',
                    hintText: 'http://192.168.1.100:3000',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _mesaNumeroController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'mesaNumero',
                    hintText: '12',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _mesaIdController,
                  decoration: const InputDecoration(
                    labelText: 'mesaId (opcional se o número resolver via API)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _vincular,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('VINCULAR'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          );
                        },
                  child: const Text('Entrar como Gerente/Suporte'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
