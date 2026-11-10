class Promotion {
  const Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.menu = '',
    this.location = '',
    this.schedule = '',
    this.parking = '',
  });

  final int id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String menu;
  final String location;
  final String schedule;
  final String parking;

  factory Promotion.fromRemoteJson(Map<String, dynamic> json, {int index = 0}) {
    final images = [
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=900&q=80',
    ];

    final rawPrice = json['price'] ?? json['preco'];
    final parsedPrice = rawPrice is num ? rawPrice.toDouble() : 24 + (index * 5.50);

    return Promotion(
      id: json['id'] as int? ?? 0,
      title: (json['title'] ?? json['nome'])?.toString() ?? 'Restaurante especial',
      description:
          (json['body'] ?? json['descricao'])?.toString() ?? 'Experiência gastronômica pensada para você.',
      price: parsedPrice,
      imageUrl: (json['imageUrl'] ?? json['imagem'])?.toString() ??
          images[index % images.length],
      menu: (json['menu'] ?? json['cardapio'])?.toString() ?? 'Pratos especiais da casa',
      location: (json['location'] ?? json['localizacao'])?.toString() ?? 'Centro da cidade',
      schedule: (json['schedule'] ?? json['horario'])?.toString() ?? 'Segunda a domingo',
      parking: (json['parking'] ?? json['estacionamento'])?.toString() ?? 'Estacionamento disponível',
    );
  }

  Map<String, dynamic> toRemoteJson() {
    return {
      'id': id,
      'title': title,
      'body': description,
      'price': price,
      'imageUrl': imageUrl,
      'menu': menu,
      'location': location,
      'schedule': schedule,
      'parking': parking,
      'userId': 1,
      'nome': title,
      'descricao': description,
      'cardapio': menu,
      'localizacao': location,
      'horario': schedule,
      'estacionamento': parking,
      'imagem': imageUrl,
      'categoria': 'Restaurante',
      'preco': price,
    };
  }

  Promotion copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    String? imageUrl,
    String? menu,
    String? location,
    String? schedule,
    String? parking,
  }) {
    return Promotion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      menu: menu ?? this.menu,
      location: location ?? this.location,
      schedule: schedule ?? this.schedule,
      parking: parking ?? this.parking,
    );
  }
}
