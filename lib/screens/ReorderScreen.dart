import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Ensure 'intl' is in pubspec.yaml for date formatting
import 'package:provider/provider.dart';
import '../DatabaseService.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../themes.dart';

class ReorderScreen extends StatelessWidget {
  const ReorderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();

    return Scaffold(
      backgroundColor: AppTheme.background, // Light grey background
      appBar: AppBar(
        title: const Text("Past Orders"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove back button on tabs
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: dbService.getUserOrders(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State (Likely missing Index)
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text("Error: ${snapshot.error}\n\nCheck console for Index Link.", textAlign: TextAlign.center),
              ),
            );
          }

          // 3. Empty State
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.receipt_long_rounded, size: 60, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "No past orders yet",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Your order history will appear here",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      // FIX: Reset to Home Screen (Tab 0)
                      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Start Shopping"),
                  )
                ],
              ),
            );
          }

          // 4. List of Orders
          final orders = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildOrderCard(context, orders[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    final items = (order['items'] as List<dynamic>?) ?? [];
    final Timestamp? timestamp = order['createdAt'];
    final dateStr = timestamp != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate())
        : 'Processing...';

    final double total = (order['total'] is int)
        ? (order['total'] as int).toDouble()
        : (order['total'] as double? ?? 0.0);

    // Status styling
    final String status = order['status'] ?? 'Pending';
    Color statusColor = Colors.orange;
    if (status.toLowerCase() == 'delivered') statusColor = AppTheme.qcGreen;
    if (status.toLowerCase() == 'cancelled') statusColor = Colors.red;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          // Header: Shop Name & Status
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: Colors.black87, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Grocery Store", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text("Mumbai • $dateStr", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),

          // Item Summary
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatItemsList(items),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),

          // Footer: Total & Repeat Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total Paid", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(
                      "\$${total.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () => _repeatOrder(context, items),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text("REPEAT ORDER"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper: "2 x Milk, 1 x Bread"
  String _formatItemsList(List<dynamic> items) {
    if (items.isEmpty) return "No items";
    return items.map((i) => "${i['quantity']} x ${i['name']}").join(", ");
  }

  // Logic: Add Items Back to Cart
  void _repeatOrder(BuildContext context, List<dynamic> items) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    for (var item in items) {
      // Create a temporary product from history
      final product = Product(
        id: item['productId'],
        name: item['name'],
        price: (item['price'] as num).toDouble(),
        description: '',
        unit: '',
        imageUrl: '', // Image not needed for cart calculation logic
        category: 'General',
      );

      // Add quantity
      int qty = item['quantity'] as int;
      for(int i=0; i < qty; i++) {
        cart.addItem(product);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Items added to your cart!"),
        backgroundColor: AppTheme.qcGreen,
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}