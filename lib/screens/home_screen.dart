import 'package:flutter/material.dart';
import 'package:onde_comer/models/promotion.dart';
import 'package:onde_comer/screens/about_screen.dart';
import 'package:onde_comer/screens/profile_screen.dart';
import 'package:onde_comer/screens/restaurant_detail_screen.dart';
import 'package:onde_comer/services/promotion_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PromotionService _service = PromotionService();
  Future<List<Promotion>>? _promotions;

  @override
  void initState() {
    super.initState();
    _promotions = _service.fetchPromotions();
  }

  void _reload() {
    setState(() => _promotions = _service.fetchPromotions());
  }

  Future<void> _showRestaurantForm() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageUrlController = TextEditingController(
      text: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=80',
    );
    final menuController = TextEditingController();
    final locationController = TextEditingController();
    final scheduleController = TextEditingController();
    final parkingController = TextEditingController();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adicionar restaurante',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Nome do restaurante'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(labelText: 'URL da imagem'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: menuController,
                  decoration: const InputDecoration(labelText: 'Cardápio'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Localização'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: scheduleController,
                  decoration: const InputDecoration(labelText: 'Horário de funcionamento'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: parkingController,
                  decoration: const InputDecoration(labelText: 'Estacionamento'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      final description = descriptionController.text.trim();
                      final imageUrl = imageUrlController.text.trim();
                      final menu = menuController.text.trim();
                      final location = locationController.text.trim();
                      final schedule = scheduleController.text.trim();
                      final parking = parkingController.text.trim();

                      if (title.isEmpty || description.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nome e descrição são obrigatórios.')),
                        );
                        return;
                      }

                      try {
                        final created = await _service.createPromotion(
                          Promotion(
                            id: DateTime.now().millisecondsSinceEpoch,
                            title: title,
                            description: description,
                            price: 0,
                            imageUrl: imageUrl.isEmpty
                                ? 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=80'
                                : imageUrl,
                            menu: menu.isEmpty ? 'Pratos especiais da casa' : menu,
                            location: location.isEmpty ? 'São Paulo/SP' : location,
                            schedule: schedule.isEmpty ? 'Horário a confirmar' : schedule,
                            parking: parking.isEmpty ? 'Estacionamento disponível' : parking,
                          ),
                        );

                        if (!mounted) return;
                        Navigator.of(context, rootNavigator: true).pop(true);
                        if (created.id != 0) {
                          _reload();
                        }
                      } catch (error) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())),
                        );
                      }
                    },
                    child: const Text('Salvar restaurante'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == true) {
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onde Comer'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Meu perfil',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'Sobre o sistema',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<Promotion>>(
          future: _promotions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 48),
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString()),
                    TextButton(
                      onPressed: _reload,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            final restaurants = snapshot.data ?? const <Promotion>[];

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1C3127), Color(0xFF0E1715)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: const Color(0xFF325A4A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFF8AE6A8),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'São Paulo, SP',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFFD9F5E6),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sabores perto de você',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFF4FBF7),
                              letterSpacing: -0.8,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Descubra restaurantes, pratos e promoções do dia',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFFC7E5D4),
                            ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: const [
                            _FilterChip(label: 'Tudo'),
                            _FilterChip(label: 'Japonesa'),
                            _FilterChip(label: 'Italiano'),
                            _FilterChip(label: 'Bacalhau'),
                            _FilterChip(label: 'Top'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                ...restaurants.map((restaurant) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RestaurantDetailScreen(
                              restaurant: restaurant,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF294C3F)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 18,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                restaurant.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const ColoredBox(
                                  color: Color(0xFFEDE7E1),
                                  child: Icon(Icons.restaurant, size: 48),
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              color: const Color(0xFF18241F),
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          restaurant.title,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFFF1FAF4),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2DBE6A).withOpacity(0.16),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: const Text(
                                          '30% OFF',
                                          style: TextStyle(
                                            color: Color(0xFF9AE8B5),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    restaurant.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFFCFDDD3),
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 16,
                                        color: Color(0xFF8AE6A8),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          restaurant.location,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFFD9F5E6),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1D322B),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF395F4F)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFEAF8F0),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
