import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../themes.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    final heroTag = heroSuffix != null ? "${product.id}-$heroSuffix" : product.id;
    final isOutOfStock = product.stock.availableQty <= 0;

    // CACHE BUSTER: Append lastUpdated timestamp to URL to force refresh when data changes
    String imageUrl = product.thumbnail;
    if (imageUrl.isNotEmpty) {
      // Logic: If lastUpdated is epoch(0) (default from model), it won't affect URL much.
      // If it is a real timestamp from Firestore, it acts as a version key.
      final separator = imageUrl.contains('?') ? '&' : '?';
      imageUrl += "${separator}v=${product.stock.lastUpdated.millisecondsSinceEpoch}";
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE SECTION
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Container(
                  height: 120, // Fixed height for image area
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: Hero(
                    tag: heroTag,
                    child: imageUrl.isEmpty
                        ? const Icon(Icons.image_not_supported, color: Colors.grey)
                        : CachedNetworkImage(
                      // FIX: The Key forces the widget to refresh if the URL (including timestamp) changes
                      key: ValueKey(imageUrl),
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      // Show a light spinner while loading
                      placeholder: (context, url) => Center(
                        child: Container(
                            width: 20,
                            height: 20,
                            child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.grey)
                        ),
                      ),
                      errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
              ),

              // Discount Tag (Simple Text)
              if (!isOutOfStock && product.discount > 0)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.qcAccentBlue,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomRight: Radius.circular(8)),
                    ),
                    child: Text(
                      "${product.discount.toInt()}% OFF",
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

              // Time Badge
              Positioned(
                bottom: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 10, color: Colors.grey.shade700),
                      const SizedBox(width: 2),
                      Text("12 mins", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                    ],
                  ),
                ),
              ),

              // (+) Button / Qty Control at Top Right
              Positioned(
                top: 8,
                right: 8,
                child: isOutOfStock
                    ? _buildOutOfStockBadge()
                    : Consumer<CartProvider>(
                  builder: (context, cart, _) {
                    final qty = cart.items.containsKey(product.id) ? cart.items[product.id]!.quantity : 0;
                    return qty == 0
                        ? _buildAddIcon(cart)
                        : _buildQtyControl(cart, qty, product.id, product.stock.availableQty);
                  },
                ),
              ),
            ],
          ),

          // CONTENT SECTION
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.2),
                      ),
                      const SizedBox(height: 2),
                      // Unit
                      Text(
                        product.unitText,
                        style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                  // PRICE
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.discount > 0)
                        Text(
                          "₹${product.mrp.toInt()}",
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      Text(
                        "₹${product.price.toInt()}",
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOutOfStockBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text("OOS", style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  // (+) Icon Button
  Widget _buildAddIcon(CartProvider cart) {
    return InkWell(
      onTap: () => cart.addItem(product),
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.qcGreen),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: const Icon(Icons.add, color: AppTheme.qcGreen, size: 20),
      ),
    );
  }

  // (- Qty +) Control
  Widget _buildQtyControl(CartProvider cart, int qty, String productId, int maxStock) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.qcGreen,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => cart.removeItem(productId),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.remove, color: Colors.white, size: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              "$qty",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          InkWell(
            onTap: () {
              if (qty < maxStock) cart.addItem(product);
            },
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

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