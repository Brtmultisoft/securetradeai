import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/model/future_trading_models.dart';
import 'package:securetradeai/model/repoModel.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/Service/future_trading_service.dart';
import 'package:securetradeai/src/widget/trading_widgets.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';

class FutureTradePage extends StatefulWidget {
  const FutureTradePage({Key? key}) : super(key: key);

  @override
  State<FutureTradePage> createState() => _FutureTradePageState();
}

class _FutureTradePageState extends State<FutureTradePage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  Timer? _priceUpdateTimer;
  bool _isLoading = false;

  // Form controllers
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _takeProfitController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Trading data
  FutureSymbol? _selectedSymbol;
  List<FutureSymbol> _availableSymbols = [];
  List<FutureSymbol> _filteredSymbols = [];
  double _leverage = 10.0;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Calculated values
  double _orderCost = 0.0;
  double _liquidationPrice = 0.0;
  double _estimatedFees = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSymbols();
    _startPriceUpdates();
    _amountController.addListener(_calculateOrderCost);
    _priceController.addListener(_calculateOrderCost);
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

  Future<void> _loadSymbols() async {
    setState(() => _isLoading = true);

    try {
      // Try to get real-time data from existing 24hr ticker API
      Repo? repo;
      try {
        repo = Provider.of<Repo>(context, listen: false);
      } catch (providerError) {
        print('Provider not available: $providerError');
        repo = null;
      }

      // Get all USDT pairs from the API data
      _availableSymbols = [];

      if (repo != null) {
        // Trigger data fetch if not already available
        if (repo.quantutumdata.isEmpty) {
          await repo.getquantitumData('', 0);
        }

        for (final symbolData in repo.quantutumdata) {
          final symbol = symbolData['symbol'] as String;

          // Filter for USDT pairs only (futures trading pairs)
          if (symbol.endsWith('USDT')) {
            final baseAsset = symbol.replaceAll('USDT', '');

            // Skip stablecoins and some problematic pairs
            if (_shouldIncludeSymbol(baseAsset)) {
              _availableSymbols.add(FutureSymbol(
                symbol: symbol,
                baseAsset: baseAsset,
                quoteAsset: 'USDT',
                currentPrice: double.tryParse(
                        symbolData['lastPrice']?.toString() ?? '0') ??
                    0.0,
                priceChange24h: double.tryParse(
                        symbolData['priceChange']?.toString() ?? '0') ??
                    0.0,
                priceChangePercent24h: double.tryParse(
                        symbolData['priceChangePercent']?.toString() ?? '0') ??
                    0.0,
                volume24h:
                    double.tryParse(symbolData['volume']?.toString() ?? '0') ??
                        0.0,
                high24h: double.tryParse(
                        symbolData['highPrice']?.toString() ?? '0') ??
                    0.0,
                low24h: double.tryParse(
                        symbolData['lowPrice']?.toString() ?? '0') ??
                    0.0,
                maxLeverage: 10, // Set to 10x as per requirement
                minOrderSize: _getMinOrderSize(baseAsset),
                tickSize: _getTickSize(baseAsset),
              ));
            }
          }
        }
      }

      // If no symbols loaded from API, use fallback
      if (_availableSymbols.isEmpty) {
        _availableSymbols = [
          FutureSymbol(
            symbol: 'BTCUSDT',
            baseAsset: 'BTC',
            quoteAsset: 'USDT',
            currentPrice: 43250.0,
            priceChange24h: 1250.0,
            priceChangePercent24h: 2.98,
            volume24h: 125000000.0,
            high24h: 44000.0,
            low24h: 42000.0,
            maxLeverage: 10,
            minOrderSize: 0.001,
            tickSize: 0.1,
          ),
          FutureSymbol(
            symbol: 'ETHUSDT',
            baseAsset: 'ETH',
            quoteAsset: 'USDT',
            currentPrice: 2680.0,
            priceChange24h: 45.0,
            priceChangePercent24h: 1.71,
            volume24h: 85000000.0,
            high24h: 2720.0,
            low24h: 2620.0,
            maxLeverage: 10,
            minOrderSize: 0.01,
            tickSize: 0.01,
          ),
        ];
      }

      // Sort by volume (most traded first)
      _availableSymbols.sort((a, b) => b.volume24h.compareTo(a.volume24h));

      // Initialize filtered symbols
      _filteredSymbols = List.from(_availableSymbols);

      if (_availableSymbols.isNotEmpty) {
        // Try to find BNBUSDT as default, otherwise use first symbol
        _selectedSymbol = _availableSymbols.firstWhere(
          (symbol) => symbol.symbol == 'BNBUSDT',
          orElse: () => _availableSymbols.first,
        );
        _priceController.text =
            _selectedSymbol!.currentPrice.toStringAsFixed(2);
        _calculateOrderCost();
      }
    } catch (e) {
      print('Error loading symbols: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _shouldIncludeSymbol(String baseAsset) {
    // Exclude stablecoins and problematic pairs
    final excludedAssets = {
      'USDC', 'BUSD', 'TUSD', 'PAX', 'USDS', 'FDUSD', 'DAI', // Stablecoins
      'UP', 'DOWN', 'BULL', 'BEAR', // Leveraged tokens
      'EUR', 'GBP', 'AUD', 'BRL', 'RUB', 'TRY', 'UAH', // Fiat pairs
    };

    // Exclude assets that contain these patterns
    final excludedPatterns = ['UP', 'DOWN', 'BULL', 'BEAR'];

    if (excludedAssets.contains(baseAsset)) {
      return false;
    }

    for (final pattern in excludedPatterns) {
      if (baseAsset.contains(pattern)) {
        return false;
      }
    }

    return true;
  }

  double _getMinOrderSize(String baseAsset) {
    switch (baseAsset) {
      case 'BTC':
        return 0.001;
      case 'ETH':
        return 0.01;
      case 'BNB':
      case 'ADA':
      case 'SOL':
      case 'DOT':
      case 'MATIC':
      case 'AVAX':
      case 'LINK':
        return 0.1;
      default:
        return 1.0; // Default for smaller coins
    }
  }

  double _getTickSize(String baseAsset) {
    switch (baseAsset) {
      case 'BTC':
        return 0.1;
      case 'ETH':
        return 0.01;
      case 'BNB':
      case 'ADA':
      case 'SOL':
      case 'DOT':
        return 0.01;
      default:
        return 0.001; // Smaller tick size for lower-priced coins
    }
  }

  void _startPriceUpdates() {
    _priceUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted && _selectedSymbol != null) {
        _updatePriceFromLiveData();
        // Also refresh the entire symbol list to get latest data
        _refreshSymbolData();
      }
    });
  }

  void _refreshSymbolData() {
    if (!mounted) return;

    try {
      final repo = Provider.of<Repo>(context, listen: false);

      // Check if we have fresh data from the API
      if (repo.quantutumdata.isEmpty) return;

      bool hasUpdates = false;

      // Update all symbols with latest data
      for (int i = 0; i < _availableSymbols.length; i++) {
        final currentSymbol = _availableSymbols[i];

        // Find matching data in API response
        for (final symbolData in repo.quantutumdata) {
          if (symbolData['symbol'] == currentSymbol.symbol) {
            final newPrice =
                double.tryParse(symbolData['lastPrice']?.toString() ?? '0') ??
                    currentSymbol.currentPrice;
            final newPriceChange =
                double.tryParse(symbolData['priceChange']?.toString() ?? '0') ??
                    currentSymbol.priceChange24h;
            final newPriceChangePercent = double.tryParse(
                    symbolData['priceChangePercent']?.toString() ?? '0') ??
                currentSymbol.priceChangePercent24h;

            // Only update if there are actual changes
            if (newPrice != currentSymbol.currentPrice ||
                newPriceChange != currentSymbol.priceChange24h ||
                newPriceChangePercent != currentSymbol.priceChangePercent24h) {
              _availableSymbols[i] = FutureSymbol(
                symbol: currentSymbol.symbol,
                baseAsset: currentSymbol.baseAsset,
                quoteAsset: currentSymbol.quoteAsset,
                currentPrice: newPrice,
                priceChange24h: newPriceChange,
                priceChangePercent24h: newPriceChangePercent,
                volume24h:
                    double.tryParse(symbolData['volume']?.toString() ?? '0') ??
                        currentSymbol.volume24h,
                high24h: double.tryParse(
                        symbolData['highPrice']?.toString() ?? '0') ??
                    currentSymbol.high24h,
                low24h: double.tryParse(
                        symbolData['lowPrice']?.toString() ?? '0') ??
                    currentSymbol.low24h,
                maxLeverage: currentSymbol.maxLeverage,
                minOrderSize: currentSymbol.minOrderSize,
                tickSize: currentSymbol.tickSize,
              );
              hasUpdates = true;
            }
            break;
          }
        }
      }

      // Only update UI if there were actual changes
      if (hasUpdates) {
        // Update filtered symbols as well
        _filteredSymbols = List.from(_availableSymbols);

        // Apply current search filter if any
        if (_searchQuery.isNotEmpty) {
          _filterSymbols(_searchQuery);
        }

        // Force UI update
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  void _updatePriceFromLiveData() {
    try {
      final repo = Provider.of<Repo>(context, listen: false);

      // Find the current symbol in the live data
      for (final symbolData in repo.quantutumdata) {
        if (symbolData['symbol'] == _selectedSymbol!.symbol) {
          final newPrice =
              double.tryParse(symbolData['lastPrice']?.toString() ?? '0') ??
                  _selectedSymbol!.currentPrice;

          // Only update if price has changed to avoid unnecessary rebuilds
          if (newPrice != _selectedSymbol!.currentPrice) {
            setState(() {
              _selectedSymbol = FutureSymbol(
                symbol: _selectedSymbol!.symbol,
                baseAsset: _selectedSymbol!.baseAsset,
                quoteAsset: _selectedSymbol!.quoteAsset,
                currentPrice: newPrice,
                priceChange24h: double.tryParse(
                        symbolData['priceChange']?.toString() ?? '0') ??
                    _selectedSymbol!.priceChange24h,
                priceChangePercent24h: double.tryParse(
                        symbolData['priceChangePercent']?.toString() ?? '0') ??
                    _selectedSymbol!.priceChangePercent24h,
                volume24h:
                    double.tryParse(symbolData['volume']?.toString() ?? '0') ??
                        _selectedSymbol!.volume24h,
                high24h: double.tryParse(
                        symbolData['highPrice']?.toString() ?? '0') ??
                    _selectedSymbol!.high24h,
                low24h: double.tryParse(
                        symbolData['lowPrice']?.toString() ?? '0') ??
                    _selectedSymbol!.low24h,
                maxLeverage: _selectedSymbol!.maxLeverage,
                minOrderSize: _selectedSymbol!.minOrderSize,
                tickSize: _selectedSymbol!.tickSize,
              );

              // Always use market price for market orders
              _priceController.text =
                  _selectedSymbol!.currentPrice.toStringAsFixed(2);
              _calculateOrderCost();
            });
          }
          break;
        }
      }
    } catch (e) {
      // Silently handle errors - don't disrupt the UI
    }
  }

  void _calculateOrderCost() {
    if (_selectedSymbol == null) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final price =
        double.tryParse(_priceController.text) ?? _selectedSymbol!.currentPrice;

    if (amount > 0 && price > 0) {
      setState(() {
        _orderCost = amount;
        _estimatedFees = _orderCost * 0.0004; // 0.04% fee

        // Calculate liquidation price (using default long position calculation)
        final marginRatio = 0.8; // 80% margin ratio
        _liquidationPrice = price * (1 - (1 / _leverage) * marginRatio);
      });
    }
  }

  void _filterSymbols(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredSymbols = List.from(_availableSymbols);
      } else {
        _filteredSymbols = _availableSymbols.where((symbol) {
          final symbolLower = symbol.symbol.toLowerCase();
          final baseAssetLower = symbol.baseAsset.toLowerCase();
          final queryLower = query.toLowerCase();

          return symbolLower.contains(queryLower) ||
              baseAssetLower.contains(queryLower);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterSymbols('');
  }

  @override
  void dispose() {
    _slideController.dispose();
    _priceUpdateTimer?.cancel();
    _amountController.dispose();
    _priceController.dispose();
    _takeProfitController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Repo>(
      builder: (context, repo, child) {
        return Scaffold(
          backgroundColor: TradingTheme.primaryBackground,
          appBar: _buildAppBar(),
          body: _isLoading ? _buildLoadingScreen() : _buildTradeContent(),
          bottomNavigationBar: _buildBottomActions(),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CommonAppBar.trading(
      title: 'New Order',
      badgeText: 'ORDER',
      badgeIcon: Icons.add_circle,
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: TradingLoadingIndicator(
        message: 'Loading Trading Data...',
      ),
    );
  }

  Widget _buildTradeContent() {
    return SlideTransition(
      position: _slideAnimation,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSymbolSelector(),
              _buildLeverageSelector(),
              _buildAmountInput(),
              _buildTakeProfit(),
              _buildOrderSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSymbolSelector() {
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
                'Select Symbol',
                style: TradingTypography.heading3,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedSymbol != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TradingTheme.surfaceBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: TradingTheme.primaryAccent),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedSymbol!.symbol,
                          style: TradingTypography.heading2,
                        ),
                        Text(
                          '${_selectedSymbol!.baseAsset}/${_selectedSymbol!.quoteAsset}',
                          style: TradingTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AnimatedPriceDisplay(
                        price:
                            '\$${_selectedSymbol!.currentPrice.toStringAsFixed(2)}',
                        textStyle: TradingTypography.priceText,
                      ),
                      Text(
                        '${_selectedSymbol!.priceChangePercent24h >= 0 ? '+' : ''}${_selectedSymbol!.priceChangePercent24h.toStringAsFixed(2)}%',
                        style: TradingTypography.bodySmall.copyWith(
                          color: _selectedSymbol!.priceChangePercent24h >= 0
                              ? TradingTheme.successColor
                              : TradingTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _showSymbolSelector,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: TradingTheme.primaryAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: TradingTheme.primaryAccent,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSymbolSelector() {
    // Reset search when opening modal
    _searchController.clear();

    // Force refresh data from Provider before showing modal
    try {
      final repo = Provider.of<Repo>(context, listen: false);
      if (repo.quantutumdata.isNotEmpty) {
        _refreshSymbolData();
      }
    } catch (e) {
      // Handle error silently
    }

    _filteredSymbols = List.from(_availableSymbols);

    showModalBottomSheet(
      context: context,
      backgroundColor: TradingTheme.secondaryBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.6,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Handle bar for dragging
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: TradingTheme.hintText,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Text(
                        'Select Trading Pair',
                        style: TradingTypography.heading3,
                      ),
                      const SizedBox(height: 20),

                      // Search bar
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: TextField(
                          controller: _searchController,
                          style: TradingTypography.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'Search trading pairs (e.g., BTC, ETH)',
                            hintStyle: TradingTypography.bodyMedium.copyWith(
                              color: TradingTheme.hintText,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: TradingTheme.secondaryText,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: TradingTheme.secondaryText,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setModalState(() {
                                        _filterSymbols('');
                                      });
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: TradingTheme.surfaceBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: TradingTheme.primaryBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: TradingTheme.primaryBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: TradingTheme.primaryAccent),
                            ),
                          ),
                          onChanged: (value) {
                            setModalState(() {
                              _filterSymbols(value);
                            });
                          },
                        ),
                      ),

                      // Results count
                      if (_searchQuery.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${_filteredSymbols.length} pairs found',
                            style: TradingTypography.bodySmall.copyWith(
                              color: TradingTheme.secondaryText,
                            ),
                          ),
                        ),

                      // Symbol list
                      Expanded(
                        child: _filteredSymbols.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.search_off,
                                      size: 48,
                                      color: TradingTheme.secondaryText,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No trading pairs found',
                                      style:
                                          TradingTypography.bodyMedium.copyWith(
                                        color: TradingTheme.secondaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Try a different search term',
                                      style:
                                          TradingTypography.bodySmall.copyWith(
                                        color: TradingTheme.hintText,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _buildSymbolList(scrollController),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSymbolList(ScrollController scrollController) {
    // Define recommended coins
    final recommendedSymbols = ['BNBUSDT', 'BTCUSDT', 'ETHUSDT', 'TRXUSDT'];

    // Get recommended coins from filtered symbols
    final recommendedCoins = _filteredSymbols
        .where((symbol) => recommendedSymbols.contains(symbol.symbol))
        .toList();

    // Get all other coins (excluding recommended ones)
    final otherCoins = _filteredSymbols
        .where((symbol) => !recommendedSymbols.contains(symbol.symbol))
        .toList();

    return ListView(
      controller: scrollController,
      children: [
        // Recommended Coins Section
        if (recommendedCoins.isNotEmpty && _searchQuery.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: TradingTheme.accentGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.black,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Recommended Coins',
                        style: TradingTypography.bodyMedium.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...recommendedCoins.map((symbol) => _buildSymbolOption(symbol)),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            height: 1,
            color: TradingTheme.primaryBorder,
          ),

          // All Coins Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TradingTheme.surfaceBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TradingTheme.primaryBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.list,
                        color: TradingTheme.primaryAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'All Trading Pairs',
                        style: TradingTypography.bodyMedium.copyWith(
                          color: TradingTheme.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${otherCoins.length} pairs',
                  style: TradingTypography.bodySmall.copyWith(
                    color: TradingTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],

        // All Coins Section
        ...(_searchQuery.isEmpty ? otherCoins : _filteredSymbols)
            .map((symbol) => _buildSymbolOption(symbol)),
      ],
    );
  }

  Widget _buildSymbolOption(FutureSymbol symbol) {
    final isSelected = _selectedSymbol?.symbol == symbol.symbol;

    return AnimatedTradingCard(
      margin: const EdgeInsets.only(bottom: 12),
      isSelected: isSelected,
      onTap: () {
        setState(() {
          _selectedSymbol = symbol;
          _priceController.text = symbol.currentPrice.toStringAsFixed(2);
          _leverage = _leverage > 10.0 ? 10.0 : _leverage;
        });
        Navigator.pop(context);
        _calculateOrderCost();
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol.symbol,
                  style: TradingTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${symbol.baseAsset}/${symbol.quoteAsset}',
                  style: TradingTypography.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${symbol.currentPrice.toStringAsFixed(2)}',
                style: TradingTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${symbol.priceChangePercent24h >= 0 ? '+' : ''}${symbol.priceChangePercent24h.toStringAsFixed(2)}%',
                style: TradingTypography.bodySmall.copyWith(
                  color: symbol.priceChangePercent24h >= 0
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

  Widget _buildLeverageSelector() {
    return AnimatedTradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.speed,
                color: TradingTheme.primaryAccent,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                'Leverage',
                style: TradingTypography.heading3,
              ),
              const Spacer(),
              Text(
                '${_leverage.toStringAsFixed(0)}x',
                style: TradingTypography.heading3.copyWith(
                  color: TradingTheme.primaryAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: TradingTheme.primaryAccent,
              inactiveTrackColor: TradingTheme.hintText,
              thumbColor: TradingTheme.primaryAccent,
              overlayColor: TradingTheme.primaryAccent.withOpacity(0.2),
            ),
            child: Slider(
              value: _leverage,
              min: 1.0,
              max: 10.0,
              divisions: 9,
              onChanged: (value) {
                setState(() {
                  _leverage = value;
                });
                _calculateOrderCost();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('1x', style: TradingTypography.bodySmall),
              Text('10x', style: TradingTypography.bodySmall),
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
                Icons.monetization_on,
                color: TradingTheme.primaryAccent,
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                'Amount (USDT)',
                style: TradingTypography.heading3,
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            style: TradingTypography.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Enter amount in USDT',
              hintStyle: TradingTypography.bodyMedium.copyWith(
                color: TradingTheme.hintText,
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
              suffixText: 'USDT',
              suffixStyle: TradingTypography.bodyMedium.copyWith(
                color: TradingTheme.secondaryText,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              if (amount < 10) {
                return 'Minimum amount is \$10';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPercentageButton('25%', 0.25),
              const SizedBox(width: 8),
              _buildPercentageButton('50%', 0.50),
              const SizedBox(width: 8),
              _buildPercentageButton('75%', 0.75),
              const SizedBox(width: 8),
              _buildPercentageButton('100%', 1.0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageButton(String text, double percentage) {
    return Expanded(
      child: TradingButton(
        text: text,
        onPressed: () {
          // Simulate available balance of $1000
          final availableBalance = 1000.0;
          final amount = availableBalance * percentage;
          _amountController.text = amount.toStringAsFixed(2);
          _calculateOrderCost();
        },
        backgroundColor: TradingTheme.surfaceBackground,
        textColor: TradingTheme.primaryText,
        height: 36,
      ),
    );
  }

  Widget _buildTakeProfit() {
    return AnimatedTradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.shield,
                color: TradingTheme.primaryAccent,
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                'Take Profit',
                style: TradingTypography.heading3,
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _takeProfitController,
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
                borderSide: const BorderSide(color: TradingTheme.successColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: TradingTheme.successColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: TradingTheme.successColor,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return AnimatedTradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.receipt,
                color: TradingTheme.primaryAccent,
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                'Order Summary',
                style: TradingTypography.heading3,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Order Cost', '\$${_orderCost.toStringAsFixed(2)}'),
          _buildSummaryRow(
              'Estimated Fees', '\$${_estimatedFees.toStringAsFixed(4)}'),
          _buildSummaryRow('Leverage', '${_leverage.toStringAsFixed(0)}x'),
          if (_liquidationPrice > 0)
            _buildSummaryRow(
              'Liquidation Price',
              '\$${_liquidationPrice.toStringAsFixed(2)}',
              valueColor: TradingTheme.errorColor,
            ),
          const Divider(color: TradingTheme.primaryBorder),
          _buildSummaryRow(
            'Total Required',
            '\$${(_orderCost + _estimatedFees).toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {Color? valueColor, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? TradingTypography.bodyLarge
                    .copyWith(fontWeight: FontWeight.bold)
                : TradingTypography.bodyMedium,
          ),
          Text(
            value,
            style: (isTotal
                    ? TradingTypography.bodyLarge
                        .copyWith(fontWeight: FontWeight.bold)
                    : TradingTypography.bodyMedium)
                .copyWith(
              color: valueColor ?? TradingTheme.primaryText,
            ),
          ),
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
      child: Row(
        children: [
          Expanded(
            child: TradingButton(
              text: 'Place Order',
              onPressed: _isLoading ? null : _submitOrder,
              isLoading: _isLoading,
              backgroundColor: TradingTheme.primaryAccent,
              textColor: Colors.black,
              height: 56,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitOrder() async {
    // if (!_formKey.currentState!.validate()) {
    //   return;
    // }

    // Validate required fields
    if (_selectedSymbol == null) {
      // _showErrorMessage('Please select a trading pair');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      // _showErrorMessage('Please enter a valid amount');
      return;
    }

    final takeProfitPercent = double.tryParse(_takeProfitController.text);
    if (takeProfitPercent == null || takeProfitPercent <= 0) {
      // _showErrorMessage('Please enter a valid take profit percentage');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Calculate position size: (amount in percentage) / (live price of selected symbol)
      final currentPrice = _selectedSymbol!.currentPrice;
      final positionSize =
          double.parse((amount / currentPrice).toStringAsFixed(2));

      // Call the dual-side init API
      final response = await FutureTradingService.initializeDualSideStrategy(
        userId: commonuserId,
        symbol: _selectedSymbol!.symbol,
        positionSize: positionSize,
        tpPercentage: takeProfitPercent,
        leverage: _leverage.toInt(),
      );

      if (mounted) {
        if (response != null && response.isSuccess) {
          // Show success popup and notification
          await _showSuccessPopup(response.data!);
          _sendSuccessNotification(response.data!);

          // Navigate back to dashboard
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          // Show error popup and notification
          final errorMessage = response?.message ?? 'Unknown error occurred';
          await _showErrorPopup('Failed to initialize strategy', errorMessage);
          _sendErrorNotification(errorMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        await _showErrorPopup(
            'Network Error', 'Please check your connection and try again');
        _sendErrorNotification('Network error occurred');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Success Popup Dialog
  Future<void> _showSuccessPopup(DualSideInitData data) async {
    // Haptic feedback for success
    HapticFeedback.lightImpact();

    return showDialog<void>(
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
                  'Strategy Initialized!',
                  style: TradingTypography.heading3.copyWith(
                    color: TradingTheme.successColor,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your dual-side trading strategy has been successfully initialized.',
                  style: TradingTypography.bodyMedium.copyWith(
                    color: TradingTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TradingTheme.surfaceBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TradingTheme.primaryBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('🆔 Pair ID', data.pairId),
                      _buildDetailRow('💰 Entry Price',
                          '\$${data.entryPrice.toStringAsFixed(2)}'),
                      _buildDetailRow(
                          '📈 Long TP', '\$${data.longTp.toStringAsFixed(2)}'),
                      _buildDetailRow('📉 Short TP',
                          '\$${data.shortTp.toStringAsFixed(2)}'),
                      _buildDetailRow('🔢 Long Position ID',
                          data.longPositionId.toString()),
                      _buildDetailRow('🔢 Short Position ID',
                          data.shortPositionId.toString()),
                      _buildDetailRow(
                          '⚡ Strategy ID', data.strategyId.toString()),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TradingTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: TradingTheme.successColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: TradingTheme.successColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You can monitor your positions in the Positions tab.',
                          style: TradingTypography.bodySmall.copyWith(
                            color: TradingTheme.successColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'View Positions',
                style: TradingTypography.bodyMedium.copyWith(
                  color: TradingTheme.secondaryText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TradingTheme.successColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Got It!',
                style: TradingTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Error Popup Dialog
  Future<void> _showErrorPopup(String title, String message) async {
    // Haptic feedback for error
    HapticFeedback.heavyImpact();

    return showDialog<void>(
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
                  title,
                  style: TradingTypography.heading3.copyWith(
                    color: TradingTheme.errorColor,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: TradingTypography.bodyMedium.copyWith(
                  color: TradingTheme.primaryText,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TradingTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: TradingTheme.errorColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: TradingTheme.errorColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please check your internet connection and try again.',
                        style: TradingTypography.bodySmall.copyWith(
                          color: TradingTheme.errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Retry the order
                _submitOrder();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TradingTheme.primaryAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Retry',
                style: TradingTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to build detail rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TradingTypography.bodySmall.copyWith(
              color: TradingTheme.secondaryText,
            ),
          ),
          Text(
            value,
            style: TradingTypography.bodySmall.copyWith(
              color: TradingTheme.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Success Push Notification
  void _sendSuccessNotification(DualSideInitData data) {
    // Show local notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.check_circle,
                color: TradingTheme.successColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Strategy Initialized Successfully!',
                    style: TradingTypography.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Pair ID: ${data.pairId} • Entry: \$${data.entryPrice.toStringAsFixed(2)}',
                    style: TradingTypography.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: TradingTheme.successColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to positions page
          },
        ),
      ),
    );

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  // Error Push Notification
  void _sendErrorNotification(String message) {
    // Show local notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.error_outline,
                color: TradingTheme.errorColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Strategy Initialization Failed',
                    style: TradingTypography.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    message,
                    style: TradingTypography.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: TradingTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            _submitOrder();
          },
        ),
      ),
    );

    // Haptic feedback
    HapticFeedback.heavyImpact();
  }
}
