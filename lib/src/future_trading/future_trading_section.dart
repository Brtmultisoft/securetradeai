import 'dart:async';

import 'package:flutter/material.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/model/future_trading_models.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/Service/future_trading_service.dart';
import 'package:securetradeai/src/future_trading/emergency_stop_popup.dart';
import 'package:securetradeai/src/future_trading/future_history_page.dart';
import 'package:securetradeai/src/future_trading/future_positions_page.dart';
import 'package:securetradeai/src/future_trading/future_trade_page.dart';
import 'package:securetradeai/src/future_trading/monitor_tpsl_popup.dart';
import 'package:securetradeai/src/future_trading/performance_popup.dart';
import 'package:securetradeai/src/future_trading/pnl_tracking_popup.dart';
import 'package:securetradeai/src/future_trading/risk_settings_page.dart';
import 'package:securetradeai/src/future_trading/set_tpsl_popup.dart';
import 'package:securetradeai/src/future_trading/strategy_monitor_popup.dart';
import 'package:securetradeai/src/future_trading/system_health_popup.dart';
import 'package:securetradeai/src/future_trading/tpsl_monitor_popup.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';
import 'package:securetradeai/src/widget/trading_widgets.dart';

class FutureTradingSection extends StatefulWidget {
  const FutureTradingSection({Key? key}) : super(key: key);

  @override
  State<FutureTradingSection> createState() => _FutureTradingSectionState();
}

class _FutureTradingSectionState extends State<FutureTradingSection>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  Timer? _refreshTimer;
  bool _isLoading = true;
  bool _isRefreshing = false;

  // Dashboard data
  FutureAccountSummary? _accountSummary;
  List<FuturePosition> _recentPositions = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDashboardData();
    _startAutoRefresh();
  }

  void _initializeAnimations() {
    // Slide animation for main content
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

    // Fade animation for cards
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Scale animation for buttons
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Rotation animation for refresh icon
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    // Start animations with staggered delays
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _scaleController.forward();
    });
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && !_isLoading) {
        // Background refresh without any UI indicators
        _refreshData();
      }
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Call real API to get account balance
      _accountSummary = await FutureTradingService.getAccountBalanceWithRetry();

      // Load positions in background without affecting loading state
      _loadOpenPositions();

      if (_accountSummary == null) {
        // If API fails, show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to load account data. Please check your connection.',
                style:
                    TradingTypography.bodyMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: TradingTheme.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        // Set default empty values
        _accountSummary = FutureAccountSummary(
          totalWalletBalance: 0.0,
          futuresBalance: 0.0,
          unrealizedPnl: 0.0,
          totalRealizedProfit: 0.0,
          openPositionsCount: 0,
          todayPnl: 0.0,
          currentLeverage: 1.0,
          availableBalance: 0.0,
          marginBalance: 0.0,
          maxWithdrawAmount: 0.0,
          totalPositionInitialMargin: 0.0,
          totalOpenOrderInitialMargin: 0.0,
          canTrade: true,
          canDeposit: true,
          canWithdraw: true,
        );
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error loading data: ${e.toString()}',
              style: TradingTypography.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: TradingTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Set default empty values on error
      _accountSummary = FutureAccountSummary(
        totalWalletBalance: 0.0,
        futuresBalance: 0.0,
        unrealizedPnl: 0.0,
        totalRealizedProfit: 0.0,
        openPositionsCount: 0,
        todayPnl: 0.0,
        currentLeverage: 1.0,
        availableBalance: 0.0,
        marginBalance: 0.0,
        maxWithdrawAmount: 0.0,
        totalPositionInitialMargin: 0.0,
        totalOpenOrderInitialMargin: 0.0,
        canTrade: true,
        canDeposit: true,
        canWithdraw: true,
      );
      _recentPositions = [];
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshData() async {
    // Background refresh without UI indicators
    try {
      // Call real API to refresh account balance
      final refreshedSummary =
          await FutureTradingService.getDualSideAccountBalance();

      if (refreshedSummary != null && mounted) {
        setState(() {
          _accountSummary = refreshedSummary;
        });
      }

      // Also refresh positions in background
      await _loadOpenPositions();
    } catch (e) {
      // Silently handle refresh errors - don't show error messages for background refresh
      print('Background refresh error: $e');
    }
  }

  Future<void> _manualRefresh() async {
    // Manual refresh triggered by user - show brief feedback
    setState(() => _isRefreshing = true);

    // Start rotation animation briefly
    _rotationController.repeat();

    try {
      await _refreshData();
    } finally {
      if (mounted) {
        // Stop animation after brief period
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() => _isRefreshing = false);
            _rotationController.stop();
            _rotationController.reset();
          }
        });
      }
    }
  }

  // Load open positions from API
  Future<void> _loadOpenPositions() async {
    try {
      print('🔄 Loading open positions...');

      final response = await FutureTradingService.getDualSideOpenPositions(
        userId: commonuserId,
      );

      if (response != null && response.isSuccess && response.data != null) {
        setState(() {
          // Convert API positions to FuturePosition objects
          _recentPositions = response.data!
              .map((apiPosition) => apiPosition.toFuturePosition())
              .toList();

          // Update account summary with correct open positions count
          if (_accountSummary != null) {
            _accountSummary = FutureAccountSummary(
              totalWalletBalance: _accountSummary!.totalWalletBalance,
              futuresBalance: _accountSummary!.futuresBalance,
              unrealizedPnl: _accountSummary!.unrealizedPnl,
              totalRealizedProfit: _accountSummary!.totalRealizedProfit,
              openPositionsCount:
                  _recentPositions.length, // ← Update with real count
              todayPnl: _accountSummary!.todayPnl,
              currentLeverage: _accountSummary!.currentLeverage,
              availableBalance: _accountSummary!.availableBalance,
              marginBalance: _accountSummary!.marginBalance,
              maxWithdrawAmount: _accountSummary!.maxWithdrawAmount,
              totalPositionInitialMargin:
                  _accountSummary!.totalPositionInitialMargin,
              totalOpenOrderInitialMargin:
                  _accountSummary!.totalOpenOrderInitialMargin,
              canTrade: _accountSummary!.canTrade,
              canDeposit: _accountSummary!.canDeposit,
              canWithdraw: _accountSummary!.canWithdraw,
            );
          }
        });
        print('✅ Loaded ${_recentPositions.length} open positions');
      } else {
        print('❌ Failed to load positions: ${response?.message}');
        setState(() {
          _recentPositions = [];
          // Update account summary with 0 positions count
          if (_accountSummary != null) {
            _accountSummary = FutureAccountSummary(
              totalWalletBalance: _accountSummary!.totalWalletBalance,
              futuresBalance: _accountSummary!.futuresBalance,
              unrealizedPnl: _accountSummary!.unrealizedPnl,
              totalRealizedProfit: _accountSummary!.totalRealizedProfit,
              openPositionsCount: 0, // ← Reset to 0 on error
              todayPnl: _accountSummary!.todayPnl,
              currentLeverage: _accountSummary!.currentLeverage,
              availableBalance: _accountSummary!.availableBalance,
              marginBalance: _accountSummary!.marginBalance,
              maxWithdrawAmount: _accountSummary!.maxWithdrawAmount,
              totalPositionInitialMargin:
                  _accountSummary!.totalPositionInitialMargin,
              totalOpenOrderInitialMargin:
                  _accountSummary!.totalOpenOrderInitialMargin,
              canTrade: _accountSummary!.canTrade,
              canDeposit: _accountSummary!.canDeposit,
              canWithdraw: _accountSummary!.canWithdraw,
            );
          }
        });
      }
    } catch (e) {
      print('❌ Error loading positions: $e');
      setState(() {
        _recentPositions = [];
        // Update account summary with 0 positions count
        if (_accountSummary != null) {
          _accountSummary = FutureAccountSummary(
            totalWalletBalance: _accountSummary!.totalWalletBalance,
            futuresBalance: _accountSummary!.futuresBalance,
            unrealizedPnl: _accountSummary!.unrealizedPnl,
            totalRealizedProfit: _accountSummary!.totalRealizedProfit,
            openPositionsCount: 0, // ← Reset to 0 on error
            todayPnl: _accountSummary!.todayPnl,
            currentLeverage: _accountSummary!.currentLeverage,
            availableBalance: _accountSummary!.availableBalance,
            marginBalance: _accountSummary!.marginBalance,
            maxWithdrawAmount: _accountSummary!.maxWithdrawAmount,
            totalPositionInitialMargin:
                _accountSummary!.totalPositionInitialMargin,
            totalOpenOrderInitialMargin:
                _accountSummary!.totalOpenOrderInitialMargin,
            canTrade: _accountSummary!.canTrade,
            canDeposit: _accountSummary!.canDeposit,
            canWithdraw: _accountSummary!.canWithdraw,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Show performance popup
  void _showPerformancePopup() {
    showDialog(
      context: context,
      builder: (context) => const PerformancePopup(),
    );
  }

  // Show PnL tracking popup
  void _showPnlTrackingPopup() {
    showDialog(
      context: context,
      builder: (context) => const PnlTrackingPopup(),
    );
  }

  // Show strategy monitor popup
  void _showStrategyMonitorPopup() {
    showDialog(
      context: context,
      builder: (context) => const StrategyMonitorPopup(),
    );
  }

  // Show TP/SL monitor popup
  void _showTpSlMonitorPopup() {
    showDialog(
      context: context,
      builder: (context) => const TpSlMonitorPopup(),
    );
  }

  // Show emergency stop popup
  void _showEmergencyStopPopup() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => const EmergencyStopPopup(),
    );
  }

  // Show system health popup
  void _showSystemHealthPopup() {
    showDialog(
      context: context,
      builder: (context) => const SystemHealthPopup(),
    );
  }

  // Show set TP/SL popup
  void _showSetTpSlPopup() {
    showDialog(
      context: context,
      builder: (context) => const SetTpSlPopup(),
    );
  }

  // Show monitor TP/SL popup (enhanced version)
  void _showMonitorTpSlPopup() {
    showDialog(
      context: context,
      builder: (context) => const MonitorTpSlPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TradingTheme.primaryBackground,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingScreen() : _buildDashboardContent(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CommonAppBar.analytics(
      title: 'Future Trading',
      actions: [
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * 3.14159,
              child: IconButton(
                icon: const Icon(Icons.refresh, color: TradingTheme.primaryAccent),
                onPressed: _manualRefresh,
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: TradingTheme.secondaryText),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RiskSettingsPage(),
              ),
            );
          },
        ),
      ],
    );
  }
  // PreferredSizeWidget _buildAppBar() {
  //   return AppBar(
  //     backgroundColor: TradingTheme.secondaryBackground,
  //     elevation: 0,
  //     title: Text(
  //       'Future Trading',
  //       style: TradingTypography.heading3,
  //     ),
  //     leading: IconButton(
  //       icon: const Icon(Icons.arrow_back, color: TradingTheme.primaryText),
  //       onPressed: () => Navigator.pop(context),
  //     ),
  //     actions: [
  //       if (_isRefreshing)
  //         Container(
  //           margin: const EdgeInsets.all(16),
  //           width: 20,
  //           height: 20,
  //           child: const CircularProgressIndicator(
  //             strokeWidth: 2,
  //             color: TradingTheme.primaryAccent,
  //           ),
  //         )
  //       else
  //         IconButton(
  //           icon: const Icon(Icons.refresh, color: TradingTheme.primaryAccent),
  //           onPressed: _refreshData,
  //         ),
  //       IconButton(
  //         icon: const Icon(Icons.settings, color: TradingTheme.secondaryText),
  //         onPressed: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => const RiskSettingsPage(),
  //             ),
  //           );
  //         },
  //       ),
  //     ],
  //   );
  // }

  Widget _buildLoadingScreen() {
    return const Center(
      child: TradingLoadingIndicator(
        message: 'Loading Dashboard...',
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SlideTransition(
      position: _slideAnimation,
      child: RefreshIndicator(
        color: TradingTheme.primaryAccent,
        backgroundColor: TradingTheme.secondaryBackground,
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAccountSummaryCard(),
              _buildQuickStatsRow(),
              _buildRecentPositionsCard(),
              _buildQuickActionsCard(),
              const SizedBox(height: 60), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSummaryCard() {
    if (_accountSummary == null) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _fadeController,
          curve: Curves.easeOutCubic,
        )),
        child: AnimatedTradingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _isRefreshing
                            ? _rotationAnimation.value * 2 * 3.14159
                            : 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: TradingTheme.primaryAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: TradingTheme.primaryAccent,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Account Summary',
                    style: TradingTypography.heading3,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'Total Wallet Balance',
                      '\$${_accountSummary!.totalWalletBalance.toStringAsFixed(2)}',
                      TradingTheme.primaryAccent,
                      Icons.account_balance_wallet,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: TradingTheme.primaryBorder,
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Available Balance',
                      '\$${_accountSummary!.availableBalance.toStringAsFixed(2)}',
                      TradingTheme.successColor,
                      Icons.account_balance,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'Margin Balance',
                      '\$${_accountSummary!.marginBalance.toStringAsFixed(2)}',
                      TradingTheme.primaryAccent,
                      Icons.pie_chart,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: TradingTheme.primaryBorder,
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Unrealized PnL',
                      '\$${_accountSummary!.unrealizedPnl.toStringAsFixed(2)}',
                      _accountSummary!.unrealizedPnl >= 0
                          ? TradingTheme.successColor
                          : TradingTheme.errorColor,
                      _accountSummary!.unrealizedPnl >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Additional Balance Details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TradingTheme.surfaceBackground.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: TradingTheme.primaryBorder.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Max Withdraw Amount',
                          style: TradingTypography.bodySmall.copyWith(
                            color: TradingTheme.secondaryText,
                          ),
                        ),
                        Text(
                          '\$${_accountSummary!.maxWithdrawAmount.toStringAsFixed(2)}',
                          style: TradingTypography.bodyMedium.copyWith(
                            color: TradingTheme.primaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Position Initial Margin',
                          style: TradingTypography.bodySmall.copyWith(
                            color: TradingTheme.secondaryText,
                          ),
                        ),
                        Text(
                          '\$${_accountSummary!.totalPositionInitialMargin.toStringAsFixed(2)}',
                          style: TradingTypography.bodyMedium.copyWith(
                            color: TradingTheme.primaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Open Order Initial Margin',
                          style: TradingTypography.bodySmall.copyWith(
                            color: TradingTheme.secondaryText,
                          ),
                        ),
                        Text(
                          '\$${_accountSummary!.totalOpenOrderInitialMargin.toStringAsFixed(2)}',
                          style: TradingTypography.bodyMedium.copyWith(
                            color: TradingTheme.primaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
      String title, String value, Color valueColor, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: valueColor, size: 18),
          const SizedBox(height: 8),
          Text(title,
              style: TradingTypography.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          AnimatedPriceDisplay(
            price: value,
            textStyle: TradingTypography.bodyLarge.copyWith(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    if (_accountSummary == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: TradingStatsCard(
            title: 'Open Positions',
            value: _accountSummary!.openPositionsCount.toString(),
            icon: Icons.bar_chart,
            valueColor: TradingTheme.primaryAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TradingStatsCard(
            title: 'Total Realized',
            value:
                '\$${_accountSummary!.totalRealizedProfit.toStringAsFixed(2)}',
            icon: Icons.monetization_on,
            valueColor: _accountSummary!.totalRealizedProfit >= 0
                ? TradingTheme.successColor
                : TradingTheme.errorColor,
            // showTrend: true,
            isPositiveTrend: _accountSummary!.totalRealizedProfit >= 0,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentPositionsCard() {
    return AnimatedTradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.list_alt,
                color: TradingTheme.primaryAccent,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Recent Positions',
                style: TradingTypography.heading3,
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FuturePositionsPage(),
                    ),
                  );
                },
                child: Text(
                  'View All',
                  style: TradingTypography.bodySmall.copyWith(
                    color: TradingTheme.primaryAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_recentPositions.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inbox,
                    color: TradingTheme.secondaryText,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No open positions',
                    style: TradingTypography.bodyMedium.copyWith(
                      color: TradingTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            )
          else
            ...(_recentPositions
                .take(3)
                .map((position) => _buildPositionItem(position))
                .toList()),
        ],
      ),
    );
  }

  Widget _buildPositionItem(FuturePosition position) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TradingTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: position.isProfit
              ? TradingTheme.successColor.withOpacity(0.3)
              : TradingTheme.errorColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: position.isLong
                  ? TradingTheme.successColor.withOpacity(0.1)
                  : TradingTheme.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              position.side,
              style: TradingTypography.bodySmall.copyWith(
                color: position.isLong
                    ? TradingTheme.successColor
                    : TradingTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  position.symbol,
                  style: TradingTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${position.leverage.toStringAsFixed(0)}x • \$${position.entryPrice.toStringAsFixed(2)}',
                  style: TradingTypography.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${position.unrealizedPnl.toStringAsFixed(2)}',
                style: TradingTypography.bodyMedium.copyWith(
                  color: position.isProfit
                      ? TradingTheme.successColor
                      : TradingTheme.errorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${position.profitPercent >= 0 ? '+' : ''}${position.profitPercent.toStringAsFixed(2)}%',
                style: TradingTypography.bodySmall.copyWith(
                  color: position.isProfit
                      ? TradingTheme.successColor
                      : TradingTheme.errorColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedTradingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.flash_on,
                    color: TradingTheme.primaryAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Quick Actions',
                    style: TradingTypography.heading3,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildAnimatedActionButton(
                      'New Trade',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FutureTradePage(),
                          ),
                        );
                      },
                      TradingTheme.primaryAccent,
                      Colors.black,
                      0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAnimatedActionButton(
                      'History',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FutureHistoryPage(),
                          ),
                        );
                      },
                      TradingTheme.surfaceBackground,
                      TradingTheme.primaryText,
                      100,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Performance Report Button
              SizedBox(
                width: double.infinity,
                child: _buildAnimatedActionButton(
                  'Performance Report',
                  () {
                    _showPerformancePopup();
                  },
                  TradingTheme.secondaryBackground,
                  TradingTheme.primaryAccent,
                  200,
                ),
              ),
              const SizedBox(height: 12),
              // PnL Tracking Button
              SizedBox(
                width: double.infinity,
                child: _buildAnimatedActionButton(
                  'PnL Tracking',
                  () {
                    _showPnlTrackingPopup();
                  },
                  TradingTheme.secondaryBackground,
                  TradingTheme.successColor,
                  250,
                ),
              ),
              const SizedBox(height: 16),
              // Critical Monitoring Section
              Text(
                'Critical Monitoring',
                style: TradingTypography.bodyMedium.copyWith(
                  color: TradingTheme.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildAnimatedActionButton(
                      'Strategy Monitor',
                      () {
                        _showStrategyMonitorPopup();
                      },
                      TradingTheme.secondaryBackground,
                      TradingTheme.primaryAccent,
                      300,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAnimatedActionButton(
                      'TP/SL Monitor',
                      () {
                        _showTpSlMonitorPopup();
                      },
                      TradingTheme.secondaryBackground,
                      TradingTheme.warningColor,
                      350,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // TP/SL Management Section
              Text(
                'TP/SL Management',
                style: TradingTypography.bodyMedium.copyWith(
                  color: TradingTheme.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildAnimatedActionButton(
                      'Set TP/SL',
                      () {
                        _showSetTpSlPopup();
                      },
                      TradingTheme.secondaryBackground,
                      TradingTheme.warningColor,
                      375,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAnimatedActionButton(
                      'Monitor TP/SL',
                      () {
                        _showMonitorTpSlPopup();
                      },
                      TradingTheme.secondaryBackground,
                      TradingTheme.primaryAccent,
                      400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // System Health Button
              SizedBox(
                width: double.infinity,
                child: _buildAnimatedActionButton(
                  'System Health',
                  () {
                    _showSystemHealthPopup();
                  },
                  TradingTheme.secondaryBackground,
                  TradingTheme.successColor,
                  425,
                ),
              ),
              const SizedBox(height: 12),
              // Emergency Stop Button
              SizedBox(
                width: double.infinity,
                child: _buildAnimatedActionButton(
                  '🚨 EMERGENCY STOP',
                  () {
                    _showEmergencyStopPopup();
                  },
                  TradingTheme.errorColor.withOpacity(0.1),
                  TradingTheme.errorColor,
                  450,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedActionButton(
    String text,
    VoidCallback onPressed,
    Color backgroundColor,
    Color textColor,
    int delayMs,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delayMs),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: TradingButton(
                text: text,
                onPressed: onPressed,
                backgroundColor: backgroundColor,
                textColor: textColor,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FutureTradePage(),
          ),
        );
      },
      backgroundColor: TradingTheme.primaryAccent,
      foregroundColor: Colors.black,
      icon: const Icon(Icons.add),
      label: Text(
        'New Trade',
        style: TradingTypography.bodyMedium.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
