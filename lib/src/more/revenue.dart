import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../method/methods.dart';
import '../../model/revenueModel.dart';
import '../Service/assets_service.dart';
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
    setState(() {
      isAPIcalled = true;
      getRevenueDetail = [];
    });
    try {
      print("🔄 Starting to fetch revenue data...");
      print(
          "🌐 API ENDPOINT: https://securetradeai.com/myrest/user/revenue_details");
      print("📤 API REQUEST: POST with body: {\"user_id\": \"$commonuserId\"}");

      final data = await CommonMethod().getRevenueDetail();
      print("📊 API Response Status: ${data.status}");
      print("📊 API Response Message: ${data.message}");
      print("📊 API Response Code: ${data.responsecode}");

      if (data.status == "success" && data.data != null) {
        var a = data.data.cumulativeProfit;
        var b = data.data.profitToday;

        setState(() {
          today = b != 0 ? b.toStringAsFixed(6) : "0.000000";
          cumulative = a != 0 ? a.toStringAsFixed(6) : "0.000000";
          if (data.data.details != null) {
            List<Detail> details = [];
            print(
                "🔍 Processing ${data.data.details.length} transaction details...");

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
                  } catch (e) {
                    print("Error parsing balance value: $e");
                  }
                }
                print("Parsed Balance Value: $balanceValue");

                details.add(Detail(
                  id: detail.id,
                  cryptoPair: detail.cryptoPair,
                  profit:
                      balanceValue.toStringAsFixed(6), // Use balance as profit
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
        setState(() {
          checkData = true;
        });
        showtoast(data.message, context);
      }
    } catch (e) {
      print("Error fetching revenue data: $e");
      setState(() {
        checkData = true;
      });
      showtoast("Failed to load revenue data", context);
    } finally {
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
    } catch (e) {
      print("Error updating currency values: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCurrentCurrency();
    _getRevenueData();
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
          tabs: [
            const Tab(
              text: 'Spot Trading',
              icon: Icon(Icons.trending_up, size: 20),
            ),
            const Tab(
              text: 'Future Trading',
              icon: Icon(Icons.show_chart, size: 20),
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
                    child: CircularProgressIndicator(color: Color(0xFFF0B90B)))
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
          // Future Trading Tab
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
        children: [
          const Icon(
            Icons.trending_up,
            color: Color(0xFFF0B90B),
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
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
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Future Trading Revenue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Coming Soon',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Future trading revenue tracking will be available soon. Stay tuned for updates!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
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
        print("Error processing transaction date: $e");
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
            if (profitStr != null && profitStr.isNotEmpty) {
              print("Processing profit value: $profitStr for date: $date");
              double profit =
                  double.tryParse(profitStr.replaceAll(',', '')) ?? 0.0;
              totalProfit += profit;
            }
          } catch (e) {
            print("Error parsing profit: $e");
          }
        }
        print("Total profit for date $date: $totalProfit");

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
                    print("Processing individual profit: $profitStr");
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
