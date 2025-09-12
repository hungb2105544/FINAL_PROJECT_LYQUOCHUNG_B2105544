// core/services/cache_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';

// Cache Statistics Model
class CacheStats {
  final int productsCount;
  final int metadataCount;
  final double totalSize; // in KB
  final DateTime? lastUpdated;

  const CacheStats({
    required this.productsCount,
    required this.metadataCount,
    required this.totalSize,
    this.lastUpdated,
  });

  factory CacheStats.empty() {
    return const CacheStats(
      productsCount: 0,
      metadataCount: 0,
      totalSize: 0,
    );
  }

  @override
  String toString() {
    return 'CacheStats(products: $productsCount, metadata: $metadataCount, size: ${totalSize.toStringAsFixed(2)}KB, lastUpdated: $lastUpdated)';
  }
}

// Cache Category Enum
enum CacheCategory {
  products,
  featuredProducts,
  singleProducts,
}

// Cache Exception
class CacheException implements Exception {
  final String message;
  final String? code;

  const CacheException(this.message, [this.code]);

  @override
  String toString() =>
      'CacheException: $message${code != null ? ' (Code: $code)' : ''}';
}

class CacheService {
  static const String _productsBoxName = 'products_cache';
  static const String _metadataBoxName = 'cache_metadata';

  // Cache expiry times for different types of data
  static const Duration productsCacheExpiry = Duration(minutes: 30);
  static const Duration featuredProductsCacheExpiry = Duration(hours: 1);
  static const Duration singleProductCacheExpiry = Duration(hours: 2);

  Box<ProductModel> get _productsBox =>
      Hive.box<ProductModel>(_productsBoxName);
  Box get _metadataBox => Hive.box(_metadataBoxName);

  // Get cache statistics
  CacheStats getCacheStats() {
    try {
      final productsCount = _productsBox.length;
      final metadataCount = _metadataBox.length;

      // Calculate cache size (approximate)
      final productsSize = _estimateBoxSize(_productsBox);
      final metadataSize = _estimateBoxSize(_metadataBox);

      return CacheStats(
        productsCount: productsCount,
        metadataCount: metadataCount,
        totalSize: productsSize + metadataSize,
        lastUpdated: _getLastCacheUpdate(),
      );
    } catch (e) {
      print('❌ Error getting cache stats: $e');
      return CacheStats.empty();
    }
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    try {
      await _productsBox.clear();
      await _metadataBox.clear();
      print('🧹 All cache cleared successfully');
    } catch (e) {
      print('❌ Error clearing all cache: $e');
      throw CacheException('Failed to clear cache: $e');
    }
  }

  // Clear expired cache
  Future<void> clearExpiredCache() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final keysToDelete = <String>[];
      final productKeysToDelete = <String>[];

      // Check all timestamp entries
      for (final key in _metadataBox.keys) {
        final keyStr = key.toString();
        if (keyStr.endsWith('_timestamp')) {
          final timestamp = _metadataBox.get(key) as int?;
          if (timestamp != null) {
            final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            final currentTime = DateTime.fromMillisecondsSinceEpoch(now);
            final age = currentTime.difference(cacheTime);

            // Determine expiry based on cache type
            Duration expiry = productsCacheExpiry;
            if (keyStr.contains('featured')) {
              expiry = featuredProductsCacheExpiry;
            } else if (keyStr.startsWith('product_') &&
                !keyStr.contains('page')) {
              expiry = singleProductCacheExpiry;
            }

            if (age > expiry) {
              final cacheKey = keyStr.replaceAll('_timestamp', '');
              keysToDelete.add(keyStr);
              keysToDelete.add('${cacheKey}_data');

              // If it's a single product cache, mark product for deletion
              if (keyStr.startsWith('product_') && !keyStr.contains('page')) {
                productKeysToDelete.add(cacheKey);
              }
            }
          }
        }
      }

      // Delete expired metadata
      for (final key in keysToDelete) {
        await _metadataBox.delete(key);
      }

      // Delete expired products
      for (final key in productKeysToDelete) {
        await _productsBox.delete(key);
      }

      if (keysToDelete.isNotEmpty || productKeysToDelete.isNotEmpty) {
        print(
            '🧹 Expired cache cleared: ${keysToDelete.length} metadata entries, ${productKeysToDelete.length} products');
      }
    } catch (e) {
      print('❌ Error clearing expired cache: $e');
      throw CacheException('Failed to clear expired cache: $e');
    }
  }

  // Clear cache for specific category
  Future<void> clearCacheByCategory(CacheCategory category) async {
    try {
      final keysToDelete = <String>[];
      final productKeysToDelete = <String>[];

      for (final key in _metadataBox.keys) {
        final keyStr = key.toString();
        bool shouldDelete = false;

        switch (category) {
          case CacheCategory.products:
            shouldDelete = keyStr.contains('products_page') ||
                keyStr.contains('products_type');
            break;
          case CacheCategory.featuredProducts:
            shouldDelete = keyStr.contains('featured_products');
            break;
          case CacheCategory.singleProducts:
            shouldDelete = keyStr.startsWith('product_') &&
                keyStr.endsWith('_timestamp') &&
                !keyStr.contains('page') &&
                !keyStr.contains('type');
            if (shouldDelete) {
              final productKey = keyStr.replaceAll('_timestamp', '');
              productKeysToDelete.add(productKey);
            }
            break;
        }

        if (shouldDelete) {
          keysToDelete.add(keyStr);
          // Also delete the corresponding _data key
          final baseKey = keyStr.replaceAll('_timestamp', '');
          keysToDelete.add('${baseKey}_data');
        }
      }

      // Delete metadata entries
      for (final key in keysToDelete) {
        await _metadataBox.delete(key);
      }

      // Delete products for single products category
      for (final key in productKeysToDelete) {
        await _productsBox.delete(key);
      }

      print(
          '🧹 Cache category ${category.name} cleared: ${keysToDelete.length} entries');
    } catch (e) {
      print('❌ Error clearing cache by category: $e');
      throw CacheException(
          'Failed to clear cache category ${category.name}: $e');
    }
  }

  // Safe method to get cached product IDs
  List<String>? _getCachedProductIds(String cacheKey) {
    try {
      final cachedData = _metadataBox.get('${cacheKey}_data');
      if (cachedData == null) return null;

      // Safely cast to List<String>
      if (cachedData is List<String>) {
        return cachedData;
      } else if (cachedData is List) {
        // Cast List<dynamic> to List<String>
        return cachedData.cast<String>();
      } else {
        print(
            '❌ Invalid cached data type for $cacheKey: ${cachedData.runtimeType}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting cached product IDs: $e');
      return null;
    }
  }

  // Get last cache update time
  DateTime? _getLastCacheUpdate() {
    try {
      int? latestTimestamp;

      for (final key in _metadataBox.keys) {
        if (key.toString().endsWith('_timestamp')) {
          final timestamp = _metadataBox.get(key) as int?;
          if (timestamp != null) {
            if (latestTimestamp == null || timestamp > latestTimestamp) {
              latestTimestamp = timestamp;
            }
          }
        }
      }

      return latestTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(latestTimestamp)
          : null;
    } catch (e) {
      print('❌ Error getting last cache update: $e');
      return null;
    }
  }

  // Estimate box size (rough calculation)
  double _estimateBoxSize(Box box) {
    try {
      // This is a rough estimation
      // Each entry approximately 1KB for products, 0.1KB for metadata
      if (box.name == _productsBoxName) {
        return box.length * 1.0; // 1KB per product (rough estimate)
      } else {
        return box.length * 0.1; // 0.1KB per metadata entry
      }
    } catch (e) {
      return 0.0;
    }
  }

  // Check if specific cache key exists and is valid
  bool isCacheValid(String cacheKey) {
    try {
      final timestamp = _metadataBox.get('${cacheKey}_timestamp') as int?;
      if (timestamp == null) return false;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cacheTime);

      // Determine expiry based on cache type
      Duration expiry = productsCacheExpiry;
      if (cacheKey.contains('featured')) {
        expiry = featuredProductsCacheExpiry;
      } else if (cacheKey.startsWith('product_') &&
          !cacheKey.contains('page')) {
        expiry = singleProductCacheExpiry;
      }

      return difference < expiry;
    } catch (e) {
      print('❌ Error checking cache validity: $e');
      return false;
    }
  }

  // Get cache age for specific key
  Duration? getCacheAge(String cacheKey) {
    try {
      final timestamp = _metadataBox.get('${cacheKey}_timestamp') as int?;
      if (timestamp == null) return null;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateTime.now().difference(cacheTime);
    } catch (e) {
      print('❌ Error getting cache age: $e');
      return null;
    }
  }

  // Force refresh cache for specific key (mark as expired)
  Future<void> expireCache(String cacheKey) async {
    try {
      await _metadataBox.delete('${cacheKey}_timestamp');
      print('⏰ Cache expired manually: $cacheKey');
    } catch (e) {
      print('❌ Error expiring cache: $e');
      throw CacheException('Failed to expire cache: $e');
    }
  }

  // Get all cache keys
  List<String> getAllCacheKeys() {
    try {
      final keys = <String>[];

      for (final key in _metadataBox.keys) {
        final keyStr = key.toString();
        if (keyStr.endsWith('_timestamp')) {
          keys.add(keyStr.replaceAll('_timestamp', ''));
        }
      }

      return keys;
    } catch (e) {
      print('❌ Error getting all cache keys: $e');
      return [];
    }
  }
}
