import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';
import 'package:securetradeai/src/widget/lottie_loading_widget.dart';
import 'package:securetradeai/src/Service/live_trading_service.dart';

class LiveTradingPage extends StatefulWidget {
  const LiveTradingPage({Key? key}) : super(key: key);

  @override
  _LiveTradingPageState createState() => _LiveTradingPageState();
}

class _LiveTradingPageState extends State<LiveTradingPage>
    with TickerProviderStateMixin {
  List<dynamic> _cryptoData = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  String _selectedExchange = 'Binance';
  List<Map<String, dynamic>> _orderBookData = [];
  late LiveTradingService _liveService;
  StreamSubscription? _tickerSubscription;
  StreamSubscription? _orderBookSubscription;
  bool _isLiveDataConnected = false;
  String _connectionStatus = 'Connecting...';

  @override
  void initState() {
    super.initState();
    _liveService = LiveTradingService();
    _initializeLiveData();
  }

  Future<void> _initializeLiveData() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'Connecting to live data...';
    });

    try {
      // Start live data connection
      await _liveService.startLiveData(exchange: _selectedExchange);

      // Subscribe to ticker updates - ONLY LIVE DATA
      _tickerSubscription = _liveService.tickerStream.listen((data) {
        if (mounted && data.isNotEmpty) {
          setState(() {
            _cryptoData = data.values.toList();
            _isLoading = false;
            _isLiveDataConnected = true;
            _connectionStatus = 'Live Data Connected';
          });
        }
      });

      _orderBookSubscription = _liveService.orderBookStream.listen((data) {
        if (mounted) {
          setState(() {
            _updateOrderBookFromLiveData(data);
          });
        }
      });

      // Wait for initial data, then connect to order book
      await Future.delayed(const Duration(seconds: 3));

      if (_cryptoData.isNotEmpty) {
        await _liveService.connectToOrderBook(_cryptoData[0]['symbol'], exchange: _selectedExchange);
      }
    } catch (e) {

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLiveDataConnected = false;
          _connectionStatus = 'Connection Failed';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Live data connection failed. Please check internet.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }











  void _updateOrderBookFromLiveData(Map<String, dynamic> data) {
    _orderBookData.clear();

    final bids = data['bids'] as List<dynamic>? ?? [];
    final asks = data['asks'] as List<dynamic>? ?? [];
    final symbol = data['symbol']?.toString() ?? 'BTCUSDT';

    for (var bid in bids.take(15)) {
      final price = double.tryParse(bid[0].toString()) ?? 0.0;
      final amount = double.tryParse(bid[1].toString()) ?? 0.0;

      _orderBookData.add({
        'type': 'buy',
        'price': price,
        'amount': amount,
        'total': price * amount,
        'pair': symbol,
        'exchange': data['exchange'] ?? _selectedExchange,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }

    for (var ask in asks.take(15)) {
      final price = double.tryParse(ask[0].toString()) ?? 0.0;
      final amount = double.tryParse(ask[1].toString()) ?? 0.0;

      _orderBookData.add({
        'type': 'sell',
        'price': price,
        'amount': amount,
        'total': price * amount,
        'pair': symbol,
        'exchange': data['exchange'] ?? _selectedExchange,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }

    _orderBookData.sort((a, b) {
      if (a['type'] == 'sell' && b['type'] == 'sell') {
        return a['price'].compareTo(b['price']);
      } else if (a['type'] == 'buy' && b['type'] == 'buy') {
        return b['price'].compareTo(a['price']);
      } else if (a['type'] == 'sell' && b['type'] == 'buy') {
        return -1;
      } else {
        return 1;
      }
    });
  }

  void _onPairSelected(String pair) async {
    print('🎯 PAIR SELECTED: $pair');
    print('🎯 Previous Selected Exchange: $_selectedExchange');

    setState(() {
      _selectedExchange = pair; // Set the selected pair as the active exchange
    });

    print('🎯 New Selected Exchange: $_selectedExchange');

    try {
      // Connect to order book for selected pair
      await _liveService.connectToOrderBook(pair, exchange: 'Binance');

      // Clear existing order book data and refresh
      _orderBookData.clear();

      print('🎯 Cleared order book data and starting fresh for: $pair');
    } catch (e) {
      print('Error switching to pair $pair: $e');
    }
  }

  void _onExchangeSelected(String exchangeName) async {
    setState(() {
      _selectedExchange = exchangeName;
    });

    // Restart live data for the new exchange
    try {
      await _liveService.startLiveData(exchange: exchangeName);
      if (_cryptoData.isNotEmpty) {
        await _liveService.connectToOrderBook(_cryptoData[0]['symbol'], exchange: exchangeName);
      }
    } catch (e) {
      print('Error switching exchange: $e');
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tickerSubscription?.cancel();
    _orderBookSubscription?.cancel();
    _liveService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: CommonAppBar.basic(
        title: "Live Trading",
      ),
      body: Stack(
        children: [
          _isLoading && _cryptoData.isEmpty
              ? const Center(
                  child: LottieLoadingWidget.fullScreen(
                    message: 'Loading Live Market Data...',
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Top status bar
                      _buildTopStatusBar(),
                      const SizedBox(height: 8),
                      // Trading Exchange Header (moved above coins)
                      _buildTradingExchangeHeader(),
                      const SizedBox(height: 8),
                      // Exchange tabs
                      // _buildExchangeTabs(),
                      // Market depth indicator
                      _buildMarketDepthIndicator(),
                      // Trading table with headers
                      _buildTradingInterface(),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildPriceTicker() {
    if (_cryptoData.isEmpty) {
      return Container(
        height: 40,
        color: const Color(0xFF0B0E11),
        child: const Center(
          child: Text(
            'Loading market data...',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      );
    }

    return Container(
      height: 40,
      color: const Color(0xFF0B0E11),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _getFilteredCryptoData().length,
        itemBuilder: (context, index) {
          final item = _getFilteredCryptoData()[index];
          final symbol = (item['symbol']?.toString() ?? 'N/A').replaceAll('USDT', '');
          final price = double.tryParse(item['lastPrice']?.toString() ?? '0') ?? 0.0;
          final change = double.tryParse(item['priceChangePercent']?.toString() ?? '0') ?? 0.0;
          final isPositive = change >= 0;

          return _buildMarqueeTickerItem(
            symbol,
            '\$${price.toStringAsFixed(3)}',
            '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%',
            isPositive,
            item,
          );
        },
      ),
    );
  }

  Widget _buildMarqueeTickerItem(String symbol, String price, String change,
      bool isPositive, dynamic item) {
    return GestureDetector(
      onTap: () {
        // Handle ticker item click
        _onTickerItemTap(symbol, item);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A1A),
              isPositive
                  ? const Color(0xFF00D4AA).withOpacity(0.1)
                  : const Color(0xFFFF6B6B).withOpacity(0.1),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPositive
                ? const Color(0xFF00D4AA).withOpacity(0.4)
                : const Color(0xFFFF6B6B).withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isPositive
                      ? const Color(0xFF00D4AA)
                      : const Color(0xFFFF6B6B))
                  .withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Symbol with enhanced styling
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF0B90B).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                symbol,
                style: const TextStyle(
                  color: Color(0xFFF0B90B),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Price
            Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            // Change with icon
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive
                      ? const Color(0xFF00D4AA)
                      : const Color(0xFFFF6B6B),
                  size: 12,
                ),
                const SizedBox(width: 2),
                Text(
                  change,
                  style: TextStyle(
                    color: isPositive
                        ? const Color(0xFF00D4AA)
                        : const Color(0xFFFF6B6B),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onTickerItemTap(String symbol, dynamic item) {
    // Show a bottom sheet or dialog with more details
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$symbol/USDT Details',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Price',
                '\$${double.parse(item['lastPrice']).toStringAsFixed(4)}'),
            _buildDetailRow('24h Change', '${item['priceChangePercent']}%'),
            _buildDetailRow('24h High',
                '\$${double.parse(item['highPrice']).toStringAsFixed(4)}'),
            _buildDetailRow('24h Low',
                '\$${double.parse(item['lowPrice']).toStringAsFixed(4)}'),
            _buildDetailRow('24h Volume',
                '${double.parse(item['volume']).toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0B90B),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStatusBar() {
    return Container(
      height: 60,
      color: const Color(0xFF1A1A1A),
      child: Row(
        children: [
          // Left side - Trading Index
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Trading Index',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4AA),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'BTC/USDT',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right side - Live indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D4AA),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D4AA).withOpacity(0.6),
                        spreadRadius: 2,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isLiveDataConnected ? 'LIVE DATA' : _connectionStatus.toUpperCase(),
                  style: TextStyle(
                    color: _isLiveDataConnected ? const Color(0xFF00D4AA) : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradingExchangeHeader() {
    return Container(
      height: 40,
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.trending_up,
            color: Color(0xFFF0B90B),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'TRADING EXCHANGES - $_selectedExchange',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF00D4AA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF00D4AA), width: 0.5),
            ),
            child: Text(
              '${_getAvailablePairsForExchange(_selectedExchange).length} pairs',
              style: const TextStyle(
                color: Color(0xFF00D4AA),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeTabs() {
    // Fixed list of popular trading pairs - always show these 8 pairs
    final allPairs = ['BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'ADAUSDT', 'SOLUSDT', 'XRPUSDT', 'DOGEUSDT', 'AVAXUSDT'];

    // Find pairs that have live buy/sell activity
    final activePairs = <String>{};
    for (var order in _orderBookData) {
      final pair = order['pair']?.toString();
      if (pair != null) {
        activePairs.add(pair);
      }
    }

    print('🎯 BUILDING EXCHANGE TABS - CHIPS FORMAT');
    print('🎯 Active Pairs with Buy/Sell: $activePairs');
    print('🎯 Order Book Data Count: ${_orderBookData.length}');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFF1E1E1E),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: allPairs.map<Widget>((pair) {
          final hasLiveActivity = activePairs.contains(pair);
          // Default first pair (BTCUSDT) is highlighted if no live activity
          final isActivePair = hasLiveActivity || (activePairs.isEmpty && pair == 'BTCUSDT');
          print('🎯 Building Chip - Pair: $pair, Active: $isActivePair, Live: $hasLiveActivity');
          return _buildPairChip(pair, isActivePair, hasLiveActivity);
        }).toList(),
      ),
    );
  }

  Widget _buildActivePairTab(String pair, bool isActive, bool hasLiveActivity) {
    return GestureDetector(
      onTap: () => _onPairSelected(pair),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isActive
                ? [
                    const Color(0xFF00D4AA), // Green for active pair
                    const Color(0xFF00D4AA).withOpacity(0.8)
                  ]
                : hasLiveActivity
                    ? [
                        const Color(0xFFF0B90B).withOpacity(0.3), // Gold for live activity
                        const Color(0xFFF0B90B).withOpacity(0.1)
                      ]
                    : [const Color(0xFF2A2A2A), const Color(0xFF1E1E1E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? const Color(0xFF00D4AA)
                : hasLiveActivity
                    ? const Color(0xFFF0B90B)
                    : const Color(0xFF444444),
            width: isActive ? 2.0 : 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF00D4AA).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : hasLiveActivity
                  ? [
                      BoxShadow(
                        color: const Color(0xFFF0B90B).withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Live activity indicator
            if (hasLiveActivity) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : const Color(0xFF00D4AA),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isActive ? Colors.white : const Color(0xFF00D4AA)).withOpacity(0.6),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Pair name
            Text(
              pair,
              style: TextStyle(
                color: isActive
                    ? Colors.black
                    : hasLiveActivity
                        ? const Color(0xFFF0B90B)
                        : Colors.white,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            // Active indicator
            if (isActive) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPairChip(String pair, bool isActivePair, bool hasLiveActivity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActivePair
            ? const Color(0xFF00D4AA)
            : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActivePair
              ? const Color(0xFF00D4AA)
              : const Color(0xFF3A3A3A),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActivePair)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 6),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            pair.replaceAll('USDT', ''),
            style: TextStyle(
              color: isActivePair ? Colors.white : Colors.white70,
              fontSize: 12,
              fontWeight: isActivePair ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradingInterface() {
    return Container(
      color: const Color(0xFF0B0E11),
      child: Column(
        children: [
          const SizedBox(
            height: 8,
          ),
          // Trading history section at the top
          _buildOrderBookSection(),

          // BUY and SELL tables side by side
          const SizedBox(height: 8),
          _buildBuySellTables(),
          const SizedBox(height: 20),

          // Table headers
          // _buildTableHeaders(),

          // Trading data (full width now)
          // _buildLiveTradingSection(),

          // Add some bottom padding
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTableHeaders() {
    return Container(
      height: 40,
      color: const Color(0xFF1A1A1A),
      child: Row(
        children: [
          Expanded(flex: 2, child: _buildHeaderCell('PAIR')),
          Expanded(flex: 2, child: _buildHeaderCell('PRICE')),
          Expanded(flex: 2, child: _buildHeaderCell('24H')),
          Expanded(flex: 2, child: _buildHeaderCell('EXCHANGE')),
          Expanded(flex: 2, child: _buildHeaderCell('VOLUME')),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildLiveTradingSection() {
    return Container(
      color: const Color(0xFF0B0E11),
      child: Column(
        children: _getFilteredCryptoData().map((item) {
          final index = _getFilteredCryptoData().indexOf(item);
          return _buildTradingRow(item, index);
        }).toList(),
      ),
    );
  }

  Widget _buildOrderBookSection() {
    return Container(
      color: const Color(0xFF0B0E11),
      child: Column(
        children: [
          // Order book header with selected exchange
          Container(
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.history,
                  color: Color(0xFFF0B90B),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'TRADING HISTORY - $_selectedExchange',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D4AA).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Color(0xFF00D4AA),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF0F1419),
              border: Border(
                bottom: BorderSide(color: Colors.grey),
                top: BorderSide(color: Colors.grey),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: _buildDataCell('PAIR', Colors.white70),
                    )),
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: _buildDataCell('TYPE', Colors.white70),
                    )),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'PRICE',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'AMOUNT',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'EXCHANGE',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Order book data (limited rows, no scrolling)
          Column(
            children: () {
              // Get a random mix of buy and sell orders
              final allOrders = List.from(_orderBookData);
              allOrders.shuffle(); // Randomly shuffle all orders
              final displayOrders = allOrders.take(8).toList();

              return displayOrders.map((order) {
                final index = displayOrders.indexOf(order);
                return _buildLiveOrderBookRow(order, index);
              }).toList();
            }(),
          ),
          const Divider(
            color: Colors.grey,
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  Widget _buildBuySellTables() {
    print('🔥 Building BUY/SELL Tables');
    return Container(
      height: 200, // Fixed height to ensure visibility
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // BUY Orders Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0B0E11),
                border:
                    Border.all(color: const Color(0xFF00D4AA).withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // BUY header
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4AA).withOpacity(0.2),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.trending_up,
                              color: Color(0xFF00D4AA), size: 16),
                          const SizedBox(width: 8),
                          const Text(
                            'BUY ORDERS',
                            style: TextStyle(
                              color: Color(0xFF00D4AA),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Column headers
                  Container(
                    height: 30,
                    color: const Color(0xFF0F1419),
                    child: Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text(
                            'PAIR',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 9),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Expanded(
                          flex: 2,
                          child: Text(
                            'PRICE',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 9),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Expanded(
                          flex: 2,
                          child: Text(
                            'AMOUNT',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 9),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Real BUY data
                  Container(
                    height: 125, // Fixed height for 5 rows
                    child: Column(
                      children: _orderBookData
                          .where((order) => order['type'] == 'buy')
                          .take(5)
                          .map((order) {
                        final index = _orderBookData.indexOf(order);
                        return Container(
                          height: 25,
                          color: index % 2 == 0
                              ? const Color(0xFF0F1419)
                              : const Color(0xFF0B0E11),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  order['pair']?.toString() ?? 'BTCUSDT',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 8),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '\$${double.parse(order['price'].toString()).toStringAsFixed(3)}',
                                  style: const TextStyle(
                                      color: Color(0xFF00D4AA), fontSize: 9),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  double.parse(order['amount'].toString()).toStringAsFixed(3),
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 9),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 15),
          // SELL Orders Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0B0E11),
                border:
                    Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // SELL header
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B).withOpacity(0.2),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.trending_down,
                              color: Color(0xFFFF6B6B), size: 16),
                          const SizedBox(width: 8),
                          const Text(
                            'SELL ORDERS',
                            style: TextStyle(
                              color: Color(0xFFFF6B6B),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Column headers
                  Container(
                    height: 30,
                    color: const Color(0xFF0F1419),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'PAIR',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 9),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'PRICE',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 9),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'AMOUNT',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 9),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Real SELL data
                  Container(
                    height: 125, // Fixed height for 5 rows
                    child: Column(
                      children: _orderBookData
                          .where((order) => order['type'] == 'sell')
                          .take(5)
                          .map((order) {
                        final index = _orderBookData.indexOf(order);
                        return Container(
                          height: 25,
                          color: index % 2 == 0
                              ? const Color(0xFF0F1419)
                              : const Color(0xFF0B0E11),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  order['pair']?.toString() ?? 'BTCUSDT',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 8),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '\$${double.parse(order['price'].toString()).toStringAsFixed(3)}',
                                  style: const TextStyle(
                                      color: Color(0xFFFF6B6B), fontSize: 9),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  double.parse(order['amount'].toString()).toStringAsFixed(3),
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 9),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyOrdersTable() {
    final buyOrders = _orderBookData
        .where((order) => order['type'] == 'buy')
        .take(6)
        .toList();
    print('🟢 BUY Orders found: ${buyOrders.length}');

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E11),
        border: Border.all(color: const Color(0xFF00D4AA).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // BUY header
          Container(
            height: 35,
            decoration: BoxDecoration(
              color: const Color(0xFF00D4AA).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.trending_up,
                  color: Color(0xFF00D4AA),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'BUY ORDERS',
                  style: TextStyle(
                    color: Color(0xFF00D4AA),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Column headers
          Container(
            height: 25,
            color: const Color(0xFF0F1419),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'PRICE',
                    style: TextStyle(color: Colors.white70, fontSize: 9),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'AMOUNT',
                    style: TextStyle(color: Colors.white70, fontSize: 9),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // BUY orders data
          Column(
            children: buyOrders.isNotEmpty
                ? buyOrders.map((order) {
                    final index = buyOrders.indexOf(order);
                    return _buildBuyOrderRow(order, index);
                  }).toList()
                : [
                    Container(
                      height: 25,
                      child: const Center(
                        child: Text(
                          'Loading BUY orders...',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ),
                    ),
                  ],
          ),
        ],
      ),
    );
  }

  Widget _buildSellOrdersTable() {
    final sellOrders = _orderBookData
        .where((order) => order['type'] == 'sell')
        .take(6)
        .toList();
    print('🔴 SELL Orders found: ${sellOrders.length}');

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E11),
        border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // SELL header
          Container(
            height: 35,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.trending_down,
                  color: Color(0xFFFF6B6B),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'SELL ORDERS',
                  style: TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Column headers
          Container(
            height: 25,
            color: const Color(0xFF0F1419),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'PRICE',
                    style: TextStyle(color: Colors.white70, fontSize: 9),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'AMOUNT',
                    style: TextStyle(color: Colors.white70, fontSize: 9),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // SELL orders data
          Column(
            children: sellOrders.map((order) {
              final index = sellOrders.indexOf(order);
              return _buildSellOrderRow(order, index);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyOrderRow(Map<String, dynamic> order, int index) {
    final price = order['price'] as double;
    final amount = order['amount'] as double;

    return Container(
      height: 25,
      color: index % 2 == 0 ? const Color(0xFF0F1419) : const Color(0xFF0B0E11),
      child: Row(
        children: [
          // Price column
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '\$${price.toStringAsFixed(3)}',
                style: const TextStyle(
                  color: Color(0xFF00D4AA),
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Amount column
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                amount.toStringAsFixed(3),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellOrderRow(Map<String, dynamic> order, int index) {
    final price = order['price'] as double;
    final amount = order['amount'] as double;

    return Container(
      height: 25,
      color: index % 2 == 0 ? const Color(0xFF0F1419) : const Color(0xFF0B0E11),
      child: Row(
        children: [
          // Price column
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '\$${price.toStringAsFixed(3)}',
                style: const TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Amount column
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                amount.toStringAsFixed(3),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _getFilteredCryptoData() {
    if (_cryptoData.isEmpty) return [];

    // Filter data by selected exchange
    return _cryptoData.where((item) {
      final itemExchange = item['exchange']?.toString() ?? '';
      return itemExchange == _selectedExchange || itemExchange.isEmpty;
    }).toList();
  }

  List<String> _getAvailablePairsForExchange(String exchange) {
    return _liveService.getExchangePairs(exchange);
  }

  String _formatVolume(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    } else {
      return volume.toStringAsFixed(2);
    }
  }

  Widget _buildLiveTradingIndicator(dynamic item) {
    final change = double.tryParse(item['priceChange']?.toString() ?? item['priceChangePercent']?.toString() ?? '0') ?? 0.0;
    final volume = double.tryParse(item['volume']?.toString() ?? '0') ?? 0.0;
    final isPositive = change >= 0;

    // Determine trading activity level based on volume
    String activityLevel = 'LOW';
    Color activityColor = Colors.grey;

    if (volume > 1000000) {
      activityLevel = 'HIGH';
      activityColor = const Color(0xFF00D4AA);
    } else if (volume > 100000) {
      activityLevel = 'MED';
      activityColor = const Color(0xFFF0B90B);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Price trend indicator
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPositive ? const Color(0xFF00D4AA) : const Color(0xFFFF6B6B),
          ),
        ),
        const SizedBox(width: 4),
        // Activity level indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: activityColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: activityColor, width: 0.5),
          ),
          child: Text(
            activityLevel,
            style: TextStyle(
              color: activityColor,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _calculateMarketDepth() {
    if (_orderBookData.isEmpty) {
      return {
        'buyPressure': 0.0,
        'sellPressure': 0.0,
        'spread': 0.0,
        'totalBuyVolume': 0.0,
        'totalSellVolume': 0.0,
      };
    }

    final buyOrders = _orderBookData.where((order) => order['type'] == 'buy').toList();
    final sellOrders = _orderBookData.where((order) => order['type'] == 'sell').toList();

    double totalBuyVolume = buyOrders.fold(0.0, (sum, order) => sum + (order['amount'] as double));
    double totalSellVolume = sellOrders.fold(0.0, (sum, order) => sum + (order['amount'] as double));

    double buyPressure = totalBuyVolume / (totalBuyVolume + totalSellVolume);
    double sellPressure = totalSellVolume / (totalBuyVolume + totalSellVolume);

    double spread = 0.0;
    if (buyOrders.isNotEmpty && sellOrders.isNotEmpty) {
      final highestBid = buyOrders.map((o) => o['price'] as double).reduce((a, b) => a > b ? a : b);
      final lowestAsk = sellOrders.map((o) => o['price'] as double).reduce((a, b) => a < b ? a : b);
      spread = lowestAsk - highestBid;
    }

    return {
      'buyPressure': buyPressure,
      'sellPressure': sellPressure,
      'spread': spread,
      'totalBuyVolume': totalBuyVolume,
      'totalSellVolume': totalSellVolume,
    };
  }

  Widget _buildMarketDepthIndicator() {
    final marketDepth = _calculateMarketDepth();
    final buyPressure = marketDepth['buyPressure'] as double;
    final sellPressure = marketDepth['sellPressure'] as double;
    final spread = marketDepth['spread'] as double;

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Market Depth',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Buy/Sell pressure bar
          Container(
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFF333333),
            ),
            child: Row(
              children: [
                if (buyPressure > 0)
                  Expanded(
                    flex: (buyPressure * 100).round(),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF00D4AA),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                if (sellPressure > 0)
                  Expanded(
                    flex: (sellPressure * 100).round(),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Buy: ${(buyPressure * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Color(0xFF00D4AA),
                  fontSize: 10,
                ),
              ),
              Text(
                'Spread: \$${spread.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
              Text(
                'Sell: ${(sellPressure * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTradingRow(dynamic item, int index) {
    final symbol = item['symbol']?.toString() ?? 'N/A';
    final price = double.tryParse(item['price']?.toString() ?? item['lastPrice']?.toString() ?? '0') ?? 0.0;
    final change = double.tryParse(item['priceChange']?.toString() ?? item['priceChangePercent']?.toString() ?? '0') ?? 0.0;
    final isPositive = change >= 0;
    final volume = double.tryParse(item['volume']?.toString() ?? '0') ?? 0.0;
    final exchange = item['exchange']?.toString() ?? _selectedExchange;

    final displaySymbol = symbol.replaceAll('USDT', '').replaceAll('-USDT', '').replaceAll('_USDT', '').replaceAll('-USD', '');
    final formattedVolume = _formatVolume(volume);

    return Container(
      height: 32,
      color: index % 2 == 0 ? const Color(0xFF0F1419) : const Color(0xFF0B0E11),
      child: Row(
        children: [
          // PAIR column with live indicator
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(child: _buildDataCell(displaySymbol, Colors.white)),
                _buildLiveTradingIndicator(item),
              ],
            ),
          ),
          // PRICE column
          Expanded(
              flex: 2,
              child: _buildDataCell(
                  '\$${price.toStringAsFixed(3)}', const Color(0xFFF0B90B))),
          // 24H column
          Expanded(
              flex: 2,
              child: _buildDataCell(
                  '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}%',
                  isPositive
                      ? const Color(0xFF00D4AA)
                      : const Color(0xFFFF6B6B))),
          // EXCHANGE column
          Expanded(
              flex: 2, child: _buildDataCell(exchange, Colors.white70)),
          // VOLUME column
          Expanded(
              flex: 2,
              child: _buildDataCell(
                  formattedVolume,
                  Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildLiveOrderBookRow(Map<String, dynamic> order, int index) {
    final isBuyOrder = order['type'] == 'buy';
    final price = order['price'] as double;
    final amount = order['amount'] as double;
    final pair = order['pair']?.toString() ?? 'BTCUSDT';
    final exchange = order['exchange']?.toString() ?? 'Binance';

    return Container(
      height: 28,
      color: index % 2 == 0 ? const Color(0xFF0F1419) : const Color(0xFF0B0E11),
      child: Row(
        children: [
          // Pair column
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                pair.replaceAll('USDT', ''),
                style: const TextStyle(
                  color: Color(0xFFF0B90B),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Type column (BUY/SELL)
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                isBuyOrder ? 'BUY' : 'SELL',
                style: TextStyle(
                  color: isBuyOrder
                      ? const Color(0xFF00D4AA)
                      : const Color(0xFFFF6B6B),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Price column
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '\$${price.toStringAsFixed(3)}',
                style: TextStyle(
                  color: isBuyOrder
                      ? const Color(0xFF00D4AA)
                      : const Color(0xFFFF6B6B),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Amount column
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                amount.toStringAsFixed(3),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Exchange column (replaced Total)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                exchange,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCell(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}

class BubbleData {
  double x;
  double y;
  final double size;
  final double opacity;
  final double speed;

  BubbleData({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
  });
}

class AnimatedBubble extends StatelessWidget {
  final BubbleData bubble;
  final Animation<double> animation;

  const AnimatedBubble({
    Key? key,
    required this.bubble,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Update bubble position
        bubble.y -= bubble.speed * 2;

        // Remove bubble if it goes off screen
        if (bubble.y < -bubble.size) {
          return const SizedBox.shrink();
        }

        return Positioned(
          left: bubble.x,
          top: bubble.y,
          child: Container(
            width: bubble.size,
            height: bubble.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00D4AA).withOpacity(bubble.opacity),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D4AA).withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
