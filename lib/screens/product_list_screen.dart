import 'package:flutter/material.dart';
import '../DatabaseService.dart';
import '../models/product.dart';
import '../themes.dart';
import '../widgets/ProductCard.dart';
import '../widgets/FloatingCartButton.dart'; // Import the button

class ProductListScreen extends StatelessWidget {
  final String title;
  final String searchQuery;

  const ProductListScreen({
    super.key,
    required this.title,
    required this.searchQuery
  });

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      // WRAP BODY IN A STACK
      body: Stack(
        children: [
          StreamBuilder<List<Product>>(
            stream: dbService.getProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState();
              }

              final products = snapshot.data!.where((p) {
                if (searchQuery == "Featured") return p.isFeatured;
                if (searchQuery == "All") return true;
                return p.category.toLowerCase() == searchQuery.toLowerCase();
              }).toList();

              if (products.isEmpty) return _buildEmptyState();

              return GridView.builder(
                // Add padding at the bottom so the last items aren't hidden by the button
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  return ProductCard(product: products[index]);
                },
              );
            },
          ),

          // ADD THE FLOATING BUTTON HERE
          const FloatingCartButton(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No items found in this section", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}