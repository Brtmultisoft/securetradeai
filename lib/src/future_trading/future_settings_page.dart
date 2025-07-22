import 'package:flutter/material.dart';
import 'package:securetradeai/model/future_trading_models.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/widget/trading_widgets.dart';

class FutureSettingsPage extends StatefulWidget {
  const FutureSettingsPage({Key? key}) : super(key: key);

  @override
  State<FutureSettingsPage> createState() => _FutureSettingsPageState();
}

class _FutureSettingsPageState extends State<FutureSettingsPage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  late FutureSettings _settings;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSettings();
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

  void _loadSettings() {
    // Load settings from storage or use defaults
    _settings = FutureSettings();
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
      body: _buildSettingsContent(),
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
                  Icons.settings,
                  color: Colors.black,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Config',
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
            'Future Settings',
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

  Widget _buildSettingsContent() {
    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTradingDefaults(),
            const SizedBox(height: 20),
            _buildNotificationSettings(),
            const SizedBox(height: 100), // Space for bottom actions
          ],
        ),
      ),
    );
  }

  Widget _buildTradingDefaults() {
    return AnimatedTradingCard(
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

          // Default Leverage
          _buildSliderSetting(
            'Default Leverage',
            '${_settings.defaultLeverage.toStringAsFixed(0)}x',
            _settings.defaultLeverage,
            1,
            10,
            (value) => setState(
                () => _settings = _settings.copyWith(defaultLeverage: value)),
          ),
          const SizedBox(height: 16),

          // Default Take Profit
          _buildSliderSetting(
            'Default Take Profit',
            '${_settings.defaultTakeProfitPercent.toStringAsFixed(1)}%',
            _settings.defaultTakeProfitPercent,
            0.5,
            10,
            (value) => setState(() => _settings =
                _settings.copyWith(defaultTakeProfitPercent: value)),
          ),
          const SizedBox(height: 16),

          // Default Stop Loss
          _buildSliderSetting(
            'Default Stop Loss',
            '${_settings.defaultStopLossPercent.toStringAsFixed(1)}%',
            _settings.defaultStopLossPercent,
            0.5,
            5,
            (value) => setState(() =>
                _settings = _settings.copyWith(defaultStopLossPercent: value)),
          ),
          const SizedBox(height: 16),

          // Order Type Info (Always Market)
          Row(
            children: [
              Text(
                'Order Type',
                style: TradingTypography.bodyMedium,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: TradingTheme.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'MARKET',
                  style: TradingTypography.bodySmall.copyWith(
                    color: TradingTheme.primaryAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return AnimatedTradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications,
                color: TradingTheme.primaryAccent,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Notifications',
                style: TradingTypography.heading3,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Master notifications toggle
          Row(
            children: [
              Expanded(
                child: Text(
                  'Enable Notifications',
                  style: TradingTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TradingToggleSwitch(
                value: _settings.notificationsEnabled,
                onChanged: (value) => setState(() => _settings =
                    _settings.copyWith(notificationsEnabled: value)),
              ),
            ],
          ),

          if (_settings.notificationsEnabled) ...[
            const SizedBox(height: 16),
            const Divider(color: TradingTheme.primaryBorder),
            const SizedBox(height: 16),

            // Individual notification settings
            _buildNotificationToggle(
              'Trade Executed',
              'Get notified when trades are opened',
              _settings.tradeExecutedNotification,
              (value) => setState(() => _settings =
                  _settings.copyWith(tradeExecutedNotification: value)),
            ),
            const SizedBox(height: 12),

            _buildNotificationToggle(
              'TP/SL Hit',
              'Get notified when TP or SL is triggered',
              _settings.tpSlHitNotification,
              (value) => setState(() =>
                  _settings = _settings.copyWith(tpSlHitNotification: value)),
            ),
            const SizedBox(height: 12),

            _buildNotificationToggle(
              'Liquidation Warning',
              'Get warned before potential liquidation',
              _settings.liquidationWarningNotification,
              (value) => setState(() => _settings =
                  _settings.copyWith(liquidationWarningNotification: value)),
            ),
            const SizedBox(height: 12),

            _buildNotificationToggle(
              'API Errors',
              'Get notified about API connection issues',
              _settings.apiErrorNotification,
              (value) => setState(() =>
                  _settings = _settings.copyWith(apiErrorNotification: value)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSliderSetting(
    String title,
    String value,
    double currentValue,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TradingTypography.bodyMedium),
            Text(
              value,
              style: TradingTypography.bodyMedium.copyWith(
                color: TradingTheme.primaryAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: TradingTheme.primaryAccent,
            inactiveTrackColor: TradingTheme.hintText,
            thumbColor: TradingTheme.primaryAccent,
            overlayColor: TradingTheme.primaryAccent.withOpacity(0.2),
          ),
          child: Slider(
            value: currentValue,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationToggle(
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TradingTypography.bodyMedium,
              ),
              Text(
                description,
                style: TradingTypography.bodySmall.copyWith(
                  color: TradingTheme.secondaryText,
                ),
              ),
            ],
          ),
        ),
        TradingToggleSwitch(
          value: value,
          onChanged: onChanged,
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
            color: TradingTheme.primaryBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TradingButton(
              text: 'Reset to Defaults',
              onPressed: _resetToDefaults,
              backgroundColor: TradingTheme.hintText,
              textColor: TradingTheme.primaryText,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TradingButton(
              text: 'Save Settings',
              onPressed: _isLoading ? null : _saveSettings,
              isLoading: _isLoading,
              backgroundColor: TradingTheme.primaryAccent,
              textColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _settings = FutureSettings();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Settings reset to defaults',
          style: TradingTypography.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: TradingTheme.primaryAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      // Simulate API call to save settings
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Settings saved successfully!',
              style: TradingTypography.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: TradingTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save settings: $e',
              style: TradingTypography.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: TradingTheme.errorColor,
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
}
