import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../DatabaseService.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favourite.dart';
import '../themes.dart';
class ProductCard extends StatelessWidget {
  final Product product;
  final String? heroSuffix;

  const ProductCard({
    super.key,
    required this.product,
    this.heroSuffix,
  });

  @override
  Widget build(BuildContext context) {
    // Create a unique tag based on the suffix
    final String heroTag = heroSuffix != null
        ? "${product.id}-$heroSuffix"
        : product.id;

    // Check stock status
    final isOutOfStock = product.stock.availableQty <= 0;
    final isLowStock = product.stock.lowStock && !isOutOfStock;

    return GestureDetector(
      onTap: () => _showProductBottomSheet(context, product),
      child: Container(
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
                    child: product.thumbnail.isNotEmpty
                        ? Hero(
                      tag: heroTag,
                      child: Image.network(
                        product.thumbnail,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    )
                        : const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),

                // Stock Status Badge
                if (isOutOfStock)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(11),
                          topRight: Radius.circular(11),
                        ),
                      ),
                      child: Text(
                        "OUT OF STOCK",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  )
                else if (isLowStock)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(11),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        "LOW STOCK",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                // Discount Ribbon
                if (!isOutOfStock && product.discount > 0)
                  Positioned(
                    top: isLowStock ? 24 : 0,
                    left: isLowStock ? 0 : null,
                    right: isLowStock ? null : 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: AppTheme.qcDiscountRed,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(11),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        "${product.discount.toInt()}% OFF",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
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
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              )
                            ],
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
                            color: isFavorite ? AppTheme.qcDiscountRed : Colors.grey.shade400,
                            size: 18,
                          ),
                        ),
                      );
                    },
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
                        // Product Name
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isOutOfStock ? Colors.grey.shade500 : AppTheme.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Unit & Brand
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.unitText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isOutOfStock ? Colors.grey.shade400 : AppTheme.textTertiary,
                              ),
                            ),
                            if (product.brand.isNotEmpty)
                              Text(
                                product.brand,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isOutOfStock ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    // 3. Price and Add Button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₹${product.price.toStringAsFixed(product.price % 1 == 0 ? 0 : 2)}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isOutOfStock ? Colors.grey.shade500 : AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (product.discount > 0 && !isOutOfStock)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  "₹${product.mrp.toStringAsFixed(product.mrp % 1 == 0 ? 0 : 2)}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    decoration: TextDecoration.lineThrough,
                                    color: AppTheme.textTertiary,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // Ratings (if any)
                        if (product.ratings.count > 0 && !isOutOfStock)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber.shade600, size: 12),
                                const SizedBox(width: 2),
                                Text(
                                  "${product.ratings.average.toStringAsFixed(1)}",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  " (${product.ratings.count})",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 8),

                        // Add to Cart / Quantity Counter
                        Consumer<CartProvider>(
                          builder: (context, cart, child) {
                            final int quantity = cart.items.containsKey(product.id)
                                ? cart.items[product.id]!.quantity
                                : 0;

                            return isOutOfStock
                                ? _buildOutOfStockButton()
                                : quantity == 0
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

  Widget _buildOutOfStockButton() {
    return SizedBox(
      width: double.infinity,
      height: 32,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: const Text(
          "OUT OF STOCK",
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: const Text(
          "ADD",
          style: TextStyle(
            color: AppTheme.qcGreen,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
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
            onTap: () => cart.removeItem(product.id),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.remove, color: Colors.white, size: 16),
            ),
          ),
          Text(
            "$quantity",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          InkWell(
            onTap: () {
              // Check stock before adding
              if (quantity >= product.stock.availableQty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Only ${product.stock.availableQty} items available"),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              if (quantity >= product.attributes.maxOrder) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Maximum ${product.attributes.maxOrder} items allowed"),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              cart.addItem(product);
            },
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
    final isOutOfStock = product.stock.availableQty <= 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ProductDetailsSheet(product: product);
      },
    );
  }
}

// Separate Product Details Sheet for better organization
class ProductDetailsSheet extends StatelessWidget {
  final Product product;

  const ProductDetailsSheet({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.stock.availableQty <= 0;
    final isLowStock = product.stock.lowStock && !isOutOfStock;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Product Images
            SizedBox(
              height: 200,
              child: product.images.isNotEmpty
                  ? PageView.builder(
                itemCount: product.images.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade100,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product.images[index],
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                },
              )
                  : const Center(
                child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // Product Name and Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isOutOfStock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Text(
                      "Out of Stock",
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (isLowStock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.orange.shade100),
                    ),
                    child: Text(
                      "Low Stock",
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Price Row
            Row(
              children: [
                Text(
                  "₹${product.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                if (product.discount > 0)
                  Text(
                    "₹${product.mrp.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                const SizedBox(width: 8),
                if (product.discount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "${product.discount.toInt()}% OFF",
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Unit and Stock
            Row(
              children: [
                Text(
                  product.unitText,
                  style: const TextStyle(color: Colors.grey),
                ),
                const Spacer(),
                if (!isOutOfStock)
                  Text(
                    "${product.stock.availableQty} items available",
                    style: const TextStyle(color: Colors.grey),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Description
            if (product.description.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // Attributes
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Product Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (product.brand.isNotEmpty)
                      _buildAttributeChip("Brand", product.brand),
                    if (product.attributes.organic)
                      _buildAttributeChip("Organic", "Yes", color: Colors.green),
                    if (product.attributes.vegetarian)
                      _buildAttributeChip("Vegetarian", "Yes", color: Colors.green),
                    if (product.attributes.weight > 0)
                      _buildAttributeChip(
                        "Weight",
                        "${product.attributes.weight}${product.attributes.weightUnit}",
                      ),
                    if (product.attributes.perishable)
                      _buildAttributeChip("Perishable", "Yes"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              child: Consumer<CartProvider>(
                builder: (context, cart, _) {
                  final int quantity = cart.items.containsKey(product.id)
                      ? cart.items[product.id]!.quantity
                      : 0;

                  return isOutOfStock
                      ? ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "OUT OF STOCK",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                      : quantity == 0
                      ? ElevatedButton(
                    onPressed: () => cart.addItem(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Add to Cart",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                      : Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.qcGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => cart.removeItem(product.id),
                            child: const Center(
                              child: Icon(Icons.remove, color: Colors.white, size: 24),
                            ),
                          ),
                        ),
                        Text(
                          "$quantity in cart",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (quantity >= product.stock.availableQty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Only ${product.stock.availableQty} items available"),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              if (quantity >= product.attributes.maxOrder) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Maximum ${product.attributes.maxOrder} items allowed"),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              cart.addItem(product);
                            },
                            child: const Center(
                              child: Icon(Icons.add, color: Colors.white, size: 24),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeChip(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color != null ? Colors.white : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color != null ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

