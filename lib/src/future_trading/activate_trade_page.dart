import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rapidtradeai/data/api.dart';
import 'package:rapidtradeai/model/future_trading_models.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';
import 'package:rapidtradeai/src/Service/future_trading_service.dart';
import 'package:rapidtradeai/src/Service/symbol_whitelisting_service.dart';
import 'package:rapidtradeai/src/widget/common_app_bar.dart';
import 'package:rapidtradeai/src/widget/trading_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'trading_pair_popup.dart';

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
  List<TradingPair> _tradingPairs = [];

  // Whitelisting state
  bool _isCheckingWhitelisting = false;
  Map<String, bool> _whitelistingStatus = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Add listener for instant validation
    _amountController.addListener(_validateAmount);
    // Load available balance and trading pairs
    _loadAvailableBalance();
    _loadTradingPairs();
  }

  Future<void> _loadAvailableBalance() async {
    try {
      final accountSummary =
          await FutureTradingService.getDualSideAccountBalance();
      if (accountSummary != null && mounted) {
        setState(() {
          _availableBalance = accountSummary.availableBalance;
        });
      }
    } catch (e) {
      // Handle error silently, keep default balance of 0.0
    }
  }

  Future<void> _loadTradingPairs() async {
    try {
      final tradingPairs = await FutureTradingService.getActiveTradingPairs();
      if (mounted) {
        setState(() {
          _tradingPairs = tradingPairs;
        });

        // Check whitelisting status for all pairs
        _checkAllPairsWhitelisting();
      }
    } catch (e) {
      // Handle error silently, keep empty list
    }
  }

  Future<void> _checkAllPairsWhitelisting() async {
    if (_tradingPairs.isEmpty) return;

    try {
      final symbols = _tradingPairs.map((pair) => pair.assets).toList();
      final whitelistingResults =
          await SymbolWhitelistingService.checkMultipleSymbols(symbols);

      if (mounted) {
        setState(() {
          _whitelistingStatus = whitelistingResults;
        });

        print('📊 Whitelisting status for all pairs: $whitelistingResults');
      }
    } catch (e) {
      print('❌ Error checking whitelisting for all pairs: $e');
    }
  }

  void _showTradingPairPopup(TradingPair pair) async {
    print('🎯 Trading pair clicked: ${pair.assets}');

    // Check if symbol is whitelisted
    setState(() {
      _isCheckingWhitelisting = true;
    });

    try {
      final isWhitelisted =
          await SymbolWhitelistingService.isSymbolWhitelisted(pair.assets);

      setState(() {
        _isCheckingWhitelisting = false;
        _whitelistingStatus[pair.assets] = isWhitelisted;
      });

      if (isWhitelisted) {
        // Symbol is whitelisted, navigate directly to activation page
        print(
            '✅ Symbol ${pair.assets} is whitelisted, navigating to activation page');
        _navigateToActivationPage(pair);
      } else {
        // Symbol is not whitelisted, show popup
        print('❌ Symbol ${pair.assets} is not whitelisted, showing popup');
        showDialog(
          context: context,
          barrierDismissible: false, // Cannot dismiss by tapping outside
          barrierColor: Colors.black.withOpacity(0.8), // Blurred background
          builder: (BuildContext context) {
            return TradingPairPopup(
              tradingPair: pair,
              onClose: () => Navigator.of(context).pop(),
            );
          },
        );
      }
    } catch (e) {
      setState(() {
        _isCheckingWhitelisting = false;
      });
      print('❌ Error checking whitelisting for ${pair.assets}: $e');
      // On error, show popup as fallback
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.8),
        builder: (BuildContext context) {
          return TradingPairPopup(
            tradingPair: pair,
            onClose: () => Navigator.of(context).pop(),
          );
        },
      );
    }
  }

  void _navigateToActivationPage(TradingPair pair) {
    // Navigate to the actual activation page
    // You can implement the navigation logic here based on your app's structure
    print('🚀 Navigating to activation page for ${pair.assets}');

    // Example: Navigate to future trade page or specific activation screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => FutureTradePage(selectedPair: pair),
    //   ),
    // );

    // For now, just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${pair.assets} is whitelisted!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAllTradingPairsPopup() async {
    print('🎯 checking whitelisting status');

    // Check if all pairs are whitelisted
    if (_tradingPairs.isNotEmpty) {
      final allSymbols = _tradingPairs.map((pair) => pair.assets).toList();
      final areAllWhitelisted =
          await SymbolWhitelistingService.areAllSymbolsWhitelisted(allSymbols);

      if (areAllWhitelisted) {
        // All pairs are whitelisted, navigate directly to activation
        print('✅ All trading pairs are whitelisted');
        _showDirectActivationDialog();
        return;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Blurred background
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                ),
              ),

              // Popup content
              Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF333333),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C5CE7).withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.currency_exchange,
                              color: Color(0xFF6C5CE7),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Select Trading Pair',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Trading pairs list
                      Expanded(
                        child: _tradingPairs.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.currency_exchange,
                                      color: Color(0xFF666666),
                                      size: 48,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Loading trading pairs...',
                                      style: TextStyle(
                                        color: Color(0xFF666666),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: _tradingPairs.length,
                                itemBuilder: (context, index) {
                                  final pair = _tradingPairs[index];
                                  return _buildPopupTradingPairItem(pair);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDirectActivationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'All Pairs Whitelisted',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'All trading pairs are whitelisted for your account. You can proceed directly to activation.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _proceedToActivation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Proceed to Activation'),
            ),
          ],
        );
      },
    );
  }

  void _proceedToActivation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All pairs are whitelisted!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // You can navigate to the actual activation page here
    // Navigator.push(context, MaterialPageRoute(builder: (context) => ActivationPage()));
  }

  Widget _buildPopupTradingPairItem(TradingPair pair) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop(); // Close popup
            _showTradingPairPopup(pair); // Show individual pair popup
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF444444),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: pair.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            pair.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  pair.assets.substring(0, 1),
                                  style: const TextStyle(
                                    color: Color(0xFF6C5CE7),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Text(
                            pair.assets.substring(0, 1),
                            style: const TextStyle(
                              color: Color(0xFF6C5CE7),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pair.assets,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Active Trading Pair',
                        style: TextStyle(
                          color: Color(0xFF00C851),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: TradingTheme.secondaryAccent,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        _amountError =
            'Amount exceeds available balance (\$${_availableBalance.toStringAsFixed(2)})';
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
          'User-Agent': 'rapidtradeai-Mobile-App',
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
      backgroundColor: TradingTheme.backgroundColor,
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
            children:  [
              const Icon(
                Icons.flash_on,
                color: FutureTradingTheme.secondaryAccent,
                size: 24,
              ),
              const SizedBox(width: 12),
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
              color: FutureTradingTheme.secondaryAccent,
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
            children: [
              const Icon(
                Icons.currency_exchange,
                color: TradingTheme.secondaryAccent,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Trading Pairs',
                style: TradingTypography.heading3,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _tradingPairs.isEmpty
              ? Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.currency_exchange,
                        color: TradingTheme.secondaryAccent,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Loading trading pairs...',
                        style: TradingTypography.bodyMedium.copyWith(
                          color: TradingTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    final cardWidth = (screenWidth - 24) / 2;
                    final aspectRatio = cardWidth / 45;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _tradingPairs.length,
                      itemBuilder: (context, index) {
                        final pair = _tradingPairs[index];
                        return _buildPairOption(pair);
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildPairOption(TradingPair pair) {
    final isWhitelisted = _whitelistingStatus[pair.assets] ?? false;

    return GestureDetector(
      onTap: () => _showTradingPairPopup(pair),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: FutureTradingTheme.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isWhitelisted
                ? Colors.green.withOpacity(0.5)
                : FutureTradingTheme.primaryBorder,
            width: isWhitelisted ? 2 : 1,
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
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: FutureTradingTheme.primaryAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: pair.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            pair.imageUrl,
                            width: 20,
                            height: 20,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  pair.assets.substring(0, 3),
                                  style: const TextStyle(
                                    color: TradingTheme.primaryAccent,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Text(
                            pair.assets.substring(0, 3),
                            style: const TextStyle(
                              color: TradingTheme.primaryAccent,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pair.assets,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: TradingTheme.primaryText,
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (isWhitelisted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '✓',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      // Text(
                      //   'Trading Pair',
                      //   style: const TextStyle(
                      //     color: TradingTheme.secondaryText,
                      //     fontSize: 8,
                      //   ),
                      //   overflow: TextOverflow.ellipsis,
                      //   maxLines: 1,
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return AnimatedTradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children:  [
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
                color: TradingTheme.secondaryAccent,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: TradingTheme.secondaryAccent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: TradingTheme.secondaryAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: TradingTheme.secondaryAccent),
              ),
            ),
          ),
          if (_amountError != null) ...[
            const SizedBox(height: 8),
            Text(
              _amountError!,
              style: TradingTypography.bodySmall.copyWith(
                color: FutureTradingTheme.errorColor,
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
        color: FutureTradingTheme.secondaryBackground,
        border: Border(
          top: BorderSide(
            color: FutureTradingTheme.primaryBorder,
            width: 1,
          ),
        ),
      ),
      child: TradingButton(
        text: 'Activate Trade',
        onPressed: _canSubmit() ? _showAllTradingPairsPopup : null,
        isLoading: _isLoading,
        backgroundColor: TradingTheme.secondaryAccent,
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
               Expanded(
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
               Expanded(
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
