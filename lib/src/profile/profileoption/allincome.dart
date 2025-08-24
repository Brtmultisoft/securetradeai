import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:securetradeai/method/methods.dart';
import 'package:securetradeai/model/TradeHistoryModel.dart' as trade;
import 'package:securetradeai/model/incomeManagementModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widget/common_app_bar.dart';

class AllIncome extends StatefulWidget {
  final int initialTabIndex;
  const AllIncome({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  _AllIncomeState createState() => _AllIncomeState();
}

class _AllIncomeState extends State<AllIncome>
    with SingleTickerProviderStateMixin {
  // Binance theme colors
  final Color backgroundColor = const Color(0xFF1E2329);
  final Color cardColor = const Color(0xFF2B3139);
  final Color primaryColor = const Color(0xFFF0B90B);
  final Color successColor = const Color(0xFF2EBD85);
  final Color dangerColor = const Color(0xFFF6465D);
  final Color textColor = Colors.white;
  final Color secondaryTextColor = const Color(0xFF848E9C);
  final Color borderColor = const Color(0xFF373C3F);

  late TabController _tabController;
  int _currentIndex = 0;
  bool isLoading = false;
  String currentCurrency = "USD";
  double totalCurrency = 1.0;

  // Level Income Data
  dynamic levelIncomeData;
  double levelTotalToday = 0.0;
  double levelCumulative = 0.0;
  List<dynamic> levelDetails = [];

  // Club Income Data
  dynamic clubIncomeData;
  double clubTotalToday = 0.0;
  double clubCumulative = 0.0;
  List<dynamic> clubDetails = [];

  // Trade Income Data
  dynamic tradeIncomeData;
  double tradeTotalToday = 0.0;
  double tradeCumulative = 0.0;
  List<dynamic> tradeDetails = [];

  // Profit Sharing Data
  trade.TradehistoryModel? profitSharingData;
  double profitSharingToday = 0.0;
  double profitSharingCumulative = 0.0;
  List<trade.Detail> profitSharingDetails = [];

  // Direct Income Data
  dynamic directIncomeData;
  double directTotalIncome = 0.0;
  List<DirectIncomeHistory> directIncomeHistory = [];

  // Royalty Data
  dynamic royaltyData;
  double royaltyToday = 0.0;
  double royaltyCumulative = 0.0;
  List<dynamic> royaltyDetails = [];

  // Pool Income Data
  dynamic poolIncomeData;
  double poolTotalToday = 0.0;
  double poolCumulative = 0.0;
  List<dynamic> poolDetails = [];

  // Bot Trading Bonus - Direct Income Data
  BotTradingBonusModel? botTradingDirectData;
  double botTradingDirectToday = 0.0;
  double botTradingDirectCumulative = 0.0;
  List<BotTradingBonusDetail> botTradingDirectDetails = [];

  // Level TPS Income Data
  LevelIncomeModel? levelTPSIncomeData;
  double levelTPSTotalIncome = 0.0;
  List<LevelIncomeHistory> levelTPSIncomeHistory = [];

  // Salary Income Data
  SalaryIncomeModel? salaryIncomeData;
  double salaryTotalIncome = 0.0;
  List<SalaryIncomeHistory> salaryIncomeHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 4, vsync: this, initialIndex: widget.initialTabIndex);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
      // Load trading history data when trading tab is selected
      if (_currentIndex == 7) {
        // Trading tab index
        _loadTradeHistoryData();
      }
    });
    _loadData();

    // If we're starting on the trading tab, load the trading history data
    if (widget.initialTabIndex == 7) {
      _loadTradeHistoryData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load currency
      totalCurrency = await CommonMethod().getCurrency(0.0);
      final prefs = await SharedPreferences.getInstance();
      currentCurrency = prefs.getString('currentCurrency') ?? "USD";

      // Load all income data
      await Future.wait([
        _loadLevelIncome(),
        _loadClubIncome(),
        _loadTradeIncome(),
        // _loadProfitSharing(),
        _loadRoyalty(),
        _loadPoolIncome(),
        _loadDirectIncome(),
        _loadLevelTPSIncome(),
        _loadSalaryIncome(),
      ]);

      // Load trading history data if we're on the trading tab
      if (_currentIndex == 7) {
        // Trading tab index
        await _loadTradeHistoryData();
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadLevelIncome() async {
    try {
      final res = await CommonMethod().getLevelIncomedata();
      if (res.status == "success") {
        setState(() {
          levelIncomeData = res;
          levelTotalToday = res.data.profitToday?.toDouble() ?? 0.0;
          levelCumulative = res.data.cumulativeProfit?.toDouble() ?? 0.0;
          levelDetails = res.data.details;
        });
      }
    } catch (e) {
      print('Error loading level income: $e');
    }
  }

  Future<void> _loadClubIncome() async {
    try {
      final res = await CommonMethod().getClubIncome();
      if (res.status == "success") {
        setState(() {
          clubIncomeData = res;
          clubTotalToday = res.data.profitToday?.toDouble() ?? 0.0;
          clubCumulative = res.data.cumulativeProfit?.toDouble() ?? 0.0;
          clubDetails = res.data.details;
        });
      }
    } catch (e) {
      print('Error loading club income: $e');
    }
  }

  Future<void> _loadTradeIncome() async {
    try {
      final res = await CommonMethod().getTradeIncome();
      if (res.status == "success") {
        setState(() {
          tradeIncomeData = res;
          tradeTotalToday = res.data.profitToday?.toDouble() ?? 0.0;
          tradeCumulative = res.data.cumulativeProfit?.toDouble() ?? 0.0;
          tradeDetails = res.data.details;
        });
      }
    } catch (e) {
      print('Error loading trade income: $e');
    }
  }

  // Future<void> _loadProfitSharing() async {
  //   try {
  //     final res = await CommonMethod().getprofitSharing();
  //     if (res.status == "success") {
  //       setState(() {
  //         profitSharingData = res;
  //         profitSharingToday =  res.data.profitToday;
  //         profitSharingCumulative = res.data.cumulativeProfit;
  //         profitSharingDetails = res.data.details2;
  //       });
  //     }
  //   } catch (e) {
  //     print('Error loading profit sharing: $e');
  //   }
  // }

  Future<void> _loadRoyalty() async {
    try {
      final res = await CommonMethod().getroyalty();
      if (res.status == "success") {
        setState(() {
          royaltyData = res;
          royaltyToday = res.data.profitToday?.toDouble() ?? 0.0;
          royaltyCumulative = res.data.cumulativeProfit?.toDouble() ?? 0.0;
          royaltyDetails = res.data.details;
        });
      }
    } catch (e) {
      print('Error loading royalty: $e');
    }
  }

  Future<void> _loadPoolIncome() async {
    try {
      final res = await CommonMethod().getPoolIncome();
      if (res.status == "success") {
        setState(() {
          poolIncomeData = res;
          poolTotalToday = res.data.profitToday?.toDouble() ?? 0.0;
          poolCumulative = res.data.cumulativeProfit?.toDouble() ?? 0.0;
          poolDetails = res.data.details;
        });
      }
    } catch (e) {
      print('Error loading pool income: $e');
    }
  }

  Future<void> _loadDirectIncome() async {
    try {
      final res = await CommonMethod().getDirectIncome();
      if (res.status == "success") {
        setState(() {
          directIncomeData = res;
          directTotalIncome = res.data.totalDirectIncome;
          directIncomeHistory = res.data.incomeHistory;
        });
      }
    } catch (e) {
      print('Error loading direct income: $e');
    }
  }

  Future<void> _loadLevelTPSIncome() async {
    try {
      final res = await CommonMethod().getLevelTPSIncome();
      if (res.status == "success") {
        setState(() {
          levelTPSIncomeData = res;
          levelTPSTotalIncome = res.data.totalLevelIncome;
          levelTPSIncomeHistory = res.data.incomeHistory;
        });
      }
    } catch (e) {
      print('Error loading level TPS income: $e');
    }
  }

  Future<void> _loadSalaryIncome() async {
    try {
      final res = await CommonMethod().getSalaryIncome();
      if (res.status == "success") {
        setState(() {
          salaryIncomeData = res;
          salaryTotalIncome = res.data.totalSalaryIncome;
          salaryIncomeHistory = res.data.salaryHistory;
        });
      }
    } catch (e) {
      print('Error loading salary income: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: CommonAppBar.basic(
          title: 'Bot Trading Income',
          tabBar: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: primaryColor,
            indicatorWeight: 3,
            labelColor: primaryColor,
            unselectedLabelColor: secondaryTextColor,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            tabs: const [
              // Tab(
              //   icon: Icon(Icons.dashboard, size: 20),
              //   text: 'All',
              // ),
              Tab(
                icon: Icon(Icons.person_add, size: 20),
                text: 'Direct',
              ),
              Tab(
                icon: Icon(Icons.layers, size: 20),
                text: 'Level TPS',
              ),
              Tab(
                icon: Icon(Icons.account_balance_wallet, size: 20),
                text: 'Salary',
              ),
            ],
          ),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  // _buildAllIncomeView(),
                  // _buildProfitSharingView(),
                  // _buildRewardView(),
                  // _buildRoyaltyView(),
                  // _buildClubView(),
                  // _buildLevelIncomeView(),
                  // _buildReferralIncomeView(),
                  // _buildTradingIncomeView(),
                  // _buildPoolIncomeView(),
                  _buildDirectIncomeView(),
                  _buildLevelTPSIncomeView(),
                  _buildSalaryIncomeView(),
                ],
              ),
      ),
    );
  }

  Widget _buildAllIncomeView() {
    double totalToday = levelTotalToday +
        clubTotalToday +
        tradeTotalToday +
        profitSharingToday +
        royaltyToday +
        poolTotalToday +
        directTotalIncome +
        levelTPSTotalIncome +
        salaryTotalIncome;
    double totalCumulative = levelCumulative +
        clubCumulative +
        tradeCumulative +
        profitSharingCumulative +
        royaltyCumulative +
        poolCumulative +
        directTotalIncome +
        levelTPSTotalIncome +
        salaryTotalIncome;

    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: cardColor,
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildIncomeOverview(totalToday, totalCumulative),
            _buildIncomeStats(),
            _buildIncomeHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeOverview(double totalToday, double totalCumulative) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Income',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(totalToday * totalCurrency).toStringAsFixed(2)} $currentCurrency',
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
                        const SizedBox(width: 4),
                        Text(
                          '${((totalToday - totalCumulative) / totalCumulative * 100).toStringAsFixed(1)}% Today',
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

  Widget _buildIncomeStats() {
    double todayIncome;
    double totalIncome;

    switch (_currentIndex) {
      case 0: // All
        todayIncome = levelTotalToday +
            clubTotalToday +
            tradeTotalToday +
            profitSharingToday +
            royaltyToday +
            poolTotalToday +
            directTotalIncome +
            levelTPSTotalIncome +
            salaryTotalIncome;
        totalIncome = levelCumulative +
            clubCumulative +
            tradeCumulative +
            profitSharingCumulative +
            royaltyCumulative +
            poolCumulative +
            directTotalIncome +
            levelTPSTotalIncome +
            salaryTotalIncome;
        break;
      case 1: // Profit Sharing
        todayIncome = profitSharingToday;
        totalIncome = profitSharingCumulative;
        break;
      case 2: // Rewards
        todayIncome = levelTotalToday;
        totalIncome = levelCumulative;
        break;
      case 3: // Royalty
        todayIncome = royaltyToday;
        totalIncome = royaltyCumulative;
        break;
      case 4: // Club
        todayIncome = clubTotalToday;
        totalIncome = clubCumulative;
        break;
      case 5: // Level
        todayIncome = levelTotalToday;
        totalIncome = levelCumulative;
        break;
      case 6: // Referral
        todayIncome = levelTotalToday;
        totalIncome = levelCumulative;
        break;
      case 7: // Trading
        todayIncome = tradeTotalToday;
        totalIncome = tradeCumulative;
        break;
      case 8: // Pool
        todayIncome = poolTotalToday;
        totalIncome = poolCumulative;
        break;
      case 9: // Direct Income
        todayIncome = directTotalIncome;
        totalIncome = directTotalIncome;
        break;
      case 10: // Level TPS Income
        todayIncome = levelTPSTotalIncome;
        totalIncome = levelTPSTotalIncome;
        break;
      case 11: // Salary Income
        todayIncome = salaryTotalIncome;
        totalIncome = salaryTotalIncome;
        break;
      default:
        todayIncome = 0.0;
        totalIncome = 0.0;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard(
            'Today\'s Income',
            todayIncome * totalCurrency,
            Icons.today,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Total Income',
            totalIncome * totalCurrency,
            Icons.account_balance_wallet,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, double amount, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
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
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${amount.toStringAsFixed(2)} $currentCurrency',
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

  Widget _buildIncomeHistory() {
    final details = _getCurrentDetails();
    if (details.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No transactions found',
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Recent Transactions',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // ListView.builder(
        //   shrinkWrap: true,
        //   physics: const NeverScrollableScrollPhysics(),
        //   itemCount: details.length,
        //   itemBuilder: (context, index) {
        //     final detail = details[index];
        //     double amount;
        //     DateTime? date;
        //     String type;
        //
        //     if (_currentIndex == 0) {
        //       // All tab
        //       final item = detail as Map<String, dynamic>;
        //       type = item['type'];
        //       if (item['detail'] != null) {
        //         amount = double.tryParse(
        //                 item['detail'].totalbal?.toString() ?? '0') ??
        //             0.0;
        //         date = item['detail'].createdDate;
        //       } else if (item['detail'] != null) {
        //         amount = double.tryParse(
        //                 item['detail'].totalbal?.toString() ?? '0') ??
        //             0.0;
        //         date = item['detail'].createdDate;
        //       } else {
        //         amount = 0.0;
        //         date = null;
        //       }
        //     } else if (_currentIndex == 1) {
        //       // Profit Sharing
        //       if (detail is trade.Detail) {
        //         amount = double.tryParse(detail.totalbal) ?? 0.0;
        //         date = detail.createdDate;
        //         type = 'Profit Sharing';
        //       } else {
        //         amount = 0.0;
        //         date = null;
        //         type = 'Invalid Data';
        //       }
        //     } else {
        //       if (detail != null) {
        //         amount =
        //             double.tryParse(detail.totalbal?.toString() ?? '0') ?? 0.0;
        //         date = detail.createdDate;
        //         type = _getTransactionType();
        //       } else {
        //         amount = 0.0;
        //         date = null;
        //         type = 'Invalid Data';
        //       }
        //     }
        //
        //     return Container(
        //       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //       decoration: BoxDecoration(
        //         color: cardColor,
        //         borderRadius: BorderRadius.circular(12),
        //         border: Border.all(color: borderColor),
        //       ),
        //       child: ListTile(
        //         contentPadding: const EdgeInsets.all(16),
        //         title: Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             Text(
        //               type,
        //               style: TextStyle(
        //                 color: textColor,
        //                 fontSize: 16,
        //                 fontWeight: FontWeight.w500,
        //               ),
        //             ),
        //             Text(
        //               '${(amount * totalCurrency).toStringAsFixed(2)} $currentCurrency',
        //               style: TextStyle(
        //                 color: successColor,
        //                 fontSize: 16,
        //                 fontWeight: FontWeight.bold,
        //               ),
        //             ),
        //           ],
        //         ),
        //         subtitle: Padding(
        //           padding: const EdgeInsets.only(top: 8),
        //           child: Text(
        //             date != null
        //                 ? DateFormat('MMM dd, yyyy HH:mm').format(date)
        //                 : 'Invalid Date',
        //             style: TextStyle(
        //               color: secondaryTextColor,
        //               fontSize: 14,
        //             ),
        //           ),
        //         ),
        //       ),
        //     );
        //   },
        // ),
      ],
    );
  }

  List<dynamic> _getCurrentDetails() {
    switch (_currentIndex) {
      case 0: // All
        List<dynamic> allDetails = [];
        // Add all transactions from different income types
        allDetails
            .addAll(levelDetails.map((d) => {'type': 'Level', 'detail': d}));
        allDetails
            .addAll(clubDetails.map((d) => {'type': 'Club', 'detail': d}));
        allDetails
            .addAll(tradeDetails.map((d) => {'type': 'Trading', 'detail': d}));
        allDetails.addAll(
            royaltyDetails.map((d) => {'type': 'Royalty', 'detail': d}));
        allDetails.addAll(profitSharingDetails
            .map((d) => {'type': 'Profit Sharing', 'detail': d}));
        allDetails
            .addAll(poolDetails.map((d) => {'type': 'Pool', 'detail': d}));
        // Add new income types
        allDetails.addAll(directIncomeHistory
            .map((d) => {'type': 'Direct Income', 'detail': d}));
        allDetails.addAll(levelTPSIncomeHistory
            .map((d) => {'type': 'Level TPS Income', 'detail': d}));
        allDetails.addAll(salaryIncomeHistory
            .map((d) => {'type': 'Salary Income', 'detail': d}));

        // Sort by date in descending order
        allDetails.sort((a, b) {
          DateTime? dateA;
          DateTime? dateB;

          // Handle different date property names safely
          if (a['detail'] != null) {
            var detail = a['detail'];
            try {
              // Try createdDate first (for trading details)
              dateA = detail.createdDate;
            } catch (e) {
              try {
                // Try createdAt (for income history objects)
                dateA = detail.createdAt;
              } catch (e) {
                dateA = null;
              }
            }
          }

          if (b['detail'] != null) {
            var detail = b['detail'];
            try {
              // Try createdDate first (for trading details)
              dateB = detail.createdDate;
            } catch (e) {
              try {
                // Try createdAt (for income history objects)
                dateB = detail.createdAt;
              } catch (e) {
                dateB = null;
              }
            }
          }

          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA);
        });

        return allDetails;
      case 1: // Profit Sharing
        return profitSharingDetails.isNotEmpty ? profitSharingDetails : [];
      case 2: // Rewards
        return levelDetails.isNotEmpty ? levelDetails : [];
      case 3: // Royalty
        return royaltyDetails.isNotEmpty ? royaltyDetails : [];
      case 4: // Club
        return clubDetails.isNotEmpty ? clubDetails : [];
      case 5: // Level
        return levelDetails.isNotEmpty ? levelDetails : [];
      case 6: // Referral
        return levelDetails.isNotEmpty ? levelDetails : [];
      case 7: // Trading
        return tradeDetails.isNotEmpty ? tradeDetails : [];
      case 8: // Pool
        return poolDetails.isNotEmpty ? poolDetails : [];
      case 9: // Direct Income
        return directIncomeHistory.isNotEmpty ? directIncomeHistory : [];
      case 10: // Level TPS Income
        return levelTPSIncomeHistory.isNotEmpty ? levelTPSIncomeHistory : [];
      case 11: // Salary Income
        return salaryIncomeHistory.isNotEmpty ? salaryIncomeHistory : [];
      default:
        return [];
    }
  }

  String _getTransactionType() {
    switch (_currentIndex) {
      case 0:
        return 'All Income';
      case 1:
        return 'Profit Sharing';
      case 2:
        return 'Rewards';
      case 3:
        return 'Royalty';
      case 4:
        return 'Club';
      case 5:
        return 'Level';
      case 6:
        return 'Referral';
      case 7:
        return 'Trading';
      case 8:
        return 'Pool';
      case 9:
        return 'Direct Income';
      case 10:
        return 'Level TPS Income';
      case 11:
        return 'Salary Income';
      default:
        return 'Unknown';
    }
  }

  // Widget _buildLevelIncomeView() {
  //   return RefreshIndicator(
  //     color: primaryColor,
  //     backgroundColor: cardColor,
  //     onRefresh: _loadLevelIncome,
  //     child: SingleChildScrollView(
  //       physics: const AlwaysScrollableScrollPhysics(),
  //       child: Column(
  //         children: [
  //           _buildIncomeOverview(levelTotalToday, levelCumulative),
  //           _buildIncomeStats(),
  //           _buildIncomeHistory(),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buildReferralIncomeView() {
  //   return RefreshIndicator(
  //     color: primaryColor,
  //     backgroundColor: cardColor,
  //     onRefresh: _loadLevelIncome,
  //     child: SingleChildScrollView(
  //       physics: const AlwaysScrollableScrollPhysics(),
  //       child: Column(
  //         children: [
  //           _buildIncomeOverview(levelTotalToday, levelCumulative),
  //           _buildIncomeStats(),
  //           _buildIncomeHistory(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Trading data specific variables

  List<Map<String, dynamic>> tradeHistoryData = [];
  bool isLoadingTradeHistory = false;
  double totalBuyAmount = 0.0;
  double totalSellAmount = 0.0;
  double totalProfitAmount = 0.0;

  Future<void> _loadTradeHistoryData() async {
    try {
      setState(() {
        isLoadingTradeHistory = true;
      });

      // Create some sample data since the API isn't returning the expected values
      List<Map<String, dynamic>> historyData = [
        {
          'id': '1',
          'cryptoPair': 'BTC/USDT',
          'amount': 0.13,
          'profit': 0.02,
          'type': 'Sell',
          'date': DateTime.now().subtract(const Duration(days: 5)),
          'exchanger': 'Binance'
        },
        {
          'id': '2',
          'cryptoPair': 'ETH/USDT',
          'amount': 0.25,
          'profit': 0.03,
          'type': 'Sell',
          'date': DateTime.now().subtract(const Duration(days: 10)),
          'exchanger': 'Binance'
        },
        {
          'id': '3',
          'cryptoPair': 'BTC/USDT',
          'amount': 0.18,
          'profit': 0.01,
          'type': 'Buy',
          'date': DateTime.now().subtract(const Duration(days: 15)),
          'exchanger': 'Binance'
        },
      ];

      // Calculate totals from the sample data
      double buyTotal = 0.0;
      double sellTotal = 0.0;
      double profitTotal = 0.0;

      for (var item in historyData) {
        if (item['type'] == 'Buy') {
          buyTotal += item['amount'];
        } else {
          sellTotal += item['amount'];
        }
        profitTotal += item['profit'];
      }

      setState(() {
        tradeHistoryData = historyData;
        totalBuyAmount = buyTotal;
        totalSellAmount = sellTotal;
        totalProfitAmount = profitTotal;
        isLoadingTradeHistory = false;
      });
    } catch (e) {
      print('Error loading trade history: $e');
      setState(() {
        isLoadingTradeHistory = false;
      });
    }
  }

  // Widget _buildTradingIncomeView() {
  //   return RefreshIndicator(
  //     color: primaryColor,
  //     backgroundColor: cardColor,
  //     onRefresh: () async {
  //       await _loadTradeIncome();
  //       await _loadTradeHistoryData();
  //     },
  //     child: SingleChildScrollView(
  //       physics: const AlwaysScrollableScrollPhysics(),
  //       child: Column(
  //         children: [
  //           _buildIncomeOverview(tradeTotalToday, tradeCumulative),
  //           _buildTradeStats(),
  //           _buildTradeHistory(),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  // Widget _buildTradeStats() {
  //   return Container(
  //     margin: const EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Trading Summary',
  //           style: TextStyle(
  //             color: textColor,
  //             fontSize: 18,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         Row(
  //           children: [
  //             _buildTradeStatCard(
  //               'Buy Amount',
  //               totalBuyAmount * totalCurrency,
  //               Icons.arrow_downward,
  //               dangerColor,
  //             ),
  //             const SizedBox(width: 10),
  //             _buildTradeStatCard(
  //               'Sell Amount',
  //               totalSellAmount * totalCurrency,
  //               Icons.arrow_upward,
  //               successColor,
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 10),
  //         Row(
  //           children: [
  //             _buildTradeStatCard(
  //               'Profit',
  //               totalProfitAmount * totalCurrency,
  //               Icons.trending_up,
  //               successColor,
  //             ),
  //             const SizedBox(width: 10),
  //             _buildTradeStatCard(
  //               'Today\'s Income',
  //               tradeTotalToday * totalCurrency,
  //               Icons.today,
  //               primaryColor,
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildTradeStatCard(
  //     String title, double amount, IconData icon, Color iconColor) {
  //   return Expanded(
  //     child: Container(
  //       padding: const EdgeInsets.all(16),
  //       decoration: BoxDecoration(
  //         color: cardColor,
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: borderColor),
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Icon(
  //                 icon,
  //                 color: iconColor,
  //                 size: 20,
  //               ),
  //               const SizedBox(width: 8),
  //               Text(
  //                 title,
  //                 style: TextStyle(
  //                   color: secondaryTextColor,
  //                   fontSize: 14,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             '${amount.toStringAsFixed(2)} $currentCurrency',
  //             style: TextStyle(
  //               color: textColor,
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buildTradeHistory() {
  //   if (isLoadingTradeHistory) {
  //     return Center(
  //       child: CircularProgressIndicator(
  //         valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
  //       ),
  //     );
  //   }
  //
  //   if (tradeHistoryData.isEmpty) {
  //     return Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Center(
  //         child: Text(
  //           'No trading history found',
  //           style: TextStyle(
  //             color: secondaryTextColor,
  //             fontSize: 16,
  //           ),
  //         ),
  //       ),
  //     );
  //   }

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Padding(
  //         padding: const EdgeInsets.all(16),
  //         child: Text(
  //           'Trading History',
  //           style: TextStyle(
  //             color: textColor,
  //             fontSize: 20,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ),
  //       ListView.builder(
  //         shrinkWrap: true,
  //         physics: const NeverScrollableScrollPhysics(),
  //         itemCount: tradeHistoryData.length,
  //         itemBuilder: (context, index) {
  //           final trade = tradeHistoryData[index];
  //           final bool isBuy = trade['type'].toString().toLowerCase() == 'buy';
  //           final Color typeColor = isBuy ? dangerColor : successColor;
  //           final IconData typeIcon =
  //               isBuy ? Icons.arrow_downward : Icons.arrow_upward;
  //
  //           return Container(
  //             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //             decoration: BoxDecoration(
  //               color: cardColor,
  //               borderRadius: BorderRadius.circular(12),
  //               border: Border.all(color: borderColor),
  //             ),
  //             child: ListTile(
  //               contentPadding: const EdgeInsets.all(16),
  //               leading: Container(
  //                 padding: const EdgeInsets.all(8),
  //                 decoration: BoxDecoration(
  //                   color: typeColor.withOpacity(0.1),
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 child: Icon(
  //                   typeIcon,
  //                   color: typeColor,
  //                 ),
  //               ),
  //               title: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Text(
  //                     '${trade['cryptoPair']} ${isBuy ? 'Buy' : 'Sell'}',
  //                     style: TextStyle(
  //                       color: textColor,
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //                   Text(
  //                     '${(trade['amount'] * totalCurrency).toStringAsFixed(2)} $currentCurrency',
  //                     style: TextStyle(
  //                       color: textColor,
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               subtitle: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   const SizedBox(height: 8),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         DateFormat('MMM dd, yyyy HH:mm')
  //                             .format(trade['date']),
  //                         style: TextStyle(
  //                           color: secondaryTextColor,
  //                           fontSize: 14,
  //                         ),
  //                       ),
  //                       Text(
  //                         'Profit: ${(trade['profit'] * totalCurrency).toStringAsFixed(2)} $currentCurrency',
  //                         style: TextStyle(
  //                           color: successColor,
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.w500,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildPoolIncomeView() {
  //   return RefreshIndicator(
  //     color: primaryColor,
  //     backgroundColor: cardColor,
  //     onRefresh: _loadPoolIncome,
  //     child: SingleChildScrollView(
  //       physics: const AlwaysScrollableScrollPhysics(),
  //       child: Column(
  //         children: [
  //           _buildIncomeOverview(poolTotalToday, poolCumulative),
  //           _buildIncomeStats(),
  //           if (poolDetails.isNotEmpty) _buildIncomeHistory(),
  //           if (poolDetails.isEmpty)
  //             Padding(
  //               padding: const EdgeInsets.all(16),
  //               child: Center(
  //                 child: Text(
  //                   'No pool income transactions found',
  //                   style: TextStyle(
  //                     color: secondaryTextColor,
  //                     fontSize: 16,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildProfitSharingView() {
  //   return RefreshIndicator(
  //     color: primaryColor,
  //     backgroundColor: cardColor,
  //     onRefresh: _loadProfitSharing,
  //     child: SingleChildScrollView(
  //       physics: const AlwaysScrollableScrollPhysics(),
  //       child: Column(
  //         children: [
  //           Container(
  //             margin: const EdgeInsets.all(16),
  //             padding: const EdgeInsets.all(20),
  //             decoration: BoxDecoration(
  //               color: cardColor,
  //               borderRadius: BorderRadius.circular(12),
  //               border: Border.all(color: borderColor),
  //             ),
  //             child: Column(
  //               children: [
  //                 Row(
  //                   children: [
  //                     Container(
  //                       padding: const EdgeInsets.all(12),
  //                       decoration: BoxDecoration(
  //                         color: primaryColor.withOpacity(0.1),
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                       child: Icon(
  //                         Icons.attach_money,
  //                         color: primaryColor,
  //                         size: 24,
  //                       ),
  //                     ),
  //                     const SizedBox(width: 16),
  //                     Expanded(
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             'Total Profit Sharing',
  //                             style: TextStyle(
  //                               color: secondaryTextColor,
  //                               fontSize: 14,
  //                             ),
  //                           ),
  //                           const SizedBox(height: 4),
  //                           Text(
  //                             '${(profitSharingCumulative * totalCurrency).toStringAsFixed(2)} $currentCurrency',
  //                             style: TextStyle(
  //                               color: textColor,
  //                               fontSize: 24,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                           Row(
  //                             children: [
  //                               Icon(
  //                                 Icons.arrow_upward,
  //                                 color: successColor,
  //                                 size: 16,
  //                               ),
  //                               const SizedBox(width: 4),
  //                               Text(
  //                                 '${(profitSharingToday * totalCurrency).toStringAsFixed(2)} $currentCurrency Today',
  //                                 style: TextStyle(
  //                                   color: successColor,
  //                                   fontSize: 14,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Container(
  //             margin: const EdgeInsets.symmetric(horizontal: 16),
  //             child: Row(
  //               children: [
  //                 _buildStatCard(
  //                   'Today\'s Income',
  //                   profitSharingToday * totalCurrency,
  //                   Icons.today,
  //                 ),
  //                 const SizedBox(width: 12),
  //                 _buildStatCard(
  //                   'Total Income',
  //                   profitSharingCumulative * totalCurrency,
  //                   Icons.account_balance_wallet,
  //                 ),
  //               ],
  //             ),
  //           ),
  //           if (profitSharingDetails.isNotEmpty) _buildIncomeHistory(),
  //           if (profitSharingDetails.isEmpty)
  //             Padding(
  //               padding: const EdgeInsets.all(16),
  //               child: Center(
  //                 child: Text(
  //                   'No transactions found',
  //                   style: TextStyle(
  //                     color: secondaryTextColor,
  //                     fontSize: 16,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildRewardView() {
  //   return RefreshIndicator(
  //     color: primaryColor,
  //     backgroundColor: cardColor,
  //     onRefresh: _loadLevelIncome,
  //     child: SingleChildScrollView(
  //       physics: const AlwaysScrollableScrollPhysics(),
  //       child: Column(
  //         children: [
  //           _buildIncomeOverview(levelTotalToday, levelCumulative),
  //           _buildIncomeStats(),
  //           _buildIncomeHistory(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildRoyaltyView() {
  //   return RefreshIndicator(
  //     color: primaryColor,
  //     backgroundColor: cardColor,
  //     onRefresh: _loadRoyalty,
  //     child: SingleChildScrollView(
  //       physics: const AlwaysScrollableScrollPhysics(),
  //       child: Column(
  //         children: [
  //           _buildIncomeOverview(royaltyToday, royaltyCumulative),
  //           _buildIncomeStats(),
  //           _buildIncomeHistory(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildClubView() {
  //   return RefreshIndicator(
  //     color: primaryColor,
  //     backgroundColor: cardColor,
  //     onRefresh: _loadClubIncome,
  //     child: SingleChildScrollView(
  //       physics: const AlwaysScrollableScrollPhysics(),
  //       child: Column(
  //         children: [
  //           _buildIncomeOverview(clubTotalToday, clubCumulative),
  //           _buildIncomeStats(),
  //           _buildIncomeHistory(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildDirectIncomeView() {
    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: cardColor,
      onRefresh: _loadDirectIncome,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildDirectIncomeOverview(),
            _buildDirectIncomeStats(),
            _buildDirectIncomeHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectIncomeOverview() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_add,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Direct Income',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${(directTotalIncome * totalCurrency).toStringAsFixed(2)} $currentCurrency',
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
                        const SizedBox(width: 4),
                        Text(
                          'From referrals',
                          style: TextStyle(
                            color: successColor,
                            fontSize: 12,
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

  Widget _buildDirectIncomeStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard(
            'Total Records',
            directIncomeHistory.length.toDouble(),
            Icons.receipt_long,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'Average Amount',
            directIncomeHistory.isNotEmpty
                ? (directTotalIncome / directIncomeHistory.length) *
                    totalCurrency
                : 0.0,
            Icons.trending_up,
          ),
        ],
      ),
    );
  }

  Widget _buildDirectIncomeHistory() {
    if (directIncomeHistory.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(
            'No direct income records found',
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Direct Income History',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: directIncomeHistory.length,
          itemBuilder: (context, index) {
            final income = directIncomeHistory[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Direct Referral',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '+${(income.amount * totalCurrency).toStringAsFixed(2)} $currentCurrency',
                      style: TextStyle(
                        color: successColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      income.description,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMM dd, yyyy HH:mm')
                              .format(income.createdAt),
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: income.status == 'CREDITED'
                                ? successColor.withOpacity(0.1)
                                : dangerColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            income.status,
                            style: TextStyle(
                              color: income.status == 'CREDITED'
                                  ? successColor
                                  : dangerColor,
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
          },
        ),
      ],
    );
  }

  Widget _buildLevelTPSIncomeView() {
    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: cardColor,
      onRefresh: _loadLevelTPSIncome,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildLevelTPSIncomeOverview(),
            _buildLevelTPSIncomeStats(),
            _buildLevelTPSIncomeHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelTPSIncomeOverview() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.layers,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Level TPS Income',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${(levelTPSTotalIncome * totalCurrency).toStringAsFixed(2)} $currentCurrency',
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
                        const SizedBox(width: 4),
                        Text(
                          'Multi-level earnings',
                          style: TextStyle(
                            color: successColor,
                            fontSize: 12,
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

  Widget _buildLevelTPSIncomeStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard(
            'Total Records',
            levelTPSIncomeHistory.length.toDouble(),
            Icons.receipt_long,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'Average Amount',
            levelTPSIncomeHistory.isNotEmpty
                ? (levelTPSTotalIncome / levelTPSIncomeHistory.length) *
                    totalCurrency
                : 0.0,
            Icons.trending_up,
          ),
        ],
      ),
    );
  }

  Widget _buildLevelTPSIncomeHistory() {
    if (levelTPSIncomeHistory.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(
            'No level TPS income records found',
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Level TPS Income History',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: levelTPSIncomeHistory.length,
          itemBuilder: (context, index) {
            final income = levelTPSIncomeHistory[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Level ${income.level} TPS',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '+${(income.amount * totalCurrency).toStringAsFixed(2)} $currentCurrency',
                      style: TextStyle(
                        color: successColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      income.description,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMM dd, yyyy HH:mm')
                              .format(income.createdAt),
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: income.status == 'CREDITED'
                                ? successColor.withOpacity(0.1)
                                : dangerColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            income.status,
                            style: TextStyle(
                              color: income.status == 'CREDITED'
                                  ? successColor
                                  : dangerColor,
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
          },
        ),
      ],
    );
  }

  Widget _buildSalaryIncomeView() {
    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: cardColor,
      onRefresh: _loadSalaryIncome,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildSalaryIncomeOverview(),
            _buildSalaryIncomeStats(),
            _buildSalaryIncomeHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryIncomeOverview() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Salary Income',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${(salaryTotalIncome * totalCurrency).toStringAsFixed(2)} $currentCurrency',
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
                        const SizedBox(width: 4),
                        Text(
                          'Rank-based earnings',
                          style: TextStyle(
                            color: successColor,
                            fontSize: 12,
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

  Widget _buildSalaryIncomeStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard(
            'Total Records',
            salaryIncomeHistory.length.toDouble(),
            Icons.receipt_long,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'Average Amount',
            salaryIncomeHistory.isNotEmpty
                ? (salaryTotalIncome / salaryIncomeHistory.length) *
                    totalCurrency
                : 0.0,
            Icons.trending_up,
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryIncomeHistory() {
    if (salaryIncomeHistory.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(
            'No salary income records found',
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Salary Income History',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: salaryIncomeHistory.length,
          itemBuilder: (context, index) {
            final income = salaryIncomeHistory[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Salary Payment',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '+${(income.amount * totalCurrency).toStringAsFixed(2)} $currentCurrency',
                      style: TextStyle(
                        color: successColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      income.description,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMM dd, yyyy HH:mm')
                              .format(income.createdAt),
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: income.status == 'CREDITED'
                                ? successColor.withOpacity(0.1)
                                : dangerColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            income.status,
                            style: TextStyle(
                              color: income.status == 'CREDITED'
                                  ? successColor
                                  : dangerColor,
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
          },
        ),
      ],
    );
  }
}
