import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:onde_comer/models/cart_item.dart';
import 'package:onde_comer/models/promotion.dart';

class LocalStorageService {
  static const _nameKey = 'customer_name';
  static const _cepKey = 'customer_cep';
  static const _addressKey = 'customer_address';
  static const _phoneKey = 'customer_phone';
  static const _reservationTimeKey = 'customer_reservation_time';
  static const _favoritesKey = 'favorite_promotions';

  Future<void> saveProfile({
    required String name,
    required String cep,
    required String address,
    required String phone,
    String? reservationTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_cepKey, cep);
    await prefs.setString(_addressKey, address);
    await prefs.setString(_phoneKey, phone);
    if (reservationTime != null && reservationTime.isNotEmpty) {
      await prefs.setString(_reservationTimeKey, reservationTime);
    }
  }

  Future<void> saveCustomer({
    String? name,
    String? cep,
    required String address,
    required String phone,
    String? reservationTime,
  }) async {
    await saveProfile(
      name: name ?? '',
      cep: cep ?? '',
      address: address,
      phone: phone,
      reservationTime: reservationTime,
    );
  }

  Future<void> clearCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_cepKey);
    await prefs.remove(_addressKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_reservationTimeKey);
  }

  Future<Map<String, String>> getCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_nameKey) ?? '',
      'cep': prefs.getString(_cepKey) ?? '',
      'address': prefs.getString(_addressKey) ?? '',
      'phone': prefs.getString(_phoneKey) ?? '',
      'reservationTime': prefs.getString(_reservationTimeKey) ?? '',
    };
  }

  Future<void> toggleFavorite(int promotionId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? <String>[];
    final id = promotionId.toString();
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }
    await prefs.setStringList(_favoritesKey, favorites);
  }

  Future<Set<int>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? <String>[];
    return favorites
        .map((value) => int.tryParse(value))
        .whereType<int>()
        .toSet();
  }

  Future<void> saveCart(List<CartItem> cart) async {
    final prefs = await SharedPreferences.getInstance();
    final data = cart
        .map((item) => {
              'id': item.promotion.id,
              'title': item.promotion.title,
              'description': item.promotion.description,
              'price': item.promotion.price,
              'imageUrl': item.promotion.imageUrl,
              'quantity': item.quantity,
            })
        .toList();
    await prefs.setString('customer_cart', jsonEncode(data));
  }

  Future<List<CartItem>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('customer_cart');
    if (raw == null || raw.isEmpty) return [];

    try {
      final data = jsonDecode(raw) as List<dynamic>;
      return data.whereType<Map<String, dynamic>>().map((item) {
        final promotion = Promotion(
          id: item['id'] as int? ?? 0,
          title: item['title']?.toString() ?? 'Promoção',
          description: item['description']?.toString() ?? '',
          price: (item['price'] as num?)?.toDouble() ?? 0,
          imageUrl: item['imageUrl']?.toString() ?? '',
        );
        return CartItem(
          promotion: promotion,
          quantity: item['quantity'] as int? ?? 1,
        );
      }).toList();
    } catch (_) {
      await prefs.remove('customer_cart');
      return [];
    }
  }
}
