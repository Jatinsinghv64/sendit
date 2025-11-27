import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sendit/screens/product_list_screen.dart';
import 'package:sendit/screens/profilescreen.dart';
import 'package:sendit/screens/searchscreen.dart';
import '../DatabaseService.dart';
import '../models/product.dart';
import '../themes.dart';
import '../widgets/ProductCard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();

  // State for category expansion
  bool _isCategoryExpanded = false;

  void _navigateToList(String title, String query) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductListScreen(title: title, searchQuery: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Top Header
            SliverToBoxAdapter(child: _buildTopHeader()),

            // 2. Search Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickySearchDelegate(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
              ),
            ),

            // 3. Main Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPromoBanner(),

                  // UPDATED: Categories Section (4x2 Grid that expands)
                  _buildCategorySection(),

                  // Spotlight Shelves
                  _buildHorizontalProductSection(title: "Fresh Vegetables", categoryFilter: "Vegetables"),
                  _buildHorizontalProductSection(title: "Daily Essentials", categoryFilter: "Dairy"),
                  _buildHorizontalProductSection(title: "Featured Products", categoryFilter: "Featured"),
                ],
              ),
            ),

            // 4. "More For You"
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  "More For You",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),

            // 5. All Products Grid
            _buildAllProductsGrid(),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  // --- NEW CATEGORY SECTION LOGIC ---

  Widget _buildCategorySection() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _dbService.getCategories(),
      builder: (context, snapshot) {
        // Loading State (Shimmer)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        var categories = snapshot.data ?? [];

        // Logic: Show only first 8 (4x2) if collapsed, otherwise show all
        final int initialCount = 8;
        final bool hasMore = categories.length > initialCount;
        final int displayCount = _isCategoryExpanded ? categories.length : (hasMore ? initialCount : categories.length);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with "View All" Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Explore by Category", style: Theme.of(context).textTheme.titleLarge),
                  if (hasMore)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isCategoryExpanded = !_isCategoryExpanded;
                        });
                      },
                      child: Text(
                        _isCategoryExpanded ? "Show Less" : "View All",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // The Grid (Instant update, no loading)
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true, // Takes only needed space
              physics: const NeverScrollableScrollPhysics(), // Disables scrolling within grid
              itemCount: displayCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 4 Columns
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75, // Adjusted for icon + text
              ),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return GestureDetector(
                  onTap: () => _navigateToList(cat['name'], cat['name']),
                  child: Column(
                    children: [
                      // Category Circle
                      Container(
                        width: 70,
                        height: 70,
                        padding: const EdgeInsets.all(6), // Reduced padding = Larger Image
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12), // Soft square like Blinkit
                        ),
                        child: cat['image'] != null && cat['image'].isNotEmpty
                            ? Image.network(
                          cat['image'],
                          fit: BoxFit.contain, // Image fills nicely
                          errorBuilder: (_,__,___) => const Icon(Icons.category, color: AppTheme.primaryColor),
                        )
                            : const Icon(Icons.category, color: AppTheme.primaryColor, size: 32),
                      ),
                      const SizedBox(height: 8),
                      // Category Name
                      Text(
                        cat['name'],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // --- EXISTING WIDGETS (Unchanged) ---

  Widget _buildTopHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("Delivery in ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const Text("10 minutes", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                ],
              ),
              Row(
                children: [
                  Text("Home - Mumbai, India", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
                  Icon(Icons.arrow_drop_down, size: 18, color: AppTheme.textSecondary),
                ],
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[100],
              child: const Icon(Icons.person, size: 20, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF374151)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10, bottom: -10,
            child: Icon(Icons.local_offer_rounded, size: 140, color: Colors.white.withOpacity(0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFFC107), borderRadius: BorderRadius.circular(4)),
                  child: const Text("FREE DELIVERY", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black)),
                ),
                const SizedBox(height: 10),
                const Text("Get 50% OFF\nOn your first order", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, height: 1.1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalProductSection({required String title, required String categoryFilter}) {
    return StreamBuilder<List<Product>>(
      stream: _dbService.getProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        var products = snapshot.data!.where((p) {
          if (categoryFilter == "Featured") return p.isFeatured;
          return p.category.toLowerCase() == categoryFilter.toLowerCase();
        }).toList();

        if (products.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  GestureDetector(
                    onTap: () => _navigateToList(title, categoryFilter),
                    child: const Text("See all", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 240,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: products.length > 6 ? 6 : products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) => ProductCard(product: products[index]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAllProductsGrid() {
    return StreamBuilder<List<Product>>(
      stream: _dbService.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text("No products found in database")),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => ProductCard(product: snapshot.data![index]),
              childCount: snapshot.data!.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
          ),
        );
      },
    );
  }
}

class _StickySearchDelegate extends SliverPersistentHeaderDelegate {
  final VoidCallback onTap;
  _StickySearchDelegate({required this.onTap});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 60,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppTheme.primaryColor, size: 22),
              const SizedBox(width: 10),
              Expanded(child: Text("Search 'Milk', 'Curd'...", style: TextStyle(color: Colors.grey[400], fontSize: 14))),
              const Icon(Icons.mic_none, color: AppTheme.primaryColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 60;
  @override
  double get minExtent => 60;
  @override
  bool shouldRebuild(covariant _StickySearchDelegate oldDelegate) => false;
}