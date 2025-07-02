import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:lancheria/drink.dart';
import 'package:lancheria/lanche.dart';
import 'package:lancheria/sobremesa.dart';

class ApiService {
  // URL base da sua API no MockAPI
  static const String _baseUrl =
      'https://6864e5415b5d8d03397eba76.mockapi.io/produto/lanches';

  // Mapeamento entre nome da categoria e o ID usado no MockAPI
  static const Map<String, String> _categoriaMap = {
    'lanches': '1',
    'drinks': '2',
    'sobremesas': '3',
  };

  /// Método genérico privado para buscar dados da API.
  ///
  /// [categoriaNome] é o nome da categoria, que será traduzido para o ID usado no MockAPI.
  /// [fromJson] é a função que converte um item do JSON para um objeto Dart.
  static Future<List<T>> _fetchData<T>(
    String categoriaNome,
    T Function(Map<String, dynamic> json) fromJson,
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

  /// Busca os lanches
  static Future<List<Lanche>> fetchLanches() =>
      _fetchData('lanches', Lanche.fromJson);

  /// Busca os drinks
  static Future<List<Drink>> fetchDrinks() =>
      _fetchData('drinks', Drink.fromJson);

  /// Busca as sobremesas
  static Future<List<Sobremesa>> fetchSobremesas() =>
      _fetchData('sobremesas', Sobremesa.fromJson);
}
