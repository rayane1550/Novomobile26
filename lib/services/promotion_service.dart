import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:onde_comer/models/promotion.dart';

class PromotionService {
  PromotionService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? 'https://jsonplaceholder.typicode.com';

  final http.Client _client;
  final String _baseUrl;

  Future<List<Promotion>> fetchPromotions() async {
    final response = await _client
        .get(Uri.parse('$_baseUrl/posts?_limit=8'))
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw Exception('Não foi possível carregar as promoções');
    }
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return List.generate(
      data.length,
      (index) => Promotion.fromRemoteJson(
        data[index] as Map<String, dynamic>,
        index: index,
      ),
    );
  }

  Future<Promotion> createPromotion(Promotion promotion) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(promotion.toRemoteJson()),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Não foi possível criar a promoção');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return promotion.copyWith(id: data['id'] as int? ?? promotion.id);
  }

  Future<void> updatePromotion(Promotion promotion) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/posts/${promotion.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(promotion.toRemoteJson()),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Não foi possível atualizar a promoção');
    }
  }

  Future<void> deletePromotion(int id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/posts/$id'));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Não foi possível excluir a promoção');
    }
  }
}
