import 'package:lancheria/lanche.dart';
import 'package:lancheria/drink.dart';
import 'package:lancheria/sobremesa.dart';
import 'package:lancheria/mock_data_service.dart';

class AppConfig {
  // Construtor privado para o padrão Singleton
  AppConfig._privateConstructor();

  // Instância estática única
  static final AppConfig _instance = AppConfig._privateConstructor();

  // Acessor público para a instância
  static AppConfig get instance => _instance;

  // --- DADOS CONFIGURÁVEIS DO ESTABELECIMENTO ---
  String establishmentName = 'Lancheria Padrão';
  String logoAssetPath = 'assets/images/logo_padrao.png'; // Caminho para a logo principal
  String currencySymbol = 'R\$';

  // Chaves de API (substitua pelas suas chaves reais ou deixe como placeholder)
  String apiKey1 = 'SUA_API_KEY_1_AQUI';
  String apiKey2 = 'SUA_API_KEY_2_AQUI';

  // --- FONTES DE DADOS PARA PRODUTOS ---
  // Inicialmente, apontam para os dados mockados.
  // No futuro, você pode mudar para:
  // getLanches = ApiService.fetchLanchesFromApi;
  Future<List<Lanche>> Function() getLanches = MockDataService.fetchLanches;
  Future<List<Drink>> Function() getDrinks = MockDataService.fetchDrinks;
  Future<List<Sobremesa>> Function() getSobremesas = MockDataService.fetchSobremesas;

  // Método para inicializar configurações (opcional, pode ser expandido no futuro)
  void initialize() {
    // Aqui você poderia carregar configurações de um arquivo, variáveis de ambiente, etc.
    //print('AppConfig inicializado para: ${instance.establishmentName}');
  }
}
