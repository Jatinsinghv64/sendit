import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sendit/screens/profilescreen.dart';
import 'package:sendit/screens/searchscreen.dart';
import '../DatabaseService.dart';
import '../models/product.dart';
import '../widgets/ProductCard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  String _selectedCategory = 'All';

  // Seed functions removed as requested

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF2E7D32), size: 24),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "Delivery to",
                    style: TextStyle(fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.w600)
                ),
                const Text(
                    "Home - Mumbai",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)
                ),
              ],
            ),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black54),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.person, size: 20, color: Color(0xFF2E7D32)),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
            ),
          )
        ],
      ),

      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[500]),
                      const SizedBox(width: 12),
                      Text("Search for 'paneer'", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: _buildPromoBanner()),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Shop by Category", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      // Removed Seed Category Button
                    ],
                  ),
                ),
                SizedBox(
                  height: 110,
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _dbService.getCategories(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return _buildCategoryShimmer();
                      var categories = snapshot.data!;

                      // Removed seed button trigger on empty list
                      if (categories.isEmpty) return const Center(child: Text("No categories found"));

                      if (!categories.any((c) => c['name'] == 'All')) {
                        categories.insert(0, {'name': 'All', 'image': null, 'icon': Icons.grid_view.codePoint});
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isSelected = _selectedCategory == cat['name'];
                          final hasImage = cat['image'] != null && cat['image'].toString().isNotEmpty;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat['name']),
                            child: Column(
                              children: [
                                Container(
                                  width: 65,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
                                        width: 2
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: hasImage
                                        ? Image.network(
                                      cat['image'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (c,e,s) => Icon(Icons.broken_image, color: Colors.grey[300]),
                                    )
                                        : Container(
                                      color: const Color(0xFFF5F5F5),
                                      child: Icon(
                                          cat['icon'] != null ? IconData(cat['icon'], fontFamily: 'MaterialIcons') : Icons.category,
                                          color: isSelected ? const Color(0xFF2E7D32) : Colors.grey
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  cat['name'],
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? const Color(0xFF2E7D32) : Colors.black87
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      _selectedCategory == 'All' ? "Recommended for You" : "$_selectedCategory Items",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                  ),
                  // Removed Seed Products Button
                ],
              ),
            ),
          ),

          StreamBuilder<List<Product>>(
            stream: _dbService.getProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(child: _buildLoadingShimmer());
              }

              var products = snapshot.data ?? [];
              if (_selectedCategory != 'All') {
                products = products.where((p) => p.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
              }

              if (products.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text("No items found in this category")),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), // Bottom padding for floating cart
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => ProductCard(product: products[index]),
                    childCount: products.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFF2E7D32).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: const Text("Free Delivery", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
                const SizedBox(height: 8),
                const Text("Get 50% Off\nOn First Order", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Icon(Icons.shopping_basket, size: 80, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildCategoryShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(width: 16),
      itemBuilder: (_, __) => Column(
        children: [
          Container(width: 65, height: 65, decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle)),
          const SizedBox(height: 8),
          Container(width: 40, height: 10, color: Colors.grey[200]),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 16, mainAxisSpacing: 16),
        itemCount: 4,
        itemBuilder: (_, __) => Container(decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16))),
      ),
    );
  }
}