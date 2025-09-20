import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:rapidtradeai/data/strings.dart';
import 'package:rapidtradeai/model/future_trading_models.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';
import 'package:rapidtradeai/src/Service/future_trading_service.dart';
import 'package:rapidtradeai/src/widget/common_app_bar.dart';
import 'package:rapidtradeai/src/widget/trading_widgets.dart';

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
      if (mounted) {
        _refreshPositions();
      }
    });
  }

  Future<void> _loadPositions() async {
    // Call API in background without showing loader
    try {
      // Load real positions from API
      final response = await FutureTradingService.getDualSideOpenPositions(
        userId: commonuserId,
      );

      if (response != null && response.isSuccess && response.data != null) {
        setState(() {
          _positions = response.data!
              .map((apiPosition) => apiPosition.toFuturePosition())
              .toList();
        });
        print('✅ Loaded ${_positions.length} open positions');
      } else {
        print('❌ Failed to load positions: ${response?.message}');
        setState(() {
          _positions = [];
        });
      }
    } catch (e) {
      print('Error loading positions: $e');
      setState(() {
        _positions = [];
      });
    }
  }

  Future<void> _refreshPositions() async {
    // Refresh positions in background without showing loader
    try {
      // Reload positions from API
      final response = await FutureTradingService.getDualSideOpenPositions(
        userId: commonuserId,
      );

      if (response != null && response.isSuccess && response.data != null) {
        setState(() {
          _positions = response.data!
              .map((apiPosition) => apiPosition.toFuturePosition())
              .toList();
        });
        print('✅ Refreshed ${_positions.length} open positions');
      } else {
        print('❌ Failed to refresh positions: ${response?.message}');
      }
    } catch (e) {
      print('Error refreshing positions: $e');
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
      backgroundColor: Color(0xFF1E2329),
      appBar: _buildAppBar(),
      body: _buildPositionsContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CommonAppBar.basic(
      title: "Open Position",
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: TradingTheme.secondaryAccent),
          onPressed: _refreshPositions,
        ),
      ],
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
              color: TradingTheme.secondaryAccent,
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
      padding: EdgeInsets.all(kIsWeb ? 24 : 16), // Bigger padding for web
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _filterType == filter['key'];
            return Padding(
              padding: EdgeInsets.only(right: kIsWeb ? 12 : 8), // More spacing for web
              child: TradingButton(
                text: filter['label'] as String,
                onPressed: () =>
                    setState(() => _filterType = filter['key'] as String),
                backgroundColor: isSelected
                    ? TradingTheme.secondaryAccent
                    : TradingTheme.secondaryAccent,
                textColor: isSelected ? Colors.black : Colors.black,
                width: kIsWeb ? 100 : 80, // Bigger buttons for web
                height: kIsWeb ? 48 : 40, // Taller buttons for web
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
      padding: EdgeInsets.all(kIsWeb ? 24 : 16), // Bigger padding for web
      itemCount: _filteredPositions.length,
      itemBuilder: (context, index) {
        final position = _filteredPositions[index];
        return _buildPositionCard(position, index);
      },
    );
  }

  Widget _buildPositionCard(FuturePosition position, int index) {
    return AnimatedTradingCard(
      margin: EdgeInsets.only(bottom: kIsWeb ? 20 : 16), // More spacing for web
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with symbol and side
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: kIsWeb ? 12 : 8,
                  vertical: kIsWeb ? 6 : 4
                ), // Bigger padding for web
                decoration: BoxDecoration(
                  color: position.isLong
                      ? TradingTheme.successColor.withOpacity(0.1)
                      : TradingTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  position.side,
                  style: ResponsiveTradingTypography.bodyMedium.copyWith( // Bigger text for web
                    color: position.isLong
                        ? TradingTheme.successColor
                        : TradingTheme.errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: kIsWeb ? 16 : 12), // More spacing for web
              Expanded(
                child: Text(
                  position.symbol,
                  style: ResponsiveTradingTypography.heading3, // Much bigger symbol text for web
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${position.unrealizedPnl.toStringAsFixed(2)}',
                    style: ResponsiveTradingTypography.priceText.copyWith( // Much bigger PnL text for web
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
              // Only show fields that have real data from API
              if (position.marginUsed > 0) ...[
                Expanded(
                  child: _buildPositionDetail('Margin Used',
                      '\$${position.marginUsed.toStringAsFixed(2)}'),
                ),
              ],
              if (position.liquidationPrice > 0) ...[
                Expanded(
                  child: _buildPositionDetail('Liquidation',
                      '\$${position.liquidationPrice.toStringAsFixed(2)}'),
                ),
              ],
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
                  backgroundColor: TradingTheme.secondaryAccent,
                  textColor: TradingTheme.primaryText,
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
        backgroundColor: FutureTradingTheme.cardBackground,
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

  Future<void> _updateTpSl() async {
    print(
        '🎯 UPDATE TP/SL - Starting update for position ${widget.position.id}...');

    // Parse position ID from string to int
    final positionId = int.tryParse(widget.position.id);
    if (positionId == null) {
      print('❌ UPDATE TP/SL - Invalid position ID: ${widget.position.id}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid position ID',
            style: TradingTypography.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: TradingTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Get TP/SL values
    final tpPrice = _enableTp && _tpController.text.isNotEmpty
        ? double.tryParse(_tpController.text)
        : null;
    final slPrice = _enableSl && _slController.text.isNotEmpty
        ? double.tryParse(_slController.text)
        : null;

    if (!_enableTp && !_enableSl) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enable at least one of TP or SL',
            style: TradingTypography.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: TradingTheme.warningColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final response = await FutureTradingService.setDualSideTpSl(
        userId: commonuserId,
        positionId: positionId,
        tpPrice: tpPrice,
        slPrice: slPrice,
      );

      if (response != null && response.isSuccess) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'TP/SL updated successfully!\nTP: ${response.data?.tpPrice ?? 'Not set'}\nSL: ${response.data?.slPrice ?? 'Not set'}',
              style: TradingTypography.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: TradingTheme.successColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response?.message ?? 'Failed to update TP/SL',
              style: TradingTypography.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: TradingTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Network error: $e',
            style: TradingTypography.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: TradingTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: FutureTradingTheme.cardBackground,
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: TradingTheme.secondaryAccent),
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
          onPressed: () => _updateTpSl(),
          backgroundColor: TradingTheme.secondaryAccent,
          textColor: Colors.black,
          width: 80,
          height: 36,
        ),
      ],
    );
  }
}
