import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart'; // Ensure this imports the lowercase file

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections
  CollectionReference get _productsRef => _db.collection('products');
  CollectionReference get _ordersRef => _db.collection('orders');
  CollectionReference get _categoriesRef => _db.collection('categories');

  // Get Products Stream
  Stream<List<Product>> getProducts() {
    return _productsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromFirestore(doc);
      }).toList();
    });
  }

  // Get Categories
  Stream<List<Map<String, dynamic>>> getCategories() {
    return _categoriesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  Future<void> createOrder(Map<String, dynamic> orderData) async {
    try {
      await _ordersRef.add(orderData);
    } catch (e) {
      print("Error placing order: $e");
      throw Exception("Failed to place order. Please check your internet connection.");
    }
  }
}