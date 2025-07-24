import 'package:flutter/material.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/model/future_trading_models.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/Service/future_trading_service.dart';

class StrategyMonitorPopup extends StatefulWidget {
  const StrategyMonitorPopup({Key? key}) : super(key: key);

  @override
  State<StrategyMonitorPopup> createState() => _StrategyMonitorPopupState();
}

class _StrategyMonitorPopupState extends State<StrategyMonitorPopup> {
  MonitorData? _monitorData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMonitorData();
  }

  Future<void> _loadMonitorData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔄 Loading dual-side strategy monitoring data...');

      final response = await FutureTradingService.getDualSideMonitor(
        userId: commonuserId,
      );

      if (response != null && response.isSuccess) {
        if (response.data != null) {
          setState(() {
            _monitorData = response.data;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage =
                'No monitoring data available.\n\nThis could be because:\n• No active strategies are running\n• Monitoring system is initializing\n• No recent strategy activity';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = response?.message ?? 'Failed to load monitoring data';
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
                      : _buildMonitorContent(),
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
          // Container(
          //   padding: const EdgeInsets.all(8),
          //   decoration: BoxDecoration(
          //     color: TradingTheme.primaryAccent.withOpacity(0.2),
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   child: const Icon(
          //     Icons.monitor_heart,
          //     color: TradingTheme.primaryAccent,
          //     size: 20,
          //   ),
          // ),
          // const SizedBox(width: 10),
          Text(
            'Strategy Monitor',
            style: TradingTypography.heading3,
          ),
          const Spacer(),
          IconButton(
            onPressed: _loadMonitorData,
            icon: const Icon(
              Icons.refresh,
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
            'Loading strategy monitoring data...',
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
            'Error Loading Monitor Data',
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
            onPressed: _loadMonitorData,
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

  Widget _buildMonitorContent() {
    if (_monitorData == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusInfo(),
          const SizedBox(height: 24),
          _buildOverviewSection(),
          const SizedBox(height: 24),
          _buildActivitySection(),
        ],
      ),
    );
  }

  Widget _buildStatusInfo() {
    final hasActivity = _monitorData!.hasActivity;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasActivity
            ? TradingTheme.successColor.withOpacity(0.1)
            : TradingTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasActivity
              ? TradingTheme.successColor.withOpacity(0.3)
              : TradingTheme.primaryBorder.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasActivity ? Icons.check_circle : Icons.info,
            color: hasActivity
                ? TradingTheme.successColor
                : TradingTheme.primaryAccent,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            hasActivity ? 'Active Monitoring' : 'Monitoring Active',
            style: TradingTypography.bodyMedium.copyWith(
              color: hasActivity
                  ? TradingTheme.successColor
                  : TradingTheme.primaryAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            'Last Check: ${_monitorData!.lastCheck}',
            style: TradingTypography.bodySmall.copyWith(
              color: TradingTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
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
            'Monitoring Overview',
            style: TradingTypography.heading3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'TP Hits',
                  _monitorData!.tpHits.toString(),
                  _monitorData!.tpHits > 0
                      ? TradingTheme.successColor
                      : TradingTheme.primaryAccent,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Strategies Checked',
                  _monitorData!.strategiesChecked.toString(),
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
                  'Strategies Updated',
                  _monitorData!.strategiesUpdated.length.toString(),
                  _monitorData!.strategiesUpdated.isNotEmpty
                      ? TradingTheme.warningColor
                      : TradingTheme.primaryAccent,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Activity Status',
                  _monitorData!.hasActivity ? 'Active' : 'Idle',
                  _monitorData!.hasActivity
                      ? TradingTheme.successColor
                      : TradingTheme.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    if (_monitorData!.strategiesUpdated.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TradingTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: TradingTheme.primaryBorder.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: TradingTheme.successColor,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No Recent Updates',
              style: TradingTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'All strategies are running normally',
              style: TradingTypography.bodySmall.copyWith(
                color: TradingTheme.secondaryText,
              ),
            ),
          ],
        ),
      );
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
            'Updated Strategies',
            style: TradingTypography.heading3,
          ),
          const SizedBox(height: 16),
          ...(_monitorData!.strategiesUpdated.map((strategy) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TradingTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: TradingTheme.warningColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.update,
                      color: TradingTheme.warningColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        strategy,
                        style: TradingTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      'Updated',
                      style: TradingTypography.bodySmall.copyWith(
                        color: TradingTheme.warningColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ))).toList(),
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
}
