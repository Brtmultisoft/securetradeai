import 'dart:async';

import 'package:flutter/material.dart';
import 'package:securetradeai/model/future_trading_models.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/widget/trading_widgets.dart';

class FuturePositionsPage extends StatefulWidget {
  const FuturePositionsPage({Key? key}) : super(key: key);

  @override
  State<FuturePositionsPage> createState() => _FuturePositionsPageState();
}

class _FuturePositionsPageState extends State<FuturePositionsPage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  Timer? _refreshTimer;
  bool _isLoading = true;
  bool _isRefreshing = false;

  List<FuturePosition> _positions = [];
  String _filterType = 'ALL'; // 'ALL', 'LONG', 'SHORT', 'PROFIT', 'LOSS'

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPositions();
    _startAutoRefresh();
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

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && !_isLoading) {
        _refreshPositions();
      }
    });
  }

  Future<void> _loadPositions() async {
    setState(() => _isLoading = true);

    try {
      // Simulate API call - replace with actual API integration
      await Future.delayed(const Duration(seconds: 2));

      // Mock data - replace with actual API response
      _positions = [
        FuturePosition(
          id: '1',
          symbol: 'BTCUSDT',
          side: 'LONG',
          entryPrice: 43250.0,
          currentPrice: 43500.0,
          quantity: 0.1,
          leverage: 10.0,
          unrealizedPnl: 25.0,
          realizedPnl: 0.0,
          profitPercent: 0.58,
          marginUsed: 432.5,
          liquidationPrice: 39000.0,
          openTime: DateTime.now().subtract(const Duration(hours: 2)),
          status: 'OPEN',
          takeProfitPrice: 45000.0,
          stopLossPrice: 42000.0,
        ),
        FuturePosition(
          id: '2',
          symbol: 'ETHUSDT',
          side: 'SHORT',
          entryPrice: 2680.0,
          currentPrice: 2650.0,
          quantity: 1.0,
          leverage: 5.0,
          unrealizedPnl: 30.0,
          realizedPnl: 0.0,
          profitPercent: 1.12,
          marginUsed: 536.0,
          liquidationPrice: 3000.0,
          openTime: DateTime.now().subtract(const Duration(hours: 1)),
          status: 'OPEN',
        ),
        FuturePosition(
          id: '3',
          symbol: 'BNBUSDT',
          side: 'LONG',
          entryPrice: 315.20,
          currentPrice: 312.50,
          quantity: 5.0,
          leverage: 3.0,
          unrealizedPnl: -13.5,
          realizedPnl: 0.0,
          profitPercent: -0.86,
          marginUsed: 525.33,
          liquidationPrice: 280.0,
          openTime: DateTime.now().subtract(const Duration(minutes: 30)),
          status: 'OPEN',
        ),
      ];
    } catch (e) {
      print('Error loading positions: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshPositions() async {
    setState(() => _isRefreshing = true);

    try {
      // Simulate price updates
      for (int i = 0; i < _positions.length; i++) {
        final position = _positions[i];
        final priceChange = (DateTime.now().millisecond % 20 - 10) * 0.1;
        final newCurrentPrice = position.currentPrice + priceChange;
        final newUnrealizedPnl = position.isLong
            ? (newCurrentPrice - position.entryPrice) *
                position.quantity *
                position.leverage
            : (position.entryPrice - newCurrentPrice) *
                position.quantity *
                position.leverage;
        final newProfitPercent =
            ((newCurrentPrice - position.entryPrice) / position.entryPrice) *
                100 *
                position.leverage;

        _positions[i] = FuturePosition(
          id: position.id,
          symbol: position.symbol,
          side: position.side,
          entryPrice: position.entryPrice,
          currentPrice: newCurrentPrice,
          quantity: position.quantity,
          leverage: position.leverage,
          unrealizedPnl: newUnrealizedPnl,
          realizedPnl: position.realizedPnl,
          profitPercent: position.isLong ? newProfitPercent : -newProfitPercent,
          marginUsed: position.marginUsed,
          liquidationPrice: position.liquidationPrice,
          openTime: position.openTime,
          status: position.status,
          takeProfitPrice: position.takeProfitPrice,
          stopLossPrice: position.stopLossPrice,
        );
      }
    } catch (e) {
      print('Error refreshing positions: $e');
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  List<FuturePosition> get _filteredPositions {
    switch (_filterType) {
      case 'LONG':
        return _positions.where((p) => p.isLong).toList();
      case 'SHORT':
        return _positions.where((p) => p.isShort).toList();
      case 'PROFIT':
        return _positions.where((p) => p.isProfit).toList();
      case 'LOSS':
        return _positions.where((p) => !p.isProfit).toList();
      default:
        return _positions;
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TradingTheme.primaryBackground,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingScreen() : _buildPositionsContent(),
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
                  Icons.list_alt,
                  color: Colors.black,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_positions.length}',
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
            'Open Positions',
            style: TradingTypography.heading3,
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: TradingTheme.primaryText),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (_isRefreshing)
          Container(
            margin: const EdgeInsets.all(16),
            width: 20,
            height: 20,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: TradingTheme.primaryAccent,
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.refresh, color: TradingTheme.primaryAccent),
            onPressed: _refreshPositions,
          ),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: TradingLoadingIndicator(
        message: 'Loading Positions...',
      ),
    );
  }

  Widget _buildPositionsContent() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: RefreshIndicator(
              color: TradingTheme.primaryAccent,
              backgroundColor: TradingTheme.secondaryBackground,
              onRefresh: _loadPositions,
              child: _filteredPositions.isEmpty
                  ? _buildEmptyState()
                  : _buildPositionsList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      {'key': 'ALL', 'label': 'All', 'icon': Icons.list},
      {'key': 'LONG', 'label': 'Long', 'icon': Icons.trending_up},
      {'key': 'SHORT', 'label': 'Short', 'icon': Icons.trending_down},
      {'key': 'PROFIT', 'label': 'Profit', 'icon': Icons.add_circle},
      {'key': 'LOSS', 'label': 'Loss', 'icon': Icons.remove_circle},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _filterType == filter['key'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TradingButton(
                text: filter['label'] as String,
                onPressed: () =>
                    setState(() => _filterType = filter['key'] as String),
                backgroundColor: isSelected
                    ? TradingTheme.primaryAccent
                    : TradingTheme.surfaceBackground,
                textColor: isSelected ? Colors.black : TradingTheme.primaryText,
                width: 80,
                height: 40,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            color: TradingTheme.secondaryText,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No positions found',
            style: TradingTypography.heading3.copyWith(
              color: TradingTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your open positions will appear here',
            style: TradingTypography.bodyMedium.copyWith(
              color: TradingTheme.hintText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPositions.length,
      itemBuilder: (context, index) {
        final position = _filteredPositions[index];
        return _buildPositionCard(position, index);
      },
    );
  }

  Widget _buildPositionCard(FuturePosition position, int index) {
    return AnimatedTradingCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with symbol and side
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: position.isLong
                      ? TradingTheme.successColor.withOpacity(0.1)
                      : TradingTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
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
                child: Text(
                  position.symbol,
                  style: TradingTypography.heading3,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${position.unrealizedPnl.toStringAsFixed(2)}',
                    style: TradingTypography.bodyLarge.copyWith(
                      color: position.isProfit
                          ? TradingTheme.successColor
                          : TradingTheme.errorColor,
                      fontWeight: FontWeight.bold,
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
          const SizedBox(height: 16),

          // Position details
          Row(
            children: [
              Expanded(
                child: _buildPositionDetail('Entry Price',
                    '\$${position.entryPrice.toStringAsFixed(2)}'),
              ),
              Expanded(
                child: _buildPositionDetail('Current Price',
                    '\$${position.currentPrice.toStringAsFixed(2)}'),
              ),
              Expanded(
                child: _buildPositionDetail(
                    'Leverage', '${position.leverage.toStringAsFixed(0)}x'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPositionDetail(
                    'Quantity', position.quantity.toStringAsFixed(4)),
              ),
              Expanded(
                child: _buildPositionDetail('Margin Used',
                    '\$${position.marginUsed.toStringAsFixed(2)}'),
              ),
              Expanded(
                child: _buildPositionDetail('Liquidation',
                    '\$${position.liquidationPrice.toStringAsFixed(2)}'),
              ),
            ],
          ),

          // TP/SL info if available
          if (position.takeProfitPrice != null ||
              position.stopLossPrice != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (position.takeProfitPrice != null) ...[
                  Expanded(
                    child: _buildPositionDetail(
                      'Take Profit',
                      '\$${position.takeProfitPrice!.toStringAsFixed(2)}',
                      valueColor: TradingTheme.successColor,
                    ),
                  ),
                ],
                if (position.stopLossPrice != null) ...[
                  Expanded(
                    child: _buildPositionDetail(
                      'Stop Loss',
                      '\$${position.stopLossPrice!.toStringAsFixed(2)}',
                      valueColor: TradingTheme.errorColor,
                    ),
                  ),
                ],
                if (position.takeProfitPrice == null ||
                    position.stopLossPrice == null)
                  const Expanded(child: SizedBox()),
              ],
            ),
          ],

          const SizedBox(height: 16),

          /// Action buttons
          Row(
            children: [
              Expanded(
                child: TradingButton(
                  text: 'Close',
                  onPressed: () => _closePosition(position),
                  backgroundColor: TradingTheme.errorColor,
                  textColor: Colors.white,
                  height: 40,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TradingButton(
                  text: 'TP/SL',
                  onPressed: () => _editTpSl(position),
                  backgroundColor: TradingTheme.surfaceBackground,
                  textColor: TradingTheme.primaryText,
                  height: 40,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TradingButton(
                  text: 'Margin',

                  /// Add Margin
                  onPressed: () => _addMargin(position),
                  backgroundColor: TradingTheme.primaryAccent,
                  textColor: Colors.black,
                  height: 40,
                ),
              ),
            ],
          ),

          // Time info
          const SizedBox(height: 12),
          Text(
            'Opened: ${_formatDateTime(position.openTime)}',
            style: TradingTypography.bodySmall.copyWith(
              color: TradingTheme.hintText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionDetail(String label, String value, {Color? valueColor}) {
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
          style: TradingTypography.bodyMedium.copyWith(
            color: valueColor ?? TradingTheme.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _closePosition(FuturePosition position) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TradingTheme.secondaryBackground,
        title: Text(
          'Close Position',
          style: TradingTypography.heading3,
        ),
        content: Text(
          'Are you sure you want to close this ${position.side} position for ${position.symbol}?\n\nCurrent PnL: \$${position.unrealizedPnl.toStringAsFixed(2)}',
          style: TradingTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TradingTypography.bodyMedium.copyWith(
                color: TradingTheme.secondaryText,
              ),
            ),
          ),
          TradingButton(
            text: 'Close Position',
            onPressed: () => Navigator.pop(context, true),
            backgroundColor: TradingTheme.errorColor,
            textColor: Colors.white,
            width: 130,
            height: 36,
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Simulate API call to close position
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Position closed successfully!',
            style: TradingTypography.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: TradingTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Remove position from list
      setState(() {
        _positions.removeWhere((p) => p.id == position.id);
      });
    }
  }

  void _editTpSl(FuturePosition position) {
    // Show TP/SL edit dialog
    showDialog(
      context: context,
      builder: (context) => _TpSlEditDialog(position: position),
    );
  }

  void _addMargin(FuturePosition position) {
    // Show add margin dialog
    showDialog(
      context: context,
      builder: (context) => _AddMarginDialog(position: position),
    );
  }
}

// TP/SL Edit Dialog
class _TpSlEditDialog extends StatefulWidget {
  final FuturePosition position;

  const _TpSlEditDialog({required this.position});

  @override
  State<_TpSlEditDialog> createState() => _TpSlEditDialogState();
}

class _TpSlEditDialogState extends State<_TpSlEditDialog> {
  late TextEditingController _tpController;
  late TextEditingController _slController;
  bool _enableTp = false;
  bool _enableSl = false;

  @override
  void initState() {
    super.initState();
    _tpController = TextEditingController(
      text: widget.position.takeProfitPrice?.toStringAsFixed(2) ?? '',
    );
    _slController = TextEditingController(
      text: widget.position.stopLossPrice?.toStringAsFixed(2) ?? '',
    );
    _enableTp = widget.position.takeProfitPrice != null;
    _enableSl = widget.position.stopLossPrice != null;
  }

  @override
  void dispose() {
    _tpController.dispose();
    _slController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: TradingTheme.secondaryBackground,
      title: Text(
        'Edit TP/SL - ${widget.position.symbol}',
        style: TradingTypography.heading3,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              TradingToggleSwitch(
                value: _enableTp,
                onChanged: (value) => setState(() => _enableTp = value),
              ),
              const SizedBox(width: 12),
              Text(
                'Take Profit',
                style: TradingTypography.bodyMedium,
              ),
            ],
          ),
          if (_enableTp) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _tpController,
              keyboardType: TextInputType.number,
              style: TradingTypography.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Take Profit Price',
                labelStyle: TradingTypography.bodySmall.copyWith(
                  color: TradingTheme.successColor,
                ),
                filled: true,
                fillColor: TradingTheme.surfaceBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: TradingTheme.successColor),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              TradingToggleSwitch(
                value: _enableSl,
                onChanged: (value) => setState(() => _enableSl = value),
              ),
              const SizedBox(width: 12),
              Text(
                'Stop Loss',
                style: TradingTypography.bodyMedium,
              ),
            ],
          ),
          if (_enableSl) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _slController,
              keyboardType: TextInputType.number,
              style: TradingTypography.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Stop Loss Price',
                labelStyle: TradingTypography.bodySmall.copyWith(
                  color: TradingTheme.errorColor,
                ),
                filled: true,
                fillColor: TradingTheme.surfaceBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: TradingTheme.errorColor),
                ),
              ),
            ),
          ],
        ],
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
        TradingButton(
          text: 'Update',
          onPressed: () {
            // Simulate API call to update TP/SL
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'TP/SL updated successfully!',
                  style: TradingTypography.bodyMedium
                      .copyWith(color: Colors.white),
                ),
                backgroundColor: TradingTheme.successColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          backgroundColor: TradingTheme.primaryAccent,
          textColor: Colors.black,
          width: 80,
          height: 36,
        ),
      ],
    );
  }
}

// Add Margin Dialog
class _AddMarginDialog extends StatefulWidget {
  final FuturePosition position;

  const _AddMarginDialog({required this.position});

  @override
  State<_AddMarginDialog> createState() => _AddMarginDialogState();
}

class _AddMarginDialogState extends State<_AddMarginDialog> {
  late TextEditingController _marginController;

  @override
  void initState() {
    super.initState();
    _marginController = TextEditingController();
  }

  @override
  void dispose() {
    _marginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: TradingTheme.secondaryBackground,
      title: Text(
        'Add Margin - ${widget.position.symbol}',
        style: TradingTypography.heading3,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Current Margin: \$${widget.position.marginUsed.toStringAsFixed(2)}',
            style: TradingTypography.bodyMedium.copyWith(
              color: TradingTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _marginController,
            keyboardType: TextInputType.number,
            style: TradingTypography.bodyMedium,
            decoration: InputDecoration(
              labelText: 'Additional Margin (USDT)',
              labelStyle: TradingTypography.bodySmall.copyWith(
                color: TradingTheme.primaryAccent,
              ),
              filled: true,
              fillColor: TradingTheme.surfaceBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: TradingTheme.primaryAccent),
              ),
            ),
          ),
        ],
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
        TradingButton(
          text: 'Add Margin',
          onPressed: () {
            // Simulate API call to add margin
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Margin added successfully!',
                  style: TradingTypography.bodyMedium
                      .copyWith(color: Colors.white),
                ),
                backgroundColor: TradingTheme.successColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          backgroundColor: TradingTheme.primaryAccent,
          textColor: Colors.black,
          width: 110,
          height: 36,
        ),
      ],
    );
  }
}
