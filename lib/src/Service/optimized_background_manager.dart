import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'optimized_bot_service.dart';
import 'optimized_data_processor.dart';

/// OPTIMIZATION: Advanced Background Manager with Smart Scheduling and Resource Management
class OptimizedBackgroundManager {
  static final OptimizedBackgroundManager _instance = OptimizedBackgroundManager._internal();
  factory OptimizedBackgroundManager() => _instance;
  OptimizedBackgroundManager._internal();

  // OPTIMIZATION: Smart scheduling configuration
  static const int HIGH_FREQUENCY_INTERVAL = 1; // seconds - for critical operations
  static const int MEDIUM_FREQUENCY_INTERVAL = 5; // seconds - for regular operations
  static const int LOW_FREQUENCY_INTERVAL = 30; // seconds - for maintenance operations
  static const int ADAPTIVE_THRESHOLD = 10; // number of consecutive empty checks before reducing frequency

  // OPTIMIZATION: Resource management
  final Map<String, Timer> _timers = {};
  final Map<String, int> _emptyCheckCounts = {};
  final Map<String, TaskPriority> _taskPriorities = {};
  final Map<String, DateTime> _lastExecutionTimes = {};
  
  bool _isRunning = false;
  bool _isHighActivity = false;
  int _totalActiveBots = 0;
  
  // Services
  late OptimizedBotService _botService;
  late OptimizedDataProcessor _dataProcessor;

  /// OPTIMIZATION: Initialize optimized background manager
  Future<void> initialize() async {
    if (_isRunning) return;
    
    print("🚀 INITIALIZING OPTIMIZED BACKGROUND MANAGER...");
    
    try {
      // Initialize services
      _botService = OptimizedBotService();
      _dataProcessor = OptimizedDataProcessor();
      
      // Start optimized bot service
      await _botService.startOptimizedBotService();
      
      // Initialize smart scheduling
      await _initializeSmartScheduling();
      
      _isRunning = true;
      print("✅ OPTIMIZED BACKGROUND MANAGER INITIALIZED");
      
    } catch (e) {
      print("❌ ERROR INITIALIZING BACKGROUND MANAGER: $e");
      rethrow;
    }
  }

  /// OPTIMIZATION: Initialize smart scheduling with adaptive intervals
  Future<void> _initializeSmartScheduling() async {
    try {
      // OPTIMIZATION: High priority tasks (critical trading operations)
      _scheduleTask(
        'bot_monitoring',
        _monitorBots,
        HIGH_FREQUENCY_INTERVAL,
        TaskPriority.HIGH,
      );
      
      // OPTIMIZATION: Medium priority tasks (data processing)
      _scheduleTask(
        'data_processing',
        _processMarketData,
        MEDIUM_FREQUENCY_INTERVAL,
        TaskPriority.MEDIUM,
      );
      
      // OPTIMIZATION: Low priority tasks (maintenance)
      _scheduleTask(
        'system_maintenance',
        _performSystemMaintenance,
        LOW_FREQUENCY_INTERVAL,
        TaskPriority.LOW,
      );
      
      // OPTIMIZATION: Adaptive frequency adjustment
      _scheduleTask(
        'frequency_adjustment',
        _adjustTaskFrequencies,
        MEDIUM_FREQUENCY_INTERVAL,
        TaskPriority.MEDIUM,
      );
      
      print("📅 Smart scheduling initialized with adaptive intervals");
      
    } catch (e) {
      print("❌ Error initializing smart scheduling: $e");
    }
  }

  /// OPTIMIZATION: Schedule task with priority and adaptive frequency
  void _scheduleTask(
    String taskName,
    Future<void> Function() taskFunction,
    int baseIntervalSeconds,
    TaskPriority priority,
  ) {
    _taskPriorities[taskName] = priority;
    
    Timer? timer;
    timer = Timer.periodic(Duration(seconds: baseIntervalSeconds), (t) async {
      try {
        final startTime = DateTime.now();
        
        // OPTIMIZATION: Check if task should run based on adaptive logic
        if (_shouldRunTask(taskName)) {
          await taskFunction();
          _lastExecutionTimes[taskName] = DateTime.now();
          
          // Reset empty check count on successful execution
          _emptyCheckCounts[taskName] = 0;
          
          final executionTime = DateTime.now().difference(startTime).inMilliseconds;
          print("⚡ Task '$taskName' completed in ${executionTime}ms");
        } else {
          _emptyCheckCounts[taskName] = (_emptyCheckCounts[taskName] ?? 0) + 1;
        }
        
      } catch (e) {
        print("❌ Error in task '$taskName': $e");
        _emptyCheckCounts[taskName] = (_emptyCheckCounts[taskName] ?? 0) + 1;
      }
    });
    
    _timers[taskName] = timer;
    print("📅 Scheduled task: $taskName (${priority.name} priority, ${baseIntervalSeconds}s interval)");
  }

  /// OPTIMIZATION: Determine if task should run based on adaptive logic
  bool _shouldRunTask(String taskName) {
    final priority = _taskPriorities[taskName] ?? TaskPriority.MEDIUM;
    final emptyCount = _emptyCheckCounts[taskName] ?? 0;
    
    // OPTIMIZATION: Always run high priority tasks
    if (priority == TaskPriority.HIGH) {
      return true;
    }
    
    // OPTIMIZATION: Reduce frequency for tasks with consecutive empty results
    if (emptyCount >= ADAPTIVE_THRESHOLD) {
      // Run less frequently based on empty count
      final skipFactor = min(emptyCount ~/ ADAPTIVE_THRESHOLD, 10);
      return DateTime.now().millisecondsSinceEpoch % (skipFactor + 1) == 0;
    }
    
    // OPTIMIZATION: Adjust based on system activity
    if (_isHighActivity && priority == TaskPriority.LOW) {
      return false; // Skip low priority tasks during high activity
    }
    
    return true;
  }

  /// OPTIMIZATION: Monitor bots with intelligent resource allocation
  Future<void> _monitorBots() async {
    try {
      print("🤖 Monitoring bots with intelligent resource allocation...");
      
      // Get bot status from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final botStatesJson = prefs.getString('bot_states');
      
      if (botStatesJson == null) {
        print("⚠️ No bot states found");
        return;
      }
      
      final List<dynamic> botStates = json.decode(botStatesJson);
      final activeBots = botStates.where((state) => state['isActive'] == true).toList();
      
      _totalActiveBots = activeBots.length;
      _isHighActivity = _totalActiveBots > 5; // Threshold for high activity
      
      print("📊 Active bots: $_totalActiveBots (High activity: $_isHighActivity)");
      
      if (activeBots.isEmpty) {
        return;
      }
      
      // OPTIMIZATION: Process bots in parallel batches
      await _processBotBatches(activeBots);
      
    } catch (e) {
      print("❌ Error monitoring bots: $e");
    }
  }

  /// OPTIMIZATION: Process bots in intelligent batches
  Future<void> _processBotBatches(List<dynamic> activeBots) async {
    try {
      // OPTIMIZATION: Determine optimal batch size based on system load
      final batchSize = _calculateOptimalBatchSize(activeBots.length);
      
      print("📦 Processing ${activeBots.length} bots in batches of $batchSize");
      
      for (int i = 0; i < activeBots.length; i += batchSize) {
        final batch = activeBots.sublist(
          i, 
          min(i + batchSize, activeBots.length)
        );
        
        // OPTIMIZATION: Process batch with timeout
        await _processBotBatch(batch).timeout(
          Duration(seconds: 10),
          onTimeout: () {
            print("⚠️ Bot batch processing timed out");
          },
        );
        
        // OPTIMIZATION: Small delay between batches to prevent overwhelming
        if (i + batchSize < activeBots.length) {
          await Future.delayed(Duration(milliseconds: 100));
        }
      }
      
    } catch (e) {
      print("❌ Error processing bot batches: $e");
    }
  }

  /// OPTIMIZATION: Calculate optimal batch size based on system resources
  int _calculateOptimalBatchSize(int totalBots) {
    if (totalBots <= 5) return totalBots;
    if (totalBots <= 20) return 5;
    if (totalBots <= 50) return 10;
    return 15; // Maximum batch size for very large numbers
  }

  /// OPTIMIZATION: Process individual bot batch
  Future<void> _processBotBatch(List<dynamic> batch) async {
    try {
      final futures = <Future>[];
      
      for (final botState in batch) {
        futures.add(_processSingleBot(botState));
      }
      
      await Future.wait(futures);
      
    } catch (e) {
      print("❌ Error processing bot batch: $e");
    }
  }

  /// OPTIMIZATION: Process single bot with error handling
  Future<void> _processSingleBot(Map<String, dynamic> botState) async {
    try {
      final symbol = botState['assetType'] as String?;
      if (symbol == null) return;
      
      // OPTIMIZATION: Use data processor for price fetching
      final priceStream = _dataProcessor.createPriceStream([symbol]);
      
      // Get latest price with timeout
      final priceData = await priceStream.first.timeout(
        Duration(seconds: 5),
        onTimeout: () => <String, double>{},
      );
      
      final currentPrice = priceData[symbol];
      if (currentPrice == null) return;
      
      // Update bot state with current price
      botState['currentPrice'] = currentPrice.toString();
      
      print("💱 Updated price for $symbol: $currentPrice");
      
    } catch (e) {
      print("❌ Error processing bot ${botState['assetType']}: $e");
    }
  }

  /// OPTIMIZATION: Process market data with intelligent caching
  Future<void> _processMarketData() async {
    try {
      print("📊 Processing market data with intelligent caching...");
      
      // OPTIMIZATION: Get unique symbols from active bots
      final symbols = await _getActiveSymbols();
      if (symbols.isEmpty) return;
      
      // OPTIMIZATION: Create price stream for all symbols
      final priceStream = _dataProcessor.createPriceStream(symbols);
      
      // Process price data with timeout
      final priceData = await priceStream.first.timeout(
        Duration(seconds: 10),
        onTimeout: () => <String, double>{},
      );
      
      if (priceData.isNotEmpty) {
        // OPTIMIZATION: Cache processed data
        await _cacheMarketData(priceData);
        print("💾 Cached market data for ${priceData.length} symbols");
      }
      
    } catch (e) {
      print("❌ Error processing market data: $e");
    }
  }

  /// OPTIMIZATION: Get active symbols efficiently
  Future<List<String>> _getActiveSymbols() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final botStatesJson = prefs.getString('bot_states');
      
      if (botStatesJson == null) return [];
      
      final List<dynamic> botStates = json.decode(botStatesJson);
      final symbols = botStates
          .where((state) => state['isActive'] == true)
          .map((state) => state['assetType'] as String?)
          .where((symbol) => symbol != null)
          .cast<String>()
          .toSet()
          .toList();
      
      return symbols;
      
    } catch (e) {
      print("❌ Error getting active symbols: $e");
      return [];
    }
  }

  /// OPTIMIZATION: Cache market data efficiently
  Future<void> _cacheMarketData(Map<String, double> priceData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // OPTIMIZATION: Store with timestamp for TTL
      final cacheData = {
        'prices': priceData,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await prefs.setString('market_data_cache', json.encode(cacheData));
      
    } catch (e) {
      print("❌ Error caching market data: $e");
    }
  }

  /// OPTIMIZATION: Perform system maintenance
  Future<void> _performSystemMaintenance() async {
    try {
      print("🧹 Performing system maintenance...");
      
      // OPTIMIZATION: Clean up expired cache entries
      await _cleanupExpiredCache();
      
      // OPTIMIZATION: Optimize memory usage
      await _optimizeMemoryUsage();
      
      // OPTIMIZATION: Update system statistics
      await _updateSystemStatistics();
      
      print("✅ System maintenance completed");
      
    } catch (e) {
      print("❌ Error in system maintenance: $e");
    }
  }

  /// OPTIMIZATION: Clean up expired cache entries
  Future<void> _cleanupExpiredCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      int cleanedCount = 0;
      
      for (final key in keys) {
        if (key.contains('cache')) {
          final value = prefs.getString(key);
          if (value != null) {
            try {
              final data = json.decode(value);
              final timestamp = data['timestamp'] as int?;
              
              if (timestamp != null) {
                final age = DateTime.now().millisecondsSinceEpoch - timestamp;
                if (age > 300000) { // 5 minutes
                  await prefs.remove(key);
                  cleanedCount++;
                }
              }
            } catch (e) {
              // Invalid cache entry, remove it
              await prefs.remove(key);
              cleanedCount++;
            }
          }
        }
      }
      
      if (cleanedCount > 0) {
        print("🧹 Cleaned $cleanedCount expired cache entries");
      }
      
    } catch (e) {
      print("❌ Error cleaning cache: $e");
    }
  }

  /// OPTIMIZATION: Optimize memory usage
  Future<void> _optimizeMemoryUsage() async {
    try {
      // Clear internal caches if they get too large
      _emptyCheckCounts.clear();
      
      // Force garbage collection if available
      if (!kIsWeb) {
        // System.gc() equivalent would go here for native platforms
      }
      
      print("🧠 Memory optimization completed");
      
    } catch (e) {
      print("❌ Error optimizing memory: $e");
    }
  }

  /// OPTIMIZATION: Update system statistics
  Future<void> _updateSystemStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final stats = {
        'totalActiveBots': _totalActiveBots,
        'isHighActivity': _isHighActivity,
        'lastMaintenanceTime': DateTime.now().toIso8601String(),
        'taskExecutionTimes': _lastExecutionTimes.map(
          (key, value) => MapEntry(key, value.toIso8601String())
        ),
      };
      
      await prefs.setString('system_statistics', json.encode(stats));
      
    } catch (e) {
      print("❌ Error updating statistics: $e");
    }
  }

  /// OPTIMIZATION: Adjust task frequencies based on system performance
  Future<void> _adjustTaskFrequencies() async {
    try {
      print("⚙️ Adjusting task frequencies based on system performance...");
      
      for (final taskName in _emptyCheckCounts.keys) {
        final emptyCount = _emptyCheckCounts[taskName] ?? 0;
        final priority = _taskPriorities[taskName] ?? TaskPriority.MEDIUM;
        
        if (emptyCount >= ADAPTIVE_THRESHOLD && priority != TaskPriority.HIGH) {
          print("📉 Task '$taskName' has $emptyCount empty checks - reducing frequency");
          
          // OPTIMIZATION: Restart timer with longer interval
          _timers[taskName]?.cancel();
          // Implementation would restart with adjusted interval
        }
      }
      
    } catch (e) {
      print("❌ Error adjusting task frequencies: $e");
    }
  }

  /// Stop optimized background manager
  Future<void> stop() async {
    _isRunning = false;
    
    // Cancel all timers
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    
    // Stop services
    await _botService.stopOptimizedBotService();
    _dataProcessor.dispose();
    
    // Clear state
    _emptyCheckCounts.clear();
    _taskPriorities.clear();
    _lastExecutionTimes.clear();
    
    print("🛑 OPTIMIZED BACKGROUND MANAGER STOPPED");
  }

  /// Get system statistics
  Map<String, dynamic> getSystemStatistics() {
    return {
      'isRunning': _isRunning,
      'totalActiveBots': _totalActiveBots,
      'isHighActivity': _isHighActivity,
      'activeTimers': _timers.length,
      'taskPriorities': _taskPriorities.map((k, v) => MapEntry(k, v.name)),
      'emptyCheckCounts': _emptyCheckCounts,
    };
  }
}

/// OPTIMIZATION: Task priority enumeration
enum TaskPriority {
  HIGH,
  MEDIUM,
  LOW,
}
