import 'package:flutter/material.dart';
import 'package:onde_comer/models/cart_item.dart';
import 'package:onde_comer/models/promotion.dart';
import 'package:onde_comer/screens/profile_screen.dart';
import 'package:onde_comer/services/local_storage_service.dart';
import 'package:onde_comer/services/promotion_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PromotionService _service = PromotionService();
  final LocalStorageService _localStorage = LocalStorageService();
  final List<CartItem> _cart = [];
  Set<int> _favorites = {};
  Future<List<Promotion>>? _promotions;

  @override
  void initState() {
    super.initState();
    _promotions = _service.fetchPromotions();
    _loadFavorites();
    _loadCart();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _localStorage.getFavorites();
    if (mounted) setState(() => _favorites = favorites);
  }

  Future<void> _loadCart() async {
    final cart = await _localStorage.getCart();
    if (mounted) setState(() => _cart.addAll(cart));
  }

  Future<void> _saveCart() async {
    await _localStorage.saveCart(_cart);
  }

  Future<void> _toggleFavorite(int id) async {
    await _localStorage.toggleFavorite(id);
    await _loadFavorites();
  }

  void _addToCart(Promotion promotion) {
    final index = _cart.indexWhere((item) => item.promotion.id == promotion.id);
    setState(() {
      if (index >= 0) {
        _cart[index] = _cart[index].copyWith(quantity: _cart[index].quantity + 1);
      } else {
        _cart.add(CartItem(promotion: promotion, quantity: 1));
      }
    });
    _saveCart();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${promotion.title} adicionado ao pedido')),
    );
  }

  double get _cartTotal =>
      _cart.fold(0, (total, item) => total + item.total);

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
            tooltip: 'Meu perfil e entrega',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            icon: const Icon(Icons.person_outline),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: 'Carrinho',
                onPressed: _openCart,
                icon: const Icon(Icons.shopping_bag_outlined),
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 5,
                  top: 5,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      '${_cart.length}',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPromotionForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nova promoção'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sabores perto de você',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Encontre pratos especiais da nossa cidade',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            FutureBuilder<List<Promotion>>(
              future: _promotions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(
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
                    ),
                  );
                }
                final promotions = snapshot.data!;
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList.separated(
                    itemCount: promotions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _PromotionCard(
                        promotion: promotions[index],
                        isFavorite: _favorites.contains(promotions[index].id),
                        onFavorite: () => _toggleFavorite(promotions[index].id),
                        onAdd: () => _addToCart(promotions[index]),
                        onEdit: () => _showPromotionForm(promotion: promotions[index]),
                        onDelete: () => _deletePromotion(promotions[index]),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePromotion(Promotion promotion) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir promoção?'),
        content: Text('Deseja excluir "${promotion.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _service.deletePromotion(promotion.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Promoção excluída')),
      );
      _reload();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _showPromotionForm({Promotion? promotion}) async {
    final titleController = TextEditingController(text: promotion?.title);
    final descriptionController =
        TextEditingController(text: promotion?.description);
    final priceController =
        TextEditingController(text: promotion?.price.toStringAsFixed(2));

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                promotion == null ? 'Nova promoção' : 'Editar promoção',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Preço',
                  prefixText: 'R\$ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final price =
                        double.tryParse(priceController.text.replaceAll(',', '.')) ??
                            0;
                    if (titleController.text.trim().isEmpty || price <= 0) {
                      return;
                    }
                    final model = Promotion(
                      id: promotion?.id ?? 0,
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      price: price,
                      imageUrl: promotion?.imageUrl ??
                          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&q=80',
                    );
                    try {
                      if (promotion == null) {
                        await _service.createPromotion(model);
                      } else {
                        await _service.updatePromotion(model);
                      }
                      if (context.mounted) Navigator.of(context).pop(true);
                    } catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())),
                        );
                      }
                    }
                  },
                  child: Text(promotion == null ? 'Publicar' : 'Salvar'),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (result == true) {
      _reload();
    }
  }

  void _openCart() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Meu pedido', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    if (_cart.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(child: Text('Seu carrinho está vazio')),
                      )
                    else
                      ..._cart.map((item) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.promotion.title),
                          subtitle: Text(
                            'R\$ ${item.promotion.price.toStringAsFixed(2)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (item.quantity <= 1) {
                                      _cart.remove(item);
                                    } else {
                                      final index = _cart.indexOf(item);
                                      _cart[index] =
                                          item.copyWith(quantity: item.quantity - 1);
                                    }
                                  });
                                  _saveCart();
                                  setModalState(() {});
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    final index = _cart.indexOf(item);
                                    _cart[index] =
                                        item.copyWith(quantity: item.quantity + 1);
                                  });
                                  _saveCart();
                                  setModalState(() {});
                                },
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        );
                      }),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total'),
                        Text(
                          'R\$ ${_cartTotal.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _cart.isEmpty ? null : () {
                          Navigator.of(context).pop();
                          setState(() => _cart.clear());
                          _saveCart();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pedido enviado para consulta!')),
                          );
                        },
                        child: const Text('Finalizar pedido'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PromotionCard extends StatelessWidget {
  const _PromotionCard({
    required this.promotion,
    required this.isFavorite,
    required this.onFavorite,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final Promotion promotion;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onAdd;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  promotion.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const ColoredBox(
                    color: Color(0xFFEDE7E1),
                    child: Icon(Icons.restaurant, size: 48),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: onFavorite,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        promotion.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Editar')),
                        PopupMenuItem(value: 'delete', child: Text('Excluir')),
                      ],
                    ),
                  ],
                ),
                Text(
                  promotion.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'R\$ ${promotion.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    FilledButton.icon(
                      onPressed: onAdd,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
