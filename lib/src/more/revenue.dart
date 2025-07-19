import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Service/assets_service.dart';
import 'revenueDetailBydate.dart';
import '../../method/methods.dart';
import '../../model/revenueModel.dart';

class Revenue extends StatefulWidget {
  @override
  State<Revenue> createState() => _RevenueState();
}

class _RevenueState extends State<Revenue> {
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
      final data = await CommonMethod().getRevenueDetail();
      print("API Response Status: ${data.status}");
      if (data.status == "success" && data.data != null) {
        var a = data.data.cumulativeProfit;
        var b = data.data.profitToday;
        print("Cumulative Profit from API: $a");
        print("Today's Profit from API: $b");
        
        setState(() {
          today = b != 0 ? b.toStringAsFixed(6) : "0.000000";
          cumulative = a != 0 ? a.toStringAsFixed(6) : "0.000000";
          if (data.data.details != null) {
            List<Detail> details = [];
            for (var detail in data.data.details) {
              try {
                print("Raw Detail Data: ${json.encode(detail.toJson())}");
                // Get the totalbal value instead of profit
                var rawBalance = detail.totalbal;
                print("Raw Balance Value: $rawBalance");
                
                double balanceValue = 0.0;
                if (rawBalance != null) {
                  try {
                    String balanceStr = rawBalance.toString().trim();
                    if (balanceStr.isNotEmpty) {
                      balanceValue = double.tryParse(balanceStr.replaceAll(',', '')) ?? 0.0;
                    }
                  } catch (e) {
                    print("Error parsing balance value: $e");
                  }
                }
                print("Parsed Balance Value: $balanceValue");

                details.add(Detail(
                  id: detail.id,
                  cryptoPair: detail.cryptoPair,
                  profit: balanceValue.toStringAsFixed(6), // Use balance as profit
                  sellOrBuy: detail.sellOrBuy,
                  exchanger: detail.exchanger,
                  createdate: detail.createdate,
                  totalbal: detail.totalbal ,
                ));
              } catch (e) {
                print("Error creating Detail object: $e");
                continue;
              }
            }
            getRevenueDetail = details;
            getRevenueDetail.sort((a, b) => b.createdate.compareTo(a.createdate));
            
            // Debug print the first few records
            print("First few records after processing:");
            for (var i = 0; i < min(3, getRevenueDetail.length); i++) {
              print("Record $i: Profit = ${getRevenueDetail[i].profit}, Date = ${getRevenueDetail[i].createdate}");
            }
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
    _loadCurrentCurrency();
    _getRevenueData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E2329),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E2329),
        title: Text(
          'revenue_detail'.tr,
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _getRevenueData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _getRevenueData,
        child: isAPIcalled
            ? Center(child: CircularProgressIndicator(color: Color(0xFFF0B90B)))
            : SingleChildScrollView(
                child: Column(
          children: [
                    _buildSummaryCard(),
                    _buildTransactionsList(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2B3139),
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

  Widget _buildProfitSection(String title, String amount, String convertedAmount, IconData icon) {
    return Row(
              children: [
        Container(
          padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
            color: Color(0xFFF0B90B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Color(0xFFF0B90B), size: 24),
        ),
        SizedBox(width: 12),
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
              SizedBox(height: 4),
                                              Text(
                "$amount USDT",
                                                style: TextStyle(
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
            SizedBox(height: 16),
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
        final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        if (!groupedTransactions.containsKey(formattedDate)) {
          groupedTransactions[formattedDate] = [];
        }
        groupedTransactions[formattedDate]!.add(item);
      } catch (e) {
        print("Error processing transaction date: $e");
        continue;
      }
    }

    final sortedDates = groupedTransactions.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
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
              double profit = double.tryParse(profitStr.replaceAll(',', '')) ?? 0.0;
              totalProfit += profit;
            }
          } catch (e) {
            print("Error parsing profit: $e");
          }
        }
        print("Total profit for date $date: $totalProfit");

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xFF2B3139),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
            child: Column(
                    children: [
                      Container(
                padding: EdgeInsets.all(16),
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${totalProfit.abs().toStringAsFixed(6)} USDT",
                                style: TextStyle(
                        color: totalProfit >= 0 ? Color(0xFF2EBD85) : Color(0xFFF6465D),
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
                    profit = double.tryParse(profitStr.replaceAll(',', '')) ?? 0.0;
                  }
                  
                  String tradingPair = item.cryptoPair;
                  if (tradingPair.trim().isEmpty) {
                    tradingPair = "Unknown";
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
                            cumulativecurrentCurrecny: comulativeincr.toStringAsFixed(4),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                    children: [
                          Expanded(
                            child: Text(
                              tradingPair,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${profit.abs().toStringAsFixed(6)} USDT",
                                style: TextStyle(
                                  color: profit >= 0 ? Color(0xFF2EBD85) : Color(0xFFF6465D),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (orderType.isNotEmpty) ...[
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isBuyOrder
                                      ? Color(0xFF2EBD85).withOpacity(0.1)
                                      : Color(0xFFF6465D).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    orderType.toUpperCase(),
                                    style: TextStyle(
                                      color: isBuyOrder
                                        ? Color(0xFF2EBD85) 
                                        : Color(0xFFF6465D),
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
                  return SizedBox.shrink();
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
