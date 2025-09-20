import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rapidtradeai/src/widget/common_app_bar.dart';
import 'package:rapidtradeai/src/widget/lottie_loading_widget.dart';

import '../Service/assets_service.dart';

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
  Timer? _marqueeTimer;
  Timer? _exchangeMarqueeTimer;
  late AnimationController _bubbleController;
  late ScrollController _marqueeController;
  late ScrollController _exchangeMarqueeController;
  List<BubbleData> _bubbles = [];
  Timer? _bubbleTimer;
  String _selectedExchange = 'Binance';
  String _selectedCategory = 'TRADING EXCHANGES';
  int _selectedTabIndex = 0;
  List<Map<String, dynamic>> _orderBookData = [];
  Timer? _orderBookTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _marqueeController = ScrollController();
    _exchangeMarqueeController = ScrollController();
    _fetchCryptoData();
    _startAutoRefresh();
    _startBubbleAnimation();
    _generateOrderBookData();
    _startOrderBookAnimation();
  }

  void _initializeAnimations() {
    _bubbleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

  void _startBubbleAnimation() {
    _bubbleTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted) {
        _addBubble();
      }
    });
  }

  void _addBubble() {
    final random = Random();
    final bubble = BubbleData(
      x: random.nextDouble() * MediaQuery.of(context).size.width,
      y: MediaQuery.of(context).size.height,
      size: 20 + random.nextDouble() * 40,
      opacity: 0.3 + random.nextDouble() * 0.4,
      speed: 1 + random.nextDouble() * 2,
    );

    setState(() {
      _bubbles.add(bubble);
      // Remove old bubbles to prevent memory issues
      if (_bubbles.length > 15) {
        _bubbles.removeAt(0);
      }
    });
  }

  Future<void> _fetchCryptoData() async {
    try {
      // Only show loading on first load, not on refresh
      if (_cryptoData.isEmpty) {
        setState(() {
          _isLoading = true;
        });
      }

      final response = await http.get(
        Uri.parse('https://api.binance.com/api/v3/ticker/24hr'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Filter for USDT pairs and sort by volume
        final filteredData = data
            .where((item) =>
                item['symbol'].toString().endsWith('USDT') &&
                double.parse(item['quoteVolume']) >
                    1000000) // Min volume filter
            .toList();

        filteredData.sort((a, b) => double.parse(b['quoteVolume'])
            .compareTo(double.parse(a['quoteVolume'])));

        if (mounted) {
          setState(() {
            _cryptoData = filteredData.take(50).toList(); // Top 50 by volume
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching crypto data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _fetchCryptoData(); // This will now update in background without showing loading
      }
    });
  }

  void _startMarqueeAnimation() {
    _marqueeTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted && _marqueeController.hasClients && _cryptoData.isNotEmpty) {
        try {
          final maxScroll = _marqueeController.position.maxScrollExtent;
          final currentScroll = _marqueeController.offset;

          if (maxScroll > 0) {
            if (currentScroll >= maxScroll) {
              // Reset to beginning smoothly
              _marqueeController.jumpTo(0);
            } else {
              // Smooth continuous scrolling
              final nextPosition = currentScroll + 2.0;
              _marqueeController.jumpTo(nextPosition);
            }
          }
        } catch (e) {
          // Handle any scroll controller errors
        }
      }
    });
  }

  void _startExchangeMarqueeAnimation() {
    _exchangeMarqueeTimer =
        Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (mounted && _exchangeMarqueeController.hasClients) {
        try {
          final maxScroll = _exchangeMarqueeController.position.maxScrollExtent;
          final currentScroll = _exchangeMarqueeController.offset;

          if (maxScroll > 0) {
            if (currentScroll >= maxScroll) {
              // Reset to beginning smoothly
              _exchangeMarqueeController.jumpTo(0);
            } else {
              // Slower scrolling for exchange tabs - reduced speed
              final nextPosition = currentScroll + 1.5;
              _exchangeMarqueeController.jumpTo(nextPosition);
            }
          }
        } catch (e) {
          // Handle any scroll controller errors
        }
      }
    });
  }

  void _generateOrderBookData() {
    _orderBookData.clear();
    final random = Random();

    // Get current price for selected exchange (use first crypto data as base)
    double basePrice = _cryptoData.isNotEmpty
        ? double.parse(_cryptoData[0]['lastPrice'])
        : 50000.0;

    // Generate buy orders (below current price)
    for (int i = 0; i < 15; i++) {
      final priceOffset = random.nextDouble() * 1000 + (i * 50);
      final price = basePrice - priceOffset;
      final amount = random.nextDouble() * 10 + 0.1;

      _orderBookData.add({
        'type': 'buy',
        'price': price,
        'amount': amount,
        'total': price * amount,
        'exchange': _selectedExchange,
      });
    }

    // Generate sell orders (above current price)
    for (int i = 0; i < 15; i++) {
      final priceOffset = random.nextDouble() * 1000 + (i * 50);
      final price = basePrice + priceOffset;
      final amount = random.nextDouble() * 10 + 0.1;

      _orderBookData.add({
        'type': 'sell',
        'price': price,
        'amount': amount,
        'total': price * amount,
        'exchange': _selectedExchange,
      });
    }

    // Sort to show sell orders first (ascending price), then buy orders (descending price)
    // This creates a realistic order book view
    _orderBookData.sort((a, b) {
      if (a['type'] == 'sell' && b['type'] == 'sell') {
        return a['price']
            .compareTo(b['price']); // Sell orders: lowest price first
      } else if (a['type'] == 'buy' && b['type'] == 'buy') {
        return b['price']
            .compareTo(a['price']); // Buy orders: highest price first
      } else if (a['type'] == 'sell' && b['type'] == 'buy') {
        return -1; // Sell orders come first
      } else {
        return 1; // Buy orders come after sell orders
      }
    });
  }

  void _startOrderBookAnimation() {
    _orderBookTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          // Update random values to simulate live trading
          final random = Random();
          for (var order in _orderBookData) {
            // Slightly modify price and amount
            final priceVariation = (random.nextDouble() - 0.5) * 10;
            final amountVariation = (random.nextDouble() - 0.5) * 0.5;

            order['price'] = (order['price'] + priceVariation).abs();
            order['amount'] = (order['amount'] + amountVariation).abs();
            order['total'] = order['price'] * order['amount'];
          }
        });
      }
    });
  }

  void _onExchangeSelected(String exchangeName) {
    setState(() {
      _selectedExchange = exchangeName;
    });
    // Regenerate order book data for the new exchange
    _generateOrderBookData();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _bubbleTimer?.cancel();
    _marqueeTimer?.cancel();
    _exchangeMarqueeTimer?.cancel();
    _orderBookTimer?.cancel();
    _bubbleController.dispose();
    _marqueeController.dispose();
    _exchangeMarqueeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Start animations after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _marqueeTimer == null && _exchangeMarqueeTimer == null) {
        _startMarqueeAnimation();
        _startExchangeMarqueeAnimation();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: CommonAppBar.basic(
        title: "Live Trading",
      ),
      body: Stack(
        children: [
          // // Animated bubbles background
          // ..._bubbles.map((bubble) => AnimatedBubble(
          //       bubble: bubble,
          //       animation: _bubbleController,
          //     )),

          // Main content
          _isLoading && _cryptoData.isEmpty
              ? const Center(
                  child: LottieLoadingWidget.fullScreen(
                    message: 'Loading Live Market Data...',
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Price ticker
                      _buildPriceTicker(),
                      const SizedBox(height: 8),
                      // Top status bar
                      _buildTopStatusBar(),
                      const SizedBox(height: 8),
                      // Trading Exchange Header (moved above coins)
                      _buildTradingExchangeHeader(),
                      const SizedBox(height: 8),
                      // Exchange tabs
                      _buildExchangeTabs(),
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
      child: SingleChildScrollView(
        controller: _marqueeController,
        scrollDirection: Axis.horizontal,
        physics:
            const NeverScrollableScrollPhysics(), // Disable manual scrolling
        child: Row(
          children: [
            // First set of items
            ..._cryptoData.take(20).map<Widget>((item) {
              final symbol = item['symbol'].toString().replaceAll('USDT', '');
              final price = double.parse(item['lastPrice']);
              final change = double.parse(item['priceChangePercent']);
              final isPositive = change >= 0;

              return _buildMarqueeTickerItem(
                symbol,
                '\$${price.toStringAsFixed(3)}',
                '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%',
                isPositive,
                item,
              );
            }).toList(),
            // Duplicate set for seamless loop
            ..._cryptoData.take(20).map<Widget>((item) {
              final symbol = item['symbol'].toString().replaceAll('USDT', '');
              final price = double.parse(item['lastPrice']);
              final change = double.parse(item['priceChangePercent']);
              final isPositive = change >= 0;

              return _buildMarqueeTickerItem(
                symbol,
                '\$${price.toStringAsFixed(3)}',
                '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%',
                isPositive,
                item,
              );
            }).toList(),
          ],
        ),
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
                color:  TradingTheme.secondaryAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                symbol,
                style: const TextStyle(
                  color: TradingTheme.secondaryAccent,
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
                  backgroundColor:  TradingTheme.secondaryAccent,
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
                AnimatedBuilder(
                  animation: _bubbleController,
                  builder: (context, child) {
                    return Container(
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
                    );
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'TRADING ACTIVE',
                  style: TextStyle(
                    color: Color(0xFF00D4AA),
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
            color: TradingTheme.secondaryAccent,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            'TRADING EXCHANGES',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color:  TradingTheme.secondaryAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color:  TradingTheme.secondaryAccent, width: 0.5),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: TradingTheme.secondaryAccent,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeTabs() {
    final exchanges = [
      'Binance',
      'KuCoin',
      'Coinbase',
      'Crypto.com',
      'OKX',
      'Gate.io',
      'Huobi',
      'Bybit',
      'FTX',
      'Kraken',
      'Bitfinex',
      'Gemini'
    ];

    return Container(
      height: 50,
      color: const Color(0xFF1E1E1E),
      child: SingleChildScrollView(
        controller: _exchangeMarqueeController,
        scrollDirection: Axis.horizontal,
        physics:
            const NeverScrollableScrollPhysics(), // Disable manual scrolling
        child: Row(
          children: [
            // First set of exchange tabs
            ...exchanges.map<Widget>((exchange) {
              final isSelected = exchange == _selectedExchange;
              return _buildMarqueeExchangeTab(exchange, isSelected);
            }).toList(),
            // Duplicate set for seamless loop
            ...exchanges.map<Widget>((exchange) {
              final isSelected = exchange == _selectedExchange;
              return _buildMarqueeExchangeTab(exchange, isSelected);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMarqueeExchangeTab(String name, bool isSelected) {
    return GestureDetector(
      onTap: () => _onExchangeSelected(name),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [
                     TradingTheme.secondaryAccent,
                     TradingTheme.secondaryAccent.withOpacity(0.8)
                  ]
                : [const Color(0xFF2A2A2A), const Color(0xFF1E1E1E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected ?  TradingTheme.secondaryAccent : const Color(0xFF444444),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:  TradingTheme.secondaryAccent.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(
                Icons.star,
                color: Colors.black,
                size: 14,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 8,
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
          _buildTableHeaders(),

          // Trading data (full width now)
          _buildLiveTradingSection(),

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
          Expanded(flex: 2, child: _buildHeaderCell('AMOUNT')),
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
        children: _cryptoData.map((item) {
          final index = _cryptoData.indexOf(item);
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
                  color: TradingTheme.secondaryAccent,
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
                    'TOTAL',
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
                          child: Text(
                            'PRICE',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'AMOUNT',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 10),
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
                                child: Text(
                                  '\$${double.parse(order['price'].toString()).toStringAsFixed(3)}',
                                  style: const TextStyle(
                                      color: Color(0xFF00D4AA), fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${double.parse(order['amount'].toString()).toStringAsFixed(3)}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 10),
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
                        const Expanded(
                          child: Text(
                            'PRICE',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'AMOUNT',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 10),
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
                                child: Text(
                                  '\$${double.parse(order['price'].toString()).toStringAsFixed(3)}',
                                  style: const TextStyle(
                                      color: Color(0xFFFF6B6B), fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${double.parse(order['amount'].toString()).toStringAsFixed(3)}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 10),
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

  Widget _buildTradingRow(dynamic item, int index) {
    final symbol = item['symbol'].toString();
    final price = double.parse(item['lastPrice']);
    final change = double.parse(item['priceChangePercent']);
    final isPositive = change >= 0;

    final displaySymbol = symbol.replaceAll('USDT', '');
    final exchanges = ['Binance', 'KuCoin', 'Coinbase', 'Crypto.com', 'OKX'];
    final randomExchange = exchanges[index % exchanges.length];
    final randomAmount = (index * 0.1 + 1).toStringAsFixed(2);

    return Container(
      height: 32,
      color: index % 2 == 0 ? const Color(0xFF0F1419) : const Color(0xFF0B0E11),
      child: Row(
        children: [
          // PAIR column
          Expanded(flex: 2, child: _buildDataCell(displaySymbol, Colors.white)),
          // PRICE column
          Expanded(
              flex: 2,
              child: _buildDataCell(
                  '\$${price.toStringAsFixed(3)}',  TradingTheme.secondaryAccent)),
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
              flex: 2, child: _buildDataCell(randomExchange, Colors.white70)),
          // AMOUNT column
          Expanded(
              flex: 2,
              child: _buildDataCell(
                  randomAmount,
                  isPositive
                      ? const Color(0xFF00D4AA)
                      : const Color(0xFFFF6B6B))),
        ],
      ),
    );
  }

  Widget _buildLiveOrderBookRow(Map<String, dynamic> order, int index) {
    final isBuyOrder = order['type'] == 'buy';
    final price = order['price'] as double;
    final amount = order['amount'] as double;
    final total = order['total'] as double;

    return Container(
      height: 28,
      color: index % 2 == 0 ? const Color(0xFF0F1419) : const Color(0xFF0B0E11),
      child: Row(
        children: [
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
          // Total column
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '\$${total.toStringAsFixed(3)}',
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
