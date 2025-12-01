import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../DatabaseService.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';


class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("My Cart", style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return _buildEmptyState(context);
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (ctx, i) {
                    final item = cart.items.values.toList()[i];
                    final productId = cart.items.keys.toList()[i];

                    // Swipe to Dismiss functionality
                    return Dismissible(
                      key: Key(productId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEbee),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.red, size: 30),
                      ),
                      onDismissed: (direction) {
                        cart.removeItemCompletely(productId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${item.product.name} removed"),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: _buildCartItem(context, item, cart),
                    );
                  },
                ),
              ),
              _buildCheckoutSection(context, cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 24),
          Text("Your cart is empty", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Start Shopping"),
          )
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item, CartProvider cart) {
    final isOutOfStock = item.product.stock.availableQty <= 0;
    final itemTotal = item.product.price * item.quantity;

    return Container(
      decoration: BoxDecoration(
        color: isOutOfStock ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: item.product.thumbnail.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.product.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.grey),
              ),
            )
                : const Icon(Icons.image, color: Colors.grey),
          ),
          const SizedBox(width: 16),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isOutOfStock ? Colors.grey.shade500 : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isOutOfStock)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "Out of Stock",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${item.product.price.toStringAsFixed(2)} / ${item.product.unitText}",
                  style: TextStyle(
                    color: isOutOfStock ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Total: ₹${itemTotal.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isOutOfStock ? Colors.grey.shade500 : Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Quantity Counter
          Container(
            decoration: BoxDecoration(
              color: isOutOfStock ? Colors.grey.shade100 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                _qtyBtn(
                  Icons.remove,
                  isOutOfStock ? null : () => cart.removeItem(item.product.id),
                  disabled: isOutOfStock,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "${item.quantity}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isOutOfStock ? Colors.grey.shade500 : Colors.black,
                    ),
                  ),
                ),
                _qtyBtn(
                  Icons.add,
                  isOutOfStock
                      ? null
                      : () {
                    if (item.quantity >= item.product.stock.availableQty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Only ${item.product.stock.availableQty} items available"),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    cart.addItem(item.product);
                  },
                  disabled: isOutOfStock,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback? onTap, {bool disabled = false}) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(
          icon,
          size: 16,
          color: disabled ? Colors.grey.shade400 : Colors.black,
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, CartProvider cart) {
    final hasOutOfStockItems = cart.items.values.any((item) => item.product.stock.availableQty <= 0);
    final double deliveryFee = cart.totalAmount > 299 ? 0 : 29;
    final double finalTotal = cart.totalAmount + deliveryFee;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasOutOfStockItems)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Remove out of stock items to proceed",
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          _summaryRow("Subtotal", cart.totalAmount),
          const SizedBox(height: 8),
          _summaryRow("Delivery Fee", deliveryFee),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "₹${finalTotal.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading || hasOutOfStockItems ? null : () => _handleOrder(cart),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasOutOfStockItems ? Colors.grey : Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white),
              )
                  : Text(
                hasOutOfStockItems ? "Remove Out of Stock Items" : "Proceed to Checkout",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        Text(
          val == 0 ? "FREE" : "₹${val.toStringAsFixed(2)}",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: val == 0 ? Colors.green.shade700 : Colors.black,
          ),
        ),
      ],
    );
  }

  Future<void> _handleOrder(CartProvider cart) async {
    setState(() => _isLoading = true);
    try {
      await cart.placeOrder();
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Order Placed Successfully!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "₹${cart.totalAmount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Your order will be delivered soon",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close Dialog
                  Navigator.pop(context); // Close Cart
                },
                child: const Text(
                  "Continue Shopping",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}





