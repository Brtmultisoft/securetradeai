import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rapidtradeai/Data/Api.dart';
import 'package:rapidtradeai/data/strings.dart';

class BotService {
  static final BotService _instance = BotService._internal();
  factory BotService() => _instance;
  BotService._internal();

  Timer? _botTimer;
  bool _isRunning = false;
  bool _isInitialized = false;

  Future<void> startBotService() async {
    if (_isRunning) return;
    _isRunning = true;
    print("Bot service starting...");

    // Start timer to check bot conditions every 2 seconds
    _botTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_isRunning) {
        _checkAllBots();
      }
    });

    // Initial check
    await _checkAllBots();
    _isInitialized = true;
    print("Bot service started successfully");
  }

  Future<void> stopBotService() async {
    _botTimer?.cancel();
    _isRunning = false;
    _isInitialized = false;
    print("Bot service stopped");
  }

  Future<void> _checkAllBots() async {
    if (!_isRunning) return;

    try {
      print("Checking all bots...");
      // Get all active bots from the API
      final res = await http.post(Uri.parse(quantitative_txn_recordsubbin),
          body: json.encode({
            "user_id": commonuserId,
            "exchange_type": exchanger,
          }));

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['status'] == "success") {
          var finaldata = data['data'] as List;
          print("Found ${finaldata.length} bots");

          for (var bot in finaldata) {
            if (bot['status'] == "1") {
              // Only check active bots
              try {
                print("Checking bot ${bot['id']} for ${bot['symbol']}");
                // Get current price
                final currentPrice =
                    await _getCurrentPrice(bot['symbol'], bot['exchange_type']);
                print("Current price for ${bot['symbol']}: $currentPrice");

                // Check auto buy conditions
                await _checkAutoBuy(
                  bot: bot,
                  currentPrice: currentPrice,
                );

                // Check auto sell conditions
                await _checkAutoSell(
                  bot: bot,
                  currentPrice: currentPrice,
                );
              } catch (e) {
                print('Error checking bot ${bot['id']}: $e');
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error in _checkAllBots: $e');
    }
  }

  Future<double> _getCurrentPrice(String symbol, String exchange) async {
    try {
      if (exchange == "null" || exchange == "Binance") {
        final response = await http.get(Uri.parse('YOUR_BINANCE_PRICE_API'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          for (var p in data) {
            if (p['symbol'] == symbol) {
              return double.parse(p['lastPrice']);
            }
          }
        }
      } else {
        final response = await http.get(Uri.parse('YOUR_HUOBI_PRICE_API'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          for (var p in data) {
            if (p['symbol'] == symbol.toLowerCase()) {
              return double.parse(p['close']);
            }
          }
        }
      }
      throw Exception('Failed to get current price');
    } catch (e) {
      print("Error getting current price: $e");
      throw e;
    }
  }

  Future<void> _checkAutoBuy({
    required Map<String, dynamic> bot,
    required double currentPrice,
  }) async {
    if (bot['stock_margin'] == "0") return;
    if (int.parse(bot['no_margincall']) >= int.parse(bot['margin_call_limit']))
      return;

    final lastAvgPrice = double.parse(bot['last_avgprice']);
    final marginCallDrop = double.parse(bot['margin_calldrop']);

    if (marginCallDrop <= 0) return;

    final priceDropPercent =
        ((lastAvgPrice - currentPrice) / lastAvgPrice) * 100;

    if (currentPrice <= double.parse(bot['margin_calldrop']) &&
        priceDropPercent >= marginCallDrop) {
      // Execute buy
      final buyAmount = bot['switch_value'] == "1"
          ? double.parse(bot['pos_amt']) * 2
          : double.parse(bot['first_buy']);

      await _executeBuy(bot, buyAmount);
    }
  }

  Future<void> _checkAutoSell({
    required Map<String, dynamic> bot,
    required double currentPrice,
  }) async {
    final avgPrice = double.parse(bot['avg_price']);
    final currentProfitPercentage =
        ((currentPrice - avgPrice) / avgPrice) * 100;

    if (currentProfitPercentage > 0) {
      // Check take profit trigger price
      if (currentPrice >= double.parse(bot['wp_rasio']) &&
          currentProfitPercentage >= double.parse(bot['earning_callback'])) {
        await _executeSell(bot);
        return;
      }

      // Check take profit ratio
      if (currentProfitPercentage >= double.parse(bot['take_profit']) &&
          currentProfitPercentage >= double.parse(bot['earning_callback'])) {
        await _executeSell(bot);
        return;
      }

      // Check buy in callback (trailing stop)
      final peakProfit = currentProfitPercentage;
      final dropFromPeak = peakProfit - currentProfitPercentage;

      if (dropFromPeak >= double.parse(bot['buy_in_callback'])) {
        await _executeSell(bot);
      }
    }
  }

  Future<void> _executeBuy(Map<String, dynamic> bot, double amount) async {
    try {
      print('Executing buy for bot ${bot['id']}: $amount USDT');

      // Prepare the buy request
      final bodydata = jsonEncode({
        "user_id": commonuserId,
        "type": bot['exchange_type'],
        "crypto_pair": bot['symbol'],
        "amount": amount.toString(),
      });

      // Execute buy based on exchange
      final url = bot['exchange_type'] == "Binance"
          ? buymanualsubbin
          : buyManualHuobiSubbin;
      final res = await http.post(Uri.parse(url), body: bodydata);

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Buy Response: $data");

        if (data['status'] == "FILLED") {
          print("Buy order executed successfully");

          // Update margin call count
          try {
            final updateRes =
                await http.post(Uri.parse(tradesetting_update_by_columnsubbin),
                    body: json.encode({
                      "user_id": commonuserId,
                      "assets_type": bot['symbol'],
                      "colum_name": "no_margincall",
                      "exchange_type": bot['exchange_type'],
                      "colum_value":
                          (int.parse(bot['no_margincall']) + 1).toString(),
                      "table_name": "crypto_open_orders_subbin"
                    }));

            if (updateRes.statusCode == 200) {
              var updateData = jsonDecode(updateRes.body);
              if (updateData['status'] == "success") {
                print(
                    "Updated Margin Call Count: ${int.parse(bot['no_margincall']) + 1}");
              } else {
                print(
                    "Failed to update margin call count: ${updateData['message']}");
              }
            }
          } catch (e) {
            print("Error updating margin call count: $e");
          }
        } else {
          print("Buy order failed: ${data['message']}");
        }
      } else {
        print("Server Error during buy");
      }
    } catch (e) {
      print("Error in _executeBuy: $e");
    }
  }

  Future<void> _executeSell(Map<String, dynamic> bot) async {
    try {
      print('Executing sell for bot ${bot['id']}');

      // Calculate profit value
      final currentPrice =
          await _getCurrentPrice(bot['symbol'], bot['exchange_type']);
      final profitValue = (currentPrice * double.parse(bot['pos_qty'])) -
          double.parse(bot['pos_amt']);

      // Prepare the sell request
      final bodydata = jsonEncode({
        "user_id": commonuserId,
        "type": bot['exchange_type'],
        "crypto_pair": bot['symbol'],
        "amount": bot['pos_amt'],
        "profit_value": profitValue.toString()
      });

      // Execute sell
      final res =
          await http.post(Uri.parse(APIsellmanualsubbin), body: bodydata);

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Sell Response: $data");

        if (data['status'] == "success") {
          print("Sell order executed successfully");
        } else {
          print("Sell order failed: ${data['message']}");
        }
      } else {
        print("Server Error during sell");
      }
    } catch (e) {
      print("Error in _executeSell: $e");
    }
  }
}
