import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'package:rapidtradeai/data/strings.dart';
import 'notification_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:rapidtradeai/data/api.dart';

// OPTIMIZATION: Import optimized background processing
import 'optimized_background_manager.dart';
import 'optimized_data_processor.dart';
import 'optimized_bot_service.dart';

// This is the name of our background task
const String backgroundTaskName = "com.rapidtradeai.bot.backgroundTask";

// OPTIMIZATION: Global optimized background manager instance
OptimizedBackgroundManager? _optimizedManager;

// OPTIMIZATION: Initialize optimized background service
Future<void> initializeOptimizedBackgroundService() async {
  try {
    print('🚀 INITIALIZING OPTIMIZED BACKGROUND SERVICE...');

    // Initialize optimized background manager
    _optimizedManager = OptimizedBackgroundManager();
    await _optimizedManager!.initialize();

    print('✅ OPTIMIZED BACKGROUND SERVICE INITIALIZED SUCCESSFULLY');

  } catch (e) {
    print('❌ ERROR INITIALIZING OPTIMIZED BACKGROUND SERVICE: $e');
    // Fallback to regular background service
    await initializeBackgroundService();
  }
}

// Initialize the background service
Future<void> initializeBackgroundService() async {
  try {
    print('🔵 INITIALIZING BACKGROUND SERVICE...');
    
    // For web platform, use the fallback mechanism directly
    if (kIsWeb) {
      print('🌐 Web platform detected - Using fallback background mechanism');
      _initializeFallbackBackgroundService();
      return;
    }
    
    // Ensure plugins are initialized
    WidgetsFlutterBinding.ensureInitialized();
    
    // Start fallback service first as a safety net
    _initializeFallbackBackgroundService();
    print('✅ Fallback service started as backup');
    
    // For mobile platforms, try to use Workmanager but don't wait for it
    try {
      await Future.any([
        Workmanager().initialize(
          callbackDispatcher,
          isInDebugMode: true,
        ).timeout(Duration(seconds: 5)),
        Future.delayed(Duration(seconds: 5))
      ]);
      print('✅ WORKMANAGER INITIALIZED');
      
      // Register the task but don't wait for it
      _registerWorkmanagerTask();
    } catch (e) {
      print('⚠️ WORKMANAGER INITIALIZATION FAILED: $e');
      print('ℹ️ Continuing with fallback service only');
    }
    
  } catch (e) {
    print('❌ ERROR IN BACKGROUND SERVICE INITIALIZATION: $e');
    print('ℹ️ Ensuring fallback service is running');
    _initializeFallbackBackgroundService();
  }
}

// Separate function to register Workmanager task
Future<void> _registerWorkmanagerTask() async {
  try {
    await Workmanager().registerPeriodicTask(
      'bot_trading_task',
      'botTradingTask',
      frequency: Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      backoffPolicy: BackoffPolicy.exponential,
    );
    print('✅ WORKMANAGER TASK REGISTERED');
  } catch (e) {
    print('⚠️ FAILED TO REGISTER WORKMANAGER TASK: $e');
  }
}

// Add this new method to sync bot states
Future<void> syncBotStates(String userId, String assetType, bool isActive, Map<String, dynamic> botData) async {
  try {
    print('🔄 SYNCING BOT STATES...');
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing states
    final existingStatesJson = prefs.getString('bot_states') ?? '[]';
    List<dynamic> existingStates = json.decode(existingStatesJson);
    
    // Find if this bot already exists
    final index = existingStates.indexWhere((state) => 
      state['userId'] == userId && 
      state['assetType'] == assetType
    );
    
    // Create new bot state
    final newBotState = {
      'id': botData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'userId': userId,
      'isActive': isActive,
      'assetType': assetType,
      'exchangeType': botData['exchange_type'] ?? 'Binance',
      'positionAmount': botData['pos_amt']?.toString() ?? '0',
      'avgPrice': botData['avg_price']?.toString() ?? '0',
      'numberOfMarginCalls': int.parse(botData['no_margincall'] ?? '0'),
      'lastAVGPrice': double.parse(botData['last_avgprice']?.toString() ?? '0'),
      'currentPrice': botData['currentPrice']?.toString(),
      'tradeSettings': {
        'marginCallsEnabled': botData['stock_margin'] == '1',
        'marginCallLimit': botData['margin_call_limit']?.toString() ?? '0',
        'marginCallDrop': double.parse(botData['margin_drop']?.toString() ?? '0'),
        'takeProfit': botData['take_profit']?.toString() ?? '0',
        'earningCallback': botData['earning_callback']?.toString() ?? '0',
        'buyInCallback': botData['buy_in_callback']?.toString() ?? '0',
        'firstBuyAmount': botData['first_buy']?.toString() ?? '0',
        'positionDoubling': botData['position_doubling'] == '1'
      }
    };
    
    if (index != -1) {
      // Update existing bot
      existingStates[index] = newBotState;
      print('✅ UPDATED EXISTING BOT STATE: ${newBotState['assetType']}');
    } else {
      // Add new bot
      existingStates.add(newBotState);
      print('✅ ADDED NEW BOT STATE: ${newBotState['assetType']}');
    }
    
    // Save updated states
    await prefs.setString('bot_states', json.encode(existingStates));
    print('📊 TOTAL ACTIVE BOTS: ${existingStates.where((state) => state['isActive'] == true).length}');
    
  } catch (e) {
    print('❌ ERROR SYNCING BOT STATES: $e');
  }
}

// Fallback mechanism using Timer when Workmanager is not available
void _initializeFallbackBackgroundService() {
  print('🔄 INITIALIZING FALLBACK BACKGROUND SERVICE...');
  
  // Cancel any existing timer
  if (_fallbackTimer != null) {
    _fallbackTimer!.cancel();
  }
  
  // Track consecutive empty checks
  int emptyCheckCount = 0;
  const int maxEmptyChecks = 1;
  
  // Start new timer with 15-second interval
  _fallbackTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
    try {
      print('🔄 FALLBACK BACKGROUND TASK RUNNING...');
      
      // Initialize SharedPreferences with proper error handling
      SharedPreferences? prefs;
      try {
        prefs = await SharedPreferences.getInstance();
      } catch (e) {
        print('⚠️ Failed to initialize SharedPreferences: $e');
        return;
      }
      
      if (prefs == null) {
        print('⚠️ SharedPreferences is null');
        return;
      }
      
      // First try to get active bots from the API
      bool foundBotsFromAPI = false;
      try {
        final response = await http.post(
          Uri.parse(quantitative_txn_recordsubbin),
          body: json.encode({
            "user_id": commonuserId,
            "exchange_type": exchanger,
            "assets": "*" // Get all assets
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          }
        ).timeout(Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            final List<dynamic> activeBots = data['data'];
            print('📡 FOUND ${activeBots.length} BOTS FROM API');
            
            // Only proceed if we found active bots
            if (activeBots.isNotEmpty) {
              foundBotsFromAPI = true;
              emptyCheckCount = 0; // Reset empty check counter
              
              // Sync each bot's state
              for (var bot in activeBots) {
                if (bot['status'] == '1') { // Only sync active bots
                  await syncBotStates(
                    commonuserId,
                    bot['assets'],
                    true,
                    bot
                  );
                }
              }
            }
          }
        }
      } catch (e) {
        print('⚠️ ERROR FETCHING BOTS FROM API: $e');
      }
      
      // Now process the synced bot states
      final savedStatesJson = prefs.getString('bot_states');
      
      if (savedStatesJson == null) {
        print('⚠️ NO BOT STATES FOUND');
        if (!foundBotsFromAPI) {
          emptyCheckCount++;
          if (emptyCheckCount >= maxEmptyChecks) {
            print('⏸️ NO BOTS FOUND FOR $maxEmptyChecks CONSECUTIVE CHECKS - PAUSING FALLBACK SERVICE');
            timer.cancel();
            _fallbackTimer = null;
            return;
          }
        }
        return;
      }
      
      final List<dynamic> botStates = json.decode(savedStatesJson);
      final activeBots = botStates.where((state) => 
        state['isActive'] == true && 
        _validateBotState(state)
      ).toList();
      
      final int totalBots = botStates.length;
      final int activeBotCount = activeBots.length;
      
      print('📊 Bot Status:');
      print('Total Bots: $totalBots');
      print('Active Bots: $activeBotCount');
      
      if (activeBots.isEmpty) {
        print('⚠️ NO ACTIVE BOTS TO PROCESS');
        if (!foundBotsFromAPI) {
          emptyCheckCount++;
          if (emptyCheckCount >= maxEmptyChecks) {
            print('⏸️ NO BOTS FOUND FOR $maxEmptyChecks CONSECUTIVE CHECKS - PAUSING FALLBACK SERVICE');
            timer.cancel();
            _fallbackTimer = null;
            return;
          }
        }
        return;
      }
      
      // Reset empty check counter since we found active bots
      emptyCheckCount = 0;
      
      bool hasChanges = false;
      
      // Process each active bot
      for (final botState in activeBots) {
        print('🤖 Processing bot for ${botState['assetType']}...');
        
        try {
          // Get current price
          final price = await _fetchPriceFromProvider(botState);
          if (price == null) {
            print('⚠️ COULD NOT FETCH CURRENT PRICE FOR ${botState['assetType']}');
            continue;
          }
          
          // Update the current price in bot state
          botState['currentPrice'] = price;
          hasChanges = true;
          
          print('💱 CURRENT PRICE FOR ${botState['assetType']}: $price');
      
      // Check for buy conditions
      if (_shouldBuy(botState, price)) {
            print('🟢 BUY CONDITION MET FOR ${botState['assetType']} - EXECUTING BUY ORDER');
            final buySuccess = await _executeBuy(botState);
            if (buySuccess) {
              hasChanges = true;
              // Re-sync bot state after successful buy
              await syncBotStates(
                botState['userId'],
                botState['assetType'],
                true,
                botState
              );
            }
      }
      
      // Check for sell conditions
      if (_shouldSell(botState, price)) {
            print('🟢 SELL CONDITION MET FOR ${botState['assetType']} - EXECUTING SELL ORDER');
            final sellSuccess = await _executeSell(botState);
            if (sellSuccess) {
              hasChanges = true;
              // Re-sync bot state after successful sell
              await syncBotStates(
                botState['userId'],
                botState['assetType'],
                false, // Set to inactive after successful sell
                botState
              );
            }
          }
        } catch (e) {
          print('❌ Error processing bot ${botState['assetType']}: $e');
          continue;
        }
      }
      
      // Only save if there were changes
      if (hasChanges) {
        await _updateBotStates(botStates);
        print('✅ BOT STATES UPDATED SUCCESSFULLY');
      } else {
        print('ℹ️ NO CHANGES TO SAVE');
      }
    } catch (e) {
      print('❌ ERROR IN FALLBACK SERVICE: $e');
    }
  });
  
  print('✅ FALLBACK BACKGROUND SERVICE INITIALIZED');
}

// Add cache for price data
Map<String, Map<String, dynamic>> _priceCache = {};
DateTime? _lastPriceFetch;

Future<String?> _fetchPriceFromProvider(Map<String, dynamic> botState) async {
  try {
    print('🔍 FETCHING LIVE PRICE FOR ${botState['assetType']}...');

    // For web platform, use CORS-friendly endpoints
    if (kIsWeb) {
      print('🌐 Web platform detected - Using CORS-friendly endpoints');
      
      // Try Binance.US API first (CORS-friendly)
      try {
        final response = await http.get(
          Uri.parse('https://api.binance.us/api/v3/ticker/price?symbol=${botState['assetType']}'),
          headers: {
            'Accept': 'application/json'
          }
        ).timeout(Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['price'] != null) {
            final price = double.parse(data['price'].toString());
            final formattedPrice = price.toStringAsFixed(8);
            print('✅ Found live price from Binance.US: $formattedPrice');
            return formattedPrice;
          }
        }
      } catch (e) {
        print('⚠️ Binance.US API request failed: $e');
      }

      // Try CoinGecko API as fallback
      try {
        final symbol = botState['assetType']
          .replaceAll('USDT', '')
          .replaceAll('USD', '')
          .toLowerCase();
          
        final response = await http.get(
          Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=$symbol&vs_currencies=usd'),
          headers: {
            'Accept': 'application/json'
          }
        ).timeout(Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data[symbol] != null && data[symbol]['usd'] != null) {
            final price = double.parse(data[symbol]['usd'].toString());
            final formattedPrice = price.toStringAsFixed(8);
            print('✅ Found live price from CoinGecko: $formattedPrice');
            return formattedPrice;
          }
        }
      } catch (e) {
        print('⚠️ CoinGecko API request failed: $e');
      }
    } else {
      // For mobile platforms, use direct API calls
      // Try Binance API first (most reliable)
      try {
        final response = await http.get(
          Uri.parse('https://api.binance.com/api/v3/ticker/price?symbol=${botState['assetType']}'),
          headers: {
            'Accept': 'application/json'
          }
        ).timeout(Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['price'] != null) {
            final price = double.parse(data['price'].toString());
            final formattedPrice = price.toStringAsFixed(8);
            print('✅ Found live price from Binance: $formattedPrice');
            return formattedPrice;
          }
        }
      } catch (e) {
        print('⚠️ Binance API request failed: $e');
      }

      // Try Binance 24hr ticker as fallback
      try {
        final response = await http.get(
          Uri.parse('https://api.binance.com/api/v3/ticker/24hr?symbol=${botState['assetType']}'),
          headers: {
            'Accept': 'application/json'
          }
        ).timeout(Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['lastPrice'] != null) {
            final price = double.parse(data['lastPrice'].toString());
            final formattedPrice = price.toStringAsFixed(8);
            print('✅ Found live price from Binance 24hr ticker: $formattedPrice');
            return formattedPrice;
          }
        }
      } catch (e) {
        print('⚠️ Binance 24hr ticker request failed: $e');
      }
    }
    
    // If all public APIs fail, try authenticated API as last resort
    try {
      print('⚠️ All public APIs failed, trying authenticated API...');
      final response = await http.post(
        Uri.parse(quantitative_txn_recordsubbin),
        body: json.encode({
          "user_id": botState['userId'],
          "exchange_type": botState['exchangeType'] == 'null' ? 'Binance' : botState['exchangeType'],
          "assets": botState['assetType']
        }),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] is List && data['data'].isNotEmpty) {
          final pricelist = data['data'] as List;
          for (var p in pricelist) {
            if (p['symbol'] == botState['assetType']) {
              if (p['lastPrice'] != null) {
                final price = double.tryParse(p['lastPrice'].toString());
                if (price != null) {
                  final formattedPrice = price.toStringAsFixed(8);
                  print('✅ Found live price from authenticated API: $formattedPrice');
                  return formattedPrice;
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('⚠️ Authenticated API request failed: $e');
    }
    
    // If all APIs fail, try to use cached price if available
    if (_priceCache.containsKey(botState['assetType'])) {
      final cachedData = _priceCache[botState['assetType']]!;
      final now = DateTime.now();
      if (cachedData['timestamp'] != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(cachedData['timestamp']);
        if (now.difference(cacheTime).inMinutes < 5) { // Use cache if less than 5 minutes old
          print('⚠️ Using cached price due to API failures');
          return cachedData['price'];
        }
      }
    }
    
    print('❌ Could not fetch live price from any source');
    return null;
    
  } catch (e, stackTrace) {
    print('❌ ERROR FETCHING LIVE PRICE:');
    print('Error: $e');
    print('Stack trace: $stackTrace');
    return null;
  }
}

// Check if should buy based on conditions
bool _shouldBuy(Map<String, dynamic> botState, String currentPrice) {
  try {
    if (!botState['isActive']) {
      print('⏭️ Bot is not active');
      return false;
    }
  
  final settings = botState['tradeSettings'];
  final marginCallsEnabled = settings['marginCallsEnabled'] ?? false;
  final marginCallLimit = int.parse(settings['marginCallLimit'] ?? '0');
  final currentMarginCalls = botState['numberOfMarginCalls'] ?? 0;
  
    // Check if margin calls are enabled
    if (!marginCallsEnabled) {
      print('⏭️ Margin calls are disabled');
      return false;
    }
    
    // Check margin call limit
    if (currentMarginCalls >= marginCallLimit) {
      print('⏭️ Margin call limit reached ($currentMarginCalls/$marginCallLimit)');
      return false;
    }
    
    // Calculate required buy amount
    final firstBuyAmount = double.tryParse(settings['firstBuyAmount']?.toString() ?? '0') ?? 0;
    if (firstBuyAmount <= 0) {
      print('⏭️ Invalid first buy amount');
      return false;
    }
    
    double requiredAmount;
    final positionAmount = double.tryParse(botState['positionAmount'] ?? '0') ?? 0;
    
    if (positionAmount <= 0) {
      // Initial buy
      requiredAmount = settings['positionDoubling'] == true ? firstBuyAmount * 2 : firstBuyAmount;
    } else {
      // Margin call buy
      requiredAmount = settings['positionDoubling'] == true ? positionAmount * 2 : firstBuyAmount;
    }
    
    print('💰 Required buy amount: $requiredAmount USDT');
    
    // Check price conditions
    final lastAVGPrice = double.tryParse(botState['lastAVGPrice'] ?? '0') ?? 0;
    final marginCallDrop = double.tryParse(settings['marginCallDrop'] ?? '0') ?? 0;
    
    if (lastAVGPrice <= 0 || marginCallDrop <= 0) {
      print('⏭️ Invalid last average price or margin call drop');
    return false;
  }
  
    // Calculate margin call trigger price
    final CMTP = lastAVGPrice * marginCallDrop / 100;
    final triggerPrice = lastAVGPrice - CMTP;
    final currentPriceDouble = double.tryParse(currentPrice) ?? 0;
    
    print('📊 Buy Check:');
    print('Current Price: $currentPriceDouble');
    print('Last AVG Price: $lastAVGPrice');
    print('Margin Call Drop: $marginCallDrop%');
    print('Trigger Price: $triggerPrice');
    
    final shouldBuy = currentPriceDouble <= triggerPrice;
  
  if (shouldBuy) {
      print('🟢 BUY CONDITION MET: Current price ($currentPriceDouble) <= Trigger price ($triggerPrice)');
  } else {
      print('⏭️ BUY CONDITION NOT MET: Current price ($currentPriceDouble) > Trigger price ($triggerPrice)');
  }
  
  return shouldBuy;
  } catch (e) {
    print('❌ Error checking buy conditions: $e');
    return false;
  }
}

// Check if should sell based on conditions
bool _shouldSell(Map<String, dynamic> botState, String currentPrice) {
  if (!botState['isActive']) {
    print('⏭️ Bot is not active');
    return false;
  }
  
  final settings = botState['tradeSettings'];
  final avgPrice = double.parse(botState['avgPrice'] ?? '0');
  
  if (avgPrice <= 0) {
    print('⏭️ No position (avgPrice = 0)');
    return false;
  }
  
  // Check if position amount is valid
  final positionAmount = double.parse(botState['positionAmount'] ?? '0');
  if (positionAmount <= 0) {
    print('⏭️ No position amount (positionAmount = 0)');
    return false;
  }
  
  try {
  final currentPriceDouble = double.parse(currentPrice);
  final profitPercentage = ((currentPriceDouble - avgPrice) / avgPrice) * 100;
  final takeProfit = double.tryParse(settings['takeProfit']?.toString() ?? '0') ?? 0.0;
    final earningCallback = double.tryParse(settings['earningCallback']?.toString() ?? '0') ?? 0.0;
    
    print('📊 Sell Check:');
    print('Current Price: $currentPriceDouble');
    print('Average Price: $avgPrice');
    print('Profit Percentage: ${profitPercentage.toStringAsFixed(2)}%');
    print('Take Profit: $takeProfit%');
    print('Earning Callback: $earningCallback%');
    
    // Calculate take profit trigger price
    final TPTP = avgPrice * takeProfit / 100;
    final takeProfitTriggerPrice = avgPrice + TPTP;
    
    // Check if we have valid take profit values
    if (takeProfit <= 0 && takeProfitTriggerPrice <= 0) {
      print('⏭️ Invalid take profit settings');
      return false;
    }
    
    // Check all sell conditions
    final shouldSell = (currentPriceDouble >= takeProfitTriggerPrice || profitPercentage >= takeProfit) && 
                      profitPercentage >= earningCallback;
  
  if (shouldSell) {
      print('🟢 SELL CONDITION MET:');
      print('Price ($currentPriceDouble) >= Take Profit Trigger Price ($takeProfitTriggerPrice) OR');
      print('Profit ($profitPercentage%) >= Take Profit ($takeProfit%) AND');
      print('Profit ($profitPercentage%) >= Earning Callback ($earningCallback%)');
  } else {
      print('⏭️ SELL CONDITION NOT MET:');
      print('Price ($currentPriceDouble) < Take Profit Trigger Price ($takeProfitTriggerPrice) AND');
      print('Profit ($profitPercentage%) < Take Profit ($takeProfit%) OR');
      print('Profit ($profitPercentage%) < Earning Callback ($earningCallback%)');
  }
  
  return shouldSell;
  } catch (e) {
    print('❌ ERROR CHECKING SELL CONDITIONS: $e');
    return false;
  }
}

// Execute buy order
Future<bool> _executeBuy(Map<String, dynamic> botState) async {
  try {
    print('🟢 EXECUTING BUY ORDER...');
    
    // Get trade settings
    final settings = botState['tradeSettings'];
    final firstBuyAmount = double.tryParse(settings['firstBuyAmount']?.toString() ?? '0') ?? 0;
    final positionDoubling = settings['positionDoubling'] ?? false;
    
    // Calculate buy amount
    double buyAmount;
    final positionAmount = double.tryParse(botState['positionAmount'] ?? '0') ?? 0;
    final currentPrice = double.tryParse(botState['currentPrice'] ?? '0') ?? 0;
    
    if (positionAmount <= 0) {
      // Initial buy
      buyAmount = positionDoubling ? firstBuyAmount * 2 : firstBuyAmount;
      print('📈 Initial Buy: $buyAmount USDT');
    } else {
      // For margin calls, calculate the buy amount first
      if (positionDoubling) {
        buyAmount = positionAmount * 2;
        print('📈 Position Doubling Buy: $buyAmount USDT');
      } else {
        buyAmount = firstBuyAmount;
        print('📈 Fixed Amount Buy: $buyAmount USDT');
      }
    }
    
    // Execute buy order
    print('💰 Executing buy order for ${botState['assetType']}...');
    final response = await http.post(
      Uri.parse(botState['exchangeType'] == 'Binance' || botState['exchangeType'] == 'null'
        ? buymanualsubbin 
        : buyManualHuobiSubbin),
      body: json.encode({
        'user_id': botState['userId'],
        'type': botState['exchangeType'],
        'crypto_pair': botState['assetType'],
        'amount': buyAmount.toString(),
        'no_margincall': (botState['numberOfMarginCalls'] + 1).toString()  // Pass margin call count to backend
      }),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }
    ).timeout(Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'FILLED' || data['status'] == 'success') {
        // Show notification
        await NotificationService().showBuyNotification(
          assetType: botState['assetType'],
          amount: buyAmount.toString(),
          price: botState['currentPrice'] ?? 'unknown'
        );
        
        // Update local state with new values from response
        if (data['fills'] != null && data['fills'].isNotEmpty) {
          final fills = data['fills'][0];
          botState['lastAVGPrice'] = fills['price'];
          botState['numberOfMarginCalls'] = (botState['numberOfMarginCalls'] ?? 0) + 1;
        }
        
        return true;
      } else if (data['message'] != null && 
                 data['message'].toString().toLowerCase().contains('insufficient balance')) {
        print('⚠️ Insufficient balance for buy order');
        return false;
      } else {
        print('⚠️ Buy order failed: ${data['message'] ?? 'Unknown error'}');
      }
    }
    return false;
  } catch (e) {
    print('❌ ERROR EXECUTING BUY: $e');
    return false;
  }
}

// Execute sell order
Future<bool> _executeSell(Map<String, dynamic> botState) async {
  try {
    print('🔴 EXECUTING SELL ORDER...');
    
    // Validate position amount
    if (botState['positionAmount'] == null || double.parse(botState['positionAmount']) <= 0) {
      print('⚠️ INVALID POSITION AMOUNT FOR SELL');
      return false;
    }
    
    // Calculate profit value
    double currentPrice = double.parse(botState['currentPrice'] ?? '0');
    double avgPrice = double.parse(botState['avgPrice'] ?? '0');
    double positionAmount = double.parse(botState['positionAmount']);
    double profitValue = (currentPrice - avgPrice) * positionAmount;
    
    print('💰 Sell Details:');
    print('Position Amount: $positionAmount USDT');
    print('Current Price: $currentPrice');
    print('Average Price: $avgPrice');
    print('Profit Value: $profitValue USDT');
    
    final response = await http.post(
      Uri.parse(APIsellmanualsubbin),
      body: json.encode({
        'user_id': botState['userId'],
        'type': botState['exchangeType'],
        'crypto_pair': botState['assetType'],
        'amount': botState['positionAmount'],
        'profit_value': profitValue.toString()
      })
    ).timeout(Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('🔴 SELL RESPONSE: $data');
      
      if (data['status'] == 'success') {
        // Calculate profit percentage
        double profitPercentage = ((currentPrice - avgPrice) / avgPrice) * 100;
        
        // Show notification
        await NotificationService().showSellNotification(
          assetType: botState['assetType'],
          amount: botState['positionAmount'],
          price: botState['currentPrice'] ?? 'unknown',
          profit: profitPercentage.toStringAsFixed(2)
        );
        
        // Only reset bot state on successful sell
        botState['isActive'] = false;
        botState['positionAmount'] = '0';
        botState['avgPrice'] = '0';
        botState['numberOfMarginCalls'] = 0;
        botState['lastAVGPrice'] = '0';
        botState['lastSellPrice'] = currentPrice.toString();
        
        print('✅ SELL ORDER EXECUTED SUCCESSFULLY');
        print('📊 PROFIT: ${profitPercentage.toStringAsFixed(2)}%');
        
        return true;
      } else {
        print('⚠️ SELL ORDER FAILED: ${data['message'] ?? 'Unknown error'}');
        // Don't deactivate the bot on failed sell
        return false;
      }
    }
    return false;
  } catch (e) {
    print('❌ ERROR EXECUTING SELL: $e');
    return false;
  }
}

// Update bot states without clearing them on error
Future<void> _updateBotStates(List<dynamic> botStates, {bool forceUpdate = false}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // First, check backend state for each bot
    for (var botState in botStates) {
      if (botState['id'] == null || !botState['isActive']) continue;
      
      try {
        final response = await http.post(
          Uri.parse(quantitative_txn_recordsubbin),
          body: json.encode({
            "user_id": botState['userId'],
            "exchange_type": botState['exchangeType'],
            "assets": botState['assetType']
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          }
        ).timeout(Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success' && data['data'] is List) {
            final trades = data['data'] as List;
            // If no active trades found, deactivate the bot
            if (trades.isEmpty || !trades.any((t) => t['status'] == '1')) {
              print('🔄 No active trades found for ${botState['assetType']} - Deactivating bot');
              botState['isActive'] = false;
              botState['positionAmount'] = '0';
              botState['avgPrice'] = '0';
              botState['numberOfMarginCalls'] = 0;
              botState['lastAVGPrice'] = '0';
            }
          }
        }
      } catch (e) {
        print('⚠️ Error checking backend state for ${botState['assetType']}: $e');
      }
    }
    
    // Get existing states
    final existingStatesJson = prefs.getString('bot_states') ?? '[]';
    List<dynamic> existingStates = json.decode(existingStatesJson);
    
    bool hasChanges = false;
    
    // Update each bot state while preserving existing data
    for (var botState in botStates) {
      if (botState['id'] == null) continue;
      
      final index = existingStates.indexWhere((state) => state['id'] == botState['id']);
      if (index != -1) {
        existingStates[index] = botState;
        hasChanges = true;
      } else if (botState['isActive'] == true) {
        existingStates.add(botState);
        hasChanges = true;
      }
    }
    
    // Filter out inactive bots
    existingStates = existingStates.where((state) {
      if (!state['isActive'] || state['id'] == null) return false;
      
      final positionAmountStr = state['positionAmount']?.toString() ?? '0';
      final positionAmount = double.tryParse(positionAmountStr) ?? 0.0;
      return positionAmount > 0;
    }).toList();
    
    if (hasChanges || forceUpdate) {
      await prefs.setString('bot_states', json.encode(existingStates));
      print('✅ BOT STATES UPDATED: ${existingStates.length} bots (${existingStates.where((state) => state['isActive'] == true).length} active)');
    }
  } catch (e) {
    print('❌ ERROR UPDATING BOT STATES: $e');
    // Emergency save of current states
    try {
      final prefs = await SharedPreferences.getInstance();
      final activeStates = botStates.where((state) {
        if (!state['isActive']) return false;
        final positionAmountStr = state['positionAmount']?.toString() ?? '0';
        final positionAmount = double.tryParse(positionAmountStr) ?? 0.0;
        return positionAmount > 0;
      }).toList();
      await prefs.setString('bot_states', json.encode(activeStates));
      print('✅ BOT STATES RECOVERED (Emergency Save)');
    } catch (e) {
      print('❌ FAILED TO RECOVER BOT STATES: $e');
    }
  }
}

// Update the callbackDispatcher to properly initialize plugins
@pragma('vm:entry-point')
void callbackDispatcher() {
  // Ensure plugins are initialized for background execution
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences in the background isolate
  SharedPreferences.setPrefix('background_');
  
  Workmanager().executeTask((taskName, inputData) async {
    try {
      print('🔄 BACKGROUND TASK STARTED: $taskName');
      
      // Initialize SharedPreferences with proper error handling
      SharedPreferences? prefs;
      try {
        prefs = await SharedPreferences.getInstance();
      } catch (e) {
        print('⚠️ Failed to initialize SharedPreferences: $e');
        return true; // Return true to prevent retry
      }
      
      if (prefs == null) {
        print('⚠️ SharedPreferences is null');
        return true;
      }
      
      final savedStatesJson = prefs.getString('bot_states');
      
      if (savedStatesJson == null) {
        print('⚠️ NO BOT STATES FOUND');
        return true;
      }
      
      final List<dynamic> botStates = json.decode(savedStatesJson);
      final activeBots = botStates.where((state) => 
        state['isActive'] == true && 
        _validateBotState(state)
      ).toList();
      
      print('📊 Bot Status:');
      print('Total Bots: ${botStates.length}');
      print('Active Bots: ${activeBots.length}');
      
      if (activeBots.isEmpty) {
        print('⚠️ NO ACTIVE BOTS TO PROCESS');
        return true;
      }
      
      bool hasChanges = false;
      
      // Process each active bot
      for (final botState in activeBots) {
        print('🤖 Processing bot for ${botState['assetType']}...');
        
        try {
          // Get current price
          final price = await _fetchPriceFromProvider(botState);
          if (price == null) {
            print('⚠️ COULD NOT FETCH CURRENT PRICE FOR ${botState['assetType']}');
            continue;
          }
          
          botState['currentPrice'] = price;
          hasChanges = true;
          
          print('💱 CURRENT PRICE FOR ${botState['assetType']}: $price');
          
          // Check for buy conditions
          if (_shouldBuy(botState, price)) {
            print('🟢 BUY CONDITION MET FOR ${botState['assetType']} - EXECUTING BUY ORDER');
            final buySuccess = await _executeBuy(botState);
            if (buySuccess) {
              hasChanges = true;
            }
          }
          
          // Check for sell conditions
          if (_shouldSell(botState, price)) {
            print('🟢 SELL CONDITION MET FOR ${botState['assetType']} - EXECUTING SELL ORDER');
            final sellSuccess = await _executeSell(botState);
            if (sellSuccess) {
              hasChanges = true;
            }
          }
        } catch (e) {
          print('❌ Error processing bot ${botState['assetType']}: $e');
          continue;
        }
      }
      
      // Only save if there were changes
      if (hasChanges) {
        try {
          await _updateBotStates(botStates);
          print('✅ ALL BOT STATES UPDATED AND SAVED');
        } catch (e) {
          print('❌ Error updating bot states: $e');
        }
      } else {
        print('ℹ️ NO CHANGES TO SAVE');
      }
      
      return true;
    } catch (e) {
      print('❌ ERROR EXECUTING BOT LOGIC: $e');
      return false;
    }
  });
}

// Update the bot state validation to be more precise
bool _validateBotState(Map<String, dynamic> botState) {
  try {
    print('🔍 Validating bot state for ${botState['assetType']}...');
    
    // Check if bot exists and has required fields
    if (botState == null) {
      print('⚠️ Bot state is null');
      return false;
    }

    // Check if bot is marked as active
    if (botState['isActive'] != true) {
      print('⏭️ Bot is not active');
      return false;
    }

    // Check required fields
    final requiredFields = [
      'userId',
      'exchangeType',
      'assetType',
      'tradeSettings'
    ];

    for (final field in requiredFields) {
      if (!botState.containsKey(field) || botState[field] == null) {
        print('⚠️ Missing required field: $field');
        return false;
      }
    }

    // Validate trade settings
    final settings = botState['tradeSettings'];
    if (settings == null || !(settings is Map)) {
      print('⚠️ Invalid trade settings');
      return false;
    }

    // Check if first buy amount is valid
    final firstBuyAmount = double.tryParse(settings['firstBuyAmount']?.toString() ?? '0');
    if (firstBuyAmount == null || firstBuyAmount <= 0) {
      print('⚠️ Invalid first buy amount: $firstBuyAmount');
      return false;
    }

    // For active trading positions, validate position data
    final positionAmount = double.tryParse(botState['positionAmount']?.toString() ?? '0');
    if (positionAmount != null && positionAmount > 0) {
      final avgPrice = double.tryParse(botState['avgPrice']?.toString() ?? '0');
      if (avgPrice == null || avgPrice <= 0) {
        print('⚠️ Invalid average price for active position');
        return false;
      }
    }

    print('✅ Bot state validation passed for ${botState['assetType']}');
    return true;
  } catch (e) {
    print('❌ Error validating bot state: $e');
    return false;
  }
}

// Add timer variable at the top of the file
Timer? _fallbackTimer; 