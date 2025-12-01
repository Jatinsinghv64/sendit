import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/AddressProvider.dart';
import '../screens/product_list_screen.dart';
import '../screens/profilescreen.dart';
import '../widgets/ProductCard.dart';
import 'AddEditAddressScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- STATE ---
  String _selectedCategory = 'All';
  final Color _defaultBg = const Color(0xFFF5F7FD);

  // --- THEME CONFIGURATION ---
  // Maps category names to their specific Brand Colors and Sub-category data
  final Map<String, Map<String, dynamic>> _categoryThemes = {
    'All': {
      'color': const Color(0xFFF57F17), // Changed to Orange as requested
      'title': '8 mins',
      'sub_cats': [], // Empty means load from DB (Default behavior)
    },
    'Winter': {
      'color': const Color(0xFF64B5F6), // Winter Blue
      'title': 'Winter Store',
      'sub_cats': [
        {'name': 'Blankets', 'offer': '60% OFF', 'color': Color(0xFFE3F2FD)},
        {'name': 'Heaters', 'offer': '40% OFF', 'color': Color(0xFFBBDEFB)},
        {'name': 'Skin Care', 'offer': '50% OFF', 'color': Color(0xFF90CAF9)},
        {'name': 'Winter Food', 'offer': '30% OFF', 'color': Color(0xFF64B5F6)},
      ]
    },
    'Wedding': {
      'color': const Color(0xFFB71C1C), // Wedding Red
      'title': 'The Wedding Store',
      'sub_cats': [
        {'name': 'Gifting', 'offer': '20% OFF', 'color': Color(0xFFFFEBEE)},
        {'name': 'Jewellery', 'offer': '10% OFF', 'color': Color(0xFFFFCDD2)},
        {'name': 'Decor', 'offer': '60% OFF', 'color': Color(0xFFEF9A9A)},
        {'name': 'Essentials', 'offer': 'Buy 1 Get 1', 'color': Color(0xFFE57373)},
      ]
    },
    'Gourmet': {
      'color': const Color(0xFFF57F17), // Gold/Orange
      'title': 'Gourmet Picks',
      'sub_cats': [
        {'name': 'Cheese', 'offer': '15% OFF', 'color': Color(0xFFFFF8E1)},
        {'name': 'Chocolates', 'offer': '10% OFF', 'color': Color(0xFFFFECB3)},
        {'name': 'Imported', 'offer': '20% OFF', 'color': Color(0xFFFFE082)},
      ]
    },
    'Electronics': {
      'color': const Color(0xFF455A64), // Blue Grey
      'title': 'Electronics',
      'sub_cats': [
        {'name': 'Headphones', 'offer': '50% OFF', 'color': Color(0xFFECEFF1)},
        {'name': 'Chargers', 'offer': '40% OFF', 'color': Color(0xFFCFD8DC)},
      ]
    },
  };

  late Stream<List<Map<String, dynamic>>> _categoriesStream;
  late Stream<List<Product>> _productsStream;

  @override
  void initState() {
    super.initState();
    _categoriesStream = _getCategoriesStream();
    _productsStream = _getProductsStream();
  }

  // Fetch standard categories from DB for "All" tab
  Stream<List<Map<String, dynamic>>> _getCategoriesStream() {
    return FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .map((snapshot) {
      final categories = <String, Map<String, dynamic>>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final categoryId = data['category']?['id']?.toString() ?? 'uncategorized';
        final categoryName = data['category']?['name']?.toString() ?? 'Uncategorized';

        if (!categories.containsKey(categoryId)) {
          categories[categoryId] = {
            'name': categoryName,
            'image': data['thumbnail'] ?? '', // Using thumbnail as icon
            'count': 1,
          };
        } else {
          categories[categoryId]!['count'] = (categories[categoryId]!['count'] as int) + 1;
        }
      }
      return categories.values.toList();
    });
  }

  Stream<List<Product>> _getProductsStream() {
    // If specific category selected, you might want to filter here in the future
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

  @override
  Widget build(BuildContext context) {
    // Get current theme based on selection, fallback to orange (All)
    final currentTheme = _categoryThemes[_selectedCategory] ?? _categoryThemes['All']!;
    final Color headerColor = currentTheme['color'];

    return Scaffold(
      backgroundColor: _defaultBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. DYNAMIC HEADER SECTION
          SliverToBoxAdapter(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300), // Smooth color transition
              color: headerColor,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopHeader(context, currentTheme['title']),
                  _buildSearchBar(),
                  _buildCategoryTabs(), // The Top Navigation Bar

                  if (_selectedCategory == 'All') ...[
                    _buildSaleBannerText(),
                  ] else ...[
                    // Specialized Header for Winter/Wedding
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          currentTheme['title'].toUpperCase(),
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

                  // DYNAMIC GRID (Changes based on selection)
                  _buildDynamicCampaignGrid(currentTheme),
                ],
              ),
            ),
          ),

          // 2. BODY CONTENT (Quick Picks, etc.)
          SliverToBoxAdapter(
            child: Container(
              color: _defaultBg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedCategory == 'All') _buildAdBanner(),
                  if (_selectedCategory == 'All') _buildAdventCalendar(),
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
                        _selectedCategory == 'All' ? "8 mins" : title,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.0),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, // Prevent Title Overflow
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
                  Expanded(child: Text("Search for '${_selectedCategory == 'All' ? 'Fruits' : _selectedCategory}'...", style: TextStyle(color: Colors.grey[500], fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const Icon(Icons.search, color: Colors.grey, size: 24),
                  const SizedBox(width: 12),
                  Container(width: 1, height: 24, color: Colors.grey[300]),
                  const SizedBox(width: 12),
                  const Icon(Icons.mic_none, color: Colors.purple, size: 24),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 50, width: 50,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.2))),
            child: const Icon(Icons.bookmark_border, color: Colors.white),
          )
        ],
      ),
    );
  }

  // --- TOP CATEGORY TABS ---
  Widget _buildCategoryTabs() {
    // Hardcoded list of main tabs as per screenshot logic
    final tabs = [
      {'label': 'All', 'icon': Icons.shopping_basket},
      {'label': 'Winter', 'icon': Icons.ac_unit},
      {'label': 'Wedding', 'icon': Icons.favorite}, // Using heart as Wedding proxy
      {'label': 'Gourmet', 'icon': Icons.star},
      {'label': 'Electronics', 'icon': Icons.headphones},
    ];

    return SizedBox(
      height: 110, // Increased height to prevent overflow
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 24),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = _selectedCategory == tab['label'];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = tab['label'] as String;
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min, // Essential to fit in SizedBox
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
                    tab['icon'] as IconData,
                    color: isSelected ? _categoryThemes[tab['label']]!['color'] : Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tab['label'] as String,
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
  Widget _buildDynamicCampaignGrid(Map<String, dynamic> theme) {
    // 1. If it's a special category (Winter/Wedding), use local config
    if (theme.containsKey('sub_cats') && (theme['sub_cats'] as List).isNotEmpty) {
      final subCats = theme['sub_cats'] as List<dynamic>;
      return Container(
        height: 165,
        margin: const EdgeInsets.only(top: 8),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: subCats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final cat = subCats[index];
            return _buildCategoryCard(
              title: cat['name'],
              offer: cat['offer'],
              color: Colors.white, // In screenshot, these are often white or themed
              textColor: theme['color'], // Use theme color for text
              image: null, // You can add local asset logic here
              onTap: () => _navigateToList(cat['name'], cat['name']),
            );
          },
        ),
      );
    }

    // 2. If 'All', use Firestore Categories (Default behavior)
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _categoriesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 160);
        final categories = snapshot.data ?? [];
        if (categories.isEmpty) return const SizedBox.shrink();

        final cardColors = [
          const Color(0xFF4A148C), const Color(0xFF311B92),
          const Color(0xFF880E4F), const Color(0xFF1A237E), const Color(0xFF004D40),
        ];

        return Container(
          height: 165,
          margin: const EdgeInsets.only(top: 8),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return _buildCategoryCard(
                title: cat['name'],
                offer: "UP TO ${(10 + index * 5) % 60}% OFF",
                color: cardColors[index % cardColors.length],
                textColor: Colors.white,
                image: cat['image'],
                onTap: () => _navigateToList(cat['name'], cat['name']),
              );
            },
          ),
        );
      },
    );
  }

  // Reusable Card Widget for the Grid
  Widget _buildCategoryCard({
    required String title,
    required String offer,
    required Color color,
    required Color textColor,
    String? image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
              child: Text(
                title.replaceAll(" ", "\n"),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13, height: 1.2),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: image != null && image.isNotEmpty
                    ? Image.network(image, height: 50, fit: BoxFit.contain)
                    : Icon(Icons.shopping_bag_outlined, color: textColor.withOpacity(0.5), size: 40),
              ),
            ),
            Positioned(
              bottom: 10, left: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFC6FF00), borderRadius: BorderRadius.circular(6)),
                child: Text(offer, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)),
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
            const Text("SALE LIVE NOW", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFC6FF00), borderRadius: BorderRadius.circular(12)),
              child: const Text("28th Nov - 7th Dec", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
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
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), color: Colors.white, child: const Text("AASHIRVAAD", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: Color(0xFF5D1049)))),
          const SizedBox(width: 12),
          const Expanded(child: Text("Win gold & daily vouchers with Aashirvaad select atta", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
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
          const Icon(Icons.calendar_month_outlined, color: Color(0xFF7E0095), size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Today's deal unlocked!", style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              const Text("Christmas Advent Calendar >", style: TextStyle(color: Color(0xFF7E0095), fontWeight: FontWeight.bold, fontSize: 14)),
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
          const Text("Hey User, your quick picks", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F))),
          TextButton(onPressed: () => _navigateToList("Quick Picks", "All"), child: const Text("See All >", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))),
        ],
      ),
    );
  }

  // Uses YOUR Products Data
  Widget _buildQuickPicksList() {
    return StreamBuilder<List<Product>>(
      stream: _productsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 260, child: Center(child: CircularProgressIndicator()));
        final products = snapshot.data ?? [];
        if (products.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 270, // Height to accommodate ProductCard
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 150, // Constrained width for horizontal scroll
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