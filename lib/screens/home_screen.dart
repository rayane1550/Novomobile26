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
  final TextEditingController _searchController = TextEditingController();
  Future<List<Promotion>>? _promotions;
  String _selectedCategory = 'Tudo';

  String _promoLabelFor(Promotion restaurant) {
    final seed = restaurant.id % 5;
    final labels = <String>[
      '30% OFF',
      '2x1',
      'Chef Pick',
      'Happy Hour',
      'Combo +2',
    ];
    return labels[seed];
  }

  @override
  void initState() {
    super.initState();
    _promotions = _service.fetchPromotions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() => _promotions = _service.fetchPromotions());
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
            final query = _searchController.text.trim();
            final filteredRestaurants = restaurants.where((restaurant) {
              final title = restaurant.title.toLowerCase();
              final description = restaurant.description.toLowerCase();
              final matchesQuery = query.isEmpty ||
                  title.startsWith(query.toLowerCase()) ||
                  title.contains(query.toLowerCase()) ||
                  description.contains(query.toLowerCase());

              if (!matchesQuery) {
                return false;
              }

              if (_selectedCategory == 'Tudo') {
                return true;
              }

              final categoryLower = _selectedCategory.toLowerCase();
              if (categoryLower == 'japonesa') {
                return title.contains('jam') || description.contains('japonesa') || title.contains('japanese');
              }
              if (categoryLower == 'italiana') {
                return title.contains('aguzzo') || description.contains('italiana');
              }
              if (categoryLower == 'bacalhau') {
                return title.contains('bacalhau') || description.contains('bacalhau');
              }
              if (categoryLower == 'top') {
                return title.contains('adega') || title.contains('hub') || title.contains('jam') || title.contains('aguzzo');
              }

              return true;
            }).toList();

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
                      const SizedBox(height: 18),
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Buscar restaurante por inicial (ex.: J)',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.clear_rounded),
                                ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              label: 'Tudo',
                              selected: _selectedCategory == 'Tudo',
                              onTap: () => setState(() => _selectedCategory = 'Tudo'),
                            ),
                            _FilterChip(
                              label: 'Japonesa',
                              selected: _selectedCategory == 'Japonesa',
                              onTap: () => setState(() => _selectedCategory = 'Japonesa'),
                            ),
                            _FilterChip(
                              label: 'Italiana',
                              selected: _selectedCategory == 'Italiana',
                              onTap: () => setState(() => _selectedCategory = 'Italiana'),
                            ),
                            _FilterChip(
                              label: 'Bacalhau',
                              selected: _selectedCategory == 'Bacalhau',
                              onTap: () => setState(() => _selectedCategory = 'Bacalhau'),
                            ),
                            _FilterChip(
                              label: 'Top',
                              selected: _selectedCategory == 'Top',
                              onTap: () => setState(() => _selectedCategory = 'Top'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (filteredRestaurants.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF17231F),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF2D413C)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.search_off_rounded, size: 36, color: Color(0xFF8AE6A8)),
                        const SizedBox(height: 10),
                        Text(
                          'Nenhum restaurante encontrado para "$query".',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFFE8F0EC)),
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredRestaurants.map((restaurant) {
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
                                            color: const Color(0xFF2DBE6A).withValues(alpha: 0.16),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            _promoLabelFor(restaurant),
                                            style: const TextStyle(
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
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2DBE6A) : const Color(0xFF1D322B),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFF8AE6A8) : const Color(0xFF395F4F),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF062C17) : const Color(0xFFEAF8F0),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
