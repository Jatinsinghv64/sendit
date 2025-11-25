import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/ProductCard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper to get icon based on category name
  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'fruits': return Icons.apple;
      case 'vegetables':
      case 'veggies': return Icons.eco;
      case 'dairy': return Icons.water_drop;
      case 'bakery': return Icons.breakfast_dining;
      case 'meat': return Icons.kebab_dining;
      case 'seafood': return Icons.set_meal;
      case 'beverages': return Icons.local_drink;
      case 'snacks': return Icons.cookie;
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1. App Bar with Address & Cart
            SliverAppBar(
              floating: true,
              pinned: false,
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Delivery to",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Row(
                    children: [
                      Text(
                        "Home",
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.keyboard_arrow_down,
                          color: Color(0xFF2E7D32), size: 20),
                    ],
                  ),
                ],
              ),
              actions: [
                Consumer<CartProvider>(
                  builder: (_, cart, ch) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/cart'),
                      icon: Badge(
                        label: Text(cart.itemCount.toString()),
                        isLabelVisible: cart.itemCount > 0,
                        backgroundColor: const Color(0xFF2E7D32),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shopping_cart_outlined,
                              color: Colors.black87, size: 22),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2. Search Bar
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search 'Organic Bananas'",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF4F5F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ),

            // 3. Promotional Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E7D32).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        bottom: -20,
                        child: Icon(Icons.shopping_basket,
                            size: 150, color: Colors.white.withOpacity(0.15)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text("Free Delivery",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Get 50% Off\nOn First Order",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Categories Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Categories",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            // 5. Categories List (From Firebase with Fallback)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                  builder: (context, snapshot) {
                    // Start with "All"
                    List<Map<String, dynamic>> categories = [
                      {'name': 'All', 'icon': Icons.grid_view}
                    ];

                    // Check if we have data from Firebase
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      final fetchedDocs = snapshot.data!.docs;
                      for (var doc in fetchedDocs) {
                        final data = doc.data() as Map<String, dynamic>;
                        // Check for 'name' OR 'category' field
                        final categoryName = data['name'] ?? data['category'];

                        if (categoryName != null) {
                          categories.add({
                            'name': categoryName,
                            'icon': _getCategoryIcon(categoryName),
                          });
                        }
                      }
                    } else {
                      // Fallback categories if Firebase is empty/loading
                      categories.addAll([
                        {'name': 'Fruits', 'icon': Icons.apple},
                        {'name': 'Veggies', 'icon': Icons.eco},
                        {'name': 'Dairy', 'icon': Icons.water_drop},
                        {'name': 'Bakery', 'icon': Icons.breakfast_dining},
                        {'name': 'Meat', 'icon': Icons.kebab_dining},
                      ]);
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = _selectedCategory == cat['name'];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat['name'];
                            });
                          },
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF2E7D32)
                                          : Colors.grey.shade200
                                  ),
                                  boxShadow: isSelected
                                      ? [BoxShadow(color: const Color(0xFF2E7D32).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                                      : null,
                                ),
                                child: Icon(
                                    cat['icon'],
                                    color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                                    size: 28
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
            ),

            // 6. Popular Products Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        _searchQuery.isNotEmpty
                            ? "Search Results"
                            : (_selectedCategory == 'All' ? "Popular Near You" : "$_selectedCategory Products"),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.tune, size: 20),
                    )
                  ],
                ),
              ),
            ),

            // 7. Real Firestore Data Grid (Filtered by Category AND Search)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState("No products found");
                }

                // 1. Convert to Product Objects
                var products = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Product(
                    id: doc.id,
                    name: data['name'] ?? 'Unknown',
                    description: data['description'] ?? '',
                    price: (data['price'] ?? 0.0).toDouble(),
                    unit: data['unit'] ?? 'pcs',
                    imageUrl: data['imageUrl'] ?? data['image'] ?? '',
                    category: data['category'] ?? 'General',
                  );
                }).toList();

                // 2. Filter Client-Side (Category + Search)
                if (_selectedCategory != 'All') {
                  products = products.where((p) =>
                  p.category.toLowerCase() == _selectedCategory.toLowerCase()
                  ).toList();
                }

                if (_searchQuery.isNotEmpty) {
                  products = products.where((p) =>
                      p.name.toLowerCase().contains(_searchQuery)
                  ).toList();
                }

                // 3. Check if empty after filtering
                if (products.isEmpty) {
                  return _buildEmptyState("No matches found");
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                          (ctx, i) => ProductCard(product: products[i]),
                      childCount: products.length,
                    ),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.70,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                  ),
                );
              },
            ),

            // Bottom padding for scrolling clearance
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return SliverToBoxAdapter(
      child: Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
                message,
                style: TextStyle(color: Colors.grey[600])
            ),
          ],
        ),
      ),
    );
  }
}