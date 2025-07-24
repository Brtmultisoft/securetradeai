import 'package:flutter/material.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/model/future_trading_models.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/Service/future_trading_service.dart';

class RiskSettingsPage extends StatefulWidget {
  const RiskSettingsPage({Key? key}) : super(key: key);

  @override
  State<RiskSettingsPage> createState() => _RiskSettingsPageState();
}

class _RiskSettingsPageState extends State<RiskSettingsPage> {
  bool _isLoading = true;
  bool _isSaving = false;
  RiskSettingsData? _riskSettings;
  String? _errorMessage;

  // Form controllers
  final _maxOpenPositionsController = TextEditingController();
  final _maxDailyLossController = TextEditingController();
  final _maxPositionSizeController = TextEditingController();
  final _defaultTpPercentageController = TextEditingController();
  final _defaultSlPercentageController = TextEditingController();
  final _maxLeverageController = TextEditingController();
  final _emergencyStopLossPercentageController = TextEditingController();

  // Switch states
  bool _autoTpSlEnabled = true;
  bool _duplicatePositionCheck = true;
  bool _emergencyStopEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _maxOpenPositionsController.dispose();
    _maxDailyLossController.dispose();
    _maxPositionSizeController.dispose();
    _defaultTpPercentageController.dispose();
    _defaultSlPercentageController.dispose();
    _maxLeverageController.dispose();
    _emergencyStopLossPercentageController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔄 Loading risk settings...');

      final response = await FutureTradingService.getDualSideRiskSettings(
        userId: commonuserId,
      );

      if (response != null && response.isSuccess) {
        if (response.data != null) {
          setState(() {
            _riskSettings = response.data;
            _populateFormFields();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'No risk settings found. Using default values.';
            _setDefaultValues();
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = response?.message ?? 'Failed to load risk settings';
          _setDefaultValues();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _setDefaultValues();
        _isLoading = false;
      });
    }
  }

  void _populateFormFields() {
    if (_riskSettings == null) return;

    _maxOpenPositionsController.text =
        _riskSettings!.maxOpenPositions.toString();
    _maxDailyLossController.text = _riskSettings!.maxDailyLoss.toString();
    _maxPositionSizeController.text = _riskSettings!.maxPositionSize.toString();
    _defaultTpPercentageController.text =
        _riskSettings!.defaultTpPercentage.toString();
    _defaultSlPercentageController.text =
        _riskSettings!.defaultSlPercentage.toString();
    _maxLeverageController.text = _riskSettings!.maxLeverage.toString();
    _emergencyStopLossPercentageController.text =
        _riskSettings!.emergencyStopLossPercentage.toString();

    _autoTpSlEnabled = _riskSettings!.autoTpSlEnabled;
    _duplicatePositionCheck = _riskSettings!.duplicatePositionCheck;
    _emergencyStopEnabled = _riskSettings!.emergencyStopEnabled;
  }

  void _setDefaultValues() {
    _maxOpenPositionsController.text = '10';
    _maxDailyLossController.text = '100.0';
    _maxPositionSizeController.text = '1.0';
    _defaultTpPercentageController.text = '1.0';
    _defaultSlPercentageController.text = '2.0';
    _maxLeverageController.text = '10';
    _emergencyStopLossPercentageController.text = '10.0';

    _autoTpSlEnabled = true;
    _duplicatePositionCheck = true;
    _emergencyStopEnabled = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TradingTheme.primaryBackground,
      appBar: _buildAppBar(),
      body: _buildContent(),
      bottomNavigationBar: _buildBottomActions(),
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
                  Icons.security,
                  color: Colors.black,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Risk',
                  style: TradingTypography.bodyMedium.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            'Risk Settings',
            style: TradingTypography.heading3,
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: TradingTheme.primaryText),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: TradingTheme.primaryAccent,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading risk settings...',
              style: TradingTypography.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null && _riskSettings == null) {
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
              'Error Loading Settings',
              style: TradingTypography.heading3,
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
            ElevatedButton(
              onPressed: _loadSettings,
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
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
                    Icons.warning,
                    color: TradingTheme.warningColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TradingTypography.bodySmall.copyWith(
                        color: TradingTheme.warningColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          _buildRiskSettings(),
          const SizedBox(height: 20),
          _buildTradingDefaults(),
          const SizedBox(height: 20),
          _buildAdvancedSettings(),
          const SizedBox(height: 100), // Space for bottom actions
        ],
      ),
    );
  }

  Widget _buildRiskSettings() {
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
          Row(
            children: [
              const Icon(
                Icons.security,
                color: TradingTheme.errorColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Risk Management',
                style: TradingTypography.heading3,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Max Open Positions
          _buildNumberInputField(
            'Max Open Positions',
            _maxOpenPositionsController,
            'Maximum number of positions that can be open simultaneously',
          ),
          const SizedBox(height: 16),

          // Max Daily Loss
          _buildNumberInputField(
            'Max Daily Loss (\$)',
            _maxDailyLossController,
            'Maximum loss allowed per day before stopping trading',
          ),
          const SizedBox(height: 16),

          // Max Position Size
          _buildNumberInputField(
            'Max Position Size',
            _maxPositionSizeController,
            'Maximum size for a single position',
          ),
          const SizedBox(height: 16),

          // Max Leverage
          _buildNumberInputField(
            'Max Leverage',
            _maxLeverageController,
            'Maximum leverage allowed for positions',
          ),
        ],
      ),
    );
  }

  Widget _buildTradingDefaults() {
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
          Row(
            children: [
              const Icon(
                Icons.tune,
                color: TradingTheme.primaryAccent,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Trading Defaults',
                style: TradingTypography.heading3,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Default TP Percentage
          _buildNumberInputField(
            'Default Take Profit (%)',
            _defaultTpPercentageController,
            'Default take profit percentage for new positions',
          ),
          const SizedBox(height: 16),

          // Default SL Percentage
          _buildNumberInputField(
            'Default Stop Loss (%)',
            _defaultSlPercentageController,
            'Default stop loss percentage for new positions',
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettings() {
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
          Row(
            children: [
              const Icon(
                Icons.settings_applications,
                color: TradingTheme.warningColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Advanced Settings',
                style: TradingTypography.heading3,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Auto TP/SL Enabled
          _buildSwitchSetting(
            'Auto TP/SL',
            'Automatically set TP/SL for new positions',
            _autoTpSlEnabled,
            (value) => setState(() => _autoTpSlEnabled = value),
          ),
          const SizedBox(height: 16),

          // Duplicate Position Check
          _buildSwitchSetting(
            'Duplicate Position Check',
            'Prevent opening duplicate positions on the same symbol',
            _duplicatePositionCheck,
            (value) => setState(() => _duplicatePositionCheck = value),
          ),
          const SizedBox(height: 16),

          // Emergency Stop Enabled
          _buildSwitchSetting(
            'Stop',
            'Enable emergency stop functionality',
            _emergencyStopEnabled,
            (value) => setState(() => _emergencyStopEnabled = value),
          ),

          if (_emergencyStopEnabled) ...[
            const SizedBox(height: 16),
            _buildNumberInputField(
              'Emergency Stop Loss (%)',
              _emergencyStopLossPercentageController,
              'Loss percentage that triggers emergency stop',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNumberInputField(
    String label,
    TextEditingController controller,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TradingTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TradingTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: TradingTypography.bodyMedium.copyWith(
              color: TradingTheme.secondaryText,
            ),
            filled: true,
            fillColor: TradingTheme.surfaceBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: TradingTheme.primaryBorder.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: TradingTheme.primaryBorder.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: TradingTheme.primaryAccent,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TradingTypography.bodySmall.copyWith(
            color: TradingTheme.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchSetting(
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TradingTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TradingTypography.bodySmall.copyWith(
                  color: TradingTheme.secondaryText,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: TradingTheme.primaryAccent,
          activeTrackColor: TradingTheme.primaryAccent.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TradingTheme.secondaryBackground,
        border: Border(
          top: BorderSide(
            color: TradingTheme.primaryBorder.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _resetToDefaults,
              style: ElevatedButton.styleFrom(
                backgroundColor: TradingTheme.secondaryBackground,
                foregroundColor: TradingTheme.primaryText,
                side: BorderSide(
                  color: TradingTheme.primaryBorder.withOpacity(0.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Reset',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: TradingTheme.primaryAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Text(
                      'Save Settings',
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

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TradingTheme.cardBackground,
        title: Text(
          'Reset Settings',
          style: TradingTypography.heading3,
        ),
        content: Text(
          'Are you sure you want to reset all settings to their default values?',
          style: TradingTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TradingTypography.bodyMedium.copyWith(
                color: TradingTheme.secondaryText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _setDefaultValues();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TradingTheme.primaryAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      print('💾 Saving risk settings...');

      // Validate input fields
      final maxOpenPositions = int.tryParse(_maxOpenPositionsController.text);
      final maxDailyLoss = double.tryParse(_maxDailyLossController.text);
      final maxPositionSize = double.tryParse(_maxPositionSizeController.text);
      final defaultTpPercentage =
          double.tryParse(_defaultTpPercentageController.text);
      final defaultSlPercentage =
          double.tryParse(_defaultSlPercentageController.text);
      final maxLeverage = int.tryParse(_maxLeverageController.text);
      final emergencyStopLossPercentage =
          double.tryParse(_emergencyStopLossPercentageController.text);

      if (maxOpenPositions == null || maxOpenPositions <= 0) {
        throw Exception('Max Open Positions must be a positive number');
      }
      if (maxDailyLoss == null || maxDailyLoss <= 0) {
        throw Exception('Max Daily Loss must be a positive number');
      }
      if (maxPositionSize == null || maxPositionSize <= 0) {
        throw Exception('Max Position Size must be a positive number');
      }
      if (defaultTpPercentage == null || defaultTpPercentage <= 0) {
        throw Exception('Default TP Percentage must be a positive number');
      }
      if (defaultSlPercentage == null || defaultSlPercentage <= 0) {
        throw Exception('Default SL Percentage must be a positive number');
      }
      if (maxLeverage == null || maxLeverage <= 0) {
        throw Exception('Max Leverage must be a positive number');
      }
      if (_emergencyStopEnabled &&
          (emergencyStopLossPercentage == null ||
              emergencyStopLossPercentage <= 0)) {
        throw Exception(
            'Emergency Stop Loss Percentage must be a positive number');
      }

      final response = await FutureTradingService.updateDualSideRiskSettings(
        userId: commonuserId,
        maxOpenPositions: maxOpenPositions,
        maxDailyLoss: maxDailyLoss,
        maxPositionSize: maxPositionSize,
        defaultTpPercentage: defaultTpPercentage,
        defaultSlPercentage: defaultSlPercentage,
        maxLeverage: maxLeverage,
        autoTpSlEnabled: _autoTpSlEnabled,
        duplicatePositionCheck: _duplicatePositionCheck,
        emergencyStopEnabled: _emergencyStopEnabled,
        emergencyStopLossPercentage:
            _emergencyStopEnabled ? emergencyStopLossPercentage : null,
      );

      if (response != null && response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Risk settings saved successfully'),
              backgroundColor: TradingTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );

          // Reload settings to get updated data
          _loadSettings();
        }
      } else {
        throw Exception(response?.message ?? 'Failed to save settings');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: TradingTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
