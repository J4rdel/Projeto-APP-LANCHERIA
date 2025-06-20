import 'package:flutter/material.dart';
import 'package:lancheria/auth_manager.dart';
import 'package:lancheria/user_role.dart'; // Adicionar este import
import 'package:provider/provider.dart';

enum _PageMode {
  loginForm, // Formulário inicial de email/senha
  managerOptions, // Opções para o gerente após login
  configureTableForm, // Formulário para configurar a mesa
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
  final _tableIdController = TextEditingController();
  final _gerentePinController = TextEditingController();

  _PageMode _currentMode = _PageMode.loginForm;
  UserRole _loginAsRole = UserRole.gerente; // Padrão para login de gerente

  bool _isLoading = false;
  String? _errorMessage;

  void _toggleLoginRole() {
    setState(() {
      _loginAsRole = _loginAsRole == UserRole.gerente
          ? UserRole.suporte
          : UserRole.gerente;
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
      // Suporte
      success = await authManager.loginSuporte(
        _emailController.text,
        _passwordController.text,
      );
      // Para suporte, a navegação para HomePage é automática via Consumer no main.dart
    }

    if (!success) {
      _showError('Email ou senha inválidos.');
    } else {
      // Navegação será tratada pelo Consumer na HomePage/Main
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitSetTable() async {
    if (_tableIdController.text.isEmpty) {
      _showError('Por favor, insira o número da mesa.');
      return;
    }
    if (!_formKey.currentState!.validate()) return; // Validar o PIN

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authManager = Provider.of<AuthManager>(context, listen: false);

    if (authManager.validateGerentePin(_gerentePinController.text)) {
      await authManager.setTableForDevice(_tableIdController.text);
      // Navegação será tratada pelo Consumer
    } else {
      _showError('PIN do gerente incorreto.');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitClearTable() async {
    if (!_formKey.currentState!.validate()) return; // Validar o PIN

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final authManager = Provider.of<AuthManager>(context, listen: false);
    if (authManager.validateGerentePin(_gerentePinController.text)) {
      await authManager.clearTableForDeviceAndLogoutGerente();
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
    _tableIdController.dispose();
    _gerentePinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authManager = Provider.of<AuthManager>(context);

    String appBarTitle = '';
    bool showBackButton = false;

    switch (_currentMode) {
      case _PageMode.loginForm:
        appBarTitle = _loginAsRole == UserRole.gerente
            ? 'Login Gerente'
            : 'Login Suporte';
        showBackButton = false;
        break;
      case _PageMode.managerOptions:
        appBarTitle = 'Opções do Gerente';
        showBackButton = true; // Para voltar ao loginForm (e deslogar)
        break;
      case _PageMode.configureTableForm:
        appBarTitle = 'Configurar Mesa do Dispositivo';
        showBackButton = true; // Para voltar às managerOptions
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _handleAppBarBackPress,
              )
            : null,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Adicionar Hero para a logo se ela também estiver na HomePage com Hero
                  Hero(
                    tag: 'app_logo', // Mesma tag da HomePage
                    child: Image.asset(
                      context
                          .read<AuthManager>()
                          .getAppLogoPath(), // Acessar via AuthManager ou AppConfig
                      height: 100, // Ajuste o tamanho conforme necessário
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_currentMode == _PageMode.managerOptions) ...[
                    Text(
                      'Gerente Logado: ${authManager.currentUser?.nome ?? ""}',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentMode = _PageMode.configureTableForm;
                          _errorMessage = null;
                          _gerentePinController.clear();
                          _tableIdController.text =
                              authManager.currentTableIdForDevice ?? "";
                        });
                      },
                      child: const Text(
                        'CONFIGURAR/ALTERAR MESA DO DISPOSITIVO',
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        // O AuthManager já está com UserRole.gerente.
                        // O Consumer no main.dart cuidará da navegação para HomePage.
                        // Nenhuma ação extra é necessária aqui para navegar,
                        // pois o estado do AuthManager já reflete o login do gerente.
                        // A LoginPage será substituída pela HomePage.
                      },
                      child: const Text('ACESSAR GERENCIAMENTO DO APP'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                      ),
                      onPressed: () async {
                        await authManager.logout(); // Desloga o gerente
                        setState(() {
                          _currentMode =
                              _PageMode.loginForm; // Volta para a tela de login
                          _loginAsRole =
                              UserRole.gerente; // Reseta para login de gerente
                        });
                      },
                      child: const Text('SAIR (Logout Gerente)'),
                    ),
                  ] else if (_currentMode == _PageMode.configureTableForm) ...[
                    Text(
                      'Definir Mesa para este Dispositivo',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    TextFormField(
                      controller: _tableIdController,
                      decoration: const InputDecoration(
                        labelText: 'Número da Mesa (Ex: 25)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Insira o número da mesa'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _gerentePinController,
                      decoration: const InputDecoration(
                        labelText: 'PIN do Gerente',
                      ),
                      obscureText: true,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Insira o PIN do Gerente'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitSetTable,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('DEFINIR MESA'),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _gerentePinController.clear();
                        _tableIdController.clear();
                        _errorMessage = null;
                        _currentMode = _PageMode
                            .managerOptions; // Volta para as opções do gerente
                      }),
                      child: const Text(
                        'Voltar para Opções do Gerente',
                      ), // Corrigido: completar a string
                    ),
                    if (authManager.currentTableIdForDevice != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        "Este dispositivo está configurado para: Mesa ${authManager.currentTableIdForDevice}",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: _isLoading ? null : _submitClearTable,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('DESCONFIGURAR MESA'),
                      ),
                    ],
                  ] else if (_currentMode == _PageMode.loginForm) ...[
                    // Modo de Login
                    Text(
                      'Bem-vindo!',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Insira seu email';
                        }
                        if (!value.contains('@')) {
                          return 'Email inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Senha'),
                      obscureText: true,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Insira sua senha'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitLogin,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _loginAsRole == UserRole.gerente
                                  ? 'ENTRAR COMO GERENTE'
                                  : 'ENTRAR COMO SUPORTE',
                            ),
                    ),
                    TextButton(
                      onPressed: _toggleLoginRole,
                      child: Text(
                        _loginAsRole == UserRole.gerente
                            ? 'Entrar como Suporte'
                            : 'Entrar como Gerente',
                      ),
                    ),
                    // O botão "CONFIGURAR MESA DO DISPOSITIVO" foi movido para _PageMode.managerOptions
                    // Se um dispositivo já está configurado como mesa, ele vai direto para HomePage.
                    // Se não está, e o gerente quer configurar, ele loga primeiro,
                    // depois escolhe "Configurar Mesa" nas opções.
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
        authManager.logout(); // Desloga se estava nas opções do gerente
        _currentMode = _PageMode.loginForm;
        _loginAsRole = UserRole.gerente; // Volta para o login de gerente
      } else if (_currentMode == _PageMode.configureTableForm) {
        _currentMode =
            _PageMode.managerOptions; // Volta para as opções do gerente
      }
      _gerentePinController.clear();
      _tableIdController.clear();
    });
  }
}
