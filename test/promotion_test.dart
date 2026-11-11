import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:onde_comer/models/promotion.dart';
import 'package:onde_comer/services/local_storage_service.dart';
import 'package:onde_comer/services/promotion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  test('Promotion serializes public API fields', () {
    const promotion = Promotion(
      id: 10,
      title: 'Feijoada da casa',
      description: 'Porção completa',
      price: 39.90,
      imageUrl: 'image.jpg',
    );

    final json = promotion.toRemoteJson();

    expect(json['title'], 'Feijoada da casa');
    expect(json['body'], contains('Porção completa'));
    expect(json['userId'], 1);
  });

  test('Promotion copyWith updates only selected fields', () {
    const promotion = Promotion(
      id: 1,
      title: 'Original',
      description: 'Descrição',
      price: 20,
      imageUrl: 'image.jpg',
    );

    final updated = promotion.copyWith(title: 'Atualizado', price: 25);

    expect(updated.title, 'Atualizado');
    expect(updated.price, 25);
    expect(updated.description, 'Descrição');
  });

  test('PromotionService uses the provided restaurant data', () async {
    final promotions = await PromotionService().fetchPromotions();

    expect(promotions, isNotEmpty);
    expect(
      promotions.any((promotion) => promotion.title.contains('Bacalhau')),
      isTrue,
    );
    expect(
      promotions.any((promotion) => promotion.title.contains('Jam')),
      isTrue,
    );
    expect(
      promotions.any((promotion) => promotion.title.contains('Hub')),
      isTrue,
    );
    expect(
      promotions.any((promotion) => promotion.title.contains('Adega Santiago')),
      isTrue,
    );
    expect(
      promotions.any((promotion) => promotion.title.contains('Osteria Generale')),
      isTrue,
    );
    expect(
      promotions.any((promotion) => promotion.title.contains('Tadashii')),
      isTrue,
    );
    expect(
      promotions.first.imageUrl.contains('tripadvisor') ||
          promotions.first.imageUrl.contains('images.unsplash'),
      isTrue,
    );
  });

  test('PromotionService keeps created promotions in the local list', () async {
    final client = _FakePromotionClient();
    final service = PromotionService(client: client, baseUrl: 'https://example.com');

    final created = await service.createPromotion(
      const Promotion(
        id: 99,
        title: 'Restaurante novo',
        description: 'Descrição do novo restaurante',
        price: 45,
        imageUrl: 'https://example.com/foto.jpg',
      ),
    );

    final promotions = await service.fetchPromotions();

    expect(created.title, 'Restaurante novo');
    expect(
      promotions.any((promotion) => promotion.id == created.id),
      isTrue,
    );
  });

  test('Profile data stores name, CEP and booking time locally', () async {
    final storage = LocalStorageService();

    await storage.saveProfile(
      name: 'Maria',
      cep: '05477-000',
      address: 'Rua das Flores, 123',
      phone: '(11) 99999-0000',
      reservationTime: '2026-11-09 19:30',
    );

    final profile = await storage.getCustomer();
    expect(profile['name'], 'Maria');
    expect(profile['cep'], '05477-000');
    expect(profile['reservationTime'], '2026-11-09 19:30');
  });
}

class _FakePromotionClient implements http.Client {
  @override
  Future<http.Response> post(
    Uri url, {
    Object? body,
    Map<String, String>? headers,
    Encoding? encoding,
  }) async {
    final payload = jsonDecode(body as String) as Map<String, dynamic>;
    return http.Response(
      jsonEncode({
        ...payload,
        'id': 99,
      }),
      201,
    );
  }

  @override
  void close() {}

  @override
  Future<http.Response> delete(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) async =>
      http.Response('', 200);

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async =>
      http.Response('', 200);

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) async =>
      http.Response('', 200);

  @override
  Future<http.Response> patch(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) async =>
      http.Response('', 200);

  @override
  Future<http.Response> put(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) async =>
      http.Response('', 200);

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) async => '';

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) async =>
      Uint8List(0);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(Stream.value([]), 200);
}
