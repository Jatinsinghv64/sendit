import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../DatabaseService.dart';
import '../models/product.dart';


class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  final DatabaseService _dbService = DatabaseService();

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount {
    return _items.values.fold(0.0, (total, item) {
      return total + (item.product.price * item.quantity);
    });
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id] = CartItem(
        product: product,
        quantity: _items[product.id]!.quantity + 1,
      );
    } else {
      _items[product.id] = CartItem(
        product: product,
        quantity: 1,
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity > 1) {
        _items[productId] = CartItem(
          product: _items[productId]!.product,
          quantity: _items[productId]!.quantity - 1,
        );
      } else {
        _items.remove(productId);
      }
      notifyListeners();
    }
  }

  void removeItemCompletely(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<void> placeOrder() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      // Prepare order items
      final orderItems = _items.values.map((item) => {
        'productId': item.product.id,
        'name': item.product.name,
        'quantity': item.quantity,
        'price': item.product.price,
        'unit': item.product.unitText,
        'image': item.product.thumbnail,
      }).toList();

      // Calculate totals - convert deliveryFee to double
      final subtotal = totalAmount;
      final deliveryFee = subtotal > 299 ? 0.0 : 29.0; // Changed to double
      final total = subtotal + deliveryFee;

      // Create order
      await _dbService.createOrder(
        userId: user.uid,
        items: orderItems,
        subtotal: subtotal,
        deliveryFee: deliveryFee, // Now double
        total: total,
        addressId: '', // You need to get this from AddressProvider
      );

      // Clear cart after successful order
      clearCart();

    } catch (e) {
      rethrow;
    }
  }
}