import 'package:flutter/material.dart';
import 'package:onde_comer/models/promotion.dart';
import 'package:onde_comer/models/review.dart';

class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({super.key, required this.restaurant});

  final Promotion restaurant;

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  double _selectedRating = 5;
  late List<RestaurantReview> _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = _buildReviewsForRestaurant(widget.restaurant);
  }

  List<RestaurantReview> _buildReviewsForRestaurant(Promotion restaurant) {
    final seed = restaurant.id;
    final names = ['Marina', 'Thiago', 'Beatriz', 'Lucas', 'Nina', 'Rafa'];
    final reviewPool = [
      'Ambiente incrível e muito bem cuidado. A experiência foi memorável do começo ao fim.',
      'Comida muito saborosa e bem servida. Vale muito a pena voltar novamente.',
      'Atendimento atencioso, pratos bem apresentados e ambiente bem acolhedor.',
      'Gostei bastante do sabor e da atmosfera. A escolha foi certeira para o jantar.',
      'Excelente experiência gastronômica com atenção especial aos detalhes.',
      'Lugar agradável, com pratos bem executados e um serviço bem profissional.',
    ];

    final reviews = <RestaurantReview>[];
    for (var i = 0; i < 3; i++) {
      final name = names[(seed + i) % names.length];
      final comment = reviewPool[(seed + i) % reviewPool.length];
      final rating = 3 + ((seed + i) % 3);
      final likes = 8 + ((seed * 3 + i) % 16);
      reviews.add(
        RestaurantReview(
          id: seed * 10 + i,
          author: name,
          comment: comment,
          rating: rating,
          likes: likes,
        ),
      );
    }

    return reviews;
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    return _reviews.fold<double>(0, (sum, review) => sum + review.rating) / _reviews.length;
  }

  Future<void> _openReservationSheet(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );

    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 19, minute: 30),
    );

    if (time == null || !context.mounted) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final formatted =
        '${selected.day.toString().padLeft(2, '0')}/${selected.month.toString().padLeft(2, '0')}/${selected.year} • ${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reserva marcada para ${widget.restaurant.title} em $formatted'),
      ),
    );
  }

  void _toggleLike(int reviewId) {
    setState(() {
      final index = _reviews.indexWhere((review) => review.id == reviewId);
      if (index == -1) return;

      final review = _reviews[index];
      _reviews[index] = review.copyWith(
        likedByMe: !review.likedByMe,
        likes: review.likedByMe ? review.likes - 1 : review.likes + 1,
      );
    });
  }

  void _submitReview() {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escreva uma avaliação antes de enviar.')),
      );
      return;
    }

    setState(() {
      _reviews.insert(
        0,
        RestaurantReview(
          id: DateTime.now().millisecondsSinceEpoch,
          author: 'Você',
          comment: comment,
          rating: _selectedRating.round(),
          likes: 0,
        ),
      );
      _commentController.clear();
      _selectedRating = 5;
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.restaurant.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.restaurant.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF163026),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFB703), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        _averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Color(0xFF24513E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2EAE6)),
                    ),
                    child: Text(
                      widget.restaurant.description,
                      style: const TextStyle(
                        color: Color(0xFF234132),
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openReservationSheet(context),
                      icon: const Icon(Icons.schedule_outlined),
                      label: const Text('Marcar horário'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _InfoRow(
                    icon: Icons.restaurant_menu_rounded,
                    title: 'Cardápio',
                    value: widget.restaurant.menu,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    title: 'Horário de funcionamento',
                    value: widget.restaurant.schedule,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.local_parking_rounded,
                    title: 'Estacionamento',
                    value: widget.restaurant.parking,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.location_on_rounded,
                    title: 'Localização',
                    value: widget.restaurant.location,
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Avaliações',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF163026),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2EAE6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sua avaliação',
                          style: TextStyle(
                            color: Color(0xFF163026),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(5, (index) {
                            final filled = index < _selectedRating;
                            return IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => setState(() => _selectedRating = index + 1),
                              icon: Icon(
                                filled ? Icons.star_rounded : Icons.star_border_rounded,
                                color: const Color(0xFFFFD166),
                                size: 28,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _commentController,
                          maxLength: 150,
                          maxLines: 4,
                          minLines: 2,
                          decoration: const InputDecoration(
                            hintText: 'Escreva sua experiência (máx. 150 caracteres)',
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _submitReview,
                            icon: const Icon(Icons.send_rounded),
                            label: const Text('Enviar comentário'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._reviews.map(
                    (review) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ReviewCard(
                        review: review,
                        onLike: () => _toggleLike(review.id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.onLike});

  final RestaurantReview review;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2EAE6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.author,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF163026),
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  final filled = index < review.rating;
                  return Icon(
                    filled ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 16,
                    color: const Color(0xFFFFD166),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(
              color: Color(0xFF234132),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: onLike,
                icon: Icon(
                  review.likedByMe ? Icons.thumb_up_alt_rounded : Icons.thumb_up_alt_outlined,
                  color: Color(review.likedByMe ? 0xFF2DBE6A : 0xFF5B736A),
                ),
              ),
              Text(
                '${review.likes}',
                style: const TextStyle(
                  color: Color(0xFF24513E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EAE6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2DBE6A), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF163026),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF234132),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
