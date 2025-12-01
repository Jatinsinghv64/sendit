// file: lib/screens/settings_screen.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isWorking = false;
  final bool devOnly = true;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Random _rand = Random();

  // Product data
  final List<String> _brands = [
    'LocalFarm', 'FreshCo', 'GreenLeaf', 'DailyHarvest', 'PureFoods',
    'Nestle', 'Amul', 'Britannia', 'Tata', 'Parle'
  ];

  final List<String> _categories = [
    'fruits', 'vegetables', 'dairy', 'bakery', 'snacks', 'beverages',
    'personal_care', 'cleaning', 'staples', 'frozen'
  ];

  final Map<String, Map<String, dynamic>> _categoryInfo = {
    'fruits': {'name': 'Fresh Fruits', 'path': ['grocery', 'fruits']},
    'vegetables': {'name': 'Fresh Vegetables', 'path': ['grocery', 'vegetables']},
    'dairy': {'name': 'Dairy & Eggs', 'path': ['grocery', 'dairy']},
    'bakery': {'name': 'Bakery', 'path': ['grocery', 'bakery']},
    'snacks': {'name': 'Snacks', 'path': ['grocery', 'snacks']},
    'beverages': {'name': 'Beverages', 'path': ['grocery', 'beverages']},
    'personal_care': {'name': 'Personal Care', 'path': ['personal', 'care']},
    'cleaning': {'name': 'Cleaning', 'path': ['home', 'cleaning']},
    'staples': {'name': 'Staples', 'path': ['grocery', 'staples']},
    'frozen': {'name': 'Frozen Foods', 'path': ['grocery', 'frozen']},
  };

  final List<String> _imagePlaceholders = [
    'https://picsum.photos/seed/p1/600/400',
    'https://picsum.photos/seed/p2/600/400',
    'https://picsum.photos/seed/p3/600/400',
  ];

  final List<String> _suppliers = [
    'Fresh Farms', 'Mega Distributors', 'Local Wholesale', 'Direct Imports'
  ];

  Future<void> _generateProducts({int count = 60}) async {
    if (devOnly) {
      // Add your dev check logic here
    }

    setState(() => _isWorking = true);
    final WriteBatch productBatch = _db.batch();
    final WriteBatch inventoryBatch = _db.batch();
    final now = Timestamp.now();

    try {
      for (int i = 0; i < count; i++) {
        // Generate product ID using SKU
        final category = _categories[_rand.nextInt(_categories.length)];
        final sku = _makeSku(category, i);
        final productId = sku; // Using SKU as product ID

        final productDocRef = _db.collection('products').doc(productId);
        final inventoryDocRef = _db.collection('inventory').doc();

        // Product data
        final categoryInfo = _categoryInfo[category]!;
        final brand = _brands[_rand.nextInt(_brands.length)];
        final productName = _makeProductName(category, i);
        final mrp = (20 + _rand.nextInt(480)).toDouble();
        final sellingPrice = double.parse((mrp * (0.7 + _rand.nextDouble() * 0.25)).toStringAsFixed(2));
        final discountPercent = double.parse(((1 - sellingPrice / mrp) * 100).toStringAsFixed(1));
        final unit = _pickUnit(category);
        final unitText = _getUnitText(unit);

        // Determine if perishable
        final bool perishable = _isPerishable(category);

        // Get weight (FIXED: Cast to int)
        final weight = _pickWeight(category);

        // Product Document
        final Map<String, dynamic> productDoc = {
          'id': productId,
          'name': productName,
          'description': '$productName — Premium quality, fresh and hygienic.',
          'brand': brand,
          'category': {
            'id': category,
            'path': categoryInfo['path'],
            'name': categoryInfo['name'],
          },
          'images': [
            _imagePlaceholders[_rand.nextInt(_imagePlaceholders.length)],
          ],
          'thumbnail': _imagePlaceholders[_rand.nextInt(_imagePlaceholders.length)],

          // Simplified Pricing
          'price': sellingPrice,
          'mrp': mrp,
          'discount': discountPercent,
          'unit': unit,
          'unitText': unitText,

          // Stock Status (will be updated by inventory)
          'stock': {
            'availableQty': 0, // Will be calculated from inventory
            'isAvailable': true,
            'lowStock': false,
            'lastUpdated': now,
          },

          // Variants (some products have variants)
          'variants': _generateVariants(category, productName, sellingPrice, mrp, productId),

          // Attributes for filtering
          'attributes': {
            'weight': weight, // Now properly typed as int
            'weightUnit': 'g',
            'vegetarian': !category.contains('personal') && !category.contains('cleaning'),
            'organic': _rand.nextDouble() > 0.7,
            'allergens': [],
            'perishable': perishable,
            'minOrder': 1,
            'maxOrder': _pickMaxOrder(category),
          },

          // Status flags
          'isActive': true,
          'isFeatured': _rand.nextDouble() > 0.8,
          'isBestSeller': _rand.nextDouble() > 0.9,

          // Analytics
          'ratings': {
            'average': double.parse((3.5 + _rand.nextDouble() * 1.5).toStringAsFixed(1)),
            'count': 1 + _rand.nextInt(500),
          },
          'soldCount': _rand.nextInt(2000),

          // Timestamps
          'createdAt': now,
          'updatedAt': now,

          // Search & Filtering
          'searchKeywords': _generateKeywords(productName, category),
          'tags': _generateTags(category),
        };

        // Inventory Document
        final initialQty = 10 + _rand.nextInt(200);
        final expiryDate = perishable
            ? DateTime.now().add(Duration(days: 3 + _rand.nextInt(120)))
            : null;

        final Map<String, dynamic> inventoryDoc = {
          'inventoryId': inventoryDocRef.id,
          'productId': productId,
          'productName': productName,
          'sku': sku,

          // Batch Tracking
          'batch': {
            'batchId': 'BATCH-${DateTime.now().millisecondsSinceEpoch}-${_rand.nextInt(1000)}',
            'batchNumber': 'B${(i+1).toString().padLeft(3, '0')}',
            'supplierBatch': 'SUP-${_rand.nextInt(10000)}',
            'manufactureDate': Timestamp.fromDate(DateTime.now().subtract(Duration(days: _rand.nextInt(30)))),
            'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate) : null,
            'daysToExpiry': expiryDate != null ? expiryDate.difference(DateTime.now()).inDays : null,
          },

          // Stock Details
          'stock': {
            'initialQty': initialQty,
            'currentQty': initialQty,
            'reservedQty': 0,
            'availableQty': initialQty,
            'damagedQty': 0,
            'returnedQty': 0,
            'unit': unit,
            'location': {
              'aisle': ['A', 'B', 'C'][_rand.nextInt(3)],
              'rack': 'R${_rand.nextInt(10) + 1}',
              'shelf': 'S${_rand.nextInt(5) + 1}',
              'bin': 'B${_rand.nextInt(20) + 1}',
            },
          },

          // Purchase Details
          'purchase': {
            'supplierId': 'SUP-${_rand.nextInt(10) + 1}',
            'supplierName': _suppliers[_rand.nextInt(_suppliers.length)],
            'purchasePrice': double.parse((sellingPrice * 0.7).toStringAsFixed(2)),
            'purchaseDate': Timestamp.fromDate(DateTime.now().subtract(Duration(days: _rand.nextInt(30)))),
            'invoiceNumber': 'INV-${DateTime.now().millisecondsSinceEpoch}',
            'taxPercent': [0, 5, 12, 18][_rand.nextInt(4)],
          },

          // Status
          'status': {
            'isActive': true,
            'isExpired': false,
            'qualityCheck': 'approved',
            'holdReason': null,
          },

          // Reordering
          'reorder': {
            'reorderPoint': 10 + _rand.nextInt(30),
            'reorderQty': 50 + _rand.nextInt(150),
            'leadTimeDays': 1 + _rand.nextInt(7),
            'lastReorderDate': Timestamp.fromDate(DateTime.now().subtract(Duration(days: _rand.nextInt(30)))),
            'nextReorderDate': null,
          },

          'createdAt': now,
          'updatedAt': now,
        };

        // Add to batches
        productBatch.set(productDocRef, productDoc);
        inventoryBatch.set(inventoryDocRef, inventoryDoc);

        // Create initial stock movement
        await _createInitialStockMovement(
          productId: productId,
          inventoryId: inventoryDocRef.id,
          sku: sku,
          quantity: initialQty,
        );
      }

      // Commit batches
      await productBatch.commit();
      await inventoryBatch.commit();

      // Update product stock from inventory
      await _updateProductStockFromInventory();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Generated $count sample products and inventory successfully.')),
      );
    } catch (e, st) {
      debugPrint('Error generating products: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate products: $e')),
      );
    } finally {
      setState(() => _isWorking = false);
    }
  }

  Future<void> _createInitialStockMovement({
    required String productId,
    required String inventoryId,
    required String sku,
    required int quantity,
  }) async {
    try {
      await _db.collection('stock_movements').add({
        'movementId': Timestamp.now().nanoseconds.toString(),
        'productId': productId,
        'inventoryId': inventoryId,
        'sku': sku,
        'type': 'purchase',
        'subType': 'initial_stock',
        'referenceId': 'INIT-${DateTime.now().millisecondsSinceEpoch}',
        'referenceType': 'initial',
        'quantity': quantity,
        'unit': 'pcs',
        'price': 0.0,
        'fromQty': 0,
        'toQty': quantity,
        'userId': 'system',
        'userName': 'System Admin',
        'userRole': 'admin',
        'notes': 'Initial stock creation',
        'timestamp': Timestamp.now(),
        'branchId': 'branch_main',
      });
    } catch (e) {
      debugPrint('Error creating stock movement: $e');
    }
  }

  Future<void> _updateProductStockFromInventory() async {
    try {
      final inventorySnapshot = await _db.collection('inventory').get();

      final batch = _db.batch();

      // Group inventory by productId
      final Map<String, int> productStock = {};

      for (var doc in inventorySnapshot.docs) {
        final data = doc.data();
        final productId = data['productId'];
        final currentQty = data['stock']['currentQty'] ?? 0;

        productStock.update(
          productId,
              (value) => value + (currentQty as int), // Cast to int
          ifAbsent: () => currentQty as int, // Cast to int
        );
      }

      // Update each product
      for (var entry in productStock.entries) {
        final productRef = _db.collection('products').doc(entry.key);

        batch.update(productRef, {
          'stock.availableQty': entry.value,
          'stock.isAvailable': entry.value > 0,
          'stock.lowStock': entry.value < 20,
          'stock.lastUpdated': Timestamp.now(),
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error updating product stock: $e');
    }
  }

  List<Map<String, dynamic>> _generateVariants(
      String category,
      String productName,
      double sellingPrice,
      double mrp,
      String baseProductId
      ) {
    final List<Map<String, dynamic>> variants = [];

    if (_rand.nextDouble() > 0.6) { // 40% of products have variants
      final variantUnits = _getVariantUnits(category);

      for (int i = 0; i < min(variantUnits.length, 3); i++) {
        final unit = variantUnits[i];
        final unitText = _getUnitText(unit);
        final price = sellingPrice * _getVariantMultiplier(unit);
        final variantMrp = mrp * _getVariantMultiplier(unit);

        variants.add({
          'id': '${baseProductId}-${unit}',
          'name': '${productName.split('(')[0]}($unitText)',
          'price': double.parse(price.toStringAsFixed(2)),
          'mrp': double.parse(variantMrp.toStringAsFixed(2)),
          'stock': 10 + _rand.nextInt(100),
          'unit': unit,
          'unitText': unitText,
        });
      }
    }

    return variants;
  }

  List<String> _getVariantUnits(String category) {
    switch (category) {
      case 'fruits':
      case 'vegetables':
        return ['500g', '1kg', '2kg'];
      case 'beverages':
        return ['250ml', '500ml', '1L'];
      case 'snacks':
        return ['50g', '100g', '200g'];
      default:
        return [];
    }
  }

  double _getVariantMultiplier(String unit) {
    if (unit.contains('500')) return 0.5;
    if (unit.contains('250')) return 0.25;
    if (unit.contains('2')) return 2.0;
    if (unit.contains('100')) return 1.0;
    if (unit.contains('50')) return 0.5;
    if (unit.contains('200')) return 2.0;
    return 1.0;
  }

  String _makeProductName(String category, int index) {
    final Map<String, List<String>> categoryProducts = {
      'fruits': ['Fresh Banana', 'Apple', 'Orange', 'Mango', 'Grapes', 'Pomegranate', 'Watermelon', 'Papaya'],
      'vegetables': ['Tomato', 'Potato', 'Onion', 'Spinach', 'Carrot', 'Cabbage', 'Cauliflower', 'Broccoli'],
      'dairy': ['Milk', 'Paneer', 'Curd', 'Butter', 'Cheese', 'Cream'],
      'bakery': ['Brown Bread', 'Buns', 'Croissant', 'Cookies', 'Cake', 'Pastry'],
      'snacks': ['Potato Chips', 'Nuts Mix', 'Biscuits', 'Chocolate', 'Namkeen'],
      'beverages': ['Orange Juice', 'Green Tea', 'Coffee', 'Soft Drink', 'Energy Drink'],
      'personal_care': ['Shampoo', 'Soap', 'Toothpaste', 'Face Wash', 'Body Lotion'],
      'cleaning': ['Detergent', 'Floor Cleaner', 'Dish Wash', 'Toilet Cleaner'],
      'staples': ['Rice', 'Wheat Flour', 'Sugar', 'Salt', 'Pulses'],
      'frozen': ['Ice Cream', 'Frozen Vegetables', 'Frozen Chicken'],
    };

    final names = categoryProducts[category] ?? ['Product ${index + 1}'];
    final name = names[_rand.nextInt(names.length)];

    // Randomly add brand or quality descriptor
    final descriptors = ['Premium', 'Organic', 'Fresh', 'Best Quality', 'Family Pack'];
    final descriptor = _rand.nextDouble() > 0.7 ? '${descriptors[_rand.nextInt(descriptors.length)]} ' : '';

    return '$descriptor$name';
  }

  String _makeSku(String category, int index) {
    final prefix = category.substring(0, min(3, category.length)).toUpperCase();
    return '$prefix-${(DateTime.now().millisecondsSinceEpoch % 100000).toString().padLeft(5, '0')}-${(index + 1).toString().padLeft(3, '0')}';
  }

  String _pickUnit(String category) {
    switch (category) {
      case 'fruits':
      case 'vegetables':
        return ['500g', '1kg'][_rand.nextInt(2)];
      case 'dairy':
        return ['500ml', '1L', 'pack'][_rand.nextInt(3)];
      case 'beverages':
        return ['250ml', '500ml', '1L'][_rand.nextInt(3)];
      case 'snacks':
        return ['50g', '100g', '200g'][_rand.nextInt(3)];
      default:
        return ['pcs', 'pack'][_rand.nextInt(2)];
    }
  }

  String _getUnitText(String unit) {
    switch (unit) {
      case '500g': return '500g';
      case '1kg': return 'per kg';
      case '250ml': return '250ml';
      case '500ml': return '500ml';
      case '1L': return '1L';
      case '50g': return '50g';
      case '100g': return '100g';
      case '200g': return '200g';
      case 'pcs': return 'per piece';
      case 'pack': return 'per pack';
      default: return 'per unit';
    }
  }

  // FIXED: Now returns int instead of num
  int _pickWeight(String category) {
    switch (category) {
      case 'fruits':
      case 'vegetables':
        return [500, 1000, 2000][_rand.nextInt(3)];
      case 'dairy':
        return [500, 1000][_rand.nextInt(2)];
      case 'beverages':
        return [250, 500, 1000][_rand.nextInt(3)];
      case 'snacks':
        return [50, 100, 200][_rand.nextInt(3)];
      default:
        return [100, 200, 500][_rand.nextInt(3)];
    }
  }

  int _pickMaxOrder(String category) {
    if (category == 'fruits' || category == 'vegetables') return 20;
    if (category == 'dairy') return 10;
    return 5;
  }

  bool _isPerishable(String category) {
    return ['fruits', 'vegetables', 'dairy', 'bakery', 'frozen'].contains(category);
  }

  List<String> _generateKeywords(String productName, String category) {
    final keywords = <String>[];
    keywords.addAll(productName.toLowerCase().split(' '));
    keywords.add(category);
    keywords.addAll(_categoryInfo[category]!['name'].toString().toLowerCase().split(' '));

    // Add common grocery keywords
    keywords.addAll(['grocery', 'online', 'delivery', 'home', 'shop']);

    return keywords.toSet().toList();
  }

  List<String> _generateTags(String category) {
    final tags = <String>[category];

    // Add quality tags
    if (_rand.nextDouble() > 0.7) tags.add('organic');
    if (_rand.nextDouble() > 0.8) tags.add('best seller');
    if (_rand.nextDouble() > 0.9) tags.add('new arrival');

    // Add occasion tags
    if (category == 'snacks' || category == 'beverages') tags.add('party');
    if (category == 'fruits' || category == 'vegetables') tags.add('healthy');
    if (category == 'dairy') tags.add('breakfast');

    return tags;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Admin'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.primary.withOpacity(0.02),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.admin_panel_settings, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 10),
                          Text(
                            'Database Management',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Use these tools carefully. This will create sample data in your Firestore database.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generate Sample Data',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Creates 60 products with complete inventory management system.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 15),

                      ElevatedButton.icon(
                        icon: _isWorking
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Icon(Icons.data_thresholding),
                        label: Text(
                          _isWorking ? 'Generating...' : 'Generate Products & Inventory',
                          style: TextStyle(fontSize: 15),
                        ),
                        onPressed: _isWorking
                            ? null
                            : () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text('⚠️ Generate Sample Data'),
                              content: const Text(
                                  'This will create:\n'
                                      '• 60 products in "products" collection\n'
                                      '• Corresponding inventory records\n'
                                      '• Initial stock movements\n\n'
                                      'Existing data will not be deleted. Continue?'
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c, false),
                                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  style: ElevatedButton.styleFrom(
                                    // FIXED: Use backgroundColor instead of passing Color directly
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                  ),
                                  child: const Text('Generate', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await _generateProducts(count: 60);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: _isWorking
                              ? Colors.grey
                              : Theme.of(context).colorScheme.primary,
                          // FIXED: Use foregroundColor for text color
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Collections Created',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildCollectionInfo('products', 'Customer-facing product catalog'),
                      _buildCollectionInfo('inventory', 'Detailed stock & batch management'),
                      _buildCollectionInfo('stock_movements', 'Audit log of all stock changes'),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50, // Use .shade50 instead of [50]
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade100), // Use .shade100
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20), // Use .shade700
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'For development only. Restrict access in production.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700, // Use .shade700
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionInfo(String name, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.collections_bookmark, color: Colors.blue[600], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}