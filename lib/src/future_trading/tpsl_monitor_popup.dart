import 'package:flutter/material.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/model/future_trading_models.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/Service/future_trading_service.dart';

class TpSlMonitorPopup extends StatefulWidget {
  const TpSlMonitorPopup({Key? key}) : super(key: key);

  @override
  State<TpSlMonitorPopup> createState() => _TpSlMonitorPopupState();
}

class _TpSlMonitorPopupState extends State<TpSlMonitorPopup> {
  MonitorTpSlData? _monitorData;
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
      print('🔄 Loading dual-side TP/SL monitoring data...');
      
      final response = await FutureTradingService.getDualSideMonitorTpSl(
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
                'No TP/SL monitoring data available.\n\nThis could be because:\n• No positions with TP/SL are active\n• Monitoring system is initializing\n• No recent TP/SL activity';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = response?.message ?? 'Failed to load TP/SL monitoring data';
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
      padding: const EdgeInsets.all(20),
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
              color: TradingTheme.warningColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.gps_fixed,
              color: TradingTheme.warningColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'TP/SL Monitor',
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
            'Loading TP/SL monitoring data...',
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
            'Error Loading TP/SL Monitor Data',
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
          _buildExecutionsSection(),
        ],
      ),
    );
  }

  Widget _buildStatusInfo() {
    final hasExecutions = _monitorData!.hasExecutions;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasExecutions 
            ? TradingTheme.warningColor.withOpacity(0.1)
            : TradingTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasExecutions 
              ? TradingTheme.warningColor.withOpacity(0.3)
              : TradingTheme.primaryBorder.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasExecutions ? Icons.notifications_active : Icons.monitor,
            color: hasExecutions ? TradingTheme.warningColor : TradingTheme.primaryAccent,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            hasExecutions ? 'TP/SL Executions Detected' : 'TP/SL Monitoring Active',
            style: TradingTypography.bodyMedium.copyWith(
              color: hasExecutions ? TradingTheme.warningColor : TradingTheme.primaryAccent,
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
                  _monitorData!.executedTpSl > 0 ? TradingTheme.warningColor : TradingTheme.primaryAccent,
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
                  'Executed Positions',
                  _monitorData!.executedPositions.length.toString(),
                  _monitorData!.executedPositions.isNotEmpty 
                      ? TradingTheme.warningColor 
                      : TradingTheme.primaryAccent,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Execution Status',
                  _monitorData!.hasExecutions ? 'Active' : 'Idle',
                  _monitorData!.hasExecutions ? TradingTheme.warningColor : TradingTheme.successColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionsSection() {
    if (_monitorData!.executedPositions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TradingTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TradingTheme.primaryBorder.withOpacity(0.3)),
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
              'No Recent Executions',
              style: TradingTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'All TP/SL orders are pending',
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
            'Executed Positions',
            style: TradingTypography.heading3,
          ),
          const SizedBox(height: 16),
          ...(_monitorData!.executedPositions.map((position) => Container(
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
                  Icons.gps_fixed,
                  color: TradingTheme.warningColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    position,
                    style: TradingTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
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
