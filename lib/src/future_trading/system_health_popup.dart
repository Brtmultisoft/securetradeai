import 'package:flutter/material.dart';
import 'package:rapidtradeai/model/future_trading_models.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';
import 'package:rapidtradeai/src/Service/future_trading_service.dart';

class SystemHealthPopup extends StatefulWidget {
  const SystemHealthPopup({Key? key}) : super(key: key);

  @override
  State<SystemHealthPopup> createState() => _SystemHealthPopupState();
}

class _SystemHealthPopupState extends State<SystemHealthPopup> {
  SystemHealthData? _healthData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔄 Loading system health data...');

      final response = await FutureTradingService.getDualSideSystemHealth();

      if (response != null && response.isSuccess) {
        if (response.data != null) {
          setState(() {
            _healthData = response.data;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage =
                'No system health data available.\n\nThis could be because:\n• System monitoring is initializing\n• Health service is temporarily unavailable\n• Network connectivity issues';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              response?.message ?? 'Failed to load system health data';
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
                      : _buildHealthContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    Color headerColor = TradingTheme.primaryAccent;
    if (_healthData != null) {
      if (_healthData!.isHealthy) {
        headerColor = TradingTheme.successColor;
      } else if (_healthData!.isWarning) {
        headerColor = TradingTheme.warningColor;
      } else if (_healthData!.isCritical) {
        headerColor = TradingTheme.errorColor;
      }
    }

    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
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
              color: headerColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.health_and_safety,
              color: headerColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'System Health',
            style: TradingTypography.heading3,
          ),
          const Spacer(),
          // IconButton(
          //   onPressed: _loadHealthData,
          //   icon: const Icon(
          //     Icons.refresh,
          //     color: TradingTheme.primaryAccent,
          //   ),
          // ),
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
            'Loading system health data...',
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
            'Error Loading Health Data',
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
            onPressed: _loadHealthData,
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

  Widget _buildHealthContent() {
    if (_healthData == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusOverview(),
          const SizedBox(height: 24),
          _buildSystemMetrics(),
          const SizedBox(height: 24),
          _buildServiceStatus(),
          const SizedBox(height: 24),
          _buildTradingStats(),
        ],
      ),
    );
  }

  Widget _buildStatusOverview() {
    Color statusColor = TradingTheme.primaryAccent;
    if (_healthData!.isHealthy) {
      statusColor = TradingTheme.successColor;
    } else if (_healthData!.isWarning) {
      statusColor = TradingTheme.warningColor;
    } else if (_healthData!.isCritical) {
      statusColor = TradingTheme.errorColor;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Status',
                    style: TradingTypography.bodyMedium.copyWith(
                      color: TradingTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _healthData!.overallStatus,
                    style: TradingTypography.heading2.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${_healthData!.healthScore}',
                  style: TradingTypography.heading2.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: TradingTheme.secondaryText,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Last Updated: ${_healthData!.formattedTimestamp}',
                style: TradingTypography.bodySmall.copyWith(
                  color: TradingTheme.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMetrics() {
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
            'System Metrics',
            style: TradingTypography.heading3,
          ),
          const SizedBox(height: 16),
          _buildMetricItem(
            'System Load',
            _healthData!.formattedSystemLoad,
            _getLoadColor(_healthData!.systemLoad),
            Icons.speed,
          ),
          _buildMetricItem(
            'Memory Usage',
            _healthData!.formattedMemoryUsage,
            _getMemoryColor(_healthData!.memoryUsage),
            Icons.memory,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Error Rate',
                  _healthData!.formattedErrorRate,
                  _getErrorRateColor(_healthData!.errorRate),
                  Icons.error_outline,
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStatus() {
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
            'Service Status',
            style: TradingTypography.heading3,
          ),
          const SizedBox(height: 16),
          _buildServiceItem(
            'Database',
            _healthData!.database,
            Icons.storage,
          ),
          const SizedBox(height: 12),
          _buildServiceItem(
            'API Connect',
            _healthData!.apiConnectivity,
            Icons.cloud,
          ),
        ],
      ),
    );
  }

  Widget _buildTradingStats() {
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
            'Trading Activity',
            style: TradingTypography.heading3,
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            'Active Strategies',
            _healthData!.activeStrategies.toString(),
            TradingTheme.primaryAccent,
            Icons.auto_graph,
          ),
          _buildStatItem(
            'Open Positions',
            _healthData!.openPositions.toString(),
            TradingTheme.warningColor,
            Icons.account_balance,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    Color valueColor,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: TradingTheme.secondaryText,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TradingTypography.bodyMedium.copyWith(
                color: TradingTheme.secondaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TradingTypography.heading3.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceItem(
    String label,
    bool isActive,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive
                ? TradingTheme.successColor.withOpacity(0.1)
                : TradingTheme.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color:
                isActive ? TradingTheme.successColor : TradingTheme.errorColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TradingTypography.bodyMedium,
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? TradingTheme.successColor.withOpacity(0.1)
                : TradingTheme.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            isActive ? 'Online' : 'Offline',
            style: TradingTypography.bodySmall.copyWith(
              color: isActive
                  ? TradingTheme.successColor
                  : TradingTheme.errorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color valueColor,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: TradingTheme.secondaryText,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TradingTypography.bodyMedium.copyWith(
                color: TradingTheme.secondaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TradingTypography.heading3.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getLoadColor(double load) {
    if (load < 1.0) return TradingTheme.successColor;
    if (load < 2.0) return TradingTheme.warningColor;
    return TradingTheme.errorColor;
  }

  Color _getMemoryColor(double memory) {
    if (memory < 60) return TradingTheme.successColor;
    if (memory < 80) return TradingTheme.warningColor;
    return TradingTheme.errorColor;
  }

  Color _getErrorRateColor(double errorRate) {
    if (errorRate < 1.0) return TradingTheme.successColor;
    if (errorRate < 5.0) return TradingTheme.warningColor;
    return TradingTheme.errorColor;
  }
}
