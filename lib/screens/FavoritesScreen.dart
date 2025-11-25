import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favourite.dart';
import '../widgets/ProductCard.dart';


class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorites")),
      body: Consumer<FavoritesProvider>(
        builder: (context, favorites, child) {
          if (favorites.count == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text("No favorites yet"),
                  const SizedBox(height: 8),
                  const Text("Tap the heart icon on items you love!", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final favoriteList = favorites.items.values.toList();

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: favoriteList.length,
            itemBuilder: (ctx, i) => ProductCard(product: favoriteList[i]),
          );
        },
      ),
    );
  }
}