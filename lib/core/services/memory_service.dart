import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'error_service.dart';

/// Service for memory management and monitoring
class MemoryService {
  static final MemoryService _instance = MemoryService._internal();
  factory MemoryService() => _instance;
  MemoryService._internal();

  final ErrorService _errorService = ErrorService();
  final Map<String, List<Object>> _cachedObjects = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _defaultCacheExpiry = Duration(minutes: 30);

  /// Cache an object with optional expiry time
  void cacheObject(String key, Object object, {Duration? expiry}) {
    try {
      _cachedObjects[key] = [object];
      _cacheTimestamps[key] = DateTime.now();
      
      // Clean up expired cache entries
      _cleanExpiredCache(expiry ?? _defaultCacheExpiry);
      
      if (kDebugMode) {
        _errorService.logInfo('Cached object: $key', context: 'Memory');
      }
    } catch (error) {
      _errorService.logError('Failed to cache object: $key', error: error);
    }
  }

  /// Retrieve cached object
  T? getCachedObject<T>(String key) {
    try {
      final cached = _cachedObjects[key];
      final timestamp = _cacheTimestamps[key];
      
      if (cached != null && cached.isNotEmpty && timestamp != null) {
        // Check if cache is still valid
        if (DateTime.now().difference(timestamp) < _defaultCacheExpiry) {
          return cached.first as T?;
        } else {
          // Remove expired cache
          _cachedObjects.remove(key);
          _cacheTimestamps.remove(key);
        }
      }
      
      return null;
    } catch (error) {
      _errorService.logError('Failed to retrieve cached object: $key', error: error);
      return null;
    }
  }

  /// Remove cached object
  void removeCachedObject(String key) {
    _cachedObjects.remove(key);
    _cacheTimestamps.remove(key);
    
    if (kDebugMode) {
      _errorService.logInfo('Removed cached object: $key', context: 'Memory');
    }
  }

  /// Clear all cached objects
  void clearCache() {
    final count = _cachedObjects.length;
    _cachedObjects.clear();
    _cacheTimestamps.clear();
    
    if (kDebugMode) {
      _errorService.logInfo('Cleared $count cached objects', context: 'Memory');
    }
  }

  /// Clean expired cache entries
  void _cleanExpiredCache(Duration expiry) {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) > expiry) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _cachedObjects.remove(key);
      _cacheTimestamps.remove(key);
    }
    
    if (expiredKeys.isNotEmpty && kDebugMode) {
      _errorService.logInfo('Cleaned ${expiredKeys.length} expired cache entries', context: 'Memory');
    }
  }

  /// Get current memory usage (if available)
  Map<String, dynamic> getMemoryInfo() {
    final info = <String, dynamic>{};
    
    try {
      // Add cache information
      info['cached_objects_count'] = _cachedObjects.length;
      info['cache_size_estimate'] = _estimateCacheSize();
      
      // Add system memory info if available
      if (Platform.isLinux || Platform.isMacOS) {
        final result = Process.runSync('free', ['-m']);
        if (result.exitCode == 0) {
          info['system_memory_info'] = result.stdout.toString();
        }
      }
    } catch (error) {
      _errorService.logError('Failed to get memory info', error: error);
    }
    
    return info;
  }

  /// Estimate cache size (rough approximation)
  int _estimateCacheSize() {
    try {
      int totalSize = 0;
      for (final objects in _cachedObjects.values) {
        for (final obj in objects) {
          // Very rough size estimation
          if (obj is String) {
            totalSize += obj.length * 2; // UTF-16 encoding
          } else if (obj is List) {
            totalSize += obj.length * 8; // Approximate pointer size
          } else if (obj is Map) {
            totalSize += obj.length * 16; // Key-value pairs
          } else {
            totalSize += 100; // Default object overhead
          }
        }
      }
      return totalSize;
    } catch (error) {
      _errorService.logError('Failed to estimate cache size', error: error);
      return 0;
    }
  }

  /// Check if memory usage is high
  bool isMemoryUsageHigh() {
    try {
      final cacheSize = _estimateCacheSize();
      const maxCacheSize = 50 * 1024 * 1024; // 50MB threshold
      
      return cacheSize > maxCacheSize;
    } catch (error) {
      _errorService.logError('Failed to check memory usage', error: error);
      return false;
    }
  }

  /// Optimize memory usage
  void optimizeMemory() {
    try {
      final initialCount = _cachedObjects.length;
      
      // Clean expired cache first
      _cleanExpiredCache(_defaultCacheExpiry);
      
      // If still high memory usage, remove oldest cache entries
      if (isMemoryUsageHigh()) {
        final sortedEntries = _cacheTimestamps.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));
        
        // Remove oldest 25% of cache entries
        final removeCount = (sortedEntries.length * 0.25).round();
        for (int i = 0; i < removeCount && i < sortedEntries.length; i++) {
          final key = sortedEntries[i].key;
          _cachedObjects.remove(key);
          _cacheTimestamps.remove(key);
        }
      }
      
      final finalCount = _cachedObjects.length;
      final removedCount = initialCount - finalCount;
      
      if (removedCount > 0 && kDebugMode) {
        _errorService.logInfo(
          'Memory optimization removed $removedCount cached objects',
          context: 'Memory',
        );
      }
    } catch (error) {
      _errorService.logError('Failed to optimize memory', error: error);
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStatistics() {
    return {
      'total_objects': _cachedObjects.length,
      'estimated_size_bytes': _estimateCacheSize(),
      'oldest_cache_age_minutes': _getOldestCacheAge()?.inMinutes,
      'memory_usage_high': isMemoryUsageHigh(),
    };
  }

  /// Get age of oldest cache entry
  Duration? _getOldestCacheAge() {
    if (_cacheTimestamps.isEmpty) return null;
    
    final oldestTimestamp = _cacheTimestamps.values
        .reduce((a, b) => a.isBefore(b) ? a : b);
    
    return DateTime.now().difference(oldestTimestamp);
  }
}

/// Mixin for adding memory management to widgets
mixin MemoryManagementMixin {
  final MemoryService _memoryService = MemoryService();

  /// Cache data for this widget
  void cacheWidgetData(String key, Object data) {
    _memoryService.cacheObject('${runtimeType}_$key', data);
  }

  /// Get cached data for this widget
  T? getCachedWidgetData<T>(String key) {
    return _memoryService.getCachedObject<T>('${runtimeType}_$key');
  }

  /// Clear cached data for this widget
  void clearWidgetCache() {
    final prefix = '${runtimeType}_';
    final keysToRemove = _memoryService._cachedObjects.keys
        .where((key) => key.startsWith(prefix))
        .toList();
    
    for (final key in keysToRemove) {
      _memoryService.removeCachedObject(key);
    }
  }
}

/// Memory monitor widget for debugging
class MemoryDebugWidget extends StatefulWidget {
  const MemoryDebugWidget({Key? key}) : super(key: key);

  @override
  State<MemoryDebugWidget> createState() => _MemoryDebugWidgetState();
}

class _MemoryDebugWidgetState extends State<MemoryDebugWidget> {
  final MemoryService _memoryService = MemoryService();
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _updateStats();
  }

  void _updateStats() {
    setState(() {
      _stats = _memoryService.getCacheStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Memory Statistics',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _updateStats,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Cached Objects: ${_stats['total_objects'] ?? 0}'),
            Text('Cache Size: ${(_stats['estimated_size_bytes'] ?? 0) ~/ 1024} KB'),
            Text('Oldest Cache: ${_stats['oldest_cache_age_minutes'] ?? 0} min'),
            Text('High Memory Usage: ${_stats['memory_usage_high'] ?? false}'),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _memoryService.optimizeMemory();
                    _updateStats();
                  },
                  child: const Text('Optimize'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _memoryService.clearCache();
                    _updateStats();
                  },
                  child: const Text('Clear Cache'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}