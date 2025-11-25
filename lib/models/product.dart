import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String unit;
  final String imageUrl;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.imageUrl,
    required this.category,
  });

  // Factory constructor for safe data parsing from Firestore
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Product(
      id: doc.id,
      name: data['name'] ?? 'Unknown Product',
      description: data['description'] ?? '',
      // Robust parsing: Handle both int and double for price
      price: (data['price'] is int)
          ? (data['price'] as int).toDouble()
          : (data['price'] as double? ?? 0.0),
      unit: data['unit'] ?? 'pcs',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? 'General',
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}