// core/data/local/hive_setup.dart
import 'package:ecommerce_app/features/product/data/models/index.dart';
import 'package:ecommerce_app/features/product/domain/entities/product.dart';
import 'package:ecommerce_app/features/product/domain/entities/sizes.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';

class HiveSetup {
  static Future<void> initialize() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductModelAdapter());
    }
    print("Product Model Adapter Init Successfully");
    Hive.registerAdapter(SimplifiedVariantModelAdapter());
    print("Simplified Variant Init Successfully");
    Hive.registerAdapter(ProductAdapter());
    print("Product Init Successfully");
    Hive.registerAdapter(BrandModelAdapter());
    print("Brand Model Init Successfully");
    Hive.registerAdapter(BranchModelAdapter());
    print("Brach Model Init Successfully");
    Hive.registerAdapter(InventoryModelAdapter());
    print("Inventory Model Init Successfully");
    Hive.registerAdapter(ProductDiscountModelAdapter());
    print("Product Discount Model Adapter Init Successfully");
    Hive.registerAdapter(ProductPriceHistoryModelAdapter());
    print("Product Price History Model Adapter Init Successfully");
    Hive.registerAdapter(ProductRatingModelAdapter());
    print("Product Rating Model Adapter Init Successfully");
    Hive.registerAdapter(SizeModelAdapter());
    print("Size Model Adapter Init Successfully");
    Hive.registerAdapter(ProductSizeModelAdapter());
    print("Product Size Adapter Init Successfully");
    Hive.registerAdapter(ProductTypeModelAdapter());
    print("Product Type Adapter Init Successfully");
    Hive.registerAdapter(ProductVariantImageModelAdapter());
    print("Product Variant Image Adapter Init Successfully");
    Hive.registerAdapter(SizesAdapter());
    print("Sizes Adapter Init Successfully");
    Hive.registerAdapter(ProductVariantModelAdapter());
    print("Product Variant Model Adapter Init Successfully");
    await _openBoxes();
    print('✅ Hive initialized successfully');
  }

  static Future<void> _openBoxes() async {
    try {
      // Open products cache box
      await Hive.openBox<ProductModel>('products_cache');

      // Open cache metadata box
      await Hive.openBox('cache_metadata');

      print('📦 All Hive boxes opened successfully');
    } catch (e) {
      print('❌ Error opening Hive boxes: $e');
      rethrow;
    }
  }

  static Future<void> clearAllData() async {
    try {
      final boxes = [
        'products_cache',
        'cache_metadata',
      ];

      for (final boxName in boxes) {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).clear();
        }
      }

      print('🧹 All Hive data cleared');
    } catch (e) {
      print('❌ Error clearing Hive data: $e');
    }
  }

  static Future<void> closeBoxes() async {
    try {
      await Hive.close();
      print('📦 All Hive boxes closed');
    } catch (e) {
      print('❌ Error closing Hive boxes: $e');
    }
  }

  // Get cache size information
  static Map<String, int> getCacheInfo() {
    final info = <String, int>{};

    try {
      if (Hive.isBoxOpen('products_cache')) {
        info['products_cache'] = Hive.box('products_cache').length;
      }

      if (Hive.isBoxOpen('cache_metadata')) {
        info['cache_metadata'] = Hive.box('cache_metadata').length;
      }
    } catch (e) {
      print('❌ Error getting cache info: $e');
    }

    return info;
  }
}
