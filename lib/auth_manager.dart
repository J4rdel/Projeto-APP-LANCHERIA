import 'package:flutter/foundation.dart';
import 'package:lancheria/app_config.dart';
import 'package:lancheria/usuario.dart';
import 'package:lancheria/user_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthManager with ChangeNotifier {
  Usuario? _currentUser;
  UserRole _currentRole = UserRole.none;
  String? _currentTableIdForDevice; // Mesa configurada para este dispositivo

  static const String _tableIdKey = 'device_table_id';
  // static const String gerentemasterpinkey = 'gerente_master_pin'; // Removido: variável não utilizada

  Usuario? get currentUser => _currentUser;
  UserRole get currentRole => _currentRole;
  String? get currentTableIdForDevice => _currentTableIdForDevice;

  bool get isUserLoggedIn =>
      _currentUser != null && _currentRole != UserRole.none;
  bool get isDeviceConfiguredAsTable =>
      _currentTableIdForDevice != null && _currentRole == UserRole.cliente;

  // Helper para acessar o caminho da logo
  String getAppLogoPath() => AppConfig.instance.logoAssetPath;

  AuthManager() {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    final tableId = prefs.getString(_tableIdKey);
    if (tableId != null && tableId.isNotEmpty) {
      _currentTableIdForDevice = tableId;
      _currentUser = Usuario.mesaCliente(
        tableId,
      ); // Cria um usuário "cliente de mesa"
      _currentRole = UserRole.cliente;
      // print('AuthManager: Dispositivo carregado como Mesa $tableId');
    } else {
      // print('AuthManager: Nenhuma mesa configurada para este dispositivo.');
    }
    notifyListeners();
  }

  // Simulação de Login para Gerente/Suporte
  Future<bool> loginGerente(String email, String password) async {
    if (email == 'gerente@email.com' && password == 'gerente123') {
      _currentUser = Usuario(
        id: 'gerente_uid_mock',
        email: email,
        nome: 'Gerente Silva',
        role: UserRole.gerente,
      );
      _currentRole = UserRole.gerente;
      _currentTableIdForDevice = null; // Gerente não está preso a uma mesa
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tableIdKey); // Limpa configuração de mesa anterior
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> loginSuporte(String email, String password) async {
    if (email == 'suporte@email.com' && password == 'suporte123') {
      _currentUser = Usuario(
        id: 'suporte_uid_mock',
        email: email,
        nome: 'Suporte Técnico',
        role: UserRole.suporte,
      );
      _currentRole = UserRole.suporte;
      _currentTableIdForDevice = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tableIdKey);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> setTableForDevice(String tableId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tableIdKey, tableId);
    _currentTableIdForDevice = tableId;
    _currentUser = Usuario.mesaCliente(tableId);
    _currentRole = UserRole.cliente;
    // print('AuthManager: Dispositivo configurado para Mesa $tableId');
    notifyListeners();
  }

  // Valida o PIN do gerente para permitir alterações de configuração de mesa
  bool validateGerentePin(String pin) {
    // No futuro, isso pode ser o hash da senha do gerente ou um PIN específico
    // Por agora, usamos um valor fixo do AppConfig
    return pin == AppConfig.instance.gerenteMasterPin;
  }

  Future<void> logout() async {
    _currentUser = null;
    // Se o logout for de um gerente/suporte, não necessariamente limpamos a mesa do dispositivo.
    // A limpeza da mesa do dispositivo deve ser uma ação explícita do gerente.
    // Se for um "logout de mesa", então limpamos.
    if (_currentRole != UserRole.cliente) {
      // Se era gerente ou suporte
      _currentRole = UserRole.none; // Volta para a tela de login geral
    }
    // Se quiser que o logout de gerente/suporte também desconfigure a mesa:
    // await clearTableForDevice();
    // _currentRole = UserRole.none;

    notifyListeners();
  }

  // Usado pelo gerente para desconfigurar o dispositivo de uma mesa
  Future<void> clearTableForDeviceAndLogoutGerente() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tableIdKey);
    _currentTableIdForDevice = null;
    _currentUser = null; // Limpa o usuário gerente também
    _currentRole = UserRole.none;
    // print('AuthManager: Configuração de mesa removida do dispositivo.');
    notifyListeners();
  }
}
