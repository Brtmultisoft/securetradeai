import 'package:flutter/material.dart';
import 'package:rapidtradeai/method/methods.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';
import 'package:intl/intl.dart';

class RewardDetail extends StatefulWidget {
  const RewardDetail({
    Key? key,
  }) : super(key: key);
  @override
  _RewardDetailState createState() => _RewardDetailState();
}

class _RewardDetailState extends State<RewardDetail> {
  // Binance theme colors
  final Color backgroundColor = Color(0xFF1E2329);
  final Color cardColor = Color(0xFF2B3139);
  final Color primaryColor = TradingTheme.secondaryAccent;
  final Color successColor = Color(0xFF2EBD85);
  final Color dangerColor = Color(0xFFF6465D);
  final Color textColor = Colors.white;
  final Color secondaryTextColor = Color(0xFF848E9C);
  final Color borderColor = Color(0xFF373C3F);

  var levelDtail = [];
  var data;
  bool isAPIcalled = false;
  bool checkdata = false;
  double levelIncomeComulativeCr = 0.0;
  double leveltotalProfitTodayCr = 0.0;
  bool isLoading = false;
  Map<String, dynamic> rewardData = {};
  List<Map<String, dynamic>> rewardHistory = [];

  Future _getlevelIncome() async {
    try {
      setState(() {
        isAPIcalled = true;
      });
      final res = await CommonMethod().getLevelIncomedata();
      if (res.status == "success") {
        levelDtail.addAll(res.data.details.reversed.toList());
        checkdata = levelDtail.isEmpty ? true : false;
        setState(() {
          data = res.data;
          isAPIcalled = false;
        });
      } else {
        showtoast(res.message, context);
      }
    } catch (e) {
      print(e);
      setState(() {
        isAPIcalled = false;
      });
    }
  }

  getCurrency() async {
    var totalcurrency = await CommonMethod().getCurrency(0.0);
    if (mounted) {
      setState(() {
        levelIncomeComulativeCr =
            data.profitToday == null ? 0.0 : data.profitToday * totalcurrency;
        leveltotalProfitTodayCr = data.cumulativeProfit == null
            ? 0.0
            : data.cumulativeProfit * totalcurrency;
      });
    }
  }

  _getAlldata() async {
    await _getlevelIncome();
    // await getCurrency();
  }

  @override
  void initState() {
    super.initState();
    _getAlldata();
    _loadRewardData();
  }

  Future<void> _loadRewardData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        rewardData = {
          'totalRewards': 3456.78,
          'todayRewards': 123.45,
          'thisMonth': 2345.67,
          'lastMonth': 3456.78,
          'rewardChange': 2.5,
        };

        rewardHistory = [
          {
            'date': DateTime.now().subtract(Duration(days: 1)),
            'amount': 123.45,
            'type': 'Trading Reward',
            'status': 'Completed',
            'change': 2.5
          },
          {
            'date': DateTime.now().subtract(Duration(days: 2)),
            'amount': 98.76,
            'type': 'Referral Reward',
            'status': 'Completed',
            'change': 1.8
          },
          // Add more sample data
        ];
      });
    } catch (e) {
      print('Error loading reward data: $e');
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
          'Reward Details',
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
            onPressed: _loadRewardData,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primaryColor,
        backgroundColor: cardColor,
        onRefresh: _loadRewardData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildRewardOverview(),
              _buildRewardStats(),
              _buildRewardHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardOverview() {
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
                  Icons.card_giftcard,
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
                      'Total Rewards',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${rewardData['totalRewards']?.toStringAsFixed(2) ?? '0.00'} USDT',
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
                          '+${rewardData['rewardChange']?.toStringAsFixed(1) ?? '0.0'}% Today',
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

  Widget _buildRewardStats() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard(
            'Today\'s Rewards',
            rewardData['todayRewards']?.toStringAsFixed(2) ?? '0.00',
            Icons.today,
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'This Month',
            rewardData['thisMonth']?.toStringAsFixed(2) ?? '0.00',
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

  Widget _buildRewardHistory() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      );
    }

    if (rewardHistory.isEmpty) {
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
              'No reward history yet',
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
            'Reward History',
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
          itemCount: rewardHistory.length,
          itemBuilder: (context, index) {
            final reward = rewardHistory[index];
            final bool isPositiveChange = reward['change'] > 0;

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
                      reward['type'],
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${reward['amount'].toStringAsFixed(2)} USDT',
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
                        DateFormat('MMM dd, yyyy HH:mm').format(reward['date']),
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
                            '${isPositiveChange ? '+' : ''}${reward['change']}%',
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
