import 'package:flutter/material.dart';
import 'package:rapidtradeai/data/strings.dart';
import 'package:rapidtradeai/model/future_trading_models.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';
import 'package:rapidtradeai/src/Service/future_trading_service.dart';

class MonitorTpSlPopup extends StatefulWidget {
  const MonitorTpSlPopup({Key? key}) : super(key: key);

  @override
  State<MonitorTpSlPopup> createState() => _MonitorTpSlPopupState();
}

class _MonitorTpSlPopupState extends State<MonitorTpSlPopup> {
  bool _isLoading = true;
  String? _errorMessage;
  MonitorTpSlData? _monitorData;

  @override
  void initState() {
    super.initState();
    _loadMonitorData();
  }

  Future<void> _loadMonitorData() async {
    print('🎯 MONITOR TP/SL - Starting data load...');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔄 MONITOR TP/SL - Calling API...');
      print('  User ID: $commonuserId');

      final response = await FutureTradingService.getDualSideMonitorTpSl(
        userId: commonuserId,
      );

      print('📡 MONITOR TP/SL - API Response received');
      print('  Response: $response');
      print('  Is Success: ${response?.isSuccess}');
      print('  Status: ${response?.status}');
      print('  Message: ${response?.message}');
      print('  Response Code: ${response?.responsecode}');

      if (response != null && response.isSuccess) {
        if (response.data != null) {
          print('✅ MONITOR TP/SL - Success! Response data:');
          print('  Executed TP/SL: ${response.data!.executedTpSl}');
          print('  Positions Checked: ${response.data!.positionsChecked}');
          print('  Executed Positions: ${response.data!.executedPositions}');
          print('  Last Check: ${response.data!.lastCheck}');
          print('  Has Executions: ${response.data!.hasExecutions}');

          setState(() {
            _monitorData = response.data;
            _isLoading = false;
          });
        } else {
          print('⚠️ MONITOR TP/SL - No data in response');
          setState(() {
            _errorMessage =
                'No TP/SL monitoring data available.\n\nThis could be because:\n• No active positions with TP/SL\n• Monitoring system is initializing\n• No recent TP/SL activity';
            _isLoading = false;
          });
        }
      } else {
        print('❌ MONITOR TP/SL - API Error:');
        print('  Status: ${response?.status}');
        print('  Message: ${response?.message}');
        print('  Response Code: ${response?.responsecode}');

        setState(() {
          _errorMessage =
              response?.message ?? 'Failed to load TP/SL monitoring data';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ MONITOR TP/SL - Exception occurred: $e');
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
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        decoration: BoxDecoration(
          color: TradingTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: TradingTheme.primaryBorder.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
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
      padding: const EdgeInsets.only(left: 8, right: 8, top: 10, bottom: 10),
      decoration: const BoxDecoration(
        color: TradingTheme.secondaryBackground,
        borderRadius: BorderRadius.only(
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
              Icons.monitor_heart,
              color: TradingTheme.primaryAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Monitor TP/SL',
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
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: TradingTheme.primaryAccent),
          const SizedBox(height: 16),
          const Text(
            'Loading TP/SL monitoring data...',
            style: TradingTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: TradingTheme.errorColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error Loading TP/SL Data',
            style: TradingTypography.heading3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TradingTypography.bodyMedium.copyWith(
              color: TradingTheme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loadMonitorData,
              style: ElevatedButton.styleFrom(
                backgroundColor: TradingTheme.primaryAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
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
          _buildExecutionsSection(),
        ],
      ),
    );
  }

  Widget _buildStatusInfo() {
    final hasExecutions = _monitorData!.hasExecutions;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasExecutions
            ? TradingTheme.warningColor.withOpacity(0.1)
            : TradingTheme.primaryAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasExecutions
              ? TradingTheme.warningColor.withOpacity(0.3)
              : TradingTheme.primaryAccent.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                hasExecutions ? Icons.notifications_active : Icons.monitor,
                color: hasExecutions
                    ? TradingTheme.warningColor
                    : TradingTheme.primaryAccent,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                hasExecutions
                    ? 'TP/SL Executions Detected'
                    : 'TP/SL Monitoring Active',
                style: TradingTypography.bodyMedium.copyWith(
                  color: hasExecutions
                      ? TradingTheme.warningColor
                      : TradingTheme.primaryAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
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
          const Text(
            'TP/SL Monitoring Overview',
            style: TradingTypography.heading3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Executed TP/SL',
                  _monitorData!.executedTpSl.toString(),
                  _monitorData!.executedTpSl > 0
                      ? TradingTheme.warningColor
                      : TradingTheme.primaryAccent,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Positions Checked',
                  _monitorData!.positionsChecked.toString(),
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
                  'Execution Status',
                  _monitorData!.hasExecutions ? 'Active' : 'Monitoring',
                  _monitorData!.hasExecutions
                      ? TradingTheme.warningColor
                      : TradingTheme.successColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'System Status',
                  'Online',
                  TradingTheme.successColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionsSection() {
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
          const Text(
            'Recent Executions',
            style: TradingTypography.heading3,
          ),
          const SizedBox(height: 16),
          if (_monitorData!.executedPositions.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TradingTheme.secondaryBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: TradingTheme.primaryAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No recent TP/SL executions',
                      style: TradingTypography.bodyMedium.copyWith(
                        color: TradingTheme.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...(_monitorData!.executedPositions
                .map(
                  (position) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TradingTheme.secondaryBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: TradingTheme.warningColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: TradingTheme.warningColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.gps_fixed,
                            color: TradingTheme.warningColor,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Position: $position',
                            style: TradingTypography.bodyMedium,
                          ),
                        ),
                        Text(
                          'Executed',
                          style: TradingTypography.bodySmall.copyWith(
                            color: TradingTheme.warningColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
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
          style: TradingTypography.heading3.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}
