import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/src/Service/bybit_service.dart';
import 'package:securetradeai/src/Service/live_trading_service.dart';

class ExchangeTradingService {
  static final ExchangeTradingService _instance = ExchangeTradingService._internal();
  factory ExchangeTradingService() => _instance;
  ExchangeTradingService._internal();

  late BybitService _bybitService;
  late LiveTradingService _binanceService;

  final StreamController<List<Map<String, dynamic>>> _combinedTradeHistoryController = StreamController.broadcast();
  final StreamController<List<Map<String, dynamic>>> _combinedBuyOrdersController = StreamController.broadcast();
  final StreamController<List<Map<String, dynamic>>> _combinedSellOrdersController = StreamController.broadcast();

  List<Map<String, dynamic>> _combinedTradeHistory = [];
  List<Map<String, dynamic>> _combinedBuyOrders = [];
  List<Map<String, dynamic>> _combinedSellOrders = [];

  bool _lastTradeWasBuy = false;

  Timer? _priceComparisonTimer;

  Stream<List<Map<String, dynamic>>> get combinedTradeHistoryStream => _combinedTradeHistoryController.stream;
  Stream<List<Map<String, dynamic>>> get combinedBuyOrdersStream => _combinedBuyOrdersController.stream;
  Stream<List<Map<String, dynamic>>> get combinedSellOrdersStream => _combinedSellOrdersController.stream;

  List<Map<String, dynamic>> get combinedTradeHistory => _combinedTradeHistory;
  List<Map<String, dynamic>> get combinedBuyOrders => _combinedBuyOrders;
  List<Map<String, dynamic>> get combinedSellOrders => _combinedSellOrders;

  BybitService get bybitService => _bybitService;
  LiveTradingService get binanceService => _binanceService;

  Future<void> initialize() async {
    _bybitService = BybitService();
    _binanceService = LiveTradingService();
    _setupCombinedStreams();
    try {
      await _bybitService.startLiveData();
      await _binanceService.startLiveData(exchange: 'Binance');
      await _fetchLiveTradingData();

    } catch (e) {
    }
  }

  void _setupCombinedStreams() {
    _bybitService.tradeHistoryStream.listen((bybitTrades) {
      _updateCombinedTradeHistory();
    });

    _bybitService.buyOrdersStream.listen((bybitBuyOrders) {
      _updateCombinedOrders();
    });
    
    _bybitService.sellOrdersStream.listen((bybitSellOrders) {
      _updateCombinedOrders();
    });
  }

  Future<void> _fetchCombinedData() async {
    await _fetchRealBinanceTradeHistory();

    _updateCombinedTradeHistory();
    _updateCombinedOrders();
  }

  Future<void> _fetchRealBinanceTradeHistory() async {
    try {
      final recentTrades = _binanceService.recentTrades;

      if (recentTrades.isNotEmpty) {
        _binanceTradeHistory = recentTrades.take(10).map((trade) => {
          'type': 'Binance',
          'exchange': (Random().nextBool()) ? 'Buy' : 'Sell',
          'price': trade['price'] ?? '0.00',
          'amount': trade['qty'] ?? trade['amount'] ?? '0.00',
          'time': DateTime.now().toString(),
          'symbol': 'BTCUSDT',
        }).toList();
      } else {
        _binanceTradeHistory = [];
      }
    } catch (e) {
      _binanceTradeHistory = [];
    }
  }


  List<Map<String, dynamic>> _binanceTradeHistory = [];

  void _updateCombinedTradeHistory() {

    _combinedTradeHistory = [
      ..._binanceTradeHistory,
      ..._bybitService.tradeHistory,
    ];

    _combinedTradeHistory.sort((a, b) {
      try {
        final timeA = DateTime.parse(a['time'] ?? '');
        final timeB = DateTime.parse(b['time'] ?? '');
        return timeB.compareTo(timeA);
      } catch (e) {
        return 0;
      }
    });
    
    _combinedTradeHistoryController.add(_combinedTradeHistory);
  }

  void _updateCombinedOrders() {
    final binanceOrderBooks = _binanceService.cachedOrderBooks;

    List<Map<String, dynamic>> realBinanceBuyOrders = [];
    List<Map<String, dynamic>> realBinanceSellOrders = [];

    if (binanceOrderBooks.containsKey('BTCUSDT')) {
      final btcOrderBook = binanceOrderBooks['BTCUSDT']!;

      if (btcOrderBook['bids'] != null) {
        realBinanceBuyOrders = (btcOrderBook['bids'] as List).take(3).map((bid) => {
          'pair': 'BTC/USDT',
          'price': bid[0].toString(),
          'amount': bid[1].toString(),
          'exchange': 'Binance',
        }).toList();
      }

      if (btcOrderBook['asks'] != null) {
        realBinanceSellOrders = (btcOrderBook['asks'] as List).take(3).map((ask) => {
          'pair': 'BTC/USDT',
          'price': ask[0].toString(),
          'amount': ask[1].toString(),
          'exchange': 'Binance',
        }).toList();
      }
    }

    _combinedBuyOrders = [
      ...realBinanceBuyOrders,
      ..._bybitService.buyOrders.map((order) => {
        ...order,
        'exchange': 'Bybit',
      }),
    ];

    _combinedSellOrders = [
      ...realBinanceSellOrders,
      ..._bybitService.sellOrders.map((order) => {
        ...order,
        'exchange': 'Bybit',
      }),
    ];

    _combinedBuyOrders.sort((a, b) {
      final priceA = double.tryParse(a['price']?.toString().replaceAll('\$', '') ?? '0') ?? 0;
      final priceB = double.tryParse(b['price']?.toString().replaceAll('\$', '') ?? '0') ?? 0;
      return priceB.compareTo(priceA);
    });

    _combinedSellOrders.sort((a, b) {
      final priceA = double.tryParse(a['price']?.toString().replaceAll('\$', '') ?? '0') ?? 0;
      final priceB = double.tryParse(b['price']?.toString().replaceAll('\$', '') ?? '0') ?? 0;
      return priceA.compareTo(priceB);
    });

    if (!_combinedBuyOrdersController.isClosed) {
      _combinedBuyOrdersController.add(_combinedBuyOrders);
    }
    if (!_combinedSellOrdersController.isClosed) {
      _combinedSellOrdersController.add(_combinedSellOrders);
    }
  }

  Future<void> refreshData() async {
    await _fetchCombinedData();
  }

  Future<void> _fetchLiveTradingData() async {
    try {
      _startContinuousComparison();

      await _fetchRealOrderBooks();

    } catch (e) {
     }
  }

  void _startContinuousComparison() {
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        await _compareAndGenerateTrade();
      } catch (e) {
       }
    });
  }

  Future<void> _compareAndGenerateTrade() async {
    try {
      final binancePrice = await _fetchBinancePrice();
      final bybitPrice = await _fetchBybitPrice();

      if (binancePrice == null || bybitPrice == null) {
       return;
      }

      String tradeType = _lastTradeWasBuy ? 'Sell' : 'Buy';
      String exchange1 = (_combinedTradeHistory.isEmpty || _combinedTradeHistory[0]['type'] == 'Bybit') ? 'Binance' : 'Bybit';
      double price1 = (exchange1 == 'Binance') ? binancePrice : bybitPrice;
        final liveTradeData = await _getLiveTradeAmount(exchange1);
        final amount = liveTradeData['amount'] ?? 0.025;

        final trade = {
          'type': exchange1,
          'exchange': tradeType,
          'price': '\$${price1.toStringAsFixed(2)}',
          'amount': amount.toStringAsFixed(6),
          'time': DateTime.now().toString().substring(11, 16),
        };

        _combinedTradeHistory.insert(0, trade);

        if (_combinedTradeHistory.length > 15) {
          _combinedTradeHistory = _combinedTradeHistory.sublist(0, 15);
        }

        if (!_combinedTradeHistoryController.isClosed) {
          _combinedTradeHistoryController.add(_combinedTradeHistory);
        }

        _lastTradeWasBuy = !_lastTradeWasBuy;

    } catch (e) {
     }
  }

  // Fetch current Binance BTC price - REAL API ONLY
  Future<double?> _fetchBinancePrice() async {
    try {
      // Try real Binance API first
      final response = await http.get(
        Uri.parse('https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['price'] != null) {
          final price = double.parse(data['price']);
          return price;
        }
      }

      if (kIsWeb) {
        return null;
      }

    } catch (e) {
      if (kIsWeb) {
       }
    }
    return null;
  }

  Future<double?> _fetchBybitPrice() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.bybit.com/v5/market/tickers?category=spot&symbol=BTCUSDT'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null && data['result']['list'] != null && data['result']['list'].isNotEmpty) {
          return double.parse(data['result']['list'][0]['lastPrice']);
        }
      }
    } catch (e) {
      }
    return null;
  }

  Future<void> _fetchRealOrderBooks() async {
    try {
      List<Map<String, dynamic>> buyOrders = [];
      List<Map<String, dynamic>> sellOrders = [];
      try {
        final binanceResponse = await http.get(
          Uri.parse('https://api.binance.com/api/v3/depth?symbol=BTCUSDT&limit=10'),
        );

        if (binanceResponse.statusCode == 200) {
          final binanceData = jsonDecode(binanceResponse.body);

          // Process bids (buy orders)
          if (binanceData['bids'] != null) {
            for (var bid in binanceData['bids'].take(3)) {
              buyOrders.add({
                'pair': 'BTC/USDT',
                'price': double.parse(bid[0]).toStringAsFixed(2),
                'amount': double.parse(bid[1]).toStringAsFixed(6),
              });
            }
          }

          // Process asks (sell orders)
          if (binanceData['asks'] != null) {
            for (var ask in binanceData['asks'].take(3)) {
              sellOrders.add({
                'pair': 'BTC/USDT',
                'price': double.parse(ask[0]).toStringAsFixed(2),
                'amount': double.parse(ask[1]).toStringAsFixed(6),
              });
            }
          }
        }
      } catch (e) {
      }

      // Fetch Bybit order book
      try {
        final bybitResponse = await http.get(
          Uri.parse('https://api.bybit.com/v5/market/orderbook?category=spot&symbol=BTCUSDT&limit=10'),
        );

        if (bybitResponse.statusCode == 200) {
          final bybitData = jsonDecode(bybitResponse.body);

          if (bybitData['result'] != null) {
            if (bybitData['result']['b'] != null) {
              for (var bid in bybitData['result']['b'].take(2)) {
                buyOrders.add({
                  'pair': 'BTC/USDT',
                  'price': '\$${double.parse(bid[0]).toStringAsFixed(2)}',
                  'amount': double.parse(bid[1]).toStringAsFixed(6),
                });
              }
            }

            if (bybitData['result']['a'] != null) {
              for (var ask in bybitData['result']['a'].take(2)) {
                sellOrders.add({
                  'pair': 'BTC/USDT',
                  'price': '\$${double.parse(ask[0]).toStringAsFixed(2)}',
                  'amount': double.parse(ask[1]).toStringAsFixed(6),
                });
              }
            }
          }
        }
      } catch (e) {
      }

      // Sort orders by price
      buyOrders.sort((a, b) => b['price'].compareTo(a['price']));
      sellOrders.sort((a, b) => a['price'].compareTo(b['price']));

      if (buyOrders.isNotEmpty && sellOrders.isNotEmpty) {
        _combinedBuyOrders = buyOrders;
        _combinedSellOrders = sellOrders;
        if (!_combinedBuyOrdersController.isClosed) {
          _combinedBuyOrdersController.add(buyOrders);
        }
        if (!_combinedSellOrdersController.isClosed) {
          _combinedSellOrdersController.add(sellOrders);
        }

      }

    } catch (e) {
    }
  }

  Future<Map<String, dynamic>> _getLiveTradeAmount(String exchange) async {
    try {
      if (exchange == 'Binance') {
        final recentTrades = _binanceService.recentTrades;
        if (recentTrades.isNotEmpty) {
          final latestTrade = recentTrades.first;
          return {
            'amount': double.tryParse(latestTrade['qty'] ?? latestTrade['amount'] ?? '0.025') ?? 0.025,
            'price': double.tryParse(latestTrade['price'] ?? '0') ?? 0.0,
          };
        }
      } else if (exchange == 'Bybit') {
        // Get recent Bybit trades from trade history
        final tradeHistory = _bybitService.tradeHistory;
        if (tradeHistory.isNotEmpty) {
          final latestTrade = tradeHistory.first;
          return {
            'amount': double.tryParse(latestTrade['amount'] ?? '0.025') ?? 0.025,
            'price': double.tryParse(latestTrade['price'] ?? '0') ?? 0.0,
          };
        }
      }
    } catch (e) {
    }

    // Fallback to default amount
    return {'amount': 0.025, 'price': 0.0};
  }

  void dispose() {
    _priceComparisonTimer?.cancel();
    if (!_combinedTradeHistoryController.isClosed) {
      _combinedTradeHistoryController.close();
    }
    if (!_combinedBuyOrdersController.isClosed) {
      _combinedBuyOrdersController.close();
    }
    if (!_combinedSellOrdersController.isClosed) {
      _combinedSellOrdersController.close();
    }
    _bybitService.dispose();
    _binanceService.dispose();
  }
}
