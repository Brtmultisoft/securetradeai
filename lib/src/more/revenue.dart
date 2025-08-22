import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/model/future_trading_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../method/methods.dart';
import '../../model/revenueModel.dart';
import '../Service/assets_service.dart';
import '../Service/future_trading_service.dart';
import '../widget/common_app_bar.dart';
import 'revenueDetailBydate.dart';

class Revenue extends StatefulWidget {
  @override
  State<Revenue> createState() => _RevenueState();
}

class _RevenueState extends State<Revenue> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Detail> getRevenueDetail = [];
  String today = "0.000";
  String cumulative = "0.000";
  bool checkData = false;
  bool isAPIcalled = false;
  String currentCurrencyAMT = "0.000";
  String currentCurrency = "USD";
  double todayincr = 0.000;
  double comulativeincr = 0.000;

  // Future Trading Revenue Variables
  FutureTradingRevenueData? futureTradingRevenue;
  bool isFutureAPIcalled = false;
  bool checkFutureData = false;
  double futureTodayincr = 0.0;
  double futureCumulativeincr = 0.0;

  Future<void> _loadCurrentCurrency() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        currentCurrency = prefs.getString('currentCurrency') ?? "USD";
      });
    } catch (e) {
      print("Error loading currency: $e");
    }
  }

  Future<void> _getRevenueData() async {
    if (!mounted) return;
    setState(() {
      isAPIcalled = true;
      getRevenueDetail = [];
    });
    try {
      final data = await CommonMethod().getRevenueDetail();
      if (data.status == "success" && data.data != null) {
        var a = data.data.cumulativeProfit;
        var b = data.data.profitToday;

        if (!mounted) return;
        setState(() {
          today = b != 0 ? b.toStringAsFixed(6) : "0.000000";
          cumulative = a != 0 ? a.toStringAsFixed(6) : "0.000000";
          if (data.data.details != null) {
            List<Detail> details = [];

            for (int i = 0; i < data.data.details.length; i++) {
              var detail = data.data.details[i];
              try {
                var rawBalance = detail.totalbal;

                double balanceValue = 0.0;
                if (rawBalance != null) {
                  try {
                    String balanceStr = rawBalance.toString().trim();
                    if (balanceStr.isNotEmpty) {
                      balanceValue =
                          double.tryParse(balanceStr.replaceAll(',', '')) ??
                              0.0;
                    }
                  } catch (e) {}
                }
                details.add(Detail(
                  id: detail.id,
                  cryptoPair: detail.cryptoPair,
                  profit: balanceValue.toStringAsFixed(6),
                  sellOrBuy: detail.sellOrBuy,
                  exchanger: detail.exchanger,
                  createdate: detail.createdate,
                  totalbal: detail.totalbal,
                ));
              } catch (e) {
                continue;
              }
            }
            getRevenueDetail = details;
            getRevenueDetail
                .sort((a, b) => b.createdate.compareTo(a.createdate));
          }
          checkData = getRevenueDetail.isEmpty;
        });
        await _updateCurrencyValues();
      } else {
        if (!mounted) return;
        setState(() {
          checkData = true;
        });
        showtoast(data.message, context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        checkData = true;
      });
      showtoast("Failed to load revenue data", context);
    } finally {
      if (!mounted) return;
      setState(() {
        isAPIcalled = false;
      });
    }
  }

  Future<void> _updateCurrencyValues() async {
    try {
      var totalcurrency = await CommonMethod().getCurrency(0.0);
      setState(() {
        todayincr = double.parse(today) * totalcurrency;
        comulativeincr = double.parse(cumulative) * totalcurrency;
      });
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCurrentCurrency();
    _getRevenueData();
    _getFutureTradingRevenue();
  }

  // Fetch Future Trading Revenue Data
  Future<void> _getFutureTradingRevenue() async {
    setState(() {
      isFutureAPIcalled = true;
    });

    try {
      print("🔄 Starting to fetch future trading revenue data...");

      final data = await FutureTradingService.getFutureTradingRevenue(
        userId: commonuserId,
      );

      if (data != null) {
        setState(() {
          futureTradingRevenue = data;
          checkFutureData = data.allDetails.isEmpty;
        });
        await _updateFutureCurrencyValues();
        print("✅ Future trading revenue data loaded successfully");
        print("   Today's Profit: \$${data.todayProfit.toStringAsFixed(2)}");
        print(
            "   Cumulative Profit: \$${data.cumulativeProfit.toStringAsFixed(2)}");
      } else {
        setState(() {
          checkFutureData = true;
        });
        print("❌ Failed to load future trading revenue data");
      }
    } catch (e) {
      print("❌ Error fetching future trading revenue: $e");
      setState(() {
        checkFutureData = true;
      });
    } finally {
      setState(() {
        isFutureAPIcalled = false;
      });
    }
  }

  Future<void> _updateFutureCurrencyValues() async {
    try {
      if (futureTradingRevenue != null) {
        var totalcurrency = await CommonMethod().getCurrency(0.0);
        setState(() {
          futureTodayincr = futureTradingRevenue!.todayProfit * totalcurrency;
          futureCumulativeincr =
              futureTradingRevenue!.cumulativeProfit * totalcurrency;
        });
      }
    } catch (e) {
      print("Error updating future currency values: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2329),
      appBar: CommonAppBar.basic(
        title: 'revenue_detail'.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _getRevenueData,
          ),
        ],
        tabBar: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF0B90B),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(
              text: 'Spot Trading',
              icon: Icon(
                Icons.trending_up,
                size: 20,
                color: Colors.green,
              ),
            ),
            Tab(
              text: 'Future Trading',
              icon: Icon(
                Icons.show_chart,
                size: 20,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Spot Trading Tab
          RefreshIndicator(
            onRefresh: _getRevenueData,
            child: isAPIcalled
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFF0B90B),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildSpotTradingHeader(),
                        _buildSummaryCard(),
                        _buildTransactionsList(),
                      ],
                    ),
                  ),
          ),

          /// Future Trading Tab
          _buildFutureTradingTab(),
        ],
      ),
    );
  }

  Widget _buildSpotTradingHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2B3139),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF0B90B).withOpacity(0.3)),
      ),
      child: Row(
        children: const [
          Icon(
            Icons.trending_up,
            color: Color(0xFFF0B90B),
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            'Spot Trading Revenue',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFutureTradingTab() {
    return RefreshIndicator(
      onRefresh: _getFutureTradingRevenue,
      child: isFutureAPIcalled
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF0B90B)))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildFutureTradingHeader(),
                  _buildFutureSummaryCard(),
                  _buildFutureTransactionsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildFutureTradingHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B3139),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0B90B).withOpacity(0.3)),
      ),
      child: Row(
        children: const [
          Icon(
            Icons.show_chart,
            color: Color(0xFFF0B90B),
            size: 20,
          ),
          SizedBox(width: 12),
          Text(
            'Future Trading Revenue',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFutureSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B3139),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildFutureProfitSection(
            "Today's Profit",
            futureTradingRevenue?.todayProfit.toStringAsFixed(6) ?? "0.000000",
            futureTodayincr.toStringAsFixed(4),
            Icons.today,
          ),
          Divider(color: Colors.grey.withOpacity(0.2), height: 24),
          _buildFutureProfitSection(
            "Total Profit",
            futureTradingRevenue?.cumulativeProfit.toStringAsFixed(6) ??
                "0.000000",
            futureCumulativeincr.toStringAsFixed(4),
            Icons.account_balance_wallet,
          ),
        ],
      ),
    );
  }

  Widget _buildFutureTransactionsList() {
    if (checkFutureData) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF2B3139),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Future Trading Data',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start future trading to see your revenue here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final allDetails = futureTradingRevenue?.allDetails ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...allDetails
            .take(10)
            .map((detail) => _buildFutureTransactionItem(detail)),
        if (allDetails.length > 10)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Showing latest 10 transactions',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildFutureTransactionItem(FutureTradingRevenueDetail detail) {
    final isProfit = detail.profit >= 0;
    final tradingPair = detail.symbol.toUpperCase();
    final isLong = detail.side.toUpperCase() == 'LONG';

    return InkWell(
      onTap: () {
        // Show detailed view when clicked
        _showFutureTradeDetails(detail);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tradingPair,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Qty: ${detail.quantity.toStringAsFixed(4)}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${detail.profit >= 0 ? '+' : ''}${detail.profit.toStringAsFixed(4)} USDT',
                  style: TextStyle(
                    color: isProfit ? Colors.green : Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isLong
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    detail.side.toUpperCase(),
                    style: TextStyle(
                      color: isLong ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showFutureTradeDetails(FutureTradingRevenueDetail detail) {
    final entryDate = _formatDate(detail.createDate);
    final exitDate =
        detail.closeDate != null ? _formatDate(detail.closeDate!) : 'Open';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF2B3139),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trade Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Symbol and Side
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: detail.side.toUpperCase() == 'LONG'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        detail.side.toUpperCase(),
                        style: TextStyle(
                          color: detail.side.toUpperCase() == 'LONG'
                              ? Colors.green
                              : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      detail.symbol.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Profit/Loss
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2329),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Profit/Loss',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${detail.profit >= 0 ? '+' : ''}${detail.profit.toStringAsFixed(4)} USDT',
                        style: TextStyle(
                          color: detail.profit >= 0 ? Colors.green : Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Trade Details
                _buildDetailRow(
                    'Entry Price', '\$${detail.entryPrice.toStringAsFixed(4)}'),
                _buildDetailRow(
                    'Exit Price', '\$${detail.exitPrice.toStringAsFixed(4)}'),
                _buildDetailRow('Quantity', detail.quantity.toStringAsFixed(4)),
                _buildDetailRow('Entry Date', entryDate),
                _buildDetailRow('Exit Date', exitDate),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B3139),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildProfitSection(
            "Today's Profit",
            today,
            todayincr.toStringAsFixed(4),
            Icons.today,
          ),
          Divider(color: Colors.grey.withOpacity(0.2), height: 24),
          _buildProfitSection(
            "Total Profit",
            cumulative,
            comulativeincr.toStringAsFixed(4),
            Icons.account_balance_wallet,
          ),
        ],
      ),
    );
  }

  Widget _buildProfitSection(
      String title, String amount, String convertedAmount, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0B90B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFF0B90B), size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${double.parse(amount).toStringAsFixed(4)} USDT",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$convertedAmount ${currentCurrency == "null" ? "USD" : currentCurrency}",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFutureProfitSection(
      String title, String usdtAmount, String currencyAmount, IconData icon) {
    final isProfit =
        double.tryParse(usdtAmount) != null && double.parse(usdtAmount) > 0;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isProfit
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isProfit ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$usdtAmount USDT',
                style: TextStyle(
                  color: isProfit ? Colors.green : Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$currencyAmount $currentCurrency',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    if (checkData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/img/logo.png", height: 120),
            const SizedBox(height: 16),
            Text(
              "No transactions yet",
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    Map<String, List<Detail>> groupedTransactions = {};
    for (var item in getRevenueDetail) {
      try {
        final date = item.createdate;
        final formattedDate =
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        if (!groupedTransactions.containsKey(formattedDate)) {
          groupedTransactions[formattedDate] = [];
        }
        groupedTransactions[formattedDate]!.add(item);
      } catch (e) {
        continue;
      }
    }

    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final transactions = groupedTransactions[date]!;

        double totalProfit = 0.0;
        for (var item in transactions) {
          try {
            var profitStr = item.profit;
            if (profitStr.isNotEmpty) {
              double profit =
                  double.tryParse(profitStr.replaceAll(',', '')) ?? 0.0;
              totalProfit += profit;
            }
          } catch (e) {}
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2B3139),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${totalProfit.abs().toStringAsFixed(4)} USDT",
                      style: TextStyle(
                        color: totalProfit >= 0
                            ? const Color(0xFF2EBD85)
                            : const Color(0xFFF6465D),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ...transactions.map((item) {
                try {
                  double profit = 0.0;
                  var profitStr = item.profit;
                  if (profitStr != null && profitStr.isNotEmpty) {
                    profit =
                        double.tryParse(profitStr.replaceAll(',', '')) ?? 0.0;
                  }

                  String tradingPair = item.cryptoPair;
                  if (tradingPair.trim().isEmpty) {
                    tradingPair = "Spot Trading Revenue";
                  }
                  if (item.exchanger.trim().isNotEmpty) {
                    tradingPair += " (${item.exchanger})";
                  }

                  String orderType = item.sellOrBuy;
                  bool isBuyOrder = orderType.toLowerCase() == 'buy';

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RevenueDetailByDate(
                            date: date,
                            today: today,
                            cumulative: cumulative,
                            todaycurrentCurrency: todayincr.toStringAsFixed(4),
                            cumulativecurrentCurrecny:
                                comulativeincr.toStringAsFixed(4),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tradingPair,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.exchanger.isNotEmpty
                                      ? item.exchanger
                                      : "Daily Revenue Balance",
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${profit.abs().toStringAsFixed(4)} USDT",
                                style: TextStyle(
                                  color: profit >= 0
                                      ? const Color(0xFF2EBD85)
                                      : const Color(0xFFF6465D),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (orderType.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isBuyOrder
                                        ? const Color(0xFF2EBD85)
                                            .withOpacity(0.1)
                                        : const Color(0xFFF6465D)
                                            .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    orderType.toUpperCase(),
                                    style: TextStyle(
                                      color: isBuyOrder
                                          ? const Color(0xFF2EBD85)
                                          : const Color(0xFFF6465D),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } catch (e) {
                  print("Error building transaction item: $e");
                  return const SizedBox.shrink();
                }
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}

// CustomPainter class to for the header curved-container
class HeaderCurvedContainer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.white;
    Path path = Path()
      ..relativeLineTo(0, 130)
      ..quadraticBezierTo(size.width / 2, 130.0, size.width, 130)
      ..relativeLineTo(0, -130)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
