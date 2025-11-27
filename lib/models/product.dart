import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String unit;
  final String imageUrl;
  final String category;
  final bool isFeatured;
  final String deliveryTime;
  final int discount;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.unit,
    required this.imageUrl,
    required this.category,
    this.isFeatured = false,
    this.deliveryTime = "15 mins",
    this.discount = 0,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // HELPER: Safely parse numbers even if they are Strings in database
    double parseDouble(dynamic value) {
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Product(
      id: doc.id,
      name: data['name'] as String? ?? 'Unknown Product',
      description: data['description'] as String? ?? '',

      // SAFE PARSING: Handles "100", 100, and 100.0
      price: parseDouble(data['price']),
      originalPrice: data['originalPrice'] != null ? parseDouble(data['originalPrice']) : null,

      unit: data['unit'] as String? ?? '1 pc',
      imageUrl: data['imageUrl'] as String? ?? '',
      category: data['category'] as String? ?? 'General',
      isFeatured: data['isFeatured'] as bool? ?? false,
      deliveryTime: data['deliveryTime'] as String? ?? '20 mins',
      discount: parseInt(data['discount']),
    );
  }
}
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}