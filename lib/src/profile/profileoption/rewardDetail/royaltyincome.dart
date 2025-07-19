import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RoyaltyIncome extends StatefulWidget {
  const RoyaltyIncome({Key? key}) : super(key: key);

  @override
  _RoyaltyIncomeState createState() => _RoyaltyIncomeState();
}

class _RoyaltyIncomeState extends State<RoyaltyIncome> {
  // Binance theme colors
  final Color backgroundColor = Color(0xFF1E2329);
  final Color cardColor = Color(0xFF2B3139);
  final Color primaryColor = Color(0xFFF0B90B);
  final Color successColor = Color(0xFF2EBD85);
  final Color dangerColor = Color(0xFFF6465D);
  final Color textColor = Colors.white;
  final Color secondaryTextColor = Color(0xFF848E9C);
  final Color borderColor = Color(0xFF373C3F);

  bool isLoading = false;
  Map<String, dynamic> royaltyData = {};
  List<Map<String, dynamic>> royaltyHistory = [];

  @override
  void initState() {
    super.initState();
    _loadRoyaltyData();
  }

  Future<void> _loadRoyaltyData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        royaltyData = {
          'totalRoyalty': 5678.90,
          'todayRoyalty': 123.45,
          'thisMonth': 2345.67,
          'lastMonth': 3456.78,
          'royaltyChange': 1.8,
        };

        royaltyHistory = [
          {
            'date': DateTime.now().subtract(Duration(days: 1)),
            'amount': 123.45,
            'type': 'Level 1 Royalty',
            'status': 'Completed',
            'change': 1.8
          },
          {
            'date': DateTime.now().subtract(Duration(days: 2)),
            'amount': 98.76,
            'type': 'Level 2 Royalty',
            'status': 'Completed',
            'change': 1.2
          },
          // Add more sample data
        ];
      });
    } catch (e) {
      print('Error loading royalty data: $e');
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
          'Royalty Income',
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
            onPressed: _loadRoyaltyData,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primaryColor,
        backgroundColor: cardColor,
        onRefresh: _loadRoyaltyData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildRoyaltyOverview(),
              _buildRoyaltyStats(),
              _buildRoyaltyHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoyaltyOverview() {
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
                  Icons.workspace_premium,
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
                      'Total Royalty',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${royaltyData['totalRoyalty']?.toStringAsFixed(2) ?? '0.00'} USDT',
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
                          '+${royaltyData['royaltyChange']?.toStringAsFixed(1) ?? '0.0'}% Today',
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

  Widget _buildRoyaltyStats() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard(
            'Today\'s Royalty',
            royaltyData['todayRoyalty']?.toStringAsFixed(2) ?? '0.00',
            Icons.today,
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'This Month',
            royaltyData['thisMonth']?.toStringAsFixed(2) ?? '0.00',
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

  Widget _buildRoyaltyHistory() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      );
    }

    if (royaltyHistory.isEmpty) {
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
              'No royalty history yet',
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
            'Royalty History',
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
          itemCount: royaltyHistory.length,
          itemBuilder: (context, index) {
            final royalty = royaltyHistory[index];
            final bool isPositiveChange = royalty['change'] > 0;

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
                      royalty['type'],
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${royalty['amount'].toStringAsFixed(2)} USDT',
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
                        DateFormat('MMM dd, yyyy HH:mm').format(royalty['date']),
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
                            '${isPositiveChange ? '+' : ''}${royalty['change']}%',
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
