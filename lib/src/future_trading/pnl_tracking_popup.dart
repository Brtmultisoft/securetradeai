import 'package:flutter/material.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/model/future_trading_models.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/Service/future_trading_service.dart';

class PnlTrackingPopup extends StatefulWidget {
  const PnlTrackingPopup({Key? key}) : super(key: key);

  @override
  State<PnlTrackingPopup> createState() => _PnlTrackingPopupState();
}

class _PnlTrackingPopupState extends State<PnlTrackingPopup> {
  PnlTrackingData? _pnlData;
  bool _isLoading = true;
  String? _errorMessage;

  // Period filter state
  String _selectedPeriod = 'daily';
  int _selectedLimit = 30;

  final List<Map<String, dynamic>> _periodOptions = [
    {'value': 'daily', 'label': 'Daily', 'limit': 30},
    {'value': 'weekly', 'label': 'Weekly', 'limit': 12},
    {'value': 'monthly', 'label': 'Monthly', 'limit': 6},
  ];

  @override
  void initState() {
    super.initState();
    _loadPnlData();
  }

  Future<void> _loadPnlData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔄 Loading dual-side PnL tracking data...');

      final response = await FutureTradingService.getDualSidePnlTracking(
        userId: commonuserId,
        period: _selectedPeriod,
        limit: _selectedLimit,
      );

      if (response != null && response.isSuccess) {
        if (response.data != null && response.data!.pnlTracking.isNotEmpty) {
          setState(() {
            _pnlData = response.data;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage =
                'No PnL tracking data available for the selected period.\n\nThis could be because:\n• No trades have been executed yet\n• The selected period has no trading activity\n• PnL data is still being calculated';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              response?.message ?? 'Failed to load PnL tracking data';
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
                      : _buildPnlContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16),
      decoration: BoxDecoration(
        color: TradingTheme.secondaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TradingTheme.primaryAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.trending_up,
              color: TradingTheme.primaryAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'PnL Tracking',
            style: TradingTypography.heading3,
          ),
          const Spacer(),
          IconButton(
            onPressed: _showPeriodFilterDialog,
            icon: const Icon(
              Icons.tune,
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
          CircularProgressIndicator(
            color: TradingTheme.primaryAccent,
          ),
          SizedBox(height: 16),
          Text(
            'Loading PnL tracking data...',
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
          Text(
            'Error Loading PnL Data',
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
            onPressed: _loadPnlData,
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

  Widget _buildPnlContent() {
    if (_pnlData == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodInfo(),
          const SizedBox(height: 24),
          _buildOverviewSection(),
          const SizedBox(height: 24),
          _buildPnlRecordsSection(),
        ],
      ),
    );
  }

  Widget _buildPeriodInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TradingTheme.primaryAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: TradingTheme.primaryAccent.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: TradingTheme.primaryAccent,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Period: ${_pnlData!.period.toUpperCase()}',
            style: TradingTypography.bodyMedium.copyWith(
              color: TradingTheme.primaryAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            '${_pnlData!.pnlTracking.length} records',
            style: TradingTypography.bodySmall.copyWith(
              color: TradingTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    if (_pnlData == null || _pnlData!.pnlTracking.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate overview statistics from PnL records
    final records = _pnlData!.pnlTracking;
    final totalPnl =
        records.fold<double>(0, (sum, record) => sum + record.totalPnl);
    final totalTrades =
        records.fold<int>(0, (sum, record) => sum + record.tradeCount);
    final totalWinningTrades =
        records.fold<int>(0, (sum, record) => sum + record.winningTrades);
    final avgPnl = records.isNotEmpty
        ? records.fold<double>(0, (sum, record) => sum + record.avgPnl) /
            records.length
        : 0.0;
    final bestTrade = records.fold<double>(
        0, (max, record) => record.bestTrade > max ? record.bestTrade : max);
    final worstTrade = records.fold<double>(
        0, (min, record) => record.worstTrade < min ? record.worstTrade : min);
    final totalVolume =
        records.fold<double>(0, (sum, record) => sum + record.totalVolume);
    final avgWinRate = records.isNotEmpty
        ? records.fold<double>(0, (sum, record) => sum + record.winRate) /
            records.length
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TradingTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TradingTheme.primaryBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PnL Overview',
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
                  'Avg PnL',
                  '\$${avgPnl.toStringAsFixed(2)}',
                  avgPnl >= 0
                      ? TradingTheme.successColor
                      : TradingTheme.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Best Trade',
                  '\$${bestTrade.toStringAsFixed(2)}',
                  TradingTheme.successColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Worst Trade',
                  '\$${worstTrade.toStringAsFixed(2)}',
                  TradingTheme.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Volume',
                  '\$${totalVolume.toStringAsFixed(2)}',
                  TradingTheme.primaryAccent,
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
        ],
      ),
    );
  }

  Widget _buildPnlRecordsSection() {
    if (_pnlData == null || _pnlData!.pnlTracking.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TradingTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TradingTheme.primaryBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PnL Records (${_pnlData!.period.toUpperCase()})',
            style: TradingTypography.heading3,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: _pnlData!.pnlTracking.length,
              itemBuilder: (context, index) {
                final record = _pnlData!.pnlTracking[index];
                return _buildPnlRecordCard(record);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPnlRecordCard(PnlTrackingRecord record) {
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
                record.period,
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
                  '\$${record.totalPnl.toStringAsFixed(2)}',
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
                  record.tradeCount.toString(),
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
                  'Avg PnL',
                  '\$${record.avgPnl.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSmallStatItem(
                  'Best',
                  '\$${record.bestTrade.toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _buildSmallStatItem(
                  'Worst',
                  '\$${record.worstTrade.toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _buildSmallStatItem(
                  'Volume',
                  '\$${record.totalVolume.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
        ],
      ),
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

  void _showPeriodFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPeriodFilterDialog(),
    );
  }

  Widget _buildPeriodFilterDialog() {
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
                  Text(
                    'Select Period',
                    style: TradingTypography.heading3,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _selectedPeriod = 'daily';
                        _selectedLimit = 30;
                      });
                    },
                    child: Text(
                      'Reset',
                      style: TradingTypography.bodyMedium.copyWith(
                        color: TradingTheme.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Period Options
              ...(_periodOptions.map((option) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        setModalState(() {
                          _selectedPeriod = option['value'];
                          _selectedLimit = option['limit'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedPeriod == option['value']
                              ? TradingTheme.primaryAccent.withOpacity(0.2)
                              : TradingTheme.primaryBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedPeriod == option['value']
                                ? TradingTheme.primaryAccent
                                : TradingTheme.primaryBorder.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedPeriod == option['value']
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: _selectedPeriod == option['value']
                                  ? TradingTheme.primaryAccent
                                  : TradingTheme.secondaryText,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option['label'],
                                    style:
                                        TradingTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: _selectedPeriod == option['value']
                                          ? TradingTheme.primaryAccent
                                          : TradingTheme.primaryText,
                                    ),
                                  ),
                                  Text(
                                    'Last ${option['limit']} records',
                                    style: TradingTypography.bodySmall.copyWith(
                                      color: TradingTheme.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))).toList(),

              const SizedBox(height: 24),

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _loadPnlData();
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
                    'Apply Filter',
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
}
