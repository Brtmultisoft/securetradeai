import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// OPTIMIZATION: Advanced Data Processor with Compute Functions and Streaming
class OptimizedDataProcessor {
  static final OptimizedDataProcessor _instance = OptimizedDataProcessor._internal();
  factory OptimizedDataProcessor() => _instance;
  OptimizedDataProcessor._internal();

  // OPTIMIZATION: Efficient data structures using Maps for O(1) lookups
  final Map<String, dynamic> _dataCache = {};
  final Map<String, StreamController<dynamic>> _dataStreams = {};
  final Map<String, Timer> _streamTimers = {};
  
  // OPTIMIZATION: Smart caching with TTL
  final Map<String, CacheEntry> _processedDataCache = {};
  static const int CACHE_TTL_SECONDS = 30;
  static const int MAX_CACHE_SIZE = 1000;

  /// OPTIMIZATION: Process JSON data using compute() for heavy operations
  Future<Map<String, dynamic>> processJsonDataOptimized(String jsonString) async {
    try {
      print("🔄 Processing JSON data with compute()...");
      
      // OPTIMIZATION: Use compute() to run JSON processing in separate isolate
      final result = await compute(_processJsonInIsolate, jsonString);
      
      // OPTIMIZATION: Cache processed data with TTL
      final cacheKey = _generateCacheKey(jsonString);
      _processedDataCache[cacheKey] = CacheEntry(
        data: result,
        timestamp: DateTime.now(),
      );
      
      // OPTIMIZATION: Clean cache if it gets too large
      _cleanCacheIfNeeded();
      
      print("✅ JSON processing completed in isolate");
      return result;
      
    } catch (e) {
      print("❌ Error processing JSON data: $e");
      return {};
    }
  }

  /// OPTIMIZATION: JSON processing function for isolate
  static Map<String, dynamic> _processJsonInIsolate(String jsonString) {
    try {
      final stopwatch = Stopwatch()..start();
      
      // Parse JSON
      final data = json.decode(jsonString);
      
      // OPTIMIZATION: Process data efficiently
      final result = <String, dynamic>{};
      
      if (data is Map<String, dynamic>) {
        result.addAll(_processMapData(data));
      } else if (data is List) {
        result['items'] = _processListData(data);
        result['count'] = data.length;
      }
      
      // Add processing metadata
      result['_metadata'] = {
        'processedAt': DateTime.now().toIso8601String(),
        'processingTimeMs': stopwatch.elapsedMilliseconds,
        'dataSize': jsonString.length,
      };
      
      stopwatch.stop();
      print("⚡ JSON processed in ${stopwatch.elapsedMilliseconds}ms");
      
      return result;
      
    } catch (e) {
      print("❌ Error in JSON isolate processing: $e");
      return {'error': e.toString()};
    }
  }

  /// OPTIMIZATION: Process map data efficiently
  static Map<String, dynamic> _processMapData(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    
    // OPTIMIZATION: Process different data types efficiently
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value is List) {
        result[key] = _processListData(value);
      } else if (value is Map<String, dynamic>) {
        result[key] = _processMapData(value);
      } else if (value is String && _isNumericString(value)) {
        // OPTIMIZATION: Convert numeric strings to numbers
        result[key] = double.tryParse(value) ?? value;
      } else {
        result[key] = value;
      }
    }
    
    return result;
  }

  /// OPTIMIZATION: Process list data with efficient algorithms
  static List<dynamic> _processListData(List<dynamic> data) {
    final result = <dynamic>[];
    
    for (final item in data) {
      if (item is Map<String, dynamic>) {
        result.add(_processMapData(item));
      } else if (item is List) {
        result.add(_processListData(item));
      } else {
        result.add(item);
      }
    }
    
    // OPTIMIZATION: Sort if needed for better performance
    if (result.isNotEmpty && result.first is Map) {
      try {
        result.sort((a, b) {
          if (a is Map && b is Map && a.containsKey('timestamp') && b.containsKey('timestamp')) {
            return (b['timestamp'] as num).compareTo(a['timestamp'] as num);
          }
          return 0;
        });
      } catch (e) {
        // Ignore sorting errors
      }
    }
    
    return result;
  }

  /// OPTIMIZATION: Check if string is numeric
  static bool _isNumericString(String str) {
    return double.tryParse(str) != null;
  }

  /// OPTIMIZATION: Create streaming data processor
  Stream<T> createDataStream<T>(
    String streamKey,
    Future<T> Function() dataFetcher,
    Duration interval,
  ) {
    // OPTIMIZATION: Reuse existing stream if available
    if (_dataStreams.containsKey(streamKey)) {
      return _dataStreams[streamKey]!.stream.cast<T>();
    }
    
    final controller = StreamController<T>.broadcast();
    _dataStreams[streamKey] = controller as StreamController<dynamic>;
    
    // OPTIMIZATION: Create timer for periodic data updates
    _streamTimers[streamKey] = Timer.periodic(interval, (timer) async {
      try {
        final data = await dataFetcher();
        if (!controller.isClosed) {
          controller.add(data);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    });
    
    // OPTIMIZATION: Clean up when stream is cancelled
    controller.onCancel = () {
      _streamTimers[streamKey]?.cancel();
      _streamTimers.remove(streamKey);
      _dataStreams.remove(streamKey);
    };
    
    print("📡 Created data stream: $streamKey");
    return controller.stream;
  }

  /// OPTIMIZATION: Process trading data with efficient algorithms
  Future<Map<String, dynamic>> processTradingDataOptimized(List<dynamic> rawData) async {
    try {
      print("📊 Processing trading data with optimizations...");
      
      // OPTIMIZATION: Use compute() for heavy calculations
      final result = await compute(_processTradingDataInIsolate, rawData);
      
      print("✅ Trading data processing completed");
      return result;
      
    } catch (e) {
      print("❌ Error processing trading data: $e");
      return {};
    }
  }

  /// OPTIMIZATION: Trading data processing in isolate
  static Map<String, dynamic> _processTradingDataInIsolate(List<dynamic> rawData) {
    try {
      final stopwatch = Stopwatch()..start();
      
      // OPTIMIZATION: Use efficient data structures
      final symbolMap = <String, List<Map<String, dynamic>>>{};
      final priceMap = <String, double>{};
      final volumeMap = <String, double>{};
      
      // OPTIMIZATION: Single pass processing
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          final symbol = item['symbol'] as String?;
          if (symbol != null) {
            // Group by symbol
            symbolMap.putIfAbsent(symbol, () => []).add(item);
            
            // Track latest price
            final price = double.tryParse(item['price']?.toString() ?? '0');
            if (price != null && price > 0) {
              priceMap[symbol] = price;
            }
            
            // Track volume
            final volume = double.tryParse(item['volume']?.toString() ?? '0');
            if (volume != null && volume > 0) {
              volumeMap[symbol] = (volumeMap[symbol] ?? 0) + volume;
            }
          }
        }
      }
      
      // OPTIMIZATION: Calculate statistics efficiently
      final statistics = _calculateTradingStatistics(symbolMap, priceMap, volumeMap);
      
      stopwatch.stop();
      
      return {
        'symbols': symbolMap.keys.toList(),
        'symbolData': symbolMap,
        'latestPrices': priceMap,
        'volumes': volumeMap,
        'statistics': statistics,
        'metadata': {
          'processedAt': DateTime.now().toIso8601String(),
          'processingTimeMs': stopwatch.elapsedMilliseconds,
          'totalItems': rawData.length,
          'uniqueSymbols': symbolMap.length,
        }
      };
      
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// OPTIMIZATION: Calculate trading statistics efficiently
  static Map<String, dynamic> _calculateTradingStatistics(
    Map<String, List<Map<String, dynamic>>> symbolMap,
    Map<String, double> priceMap,
    Map<String, double> volumeMap,
  ) {
    final statistics = <String, dynamic>{};
    
    // OPTIMIZATION: Parallel calculation of statistics
    final futures = <Future>[];
    
    for (final symbol in symbolMap.keys) {
      final symbolData = symbolMap[symbol]!;
      
      // Calculate price statistics
      final prices = symbolData
          .map((item) => double.tryParse(item['price']?.toString() ?? '0'))
          .where((price) => price != null && price! > 0)
          .cast<double>()
          .toList();
      
      if (prices.isNotEmpty) {
        prices.sort();
        
        statistics[symbol] = {
          'count': prices.length,
          'min': prices.first,
          'max': prices.last,
          'avg': prices.reduce((a, b) => a + b) / prices.length,
          'median': prices[prices.length ~/ 2],
          'volume': volumeMap[symbol] ?? 0,
          'priceChange': _calculatePriceChange(prices),
        };
      }
    }
    
    return statistics;
  }

  /// OPTIMIZATION: Calculate price change efficiently
  static double _calculatePriceChange(List<double> prices) {
    if (prices.length < 2) return 0.0;
    
    final first = prices.first;
    final last = prices.last;
    
    return ((last - first) / first) * 100;
  }

  /// OPTIMIZATION: Batch process multiple data sets
  Future<List<Map<String, dynamic>>> batchProcessData(List<String> jsonStrings) async {
    try {
      print("🔄 Batch processing ${jsonStrings.length} data sets...");
      
      // OPTIMIZATION: Process in parallel using compute()
      final futures = jsonStrings.map((jsonString) => 
        compute(_processJsonInIsolate, jsonString)
      ).toList();
      
      final results = await Future.wait(futures);
      
      print("✅ Batch processing completed");
      return results;
      
    } catch (e) {
      print("❌ Error in batch processing: $e");
      return [];
    }
  }

  /// OPTIMIZATION: Smart caching with automatic cleanup
  T? getCachedData<T>(String key) {
    final entry = _processedDataCache[key];
    if (entry != null && entry.isValid()) {
      return entry.data as T?;
    }
    
    // Remove expired entry
    _processedDataCache.remove(key);
    return null;
  }

  /// OPTIMIZATION: Generate cache key
  String _generateCacheKey(String data) {
    return data.hashCode.toString();
  }

  /// OPTIMIZATION: Clean cache if needed
  void _cleanCacheIfNeeded() {
    if (_processedDataCache.length > MAX_CACHE_SIZE) {
      // Remove oldest entries
      final entries = _processedDataCache.entries.toList();
      entries.sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));
      
      final toRemove = entries.take(_processedDataCache.length - MAX_CACHE_SIZE);
      for (final entry in toRemove) {
        _processedDataCache.remove(entry.key);
      }
      
      print("🧹 Cleaned cache: removed ${toRemove.length} entries");
    }
  }

  /// OPTIMIZATION: Process real-time price data
  Stream<Map<String, double>> createPriceStream(List<String> symbols) {
    return createDataStream<Map<String, double>>(
      'price_stream_${symbols.join('_')}',
      () => _fetchLatestPrices(symbols),
      Duration(seconds: 1),
    );
  }

  /// OPTIMIZATION: Fetch latest prices efficiently
  Future<Map<String, double>> _fetchLatestPrices(List<String> symbols) async {
    try {
      // OPTIMIZATION: Batch request for multiple symbols
      final response = await http.get(
        Uri.parse('https://api.binance.com/api/v3/ticker/price'),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final prices = <String, double>{};
        
        for (final item in data) {
          final symbol = item['symbol'] as String?;
          final price = double.tryParse(item['price']?.toString() ?? '0');
          
          if (symbol != null && price != null && symbols.contains(symbol)) {
            prices[symbol] = price;
          }
        }
        
        return prices;
      }
      
      return {};
      
    } catch (e) {
      print("❌ Error fetching prices: $e");
      return {};
    }
  }

  /// OPTIMIZATION: Dispose resources
  void dispose() {
    // Cancel all timers
    for (final timer in _streamTimers.values) {
      timer.cancel();
    }
    _streamTimers.clear();
    
    // Close all streams
    for (final controller in _dataStreams.values) {
      controller.close();
    }
    _dataStreams.clear();
    
    // Clear caches
    _dataCache.clear();
    _processedDataCache.clear();
    
    print("🧹 OptimizedDataProcessor disposed");
  }
}

/// OPTIMIZATION: Cache entry with TTL
class CacheEntry {
  final dynamic data;
  final DateTime timestamp;

  CacheEntry({
    required this.data,
    required this.timestamp,
  });

  bool isValid() {
    return DateTime.now().difference(timestamp).inSeconds < OptimizedDataProcessor.CACHE_TTL_SECONDS;
  }
}
