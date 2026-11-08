import 'package:flutter_test/flutter_test.dart';
import 'package:onde_comer/models/promotion.dart';

void main() {
  test('Promotion serializes public API fields', () {
    final promotion = Promotion(
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
    final promotion = Promotion(
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
}
