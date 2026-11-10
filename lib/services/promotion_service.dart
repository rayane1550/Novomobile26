import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:onde_comer/models/promotion.dart';

class PromotionService {
  PromotionService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ??
            (kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000');

  static const List<Promotion> _defaultPromotions = [
    Promotion(
      id: 1,
      title: 'Bacalhau Vinho e Cia',
      description:
          'Casa especializada em bacalhau, com receitas tradicionais e ambiente acolhedor.',
      price: 89.90,
      imageUrl:
          'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/2c/df/46/0f/bacalhau-a-portuguesa.jpg?w=900&h=500&s=1',
      menu: 'Bacalhau à portuguesa, entradas quentes, sobremesas e pratos da casa.',
      location: 'Rua da Barra Funda, 120 - São Paulo/SP',
      schedule: 'Segunda a domingo, das 11:30 às 23:00',
      parking: 'Estacionamento com manobrista e vagas externas.',
    ),
    Promotion(
      id: 2,
      title: 'Jam - Itaim',
      description:
          'Culinária japonesa com ambiente elegante, pratos criativos e experiências musicais.',
      price: 99.90,
      imageUrl:
          'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/1c/a7/19/2f/caption.jpg?w=900&h=500&s=1',
      menu: 'Sushis, sashimis, combinados, frutos do mar e pratos grelhados.',
      location: 'Avenida Faria Lima, 3100 - Itaim Bibi/SP',
      schedule: 'Terça a domingo, das 12:00 às 23:30',
      parking: 'Estacionamento próprio e conveniado.',
    ),
    Promotion(
      id: 3,
      title: 'Aguzzo Cucina Italiana - Pinheiros',
      description:
          'Clássica experiência italiana com cozinha refinada, ambiente charmoso e sobremesas marcantes.',
      price: 119.90,
      imageUrl:
          'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/1d/37/3c/04/aguzzo-cucina-italiana.jpg?w=1000&h=-1&s=1',
      menu: 'Massas frescas, risotos, carnes, pizzas e entradas italianas.',
      location: 'Rua Fradique Coutinho, 170 - Pinheiros/SP',
      schedule: 'Segunda a domingo, das 12:00 às 23:00',
      parking: 'Estacionamento no local e ruas próximas.',
    ),
    Promotion(
      id: 4,
      title: 'Hub Food Art Lounge',
      description:
          'Restaurante moderno com grelhados no Josper, atmosfera compartilhada e cardápio cosmopolita.',
      price: 109.90,
      imageUrl:
          'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/18/2b/42/c7/polvo-grelhado-no-josper.jpg?w=900&h=500&s=1',
      menu: 'Grelhados, petiscos, pratos de forno, drinks e seleções de vinhos.',
      location: 'Rua Oscar Freire, 840 - Jardins/SP',
      schedule: 'Todos os dias, das 06:00 às 23:00',
      parking: 'Estacionamento exclusivo para clientes.',
    ),
    Promotion(
      id: 5,
      title: 'Adega Santiago Shopping Cidade Jardim',
      description:
          'Ambiente refinado para encontros, saborosas entradas e uma carta de vinhos premium.',
      price: 149.90,
      imageUrl:
          'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0f/7e/f5/b2/adega-santiago.jpg?w=900&h=500&s=1',
      menu: 'Entradas, pratos de cozinha, petiscos e vinhos selecionados.',
      location: 'Shopping Cidade Jardim - São Paulo/SP',
      schedule: 'Segunda a domingo, das 12:00 às 23:00',
      parking: 'Estacionamento do shopping com vagas para clientes.',
    ),
    Promotion(
      id: 6,
      title: 'Osteria Generale',
      description:
          'Culinária italiana com pratos clássicos, ambiente acolhedor e execução impecável.',
      price: 139.90,
      imageUrl:
          'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/1a/8b/c7/03/bacalhau-a-portuguesa.jpg?w=900&h=500&s=1',
      menu: 'Massas, risotos, frutos do mar, entradas e sobremesas italianas.',
      location: 'Jardins - São Paulo/SP',
      schedule: 'Segunda a domingo, das 12:00 às 22:30',
      parking: 'Estacionamento no local e ruas próximas.',
    ),
    Promotion(
      id: 7,
      title: 'Tadashii Japanese Restaurant',
      description:
          'Cozinha japonesa contemporânea com sushi, sashimi e um ambiente elegante e moderno.',
      price: 159.90,
      imageUrl:
          'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/26/b6/55/37/caption.jpg?w=900&h=-1&s=1',
      menu: 'Sushis, sashimis, combinados, tempurás e pratos quentes.',
      location: 'Moema - São Paulo/SP',
      schedule: 'Segunda a domingo, das 12:00 às 23:00',
      parking: 'Vagas na rua e estacionamento próximo.',
    ),
  ];

  final List<Promotion> _localPromotions = <Promotion>[];
  final http.Client _client;
  final String _baseUrl;

  Future<List<Promotion>> fetchPromotions() async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/Restaurantes'));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Erro ao buscar restaurantes');
      }

      final payload = jsonDecode(response.body) as List<dynamic>;
      final restaurants = payload
          .whereType<Map<String, dynamic>>()
          .map((item) => Promotion.fromRemoteJson(item))
          .toList();

      _localPromotions
        ..clear()
        ..addAll(restaurants);

      return restaurants;
    } catch (_) {
      final merged = <Promotion>[];
      final seenIds = <int>{};
      for (final promotion in [..._defaultPromotions, ..._localPromotions]) {
        if (seenIds.add(promotion.id)) {
          merged.add(promotion);
        }
      }
      return merged;
    }
  }

  Future<Promotion> createPromotion(Promotion promotion) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/Restaurantes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(promotion.toRemoteJson()),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Não foi possível criar o restaurante');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final created = Promotion.fromRemoteJson(data);
    _localPromotions.add(created);
    return created;
  }

  Future<void> updatePromotion(Promotion promotion) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/Restaurantes/${promotion.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(promotion.toRemoteJson()),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Não foi possível atualizar o restaurante');
    }

    final index = _localPromotions.indexWhere((item) => item.id == promotion.id);
    if (index >= 0) {
      _localPromotions[index] = promotion;
    } else {
      _localPromotions.add(promotion);
    }
  }

  Future<void> deletePromotion(int id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/Restaurantes/$id'));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Não foi possível excluir o restaurante');
    }

    _localPromotions.removeWhere((promotion) => promotion.id == id);
  }
}
