import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;

class LiveTradingService {
  static final LiveTradingService _instance = LiveTradingService._internal();
  factory LiveTradingService() => _instance;
  LiveTradingService._internal();

  // WebSocket connections for different exchanges
  WebSocketChannel? _binanceChannel;
  WebSocketChannel? _binanceDepthChannel;
  WebSocketChannel? _kucoinChannel;
  WebSocketChannel? _coinbaseChannel;
  WebSocketChannel? _okxChannel;
  
  // Data streams
  final StreamController<Map<String, dynamic>> _tickerController = StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _orderBookController = StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _tradeController = StreamController.broadcast();
  
  // Cached data
  Map<String, dynamic> _cachedTickers = {};
  Map<String, Map<String, dynamic>> _cachedOrderBooks = {};
  List<Map<String, dynamic>> _recentTrades = [];
  
  // Exchange configurations
  final Map<String, ExchangeConfig> _exchangeConfigs = {
    'Binance': ExchangeConfig(
      name: 'Binance',
      wsUrl: 'wss://stream.binance.com:9443/ws',
      restUrl: 'https://api.binance.com/api/v3',
      supportedPairs: ['BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'ADAUSDT', 'XRPUSDT', 'SOLUSDT', 'DOTUSDT', 'DOGEUSDT', 'AVAXUSDT', 'MATICUSDT'],
    ),
    'KuCoin': ExchangeConfig(
      name: 'KuCoin',
      wsUrl: 'wss://ws-api.kucoin.com/endpoint',
      restUrl: 'https://api.kucoin.com/api/v1',
      supportedPairs: ['BTC-USDT', 'ETH-USDT', 'KCS-USDT', 'ADA-USDT', 'XRP-USDT', 'SOL-USDT', 'DOT-USDT', 'DOGE-USDT', 'AVAX-USDT', 'MATIC-USDT'],
    ),
    'Coinbase': ExchangeConfig(
      name: 'Coinbase',
      wsUrl: 'wss://ws-feed.pro.coinbase.com',
      restUrl: 'https://api.pro.coinbase.com',
      supportedPairs: ['BTC-USD', 'ETH-USD', 'ADA-USD', 'XRP-USD', 'SOL-USD', 'DOT-USD', 'DOGE-USD', 'AVAX-USD', 'MATIC-USD'],
    ),
    'Crypto.com': ExchangeConfig(
      name: 'Crypto.com',
      wsUrl: 'wss://stream.crypto.com/v2/market',
      restUrl: 'https://api.crypto.com/v2',
      supportedPairs: ['BTC_USDT', 'ETH_USDT', 'CRO_USDT', 'ADA_USDT', 'XRP_USDT', 'SOL_USDT', 'DOT_USDT', 'DOGE_USDT', 'AVAX_USDT', 'MATIC_USDT'],
    ),
    'OKX': ExchangeConfig(
      name: 'OKX',
      wsUrl: 'wss://ws.okx.com:8443/ws/v5/public',
      restUrl: 'https://www.okx.com/api/v5',
      supportedPairs: ['BTC-USDT', 'ETH-USDT', 'OKB-USDT', 'ADA-USDT', 'XRP-USDT', 'SOL-USDT', 'DOT-USDT', 'DOGE-USDT', 'AVAX-USDT', 'MATIC-USDT'],
    ),
  };

  // Getters for streams
  Stream<Map<String, dynamic>> get tickerStream => _tickerController.stream;
  Stream<Map<String, dynamic>> get orderBookStream => _orderBookController.stream;
  Stream<Map<String, dynamic>> get tradeStream => _tradeController.stream;

  // Get cached data
  Map<String, dynamic> get cachedTickers => _cachedTickers;
  Map<String, Map<String, dynamic>> get cachedOrderBooks => _cachedOrderBooks;
  List<Map<String, dynamic>> get recentTrades => _recentTrades;

  // Get exchange configurations
  Map<String, ExchangeConfig> get exchangeConfigs => _exchangeConfigs;

  Future<void> startLiveData({String exchange = 'Binance'}) async {
    try {
      switch (exchange) {
        case 'Binance':
          await _connectToBinance();
          break;
        case 'KuCoin':
          await _connectToKuCoin();
          break;
        case 'Coinbase':
          await _connectToCoinbase();
          break;
        case 'OKX':
          await _connectToOKX();
          break;
        default:
          await _connectToBinance();
      }
      await _fetchInitialData(exchange);
    } catch (e) {
      print('Error starting live data: $e');
    }
  }

  Future<void> _connectToBinance() async {
    try {
      print('🔄 Connecting to Binance WebSocket...');

      // Connect to Binance ticker stream
      _binanceChannel = IOWebSocketChannel.connect(
        'wss://stream.binance.com:9443/ws/!ticker@arr',
      );

      _binanceChannel!.stream.listen(
        (data) {
          try {
            final jsonData = jsonDecode(data);
            if (jsonData is List) {
              print('📊 Received ${jsonData.length} ticker updates from Binance');
              _processBinanceTickerData(jsonData);
            }
          } catch (e) {
            print('❌ Error processing Binance ticker data: $e');
          }
        },
        onError: (error) {
          print('❌ Binance WebSocket error: $error');
          _reconnectBinance();
        },
        onDone: () {
          print('🔌 Binance WebSocket connection closed');
          _reconnectBinance();
        },
      );

      print('✅ Connected to Binance WebSocket');
    } catch (e) {
      print('❌ Error connecting to Binance: $e');
    }
  }

  void _processBinanceTickerData(List<dynamic> data) {
    final Map<String, dynamic> processedData = {};
    int usdtPairs = 0;

    for (var item in data) {
      if (item['s'] != null && item['s'].toString().endsWith('USDT')) {
        final symbol = item['s'].toString();
        usdtPairs++;

        processedData[symbol] = {
          'symbol': symbol,
          'lastPrice': item['c'] ?? '0',
          'price': item['c'] ?? '0',
          'priceChangePercent': item['P'] ?? '0',
          'priceChange': item['P'] ?? '0',
          'volume': item['v'] ?? '0',
          'quoteVolume': item['q'] ?? '0',
          'high': item['h'] ?? '0',
          'low': item['l'] ?? '0',
          'exchange': 'Binance',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
      }
    }

    print('📈 Processed $usdtPairs USDT pairs from ${data.length} total tickers');

    if (processedData.isNotEmpty) {
      _cachedTickers.addAll(processedData);
      _tickerController.add(processedData);
      print('✅ Sent ${processedData.length} ticker updates to UI');
    }
  }

  void _processKuCoinTickerData(Map<String, dynamic> data) {
    if (data['type'] == 'message' && data['topic'] == '/market/ticker:all') {
      final tickerData = data['data'];
      if (tickerData != null) {
        final symbol = tickerData['symbol']?.toString() ?? '';
        if (symbol.endsWith('-USDT')) {
          final processedData = {
            symbol: {
              'symbol': symbol,
              'lastPrice': tickerData['price'] ?? '0',
              'price': tickerData['price'] ?? '0',
              'priceChangePercent': tickerData['changeRate'] ?? '0',
              'priceChange': tickerData['changeRate'] ?? '0',
              'volume': tickerData['vol'] ?? '0',
              'quoteVolume': tickerData['volValue'] ?? '0',
              'high': tickerData['high'] ?? '0',
              'low': tickerData['low'] ?? '0',
              'exchange': 'KuCoin',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            }
          };

          _cachedTickers.addAll(processedData);
          _tickerController.add(processedData);
        }
      }
    }
  }

  void _processCoinbaseTickerData(Map<String, dynamic> data) {
    if (data['type'] == 'ticker') {
      final symbol = data['product_id']?.toString() ?? '';
      final processedData = {
        symbol: {
          'symbol': symbol,
          'price': data['price'] ?? '0',
          'priceChange': '0', // Coinbase doesn't provide 24h change in ticker
          'volume': data['volume_24h'] ?? '0',
          'high': data['high_24h'] ?? '0',
          'low': data['low_24h'] ?? '0',
          'exchange': 'Coinbase',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }
      };

      _cachedTickers.addAll(processedData);
      _tickerController.add(processedData);
    }
  }

  void _processOKXTickerData(Map<String, dynamic> data) {
    if (data['arg'] != null && data['data'] != null) {
      final List<dynamic> tickerList = data['data'];
      final Map<String, dynamic> processedData = {};

      for (var ticker in tickerList) {
        final symbol = ticker['instId']?.toString() ?? '';
        processedData[symbol] = {
          'symbol': symbol,
          'price': ticker['last'] ?? '0',
          'priceChange': ticker['chgUtc0'] ?? '0',
          'volume': ticker['vol24h'] ?? '0',
          'high': ticker['high24h'] ?? '0',
          'low': ticker['low24h'] ?? '0',
          'exchange': 'OKX',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
      }

      _cachedTickers.addAll(processedData);
      _tickerController.add(processedData);
    }
  }

  Future<void> connectToOrderBook(String symbol, {String exchange = 'Binance'}) async {
    try {
      if (exchange == 'Binance') {
        await _connectToBinanceOrderBook(symbol);
      }
    } catch (e) {
      print('Error connecting to order book: $e');
    }
  }

  Future<void> _connectToBinanceOrderBook(String symbol) async {
    try {
      final lowerSymbol = symbol.toLowerCase();
      _binanceDepthChannel = IOWebSocketChannel.connect(
        'wss://stream.binance.com:9443/ws/${lowerSymbol}@depth20@100ms',
      );

      _binanceDepthChannel!.stream.listen(
        (data) {
          try {
            final jsonData = jsonDecode(data);
            _processBinanceOrderBookData(jsonData, symbol);
          } catch (e) {
            print('Error processing order book data: $e');
          }
        },
        onError: (error) {
          print('Order book WebSocket error: $error');
        },
      );

      print('Connected to Binance order book for $symbol');
    } catch (e) {
      print('Error connecting to Binance order book: $e');
    }
  }

  void _processBinanceOrderBookData(Map<String, dynamic> data, String symbol) {
    final orderBookData = {
      'symbol': symbol,
      'exchange': 'Binance',
      'bids': data['bids'] ?? [],
      'asks': data['asks'] ?? [],
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    _cachedOrderBooks[symbol] = orderBookData;
    _orderBookController.add(orderBookData);
  }

  Future<void> _fetchInitialData([String exchange = 'Binance']) async {
    try {
      // Fetch initial ticker data from Binance REST API
      final response = await http.get(
        Uri.parse('https://api.binance.com/api/v3/ticker/24hr'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic> processedData = {};
        
        for (var item in data) {
          if (item['symbol'] != null && item['symbol'].toString().endsWith('USDT')) {
            final symbol = item['symbol'].toString();
            processedData[symbol] = {
              'symbol': symbol,
              'lastPrice': item['lastPrice'] ?? '0',
              'price': item['lastPrice'] ?? '0',
              'priceChangePercent': item['priceChangePercent'] ?? '0',
              'priceChange': item['priceChangePercent'] ?? '0',
              'volume': item['volume'] ?? '0',
              'quoteVolume': item['quoteVolume'] ?? '0',
              'high': item['highPrice'] ?? '0',
              'low': item['lowPrice'] ?? '0',
              'exchange': 'Binance',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            };
          }
        }

        print('🚀 Initial data loaded: ${processedData.length} USDT pairs');
        _cachedTickers = processedData;
        _tickerController.add(processedData);
        print('✅ Initial data sent to UI');
      }
    } catch (e) {
      print('Error fetching initial data: $e');
    }
  }

  void _reconnectBinance() {
    Timer(const Duration(seconds: 5), () {
      _connectToBinance();
    });
  }

  Future<void> _connectToKuCoin() async {
    try {
      // KuCoin requires token-based WebSocket connection
      final tokenResponse = await http.post(
        Uri.parse('https://api.kucoin.com/api/v1/bullet-public'),
        headers: {'Content-Type': 'application/json'},
      );

      if (tokenResponse.statusCode == 200) {
        final tokenData = jsonDecode(tokenResponse.body);
        final token = tokenData['data']['token'];
        final endpoint = tokenData['data']['instanceServers'][0]['endpoint'];

        _kucoinChannel = IOWebSocketChannel.connect(
          '$endpoint?token=$token&[connectId=1]',
        );

        // Subscribe to ticker data
        _kucoinChannel!.sink.add(jsonEncode({
          'id': '1',
          'type': 'subscribe',
          'topic': '/market/ticker:all',
          'response': true,
        }));

        _kucoinChannel!.stream.listen(
          (data) {
            try {
              final jsonData = jsonDecode(data);
              _processKuCoinTickerData(jsonData);
            } catch (e) {
              print('Error processing KuCoin data: $e');
            }
          },
          onError: (error) => print('KuCoin WebSocket error: $error'),
        );

        print('Connected to KuCoin WebSocket');
      }
    } catch (e) {
      print('Error connecting to KuCoin: $e');
    }
  }

  Future<void> _connectToCoinbase() async {
    try {
      _coinbaseChannel = IOWebSocketChannel.connect(
        'wss://ws-feed.pro.coinbase.com',
      );

      // Subscribe to ticker data
      _coinbaseChannel!.sink.add(jsonEncode({
        'type': 'subscribe',
        'product_ids': ['BTC-USD', 'ETH-USD', 'ADA-USD', 'XRP-USD'],
        'channels': ['ticker'],
      }));

      _coinbaseChannel!.stream.listen(
        (data) {
          try {
            final jsonData = jsonDecode(data);
            _processCoinbaseTickerData(jsonData);
          } catch (e) {
            print('Error processing Coinbase data: $e');
          }
        },
        onError: (error) => print('Coinbase WebSocket error: $error'),
      );

      print('Connected to Coinbase WebSocket');
    } catch (e) {
      print('Error connecting to Coinbase: $e');
    }
  }

  Future<void> _connectToOKX() async {
    try {
      _okxChannel = IOWebSocketChannel.connect(
        'wss://ws.okx.com:8443/ws/v5/public',
      );

      // Subscribe to ticker data
      _okxChannel!.sink.add(jsonEncode({
        'op': 'subscribe',
        'args': [
          {'channel': 'tickers', 'instId': 'BTC-USDT'},
          {'channel': 'tickers', 'instId': 'ETH-USDT'},
          {'channel': 'tickers', 'instId': 'ADA-USDT'},
        ],
      }));

      _okxChannel!.stream.listen(
        (data) {
          try {
            final jsonData = jsonDecode(data);
            _processOKXTickerData(jsonData);
          } catch (e) {
            print('Error processing OKX data: $e');
          }
        },
        onError: (error) => print('OKX WebSocket error: $error'),
      );

      print('Connected to OKX WebSocket');
    } catch (e) {
      print('Error connecting to OKX: $e');
    }
  }

  List<String> getExchangePairs(String exchange) {
    return _exchangeConfigs[exchange]?.supportedPairs ?? [];
  }

  String formatPairForExchange(String basePair, String exchange) {
    switch (exchange) {
      case 'Binance':
        return basePair.replaceAll('-', '').replaceAll('_', '');
      case 'KuCoin':
      case 'Coinbase':
      case 'OKX':
        if (basePair.contains('-')) {
          return basePair; // Already formatted
        }
        if (basePair.endsWith('USDT')) {
          return basePair.replaceAll('USDT', '') + '-USDT';
        } else if (basePair.endsWith('USD')) {
          return basePair.replaceAll('USD', '') + '-USD';
        }
        return basePair;
      case 'Crypto.com':
        if (basePair.contains('_')) {
          return basePair; // Already formatted
        }
        if (basePair.endsWith('USDT')) {
          return basePair.replaceAll('USDT', '') + '_USDT';
        }
        return basePair.replaceAll('-', '_');
      default:
        return basePair;
    }
  }

  void dispose() {
    _binanceChannel?.sink.close();
    _binanceDepthChannel?.sink.close();
    _kucoinChannel?.sink.close();
    _coinbaseChannel?.sink.close();
    _okxChannel?.sink.close();
    _tickerController.close();
    _orderBookController.close();
    _tradeController.close();
  }
}

class ExchangeConfig {
  final String name;
  final String wsUrl;
  final String restUrl;
  final List<String> supportedPairs;

  ExchangeConfig({
    required this.name,
    required this.wsUrl,
    required this.restUrl,
    required this.supportedPairs,
  });
}
