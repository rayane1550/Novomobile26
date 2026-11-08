import 'promotion.dart';

class CartItem {
  CartItem({
    required this.promotion,
    required this.quantity,
  });

  final Promotion promotion;
  final int quantity;

  double get total => promotion.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      promotion: promotion,
      quantity: quantity ?? this.quantity,
    );
  }
}
