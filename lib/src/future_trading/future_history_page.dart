import 'package:flutter/material.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/model/future_trading_models.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/Service/future_trading_service.dart';
import 'package:securetradeai/src/future_trading/trading_report_page.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';
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

  // Trading report data for summary stats
  DualSideTradingReportData? _reportData;

  // API Filter parameters (all optional except user_id)
  String? _selectedSymbol;
  String? _selectedStatus;
  String? _selectedStrategyType;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  int? _currentLimit;
  int? _currentOffset;
  bool _hasMore = true;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadTradeHistory();
    _loadTradingReport();
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

  Future<void> _loadTradeHistory({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentOffset = null; // Reset to default
      _tradeHistory.clear();
    }

    setState(() => _isLoading = true);

    try {
      print('🔄 Loading dual-side trade history...');

      // Format dates for API
      String? dateFromStr;
      String? dateToStr;
      if (_dateFrom != null) {
        dateFromStr =
            '${_dateFrom!.year}-${_dateFrom!.month.toString().padLeft(2, '0')}-${_dateFrom!.day.toString().padLeft(2, '0')}';
      }
      if (_dateTo != null) {
        dateToStr =
            '${_dateTo!.year}-${_dateTo!.month.toString().padLeft(2, '0')}-${_dateTo!.day.toString().padLeft(2, '0')}';
      }

      // Call the real API to get trade history with all filters
      final response = await FutureTradingService.getDualSideTradeHistory(
        userId: commonuserId,
        symbol: _selectedSymbol,
        status: _selectedStatus,
        dateFrom: dateFromStr,
        dateTo: dateToStr,
        strategyType: _selectedStrategyType,
        limit: _currentLimit,
        offset: _currentOffset,
      );

      if (response != null && response.isSuccess && response.data != null) {
        // Convert API response to FutureTradeHistory objects
        final newTrades = response.data!.trades
            .map((trade) => trade.toFutureTradeHistory())
            .toList();

        if (isRefresh) {
          _tradeHistory = newTrades;
        } else {
          _tradeHistory.addAll(newTrades);
        }

        // Update pagination info
        _totalCount = response.data!.totalCount;
        _hasMore = response.data!.hasMore;
        _currentOffset = (_currentOffset ?? 0) + newTrades.length;

        print(
            '✅ Loaded ${newTrades.length} trade records (Total: ${_tradeHistory.length}/${_totalCount})');

        // Sort by close time (most recent first)
        _tradeHistory.sort((a, b) => b.closeTime.compareTo(a.closeTime));
      } else {
        // Handle API error
        print(
            '❌ Failed to load trade history: ${response?.message ?? 'Unknown error'}');
        _tradeHistory = [];

        // Show error message to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to load trade history: ${response?.message ?? 'Please check your connection'}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error loading trade history: $e');
      _tradeHistory = [];

      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Network error: Please check your connection and try again',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Load trading report data for summary stats
  Future<void> _loadTradingReport() async {
    try {
      print('🔄 Loading dual-side trading report...');

      // Format dates for API
      String? dateFromStr;
      String? dateToStr;
      if (_dateFrom != null) {
        dateFromStr =
            '${_dateFrom!.year}-${_dateFrom!.month.toString().padLeft(2, '0')}-${_dateFrom!.day.toString().padLeft(2, '0')}';
      }
      if (_dateTo != null) {
        dateToStr =
            '${_dateTo!.year}-${_dateTo!.month.toString().padLeft(2, '0')}-${_dateTo!.day.toString().padLeft(2, '0')}';
      }

      // Call the trading report API
      final response = await FutureTradingService.getDualSideTradingReport(
        userId: commonuserId,
        dateFrom: dateFromStr,
        dateTo: dateToStr,
      );

      if (response != null && response.isSuccess && response.data != null) {
        setState(() {
          _reportData = response.data;
        });
        print('✅ Loaded trading report data successfully');
      } else {
        print('❌ Failed to load trading report: ${response?.message}');
      }
    } catch (e) {
      print('❌ Error loading trading report: $e');
    }
  }

  // Navigate to trading report page
  void _navigateToTradingReport() {
    // Format dates for API if filters are applied
    String? dateFromStr;
    String? dateToStr;
    if (_dateFrom != null) {
      dateFromStr =
          '${_dateFrom!.year}-${_dateFrom!.month.toString().padLeft(2, '0')}-${_dateFrom!.day.toString().padLeft(2, '0')}';
    }
    if (_dateTo != null) {
      dateToStr =
          '${_dateTo!.year}-${_dateTo!.month.toString().padLeft(2, '0')}-${_dateTo!.day.toString().padLeft(2, '0')}';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TradingReportPage(
          dateFrom: dateFromStr,
          dateTo: dateToStr,
        ),
      ),
    );
  }

  // Load more trades (pagination)
  Future<void> _loadMoreTrades() async {
    if (!_hasMore || _isLoading) return;

    await _loadTradeHistory(isRefresh: false);
  }

  // Apply filters and reload
  Future<void> _applyFilters() async {
    await _loadTradeHistory(isRefresh: true);
    await _loadTradingReport(); // Also reload trading report with new filters
  }

  // Reset all filters
  void _resetFilters() {
    setState(() {
      _selectedSymbol = null;
      _selectedStatus = null;
      _selectedStrategyType = null;
      _dateFrom = null;
      _dateTo = null;
      _currentLimit = null;
    });
    _applyFilters();
  }

  // Show filter dialog
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterDialog(),
    );
  }

  Widget _buildFilterDialog() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: TradingTheme.secondaryBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: TradingTheme.hintText,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Filter Trade History',
                      style: TradingTypography.heading3,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        _resetFilters();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Reset',
                        style: TradingTypography.bodyMedium.copyWith(
                          color: TradingTheme.primaryAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filter content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSymbolFilter(setModalState),
                      const SizedBox(height: 20),
                      _buildStatusFilter(setModalState),
                      const SizedBox(height: 20),
                      _buildStrategyTypeFilter(setModalState),
                      const SizedBox(height: 20),
                      _buildDateRangeFilter(setModalState),
                    ],
                  ),
                ),
              ),

              // Apply button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _applyFilters();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TradingTheme.primaryAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: TradingTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSymbolFilter(StateSetter setModalState) {
    final symbols = [
      'BTCUSDT',
      'ETHUSDT',
      'BNBUSDT',
      'ADAUSDT',
      'SOLUSDT',
      'DOGEUSDT'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trading Pair',
          style: TradingTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              'All Pairs',
              _selectedSymbol == null,
              () => setModalState(() => _selectedSymbol = null),
            ),
            ...symbols.map((symbol) => _buildFilterChip(
                  symbol,
                  _selectedSymbol == symbol,
                  () => setModalState(() => _selectedSymbol = symbol),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusFilter(StateSetter setModalState) {
    final statuses = [
      {'key': 'CLOSED', 'label': 'Closed'},
      {'key': 'OPEN', 'label': 'Open'},
      {'key': 'CANCELLED', 'label': 'Cancelled'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: TradingTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              'All Status',
              _selectedStatus == null,
              () => setModalState(() => _selectedStatus = null),
            ),
            ...statuses.map((status) => _buildFilterChip(
                  status['label']!,
                  _selectedStatus == status['key'],
                  () => setModalState(() => _selectedStatus = status['key']!),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildStrategyTypeFilter(StateSetter setModalState) {
    final strategies = [
      {'key': 'DUAL_SIDE', 'label': 'Dual Side'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Strategy Type',
          style: TradingTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              'All Strategies',
              _selectedStrategyType == null,
              () => setModalState(() => _selectedStrategyType = null),
            ),
            ...strategies.map((strategy) => _buildFilterChip(
                  strategy['label']!,
                  _selectedStrategyType == strategy['key'],
                  () => setModalState(
                      () => _selectedStrategyType = strategy['key']!),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: TradingTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDatePicker(
                'From Date',
                _dateFrom,
                (date) => setModalState(() => _dateFrom = date),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDatePicker(
                'To Date',
                _dateTo,
                (date) => setModalState(() => _dateTo = date),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? TradingTheme.primaryAccent
              : TradingTheme.surfaceBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? TradingTheme.primaryAccent
                : TradingTheme.primaryBorder,
          ),
        ),
        child: Text(
          label,
          style: TradingTypography.bodySmall.copyWith(
            color: isSelected ? Colors.black : TradingTheme.primaryText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(
      String label, DateTime? date, Function(DateTime?) onChanged) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.dark(
                  brightness: Brightness.dark,
                  primary: TradingTheme
                      .primaryAccent, // Selected date background (yellow)
                  onPrimary:
                      Colors.black, // Selected date text (black on yellow)
                  surface:
                      TradingTheme.cardBackground, // Calendar background (dark)
                  onSurface: Colors
                      .white, // Calendar dates text (WHITE - force override)
                  background: TradingTheme.cardBackground, // Dialog background
                  onBackground: Colors.white, // Text on dialog background
                  secondary:
                      TradingTheme.primaryAccent, // Today's date highlight
                  onSecondary: Colors.black, // Today's date text
                ),
                dialogBackgroundColor: TradingTheme.cardBackground,
                textTheme: ThemeData.dark().textTheme.copyWith(
                      headlineSmall: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500), // Month/year header
                      bodyLarge: const TextStyle(
                          color: Colors.white), // Date numbers - FORCE WHITE
                      bodyMedium: const TextStyle(
                          color: Colors.white), // Weekday labels - FORCE WHITE
                      labelLarge:
                          const TextStyle(color: Colors.white), // Button text
                    ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor:
                        TradingTheme.primaryAccent, // CANCEL/OK button text
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: TradingTheme.surfaceBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: TradingTheme.primaryBorder),
        ),
        child: Column(
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
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Select date',
              style: TradingTypography.bodyMedium.copyWith(
                color: date != null
                    ? TradingTheme.primaryText
                    : TradingTheme.hintText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FutureTradeHistory> get _filteredHistory {
    switch (_filterType) {
      case 'LONG':
        return _tradeHistory.where((trade) => trade.isLong).toList();
      case 'SHORT':
        return _tradeHistory.where((trade) => trade.isShort).toList();
      case 'ALL':
      default:
        return _tradeHistory;
    }
  }

  // Check if any filters are active
  bool _hasActiveFilters() {
    return _selectedSymbol != null ||
        _selectedStatus != null ||
        _selectedStrategyType != null ||
        _dateFrom != null ||
        _dateTo != null ||
        _currentLimit != null ||
        _currentOffset != null;
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
    return CommonAppBar.basic(
      title: "Trade History",
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: TradingTheme.accentGradient,
            borderRadius: BorderRadius.circular(10),
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
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color: _hasActiveFilters()
                ? TradingTheme.primaryAccent
                : TradingTheme.primaryText,
          ),
          onPressed: _showFilterDialog,
          tooltip: 'Filter trades',
        ),
      ],
    );
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
      // actions: [
      //   IconButton(
      //     icon: Icon(
      //       Icons.filter_list,
      //       color: _hasActiveFilters()
      //           ? TradingTheme.primaryAccent
      //           : TradingTheme.primaryText,
      //     ),
      //     onPressed: _showFilterDialog,
      //     tooltip: 'Filter trades',
      //   ),
      // ],
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
              onRefresh: () async {
                await _loadTradeHistory(isRefresh: true);
                await _loadTradingReport();
              },
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
      {'key': 'LONG', 'label': 'Long', 'icon': Icons.north},
      {'key': 'SHORT', 'label': 'Short', 'icon': Icons.south},
    ];

    return Container(
      width: double.infinity, // Occupy full width
      padding: const EdgeInsets.all(16),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _filterType == filter['key'];
          return Expanded(
            // Each tab takes equal width
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TradingButton(
                text: filter['label'] as String,
                onPressed: () =>
                    setState(() => _filterType = filter['key'] as String),
                backgroundColor: isSelected
                    ? TradingTheme.primaryAccent
                    : TradingTheme.surfaceBackground,
                textColor: isSelected ? Colors.black : TradingTheme.primaryText,
                height: 40,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryStats() {
    // Use report data if available, otherwise calculate from filtered history
    double totalPnl;
    double winRate;
    int totalTrades;

    if (_reportData != null) {
      // Use data from dual_side_trading_report API
      totalPnl = _reportData!.overview.totalPnl;
      winRate = _reportData!.overview.winRate;
      totalTrades = _reportData!.overview.totalTrades;
    } else {
      // Fallback to calculating from filtered history
      totalPnl = _filteredHistory.fold<double>(
          0, (sum, trade) => sum + trade.realizedPnl);
      final profitTrades = _filteredHistory.where((t) => t.isProfit).length;
      totalTrades = _filteredHistory.length;
      winRate = totalTrades > 0 ? (profitTrades / totalTrades * 100) : 0.0;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: AnimatedTradingCard(
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Total PnL',
                '\$${totalPnl.toStringAsFixed(4)}',
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
            Container(width: 1, height: 40, color: TradingTheme.primaryBorder),
            // Trading Report Button
            Expanded(
              child: InkWell(
                onTap: _navigateToTradingReport,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: TradingTheme.primaryAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.analytics,
                          color: Colors.black,
                          size: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Report',
                        style: TradingTypography.bodySmall.copyWith(
                          color: TradingTheme.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
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
                    '\$${trade.realizedPnl.toStringAsFixed(4)}',
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
                    'Fees', '\$${trade.fees.toStringAsFixed(4)}'),
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
