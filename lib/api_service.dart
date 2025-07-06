import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:lancheria/drink.dart';
import 'package:lancheria/lanche.dart';
import 'package:lancheria/sobremesa.dart';

class ApiService {
  // URL base correta do recurso no MockAPI
  static const String _baseUrl = 'http://localhost:3000/produtos?categoria=';

  // Mapeamento entre nome da categoria e o valor numérico usado no MockAPI
  static const Map<String, String> _categoriaMap = {
    'lanches': '2',
    'drinks': '1',
    'sobremesas': '3',
  };

  /// Método genérico para buscar dados da API com base na categoria.
  static Future<List<T>> _fetchData<T>(
    String categoriaNome,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final categoriaId = _categoriaMap[categoriaNome];

    if (categoriaId == null) {
      throw Exception('Categoria "$categoriaNome" não está mapeada.');
    }

    final uri = Uri.parse(
      _baseUrl,
    ).replace(queryParameters: {'categoria': categoriaId});

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(
        utf8.decode(response.bodyBytes),
      );

      return jsonList
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Falha ao carregar dados da categoria "$categoriaNome". Status: ${response.statusCode}',
      );
    }
  }

  static Future<List<Lanche>> fetchLanches() =>
      _fetchData('lanches', Lanche.fromJson);

  static Future<List<Drink>> fetchDrinks() =>
      _fetchData('drinks', Drink.fromJson);

  static Future<List<Sobremesa>> fetchSobremesas() =>
      _fetchData('sobremesas', Sobremesa.fromJson);
}
