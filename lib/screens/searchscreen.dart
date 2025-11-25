import 'package:flutter/material.dart';
import '../DatabaseService.dart';
import '../models/product.dart';
import '../widgets/ProductCard.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
          decoration: const InputDecoration(
            hintText: "Search for 'Paneer'",
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _searchQuery.isEmpty
          ? _buildSuggestions()
          : _buildSearchResults(),
    );
  }

  Widget _buildSuggestions() {
    final List<String> suggestions = [
      "Milk",
      "Bread",
      "Eggs",
      "Butter",
      "Tomatoes",
      "Potatoes"
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Popular Searches", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((s) => ActionChip(
              label: Text(s),
              backgroundColor: Colors.grey[100],
              shape: const StadiumBorder(side: BorderSide.none),
              onPressed: () {
                _searchController.text = s;
                setState(() {
                  _searchQuery = s.toLowerCase();
                });
              },
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<List<Product>>(
      stream: _dbService.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No products found"));
        }

        // Client-side filtering
        final results = snapshot.data!.where((p) =>
            p.name.toLowerCase().contains(_searchQuery)
        ).toList();

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text("No matching items found", style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final product = results[index];
            return ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.imageUrl.isNotEmpty
                    ? Image.network(product.imageUrl, fit: BoxFit.cover)
                    : const Icon(Icons.image, size: 20, color: Colors.grey),
              ),
              title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(product.unit),
              trailing: Text("\$${product.price}", style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                // Optionally navigate to detail or show bottom sheet
                showModalBottomSheet(
                    context: context,
                    builder: (_) => Container(
                      padding: const EdgeInsets.all(16),
                      height: 200,
                      child: ProductCard(product: product), // Reuse ProductCard
                    )
                );
              },
            );
          },
        );
      },
    );
  }
}