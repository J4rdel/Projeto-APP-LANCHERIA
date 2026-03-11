import 'package:flutter/material.dart';
import 'package:lancheria/api_service.dart';
import 'package:lancheria/auth_manager.dart';
import 'package:lancheria/home_page.dart';
import 'package:lancheria/user_role.dart';
import 'package:lancheria/configuracoes_page.dart';
import 'package:lancheria/qr_scanner_page.dart';
import 'package:provider/provider.dart';

enum _PageMode {
  loginForm,
  managerOptions,
  configureTableForm,
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _backendUrlController = TextEditingController();
  final _mesaIdController = TextEditingController();
  final _tableIdController = TextEditingController();
  final _gerentePinController = TextEditingController();

  _PageMode _currentMode = _PageMode.loginForm;
  UserRole _loginAsRole = UserRole.gerente;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authManager = Provider.of<AuthManager>(context, listen: false);
      if (authManager.isUserLoggedIn &&
          authManager.currentRole == UserRole.gerente &&
          !authManager.isDeviceConfiguredAsTable &&
          _currentMode == _PageMode.loginForm) {
        setState(() {
          _currentMode = _PageMode.managerOptions;
        });
      }
    });
  }

  void _toggleLoginRole() {
    setState(() {
      _loginAsRole = _loginAsRole == UserRole.gerente ? UserRole.suporte : UserRole.gerente;
      _errorMessage = null;
      _emailController.clear();
      _passwordController.clear();
      _formKey.currentState?.reset();
    });
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  void _showSnackBar(String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  bool _isBackendUrlValida(String url) {
    final lower = url.toLowerCase().trim();
    if (lower.contains('localhost') || lower.contains('127.0.0.1')) return false;
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authManager = Provider.of<AuthManager>(context, listen: false);
    bool success;

    if (_loginAsRole == UserRole.gerente) {
      success = await authManager.loginGerente(
        _emailController.text,
        _passwordController.text,
      );
      if (success && mounted) {
        setState(() => _currentMode = _PageMode.managerOptions);
      }
    } else {
      success = await authManager.loginSuporte(
        _emailController.text,
        _passwordController.text,
      );
    }

    if (!success) {
      _showError('Email ou senha inválidos.');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitSetTable() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authManager = Provider.of<AuthManager>(context, listen: false);

    if (authManager.validateGerentePin(_gerentePinController.text)) {
      final backendUrl = _backendUrlController.text.trim();
      if (!_isBackendUrlValida(backendUrl)) {
        _showError('backendUrl inválida. Use o IP do PC servidor (ex: http://192.168.1.100:3000).');
        return;
      }

      final mesaNumero = int.tryParse(_tableIdController.text.trim());
      if (mesaNumero == null) {
        _showError('Número da mesa inválido.');
        return;
      }

      ApiService.baseUrl = backendUrl;

      String mesaId = _mesaIdController.text.trim();
      int mesaNumeroFinal = mesaNumero;
      if (mesaId.isEmpty) {
        final resolved = await ApiService.resolveMesaPorNumero(mesaNumero);
        mesaId = resolved['mesaId']?.toString() ?? '';
        mesaNumeroFinal = int.tryParse(resolved['mesaNumero']?.toString() ?? '') ?? mesaNumero;
      }

      if (mesaId.isEmpty) {
        _showError('Não foi possível resolver o mesaId.');
        return;
      }

      try {
        await ApiService.alocarMesa(mesaId);
      } catch (e) {
        _showError('Erro ao alocar mesa: $e');
        return;
      }

      await authManager.setMesaForDevice(
        backendUrl: backendUrl,
        mesaId: mesaId,
        mesaNumero: mesaNumeroFinal,
      );

      if (mounted) {
        _showSnackBar('Mesa configurada com sucesso.', success: true);
        setState(() => _currentMode = _PageMode.managerOptions);
      }
    } else {
      _showError('PIN do gerente incorreto.');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _scanQr() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const QrScannerPage()),
    );
    if (!mounted || result == null) return;

    if (result['error'] != null) {
      _showSnackBar(result['error'].toString(), success: false);
      return;
    }

    setState(() {
      _backendUrlController.text = result['backendUrl']?.toString() ?? '';
      _mesaIdController.text = result['mesaId']?.toString() ?? '';
      _tableIdController.text = result['mesaNumero']?.toString() ?? '';
      _errorMessage = null;
    });
  }

  Future<void> _submitClearTable() async {
    if (_gerentePinController.text.isEmpty) {
      _showError('PIN do gerente é necessário para desconfigurar.');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final authManager = Provider.of<AuthManager>(context, listen: false);
    if (authManager.validateGerentePin(_gerentePinController.text)) {
      final mesaId = authManager.mesaIdForDevice;
      if (mesaId == null || mesaId.isEmpty) {
        _showError('Nenhuma mesa vinculada para liberar.');
        return;
      }

      try {
        await ApiService.liberarMesa(mesaId);
      } catch (e) {
        _showError('Erro ao liberar mesa: $e');
        return;
      }

      await authManager.clearTableForDeviceAndLogoutGerente();
      if (mounted) {
        _showSnackBar('Mesa liberada e tablet desconfigurado.', success: true);
      }
    } else {
      _showError('PIN do gerente incorreto para desconfigurar.');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _backendUrlController.dispose();
    _mesaIdController.dispose();
    _tableIdController.dispose();
    _gerentePinController.dispose();
    super.dispose();
  }

  Widget _buildManagerOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authManager = Provider.of<AuthManager>(context);
    String appBarTitle = '';
    bool showBackButton = false;

    switch (_currentMode) {
      case _PageMode.loginForm:
        appBarTitle = _loginAsRole == UserRole.gerente ? 'Login Gerente' : 'Login Suporte';
        showBackButton = false;
        break;
      case _PageMode.managerOptions:
        appBarTitle = 'Opções do Gerente';
        showBackButton = true;
        break;
      case _PageMode.configureTableForm:
        appBarTitle = 'Configurar Mesa';
        showBackButton = true;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: showBackButton ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _handleAppBarBackPress) : null,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Hero(
                    tag: 'app_logo',
                    child: Image.asset(authManager.getAppLogoPath(), height: 100),
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null) ...[
                    Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                  ],
                  if (_currentMode == _PageMode.managerOptions) ...[
                    _buildManagerOptionButton(
                      icon: Icons.storefront,
                      label: 'IR PARA MENU DO APP',
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const HomePage()),
                          (route) => false,
                        );
                      },
                    ),
                    _buildManagerOptionButton(
                      icon: Icons.tablet_android,
                      label: 'SELECIONAR MESA',
                      onPressed: () {
                        setState(() {
                          _currentMode = _PageMode.configureTableForm;
                          _errorMessage = null;
                          _gerentePinController.clear();
                          _backendUrlController.text = ApiService.baseUrl;
                          _mesaIdController.text = authManager.mesaIdForDevice ?? "";
                          _tableIdController.text = authManager.mesaNumeroForDevice?.toString() ?? "";
                        });
                      },
                    ),
                    _buildManagerOptionButton(
                      icon: Icons.settings,
                      label: 'CONFIGURAÇÕES DO APP',
                      backgroundColor: Colors.blueGrey,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => ConfiguracoesPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () async {
                        await authManager.logout();
                        setState(() {
                          _currentMode = _PageMode.loginForm;
                          _loginAsRole = UserRole.gerente;
                        });
                      },
                      child: const Text('SAIR (Logout Gerente)', style: TextStyle(color: Colors.red)),
                    ),
                  ] else if (_currentMode == _PageMode.configureTableForm) ...[
                    Text('Definir Mesa para este Dispositivo', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
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
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Insira o backendUrl' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tableIdController,
                      decoration: const InputDecoration(labelText: 'Número da Mesa (Ex: 25)'),
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.isEmpty) ? 'Insira o número da mesa' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mesaIdController,
                      decoration: const InputDecoration(labelText: 'mesaId (opcional)'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _gerentePinController,
                      decoration: const InputDecoration(labelText: 'PIN do Gerente'),
                      obscureText: true,
                      validator: (v) => (v == null || v.isEmpty) ? 'Insira o PIN do Gerente' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitSetTable,
                      child: _isLoading ? const CircularProgressIndicator() : const Text('DEFINIR MESA'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                      onPressed: _isLoading ? null : _submitClearTable,
                      child: _isLoading
                          ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                          : const Text('LIMPAR CONFIGURAÇÃO DE MESA'),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _gerentePinController.clear();
                        _tableIdController.clear();
                        _errorMessage = null;
                        _currentMode = _PageMode.managerOptions;
                      }),
                      child: const Text('Voltar para Opções do Gerente'),
                    ),
                  ] else if (_currentMode == _PageMode.loginForm) ...[
                    Text('Bem-vindo!', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || !v.contains('@')) ? 'Email inválido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Senha'),
                      obscureText: true,
                      validator: (v) => (v == null || v.isEmpty) ? 'Insira sua senha' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitLogin,
                      child: _isLoading ? const CircularProgressIndicator() : Text(_loginAsRole == UserRole.gerente ? 'ENTRAR COMO GERENTE' : 'ENTRAR COMO SUPORTE'),
                    ),
                    TextButton(
                      onPressed: _toggleLoginRole,
                      child: Text(_loginAsRole == UserRole.gerente ? 'Entrar como Suporte' : 'Entrar como Gerente'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleAppBarBackPress() {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    setState(() {
      _errorMessage = null;
      if (_currentMode == _PageMode.managerOptions) {
        authManager.logout();
        _currentMode = _PageMode.loginForm;
        _loginAsRole = UserRole.gerente;
      } else if (_currentMode == _PageMode.configureTableForm) {
        _currentMode = _PageMode.managerOptions;
      }
      _gerentePinController.clear();
      _backendUrlController.clear();
      _mesaIdController.clear();
      _tableIdController.clear();
    });
  }
}
