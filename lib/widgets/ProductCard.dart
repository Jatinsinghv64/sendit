import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favourite.dart';
import '../themes.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final String? heroSuffix; // Fixes Duplicate Hero Tag error

  const ProductCard({
    super.key,
    required this.product,
    this.heroSuffix,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate discount
    final double originalPrice = product.originalPrice ?? (product.price * 1.2);
    final int discount = product.discount > 0
        ? product.discount
        : ((originalPrice - product.price) / originalPrice * 100).round();

    // Create a unique tag based on the suffix
    final String heroTag = heroSuffix != null
        ? "${product.id}-$heroSuffix"
        : product.id;

    return GestureDetector(
      onTap: () => _showProductBottomSheet(context, product),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Section: Image & Icons
            Stack(
              children: [
                // Product Image with Unique Hero Tag
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                  child: Container(
                    height: 110,
                    width: double.infinity,
                    color: Colors.white,
                    child: product.imageUrl.isNotEmpty
                        ? Hero(
                      tag: heroTag, // <--- Key Fix Here
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.contain,
                      ),
                    )
                        : const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),

                // Discount Ribbon
                if (discount > 0)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: AppTheme.qcDiscountRed,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(11),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        "$discount% OFF",
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),

                // Favorite Icon
                Positioned(
                  top: 4,
                  right: 4,
                  child: Consumer<FavoritesProvider>(
                    builder: (context, fav, child) {
                      final isFavorite = fav.isFavorite(product.id);
                      return GestureDetector(
                        onTap: () => fav.toggleFavorite(product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
                              ]
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
                            color: isFavorite ? AppTheme.qcDiscountRed : Colors.grey[400],
                            size: 18,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Delivery Tag
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt, size: 10, color: Color(0xFF6B7280)),
                        const SizedBox(width: 2),
                        Text(
                          product.deliveryTime,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 2. Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.unit,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),

                    // 3. Price and Add Button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "\$${product.price.toStringAsFixed(0)}",
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(width: 6),
                            if (discount > 0)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  "\$${originalPrice.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    decoration: TextDecoration.lineThrough,
                                    color: AppTheme.textTertiary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Consumer<CartProvider>(
                          builder: (context, cart, child) {
                            final int quantity = cart.items.containsKey(product.id)
                                ? cart.items[product.id]!.quantity
                                : 0;

                            return quantity == 0
                                ? _buildAddButton(context, cart)
                                : _buildQuantityCounter(context, cart, quantity);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, CartProvider cart) {
    return SizedBox(
      width: double.infinity,
      height: 32,
      child: OutlinedButton(
        onPressed: () => cart.addItem(product),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: AppTheme.qcGreenLight,
          side: const BorderSide(color: AppTheme.qcGreen),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: const Text(
          "ADD",
          style: TextStyle(color: AppTheme.qcGreen, fontWeight: FontWeight.w800, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildQuantityCounter(BuildContext context, CartProvider cart, int quantity) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.qcGreen,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => cart.removeSingleItem(product.id),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.remove, color: Colors.white, size: 16),
            ),
          ),
          Text(
            "$quantity",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          InkWell(
            onTap: () => cart.addItem(product),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showProductBottomSheet(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              SizedBox(
                height: 180,
                child: Image.network(product.imageUrl, fit: BoxFit.contain),
              ),
              const SizedBox(height: 20),
              Text(product.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(product.description.isNotEmpty ? product.description : "No description available.",
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Consumer<CartProvider>(
                  builder: (context, cart, _) {
                    final int quantity = cart.items.containsKey(product.id) ? cart.items[product.id]!.quantity : 0;
                    return quantity == 0
                        ? ElevatedButton(
                      onPressed: () => cart.addItem(product),
                      child: const Text("Add to Cart"),
                    )
                        : _buildQuantityCounter(context, cart, quantity);
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}