import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:sendit/screens/product_list_screen.dart';
import 'package:sendit/screens/profilescreen.dart';
import 'package:sendit/screens/searchscreen.dart';
import '../DatabaseService.dart';
import '../models/product.dart';

import '../providers/AddressProvider.dart';
import '../themes.dart';
import '../widgets/ProductCard.dart';
import 'AddEditAddressScreen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();

  // FIX: Use the correct stream types for new database structure
  late Stream<List<Map<String, dynamic>>> _categoriesStream;
  late Stream<List<Product>> _productsStream;

  // State for category expansion
  bool _isCategoryExpanded = false;

  @override
  void initState() {
    super.initState();
    // Initialize streams
    _categoriesStream = _getCategoriesStream();
    _productsStream = _getProductsStream();
  }

  // FIX: Get categories from Firestore with new structure
  Stream<List<Map<String, dynamic>>> _getCategoriesStream() {
    return FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .map((snapshot) {
      // Extract unique categories from products
      final categories = <String, Map<String, dynamic>>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final category = data['category'] ?? {};
        final categoryId = category['id']?.toString() ?? 'uncategorized';
        final categoryName = category['name']?.toString() ?? 'Uncategorized';

        if (!categories.containsKey(categoryId)) {
          categories[categoryId] = {
            'id': categoryId,
            'name': categoryName,
            'image': data['thumbnail'] ?? '',
            'count': 1,
          };
        } else {
          categories[categoryId]!['count'] = (categories[categoryId]!['count'] as int) + 1;
        }
      }

      return categories.values.toList();
    });
  }

  // FIX: Get products with new structure
  Stream<List<Product>> _getProductsStream() {
    return FirebaseFirestore.instance
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: data['id'] ?? doc.id,
          name: data['name'] ?? 'Unnamed Product',
          description: data['description'] ?? '',
          brand: data['brand'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          mrp: (data['mrp'] as num?)?.toDouble() ?? 0.0,
          discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
          unit: data['unit'] ?? '',
          unitText: data['unitText'] ?? '',
          images: List<String>.from(data['images'] ?? []),
          thumbnail: data['thumbnail'] ?? '',
          stock: ProductStock.fromMap(data['stock'] ?? {}),
          category: data['category']?['name']?.toString() ?? 'Uncategorized',
          categoryId: data['category']?['id']?.toString() ?? 'uncategorized',
          isFeatured: data['isFeatured'] ?? false,
          isBestSeller: data['isBestSeller'] ?? false,
          ratings: ProductRatings.fromMap(data['ratings'] ?? {}),
          soldCount: data['soldCount'] ?? 0,
          variants: List<Map<String, dynamic>>.from(data['variants'] ?? []),
          attributes: ProductAttributes.fromMap(data['attributes'] ?? {}),
          searchKeywords: List<String>.from(data['searchKeywords'] ?? []),
          tags: List<String>.from(data['tags'] ?? []),
        );
      }).toList();
    });
  }

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
          key: const PageStorageKey('home_scroll_view'),
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Restored "Delivery in 10 mins" Header
            SliverToBoxAdapter(child: _buildTopHeader(context)),

            // 2. Sticky Search Bar
            // SliverPersistentHeader(
            //   pinned: true,
            //   delegate: _StickySearchDelegate(
            //     onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
            //   ),
            // ),

            // 3. Main Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPromoBanner(),

                  // Expandable Categories (Instant Toggle)
                  _buildCategorySection(),

                  // Spotlight Sections
                  _buildHorizontalProductSection(
                    title: "Fresh Vegetables",
                    categoryFilter: "Vegetables",
                    heroSuffix: "veg_section",
                  ),
                  _buildHorizontalProductSection(
                    title: "Daily Essentials",
                    categoryFilter: "Dairy & Eggs", // Updated to match new category name
                    heroSuffix: "dairy_section",
                  ),
                  _buildHorizontalProductSection(
                    title: "Featured Products",
                    isFeatured: true, // New parameter for featured filter
                    heroSuffix: "featured_section",
                  ),
                ],
              ),
            ),

            // 4. "More For You" Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text("More For You", style: Theme.of(context).textTheme.titleLarge),
              ),
            ),

            // 5. All Products Grid
            _buildAllProductsGrid(),

            // Bottom Padding for Floating Cart
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  // --- RESTORED HEADER DESIGN ---
  Widget _buildTopHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Consumer<AddressProvider>(
              builder: (context, addrProvider, _) {
                final selected = addrProvider.selectedAddress;

                // State 1: No Address Selected (New User)
                if (selected == null) {
                  return GestureDetector(
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const AddEditAddressScreen())),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Set Delivery Location",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.qcDiscountRed)),
                        Row(
                          children: [
                            const Text("Add Address",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textPrimary)),
                            const Icon(Icons.arrow_drop_down,
                                size: 20, color: AppTheme.textPrimary),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                // State 2: Selected Address (Restored Design)
                return GestureDetector(
                  onTap: () => _showAddressBottomSheet(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "Delivery in 10 minutes" Row
                      Row(
                        children: [
                          Text("Delivery in ",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary)),
                          Text("10 minutes",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textPrimary)),
                        ],
                      ),
                      // Address Row
                      Row(
                        children: [
                          Text(
                            "${selected.label} - ${selected.city}",
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Icon(Icons.arrow_drop_down,
                              size: 18, color: AppTheme.textSecondary),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Profile Icon
          GestureDetector(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
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

  // --- FIXED CATEGORY SECTION (Instant Toggle) ---
  Widget _buildCategorySection() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _categoriesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 100,
            padding: const EdgeInsets.all(16),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Container(
            height: 100,
            padding: const EdgeInsets.all(16),
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        var categories = snapshot.data ?? [];

        // Sort categories by product count
        categories.sort((a, b) => (b['count'] ?? 0).compareTo(a['count'] ?? 0));

        // Logic: Show first 8 (4x2) if collapsed, else show all
        final int initialCount = 8;
        final bool hasMore = categories.length > initialCount;
        final int displayCount =
        _isCategoryExpanded ? categories.length : (hasMore ? initialCount : categories.length);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Explore by Category",
                      style: Theme.of(context).textTheme.titleLarge),
                  if (hasMore)
                    GestureDetector(
                      onTap: () {
                        setState(() => _isCategoryExpanded = !_isCategoryExpanded);
                      },
                      child: Text(
                        _isCategoryExpanded ? "Show Less" : "View All",
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor),
                      ),
                    ),
                ],
              ),
            ),
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return GestureDetector(
                  onTap: () => _navigateToList(cat['name'], cat['name']),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: cat['image'] != null && cat['image'].toString().isNotEmpty
                            ? Image.network(
                          cat['image'].toString(),
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.category,
                              color: AppTheme.primaryColor),
                        )
                            : const Icon(Icons.category,
                            color: AppTheme.primaryColor, size: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['name']?.toString() ?? 'Category',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                            height: 1.1),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${cat['count'] ?? 0} items',
                        style: const TextStyle(
                            fontSize: 9,
                            color: AppTheme.textSecondary),
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

  // --- HORIZONTAL PRODUCT LIST ---
  Widget _buildHorizontalProductSection({
    required String title,
    String? categoryFilter,
    bool isFeatured = false,
    required String heroSuffix,
  }) {
    return StreamBuilder<List<Product>>(
      stream: _productsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: 240,
            child: Center(child: Text('Error loading products')),
          );
        }

        if (!snapshot.hasData) return const SizedBox.shrink();

        var products = snapshot.data!.where((p) {
          if (isFeatured) return p.isFeatured;
          if (categoryFilter != null) {
            return p.category.toLowerCase() == categoryFilter.toLowerCase();
          }
          return true;
        }).toList();

        // Filter only available products
        products = products.where((p) => p.stock.isAvailable).toList();

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
                    onTap: () => _navigateToList(title, categoryFilter ?? ''),
                    child: const Text("See all",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor)),
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
                itemBuilder: (context, index) => ProductCard(
                  product: products[index],
                  heroSuffix: heroSuffix,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- MAIN GRID ---
  Widget _buildAllProductsGrid() {
    return StreamBuilder<List<Product>>(
      stream: _productsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                )),
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Center(child: Text("Error: ${snapshot.error}")),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text("No products found")),
            ),
          );
        }

        // Filter only available products
        final availableProducts = snapshot.data!
            .where((product) => product.stock.isAvailable)
            .toList();

        if (availableProducts.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text("No products available")),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => ProductCard(
                product: availableProducts[index],
                heroSuffix: "grid_view",
              ),
              childCount: availableProducts.length,
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

  // --- PROMO BANNER ---
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
            right: -10,
            bottom: -10,
            child: Icon(Icons.local_offer_rounded,
                size: 140, color: Colors.white.withOpacity(0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFC107),
                      borderRadius: BorderRadius.circular(4)),
                  child: const Text("FREE DELIVERY",
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.black)),
                ),
                const SizedBox(height: 10),
                const Text("Get 50% OFF\nOn your first order",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ADDRESS BOTTOM SHEET ---
  void _showAddressBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (context) {
        return Consumer<AddressProvider>(
          builder: (context, provider, _) {
            final addresses = provider.addresses;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text("Select Delivery Location",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const Divider(height: 1),
                  if (addresses.isEmpty)
                    const Padding(
                        padding: EdgeInsets.all(30),
                        child: Text("No saved addresses"))
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.5),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: addresses.length,
                        separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 60),
                        itemBuilder: (context, index) {
                          final addr = addresses[index];
                          final isSelected =
                              provider.selectedAddress?.id == addr.id;
                          return ListTile(
                            onTap: () {
                              provider.selectAddress(addr);
                              Navigator.pop(context);
                            },
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8)),
                              child: Icon(_getIconForLabel(addr.label),
                                  color: isSelected
                                      ? AppTheme.qcGreen
                                      : Colors.grey),
                            ),
                            title: Text(addr.label,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? AppTheme.qcGreen
                                        : Colors.black)),
                            subtitle: Text("${addr.street}, ${addr.city}",
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle,
                                color: AppTheme.qcGreen)
                                : null,
                          );
                        },
                      ),
                    ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AddEditAddressScreen()));
                      },
                      icon: const Icon(Icons.add, color: AppTheme.qcGreen),
                      label: const Text("Add New Address",
                          style: TextStyle(
                              color: AppTheme.qcGreen,
                              fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(
                        backgroundColor: AppTheme.qcGreenLight,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'work':
        return Icons.work;
      case 'home':
        return Icons.home;
      default:
        return Icons.location_on;
    }
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
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(Icons.search,
                  color: AppTheme.primaryColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                  child: Text("Search 'Milk', 'Curd'...",
                      style: TextStyle(color: Colors.grey[400], fontSize: 14))),
              const Icon(Icons.mic_none,
                  color: AppTheme.primaryColor, size: 22),
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