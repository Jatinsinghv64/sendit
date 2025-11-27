import 'package:flutter/material.dart';
import '../DatabaseService.dart';
import '../models/product.dart';
import '../themes.dart';
import '../widgets/ProductCard.dart';
import '../widgets/FloatingCartButton.dart';

class ProductListScreen extends StatefulWidget {
  final String title;
  final String searchQuery;

  const ProductListScreen({
    super.key,
    required this.title,
    required this.searchQuery
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final DatabaseService _dbService = DatabaseService();

  // Filter States
  String _sortBy = 'Relevance'; // Options: Relevance, Price: Low to High, Price: High to Low
  bool _showOnlyOffers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Optional: Add search logic here later
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. Professional Filter Bar
              _buildFilterBar(),

              // 2. Product Grid
              Expanded(
                child: StreamBuilder<List<Product>>(
                  stream: _dbService.getProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyState();
                    }

                    // --- FILTERING LOGIC ---

                    // 1. Base Filter (Category/Search)
                    var products = snapshot.data!.where((p) {
                      if (widget.searchQuery == "Featured") return p.isFeatured;
                      if (widget.searchQuery == "All") return true;
                      return p.category.toLowerCase() == widget.searchQuery.toLowerCase();
                    }).toList();

                    // 2. Apply "On Sale" Filter
                    if (_showOnlyOffers) {
                      products = products.where((p) => p.discount > 0).toList();
                    }

                    // 3. Apply Sorting
                    if (_sortBy == 'Price: Low to High') {
                      products.sort((a, b) => a.price.compareTo(b.price));
                    } else if (_sortBy == 'Price: High to Low') {
                      products.sort((a, b) => b.price.compareTo(a.price));
                    }

                    // Check if empty after filters
                    if (products.isEmpty) return _buildEmptyState();

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Bottom padding for cart button
                      itemCount: products.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68, // Optimized for professional card height
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        return ProductCard(product: products[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // 3. Floating Cart Button
          const FloatingCartButton(),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildFilterBar() {
    return Container(
      height: 54,
      width: double.infinity,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          // Sort Filter Chip
          _buildFilterChip(
            label: _sortBy == 'Relevance' ? 'Sort By' : _sortBy.replaceAll('Price: ', ''),
            icon: Icons.sort,
            isActive: _sortBy != 'Relevance',
            hasDropdown: true,
            onTap: _showSortBottomSheet,
          ),
          const SizedBox(width: 10),

          // On Sale Filter Chip
          _buildFilterChip(
            label: 'On Sale',
            icon: Icons.local_offer_outlined,
            isActive: _showOnlyOffers,
            hasDropdown: false,
            onTap: () => setState(() => _showOnlyOffers = !_showOnlyOffers),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required bool hasDropdown,
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.qcGreenLight : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? AppTheme.primaryColor : AppTheme.textPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? AppTheme.primaryColor : AppTheme.textPrimary,
              ),
            ),
            if (hasDropdown) ...[
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 16, color: isActive ? AppTheme.primaryColor : Colors.grey)
            ]
          ],
        ),
      ),
    );
  }

  // Bottom Sheet for Sorting
  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text("Sort By", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              _buildSortOption("Relevance"),
              _buildSortOption("Price: Low to High"),
              _buildSortOption("Price: High to Low"),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String option) {
    final isSelected = _sortBy == option;
    return ListTile(
      title: Text(
          option,
          style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primaryColor : Colors.black
          )
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
      onTap: () {
        setState(() => _sortBy = option);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No items found in this section", style: TextStyle(color: Colors.grey)),
          if (_showOnlyOffers)
            TextButton(
              onPressed: () => setState(() => _showOnlyOffers = false),
              child: const Text("Clear Filters", style: TextStyle(color: AppTheme.primaryColor)),
            )
        ],
      ),
    );
  }
}