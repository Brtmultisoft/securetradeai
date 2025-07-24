import 'package:flutter/material.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/model/future_trading_models.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/Service/future_trading_service.dart';
import 'package:securetradeai/src/widget/trading_widgets.dart';

class TradingReportPage extends StatefulWidget {
  final String? dateFrom;
  final String? dateTo;

  const TradingReportPage({
    Key? key,
    this.dateFrom,
    this.dateTo,
  }) : super(key: key);

  @override
  State<TradingReportPage> createState() => _TradingReportPageState();
}

class _TradingReportPageState extends State<TradingReportPage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  DualSideTradingReportData? _reportData;
  bool _isLoading = true;

  // Date filter state
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    _initializeFilters();
    _initializeAnimations();
    _loadTradingReport();
  }

  void _initializeFilters() {
    // Initialize date filters from widget parameters
    if (widget.dateFrom != null && widget.dateFrom!.isNotEmpty) {
      _dateFrom = DateTime.tryParse(widget.dateFrom!);
    }
    if (widget.dateTo != null && widget.dateTo!.isNotEmpty) {
      _dateTo = DateTime.tryParse(widget.dateTo!);
    }
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();
  }

  Future<void> _loadTradingReport() async {
    setState(() => _isLoading = true);

    try {
      print('📊 Loading trading report...');

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

      final response = await FutureTradingService.getDualSideTradingReport(
        userId: commonuserId,
        dateFrom: dateFromStr,
        dateTo: dateToStr,
      );

      if (response != null && response.isSuccess && response.data != null) {
        setState(() {
          _reportData = response.data;
        });

        print('✅ Trading report loaded successfully');
        print('💰 Total PnL: \$${_reportData!.overview.totalPnl}');
      } else {
        print(
            '❌ Failed to load trading report: ${response?.message ?? 'Unknown error'}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to load trading report: ${response?.message ?? 'Please try again'}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error loading trading report: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Network error: Please check your connection and try again',
              style: TextStyle(color: Colors.white),
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

  // Check if any filters are active
  bool _hasActiveFilters() {
    return _dateFrom != null || _dateTo != null;
  }

  // Reset all filters
  void _resetFilters() {
    setState(() {
      _dateFrom = null;
      _dateTo = null;
    });
    _loadTradingReport();
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

  // Build filter dialog
  Widget _buildFilterDialog() {
    return StatefulBuilder(
      builder: (context, setModalState) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TradingTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Filter Trading Report',
                    style: TradingTypography.heading3,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _dateFrom = null;
                        _dateTo = null;
                      });
                    },
                    child: Text(
                      'Clear All',
                      style: TradingTypography.bodyMedium.copyWith(
                        color: TradingTheme.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date Range Section
              Text(
                'Date Range',
                style: TradingTypography.bodyLarge.copyWith(
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
              const SizedBox(height: 24),

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _loadTradingReport();
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
                    style: TradingTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build date picker widget
  Widget _buildDatePicker(String label, DateTime? selectedDate, Function(DateTime?) onDateSelected) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.dark(
                  brightness: Brightness.dark,
                  primary: TradingTheme.primaryAccent, // Selected date background (yellow)
                  onPrimary: Colors.black, // Selected date text (black on yellow)
                  surface: TradingTheme.cardBackground, // Calendar background (dark)
                  onSurface: Colors.white, // Calendar dates text (WHITE - force override)
                  background: TradingTheme.cardBackground, // Dialog background
                  onBackground: Colors.white, // Text on dialog background
                  secondary: TradingTheme.primaryAccent, // Today's date highlight
                  onSecondary: Colors.black, // Today's date text
                ),
                dialogBackgroundColor: TradingTheme.cardBackground,
                textTheme: ThemeData.dark().textTheme.copyWith(
                  headlineSmall: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500), // Month/year header
                  bodyLarge: const TextStyle(color: Colors.white), // Date numbers - FORCE WHITE
                  bodyMedium: const TextStyle(color: Colors.white), // Weekday labels - FORCE WHITE
                  labelLarge: const TextStyle(color: Colors.white), // Button text
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: TradingTheme.primaryAccent, // CANCEL/OK button text
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: TradingTheme.primaryBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: TradingTheme.primaryBorder.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: TradingTheme.secondaryText,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TradingTypography.bodySmall.copyWith(
                      color: TradingTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedDate != null
                        ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                        : 'Select date',
                    style: TradingTypography.bodyMedium.copyWith(
                      color: selectedDate != null
                          ? TradingTheme.primaryText
                          : TradingTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
      body: _isLoading ? _buildLoadingScreen() : _buildReportContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: TradingTheme.primaryBackground,
      elevation: 0,
      title: Row(
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
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            'Trading Report',
            style: TradingTypography.heading3,
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: TradingTheme.primaryText),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // Filter button
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color: _hasActiveFilters()
                ? TradingTheme.primaryAccent
                : TradingTheme.primaryText,
          ),
          onPressed: _showFilterDialog,
        ),
        // Reset filters button (only show if filters are active)
        if (_hasActiveFilters())
          IconButton(
            icon: const Icon(
              Icons.clear,
              color: TradingTheme.secondaryText,
            ),
            onPressed: _resetFilters,
          ),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: TradingLoadingIndicator(
        message: 'Loading Trading Report...',
      ),
    );
  }

  Widget _buildReportContent() {
    if (_reportData == null) {
      return _buildErrorState();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalPnlCard(),
            _buildOverviewCard(),
            _buildPositionAnalysisCard(),
            _buildCurrentPositionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: TradingTheme.errorColor,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Report',
            style: TradingTypography.heading3.copyWith(
              color: TradingTheme.errorColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TradingTypography.bodyMedium.copyWith(
              color: TradingTheme.hintText,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadTradingReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: TradingTheme.primaryAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPnlCard() {
    final totalPnl = _reportData!.overview.totalPnl; // Use API value directly
    final unrealizedPnl = _reportData!.overview.unrealizedPnl;
    final isProfit = totalPnl >= 0;

    return AnimatedTradingCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isProfit
                ? [
                    const Color(0xFF00C853),
                    const Color(0xFF4CAF50),
                    const Color(0xFF66BB6A),
                  ]
                : [
                    const Color(0xFFD32F2F),
                    const Color(0xFFE57373),
                    const Color(0xFFEF5350),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  (isProfit ? const Color(0xFF00C853) : const Color(0xFFD32F2F))
                      .withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icon with glow effect
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                isProfit
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Total PnL',
              style: TradingTypography.bodyLarge.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),

            Text(
              '\$${totalPnl.toStringAsFixed(4)}', // 4 decimal places
              style: TradingTypography.heading1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 42,
                letterSpacing: -1,
              ),
            ),
            if (unrealizedPnl != 0) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white.withOpacity(0.8),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Unrealized: \$${unrealizedPnl.toStringAsFixed(4)}',
                      style: TradingTypography.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    final overview = _reportData!.overview;

    return Container(
      child: AnimatedTradingCard(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: TradingTheme.primaryAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.analytics_outlined,
                      color: TradingTheme.primaryAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Trading Overview',
                    style: TradingTypography.heading3.copyWith(
                      color: TradingTheme.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: _buildEnhancedStatItem(
                          'Total Trades',
                          overview.totalTrades.toString(),
                          Icons.bar_chart,
                          TradingTheme.primaryAccent)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildEnhancedStatItem(
                          'Win Rate',
                          '${overview.winRate.toStringAsFixed(1)}%',
                          Icons.percent,
                          overview.winRate >= 50
                              ? TradingTheme.successColor
                              : TradingTheme.errorColor)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildEnhancedStatItem(
                          'Best Trade',
                          '\$${overview.bestTrade.toStringAsFixed(4)}',
                          Icons.trending_up,
                          TradingTheme.successColor)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildEnhancedStatItem(
                          'Worst Trade',
                          '\$${overview.worstTrade.toStringAsFixed(4)}',
                          Icons.trending_down,
                          TradingTheme.errorColor)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildEnhancedStatItem(
                          'Avg Trade',
                          '\$${overview.avgTradePnl.toStringAsFixed(4)}',
                          Icons.analytics,
                          overview.avgTradePnl >= 0
                              ? TradingTheme.successColor
                              : TradingTheme.errorColor)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildEnhancedStatItem(
                          'Profit Factor',
                          overview.profitFactor.toStringAsFixed(2),
                          Icons.functions,
                          overview.profitFactor >= 1
                              ? TradingTheme.successColor
                              : TradingTheme.errorColor)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPositionAnalysisCard() {
    final analysis = _reportData!.positionAnalysis;

    return AnimatedTradingCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Position Analysis',
              style: TradingTypography.heading3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TradingTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: TradingTheme.successColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.north, color: TradingTheme.successColor),
                        const SizedBox(height: 8),
                        Text('Long Positions',
                            style: TradingTypography.bodySmall),
                        const SizedBox(height: 4),
                        Text('${analysis.longTrades} trades',
                            style: TradingTypography.bodyMedium
                                .copyWith(fontWeight: FontWeight.w600)),
                        Text('\$${analysis.longPnl.toStringAsFixed(2)}',
                            style: TradingTypography.bodyMedium
                                .copyWith(color: TradingTheme.successColor)),
                        Text(
                            '${analysis.longWinRate.toStringAsFixed(1)}% win rate',
                            style: TradingTypography.bodySmall),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TradingTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: TradingTheme.errorColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.south, color: TradingTheme.errorColor),
                        const SizedBox(height: 8),
                        Text('Short Positions',
                            style: TradingTypography.bodySmall),
                        const SizedBox(height: 4),
                        Text('${analysis.shortTrades} trades',
                            style: TradingTypography.bodyMedium
                                .copyWith(fontWeight: FontWeight.w600)),
                        Text('\$${analysis.shortPnl.toStringAsFixed(2)}',
                            style: TradingTypography.bodyMedium
                                .copyWith(color: TradingTheme.errorColor)),
                        Text(
                            '${analysis.shortWinRate.toStringAsFixed(1)}% win rate',
                            style: TradingTypography.bodySmall),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedStatItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: TradingTheme.primaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TradingTypography.bodySmall.copyWith(
              color: TradingTheme.hintText,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TradingTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPositionsCard() {
    final overview = _reportData!.overview;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: AnimatedTradingCard(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: TradingTheme.primaryAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: TradingTheme.primaryAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Current Status',
                    style: TradingTypography.heading3.copyWith(
                      color: TradingTheme.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildEnhancedStatItem(
                        'Total Volume',
                        '\$${overview.totalVolume.toStringAsFixed(4)}',
                        Icons.bar_chart,
                        TradingTheme.primaryAccent),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildEnhancedStatItem(
                        'Unrealized PnL',
                        '\$${overview.unrealizedPnl.toStringAsFixed(4)}',
                        Icons.account_balance_wallet,
                        overview.unrealizedPnl >= 0
                            ? TradingTheme.successColor
                            : TradingTheme.errorColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
