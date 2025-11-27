import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Auth
import '../DatabaseService.dart';
import '../models/product.dart';

class AddressProvider with ChangeNotifier {
  UserAddress? _selectedAddress;
  List<UserAddress> _addresses = [];

  // Subscriptions
  StreamSubscription? _addressSubscription;
  StreamSubscription? _authSubscription;

  UserAddress? get selectedAddress => _selectedAddress;
  List<UserAddress> get addresses => _addresses;

  // Initialize: Listen to Auth Changes FIRST
  void init() {
    // Cancel any existing listeners to avoid duplicates
    _authSubscription?.cancel();

    // Listen for User Login/Logout events
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _addressSubscription?.cancel(); // Stop listening to old user's addresses

      if (user != null) {
        // ✅ NEW USER LOGGED IN: Fetch THEIR addresses
        _addressSubscription = DatabaseService().getUserAddresses().listen((List<UserAddress> addrList) {
          _addresses = addrList;
          _updateSelectedAddress(addrList);
          notifyListeners();
        });
      } else {
        // ❌ USER LOGGED OUT: Clear data
        _addresses = [];
        _selectedAddress = null;
        notifyListeners();
      }
    });
  }

  // Helper logic to pick a default address
  void _updateSelectedAddress(List<UserAddress> addrList) {
    if (_selectedAddress == null || !addrList.any((a) => a.id == _selectedAddress!.id)) {
      if (addrList.isNotEmpty) {
        // Prefer default, otherwise pick first
        _selectedAddress = addrList.firstWhere(
                (a) => a.isDefault,
            orElse: () => addrList.first
        );
      } else {
        _selectedAddress = null;
      }
    }
  }

  void selectAddress(UserAddress address) {
    _selectedAddress = address;
    notifyListeners();
  }

  @override
  void dispose() {
    _addressSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}