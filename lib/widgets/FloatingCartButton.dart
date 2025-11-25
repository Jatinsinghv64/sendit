import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../screens/CartScreen.dart';


class FloatingCartButton extends StatelessWidget {
  const FloatingCartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        if (cart.itemCount == 0) return const SizedBox.shrink();

        return Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Material(
            color: const Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(12),
            elevation: 8,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // Fixes overflow
                        children: [
                          Text(
                            "${cart.itemCount} ITEM${cart.itemCount > 1 ? 'S' : ''}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "\$${cart.totalAmount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      "View Cart",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_right, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}