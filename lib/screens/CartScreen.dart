import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../themes.dart';


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
      backgroundColor: const Color(0xFFF5F7FD),
      appBar: AppBar(
        title: const Text("My Cart", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) return _buildEmptyState(context);

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Delivery Time Banner
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppTheme.qcGreenLight, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.timer, color: AppTheme.qcGreen),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Delivery in 10 minutes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text("Shipment of 1 item", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                ),

                // 2. Cart Items List
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Items Added", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cart.items.length,
                        separatorBuilder: (_, __) => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        itemBuilder: (ctx, i) {
                          final item = cart.items.values.toList()[i];
                          return _buildCartRow(item, cart);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 3. Bill Details Widget
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Bill Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 12),
                      _buildBillRow("Item Total", cart.totalAmount),
                      _buildBillRow("Handling Charge", 5.00),
                      _buildBillRow("Delivery Fee", 30.00, isStrike: cart.totalAmount > 100),
                      const Divider(height: 24),
                      _buildBillRow("To Pay", cart.totalAmount + 5.00 + (cart.totalAmount > 100 ? 0 : 30), isTotal: true),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 4. Cancellation Policy
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Cancellation Policy: Orders cannot be cancelled once packed for delivery. In case of unexpected delays, a refund will be provided, if applicable.",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11, height: 1.4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomSheet: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) return const SizedBox.shrink();

          final total = cart.totalAmount + 5.00 + (cart.totalAmount > 100 ? 0 : 30);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("₹${total.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                      const Text("TOTAL", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _placeOrder(cart),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.qcGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Place Order", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10)]),
            child: Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          const Text("Your cart is empty", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Add items to start a cart", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Start Shopping"))
        ],
      ),
    );
  }

  Widget _buildCartRow(CartItem item, CartProvider cart) {
    return Row(
      children: [
        // Name and Unit
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.product.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text(item.product.unitText, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 4),
              Text("₹${item.product.price.toInt()}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),

        // Counter
        Container(
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.qcGreen,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () => cart.removeItem(item.product.id),
                child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.remove, color: Colors.white, size: 14)),
              ),
              Text("${item.quantity}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              InkWell(
                onTap: () => cart.addItem(item.product),
                child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.add, color: Colors.white, size: 14)),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildBillRow(String label, double amount, {bool isTotal = false, bool isStrike = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 15 : 13,
              color: isTotal ? Colors.black : Colors.grey.shade700
          )),
          Row(
            children: [
              if (isStrike) ...[
                Text("₹$amount", style: const TextStyle(decoration: TextDecoration.lineThrough, fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 4),
                const Text("FREE", style: TextStyle(color: AppTheme.qcGreen, fontWeight: FontWeight.bold, fontSize: 12)),
              ] else
                Text("₹${amount.toStringAsFixed(2)}", style: TextStyle(
                    fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
                    fontSize: isTotal ? 15 : 13
                )),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _placeOrder(CartProvider cart) async {
    setState(() => _isLoading = true);
    try {
      await cart.placeOrder();
      if(mounted) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: AppTheme.qcGreen, size: 60),
                  SizedBox(height: 16),
                  Text("Order Placed!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("Your items are on the way.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Close cart
                    },
                    child: const Text("OK")
                )
              ],
            )
        );
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $e")));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }
}