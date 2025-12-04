import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/product.dart';
import '../providers/AddressProvider.dart';
import '../screens/product_list_screen.dart';
import '../screens/profilescreen.dart';
import '../widgets/ProductCard.dart';
import '../themes.dart';
import 'AddEditAddressScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- STATE ---
  String _selectedCategoryId = 'all'; // Default to 'all'
  String _selectedCategoryName = 'All'; // Display name

  final Color _defaultBg = const Color(0xFFF5F7FD);
  final Color _defaultHeaderColor = AppTheme.swiggyOrange; // Default Orange

  late Stream<List<Product>> _productsStream;

  @override
  void initState() {
    super.initState();
    _productsStream = _getProductsStream();
  }

  Stream<List<Product>> _getProductsStream() {
    // Fetch products for "Quick Picks"
    return FirebaseFirestore.instance
        .collection('products')
        .where('isActive', isEqualTo: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList());
  }

  void _navigateToList(String title, String query) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductListScreen(title: title, searchQuery: query),
      ),
    );
  }

  // --- HELPER: Map Category Name to Icon ---
  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower == 'all') return Icons.grid_view_rounded;
    if (lower.contains('winter')) return Icons.ac_unit_rounded;
    if (lower.contains('wedding')) return Icons.volunteer_activism_rounded;
    if (lower.contains('gourmet')) return Icons.restaurant_rounded;
    if (lower.contains('electronic')) return Icons.headphones_rounded;
    if (lower.contains('fruit')) return Icons.shopping_bag_outlined;
    if (lower.contains('veg')) return Icons.eco_rounded;
    if (lower.contains('dairy')) return Icons.local_drink_rounded;
    if (lower.contains('bread') || lower.contains('bakery')) return Icons.breakfast_dining_rounded;
    if (lower.contains('egg') || lower.contains('meat')) return Icons.egg_alt_rounded;
    if (lower.contains('snack') || lower.contains('munchies')) return Icons.cookie_rounded;
    if (lower.contains('beauty') || lower.contains('care')) return Icons.face_retouching_natural_rounded;
    if (lower.contains('home') || lower.contains('clean')) return Icons.cleaning_services_rounded;
    return Icons.category_rounded;
  }

  @override
  Widget build(BuildContext context) {
    // We wrap the entire body in the Categories Stream to ensure data consistency
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        // 1. Parse Categories Data
        Map<String, Map<String, dynamic>> categoriesData = {};

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final id = data['id'] ?? doc.id;
            categoriesData[id] = data;
          }
        }

        // 2. Determine Current Theme Color
        Color headerColor = _defaultHeaderColor;
        List<dynamic> currentGridItems = [];
        bool isAllTab = _selectedCategoryId == 'all';

        if (!isAllTab && categoriesData.containsKey(_selectedCategoryId)) {
          final selectedData = categoriesData[_selectedCategoryId]!;

          // Parse Theme Color (Handle both int and hex string if necessary)
          if (selectedData['themeColor'] != null) {
            try {
              if (selectedData['themeColor'] is int) {
                headerColor = Color(selectedData['themeColor']);
              } else if (selectedData['themeColor'] is String) {
                // Fallback for string hex codes
                String hex = selectedData['themeColor'];
                hex = hex.replaceAll("#", "");
                if (hex.length == 6) hex = "FF$hex";
                headerColor = Color(int.parse("0x$hex"));
              }
            } catch (e) {
              headerColor = _defaultHeaderColor;
            }
          }

          // Set Grid Items to Sub-Categories
          currentGridItems = selectedData['subCategories'] ?? [];
        } else {
          // If "All", the grid items are the main categories themselves
          currentGridItems = categoriesData.values.toList();
        }

        return Scaffold(
          backgroundColor: _defaultBg,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. DYNAMIC HEADER SECTION
              SliverToBoxAdapter(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: headerColor,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10,
                    bottom: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopHeader(context, isAllTab ? "8 mins" : _selectedCategoryName),
                      _buildSearchBar(),

                      // DYNAMIC TABS (Passed headerColor for active icon styling)
                      _buildCategoryTabs(categoriesData.values.toList(), headerColor),

                      if (isAllTab) ...[
                        _buildSaleBannerText(),
                      ] else ...[
                        // Specialized Header Title
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              _selectedCategoryName.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)]
                              ),
                            ),
                          ),
                        ),
                      ],

                      // DYNAMIC GRID (Sub-cats or Main Cats)
                      _buildDynamicCampaignGrid(
                          items: currentGridItems,
                          isAllTab: isAllTab,
                          themeColor: headerColor
                      ),
                    ],
                  ),
                ),
              ),

              // 2. BODY CONTENT
              SliverToBoxAdapter(
                child: Container(
                  color: _defaultBg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isAllTab) _buildAdBanner(),
                      if (isAllTab) _buildAdventCalendar(),
                      _buildQuickPicksHeader(),
                      _buildQuickPicksList(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGETS ---

  Widget _buildTopHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Consumer<AddressProvider>(
              builder: (context, addrProvider, _) {
                final selected = addrProvider.selectedAddress;
                return GestureDetector(
                  onTap: () => selected == null
                      ? Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditAddressScreen()))
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.0),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text("To Home: ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          Flexible(
                            child: Text(
                              selected != null ? "${selected.street}, ${selected.city}..." : "Set Location...",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: const CircleAvatar(radius: 20, backgroundColor: Colors.white, child: Icon(Icons.person, size: 24, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(child: Text("Search for '${_selectedCategoryId == 'all' ? 'Fruits' : _selectedCategoryName}'...", style: TextStyle(color: Colors.grey[500], fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const Icon(Icons.search, color: Colors.grey, size: 24),
                  const SizedBox(width: 12),
                  Container(width: 1, height: 24, color: Colors.grey[300]),
                  const SizedBox(width: 12),
                  const Icon(Icons.mic_none, color: Colors.purple, size: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- DYNAMIC TABS FROM FIRESTORE (ICONS ONLY) ---
  Widget _buildCategoryTabs(List<Map<String, dynamic>> categories, Color activeThemeColor) {
    // Add "All" as the first option
    final allTab = {
      'id': 'all',
      'name': 'All',
    };

    final displayList = [allTab, ...categories];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        itemCount: displayList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 24),
        itemBuilder: (context, index) {
          final cat = displayList[index];
          final id = cat['id'] as String;
          final name = cat['name'] as String;
          final isSelected = _selectedCategoryId == id;

          // Get Icon based on category name
          final iconData = _getCategoryIcon(name);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryId = id;
                _selectedCategoryName = name;
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 50, width: 50,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))] : [],
                  ),
                  child: Icon(
                    iconData,
                    color: isSelected ? activeThemeColor : Colors.white, // Active icon takes theme color
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
                    fontSize: 11,
                  ),
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    height: 3, width: 24,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
                  )
              ],
            ),
          );
        },
      ),
    );
  }

  // --- DYNAMIC GRID LOGIC ---
  Widget _buildDynamicCampaignGrid({
    required List<dynamic> items,
    required bool isAllTab,
    required Color themeColor
  }) {
    if (items.isEmpty) return const SizedBox(height: 20);

    return Container(
      height: 165,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];

          // Normalize data structure between "Category" doc and "SubCategory" map
          final String title = item['name'] ?? '';
          final String offer = item['offer'] ?? (isAllTab ? 'EXPLORE' : '');
          final String imageUrl = item['image'] ?? '';

          return _buildCategoryCard(
            title: title,
            offer: offer,
            color: Colors.white,
            textColor: themeColor, // Use the current header theme color for text
            image: imageUrl,
            onTap: () => _navigateToList(title, title),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String offer,
    required Color color,
    required Color textColor,
    required String image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
              child: Text(
                title.replaceAll(" ", "\n"), // Stack words
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13, height: 1.2),
              ),
            ),

            // Image
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                child: image.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: image,
                  height: 55,
                  fit: BoxFit.contain,
                  errorWidget: (_, __, ___) => Icon(Icons.shopping_bag_outlined, color: textColor.withOpacity(0.3), size: 40),
                )
                    : Icon(Icons.shopping_bag_outlined, color: textColor.withOpacity(0.3), size: 40),
              ),
            ),

            // Offer Tag
            if (offer.isNotEmpty)
              Positioned(
                bottom: 10, left: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFC6FF00), borderRadius: BorderRadius.circular(6)),
                  child: Text(
                      offer,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildSaleBannerText() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            const Text("SENDIT EVERYDAY", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Text("Fresh Groceries & Essentials", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFF5D1049), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), color: Colors.white, child: const Text("AD", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: Color(0xFF5D1049)))),
          const SizedBox(width: 12),
          const Expanded(child: Text("Free delivery on your first order!", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 10),
        ],
      ),
    );
  }

  Widget _buildAdventCalendar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.purple.shade100)),
      child: Row(
        children: [
          const Icon(Icons.star, color: Color(0xFF7E0095), size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("New arrivals in Dairy", style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              const Text("Check out Amul Products >", style: TextStyle(color: Color(0xFF7E0095), fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQuickPicksHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Quick Picks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1F1F1F))),
          TextButton(onPressed: () => _navigateToList("Quick Picks", "All"), child: const Text("See All >", style: TextStyle(color: AppTheme.swiggyOrange, fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildQuickPicksList() {
    return StreamBuilder<List<Product>>(
      stream: _productsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 260, child: Center(child: CircularProgressIndicator()));
        final products = snapshot.data ?? [];
        if (products.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 270,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 150,
                child: ProductCard(
                    product: products[index],
                    heroSuffix: "quick_picks"
                ),
              );
            },
          ),
        );
      },
    );
  }
}