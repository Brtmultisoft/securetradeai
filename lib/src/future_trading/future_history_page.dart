import 'package:flutter/material.dart';
import 'package:securetradeai/model/future_trading_models.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/widget/trading_widgets.dart';

class FutureHistoryPage extends StatefulWidget {
  const FutureHistoryPage({Key? key}) : super(key: key);

  @override
  State<FutureHistoryPage> createState() => _FutureHistoryPageState();
}

class _FutureHistoryPageState extends State<FutureHistoryPage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = true;
  List<FutureTradeHistory> _tradeHistory = [];
  String _filterType = 'ALL'; // 'ALL', 'PROFIT', 'LOSS', 'LONG', 'SHORT'

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadTradeHistory();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: TradingAnimations.slowAnimation,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: TradingAnimations.slideCurve,
    ));

    _slideController.forward();
  }

  Future<void> _loadTradeHistory() async {
    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock data
      _tradeHistory = [
        FutureTradeHistory(
          id: '1',
          symbol: 'BTCUSDT',
          side: 'LONG',
          entryPrice: 42000.0,
          exitPrice: 43500.0,
          quantity: 0.1,
          leverage: 10.0,
          realizedPnl: 150.0,
          profitPercent: 3.57,
          tradeDuration: const Duration(hours: 2, minutes: 30),
          openTime: DateTime.now().subtract(const Duration(days: 1)),
          closeTime: DateTime.now().subtract(const Duration(hours: 22)),
          closeReason: 'TP',
          fees: 2.5,
        ),
        FutureTradeHistory(
          id: '2',
          symbol: 'ETHUSDT',
          side: 'SHORT',
          entryPrice: 2700.0,
          exitPrice: 2650.0,
          quantity: 1.0,
          leverage: 5.0,
          realizedPnl: 250.0,
          profitPercent: 1.85,
          tradeDuration: const Duration(hours: 1, minutes: 15),
          openTime: DateTime.now().subtract(const Duration(days: 2)),
          closeTime:
              DateTime.now().subtract(const Duration(days: 1, hours: 23)),
          closeReason: 'MANUAL',
          fees: 3.2,
        ),
        FutureTradeHistory(
          id: '3',
          symbol: 'BNBUSDT',
          side: 'LONG',
          entryPrice: 320.0,
          exitPrice: 315.0,
          quantity: 5.0,
          leverage: 3.0,
          realizedPnl: -75.0,
          profitPercent: -1.56,
          tradeDuration: const Duration(minutes: 45),
          openTime: DateTime.now().subtract(const Duration(days: 3)),
          closeTime:
              DateTime.now().subtract(const Duration(days: 2, hours: 23)),
          closeReason: 'SL',
          fees: 1.8,
        ),
      ];
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<FutureTradeHistory> get _filteredHistory {
    switch (_filterType) {
      case 'PROFIT':
        return _tradeHistory.where((t) => t.isProfit).toList();
      case 'LOSS':
        return _tradeHistory.where((t) => !t.isProfit).toList();
      case 'LONG':
        return _tradeHistory.where((t) => t.isLong).toList();
      case 'SHORT':
        return _tradeHistory.where((t) => t.isShort).toList();
      default:
        return _tradeHistory;
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TradingTheme.primaryBackground,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingScreen() : _buildHistoryContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: TradingTheme.secondaryBackground,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: TradingTheme.accentGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.history,
                  color: Colors.black,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_tradeHistory.length}',
                  style: TradingTypography.bodyMedium.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Text(
            'Trade History',
            style: TradingTypography.heading3,
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: TradingTheme.primaryText),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.file_download,
              color: TradingTheme.primaryAccent),
          onPressed: _exportHistory,
        ),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: TradingLoadingIndicator(
        message: 'Loading Trade History...',
      ),
    );
  }

  Widget _buildHistoryContent() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          _buildFilterTabs(),
          _buildSummaryStats(),
          Expanded(
            child: RefreshIndicator(
              color: TradingTheme.primaryAccent,
              backgroundColor: TradingTheme.secondaryBackground,
              onRefresh: _loadTradeHistory,
              child: _filteredHistory.isEmpty
                  ? _buildEmptyState()
                  : _buildHistoryList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      {'key': 'ALL', 'label': 'All', 'icon': Icons.list},
      {'key': 'PROFIT', 'label': 'Profit', 'icon': Icons.trending_up},
      {'key': 'LOSS', 'label': 'Loss', 'icon': Icons.trending_down},
      {'key': 'LONG', 'label': 'Long', 'icon': Icons.north},
      {'key': 'SHORT', 'label': 'Short', 'icon': Icons.south},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _filterType == filter['key'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TradingButton(
                text: filter['label'] as String,
                onPressed: () =>
                    setState(() => _filterType = filter['key'] as String),
                backgroundColor: isSelected
                    ? TradingTheme.primaryAccent
                    : TradingTheme.surfaceBackground,
                textColor: isSelected ? Colors.black : TradingTheme.primaryText,
                width: 80,
                height: 40,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryStats() {
    final totalPnl = _filteredHistory.fold<double>(
        0, (sum, trade) => sum + trade.realizedPnl);
    final profitTrades = _filteredHistory.where((t) => t.isProfit).length;
    final totalTrades = _filteredHistory.length;
    final winRate = totalTrades > 0 ? (profitTrades / totalTrades * 100) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: AnimatedTradingCard(
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Total PnL',
                '\$${totalPnl.toStringAsFixed(2)}',
                totalPnl >= 0
                    ? TradingTheme.successColor
                    : TradingTheme.errorColor,
                totalPnl >= 0 ? Icons.trending_up : Icons.trending_down,
              ),
            ),
            Container(width: 1, height: 40, color: TradingTheme.primaryBorder),
            Expanded(
              child: _buildStatItem(
                'Win Rate',
                '${winRate.toStringAsFixed(1)}%',
                winRate >= 50
                    ? TradingTheme.successColor
                    : TradingTheme.errorColor,
                Icons.percent,
              ),
            ),
            Container(width: 1, height: 40, color: TradingTheme.primaryBorder),
            Expanded(
              child: _buildStatItem(
                'Total Trades',
                totalTrades.toString(),
                TradingTheme.primaryAccent,
                Icons.bar_chart,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 8),
        Text(label,
            style: TradingTypography.bodySmall, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(
          value,
          style: TradingTypography.bodyLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            color: TradingTheme.secondaryText,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No trade history',
            style: TradingTypography.heading3.copyWith(
              color: TradingTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your completed trades will appear here',
            style: TradingTypography.bodyMedium.copyWith(
              color: TradingTheme.hintText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredHistory.length,
      itemBuilder: (context, index) {
        final trade = _filteredHistory[index];
        return _buildTradeCard(trade);
      },
    );
  }

  Widget _buildTradeCard(FutureTradeHistory trade) {
    return AnimatedTradingCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trade.isLong
                      ? TradingTheme.successColor.withOpacity(0.1)
                      : TradingTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trade.side,
                  style: TradingTypography.bodySmall.copyWith(
                    color: trade.isLong
                        ? TradingTheme.successColor
                        : TradingTheme.errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  trade.symbol,
                  style: TradingTypography.heading3,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${trade.realizedPnl.toStringAsFixed(2)}',
                    style: TradingTypography.bodyLarge.copyWith(
                      color: trade.isProfit
                          ? TradingTheme.successColor
                          : TradingTheme.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${trade.profitPercent >= 0 ? '+' : ''}${trade.profitPercent.toStringAsFixed(2)}%',
                    style: TradingTypography.bodySmall.copyWith(
                      color: trade.isProfit
                          ? TradingTheme.successColor
                          : TradingTheme.errorColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Trade details
          Row(
            children: [
              Expanded(
                child: _buildTradeDetail(
                    'Entry', '\$${trade.entryPrice.toStringAsFixed(2)}'),
              ),
              Expanded(
                child: _buildTradeDetail(
                    'Exit', '\$${trade.exitPrice.toStringAsFixed(2)}'),
              ),
              Expanded(
                child: _buildTradeDetail(
                    'Leverage', '${trade.leverage.toStringAsFixed(0)}x'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTradeDetail(
                    'Quantity', trade.quantity.toStringAsFixed(4)),
              ),
              Expanded(
                child: _buildTradeDetail('Duration', trade.formattedDuration),
              ),
              Expanded(
                child: _buildTradeDetail(
                    'Fees', '\$${trade.fees.toStringAsFixed(2)}'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Close reason and time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      _getCloseReasonColor(trade.closeReason).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getCloseReasonText(trade.closeReason),
                  style: TradingTypography.bodySmall.copyWith(
                    color: _getCloseReasonColor(trade.closeReason),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(trade.closeTime),
                style: TradingTypography.bodySmall.copyWith(
                  color: TradingTheme.hintText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTradeDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TradingTypography.bodySmall.copyWith(
            color: TradingTheme.secondaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TradingTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getCloseReasonColor(String reason) {
    switch (reason) {
      case 'TP':
        return TradingTheme.successColor;
      case 'SL':
        return TradingTheme.errorColor;
      case 'LIQUIDATION':
        return TradingTheme.errorColor;
      default:
        return TradingTheme.primaryAccent;
    }
  }

  String _getCloseReasonText(String reason) {
    switch (reason) {
      case 'TP':
        return 'Take Profit';
      case 'SL':
        return 'Stop Loss';
      case 'LIQUIDATION':
        return 'Liquidated';
      default:
        return 'Manual Close';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _exportHistory() {
    // Simulate export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Trade history exported successfully!',
          style: TradingTypography.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: TradingTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
