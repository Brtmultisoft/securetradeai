import 'package:flutter/material.dart';
import 'package:securetradeai/Data/Api.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'mock_data.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/src/Service/background_service.dart' as background;
import 'package:shared_preferences/shared_preferences.dart';

class AutoTrading extends StatefulWidget {
  const AutoTrading({Key? key}) : super(key: key);

  @override
  State<AutoTrading> createState() => _AutoTradingState();
}

class _AutoTradingState extends State<AutoTrading> {
  String searchWords = "";
  bool isVisible = true;
  List<Map<String, dynamic>> adminSelectedPairs = [];
  bool isLoading = true;
  Map<String, bool> activeTradingPairs = {};
  Map<String, bool> loadingTradingPairs = {}; // Track loading state for each trading pair
  Map<String, bool> activatingTradingPairs = {}; // Track activation button loading state
  Map<String, dynamic> selectedPair = {};

  @override
  void initState() {
    super.initState();
    _loadAdminSelectedPairs();
  }

  // Helper method to show toast messages
  void showtost(String message, BuildContext context) {
    // Check if the context is still valid and mounted
    if (!mounted) return;

    // Use a try-catch block to handle any potential errors
    try {
      // Check if the scaffold messenger is available
      final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
      if (scaffoldMessenger != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // If scaffold messenger is not available, just print the message
        print('Toast message (no scaffold): $message');
      }
    } catch (e) {
      // If there's an error, just print the message
      print('Error showing toast: $e');
      print('Toast message: $message');
    }
  }

  // Get live price data from Binance API
  Future<Map<String, dynamic>> _getLivePriceData(String symbol) async {
    try {
      final cleanSymbol = symbol.replaceAll('/', '');
      final response = await http.get(
        Uri.parse('https://api.binance.com/api/v3/ticker/24hr?symbol=$cleanSymbol')
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'price': data['lastPrice'] != null ? double.parse(data['lastPrice']).toStringAsFixed(2) : '0.00',
          'priceChange': data['priceChangePercent'] ?? '0.00'
        };
      }
    } catch (e) {
      print('Error fetching price for $symbol: $e');
    }

    // Return default values if API call fails
    return {
      'price': '0.00',
      'priceChange': '0.00'
    };
  }

  // Get icon URL for a cryptocurrency
  String _getIconUrl(String symbol) {
    // Extract base currency from the pair (e.g., BTC from BTC/USDT)
    final baseCurrency = symbol.split('/')[0].toLowerCase();
    return 'https://cryptologos.cc/logos/$baseCurrency-$baseCurrency-logo.png';
  }

  Future<void> _loadAdminSelectedPairs() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Step 1: Fetch all risk levels
      final riskLevelsResponse = await http.post(
        Uri.parse('${mainUrl}myrest/user/get_risk_levels'),
      );

      if (riskLevelsResponse.statusCode != 200) {
        throw Exception('Failed to load risk levels: ${riskLevelsResponse.statusCode}');
      }

      // Check if response is HTML instead of JSON
      final responseBody = riskLevelsResponse.body.trim();
      if (responseBody.startsWith('<')) {
        throw const FormatException('Received HTML instead of JSON. The API endpoint may be incorrect or the server is returning an error page.');
      }

      final riskLevelsData = jsonDecode(responseBody);

      if (riskLevelsData['status'] != 'success') {
        throw Exception(riskLevelsData['message'] ?? 'Failed to load risk levels');
      }

      List<dynamic> riskLevels = riskLevelsData['data'];
      List<Map<String, dynamic>> formattedRiskLevels = [];

      // Step 2: For each risk level, fetch its trading strategies
      for (var riskLevel in riskLevels) {
        // Convert id to int if it's a string
        final int riskLevelId = riskLevel['id'] is String ? int.parse(riskLevel['id']) : riskLevel['id'];

        final strategiesResponse = await http.post(
          Uri.parse('${mainUrl}myrest/user/get_trade_strategies'),
          body: jsonEncode({
            'risk_level_id': riskLevelId
          })
        );

        if (strategiesResponse.statusCode != 200) {
          print('Failed to load strategies for risk level ${riskLevel['risk_level']}: ${strategiesResponse.statusCode}');
          continue; // Skip this risk level if strategies can't be loaded
        }

        // Check if response is HTML instead of JSON
        final strategiesResponseBody = strategiesResponse.body.trim();
        if (strategiesResponseBody.startsWith('<')) {
          print('Received HTML instead of JSON for strategies. The API endpoint may be incorrect.');
          continue; // Skip this risk level if strategies can't be loaded
        }

        final strategiesData = jsonDecode(strategiesResponseBody);

        if (strategiesData['status'] != 'success') {
          print('Failed to load strategies: ${strategiesData['message']}');
          continue; // Skip this risk level if strategies can't be loaded
        }

        List<dynamic> strategies = strategiesData['data'];
        List<Map<String, dynamic>> formattedPairs = [];

        // Step 3: For each strategy, get live price data
        for (var strategy in strategies) {
          final symbol = strategy['symbol'];
          final priceData = await _getLivePriceData(symbol);

          formattedPairs.add({
            'symbol': symbol,
            'icon': _getIconUrl(symbol),
            'price': priceData['price'],
            'priceChange': priceData['priceChange'],
            'strategy': strategy['strategy'],
            'minInvestment': strategy['min_investment'],
            'expectedReturn': strategy['expected_return'],
          });
        }

        // Step 4: Format the risk level with its pairs
        formattedRiskLevels.add({
          'riskLevel': riskLevel['risk_level'],
          'pairs': formattedPairs,
          'description': riskLevel['description'],
          'totalPairs': formattedPairs.length,
          'totalVolume': formattedPairs.length * 500000, // Estimate volume based on number of pairs
          'avgReturn': riskLevel['avg_return'],
          'isActive': false
        });
      }

      setState(() {
        adminSelectedPairs = formattedRiskLevels;

        // Initialize active trading pairs and loading states
        for (var riskLevel in adminSelectedPairs) {
          activeTradingPairs[riskLevel['riskLevel']] = false;
          loadingTradingPairs[riskLevel['riskLevel']] = false;
          activatingTradingPairs[riskLevel['riskLevel']] = false;
        }

        isLoading = false;
      });
      // Sync indicator with real bot state
      await _syncActiveTradingPairsWithBotStates();
    } catch (e) {
      print("Error loading pairs: $e");

      // Use mock data as fallback when API fails
      _loadMockData();

      // Show error toast
      showtost("Using demo data. Error: ${e.toString()}", context);
    }
  }

  // Fallback method to load mock data when API fails
  void _loadMockData() {
    setState(() {
      adminSelectedPairs = MockData.getRiskLevels();

      // Initialize active trading pairs and loading states
      for (var riskLevel in adminSelectedPairs) {
        activeTradingPairs[riskLevel['riskLevel']] = false;
        loadingTradingPairs[riskLevel['riskLevel']] = false;
        activatingTradingPairs[riskLevel['riskLevel']] = false;
      }

      isLoading = false;
    });
    // Sync indicator with real bot state (mock)
    _syncActiveTradingPairsWithBotStates();
  }

  void _toggleAutoTrading(String symbol) async {
    // Find the selected pair based on the symbol
    selectedPair = adminSelectedPairs.firstWhere(
      (pair) => pair['riskLevel'] == symbol,
      orElse: () => {},
    );

    if (selectedPair.isEmpty) {
      showtost("Pair not found", context);
      return;
    }

    // Set loading state for this trading pair
    setState(() {
      loadingTradingPairs[symbol] = true;
    });

    try {
      // Determine the intended new state (opposite of current state)
      bool newState = !(activeTradingPairs[symbol] ?? false);

      if (newState == true) {
        // First get the admin settings for this risk level
        String riskLevel = selectedPair['riskLevel']?.toString().toLowerCase() ?? 'low';

        // Get the risk level ID from the risk level name
        int riskLevelId = 1; // Default to Low risk
        if (riskLevel == 'medium') riskLevelId = 2;
        if (riskLevel == 'high') riskLevelId = 3;

        // First, get the trade strategies for this risk level
        final strategiesResponse = await http.post(
          Uri.parse('${mainUrl}myrest/user/get_trade_strategies'),
          body: json.encode({
            "risk_level_id": riskLevelId
          })
        );

        if (strategiesResponse.statusCode == 200) {
          // Check if response is HTML instead of JSON
          final strategiesResponseBody = strategiesResponse.body.trim();
          if (strategiesResponseBody.startsWith('<')) {
            setState(() {
              loadingTradingPairs[symbol] = false;
            });
            showtost("Received HTML instead of JSON. The API endpoint may be incorrect.", context);
            return;
          }

          var strategiesData = jsonDecode(strategiesResponseBody);
          if (strategiesData['status'] == "success") {
            // Now get the specific settings for this risk level
            final settingsResponse = await http.post(
              Uri.parse('${mainUrl}myrest/user/get_setting_trade_setting_risk_subbin'),
              body: json.encode({
                "type": riskLevel // "low", "medium", or "high"
              })
            );

            // Check if response is HTML instead of JSON
            final settingsResponseBody = settingsResponse.body.trim();
            if (settingsResponseBody.startsWith('<')) {
              setState(() {
                loadingTradingPairs[symbol] = false;
              });
              showtost("Received HTML instead of JSON for settings. The API endpoint may be incorrect.", context);
              return;
            }

            if (settingsResponse.statusCode == 200) {
              var settingsData = jsonDecode(settingsResponseBody);
              if (settingsData['status'] == "success") {
                // Extract settings from the API response
                Map<String, dynamic> settings = {
                  "first_buy": settingsData['data']['first_buy']?.toString() ?? "100",
                  "wp_profit": settingsData['data']['wp_profit']?.toString() ?? "3",
                  "margin_call_limit": settingsData['data']['margin_call_limit']?.toString() ?? "10",
                  "wp_callback": settingsData['data']['wp_callback']?.toString() ?? "1",
                  "by_callback": settingsData['data']['by_callback']?.toString() ?? "1",
                  "martin_config": settingsData['data']['martin_config'] == "1" || settingsData['data']['martin_config'] == true,
                  "margin_drop_1": settingsData['data']['margin_drop_1']?.toString() ?? "5",
                  "margin_drop_2": settingsData['data']['margin_drop_2']?.toString() ?? "10",
                  "margin_drop_3": settingsData['data']['margin_drop_3']?.toString() ?? "15",
                  "margin_drop_4": settingsData['data']['margin_drop_4']?.toString() ?? "20",
                  "margin_drop_5": settingsData['data']['margin_drop_5']?.toString() ?? "25",
                  "margin_drop_6": settingsData['data']['margin_drop_6']?.toString() ?? "30",
                  "margin_drop_7": settingsData['data']['margin_drop_7']?.toString() ?? "35",
                  "margin_drop_8": settingsData['data']['margin_drop_8']?.toString() ?? "40",
                  "margin_drop_9": settingsData['data']['margin_drop_9']?.toString() ?? "45",
                  "margin_drop_10": settingsData['data']['margin_drop_10']?.toString() ?? "50"
                };

                // Show activation dialog with settings
                _showActivationDialog(symbol, settings);
              } else {
                setState(() {
                  loadingTradingPairs[symbol] = false;
                });
                showtost(settingsData['message'] ?? "Failed to get risk settings", context);
              }
            } else {
              // Use mock settings as fallback
              Map<String, dynamic> mockSettings = MockData.getMockSettings(riskLevel);
              _showActivationDialog(symbol, mockSettings);
              showtost("Using demo settings. Server error: Failed to get risk settings", context);
            }
          } else {
            // Use mock data as fallback
            String riskLevel = selectedPair['riskLevel']?.toString().toLowerCase() ?? 'low';
            Map<String, dynamic> mockSettings = MockData.getMockSettings(riskLevel);
            _showActivationDialog(symbol, mockSettings);
            showtost("Using demo data. Error: ${strategiesData['message'] ?? "Failed to get trading strategies"}", context);
          }
        } else {
          // Use mock data as fallback
          String riskLevel = selectedPair['riskLevel']?.toString().toLowerCase() ?? 'low';
          Map<String, dynamic> mockSettings = MockData.getMockSettings(riskLevel);
          _showActivationDialog(symbol, mockSettings);
          showtost("Using demo data. Server error: Failed to get trading strategies", context);
        }
      } else {
        // Deactivate bot for all pairs in this risk level
        for (var pair in selectedPair['pairs'] ?? []) {
          final stopRes = await http.post(
            Uri.parse(openOrderStatussubbin),
            body: json.encode({
              "user_id": commonuserId,
              "exchange_type": exchanger,
              "assets": pair['symbol'],  // Use the pair symbol instead of risk level
              "status": "0",  // 0 for stop
              "risk_level": selectedPair['riskLevel']?.toString() ?? 'N/A'
            })
          );

          if (stopRes.statusCode == 200) {
            var stopData = jsonDecode(stopRes.body);
            if (stopData['status'] != "success") {
              showtost("Failed to stop bot for ${pair['symbol']}", context);
            }
          }
        }

        setState(() {
          activeTradingPairs[symbol] = false;
          loadingTradingPairs[symbol] = false;
        });
        _showSuccessDialog(symbol, false);
      }
    } catch (e) {
      setState(() {
        loadingTradingPairs[symbol] = false;
      });
      print("Error toggling bot: $e");
      showtost("Error toggling bot", context);
    }
  }

  void _showActivationDialog(String symbol, Map<String, dynamic> settings) {
    // Clear loading state when dialog is shown
    setState(() {
      loadingTradingPairs[symbol] = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing during activation
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Confirm Auto Trading', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Risk Level: ${selectedPair['riskLevel']}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              const Text('Trading Pairs:', style: TextStyle(color: Colors.white70)),
              ...selectedPair['pairs'].map<Widget>((pair) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('- ${pair['symbol']}', style: const TextStyle(color: Colors.white70)),
              )).toList(),
              const SizedBox(height: 16),
              const Text('Admin Settings:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildInfoRow('First Buy', '${settings['first_buy']} % USDT'),
              _buildInfoRow('Take Profit', '${settings['wp_profit']}%'),
              _buildInfoRow('Max Drawdown', '${settings['margin_call_limit']}%'),
              _buildInfoRow('Earning Callback', '${settings['wp_callback']}%'),
              _buildInfoRow('Buy-in Callback', '${settings['by_callback']}%'),
              _buildInfoRow('Position Doubling', settings['martin_config'] ? 'Enabled' : 'Disabled'),
              const SizedBox(height: 16),
              const Text(
                'The bot will automatically execute trades for all pairs based on these admin-selected settings.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Don't change the toggle state when cancelled - it should remain as it was
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF5C9CE6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: (activatingTradingPairs[symbol] ?? false) ? null : () async {
                // Set activation loading state in both parent and dialog
                setState(() {
                  activatingTradingPairs[symbol] = true;
                });
                setDialogState(() {
                  // Trigger dialog rebuild
                });

                try {
                  // Activate bot for all pairs in this risk level
                  bool allSuccess = true;
                  for (var pair in selectedPair['pairs']) {
                    try {
                      // Log the activation attempt
                      print('Activating trading for ${pair['symbol']} with risk level ${selectedPair['riskLevel']}');

                      // Step 1: First make a buy order for this pair
                      // Get the initial buy amount from settings
                      String initialBuyAmount = settings['first_buy'] ?? "10"; // Default amount

                      print('Making initial buy order for ${pair['symbol']} with amount $initialBuyAmount USDT');

                      // Format the symbol to ensure it meets the required format
                      String symbol = pair['symbol'] ?? "";
                      // Remove any special characters and ensure uppercase
                      symbol = symbol.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9\-_.]'), '');
                      // Limit to 20 characters
                      if (symbol.length > 20) {
                        symbol = symbol.substring(0, 20);
                      }

                      print('Formatted symbol: $symbol');

                      // Make the buy API call
                      final buyRes = await http.post(
                        Uri.parse(exchanger == "Binance" ? buymanualsubbin : buyManualHuobiSubbin),
                        headers: {
                          'Content-Type': 'application/json',
                          'Accept': 'application/json',
                        },
                        body: json.encode({
                          "user_id": commonuserId,
                          "type": exchanger,
                          "crypto_pair": symbol,
                          "amount": initialBuyAmount,
                          "order_mode":"auto"
                        })
                      );

                      if (buyRes.statusCode == 200) {
                        // Check if response is HTML instead of JSON
                        final responseBody = buyRes.body.trim();
                        if (responseBody.startsWith('<')) {
                          allSuccess = false;
                          String errorMsg = "Server returned HTML instead of JSON for ${pair['symbol']}";
                          print(errorMsg);
                          if (mounted) {
                            showtost(errorMsg, context);
                          }
                          continue; // Skip starting the bot if buy fails
                        }

                        try {
                          var buyData = jsonDecode(responseBody);
                          if (buyData['status'] != "success") {
                            allSuccess = false;
                            // Store error message instead of showing toast immediately
                            String errorMsg = "Failed to make initial buy for ${pair['symbol']}: ${buyData['message']}";
                            print(errorMsg);
                            // Check if context is still valid before showing toast
                            if (mounted) {
                              showtost(errorMsg, context);
                            }
                            continue; // Skip starting the bot if buy fails
                          } else {
                            print('Successfully made initial buy for ${pair['symbol']}');
                            // Check if context is still valid before showing toast
                            if (mounted) {
                              showtost("Initial buy successful for ${pair['symbol']}", context);
                            }

                            // Wait 3 seconds for the buy order to be processed before activating bot
                            print('⏳ Waiting 3 seconds before bot activation...');
                            await Future.delayed(Duration(seconds: 3));
                          }
                        } catch (e) {
                          allSuccess = false;
                          String errorMsg = "Error parsing response for ${pair['symbol']}: $e";
                          print(errorMsg);
                          if (mounted) {
                            showtost(errorMsg, context);
                          }
                          continue; // Skip starting the bot if parsing fails
                        }
                      } else {
                        allSuccess = false;
                        // Store error message instead of showing toast immediately
                        String errorMsg = "Server error: Failed to make initial buy for ${pair['symbol']}";
                        print(errorMsg);
                        // Check if context is still valid before showing toast
                        if (mounted) {
                          showtost(errorMsg, context);
                        }
                        continue; // Skip starting the bot if buy fails
                      }

                      // Step 2: Now start the bot
                      // Format symbol for bot activation (remove slash like BNBUSDT)
                      String botSymbol = pair['symbol'].toString().replaceAll('/', '');
                      print('🤖 Starting bot activation for ${pair['symbol']} -> formatted as: $botSymbol');

                      final botActivationBody = {
                        "user_id": commonuserId,
                        "exchange_type": exchanger,
                        "assets": botSymbol,  // Use formatted symbol without slash
                        "status": "1"  // 1 for start
                      };

                      print('📤 Bot activation request: $botActivationBody');

                      final startRes = await http.post(
                        Uri.parse(openOrderStatussubbin),
                        headers: {
                          'Content-Type': 'application/json',
                        },
                        body: json.encode(botActivationBody)
                      );

                      print('📥 Bot activation response status: ${startRes.statusCode}');
                      print('📥 Bot activation response body: ${startRes.body}');

                      if (startRes.statusCode == 200) {
                        // Check if response is HTML instead of JSON
                        final responseBody = startRes.body.trim();
                        if (responseBody.startsWith('<')) {
                          allSuccess = false;
                          String errorMsg = "Server returned HTML instead of JSON when activating bot for ${pair['symbol']}";
                          print(errorMsg);
                          if (mounted) {
                            showtost(errorMsg, context);
                          }
                          continue; // Skip this pair if we got HTML
                        }

                        try {
                          var startData = jsonDecode(responseBody);
                          if (startData['status'] != "success") {
                            allSuccess = false;
                            // Store error message instead of showing toast immediately
                            String errorMsg = "Failed to start bot for ${pair['symbol']}: ${startData['message']}";
                            print(errorMsg);
                            // Check if context is still valid before showing toast
                            if (mounted) {
                              showtost(errorMsg, context);
                            }
                          } else {
                            print('✅ Successfully activated bot for ${pair['symbol']}');
                            // Check if context is still valid before showing toast
                            if (mounted) {
                              showtost("Bot activated successfully for ${pair['symbol']}", context);
                            }

                            // CRITICAL: Fetch bot data and save state (same as manual activation)
                            try {
                              print('🔄 Fetching bot data after activation...');
                              await _fetchAndSaveBotState(botSymbol);
                              print('✅ Bot state saved successfully for ${pair['symbol']}');
                            } catch (e) {
                              print('❌ Error fetching/saving bot state: $e');
                            }

                            // Start background service for this bot
                            try {
                              await background.initializeBackgroundService();
                              print('✅ Background service started for ${pair['symbol']}');
                            } catch (e) {
                              print('⚠️ Warning: Background service failed to start: $e');
                            }
                          }
                        } catch (e) {
                          allSuccess = false;
                          String errorMsg = "Error parsing bot activation response for ${pair['symbol']}: $e";
                          print(errorMsg);
                          if (mounted) {
                            showtost(errorMsg, context);
                          }
                        }
                      } else {
                        allSuccess = false;
                        // Store error message instead of showing toast immediately
                        String errorMsg = "Server error: Failed to start bot for ${pair['symbol']}";
                        print(errorMsg);
                        // Check if context is still valid before showing toast
                        if (mounted) {
                          showtost(errorMsg, context);
                        }
                      }
                    } catch (e) {
                      allSuccess = false;
                      print('Error activating trading for ${pair['symbol']}: $e');
                      // Check if context is still valid before showing toast
                      if (mounted) {
                        showtost("Error activating trading for ${pair['symbol']}", context);
                      }
                    }
                  }

                  // Clear activation loading state and close dialog
                  setState(() {
                    activatingTradingPairs[symbol] = false;
                  });
                  Navigator.pop(context);

                  if (allSuccess) {
                    setState(() {
                      activeTradingPairs[symbol] = true;
                    });
                    _showSuccessDialog(symbol, true);
                  } else {
                    setState(() {
                      activeTradingPairs[symbol] = false;
                    });
                  }
                } catch (e) {
                  // Clear activation loading state and close dialog
                  setState(() {
                    activatingTradingPairs[symbol] = false;
                    activeTradingPairs[symbol] = false;
                  });
                  Navigator.pop(context);

                  print("Error starting bot: $e");
                  // Check if context is still valid before showing toast
                  if (mounted) {
                    showtost("Error starting bot", context);
                  }
                }
              },
              child: (activatingTradingPairs[symbol] ?? false)
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Activate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
        },
      ),
    );
  }

  // Fetch bot data and save state (replicates manual activation process)
  Future<void> _fetchAndSaveBotState(String symbol) async {
    try {
      print('📡 Fetching bot data for symbol: $symbol');

      // Call the same API that manual activation uses
      final res = await http.post(
        Uri.parse(quantitative_txn_recordsubbin),
        body: json.encode({
          "user_id": commonuserId,
          "exchange_type": exchanger,
          "assets": symbol
        })
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Request timed out');
        },
      );

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print('📥 Bot data response: $data');

        if (data['status'] == "success") {
          var finaldata = data['data'] as List;

          for (var e in finaldata) {
            // Find the bot entry for this symbol
            if (e['assets'] == symbol || e['symbol'] == symbol) {
              print('✅ Found bot data for $symbol: ${e['id']}');

              // Save bot state to SharedPreferences (same as manual activation)
              await _saveBotStateToPrefs(e, symbol);
              break;
            }
          }
        } else {
          throw Exception('API returned error: ${data['message']}');
        }
      } else {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      print('❌ Error in _fetchAndSaveBotState: $e');
      rethrow;
    }
  }

  // Save bot state to SharedPreferences (replicates subbinMode._saveBotState)
  Future<void> _saveBotStateToPrefs(Map<String, dynamic> botData, String symbol) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get the current risk level settings to populate trade settings
      Map<String, dynamic> currentSettings = {};
      if (selectedPair.isNotEmpty && selectedPair['settings'] != null) {
        currentSettings = selectedPair['settings'];
        print('📋 Using risk level settings: $currentSettings');
      } else {
        print('⚠️ No risk level settings found, using defaults');
      }

      // Create bot state object (same structure as subbinMode)
      final botState = {
        'id': botData['id'],
        'isActive': botData['status'] == "1",
        'userId': commonuserId,
        'exchangeType': exchanger,
        'assetType': symbol,
        'positionAmount': botData['pos_amt'] ?? "0",
        'avgPrice': botData['avg_price'] ?? "0",
        'numberOfMarginCalls': int.parse(botData['no_margincall'] ?? "0"),
        'lastAVGPrice': double.parse(botData['last_avgprice'] ?? "0"),
        'currentPrice': "0", // Will be updated by background service
        'status': int.parse(botData['status'] ?? "0"),
        'tradeSettings': {
          'marginCallsEnabled': botData['stock_margin'] == "1",
          'marginCallLimit': currentSettings['margin_call_limit'] ?? "10",
          'marginCallDrop': double.parse(botData['margin_calldrop'] ?? currentSettings['margin_drop_1'] ?? "5"),
          'takeProfit': double.parse(botData['wp_rasio'] ?? currentSettings['wp_profit'] ?? "3"),
          'earningCallback': currentSettings['wp_callback'] ?? "1",
          'positionDoubling': currentSettings['martin_config'] == true,
          'firstBuyAmount': currentSettings['first_buy'] ?? "100", // CRITICAL: Add first buy amount
          'buyInCallback': currentSettings['by_callback'] ?? "1",
        }
      };

      // Get existing bot states
      final existingStatesJson = prefs.getString('bot_states') ?? '[]';
      List<dynamic> existingStates = json.decode(existingStatesJson);

      // Remove any existing state for this bot
      existingStates.removeWhere((state) => state['id'] == botData['id']);

      // Add the new bot state if it's active
      if (botData['status'] == "1") {
        existingStates.add(botState);
        print("✅ Added active bot to states: $symbol");
      }

      // Save all states back to SharedPreferences
      await prefs.setString('bot_states', json.encode(existingStates));
      print("✅ Bot states saved successfully");
      print("📊 Total active bots: ${existingStates.where((state) => state['isActive'] == true).length}");

    } catch (e) {
      print("❌ Error saving bot state: $e");
      rethrow;
    }
  }

  void _showSuccessDialog(String symbol, bool activated) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2234),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2A3A5A)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              activated ? Icons.check_circle : Icons.info_outline,
              color: activated ? const Color(0xFF00C853) : const Color(0xFFE53935),
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              activated ? 'Auto Trading Activated' : 'Auto Trading Deactivated',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              activated
                  ? 'Auto trading for $symbol has been activated successfully.'
                  : 'Auto trading for $symbol has been deactivated.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF5C9CE6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2329),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B3139),
        title: const Text(
          'Auto Trading',
          style: TextStyle(color: Color(0xFFEAECEF)),
        ),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF0B90B)))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                      'Risk Level Overview',
                    style: TextStyle(
                        fontSize: 20,
                      fontWeight: FontWeight.bold,
                        color: Color(0xFFEAECEF),
                    ),
                  ),
                  const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 1,
                      childAspectRatio: 2.2,
                      mainAxisSpacing: 16,
                      children: adminSelectedPairs.map((riskLevel) {
                        Color cardColor;
                        Color accentColor;
                        IconData riskIcon;

                        switch (riskLevel['riskLevel']) {
                          case 'Low':
                            cardColor = const Color(0xFF2EBD85).withOpacity(0.1);
                            accentColor = const Color(0xFF2EBD85);
                            riskIcon = Icons.shield_outlined;
                            break;
                          case 'Medium':
                            cardColor = const Color(0xFFF0B90B).withOpacity(0.1);
                            accentColor = const Color(0xFFF0B90B);
                            riskIcon = Icons.trending_up;
                            break;
                          case 'High':
                            cardColor = const Color(0xFFF6465D).withOpacity(0.1);
                            accentColor = const Color(0xFFF6465D);
                            riskIcon = Icons.local_fire_department_outlined;
                            break;
                          default:
                            cardColor = const Color(0xFF2B3139);
                            accentColor = const Color(0xFFEAECEF);
                            riskIcon = Icons.help_outline;
                        }

                                return Container(
                                  decoration: BoxDecoration(
                            color: cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                              color: accentColor.withOpacity(0.3),
                              width: 1,
                                    ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _toggleAutoTrading(riskLevel['riskLevel']),
                              child: Padding(
                                // padding: EdgeInsets.all(16),
                                padding: const EdgeInsets.only( left: 16,right: 16,top: 10),
                                  child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                        Row(
                                          children: [
                                            Icon(
                                              riskIcon,
                                              color: accentColor,
                                              size: 24,
                                              ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${riskLevel['riskLevel']} Risk',
                                              style: const TextStyle(
                                                color: Color(0xFFEAECEF),
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                            (loadingTradingPairs[riskLevel['riskLevel']] ?? false)
                                                ? SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                                    ),
                                                  )
                                                : Switch(
                                                    value: activeTradingPairs[riskLevel['riskLevel']] ?? false,
                                                    onChanged: (loadingTradingPairs[riskLevel['riskLevel']] ?? false)
                                                        ? null
                                                        : (value) => _toggleAutoTrading(riskLevel['riskLevel']),
                                                    activeColor: accentColor,
                                                  ),
                                          ],
                                        ),
                                    const SizedBox(height: 5),
                                            Text(
                                              riskLevel['description'],
                                              style: TextStyle(
                                        color: const Color(0xFFEAECEF).withOpacity(0.7),
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                        _buildStat('Pairs', '${riskLevel['totalPairs']}', accentColor),
                                        _buildStat('Volume', '\$${riskLevel['totalVolume']}', accentColor),
                                        _buildStat('Return', riskLevel['avgReturn'], accentColor),
                                                  ],
                                                ),
                                          ],
                                        ),
                                      ),
        ),
      ),
    );
                      }).toList(),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
            color: const Color(0xFFEAECEF).withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
            color: Color(0xFFEAECEF),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
    );
  }

  Future<void> _syncActiveTradingPairsWithBotStates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final botStatesJson = prefs.getString('bot_states');
      if (botStatesJson == null) return;
      final List<dynamic> botStates = json.decode(botStatesJson);
      // For each risk level, check if all bots for its pairs are active
      for (var riskLevel in adminSelectedPairs) {
        bool isActive = riskLevel['pairs'].isNotEmpty &&
          riskLevel['pairs'].every((pair) =>
            botStates.any((b) =>
              (b['assetType'] == pair['symbol'].replaceAll('/', '')) && b['isActive'] == true
            )
          );
        setState(() {
          activeTradingPairs[riskLevel['riskLevel']] = isActive;
        });
      }
    } catch (e) {
      print('Error syncing active trading pairs: $e');
    }
  }
}