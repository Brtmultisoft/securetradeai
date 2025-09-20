import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rapidtradeai/method/methods.dart';
import 'package:rapidtradeai/model/incomeManagementModel.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';
import 'package:rapidtradeai/src/widget/lottie_loading_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widget/common_app_bar.dart';

class BotTradingBonus extends StatefulWidget {
  final int initialTabIndex;
  const BotTradingBonus({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  _BotTradingBonusState createState() => _BotTradingBonusState();
}

class _BotTradingBonusState extends State<BotTradingBonus>
    with SingleTickerProviderStateMixin {
  // Binance theme colors
  final Color backgroundColor = const Color(0xFF1E2329);
  final Color cardColor = const Color(0xFF2B3139);
  final Color primaryColor = TradingTheme.secondaryAccent;
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

  // Bot Trading Bonus Data
  BotTradingBonusModel? botTradingLevelData;
  double botTradingLevelToday = 0.0;
  double botTradingLevelCumulative = 0.0;
  List<BotTradingBonusDetail> botTradingLevelDetails = [];

  BotTradingBonusModel? botTradingDirectData;
  double botTradingDirectToday = 0.0;
  double botTradingDirectCumulative = 0.0;
  List<BotTradingBonusDetail> botTradingDirectDetails = [];

  BotTradingBonusModel? botTradingSalaryData;
  double botTradingSalaryToday = 0.0;
  double botTradingSalaryCumulative = 0.0;
  List<BotTradingBonusDetail> botTradingSalaryDetails = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialTabIndex);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
    _loadData();
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

      // Load all bot trading bonus data
      await Future.wait([
        _loadBotTradingLevelIncome(),
        _loadBotTradingDirectIncome(),
        _loadBotTradingSalaryIncome(),
      ]);
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadBotTradingLevelIncome() async {
    try {
      final res = await CommonMethod().getBotTradingLevelIncome();
      if (res.status == "success") {
        setState(() {
          botTradingLevelData = res;
          botTradingLevelToday = res.data.profitToday != null 
              ? double.tryParse(res.data.profitToday!) ?? 0.0 
              : 0.0;
          botTradingLevelCumulative = res.data.cumulativeProfit;
          botTradingLevelDetails = res.data.details;
        });
      }
    } catch (e) {
      print('Error loading bot trading level income: $e');
    }
  }

  Future<void> _loadBotTradingDirectIncome() async {
    try {
      final res = await CommonMethod().getBotTradingDirectIncome();
      if (res.status == "success") {
        setState(() {
          botTradingDirectData = res;
          botTradingDirectToday = res.data.profitToday != null 
              ? double.tryParse(res.data.profitToday!) ?? 0.0 
              : 0.0;
          botTradingDirectCumulative = res.data.cumulativeProfit;
          botTradingDirectDetails = res.data.details;
        });
      }
    } catch (e) {
      print('Error loading bot trading direct income: $e');
    }
  }

  Future<void> _loadBotTradingSalaryIncome() async {
    try {
      final res = await CommonMethod().getBotTradingSalaryIncome();
      if (res.status == "success") {
        setState(() {
          botTradingSalaryData = res;
          botTradingSalaryToday = res.data.profitToday != null 
              ? double.tryParse(res.data.profitToday!) ?? 0.0 
              : 0.0;
          botTradingSalaryCumulative = res.data.cumulativeProfit;
          botTradingSalaryDetails = res.data.details;
        });
      }
    } catch (e) {
      print('Error loading bot trading salary income: $e');
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
      length: 3,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: CommonAppBar.basic(
          title: 'Bot Trading Bonus',
          tabBar: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor:TradingTheme.secondaryAccent,
            indicatorWeight: 3,
            labelColor: TradingTheme.secondaryAccent,
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
              Tab(
                icon: Icon(Icons.person_add, size: 20),
                text: 'Direct',
              ),
              Tab(
                icon: Icon(Icons.layers, size: 20),
                text: 'Level',
              ),
              Tab(
                icon: Icon(Icons.account_balance_wallet, size: 20),
                text: 'Universal Pool',
              ),
            ],
          ),
        ),
        body: isLoading
            ? const Center(
                child:LottieLoadingWidget.large(),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildDirectIncomeView(),
                  _buildLevelIncomeView(),
                  _buildSalaryIncomeView(),
                ],
              ),
      ),
    );
  }

  Widget _buildDirectIncomeView() {
    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: cardColor,
      onRefresh: _loadBotTradingDirectIncome,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildIncomeOverview(
              'Direct Income',
              botTradingDirectToday,
              botTradingDirectCumulative,
              Icons.person_add,
            ),
            _buildIncomeStats(
              botTradingDirectToday,
              botTradingDirectCumulative,
              botTradingDirectDetails.length,
            ),
            _buildIncomeHistory(botTradingDirectDetails, 'Direct Income'),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelIncomeView() {
    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: cardColor,
      onRefresh: _loadBotTradingLevelIncome,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildIncomeOverview(
              'Level Income',
              botTradingLevelToday,
              botTradingLevelCumulative,
              Icons.layers,
            ),
            _buildIncomeStats(
              botTradingLevelToday,
              botTradingLevelCumulative,
              botTradingLevelDetails.length,
            ),
            _buildIncomeHistory(botTradingLevelDetails, 'Level Income'),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryIncomeView() {
    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: cardColor,
      onRefresh: _loadBotTradingSalaryIncome,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildIncomeOverview(
              'Universal Pool Income',
              botTradingSalaryToday,
              botTradingSalaryCumulative,
              Icons.account_balance_wallet,
            ),
            _buildIncomeStats(
              botTradingSalaryToday,
              botTradingSalaryCumulative,
              botTradingSalaryDetails.length,
            ),
            _buildIncomeHistory(botTradingSalaryDetails, 'Universal Pool Income'),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeOverview(String title, double todayIncome, double totalIncome, IconData icon) {
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
                  color: TradingTheme.secondaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: TradingTheme.secondaryAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: TradingTheme.secondaryAccent,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(totalIncome * totalCurrency).toStringAsFixed(2)} $currentCurrency',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (todayIncome > 0)
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_upward,
                            color: successColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(todayIncome * totalCurrency).toStringAsFixed(2)} $currentCurrency Today',
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

  Widget _buildIncomeStats(double todayIncome, double totalIncome, int recordCount) {
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
            'Total Records',
            recordCount.toDouble(),
            Icons.receipt_long,
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
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title == 'Total Records'
                  ? amount.toInt().toString()
                  : '${amount.toStringAsFixed(2)} $currentCurrency',
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

  Widget _buildIncomeHistory(List<BotTradingBonusDetail> details, String incomeType) {
    if (details.isEmpty) {
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
            'No $incomeType records found',
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
            '$incomeType History',
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
          itemCount: details.length,
          itemBuilder: (context, index) {
            final detail = details[index];
            final amount = double.tryParse(detail.totalbal) ?? 0.0;

            // Parse the date string
            DateTime? date;
            try {
              date = DateTime.parse(detail.createdDate);
            } catch (e) {
              date = DateTime.now();
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      incomeType,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '+${(amount * totalCurrency).toStringAsFixed(2)} $currentCurrency',
                      style: TextStyle(
                        color: successColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('MMM dd, yyyy HH:mm').format(date),
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14,
                    ),
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
