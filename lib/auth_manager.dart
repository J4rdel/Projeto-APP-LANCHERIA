import 'package:flutter/foundation.dart';
import 'package:lancheria/app_config.dart';
import 'package:lancheria/usuario.dart';
import 'package:lancheria/user_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthManager with ChangeNotifier {
  Usuario? _currentUser;
  UserRole _currentRole = UserRole.none;
  String? _mesaIdForDevice;
  int? _mesaNumeroForDevice;

  static const String _mesaIdKey = 'mesa_id';
  static const String _mesaNumeroKey = 'mesa_numero';
  static const String _legacyTableIdKey = 'device_table_id';
  static const String _backendUrlKey = 'backend_url';
  static const String _legacyBackendUrlKey = 'custom_base_url';

  Usuario? get currentUser => _currentUser;
  UserRole get currentRole => _currentRole;
  String? get mesaIdForDevice => _mesaIdForDevice;
  int? get mesaNumeroForDevice => _mesaNumeroForDevice;
  String? get currentTableIdForDevice => _mesaIdForDevice;

  bool get isUserLoggedIn =>
      _currentUser != null && _currentRole != UserRole.none;
  bool get isDeviceConfiguredAsTable =>
      _mesaIdForDevice != null &&
      _mesaNumeroForDevice != null &&
      _currentRole == UserRole.cliente;

  // Helper para acessar o caminho da logo
  String getAppLogoPath() => AppConfig.instance.logoAssetPath;

  AuthManager() {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();

    final mesaId = prefs.getString(_mesaIdKey);
    final mesaNumero = prefs.getInt(_mesaNumeroKey);

    if (mesaId != null && mesaId.isNotEmpty && mesaNumero != null) {
      _mesaIdForDevice = mesaId;
      _mesaNumeroForDevice = mesaNumero;
      _currentUser = Usuario.mesaCliente(mesaId: mesaId, mesaNumero: mesaNumero);
      _currentRole = UserRole.cliente;
    } else {
      final legacyTable = prefs.getString(_legacyTableIdKey);
      final legacyMesaNumero = int.tryParse(legacyTable ?? '');
      if (legacyTable != null && legacyTable.isNotEmpty && legacyMesaNumero != null) {
        _mesaIdForDevice = legacyTable;
        _mesaNumeroForDevice = legacyMesaNumero;
        _currentUser = Usuario.mesaCliente(
          mesaId: legacyTable,
          mesaNumero: legacyMesaNumero,
        );
        _currentRole = UserRole.cliente;
        await prefs.setString(_mesaIdKey, legacyTable);
        await prefs.setInt(_mesaNumeroKey, legacyMesaNumero);
      }
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
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> setMesaForDevice({
    required String backendUrl,
    required String mesaId,
    required int mesaNumero,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backendUrlKey, backendUrl);
    await prefs.remove(_legacyBackendUrlKey);
    await prefs.setString(_mesaIdKey, mesaId);
    await prefs.setInt(_mesaNumeroKey, mesaNumero);
    await prefs.setString(_legacyTableIdKey, mesaNumero.toString());

    _mesaIdForDevice = mesaId;
    _mesaNumeroForDevice = mesaNumero;
    _currentUser = Usuario.mesaCliente(mesaId: mesaId, mesaNumero: mesaNumero);
    _currentRole = UserRole.cliente;
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
    await prefs.remove(_mesaIdKey);
    await prefs.remove(_mesaNumeroKey);
    await prefs.remove(_legacyTableIdKey);
    await prefs.remove(_backendUrlKey);
    await prefs.remove(_legacyBackendUrlKey);

    _mesaIdForDevice = null;
    _mesaNumeroForDevice = null;
    _currentUser = null; // Limpa o usuário gerente também
    _currentRole = UserRole.none;
    notifyListeners();
  }
}
