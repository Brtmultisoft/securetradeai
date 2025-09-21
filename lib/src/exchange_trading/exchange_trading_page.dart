import 'dart:async';
import 'package:flutter/material.dart';
import 'package:securetradeai/src/Service/bybit_service.dart';
import 'package:securetradeai/src/Service/live_trading_service.dart';
import 'package:securetradeai/src/Service/exchange_trading_service.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';
import 'package:securetradeai/src/widget/trading_widgets.dart';

class ExchangeTradingPage extends StatefulWidget {
  const ExchangeTradingPage({Key? key}) : super(key: key);

  @override
  State<ExchangeTradingPage> createState() => _ExchangeTradingPageState();
}

class _ExchangeTradingPageState extends State<ExchangeTradingPage>
    with TickerProviderStateMixin {

  late ExchangeTradingService _exchangeService;
  late LiveTradingService _binanceService;
  late BybitService _bybitService;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  Map<String, dynamic> _binanceData = {};
  Map<String, dynamic> _bybitData = {};
  List<Map<String, dynamic>> _tradeHistory = [];
  List<Map<String, dynamic>> _buyOrders = [];
  List<Map<String, dynamic>> _sellOrders = [];

  bool _isLoading = true;
  String _selectedPair = 'BTCUSDT';

  StreamSubscription? _binanceSubscription;
  StreamSubscription? _bybitSubscription;
  StreamSubscription? _tradeHistorySubscription;
  StreamSubscription? _buyOrdersSubscription;
  StreamSubscription? _sellOrdersSubscription;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _setupAnimations();
    _startLiveData();
  }

  void _initializeServices() {
    _exchangeService = ExchangeTradingService();
    _bybitService = BybitService();
    _binanceService = LiveTradingService();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startLiveData() async {
    setState(() => _isLoading = true);

    try {
      await _exchangeService.initialize();

      _setupDataStreams();

      setState(() => _isLoading = false);
      _fadeController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _setupDataStreams() {
    _binanceService = _exchangeService.binanceService;
    _bybitService = _exchangeService.bybitService;

    _binanceSubscription = _binanceService.tickerStream.listen((data) {
      if (mounted && data.containsKey(_selectedPair)) {
        setState(() {
          _binanceData = data[_selectedPair];
        });
      }
    });

    _bybitSubscription = _bybitService.tickerStream.listen((data) {
      if (mounted && data.containsKey(_selectedPair)) {
        setState(() {
          _bybitData = data[_selectedPair];
        });
      }
    });

    _tradeHistorySubscription = _exchangeService.combinedTradeHistoryStream.listen((data) {
      if (mounted) {
        setState(() {
          _tradeHistory = data;
        });
      }
    });

    _buyOrdersSubscription = _exchangeService.combinedBuyOrdersStream.listen((data) {
      if (mounted) {
        setState(() {
          _buyOrders = data;
        });
      }
    });

    _sellOrdersSubscription = _exchangeService.combinedSellOrdersStream.listen((data) {
      if (mounted) {
        setState(() {
          _sellOrders = data;
        });
      }
    });

    _loadInitialData();
  }

  void _loadInitialData() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final currentTrades = _exchangeService.combinedTradeHistory;
      final currentBuyOrders = _exchangeService.combinedBuyOrders;
      final currentSellOrders = _exchangeService.combinedSellOrders;

      if (mounted) {
        setState(() {
          if (currentTrades.isNotEmpty) {
            _tradeHistory = currentTrades;
           } else {
          }

          if (currentBuyOrders.isNotEmpty) {
            _buyOrders = currentBuyOrders;
          } else {

          }

          if (currentSellOrders.isNotEmpty) {
            _sellOrders = currentSellOrders;
            print('🔄 Loaded ${currentSellOrders.length} initial sell orders');
          } else {

          }
        });
      }
    } catch (e) {
      // // Fallback data
      // if (mounted) {
      //   setState(() {
      //     _tradeHistory = [
      //       {
      //         'type': 'Binance',
      //         'exchange': 'Buy',
      //         'price': '\$115,750.25',
      //         'amount': '0.025000',
      //         'time': DateTime.now().toString().substring(0, 19),
      //       },
      //     ];
      //     _buyOrders = [
      //       {'pair': 'BTC/USDT', 'price': '\$115,720.00', 'amount': '0.025000'},
      //     ];
      //     _sellOrders = [
      //       {'pair': 'BTC/USDT', 'price': '\$115,780.00', 'amount': '0.030000'},
      //     ];
      //   });
      // }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _binanceSubscription?.cancel();
    _bybitSubscription?.cancel();
    _tradeHistorySubscription?.cancel();
    _buyOrdersSubscription?.cancel();
    _sellOrdersSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: CommonAppBar.trading(
        title: 'Exchange Trading',
        badgeText: 'LIVE',
        badgeIcon: Icons.trending_up,
      ),
      body: _isLoading ? _buildLoadingScreen() : _buildMainContent(),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: TradingLoadingIndicator(
        message: 'Connecting to Exchanges...',
      ),
    );
  }

  Widget _buildMainContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        // padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExchangeHeaders(),
            _buildPairSelector(),
            _buildTradingHistoryTable(),
            const SizedBox(height: 20),
            _buildOrderTables(),
          ],
        ),
      ),
    );
  }

  Widget _buildExchangeHeaders() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(child: _buildExchangeCard('Binance', _binanceData)),
          const SizedBox(width: 16),
          Expanded(child: _buildExchangeCard('Bybit', _bybitData)),
        ],
      ),
    );
  }

  Widget _buildExchangeCard(String exchange, Map<String, dynamic> data) {
    final price = data['price'] ?? '0.00';
    final change = data['priceChangePercent'] ?? '0.00';
    final isPositive = (double.tryParse(change.toString()) ?? 0) >= 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D29),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: exchange == 'Binance' 
            ? const Color(0xFFF0B90B) 
            : const Color(0xFF00D4AA),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance,
                color: exchange == 'Binance' 
                  ? const Color(0xFFF0B90B) 
                  : const Color(0xFF00D4AA),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                exchange,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${double.tryParse(price.toString())?.toStringAsFixed(2) ?? '0.00'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}${double.tryParse(change.toString())?.toStringAsFixed(2) ?? '0.00'}%',
            style: TextStyle(
              color: isPositive ? Colors.green : Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPairSelector() {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16 ,bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D29),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text(
            'Pair: ',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0B90B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'BTC/USDT',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradingHistoryTable() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D29),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Trading History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildHistoryTableHeader(),
          ..._tradeHistory.map((trade) => _buildHistoryTableRow(trade)),
          if (_tradeHistory.isEmpty) _buildEmptyState('No trading history available'),
        ],
      ),
    );
  }

  Widget _buildHistoryTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E2E),
        border: Border(
          bottom: BorderSide(color: Color(0xFF313244), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Exchange column - 25% width
          Expanded(
            flex: 20,
            child: Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Exchange',
                style: TextStyle(
                  color: Color(0xFF9399B2),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          // Type column - 15% width
          Expanded(
            flex: 10,
            child: Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Type',
                style: TextStyle(
                  color: Color(0xFF9399B2),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          // Price column - 25% width
          Expanded(
            flex: 10,
            child: Container(
              alignment: Alignment.centerRight,
              child: const Text(
                'Price',
                style: TextStyle(
                  color: Color(0xFF9399B2),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          // Amount column - 20% width
          Expanded(
            flex: 20,
            child: Container(
              alignment: Alignment.centerRight,
              child: const Text(
                'Amount',
                style: TextStyle(
                  color: Color(0xFF9399B2),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          // Time column - 15% width
          Expanded(
            flex: 15,
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                'Time',
                style: TextStyle(
                  color: Color(0xFF9399B2),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTableRow(Map<String, dynamic> trade) {
    final isBuy = trade['exchange'] == 'Buy';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF181825),
        border: Border(
          bottom: BorderSide(color: Color(0xFF313244), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Exchange column - 25% width
          Expanded(
            flex: 21,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                trade['type'] ?? '',
                style: const TextStyle(
                  color: Color(0xFFCDD6F4),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Type column - 15% width (Buy/Sell Badge)
          Expanded(
            flex: 12,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isBuy ? const Color(0xFF40A02B).withOpacity(0.2) : const Color(0xFFE64553).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  trade['exchange'] ?? '',
                  style: TextStyle(
                    color: isBuy ? const Color(0xFF40A02B) : const Color(0xFFE64553),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Price column - 25% width
          Expanded(
            flex: 15,
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                trade['price']?.toString().replaceAll('\$', '') ?? '0.00',
                style: const TextStyle(
                  color: Color(0xFFCDD6F4),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Amount column - 20% width
          Expanded(
            flex: 20,
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                trade['amount'] ?? '0.00',
                style: const TextStyle(
                  color: Color(0xFF9399B2),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          // Time column - 15% width
          Expanded(
            flex: 15,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                _formatTime(trade['time'] ?? ''),
                style: const TextStyle(
                  color: Color(0xFF6C7086),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTables() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildOrderTable('BUY Orders', _buyOrders, Colors.green)),
          const SizedBox(width: 10),
          Expanded(child: _buildOrderTable('SELL Orders', _sellOrders, Colors.red)),
        ],
      ),
    );
  }

  Widget _buildOrderTable(String title, List<Map<String, dynamic>> orders, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D29),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildOrderTableHeader(),
          ...orders.map((order) => _buildOrderTableRow(order)),
          if (orders.isEmpty) _buildEmptyState('No ${title.toLowerCase()} available'),
        ],
      ),
    );
  }

  Widget _buildOrderTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2D3A),
        border: Border(
          bottom: BorderSide(color: Color(0xFF3A3D4A), width: 1),
        ),
      ),
      child: Row(
        children: const [
          Expanded(
            flex: 1,
            child: Text(
              'Pair',
              style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Price',
              style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Amount',
              style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTableRow(Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF2A2D3A), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Pair
          Expanded(
            flex: 2,
            child: Text(
              order['pair'] ?? 'BTC/USDT',
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
              textAlign: TextAlign.left,
            ),
          ),
          // Price
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                '\$${order['price']?.toString().replaceAll('\$', '') ?? '0.00'}',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          // Amount
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                order['amount'] ?? '0.00',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  String _formatTime(String timeString) {
    try {
      final dateTime = DateTime.parse(timeString);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timeString.length > 10 ? timeString.substring(0, 10) : timeString;
    }
  }
}
