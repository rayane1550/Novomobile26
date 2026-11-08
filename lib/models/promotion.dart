class Promotion {
  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  final int id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;

  factory Promotion.fromRemoteJson(Map<String, dynamic> json, {int index = 0}) {
    final images = [
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=900&q=80',
    ];
    return Promotion(
      id: json['id'] as int? ?? 0,
      title: json['title']?.toString() ?? 'Promoção especial',
      description: json['body']?.toString() ??
          'Uma sugestão deliciosa preparada para você.',
      price: 24 + (index * 5.50),
      imageUrl: images[index % images.length],
    );
  }

  Map<String, dynamic> toRemoteJson() {
    return {
      'title': title,
      'body': '$description\nPreço sugerido: R\$ ${price.toStringAsFixed(2)}',
      'userId': 1,
    };
  }

  Promotion copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    String? imageUrl,
  }) {
    return Promotion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
