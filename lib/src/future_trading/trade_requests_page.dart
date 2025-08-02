import 'package:flutter/material.dart';
import 'package:securetradeai/model/future_trading_models.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/Service/future_trading_service.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';
import 'package:securetradeai/src/widget/trading_widgets.dart';

class TradeRequestsPage extends StatefulWidget {
  const TradeRequestsPage({Key? key}) : super(key: key);

  @override
  State<TradeRequestsPage> createState() => _TradeRequestsPageState();
}

class _TradeRequestsPageState extends State<TradeRequestsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isLoading = true;
  List<TradeRequest> _tradeRequests = [];
  String _selectedFilter = 'all'; // all, pending, activated, rejected

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadTradeRequests();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _scaleController.forward();
  }

  Future<void> _loadTradeRequests() async {
    try {
      setState(() => _isLoading = true);

      final tradeRequests = await FutureTradingService.getTradeRequests();

      if (mounted) {
        setState(() {
          _tradeRequests = tradeRequests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _tradeRequests = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading trade requests: $e'),
            backgroundColor: TradingTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _testApiCall() async {
    try {
      print('🧪 Testing API call manually...');
      final tradeRequests = await FutureTradingService.getTradeRequests();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('API Test: Found ${tradeRequests.length} requests'),
          backgroundColor: TradingTheme.successColor,
          duration: const Duration(seconds: 3),
        ),
      );

      // Refresh the data
      _loadTradeRequests();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('API Test Failed: $e'),
          backgroundColor: TradingTheme.errorColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  List<TradeRequest> get _filteredRequests {
    switch (_selectedFilter) {
      case 'pending':
        return _tradeRequests.where((r) => r.isPending).toList();
      case 'activated':
        return _tradeRequests.where((r) => r.isActivated).toList();
      case 'closed':
        return _tradeRequests.where((r) => r.isClosed).toList();
      default:
        return _tradeRequests;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TradingTheme.primaryBackground,
      appBar: CommonAppBar(
        title: 'Trade Requests',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: TradingTheme.primaryAccent),
            onPressed: _loadTradeRequests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: TradingTheme.primaryAccent,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadTradeRequests,
              color: TradingTheme.primaryAccent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterTabs(),
                    const SizedBox(height: 20),
                    _buildRequestsList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFilterTabs() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedTradingCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.filter_list,
                  color: TradingTheme.primaryAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Filter Requests',
                  style: TradingTypography.heading3,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All (${_tradeRequests.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('pending',
                      'Pending (${_tradeRequests.where((r) => r.isPending).length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('activated',
                      'Activated (${_tradeRequests.where((r) => r.isActivated).length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('rejected',
                      'Closed (${_tradeRequests.where((r) => r.isClosed).length})'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? TradingTheme.primaryAccent
              : TradingTheme.surfaceBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? TradingTheme.primaryAccent
                : TradingTheme.secondaryText.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TradingTypography.bodySmall.copyWith(
            color: isSelected
                ? TradingTheme.bullishCandle
                : TradingTheme.primaryText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsList() {
    final filteredRequests = _filteredRequests;

    if (filteredRequests.isEmpty) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedTradingCard(
          child: Center(
            child: Column(
              children: [
                Icon(
                  _selectedFilter == 'all'
                      ? Icons.hourglass_empty
                      : Icons.filter_list_off,
                  color: TradingTheme.secondaryText,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedFilter == 'all'
                      ? 'No trade requests found'
                      : 'No ${_selectedFilter} requests',
                  style: TradingTypography.heading3.copyWith(
                    color: TradingTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedFilter == 'all'
                      ? 'Submit a trade request to see it here'
                      : 'Try selecting a different filter',
                  style: TradingTypography.bodyMedium.copyWith(
                    color: TradingTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: filteredRequests
            .map((request) => _buildTradeRequestCard(request))
            .toList(),
      ),
    );
  }

  Widget _buildTradeRequestCard(TradeRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AnimatedTradingCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(request.status),
                    color: _getStatusColor(request.status),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request #${request.id}',
                        style: TradingTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        request.formattedCreatedAt,
                        style: TradingTypography.bodySmall.copyWith(
                          color: TradingTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    request.statusDisplayText,
                    style: TradingTypography.bodySmall.copyWith(
                      color: _getStatusColor(request.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TradingTheme.surfaceBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      'Amount',
                      '\$${request.positionQuantity.toStringAsFixed(2)}',
                      Icons.monetization_on,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: TradingTheme.secondaryText.withOpacity(0.2),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      'Leverage',
                      '${request.leverage}x',
                      Icons.trending_up,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: TradingTheme.primaryAccent,
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TradingTypography.bodySmall.copyWith(
            color: TradingTheme.secondaryText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TradingTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TradingTheme.warningColor;
      case 'activated':
        return TradingTheme.successColor;
      case 'rejected':
        return TradingTheme.errorColor;
      default:
        return TradingTheme.secondaryText;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'activated':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}
