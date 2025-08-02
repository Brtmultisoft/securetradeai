import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/data/api.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';
import 'package:securetradeai/src/widget/trading_widgets.dart';
import 'package:securetradeai/src/Service/future_trading_service.dart';
import 'package:securetradeai/model/future_trading_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivateTradePage extends StatefulWidget {
  const ActivateTradePage({Key? key}) : super(key: key);

  @override
  State<ActivateTradePage> createState() => _ActivateTradePageState();
}

class _ActivateTradePageState extends State<ActivateTradePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _amountError;
  double _availableBalance = 0.0;

  // Top 6 trading pairs for display
  final List<Map<String, dynamic>> _cryptoPairs = [
    {
      'symbol': 'BTCUSDT',
      'name': 'Bitcoin',
      'price': 43250.50,
      'change': 2.45,
      'icon': '₿',
    },
    {
      'symbol': 'ETHUSDT',
      'name': 'Ethereum',
      'price': 2650.75,
      'change': -1.23,
      'icon': 'Ξ',
    },
    {
      'symbol': 'BNBUSDT',
      'name': 'BNB',
      'price': 315.20,
      'change': 3.67,
      'icon': 'BNB',
    },
    {
      'symbol': 'ADAUSDT',
      'name': 'Cardano',
      'price': 0.4825,
      'change': 5.12,
      'icon': 'ADA',
    },
    {
      'symbol': 'SOLUSDT',
      'name': 'Solana',
      'price': 98.45,
      'change': -2.89,
      'icon': 'SOL',
    },
    {
      'symbol': 'XRPUSDT',
      'name': 'XRP',
      'price': 0.6234,
      'change': 1.78,
      'icon': 'XRP',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Add listener for instant validation
    _amountController.addListener(_validateAmount);
    // Load available balance
    _loadAvailableBalance();
  }

  Future<void> _loadAvailableBalance() async {
    try {
      final accountSummary = await FutureTradingService.getDualSideAccountBalance();
      if (accountSummary != null && mounted) {
        setState(() {
          _availableBalance = accountSummary.availableBalance;
        });
      }
    } catch (e) {
      // Handle error silently, keep default balance of 0.0
    }
  }

  void _validateAmount() {
    final text = _amountController.text;
    if (text.isEmpty) {
      setState(() {
        _amountError = null;
      });
      return;
    }

    final amount = double.tryParse(text);
    if (amount == null) {
      setState(() {
        _amountError = 'Please enter a valid amount';
      });
    } else if (amount < 0) {
      setState(() {
        _amountError = 'Amount must be greater than 0';
      });
    } else if (amount > _availableBalance) {
      setState(() {
        _amountError = 'Amount exceeds available balance (\$${_availableBalance.toStringAsFixed(2)})';
      });
    } else {
      setState(() {
        _amountError = null;
      });
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _amountController.removeListener(_validateAmount);
    _animationController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _initiateTradeAPI() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdString = prefs.getString('userid') ?? '';
      final userId = int.tryParse(userIdString) ?? 0;
      final amount = double.parse(_amountController.text);

      print('🔍 Initiating trade with user_id: $userId, amount: $amount');

      final response = await http.post(
        Uri.parse(initiateTradeUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'SecureTradeAI-Mobile-App',
        },
        body: json.encode({
          'user_id': userId,
          'position_quantity': amount,
        }),
      );

      print('🔍 API Response: ${response.statusCode} - ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        _showSuccessPopup(responseData['message']);
      } else {
        _showFailurePopup(responseData['message'] ?? 'Trade initiation failed');
      }
    } catch (e) {
      print('❌ API Error: $e');
      _showFailurePopup('Network error. Please try again.');
    }
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
    return CommonAppBar.trading(
      title: 'Activate Trade',
      badgeText: 'ACTIVATE',
      badgeIcon: Icons.flash_on,
    );
  }

  Widget _buildContent() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 24),
                _buildPairSelection(),
                const SizedBox(height: 24),
                _buildAmountInput(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return AnimatedTradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.flash_on,
                color: TradingTheme.primaryAccent,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Quick Trade Activation',
                style: TradingTypography.heading2,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Trade will be activated by admin with assurance to give you up to 15-20% profit. Enter amount to get started.',
            style: TradingTypography.bodyMedium.copyWith(
              color: TradingTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TradingTheme.primaryAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: TradingTheme.primaryAccent.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: TradingTheme.primaryAccent,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Admin will review and activate your trade within 24 hours',
                    style: TradingTypography.bodySmall.copyWith(
                      color: TradingTheme.primaryAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPairSelection() {
    return AnimatedTradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.currency_exchange,
                color: TradingTheme.primaryAccent,
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                'Top Trading Pairs',
                style: TradingTypography.heading3,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final cardWidth = (screenWidth - 24) / 2; // Account for spacing
              final aspectRatio = cardWidth / 60; // Fixed height of 60

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: aspectRatio,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _cryptoPairs.length,
                itemBuilder: (context, index) {
                  final pair = _cryptoPairs[index];
                  return _buildPairOption(pair);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPairOption(Map<String, dynamic> pair) {
    final isPositive = pair['change'] > 0;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: TradingTheme.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: TradingTheme.primaryBorder,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: TradingTheme.primaryAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    pair['icon'],
                    style: const TextStyle(
                      color: TradingTheme.primaryAccent,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pair['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: TradingTheme.primaryText,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      pair['symbol'],
                      style: const TextStyle(
                        color: TradingTheme.secondaryText,
                        fontSize: 8,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 3,
                child: Text(
                  '\$${pair['price'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: TradingTheme.primaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Flexible(
                flex: 2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? TradingTheme.successColor.withOpacity(0.2)
                        : TradingTheme.errorColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}${pair['change'].toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: isPositive
                          ? TradingTheme.successColor
                          : TradingTheme.errorColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 7,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return AnimatedTradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.attach_money,
                color: TradingTheme.primaryAccent,
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                'Enter Amount',
                style: TradingTypography.heading3,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Available Balance: ',
                style: TradingTypography.bodySmall.copyWith(
                  color: TradingTheme.secondaryText,
                ),
              ),
              Text(
                '\$${_availableBalance.toStringAsFixed(2)}',
                style: TradingTypography.bodySmall.copyWith(
                  color: TradingTheme.successColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TradingTypography.bodyLarge.copyWith(
              color: TradingTheme.primaryText,
            ),
            decoration: InputDecoration(
              hintText: 'Enter amount in USDT',
              hintStyle: TradingTypography.bodyMedium.copyWith(
                color: TradingTheme.hintText,
              ),
              prefixIcon: const Icon(
                Icons.monetization_on,
                color: TradingTheme.primaryAccent,
              ),
              filled: true,
              fillColor: TradingTheme.surfaceBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: TradingTheme.primaryBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: TradingTheme.primaryBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: TradingTheme.primaryAccent),
              ),
            ),
          ),
          if (_amountError != null) ...[
            const SizedBox(height: 8),
            Text(
              _amountError!,
              style: TradingTypography.bodySmall.copyWith(
                color: TradingTheme.errorColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: TradingTheme.secondaryBackground,
        border: Border(
          top: BorderSide(
            color: TradingTheme.primaryBorder,
            width: 1,
          ),
        ),
      ),
      child: TradingButton(
        text: 'Activate Trade',
        onPressed: _canSubmit() ? _submitActivation : null,
        isLoading: _isLoading,
        backgroundColor: TradingTheme.primaryAccent,
        textColor: Colors.black,
        height: 56,
      ),
    );
  }

  bool _canSubmit() {
    return _amountController.text.isNotEmpty &&
        _amountError == null &&
        !_isLoading;
  }

  Future<void> _submitActivation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _initiateTradeAPI();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessPopup([String? message]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: TradingTheme.secondaryBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TradingTheme.successColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Request Submitted!',
                  style: TradingTypography.heading3,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message ??
                    'Your trade request has been successfully submitted.',
                style: TradingTypography.bodyMedium.copyWith(
                  color: TradingTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TradingTheme.surfaceBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Amount:',
                          style: TradingTypography.bodySmall.copyWith(
                            color: TradingTheme.secondaryText,
                          ),
                        ),
                        Text(
                          '\$${_amountController.text}',
                          style: TradingTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TradingButton(
              text: 'Continue',
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              backgroundColor: TradingTheme.successColor,
              textColor: Colors.white,
              width: 100,
              height: 40,
            ),
          ],
        );
      },
    );
  }

  void _showFailurePopup([String? message]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: TradingTheme.secondaryBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TradingTheme.errorColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Request Failed',
                  style: TradingTypography.heading3,
                ),
              ),
            ],
          ),
          content: Text(
            message ??
                'Failed to submit trade request. Please check your connection and try again.',
            style: TradingTypography.bodyMedium.copyWith(
              color: TradingTheme.secondaryText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TradingTypography.bodyMedium.copyWith(
                  color: TradingTheme.secondaryText,
                ),
              ),
            ),
            TradingButton(
              text: 'Retry',
              onPressed: () {
                Navigator.of(context).pop();
                _submitActivation();
              },
              backgroundColor: TradingTheme.errorColor,
              textColor: Colors.white,
              width: 80,
              height: 40,
            ),
          ],
        );
      },
    );
  }
}
