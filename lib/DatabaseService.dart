import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- COLLECTIONS REFERENCES ---
  CollectionReference get _productsRef => _db.collection('products');
  CollectionReference get _ordersRef => _db.collection('orders');
  CollectionReference get _categoriesRef => _db.collection('categories');

  // --- PRODUCTS & CATEGORIES ---

  // Get all products
  Stream<List<Product>> getProducts() {
    return _productsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // Get all categories
  Stream<List<Map<String, dynamic>>> getCategories() {
    return _categoriesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  // --- ORDERS ---

  // Create a new order
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    try {
      await _ordersRef.add(orderData);
    } catch (e) {
      print("Error placing order: $e");
      throw Exception("Failed to place order.");
    }
  }

  // Get current user's order history
  Stream<List<Map<String, dynamic>>> getUserOrders() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _ordersRef
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // --- ADDRESS MANAGEMENT ---

  // Get user addresses sorted by Default first
  Stream<List<UserAddress>> getUserAddresses() {
    final user = _auth.currentUser;

    // Security Check: If no user, return empty immediately
    if (user == null) return Stream.value([]);

    // ✅ Uses user.uid -> This ensures we ONLY get this user's data
    return _db
        .collection('users')
        .doc(user.uid)
        .collection('addresses')
        .orderBy('isDefault', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserAddress.fromFirestore(doc)).toList();
    });
  }

  // Add a new address
  Future<void> addAddress(UserAddress address) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _db.batch();
    final newDoc = _db.collection('users').doc(user.uid).collection('addresses').doc();

    // If setting as default, remove default status from others
    if (address.isDefault) {
      final allDocs = await _db.collection('users').doc(user.uid).collection('addresses').get();
      for (var doc in allDocs.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
    }

    batch.set(newDoc, address.toMap());
    await batch.commit();
  }

  // Update an existing address
  Future<void> updateAddress(UserAddress address) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _db.batch();
    final docRef = _db.collection('users').doc(user.uid).collection('addresses').doc(address.id);

    if (address.isDefault) {
      final allDocs = await _db.collection('users').doc(user.uid).collection('addresses').get();
      for (var doc in allDocs.docs) {
        if (doc.id != address.id) {
          batch.update(doc.reference, {'isDefault': false});
        }
      }
    }

    batch.update(docRef, address.toMap());
    await batch.commit();
  }

  // Delete an address
  Future<void> deleteAddress(String addressId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).collection('addresses').doc(addressId).delete();
  }
}