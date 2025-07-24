import 'package:flutter/material.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/model/future_trading_models.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/Service/future_trading_service.dart';
import 'package:securetradeai/src/widget/trading_widgets.dart';

class PerformancePopup extends StatefulWidget {
  const PerformancePopup({Key? key}) : super(key: key);

  @override
  State<PerformancePopup> createState() => _PerformancePopupState();
}

class _PerformancePopupState extends State<PerformancePopup> {
  List<DailyPerformanceRecord>? _performanceData;
  bool _isLoading = true;
  String? _errorMessage;

  // Date filter state
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    _loadPerformanceData();
  }

  Future<void> _loadPerformanceData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {

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

      // Call the performance API
      final response = await FutureTradingService.getDualSidePerformance(
        userId: commonuserId,
        dateFrom: dateFromStr,
        dateTo: dateToStr,
      );

      if (response != null && response.isSuccess) {
        if (response.data != null && response.data!.isNotEmpty) {
          setState(() {
            _performanceData = response.data;
            _isLoading = false;
          });
        } else {
          // API returned success but no data (empty array or null)
          setState(() {
            _errorMessage =
                'No performance data available for the selected period.\n\nThis could be because:\n• No trades have been executed yet\n• The selected date range has no trading activity\n• Performance data is still being calculated';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              response?.message ?? 'Failed to load performance data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: TradingTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TradingTheme.primaryBorder),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _buildPerformanceContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16),
      decoration: const BoxDecoration(
        color: TradingTheme.secondaryBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Performance Report',
            style: TradingTypography.heading3,
          ),
          IconButton(
            onPressed: _showDateFilterDialog,
            icon: const Icon(
              Icons.filter_list,
              color: TradingTheme.primaryAccent,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              color: TradingTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: TradingTheme.primaryAccent,
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading performance data...',
            style: TradingTypography.bodyMedium,
          ),
        ],
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
          const Text(
            'Error Loading Performance',
            style: TradingTypography.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error occurred',
            style: TradingTypography.bodyMedium.copyWith(
              color: TradingTheme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadPerformanceData,
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

  Widget _buildPerformanceContent() {
    if (_performanceData == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewSection(),
          const SizedBox(height: 24),
          _buildDailyPerformanceSection(),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    if (_performanceData == null || _performanceData!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate overview statistics from daily records
    final records = _performanceData!;
    final totalPnl =
        records.fold<double>(0, (sum, record) => sum + record.dailyPnl);
    final totalTrades =
        records.fold<int>(0, (sum, record) => sum + record.totalTrades);
    final totalWinningTrades =
        records.fold<int>(0, (sum, record) => sum + record.winningTrades);
    final avgWinRate = records.isNotEmpty
        ? records.fold<double>(0, (sum, record) => sum + record.winRate) /
            records.length
        : 0.0;
    final maxDrawdown = records.fold<double>(0,
        (min, record) => record.maxDrawdown < min ? record.maxDrawdown : min);
    final avgProfitPerTrade = records.isNotEmpty
        ? records.fold<double>(
                0, (sum, record) => sum + record.avgProfitPerTrade) /
            records.length
        : 0.0;

    return AnimatedTradingCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Overview',
              style: TradingTypography.heading3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total PnL',
                    '\$${totalPnl.toStringAsFixed(2)}',
                    totalPnl >= 0
                        ? TradingTheme.successColor
                        : TradingTheme.errorColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Trades',
                    totalTrades.toString(),
                    TradingTheme.primaryAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Win Rate',
                    '${avgWinRate.toStringAsFixed(1)}%',
                    avgWinRate >= 50
                        ? TradingTheme.successColor
                        : TradingTheme.errorColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Winning Trades',
                    totalWinningTrades.toString(),
                    TradingTheme.successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Avg Profit/Trade',
                    '\$${avgProfitPerTrade.toStringAsFixed(2)}',
                    avgProfitPerTrade >= 0
                        ? TradingTheme.successColor
                        : TradingTheme.errorColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Max Drawdown',
                    '\$${maxDrawdown.toStringAsFixed(2)}',
                    TradingTheme.errorColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyPerformanceSection() {
    if (_performanceData == null || _performanceData!.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedTradingCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Performance Records',
              style: TradingTypography.heading3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: _performanceData!.length,
                itemBuilder: (context, index) {
                  final record = _performanceData![index];
                  return _buildDailyRecordCard(record);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyRecordCard(DailyPerformanceRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TradingTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: record.isProfit
              ? TradingTheme.successColor.withOpacity(0.3)
              : TradingTheme.errorColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${record.symbol} - ${record.formattedDate}',
                style: TradingTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: record.isProfit
                      ? TradingTheme.successColor.withOpacity(0.2)
                      : TradingTheme.errorColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '\$${record.dailyPnl.toStringAsFixed(2)}',
                  style: TradingTypography.bodySmall.copyWith(
                    color: record.isProfit
                        ? TradingTheme.successColor
                        : TradingTheme.errorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSmallStatItem(
                  'Trades',
                  record.totalTrades.toString(),
                ),
              ),
              Expanded(
                child: _buildSmallStatItem(
                  'Win Rate',
                  '${record.winRate.toStringAsFixed(1)}%',
                ),
              ),
              Expanded(
                child: _buildSmallStatItem(
                  'Avg/Trade',
                  '\$${record.avgProfitPerTrade.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TradingTypography.bodySmall.copyWith(
            color: TradingTheme.secondaryText,
          ),
        ),
        Text(
          value,
          style: TradingTypography.bodySmall.copyWith(
            color: TradingTheme.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
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
          style: TradingTypography.bodyLarge.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showDateFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDateFilterDialog(),
    );
  }

  Widget _buildDateFilterDialog() {
    return StatefulBuilder(
      builder: (context, setModalState) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: TradingTheme.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
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
                  const Text(
                    'Filter Performance Report',
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
                    _loadPerformanceData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TradingTheme.primaryAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 16,
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

  Widget _buildDatePicker(String label, DateTime? selectedDate,
      Function(DateTime?) onDateSelected) {
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
                colorScheme: const ColorScheme.dark(
                  brightness: Brightness.dark,
                  primary: TradingTheme.primaryAccent,
                  onPrimary: Colors.black,
                  surface: TradingTheme.cardBackground,
                  onSurface: Colors.white,
                  background: TradingTheme.cardBackground,
                  onBackground: Colors.white,
                  secondary: TradingTheme.primaryAccent,
                  onSecondary: Colors.black,
                ),
                dialogBackgroundColor: TradingTheme.cardBackground,
                textTheme: ThemeData.dark().textTheme.copyWith(
                      headlineSmall: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                      bodyLarge: const TextStyle(color: Colors.white),
                      bodyMedium: const TextStyle(color: Colors.white),
                      labelLarge: const TextStyle(color: Colors.white),
                    ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: TradingTheme.primaryAccent,
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
            const Icon(
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
}
