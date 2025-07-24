import 'package:flutter/material.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/model/future_trading_models.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/Service/future_trading_service.dart';

class EmergencyStopPopup extends StatefulWidget {
  const EmergencyStopPopup({Key? key}) : super(key: key);

  @override
  State<EmergencyStopPopup> createState() => _EmergencyStopPopupState();
}

class _EmergencyStopPopupState extends State<EmergencyStopPopup> {
  EmergencyStopData? _stopData;
  bool _isLoading = false;
  bool _isConfirming = true;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: TradingTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TradingTheme.errorColor),
        ),
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _stopData != null
                      ? _buildResultsContent()
                      : _isConfirming
                          ? _buildConfirmationContent()
                          : _buildErrorState(),
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
        color: TradingTheme.errorColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(
          bottom: BorderSide(
            color: TradingTheme.errorColor.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TradingTheme.errorColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.emergency,
              color: TradingTheme.errorColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Stop',
            style: TradingTypography.heading3.copyWith(
              color: TradingTheme.errorColor,
            ),
          ),
          const Spacer(),
          if (!_isLoading)
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

  Widget _buildConfirmationContent() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning,
            color: TradingTheme.errorColor,
            size: 80,
          ),
          const SizedBox(height: 15),
          Text(
            'EMERGENCY STOP',
            style: TradingTypography.heading2.copyWith(
              color: TradingTheme.errorColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'This will immediately stop ALL active strategies and close ALL open positions.',
            style: TradingTypography.bodyLarge.copyWith(
              color: TradingTheme.primaryText,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TradingTheme.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: TradingTheme.errorColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '⚠️ WARNING ⚠️',
                  style: TradingTypography.bodyMedium.copyWith(
                    color: TradingTheme.errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• All running strategies will be stopped\n• All open positions will be closed at market price\n• This action cannot be undone\n• Use only in emergency situations',
                  style: TradingTypography.bodyMedium.copyWith(
                    color: TradingTheme.primaryText,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TradingTheme.secondaryBackground,
                    foregroundColor: TradingTheme.primaryText,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _executeEmergencyStop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TradingTheme.errorColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'EMERGENCY STOP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
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
            color: TradingTheme.errorColor,
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Executing Emergency Stop...',
            style: TradingTypography.heading3.copyWith(
              color: TradingTheme.errorColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while all strategies are stopped\nand positions are closed.',
            style: TradingTypography.bodyMedium.copyWith(
              color: TradingTheme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsContent() {
    if (_stopData == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  color: TradingTheme.successColor,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Emergency Stop Completed',
                  style: TradingTypography.heading3.copyWith(
                    color: TradingTheme.successColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _stopData!.stopSummary,
                  style: TradingTypography.bodyMedium.copyWith(
                    color: TradingTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildSummarySection(),
          const SizedBox(height: 24),
          if (_stopData!.hasErrors) ...[
            _buildErrorsSection(),
            const SizedBox(height: 24),
          ],
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: TradingTheme.primaryAccent,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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
            'Emergency Stop Failed',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _executeEmergencyStop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TradingTheme.errorColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TradingTheme.secondaryBackground,
                  foregroundColor: TradingTheme.primaryText,
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
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
            'Emergency Stop Summary',
            style: TradingTypography.heading3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Strategies Stopped',
                  _stopData!.stoppedStrategies.toString(),
                  TradingTheme.errorColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Total Strategies',
                  _stopData!.totalStrategies.toString(),
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
                  'Errors',
                  _stopData!.errors.length.toString(),
                  _stopData!.hasErrors
                      ? TradingTheme.errorColor
                      : TradingTheme.successColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Success Rate',
                  _stopData!.totalStrategies > 0
                      ? '${((_stopData!.stoppedStrategies / _stopData!.totalStrategies) * 100).toStringAsFixed(1)}%'
                      : '0%',
                  _stopData!.hasErrors
                      ? TradingTheme.warningColor
                      : TradingTheme.successColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorsSection() {
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
            'Errors During Emergency Stop',
            style: TradingTypography.heading3.copyWith(
              color: TradingTheme.errorColor,
            ),
          ),
          const SizedBox(height: 16),
          if (_stopData!.errors.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TradingTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: TradingTheme.successColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: TradingTheme.successColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'No errors occurred during emergency stop',
                    style: TradingTypography.bodyMedium.copyWith(
                      color: TradingTheme.successColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            ...(_stopData!.errors.map((error) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TradingTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: TradingTheme.errorColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error,
                        color: TradingTheme.errorColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error,
                          style: TradingTypography.bodyMedium.copyWith(
                            color: TradingTheme.errorColor,
                            fontWeight: FontWeight.w500,
                          ),
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

  Future<void> _executeEmergencyStop() async {
    setState(() {
      _isLoading = true;
      _isConfirming = false;
      _errorMessage = null;
    });

    try {
      print('🔄 Executing emergency stop...');

      final response = await FutureTradingService.getDualSideEmergencyStop(
        userId: commonuserId,
      );

      if (response != null && response.isSuccess) {
        if (response.data != null) {
          setState(() {
            _stopData = response.data;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Emergency stop completed but no data returned';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              response?.message ?? 'Failed to execute emergency stop';
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
}
