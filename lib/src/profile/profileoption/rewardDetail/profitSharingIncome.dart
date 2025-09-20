import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';

class ProfitSharingIncome extends StatefulWidget {
  const ProfitSharingIncome({Key? key}) : super(key: key);

  @override
  _ProfitSharingIncomeState createState() => _ProfitSharingIncomeState();
}

class _ProfitSharingIncomeState extends State<ProfitSharingIncome> {
  // Binance theme colors
  final Color backgroundColor = Color(0xFF1E2329);
  final Color cardColor = Color(0xFF2B3139);
  final Color primaryColor = TradingTheme.secondaryAccent;
  final Color successColor = Color(0xFF2EBD85);
  final Color dangerColor = Color(0xFFF6465D);
  final Color textColor = Colors.white;
  final Color secondaryTextColor = Color(0xFF848E9C);
  final Color borderColor = Color(0xFF373C3F);

  bool isLoading = false;
  Map<String, dynamic> profitData = {};
  List<Map<String, dynamic>> profitHistory = [];

  @override
  void initState() {
    super.initState();
    _loadProfitData();
  }

  Future<void> _loadProfitData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        profitData = {
          'totalProfit': 12345.67,
          'todayProfit': 234.56,
          'thisMonth': 3456.78,
          'lastMonth': 4567.89,
          'profitChange': 2.5,
        };

        profitHistory = [
          {
            'date': DateTime.now().subtract(Duration(days: 1)),
            'amount': 234.56,
            'type': 'Trading Profit',
            'status': 'Completed',
            'change': 2.5
          },
          {
            'date': DateTime.now().subtract(Duration(days: 2)),
            'amount': 189.32,
            'type': 'Team Profit',
            'status': 'Completed',
            'change': 1.8
          },
          // Add more sample data
        ];
      });
    } catch (e) {
      print('Error loading profit data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Profit Sharing',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: _loadProfitData,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primaryColor,
        backgroundColor: cardColor,
        onRefresh: _loadProfitData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildProfitOverview(),
              _buildProfitStats(),
              _buildProfitHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfitOverview() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.attach_money,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Profit',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${profitData['totalProfit']?.toStringAsFixed(2) ?? '0.00'} USDT',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_upward,
                          color: successColor,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '+${profitData['profitChange']?.toStringAsFixed(1) ?? '0.0'}% Today',
                          style: TextStyle(
                            color: successColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfitStats() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard(
            'Today\'s Profit',
            profitData['todayProfit']?.toStringAsFixed(2) ?? '0.00',
            Icons.today,
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'This Month',
            profitData['thisMonth']?.toStringAsFixed(2) ?? '0.00',
            Icons.calendar_today,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String amount, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: primaryColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '$amount USDT',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitHistory() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      );
    }

    if (profitHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: secondaryTextColor,
            ),
            SizedBox(height: 16),
            Text(
              'No profit history yet',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Profit History',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: profitHistory.length,
          itemBuilder: (context, index) {
            final profit = profitHistory[index];
            final bool isPositiveChange = profit['change'] > 0;

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      profit['type'],
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${profit['amount'].toStringAsFixed(2)} USDT',
                      style: TextStyle(
                        color: successColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMM dd, yyyy HH:mm').format(profit['date']),
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            isPositiveChange
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: isPositiveChange ? successColor : dangerColor,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${isPositiveChange ? '+' : ''}${profit['change']}%',
                            style: TextStyle(
                              color: isPositiveChange ? successColor : dangerColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
