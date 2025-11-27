import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Auth
import '../models/product.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance for getting User ID

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

  // Place Order
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    try {
      await _ordersRef.add(orderData);
    } catch (e) {
      print("Error placing order: $e");
      throw Exception("Failed to place order: $e");
    }
  }

  // NEW: Get User's Past Orders
  Stream<List<Map<String, dynamic>>> getUserOrders() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]); // Return empty list if not logged in

    // NOTE: This query requires a Firestore Index.
    // Check your Debug Console for a link to create it automatically.
    return _ordersRef
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true) // Show newest first
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Keep document ID for reference
        return data;
      }).toList();
    });
  }
}