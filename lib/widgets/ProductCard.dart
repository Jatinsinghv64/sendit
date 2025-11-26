import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart'; // FIXED: Lowercase import
import '../providers/cart_provider.dart';
import '../providers/favourite.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                // Hero Image
                GestureDetector(
                  onTap: () {
                    // Navigate to details (placeholder)
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    width: double.infinity,
                    child: product.imageUrl.isNotEmpty
                        ? Hero(
                      tag: product.id,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    )
                        : const Icon(Icons.image, color: Colors.grey),
                  ),
                ),

                // Favorite Button
                Positioned(
                  top: 10,
                  right: 10,
                  child: Consumer<FavoritesProvider>(
                    builder: (context, favorites, _) {
                      final isFav = favorites.isFavorite(product.id);
                      return GestureDetector(
                        onTap: () => favorites.toggleFavorite(product),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border_rounded,
                            size: 18,
                            color: isFav ? Colors.redAccent : Colors.grey[600],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  product.unit,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${product.price.toStringAsFixed(2)}",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 16
                      ),
                    ),
                    Material(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Provider.of<CartProvider>(context, listen: false).addItem(product);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${product.name} added to cart"),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.add_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}