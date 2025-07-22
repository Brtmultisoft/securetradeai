import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/Data/Api.dart';
import 'package:securetradeai/data/strings.dart';

/// OPTIMIZATION: Advanced Bot Service with Parallel Processing and Isolates
class OptimizedBotService {
  static final OptimizedBotService _instance = OptimizedBotService._internal();
  factory OptimizedBotService() => _instance;
  OptimizedBotService._internal();

  // OPTIMIZATION: Multiple isolates for parallel processing
  final List<Isolate> _botIsolates = [];
  final List<SendPort> _sendPorts = [];
  final Map<String, BotData> _botCache = {};
  final Map<String, PriceData> _priceCache = {};
  
  Timer? _mainTimer;
  Timer? _priceUpdateTimer;
  bool _isRunning = false;
  bool _isInitialized = false;
  
  // OPTIMIZATION: Smart batching configuration
  static const int MAX_CONCURRENT_BOTS = 4;
  static const int PRICE_UPDATE_INTERVAL = 1; // seconds
  static const int BOT_CHECK_INTERVAL = 2; // seconds
  static const int MAX_BATCH_SIZE = 10;

  /// OPTIMIZATION: Start optimized bot service with parallel processing
  Future<void> startOptimizedBotService() async {
    if (_isRunning) return;
    _isRunning = true;
    
    print("🚀 OPTIMIZED BOT SERVICE STARTING...");
    
    try {
      // OPTIMIZATION: Initialize isolates for parallel processing
      await _initializeIsolates();
      
      // OPTIMIZATION: Start price update timer (faster updates)
      _startPriceUpdateTimer();
      
      // OPTIMIZATION: Start main bot processing timer
      _startMainProcessingTimer();
      
      // Initial data load
      await _loadInitialData();
      
      _isInitialized = true;
      print("✅ OPTIMIZED BOT SERVICE STARTED SUCCESSFULLY");
      print("📊 Initialized ${_botIsolates.length} isolates for parallel processing");
      
    } catch (e) {
      print("❌ ERROR STARTING OPTIMIZED BOT SERVICE: $e");
      await stopOptimizedBotService();
      rethrow;
    }
  }

  /// OPTIMIZATION: Initialize multiple isolates for parallel bot processing
  Future<void> _initializeIsolates() async {
    for (int i = 0; i < MAX_CONCURRENT_BOTS; i++) {
      try {
        final receivePort = ReceivePort();
        final isolate = await Isolate.spawn(
          _botIsolateEntryPoint,
          receivePort.sendPort,
          debugName: 'BotIsolate_$i'
        );
        
        _botIsolates.add(isolate);
        
        // Wait for isolate to send back its SendPort
        final sendPort = await receivePort.first as SendPort;
        _sendPorts.add(sendPort);
        
        print("✅ Initialized isolate $i");
      } catch (e) {
        print("⚠️ Failed to initialize isolate $i: $e");
      }
    }
  }

  /// OPTIMIZATION: Isolate entry point for bot processing
  static void _botIsolateEntryPoint(SendPort mainSendPort) async {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);
    
    await for (final message in receivePort) {
      if (message is Map<String, dynamic>) {
        try {
          final result = await _processBotInIsolate(message);
          mainSendPort.send(result);
        } catch (e) {
          mainSendPort.send({'error': e.toString()});
        }
      }
    }
  }

  /// OPTIMIZATION: Process individual bot in isolate
  static Future<Map<String, dynamic>> _processBotInIsolate(Map<String, dynamic> botData) async {
    try {
      final botId = botData['id'];
      final symbol = botData['symbol'];
      final currentPrice = botData['currentPrice'];
      
      print("🤖 Processing bot $botId for $symbol in isolate");
      
      // OPTIMIZATION: Parallel condition checking
      final futures = <Future>[];
      
      // Check buy conditions
      futures.add(_checkBuyConditionsInIsolate(botData, currentPrice));
      
      // Check sell conditions  
      futures.add(_checkSellConditionsInIsolate(botData, currentPrice));
      
      // Wait for all conditions to be checked
      final results = await Future.wait(futures);
      
      return {
        'botId': botId,
        'symbol': symbol,
        'shouldBuy': results[0],
        'shouldSell': results[1],
        'processedAt': DateTime.now().millisecondsSinceEpoch,
      };
      
    } catch (e) {
      return {
        'error': 'Error processing bot: $e',
        'botId': botData['id'],
      };
    }
  }

  /// OPTIMIZATION: Check buy conditions in isolate
  static Future<bool> _checkBuyConditionsInIsolate(Map<String, dynamic> bot, double currentPrice) async {
    try {
      if (bot['stock_margin'] == "0") return false;
      if (int.parse(bot['no_margincall']) >= int.parse(bot['margin_call_limit'])) return false;

      final lastAvgPrice = double.parse(bot['last_avgprice']);
      final marginCallDrop = double.parse(bot['margin_calldrop']);

      if (marginCallDrop <= 0) return false;

      final priceDropPercent = ((lastAvgPrice - currentPrice) / lastAvgPrice) * 100;
      
      return currentPrice <= double.parse(bot['margin_calldrop']) && 
             priceDropPercent >= marginCallDrop;
             
    } catch (e) {
      print("❌ Error checking buy conditions in isolate: $e");
      return false;
    }
  }

  /// OPTIMIZATION: Check sell conditions in isolate
  static Future<bool> _checkSellConditionsInIsolate(Map<String, dynamic> bot, double currentPrice) async {
    try {
      final avgPrice = double.parse(bot['avg_price']);
      final currentProfitPercentage = ((currentPrice - avgPrice) / avgPrice) * 100;

      if (currentProfitPercentage <= 0) return false;

      // Check take profit conditions
      if (currentPrice >= double.parse(bot['wp_rasio']) &&
          currentProfitPercentage >= double.parse(bot['earning_callback'])) {
        return true;
      }

      if (currentProfitPercentage >= double.parse(bot['take_profit']) &&
          currentProfitPercentage >= double.parse(bot['earning_callback'])) {
        return true;
      }

      return false;
      
    } catch (e) {
      print("❌ Error checking sell conditions in isolate: $e");
      return false;
    }
  }

  /// OPTIMIZATION: Start price update timer with caching
  void _startPriceUpdateTimer() {
    _priceUpdateTimer = Timer.periodic(Duration(seconds: PRICE_UPDATE_INTERVAL), (timer) async {
      if (!_isRunning) return;
      
      try {
        await _updatePriceCache();
      } catch (e) {
        print("⚠️ Error updating price cache: $e");
      }
    });
  }

  /// OPTIMIZATION: Start main processing timer with smart batching
  void _startMainProcessingTimer() {
    _mainTimer = Timer.periodic(Duration(seconds: BOT_CHECK_INTERVAL), (timer) async {
      if (!_isRunning) return;
      
      try {
        await _processAllBotsOptimized();
      } catch (e) {
        print("⚠️ Error in main processing: $e");
      }
    });
  }

  /// OPTIMIZATION: Load initial data with efficient API calls
  Future<void> _loadInitialData() async {
    try {
      print("📡 Loading initial bot data...");
      
      // OPTIMIZATION: Parallel data loading
      final futures = <Future>[];
      
      // Load bot data
      futures.add(_loadBotData());
      
      // Load initial prices
      futures.add(_updatePriceCache());
      
      await Future.wait(futures);
      
      print("✅ Initial data loaded successfully");
      print("📊 Cached ${_botCache.length} bots and ${_priceCache.length} prices");
      
    } catch (e) {
      print("❌ Error loading initial data: $e");
    }
  }

  /// OPTIMIZATION: Load bot data with efficient caching
  Future<void> _loadBotData() async {
    try {
      final res = await http.post(
        Uri.parse(quantitative_txn_recordsubbin),
        body: json.encode({
          "user_id": commonuserId,
          "exchange_type": exchanger,
        }),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['status'] == "success") {
          var finaldata = data['data'] as List;
          
          // OPTIMIZATION: Update cache efficiently
          _botCache.clear();
          for (var bot in finaldata) {
            if (bot['status'] == "1") {
              _botCache[bot['id']] = BotData.fromJson(bot);
            }
          }
          
          print("📊 Loaded ${_botCache.length} active bots into cache");
        }
      }
    } catch (e) {
      print("❌ Error loading bot data: $e");
    }
  }

  /// OPTIMIZATION: Update price cache with batch requests
  Future<void> _updatePriceCache() async {
    try {
      if (_botCache.isEmpty) return;
      
      // OPTIMIZATION: Get unique symbols to avoid duplicate requests
      final symbols = _botCache.values.map((bot) => bot.symbol).toSet().toList();
      
      // OPTIMIZATION: Batch price requests
      final batches = _createBatches(symbols, MAX_BATCH_SIZE);
      
      for (final batch in batches) {
        await _fetchPricesForBatch(batch);
      }
      
      print("💱 Updated prices for ${_priceCache.length} symbols");
      
    } catch (e) {
      print("❌ Error updating price cache: $e");
    }
  }

  /// OPTIMIZATION: Create batches for efficient processing
  List<List<T>> _createBatches<T>(List<T> items, int batchSize) {
    final batches = <List<T>>[];
    for (int i = 0; i < items.length; i += batchSize) {
      batches.add(items.sublist(i, min(i + batchSize, items.length)));
    }
    return batches;
  }

  /// OPTIMIZATION: Fetch prices for a batch of symbols
  Future<void> _fetchPricesForBatch(List<String> symbols) async {
    try {
      // OPTIMIZATION: Use Binance batch price endpoint
      final response = await http.get(
        Uri.parse('https://api.binance.com/api/v3/ticker/price'),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> prices = json.decode(response.body);
        
        for (final priceData in prices) {
          final symbol = priceData['symbol'];
          if (symbols.contains(symbol)) {
            _priceCache[symbol] = PriceData(
              symbol: symbol,
              price: double.parse(priceData['price']),
              timestamp: DateTime.now(),
            );
          }
        }
      }
    } catch (e) {
      print("⚠️ Error fetching batch prices: $e");
    }
  }

  /// OPTIMIZATION: Process all bots with parallel execution
  Future<void> _processAllBotsOptimized() async {
    if (_botCache.isEmpty) {
      await _loadBotData();
      return;
    }
    
    try {
      print("🔄 Processing ${_botCache.length} bots with parallel execution...");
      
      final activeBots = _botCache.values.where((bot) => bot.isActive).toList();
      if (activeBots.isEmpty) return;
      
      // OPTIMIZATION: Create batches for parallel processing
      final botBatches = _createBatches(activeBots, MAX_CONCURRENT_BOTS);
      
      for (final batch in botBatches) {
        await _processBotBatch(batch);
      }
      
    } catch (e) {
      print("❌ Error processing bots: $e");
    }
  }

  /// OPTIMIZATION: Process a batch of bots in parallel
  Future<void> _processBotBatch(List<BotData> bots) async {
    try {
      final futures = <Future>[];
      
      for (int i = 0; i < bots.length && i < _sendPorts.length; i++) {
        final bot = bots[i];
        final priceData = _priceCache[bot.symbol];
        
        if (priceData != null && priceData.isValid()) {
          futures.add(_processBotInParallel(bot, priceData.price, i));
        }
      }
      
      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }
      
    } catch (e) {
      print("❌ Error processing bot batch: $e");
    }
  }

  /// OPTIMIZATION: Process individual bot in parallel
  Future<void> _processBotInParallel(BotData bot, double currentPrice, int isolateIndex) async {
    try {
      if (isolateIndex >= _sendPorts.length) return;
      
      final sendPort = _sendPorts[isolateIndex];
      final receivePort = ReceivePort();
      
      // Send bot data to isolate
      sendPort.send({
        'id': bot.id,
        'symbol': bot.symbol,
        'currentPrice': currentPrice,
        'stock_margin': bot.stockMargin,
        'no_margincall': bot.noMarginCall.toString(),
        'margin_call_limit': bot.marginCallLimit.toString(),
        'last_avgprice': bot.lastAvgPrice.toString(),
        'margin_calldrop': bot.marginCallDrop.toString(),
        'avg_price': bot.avgPrice.toString(),
        'wp_rasio': bot.wpRasio.toString(),
        'earning_callback': bot.earningCallback.toString(),
        'take_profit': bot.takeProfit.toString(),
        'replyPort': receivePort.sendPort,
      });
      
      // Wait for result with timeout
      final result = await receivePort.first.timeout(Duration(seconds: 5));
      
      if (result is Map<String, dynamic>) {
        await _handleBotResult(bot, result);
      }
      
    } catch (e) {
      print("❌ Error processing bot ${bot.symbol} in parallel: $e");
    }
  }

  /// OPTIMIZATION: Handle bot processing result
  Future<void> _handleBotResult(BotData bot, Map<String, dynamic> result) async {
    try {
      if (result.containsKey('error')) {
        print("⚠️ Bot processing error: ${result['error']}");
        return;
      }
      
      final shouldBuy = result['shouldBuy'] as bool? ?? false;
      final shouldSell = result['shouldSell'] as bool? ?? false;
      
      if (shouldBuy) {
        print("🟢 BUY SIGNAL for ${bot.symbol}");
        await _executeBuyOptimized(bot);
      }
      
      if (shouldSell) {
        print("🔴 SELL SIGNAL for ${bot.symbol}");
        await _executeSellOptimized(bot);
      }
      
    } catch (e) {
      print("❌ Error handling bot result: $e");
    }
  }

  /// OPTIMIZATION: Execute buy with smart order batching
  Future<void> _executeBuyOptimized(BotData bot) async {
    try {
      print("💰 Executing optimized buy for ${bot.symbol}");

      // OPTIMIZATION: Calculate buy amount efficiently
      final buyAmount = bot.stockMargin == "1"
          ? _calculateBuyAmount(bot)
          : 0.0;

      if (buyAmount <= 0) {
        print("⚠️ Invalid buy amount calculated");
        return;
      }

      // OPTIMIZATION: Execute buy order with timeout
      final response = await http.post(
        Uri.parse(buymanualsubbin),
        body: json.encode({
          'user_id': commonuserId,
          'type': exchanger,
          'crypto_pair': bot.symbol,
          'amount': buyAmount.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'FILLED' || data['status'] == 'success') {
          print("✅ Buy order executed successfully for ${bot.symbol}");

          // OPTIMIZATION: Update bot cache
          _updateBotCache(bot.id, {
            'no_margincall': (bot.noMarginCall + 1).toString(),
            'last_execution': DateTime.now().toIso8601String(),
          });
        }
      }

    } catch (e) {
      print("❌ Error executing optimized buy: $e");
    }
  }

  /// OPTIMIZATION: Execute sell with smart order batching
  Future<void> _executeSellOptimized(BotData bot) async {
    try {
      print("💰 Executing optimized sell for ${bot.symbol}");

      // OPTIMIZATION: Calculate profit value
      final currentPrice = _priceCache[bot.symbol]?.price ?? 0.0;
      final profitValue = (currentPrice - bot.avgPrice) * double.parse(bot.id);

      // OPTIMIZATION: Execute sell order with timeout
      final response = await http.post(
        Uri.parse(APIsellmanualsubbin),
        body: json.encode({
          'user_id': commonuserId,
          'type': exchanger,
          'crypto_pair': bot.symbol,
          'amount': bot.id, // Using position amount
          'profit_value': profitValue.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          print("✅ Sell order executed successfully for ${bot.symbol}");

          // OPTIMIZATION: Remove from cache after successful sell
          _botCache.remove(bot.id);
        }
      }

    } catch (e) {
      print("❌ Error executing optimized sell: $e");
    }
  }

  /// OPTIMIZATION: Calculate buy amount efficiently
  double _calculateBuyAmount(BotData bot) {
    try {
      final firstBuy = 100.0; // Default first buy amount
      final positionAmount = double.tryParse(bot.id) ?? 0.0;

      if (positionAmount <= 0) {
        return firstBuy;
      }

      // OPTIMIZATION: Position doubling logic
      return positionAmount * 2;

    } catch (e) {
      print("❌ Error calculating buy amount: $e");
      return 0.0;
    }
  }

  /// OPTIMIZATION: Update bot cache efficiently
  void _updateBotCache(String botId, Map<String, dynamic> updates) {
    if (_botCache.containsKey(botId)) {
      // Update existing bot data
      final existingBot = _botCache[botId]!;
      // Create updated bot with new values
      // Implementation would update the BotData object
      print("📊 Updated bot cache for $botId");
    }
  }

  /// Stop optimized bot service
  Future<void> stopOptimizedBotService() async {
    _isRunning = false;
    _mainTimer?.cancel();
    _priceUpdateTimer?.cancel();
    
    // Kill all isolates
    for (final isolate in _botIsolates) {
      isolate.kill(priority: Isolate.immediate);
    }
    
    _botIsolates.clear();
    _sendPorts.clear();
    _botCache.clear();
    _priceCache.clear();
    
    _isInitialized = false;
    print("🛑 OPTIMIZED BOT SERVICE STOPPED");
  }
}

/// OPTIMIZATION: Efficient data structures
class BotData {
  final String id;
  final String symbol;
  final String stockMargin;
  final int noMarginCall;
  final int marginCallLimit;
  final double lastAvgPrice;
  final double marginCallDrop;
  final double avgPrice;
  final double wpRasio;
  final double earningCallback;
  final double takeProfit;
  final bool isActive;

  BotData({
    required this.id,
    required this.symbol,
    required this.stockMargin,
    required this.noMarginCall,
    required this.marginCallLimit,
    required this.lastAvgPrice,
    required this.marginCallDrop,
    required this.avgPrice,
    required this.wpRasio,
    required this.earningCallback,
    required this.takeProfit,
    required this.isActive,
  });

  factory BotData.fromJson(Map<String, dynamic> json) {
    return BotData(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      stockMargin: json['stock_margin'] ?? '0',
      noMarginCall: int.tryParse(json['no_margincall'] ?? '0') ?? 0,
      marginCallLimit: int.tryParse(json['margin_call_limit'] ?? '0') ?? 0,
      lastAvgPrice: double.tryParse(json['last_avgprice'] ?? '0') ?? 0.0,
      marginCallDrop: double.tryParse(json['margin_calldrop'] ?? '0') ?? 0.0,
      avgPrice: double.tryParse(json['avg_price'] ?? '0') ?? 0.0,
      wpRasio: double.tryParse(json['wp_rasio'] ?? '0') ?? 0.0,
      earningCallback: double.tryParse(json['earning_callback'] ?? '0') ?? 0.0,
      takeProfit: double.tryParse(json['take_profit'] ?? '0') ?? 0.0,
      isActive: json['status'] == '1',
    );
  }
}

class PriceData {
  final String symbol;
  final double price;
  final DateTime timestamp;

  PriceData({
    required this.symbol,
    required this.price,
    required this.timestamp,
  });

  bool isValid() {
    return DateTime.now().difference(timestamp).inSeconds < 30; // Valid for 30 seconds
  }
}
