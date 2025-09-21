import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:crypto/crypto.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;

class BybitService {
  static final BybitService _instance = BybitService._internal();
  factory BybitService() => _instance;
  BybitService._internal();

  static const String _apiKey = 'QQMtehmj1EYe71ggUH';
  static const String _secretKey = 'ZZW0V0mcIpxtiwRn0vPjqT14AalsvUbebqNU';
  static const String _baseUrl = 'https://api.bybit.com';
  static const String _wsUrl = 'wss://stream.bybit.com/v5/public/spot';

  WebSocketChannel? _wsChannel;
  WebSocketChannel? _orderBookChannel;

  final StreamController<Map<String, dynamic>> _tickerController = StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _orderBookController = StreamController.broadcast();
  final StreamController<List<Map<String, dynamic>>> _tradeHistoryController = StreamController.broadcast();
  final StreamController<List<Map<String, dynamic>>> _buyOrdersController = StreamController.broadcast();
  final StreamController<List<Map<String, dynamic>>> _sellOrdersController = StreamController.broadcast();

  Map<String, dynamic> _cachedTickers = {};
  Map<String, Map<String, dynamic>> _cachedOrderBooks = {};
  List<Map<String, dynamic>> _tradeHistory = [];
  List<Map<String, dynamic>> _buyOrders = [];
  List<Map<String, dynamic>> _sellOrders = [];

  Stream<Map<String, dynamic>> get tickerStream => _tickerController.stream;
  Stream<Map<String, dynamic>> get orderBookStream => _orderBookController.stream;
  Stream<List<Map<String, dynamic>>> get tradeHistoryStream => _tradeHistoryController.stream;
  Stream<List<Map<String, dynamic>>> get buyOrdersStream => _buyOrdersController.stream;
  Stream<List<Map<String, dynamic>>> get sellOrdersStream => _sellOrdersController.stream;

  Map<String, dynamic> get cachedTickers => _cachedTickers;
  List<Map<String, dynamic>> get tradeHistory => _tradeHistory;
  List<Map<String, dynamic>> get buyOrders => _buyOrders;
  List<Map<String, dynamic>> get sellOrders => _sellOrders;

  String _generateSignature(String queryString, int timestamp) {
    final message = '$timestamp$_apiKey$queryString';
    final key = utf8.encode(_secretKey);
    final bytes = utf8.encode(message);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString();
  }

  Future<void> startLiveData() async {
    try {
      await _connectToBybitWebSocket();
      await _fetchInitialData();
      await _fetchTradeHistory();
      await _fetchOpenOrders();
    } catch (e) {
    }
  }

  Future<void> _connectToBybitWebSocket() async {
    try {
      if (kIsWeb) {
        _startRestApiPolling();
        return;
      }

      _wsChannel = IOWebSocketChannel.connect(_wsUrl);

      final subscribeMessage = {
        'op': 'subscribe',
        'args': ['tickers.BTCUSDT']
      };
      
      _wsChannel!.sink.add(jsonEncode(subscribeMessage));
      
      _wsChannel!.stream.listen(
        (data) {
          try {
            final jsonData = jsonDecode(data);
            if (jsonData['topic'] == 'tickers.BTCUSDT') {
              _processBybitTickerData(jsonData['data']);
            }
          } catch (e) {
          }
        },
        onError: (error) {
          _reconnectBybit();
        },
        onDone: () {
          _reconnectBybit();
        },
      );
    } catch (e) {
    }
  }

  void _startRestApiPolling() {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        await _fetchBybitTickerData();
      } catch (e) {
      }
    });
  }

  Future<void> _fetchBybitTickerData() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.bybit.com/v5/market/tickers?category=spot&symbol=BTCUSDT'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null && data['result']['list'] != null && data['result']['list'].isNotEmpty) {
          final tickerData = data['result']['list'][0];
          _processBybitTickerData(tickerData);
        }
      }
    } catch (e) {
    }
  }

  void _processBybitTickerData(Map<String, dynamic> data) {
    final tickerData = {
      'symbol': data['symbol'] ?? 'BTCUSDT',
      'lastPrice': data['lastPrice'] ?? '0',
      'price': data['lastPrice'] ?? '0',
      'priceChangePercent': data['price24hPcnt'] ?? '0',
      'priceChange': data['price24hPcnt'] ?? '0',
      'volume': data['volume24h'] ?? '0',
      'high': data['highPrice24h'] ?? '0',
      'low': data['lowPrice24h'] ?? '0',
      'exchange': 'Bybit',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    _cachedTickers['BTCUSDT'] = tickerData;
    _tickerController.add({data['symbol'] ?? 'BTCUSDT': tickerData});
  }

  Future<void> _fetchInitialData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v5/market/tickers?category=spot&symbol=BTCUSDT'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null && data['result']['list'] != null) {
          final tickerList = data['result']['list'] as List;
          if (tickerList.isNotEmpty) {
            _processBybitTickerData(tickerList[0]);
          }
        }
      }
    } catch (e) {
    }
  }

  // Fetch trade history
  Future<void> _fetchTradeHistory() async {
    try {

    } catch (e) {

    }
  }

  Future<void> _fetchOpenOrders() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final queryString = 'category=spot&symbol=BTCUSDT&openOnly=0&limit=50';
      final signature = _generateSignature(queryString, timestamp);
      
      final response = await http.get(
        Uri.parse('$_baseUrl/v5/order/history?$queryString'),
        headers: {
          'X-BAPI-API-KEY': _apiKey,
          'X-BAPI-SIGN': signature,
          'X-BAPI-SIGN-TYPE': '2',
          'X-BAPI-TIMESTAMP': timestamp.toString(),
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null && data['result']['list'] != null) {
          final orders = data['result']['list'] as List;
          
          _buyOrders = orders.where((order) => order['side'] == 'Buy').map((order) => {
            'pair': order['symbol'] ?? 'BTCUSDT',
            'price': order['price'] ?? '0',
            'amount': order['qty'] ?? '0',
            'status': order['orderStatus'] ?? 'Unknown',
          }).toList();
          
          _sellOrders = orders.where((order) => order['side'] == 'Sell').map((order) => {
            'pair': order['symbol'] ?? 'BTCUSDT',
            'price': order['price'] ?? '0',
            'amount': order['qty'] ?? '0',
            'status': order['orderStatus'] ?? 'Unknown',
          }).toList();
          
          _buyOrdersController.add(_buyOrders);
          _sellOrdersController.add(_sellOrders);
        }
      }
    } catch (e) {
    }
  }

  void _reconnectBybit() {
    Timer(const Duration(seconds: 5), () {
      _connectToBybitWebSocket();
    });
  }

  void dispose() {
    _wsChannel?.sink.close();
    _orderBookChannel?.sink.close();
    _tickerController.close();
    _orderBookController.close();
    _tradeHistoryController.close();
    _buyOrdersController.close();
    _sellOrdersController.close();
  }
}
