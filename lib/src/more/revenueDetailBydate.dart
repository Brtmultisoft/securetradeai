import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/src/Service/assets_service.dart';

import '../../Data/Api.dart';
import '../../method/methods.dart';

class RevenueDetailByDate extends StatefulWidget {
  const RevenueDetailByDate(
      {Key? key,
      this.date,
      this.today,
      this.cumulative,
      this.todaycurrentCurrency,
      this.cumulativecurrentCurrecny})
      : super(key: key);
  final date;
  final today;
  final cumulative;
  final todaycurrentCurrency;
  final cumulativecurrentCurrecny;
  @override
  _RevenueDetailByDateState createState() => _RevenueDetailByDateState();
}

class _RevenueDetailByDateState extends State<RevenueDetailByDate> {
  var getRevenueDetail = [];
  var assets;
  List temp = [];
  bool checkData = false;
  var finaldata = [];
  _getRevenueData() async {
    try {
      print("🔄 Loading revenue details for date: ${widget.date}");
      print(
          "🌐 API ENDPOINT: https://securetradeai.com/myrest/user/revenue_bydate");
      print(
          "📤 API REQUEST: POST with body: {\"user_id\": \"user_id\", \"date\": \"${widget.date}\"}");

      final data = await CommonMethod().getRevenueDetailByDate(widget.date);
      print("📊 Revenue Details API Response Status: ${data.status}");
      print("📊 Revenue Details API Response Message: ${data.message}");

      if (data.status == "success") {
        if (mounted) {
          setState(() {
            getRevenueDetail.addAll(data.data.details);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            checkData = true;
          });
        }
        showtoast(data.message, context);
      }
    } catch (e) {
      print(e);
    }
  }

  _getAssets() async {
    final res = await http.get(Uri.parse(cryptoassets));
    var response = jsonDecode(res.body);
    if (mounted) {
      setState(() {
        assets = response['data'];
      });
      _commonMethod();
    }
  }

  _commonMethod() {
    for (var e in assets) {
      if (checkData) {
        print('no data');
      } else {
        for (var element in getRevenueDetail) {
          // print(getRevenueDetail);
          if (element.cryptoPair == e['assets']) {
            if (mounted) {
              setState(() {
                finaldata.add({
                  'id': int.parse(element.id),
                  'orderno': element.originalOrderid,
                  'image': e['assets_img'],
                  'cryptopair': element.cryptoPair,
                  'exchange': element.exchanger,
                  'profit': element.profit,
                  'createtype': element.createdate,
                });
              });
            }
          }
        }
      }
    }
    if (mounted) {
      setState(() {
        finaldata.sort((a, b) => a["id"].compareTo(b["id"]));
        finaldata.sort((a, b) => b["id"].compareTo(a["id"]));
        // print(finaldata);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getRevenueData();
    _getAssets();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height * 0.50;
    return Scaffold(
      backgroundColor:
          const Color(0xFF0C0E12), // TradingTheme.primaryBackground
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF161A1E), // TradingTheme.secondaryBackground
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF0B90B), Color(0xFFE6A500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.receipt_long, color: Colors.black, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'DETAILS',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Revenue - ${widget.date}",
                style: const TextStyle(
                  color: Color(0xFFEAECEF), // TradingTheme.primaryText
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFFEAECEF), // TradingTheme.primaryText
          ),
        ),
      ),
      body: Column(
        children: [
          topHeader(widget.today, widget.cumulative),
          Expanded(
              child: getRevenueDetail.isEmpty
                  ? Center(
                      child:
                          CircularProgressIndicator(color: securetradeaicolor),
                    )
                  :
                  // dummyBuilder()
                  ListView.builder(
                      itemCount: finaldata.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, i) {
                        final item = finaldata[i];
                        final profitStr = item['profit']?.toString() ?? '';
                        final profit = double.tryParse(profitStr) ?? 0.0;
                        final isProfit = profit >= 0;

                        return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1E2026), Color(0xFF12151C)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF2A3A5A),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header Row
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: const Color(0xFFF0B90B),
                                            width: 2,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          child: Image.network(
                                            item['image'] ?? '',
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                color: const Color(0xFF2B3139),
                                                child: const Icon(
                                                  Icons.currency_bitcoin,
                                                  color: Color(0xFFF0B90B),
                                                  size: 20,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['cryptopair'] ??
                                                  'Unknown Pair',
                                              style: const TextStyle(
                                                color: Color(0xFFEAECEF),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Order #${item['orderno'] ?? 'N/A'}",
                                              style: const TextStyle(
                                                color: Color(0xFF848E9C),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isProfit
                                              ? const Color(0xFF0ECB81)
                                                  .withOpacity(0.1)
                                              : const Color(0xFFEA4335)
                                                  .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isProfit
                                              ? '+${profit.toStringAsFixed(4)}'
                                              : profit.toStringAsFixed(4),
                                          style: TextStyle(
                                            color: isProfit
                                                ? const Color(0xFF0ECB81)
                                                : const Color(0xFFEA4335),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Details Section
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Sell Currency",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          finaldata[i]['cryptopair'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Exchange",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          finaldata[i]['exchange'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Profit",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: () {
                                                  final profitStr = finaldata[i]
                                                              ['profit']
                                                          ?.toString() ??
                                                      '';
                                                  final profit =
                                                      double.tryParse(
                                                              profitStr) ??
                                                          0.0;
                                                  return profit
                                                      .toStringAsFixed(4);
                                                }(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const TextSpan(
                                                  text: ' USDT',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white70)),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Time",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          finaldata[i]['createtype'].toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ));
                      }))
        ],
      ),
    );
  }

  Widget dummyBuilder() {
    return ListView.builder(
        itemCount: temp.length,
        itemBuilder: (context, index) {
          return ListTile(
            trailing: Image.network(
              temp[index]['img'],
              height: 19,
            ),
            title: Text(
              temp[index]['name'],
              style: TextStyle(color: Colors.white),
            ),
          );
        });
  }

  Widget topHeader(String today, comulative) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E2026), Color(0xFF12151C)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3A5A), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0B90B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Color(0xFFF0B90B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Daily Revenue Summary',
                style: TextStyle(
                  color: Color(0xFFEAECEF),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Today's Profit",
                  "≈\$${double.parse(today).toStringAsFixed(4)}",
                  Icons.today,
                  const Color(0xFF0ECB81),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  "Total Profit",
                  "≈\$${double.parse(comulative).toStringAsFixed(4)}",
                  Icons.account_balance_wallet,
                  const Color(0xFF4A90E2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B3139),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF848E9C),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
