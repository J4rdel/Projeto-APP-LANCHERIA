import 'dart:convert';
import 'dart:io'; // Necessário para o Platform.isAndroid
import 'package:http/http.dart' as http;
import 'package:lancheria/drink.dart';
import 'package:lancheria/lanche.dart';
import 'package:lancheria/sobremesa.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importar SharedPreferences

class ApiService {
  // Variável interna para armazenar a URL customizada
  static String? _customBaseUrl;
  static const String _baseUrlKey = 'backend_url';
  static const String _legacyBaseUrlKey = 'custom_base_url';
  static Map<int, String>? _categoriaIdToNomeCache;

  // Getter inteligente que decide qual URL usar.
  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) return _customBaseUrl!;
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://10.0.2.2:3000';
  }

  // Setter para permitir que a tela de configurações mude a URL
  static set baseUrl(String value) {
    _customBaseUrl = value;
    _saveBaseUrl(value);
  }

  static Future<void> _saveBaseUrl(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, value);
  }

  static Future<void> loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final fromNewKey = prefs.getString(_baseUrlKey);
    if (fromNewKey != null && fromNewKey.isNotEmpty) {
      _customBaseUrl = fromNewKey;
      return;
    }

    final fromLegacyKey = prefs.getString(_legacyBaseUrlKey);
    if (fromLegacyKey != null && fromLegacyKey.isNotEmpty) {
      _customBaseUrl = fromLegacyKey;
      await prefs.setString(_baseUrlKey, fromLegacyKey);
    }
  }

  /// Retorna a URL completa para uma imagem, tratando caminhos relativos.
  static String getFullImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$baseUrl$path';
  }

  static Future<Map<int, String>> _loadCategorias() async {
    if (_categoriaIdToNomeCache != null) return _categoriaIdToNomeCache!;

    final uri = Uri.parse('$baseUrl/categorias');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar categorias. Status: ${response.statusCode}');
    }

    final decoded = json.decode(utf8.decode(response.bodyBytes));
    final List<dynamic> list = decoded is List ? decoded : (decoded['data'] as List? ?? []);

    final map = <int, String>{};
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        final id = item['id'];
        final nome = item['nome'];
        final idParsed = int.tryParse(id?.toString() ?? '');
        if (idParsed != null && nome is String) {
          map[idParsed] = nome;
        }
      }
    }

    _categoriaIdToNomeCache = map;
    return map;
  }

  // Mapeamento atualizado para bater com as categorias que o backend cria automaticamente
  static const Map<String, String> _categoriaMap = {
    'lanches': 'Lanches',
    'drinks': 'Bebidas',
    'sobremesas': 'Sobremesas',
  };

  /// Método para buscar dados da API.
  static Future<List<T>> _fetchData<T>(
    String categoriaChave,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final categoriaNomeReal = _categoriaMap[categoriaChave];

    if (categoriaNomeReal == null) {
      throw Exception('Categoria "$categoriaChave" não está mapeada no App.');
    }

    final uri = Uri.parse('$baseUrl/produtos');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> jsonList = decoded is List ? decoded : (decoded['data'] as List? ?? []);

        Map<int, String> categoriasById = {};
        bool precisaCategorias = false;

        for (final item in jsonList) {
          if (item is Map<String, dynamic>) {
            final categoria = item['categoria'];
            if (categoria is int || categoria is String) {
              precisaCategorias = true;
              break;
            }
          }
        }

        if (precisaCategorias) {
          try {
            categoriasById = await _loadCategorias();
          } catch (_) {
            categoriasById = {};
          }
        }

        final parsed = <Map<String, dynamic>>[];
        final categoriaNomes = <String?>[];

        for (final item in jsonList) {
          if (item is! Map<String, dynamic>) continue;

          String? categoriaNome;
          final categoria = item['categoria'];
          if (categoria is Map<String, dynamic>) {
            final nome = categoria['nome'];
            if (nome is String && nome.isNotEmpty) categoriaNome = nome;
          } else if (categoria is String) {
            final idParsed = int.tryParse(categoria);
            if (idParsed != null && categoriasById[idParsed] != null) {
              categoriaNome = categoriasById[idParsed];
            }
          } else if (categoria is int) {
            if (categoriasById[categoria] != null) {
              categoriaNome = categoriasById[categoria];
            }
          }

          if (categoriaNome == null) {
            final nome1 = item['categoria_nome'];
            if (nome1 is String && nome1.isNotEmpty) categoriaNome = nome1;
          }
          if (categoriaNome == null) {
            final nome2 = item['categoriaNome'];
            if (nome2 is String && nome2.isNotEmpty) categoriaNome = nome2;
          }

          categoriaNomes.add(categoriaNome);
          parsed.add(item);
        }

        final encontrouAlgumaCategoria = categoriaNomes.any((c) => c != null);
        final filtrado = !encontrouAlgumaCategoria
            ? parsed
            : [
                for (int i = 0; i < parsed.length; i++)
                  if (categoriaNomes[i] == categoriaNomeReal) parsed[i],
              ];

        return filtrado.map((item) => fromJson(item)).toList();
      } else {
        throw Exception('Erro ao carregar $categoriaChave. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Não foi possível conectar ao servidor: $e');
    }
  }

  static Future<List<Lanche>> fetchLanches() =>
      _fetchData('lanches', Lanche.fromJson);

  static Future<List<Drink>> fetchDrinks() =>
      _fetchData('drinks', Drink.fromJson);

  static Future<List<Sobremesa>> fetchSobremesas() =>
      _fetchData('sobremesas', Sobremesa.fromJson);

  static Future<Map<String, dynamic>> resolveMesaPorNumero(int mesaNumero) async {
    final candidates = [
      Uri.parse('$baseUrl/mesas?numero=$mesaNumero'),
      Uri.parse('$baseUrl/mesas/numero/$mesaNumero'),
      Uri.parse('$baseUrl/mesas/$mesaNumero'),
    ];

    for (final uri in candidates) {
      final response = await http.get(uri);
      if (response.statusCode != 200) continue;

      final decoded = json.decode(utf8.decode(response.bodyBytes));
      dynamic mesa = decoded;
      if (decoded is Map<String, dynamic> && decoded['data'] != null) mesa = decoded['data'];

      if (mesa is List && mesa.isNotEmpty) mesa = mesa.first;

      if (mesa is Map<String, dynamic>) {
        final id = mesa['id']?.toString();
        final numero = int.tryParse(mesa['numero']?.toString() ?? '');
        if (id != null && id.isNotEmpty && numero != null) {
          return {'mesaId': id, 'mesaNumero': numero};
        }
      }
    }

    throw Exception('Não foi possível encontrar a mesa $mesaNumero no servidor.');
  }

  static Future<void> alocarMesa(String mesaId) async {
    final uri = Uri.parse('$baseUrl/mesas/$mesaId/alocar');
    try {
      final response = await http.patch(uri);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erro ao alocar mesa. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao alocar mesa: $e');
    }
  }

  static Future<void> liberarMesa(String mesaId) async {
    final uri = Uri.parse('$baseUrl/mesas/$mesaId/liberar');
    try {
      final response = await http.patch(uri);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erro ao liberar mesa. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao liberar mesa: $e');
    }
  }

  static Future<void> postFeedback({
    required String mesaId,
    int? mesaNumero,
    required int estrelas,
    String? mensagem,
  }) async {
    final uri = Uri.parse('$baseUrl/feedbacks');
    final body = <String, dynamic>{
      'mesaId': mesaId,
      'mesaNumero': mesaNumero,
      'clienteNome': 'Anônimo',
      'estrelas': estrelas,
      'mensagem': mensagem,
      'dataHora': DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      if (response.statusCode != 201 && response.statusCode != 200) {
        final responseText = utf8.decode(response.bodyBytes);
        throw Exception('Status: ${response.statusCode}. Resposta: $responseText');
      }
    } catch (e) {
      throw Exception('Erro ao enviar feedback: $e');
    }
  }

  static Future<PedidoCriado> postPedido({
    required String mesaId,
    String? clienteId,
    required List<Map<String, dynamic>> itens,
  }) async {
    final uri = Uri.parse('$baseUrl/pedidos');

    try {
      Future<http.Response> postBody(Map<String, dynamic> body) {
        return http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body),
        );
      }

      final bodyCamel = <String, dynamic>{
        'mesaId': mesaId,
        'clienteId': clienteId,
        'itens': itens,
      };

      final itensSnake = itens.map<Map<String, dynamic>>((item) {
        final produtoId = item['produto_id'] ?? item['produtoId'];
        final opcionaisIds = item['opcionais_ids'] ?? item['opcionaisIds'] ?? [];
        return {
          'produto_id': produtoId,
          'quantidade': item['quantidade'],
          'opcionais_ids': opcionaisIds,
          'observacoes': item['observacoes'],
        };
      }).toList();

      final bodySnake = <String, dynamic>{
        'mesa_id': mesaId,
        'cliente_id': clienteId,
        'itens': itensSnake,
      };

      http.Response response = await postBody(bodyCamel);
      if (response.statusCode == 400 || response.statusCode == 422) {
        response = await postBody(bodySnake);
      }
      if (response.statusCode == 400 || response.statusCode == 422) {
        final itensHybrid = itensSnake.map<Map<String, dynamic>>((item) {
          return {
            'produtoId': item['produto_id'],
            'produto_id': item['produto_id'],
            'quantidade': item['quantidade'],
            'opcionaisIds': item['opcionais_ids'],
            'opcionais_ids': item['opcionais_ids'],
            'observacoes': item['observacoes'],
          };
        }).toList();

        final bodyHybrid = <String, dynamic>{
          'mesaId': mesaId,
          'mesa_id': mesaId,
          'clienteId': clienteId,
          'cliente_id': clienteId,
          'itens': itensHybrid,
        };

        response = await postBody(bodyHybrid);
      }
      if (response.statusCode == 400 || response.statusCode == 422) {
        final itensMin = itensSnake.map<Map<String, dynamic>>((item) {
          return {
            'produtoId': item['produto_id'],
            'quantidade': item['quantidade'],
          };
        }).toList();

        response = await postBody({
          'mesaId': mesaId,
          'clienteId': clienteId,
          'itens': itensMin,
        });
      }
      if (response.statusCode == 400 || response.statusCode == 422) {
        final itensProdutoObj = itensSnake.map<Map<String, dynamic>>((item) {
          return {
            'produto': {'id': item['produto_id']},
            'quantidade': item['quantidade'],
          };
        }).toList();

        response = await postBody({
          'mesaId': mesaId,
          'clienteId': clienteId,
          'itens': itensProdutoObj,
        });
      }
      if (response.statusCode == 400 || response.statusCode == 422) {
        final itensProdutoScalar = itensSnake.map<Map<String, dynamic>>((item) {
          return {
            'produto': item['produto_id'],
            'quantidade': item['quantidade'],
          };
        }).toList();

        response = await postBody({
          'mesaId': mesaId,
          'clienteId': clienteId,
          'itens': itensProdutoScalar,
        });
      }

      if (response.statusCode != 201 && response.statusCode != 200) {
        final responseText = utf8.decode(response.bodyBytes);
        throw Exception('Erro ao enviar pedido. Status: ${response.statusCode}. Resposta: $responseText');
      }

      final decoded = json.decode(utf8.decode(response.bodyBytes));
      final Map<String, dynamic> data = decoded is Map<String, dynamic>
          ? decoded
          : {'data': decoded};
      final dynamic root = data['data'] ?? data;

      int? numero;
      String? dataHoraIso;

      if (root is Map<String, dynamic>) {
        numero = int.tryParse((root['numero'] ?? root['pedidoNumero'] ?? '').toString());
        dataHoraIso = (root['dataHoraPedido'] ?? root['data_hora_pedido'] ?? root['createdAt'] ?? root['created_at'])?.toString();

        final pedido = root['pedido'];
        if (numero == null && pedido is Map<String, dynamic>) {
          numero = int.tryParse(pedido['numero']?.toString() ?? '');
        }
        if ((dataHoraIso == null || dataHoraIso.isEmpty) && pedido is Map<String, dynamic>) {
          dataHoraIso = (pedido['dataHoraPedido'] ?? pedido['data_hora_pedido'] ?? pedido['createdAt'] ?? pedido['created_at'])?.toString();
        }
      }

      return PedidoCriado(
        numero: numero,
        dataHora: DateTime.tryParse(dataHoraIso ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      throw Exception('Erro ao enviar pedido: $e');
    }
  }
}

class PedidoCriado {
  final int? numero;
  final DateTime dataHora;

  const PedidoCriado({required this.numero, required this.dataHora});
}
