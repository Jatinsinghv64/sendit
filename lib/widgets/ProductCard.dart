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
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    width: double.infinity,
                    child: product.imageUrl.isNotEmpty
                        ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    )
                        : const Icon(Icons.image, color: Colors.grey),
                  ),
                  // Functional Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<FavoritesProvider>(
                      builder: (context, favorites, _) {
                        final isFav = favorites.isFavorite(product.id);
                        return GestureDetector(
                          onTap: () {
                            favorites.toggleFavorite(product);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: isFav ? Colors.red : Colors.grey,
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
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${product.unit}",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${product.price.toStringAsFixed(2)}",
                        style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Material(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Provider.of<CartProvider>(context, listen: false).addItem(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${product.name} added"),
                                duration: const Duration(milliseconds: 600),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.black87,
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Icon(Icons.add, color: Colors.white, size: 20),
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
      ),
    );
  }
}