import 'dart:io';
import 'dart:math';

import 'package:cross_file/cross_file.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/method/methods.dart';
import 'package:securetradeai/model/dailyRoiHistoryModel.dart';
import 'package:securetradeai/model/incomeManagementModel.dart';
import 'package:securetradeai/model/incomeSummaryModel.dart';
import 'package:securetradeai/model/userInvestmentsModel.dart';
import 'package:securetradeai/model/userRankModel.dart';
import 'package:securetradeai/src/profile/profileoption/Arbitrade/income_details.dart';
import 'package:securetradeai/src/widget/animated_toast.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';
import 'package:securetradeai/src/widget/trading_animations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

class ArbiTradeSection extends StatefulWidget {
  const ArbiTradeSection({Key? key}) : super(key: key);

  @override
  State<ArbiTradeSection> createState() => _ArbiTradeSectionState();
}

class _ArbiTradeSectionState extends State<ArbiTradeSection>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = false;
  double gasBalance = 0.0;
  double bonusBalance = 0.0;
  double totalBalance = 0.0;

  // Investment form data
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  // Income data
  double dailyTPS = 0.0;
  double directIncome = 0.0;
  double levelIncome = 0.0;
  double businessIncome = 0.0;
  double totalTPSIncome = 0.0;
  double totalDirectTPSIncome = 0.0;
  double totalBusinessIncome = 0.0;
  double investmentAmount = 0.0;
  // List<Map<String, dynamic>> myInvestments = [];
  // List<Map<String, dynamic>> incomeHistory = [];

  // New API data
  UserInvestmentsModel? userInvestmentsData;
  List<ArbitrageInvestment> arbitrageInvestments = [];
  InvestmentSummary? investmentSummary;

  // User rank data
  UserRankModel? userRankData;

  // Income summary data
  IncomeSummaryModel? incomeSummaryData;

  // TPS history data for chart
  DailyRoiHistoryModel? roiHistoryData;

  // New Income Management Data
  DirectIncomeModel? directIncomeData;
  double directTotalIncome = 0.0;
  List<DirectIncomeHistory> directIncomeHistory = [];

  LevelIncomeModel? levelTPSIncomeData;
  double levelTPSTotalIncome = 0.0;
  List<LevelIncomeHistory> levelTPSIncomeHistory = [];

  SalaryIncomeModel? salaryIncomeData;
  double salaryTotalIncome = 0.0;
  List<SalaryIncomeHistory> salaryIncomeHistory = [];
  Color binanceYellow = const Color(0xFFF0B90B);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Load investment data first
      await _loadInvestmentData();

      // Load income management data using only the 6 specific APIs
      await Future.wait<void>([
        _loadDirectIncome(),
        _loadLevelTPSIncome(),
        _loadSalaryIncome(),
        _loadUserRank(),
        _loadIncomeSummary(),
        _loadTPSHistory(),
      ]);

      // Calculate totals from the loaded data instead of mine API
      _calculateTotalsFromLoadedData();
    } catch (e) {
      print('Error loading data: $e');
      _showErrorToast('Failed to load data. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Calculate totals from loaded data instead of using mine API for reports only
  void _calculateTotalsFromLoadedData() async {
    // Load gas wallet data separately to maintain gas wallet functionality
    try {
      final userData = await CommonMethod().getMineData();
      if (userData.status == "success" && userData.data.isNotEmpty) {
        final userInfo = userData.data[0];
        setState(() {
          // Keep gas wallet values intact
          gasBalance = double.tryParse(userInfo.balance) ?? 0.0;
          bonusBalance = double.tryParse(userInfo.incomeBalance) ?? 0.0;
          totalBalance = gasBalance + bonusBalance;
        });
      }
    } catch (e) {
      print('Error loading gas wallet data: $e');
    }

    setState(() {
      // Only calculate TPS income from the income summary API for reports
      totalTPSIncome = _getTotalTPSFromIncomeSummary();

      // Set these to 0 since we're not using mine API for report calculations
      totalDirectTPSIncome = 0.0;
      totalBusinessIncome = 0.0;
    });
  }

  Future<void> _loadInvestmentData() async {
    try {
      print('🔄 Loading investment data for user: $commonuserId');

      final data = await CommonMethod().getUserInvestmentsNew();

      print('📤 Investment API Request: getUserInvestmentsNew()');
      print('📥 Response: ${data.status}');

      if (data.status == 'success') {
        setState(() {
          userInvestmentsData = data;
          arbitrageInvestments = data.data.arbitrageInvestments;
          investmentSummary = data.data.summary;
        });

        print('✅ Found ${arbitrageInvestments.length} arbitrage investments');
        return; // Success, exit early
      }

      // If API fails, set empty data
      print('⚠️ Investment API failed, setting empty data');
      setState(() {
        userInvestmentsData = null;
        arbitrageInvestments = [];
        investmentSummary = null;
      });
    } catch (e) {
      print('❌ Exception loading investment data: $e');
      setState(() {
        userInvestmentsData = null;
        arbitrageInvestments = [];
        investmentSummary = null;
      });
    }
  }

  void _showErrorToast(String message) {
    AnimatedToast.show(
      context: context,
      title: "Error",
      message: message,
      status: "error",
    );
  }

  void _showSuccessToast(String message) {
    AnimatedToast.show(
      context: context,
      title: "Success",
      message: message,
      status: "success",
    );
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

  Future<void> _loadTPSHistory() async {
    try {
      // Get the first active investment ID for TPS history
      final investmentsRes = await CommonMethod().getUserInvestmentsNew();
      if (investmentsRes.status == "success" &&
          investmentsRes.data.arbitrageInvestments.isNotEmpty) {
        final firstInvestment = investmentsRes.data.arbitrageInvestments.first;
        final roiRes = await CommonMethod().getDailyRoiHistory(
          investmentId: firstInvestment.id,
          limit: 30, // Get last 30 days for chart
        );

        if (roiRes.status == "success") {
          setState(() {
            roiHistoryData = roiRes;
          });
        }
      }
    } catch (e) {
      print('Error loading TPS history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      appBar: CommonAppBar.analytics(
        title: 'Arbitrade Trading',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF0B90B),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // User Rank Banner
                  if (userRankData != null) _buildUserRankBanner(),
                  // Balance Card
                  _buildBalanceCard(),

                  Container(
                    margin: const EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                      left: 15,
                      right: 15,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          binanceYellow.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: binanceYellow.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                binanceYellow,
                                binanceYellow.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: binanceYellow.withOpacity(0.3),
                                spreadRadius: 0,
                                blurRadius: 4,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          " User Rank",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (userRankData != null) _buildRankBanner(),
                  // Tab Bar
                  Container(
                    color: const Color(0xFF161A1E),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFFF0B90B),
                      unselectedLabelColor: const Color(0xFF848E9C),
                      indicatorColor: const Color(0xFFF0B90B),
                      tabs: const [
                        Tab(text: 'Investment'),
                        Tab(text: 'My Investments'),
                        Tab(text: 'Income'),
                        Tab(text: 'Reports'),
                      ],
                    ),
                  ),
                  // Tab Content with fixed height
                  SizedBox(
                    height: 600, // Fixed height for TabBarView
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildInvestmentTab(),
                        _buildMyInvestmentsTab(),
                        _buildIncomeTab(),
                        _buildReportsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0ECB81).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF0ECB81).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Gas Wallet',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${gasBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Earning Balance',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${incomeSummaryData!.data.totalIncome.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.yellow,
          ),
          // Income Breakdown Section
          if (incomeSummaryData != null) ...[
            _buildIncomeBreakdownGrid(),
          ],
        ],
      ),
    );
  }

  Widget _buildIncomeBreakdownGrid() {
    if (incomeSummaryData == null) return const SizedBox.shrink();

    final breakdown = incomeSummaryData!.data.incomeBreakdown;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 15),
      child: Column(
        children: [
          // First row: Daily TPS and Direct Referral
          Row(
            children: [
              Expanded(
                child: _buildIncomeItem(
                  'Daily TPS',
                  breakdown.dailyRoi,
                  Icons.trending_up,
                  const Color(0xFF0ECB81),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _buildIncomeItem(
                  'Direct Referral',
                  breakdown.directReferral,
                  Icons.person_add,
                  const Color(0xFF4A90E2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Second row: Level TPS and Gas Fee
          Row(
            children: [
              Expanded(
                child: _buildIncomeItem(
                  'Level TPS',
                  breakdown.levelRoi,
                  Icons.layers,
                  const Color(0xFFF0B90B),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _buildIncomeItem(
                  'Salary',
                  breakdown.salary,
                  Icons.account_balance_wallet,
                  const Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeItem(
      String label, double amount, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        // Navigate to appropriate income details page based on label
        String incomeType;
        String title;

        switch (label) {
          case 'Daily TPS':
            incomeType = 'roi';
            title = 'Daily TPS Income';
            break;
          case 'Direct Referral':
            incomeType = 'direct_income';
            title = 'Direct Referral Income';
            break;
          case 'Level TPS':
            incomeType = 'level_income';
            title = 'Level TPS Income';
            break;
          case 'Salary':
            incomeType = 'salary_income';
            title = 'Salary Income';
            break;
          default:
            incomeType = 'roi';
            title = '$label Income';
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IncomeDetailsPage(
              incomeType: incomeType,
              title: title,
              color: color,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2026),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2A2D35), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: color,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF848E9C),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: amount > 0 ? color : const Color(0xFF848E9C),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Add a subtle arrow icon to indicate it's clickable
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF848E9C),
              size: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRankBanner() {
    if (userRankData == null) return const SizedBox.shrink();

    final rankData = userRankData!.data;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0B90B), // Golden yellow
            Color(0xFFFFD700), // Bright gold
            Color(0xFFF0B90B), // Golden yellow
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF0B90B).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Investment Stats Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.account_balance_wallet,
                      color: Colors.black,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Arbitrage Summary',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Expanded(
                    //   child: _buildInvestmentStat(
                    //     'Total \nInvestment',
                    //     '\$${(investmentSummary?.totalInvestment ?? 0.0).toStringAsFixed(0)}',
                    //     Icons.trending_up,
                    //     Colors.green,
                    //   ),
                    // ),
                    // const SizedBox(width: 12),
                    Expanded(
                      child: _buildInvestmentStat(
                        'Arbitrage \nFunds',
                        '\$${(investmentSummary?.totalArbitrageInvestment ?? 0.0).toStringAsFixed(0)}',
                        Icons.swap_horiz,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: _buildInvestmentStat(
                        'Earning \nBalance',
                        '\$${incomeSummaryData!.data.totalIncome.toStringAsFixed(2)}',
                        Icons.swap_horiz,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Team Stats Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.groups,
                      color: Colors.black,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Team Performance',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTeamStat(
                        'Team Business',
                        '\$${rankData.teamBusiness.toStringAsFixed(0)}',
                        Icons.business,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTeamStat(
                        'Team Members',
                        '${rankData.teamMembers}',
                        Icons.group,
                      ),
                    ),
                    // const SizedBox(width: 12),
                    // Expanded(
                    //   child: _buildTeamStat(
                    //     'Total Earnings',
                    //     '\$${rankData.totalEarnings.toStringAsFixed(0)}',
                    //     Icons.account_balance_wallet,
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentStat(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.black.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamStat(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.black.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.black.withOpacity(0.8),
            size: 18,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: Colors.black.withOpacity(0.6),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRankBanner() {
    if (userRankData == null) return const SizedBox.shrink();

    final rankData = userRankData!.data;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0B90B), // Golden yellow
            Color(0xFFFFD700), // Bright gold
            Color(0xFFF0B90B), // Golden yellow
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF0B90B).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with rank and crown icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.military_tech,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rankData.currentRank.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        rankData.name,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${rankData.progressPercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress to ${rankData.nextRank}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '\$${rankData.teamBusiness.toStringAsFixed(0)} / \$${rankData.nextRankRequirement.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor:
                      (rankData.progressPercentage / 100).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.black,
            size: 16,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.black.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentTab() {
    return RefreshIndicator(
      color: const Color(0xFFF0B90B),
      backgroundColor: const Color(0xFF161A1E),
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Investment Package Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E2026),
                      Color(0xFF12151C),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF0B90B), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0B90B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: Color(0xFFF0B90B),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Investment Package',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Flexible investment from \$100 to \$1000',
                                style: TextStyle(
                                  color: Color(0xFF848E9C),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Package Features
                    _buildFeatureRow(
                        Icons.trending_up, 'Daily TPS', '0.33% - 0.50%'),
                    // const SizedBox(height: 12),
                    // _buildFeatureRow(Icons.schedule, 'Duration', '30 Days'),
                    const SizedBox(height: 12),
                    _buildFeatureRow(
                        Icons.security, 'Secure', 'Gas Wallet Protected'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Amount Input Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2026),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2D35), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Arbitrage Investment Amount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter amount (100 - 1000)',
                        hintStyle: const TextStyle(
                          color: Color(0xFF848E9C),
                          fontSize: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.attach_money,
                          color: Color(0xFFF0B90B),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF12151C),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFF2A2D35)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFF2A2D35)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFF0B90B)),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFE53935)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null) {
                          return 'Please enter a valid number';
                        }
                        if (amount < 100) {
                          return 'Minimum investment is \$100';
                        }
                        if (amount > 1000) {
                          return 'Maximum investment is \$1000';
                        }
                        if (amount > totalBalance) {
                          return 'Insufficient balance';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Quick Amount Buttons
                    Row(
                      children: [
                        Expanded(child: _buildQuickAmountButton('100')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildQuickAmountButton('250')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildQuickAmountButton('500')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildQuickAmountButton('1000')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Purchase Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _purchasePackage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF0B90B),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text(
                          'Purchase Investment Package',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFF0B90B),
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF848E9C),
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAmountButton(String amount) {
    return InkWell(
      onTap: () {
        _amountController.text = amount;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2D35),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF3A3D45), width: 1),
        ),
        child: Center(
          child: Text(
            '\$$amount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _purchasePackage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double amount = double.parse(_amountController.text);

    try {
      // Show confirmation dialog
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E2026),
            title: const Text(
              'Confirm Purchase',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Arbitrage Package',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Amount: \$${amount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Daily TPS: 0.33% - 0.50%',
                  style: TextStyle(color: Colors.white),
                ),
                // const SizedBox(height: 8),
                // const Text(
                //   'Duration: 30 Days',
                //   style: TextStyle(color: Colors.white),
                // ),
                const SizedBox(height: 16),
                const Text(
                  'This amount will be deducted from your gas wallet.',
                  style: TextStyle(
                    color: Color(0xFF848E9C),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF848E9C)),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0B90B),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );

      if (confirmed == true) {
        setState(() {
          _isProcessing = true;
        });

        try {
          print(
              '🛒 Purchasing arbitrage package for user: $commonuserId, amount: $amount');

          // Use arbitrage package API
          final data = await CommonMethod().buyArbitragePackage(amount);

          print('📤 Purchase API Request: buyArbitragePackage()');
          print('📥 Response: $data');

          if (data['status'] == 'success') {
            // Update local balance
            setState(() {
              gasBalance -= amount;
              totalBalance = gasBalance + bonusBalance;
            });

            // Reload investment data from API
            await _loadInvestmentData();

            _showSuccessToast(
                data['message'] ?? 'Package purchased successfully!');

            // Clear form and switch to My Investments tab
            _amountController.clear();
            _tabController.animateTo(1);
          } else {
            _showErrorToast(data['message'] ?? 'Failed to purchase package.');
          }
        } catch (e) {
          _showErrorToast('Network error. Please check your connection.');
        }
      }
    } catch (e) {
      _showErrorToast('An error occurred. Please try again.');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _loadUserRank() async {
    try {
      print('🔄 Loading user rank data for user: $commonuserId');

      final data = await CommonMethod().getUserRank();
      if (data.status == 'success') {
        setState(() {
          userRankData = data;
        });
        return; // Success, exit early
      }
      setState(() {
        userRankData = null;
      });
    } catch (e) {
      setState(() {
        userRankData = null;
      });
    }
  }

  Future<void> _loadIncomeSummary() async {
    try {
      final data = await CommonMethod().getIncomeSummary();

      if (data.status == 'success') {
        setState(() {
          incomeSummaryData = data;
        });
        return; // Success, exit early
      }
      setState(() {
        incomeSummaryData = null;
      });
    } catch (e) {
      setState(() {
        incomeSummaryData = null;
      });
    }
  }

  /// Get Daily TPS value from income summary API data
  double _getTotalTPSFromIncomeSummary() {
    if (incomeSummaryData == null) {
      return totalTPSIncome;
    }
    final dailyTPSValue = incomeSummaryData!.data.incomeBreakdown.dailyRoi;
    return dailyTPSValue;
  }

  Widget _buildMyInvestmentsTab() {
    return RefreshIndicator(
      color: const Color(0xFFF0B90B),
      backgroundColor: const Color(0xFF161A1E),
      onRefresh: _loadData,
      child: (arbitrageInvestments.isEmpty)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Color(0xFF848E9C),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Active Investments',
                    style: TextStyle(
                      color: Color(0xFF848E9C),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Purchase a package to start earning',
                    style: TextStyle(
                      color: Color(0xFF848E9C),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: arbitrageInvestments.length,
              itemBuilder: (context, index) {
                return _buildArbitrageInvestmentCard(
                    arbitrageInvestments[index]);
              },
            ),
    );
  }

  Widget _buildArbitrageInvestmentCard(ArbitrageInvestment investment) {
    final DateTime endDate = investment.startDate.add(const Duration(days: 30));
    final int daysRemaining =
        endDate.difference(DateTime.now()).inDays.clamp(0, 30);
    final double progress = (investment.daysRunning / 30).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2026),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2D35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Arbitrage Package',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: investment.status == 'ACTIVE'
                      ? const Color(0xFF0ECB81).withOpacity(0.1)
                      : const Color(0xFF848E9C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  investment.status,
                  style: TextStyle(
                    color: investment.status == 'ACTIVE'
                        ? const Color(0xFF0ECB81)
                        : const Color(0xFF848E9C),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInvestmentDetail('Investment',
                    '${investment.investmentAmount.toStringAsFixed(2)}'),
              ),
              Expanded(
                child: _buildInvestmentDetail(
                    'Daily TPS', '${investment.dailyRoiPercentage}%'),
              ),
              Expanded(
                child: _buildInvestmentDetail('Total Earned',
                    '${investment.totalRoiEarned.toStringAsFixed(2)}'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Release (Principal Withdrawal) Button
          if (investment.status == 'ACTIVE')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon:
                    const Icon(Icons.lock_open, color: Colors.black, size: 18),
                label: const Text(
                  'Release Principal',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0B90B),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1E2026),
                      title: const Text('Release Principal',
                          style: TextStyle(color: Colors.white)),
                      content: const Text(
                        'Are you sure you want to release (withdraw) your principal for this investment? This action cannot be undone.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel',
                              style: TextStyle(color: Color(0xFF848E9C))),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF0B90B),
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Release'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    try {
                      // Call backend to release principal
                      final res = await CommonMethod()
                          .releaseArbitragePrincipal(investment.id);
                      if (res['status'] == 'success') {
                        _showSuccessToast(res['message'] ??
                            'Principal released successfully!');
                        await _loadInvestmentData();
                      } else {
                        _showErrorToast(
                            res['message'] ?? 'Failed to release principal.');
                      }
                    } catch (e) {
                      _showErrorToast('Network error. Please try again.');
                    }
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInvestmentDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF848E9C),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeTab() {
    return RefreshIndicator(
      color: const Color(0xFFF0B90B),
      backgroundColor: const Color(0xFF161A1E),
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Income Overview Cards - New Income Management APIs
            Row(
              children: [
                Expanded(
                  child: _buildIncomeCard('Direct Income', directTotalIncome,
                      const Color(0xFF0ECB81), 'direct_income'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildIncomeCard(
                      'Level TPS Income',
                      levelTPSTotalIncome,
                      const Color(0xFFF0B90B),
                      'level_income'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildIncomeCard('Salary Income', salaryTotalIncome,
                      const Color(0xFF4A90E2), 'salary_income'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildIncomeCard(
                      'Total TPS Income',
                      _getTotalTPSFromIncomeSummary(),
                      const Color(0xFF9f86c0),
                      'roi'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Income History
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2026),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2D35), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Income History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Show new income management history
                  ...directIncomeHistory.map((income) =>
                      _buildNewIncomeHistoryItem('Direct Income', income.amount,
                          income.createdAt, income.status, income.description)),
                  ...levelTPSIncomeHistory.reversed.map((income) =>
                      _buildNewIncomeHistoryItem(
                          'Level TPS Income',
                          income.amount,
                          income.createdAt,
                          income.status,
                          income.description)),
                  ...salaryIncomeHistory.map((income) =>
                      _buildNewIncomeHistoryItem('Salary Income', income.amount,
                          income.createdAt, income.status, income.description)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeCard(
      String title, double amount, Color color, String incomeType) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IncomeDetailsPage(
              incomeType: incomeType,
              title: title,
              color: color,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2026),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF848E9C),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeHistoryItem(Map<String, dynamic> income) {
    final DateTime date = income['date'];
    final String formattedDate = '${date.day}/${date.month}/${date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF12151C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A2D35), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                income['type'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: const TextStyle(
                  color: Color(0xFF848E9C),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${income['amount'].toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF0ECB81),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0ECB81).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  income['status'],
                  style: const TextStyle(
                    color: Color(0xFF0ECB81),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewIncomeHistoryItem(String type, double amount, DateTime date,
      String status, String description) {
    final String formattedDate = '${date.day}/${date.month}/${date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF12151C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A2D35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF0ECB81),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF848E9C),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: const TextStyle(
                  color: Color(0xFF848E9C),
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: status == 'CREDITED'
                      ? const Color(0xFF0ECB81).withOpacity(0.1)
                      : const Color(0xFFE53935).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'CREDITED'
                        ? const Color(0xFF0ECB81)
                        : const Color(0xFFE53935),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return RefreshIndicator(
      color: const Color(0xFFF0B90B),
      backgroundColor: const Color(0xFF161A1E),
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Summary Cards
            _buildReportSummaryCard(),
            const SizedBox(height: 12),
            // Performance Chart Placeholder
            _buildPerformanceChart(),
            const SizedBox(height: 12),
            // Investment Breakdown
            _buildInvestmentBreakdown(),
            const SizedBox(height: 12),
            // Export Options
            _buildExportOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportSummaryCard() {
    final double totalInvested = investmentSummary?.totalInvestment ?? 0.0;
    final double totalEarned = investmentSummary?.totalRoiEarned ?? 0.0;
    final double totalIncome = dailyTPS +
        directIncome +
        levelIncome +
        businessIncome +
        directTotalIncome +
        levelTPSTotalIncome +
        salaryTotalIncome;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E2026),
            Color(0xFF12151C),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2D35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Investment Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                    'Total Invested',
                    '\$${totalInvested.toStringAsFixed(2)}',
                    const Color(0xFFF0B90B)),
              ),
              Expanded(
                child: _buildSummaryItem(
                    'Total Earned',
                    '\$${(totalDirectTPSIncome + totalBusinessIncome + totalTPSIncome + directTotalIncome + levelTPSTotalIncome + salaryTotalIncome).toStringAsFixed(2)}',
                    const Color(0xFF0ECB81)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                    'Active Investments',
                    '${arbitrageInvestments.where((inv) => inv.status == 'ACTIVE').length}',
                    const Color(0xFF4A90E2)),
              ),
              // Today's Income hidden as requested
              Expanded(child: Container()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF848E9C),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
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
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2026),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2D35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Performance Chart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0ECB81).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF0ECB81), width: 1),
                ),
                child: const Text(
                  'Live Data',
                  style: TextStyle(
                    color: Color(0xFF0ECB81),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Income Overview Cards
          FadeSlideTransition(
            delay: const Duration(milliseconds: 200),
            child: _buildIncomeOverviewCards(),
          ),
          const SizedBox(height: 12),
          // Bar Chart
          FadeSlideTransition(
            delay: const Duration(milliseconds: 300),
            child: _buildIncomeBarChart(),
          ),
          const SizedBox(height: 12),
          // Pie Chart
          FadeSlideTransition(
            delay: const Duration(milliseconds: 400),
            child: _buildIncomePieChartSection(),
          ),
          const SizedBox(height: 12),
          // Performance Metrics
          FadeSlideTransition(
            delay: const Duration(milliseconds: 600),
            child: _buildPerformanceMetrics(),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentBreakdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2026),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2D35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Investment Breakdown',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (arbitrageInvestments.isEmpty)
            const Center(
              child: Text(
                'No investments to display',
                style: TextStyle(
                  color: Color(0xFF848E9C),
                  fontSize: 14,
                ),
              ),
            )
          else
            ...arbitrageInvestments
                .map((investment) => _buildArbitrageBreakdownItem(investment)),
        ],
      ),
    );
  }

  Widget _buildIncomeOverviewCards() {
    // Use real loaded income data from specific APIs
    final totalIncome = directTotalIncome +
        levelTPSTotalIncome +
        salaryTotalIncome +
        totalTPSIncome;

    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            'Total Income',
            '\$${totalIncome.toStringAsFixed(2)}',
            const Color(0xFF0ECB81),
            Icons.account_balance_wallet,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildOverviewCard(
            'Daily TPS',
            '\$${totalTPSIncome.toStringAsFixed(2)}',
            const Color(0xFFF0B90B),
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildOverviewCard(
            'Direct Income',
            '\$${directTotalIncome.toStringAsFixed(2)}',
            const Color(0xFF4A90E2),
            Icons.people,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
      String title, String amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF848E9C),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeBarChart() {
    // Use real loaded income data from specific APIs
    final totalIncome = directTotalIncome +
        levelTPSTotalIncome +
        salaryTotalIncome +
        totalTPSIncome;

    if (totalIncome <= 0) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2026),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2D35), width: 1),
        ),
        child: const Center(
          child: Text(
            'No income data available',
            style: TextStyle(color: Color(0xFF848E9C)),
          ),
        ),
      );
    }

    // Create chart data using real API values
    final chartData = [
      {
        'label': 'Daily TPS',
        'value': totalTPSIncome,
        'color': const Color(0xFF0ECB81)
      },
      {
        'label': 'Direct',
        'value': directTotalIncome,
        'color': const Color(0xFFF0B90B)
      },
      {
        'label': 'Level TPS',
        'value': levelTPSTotalIncome,
        'color': const Color(0xFF4A90E2)
      },
      {
        'label': 'Salary',
        'value': salaryTotalIncome,
        'color': const Color(0xFF9C27B0)
      },
    ].where((data) => (data['value'] as double) > 0).toList();

    final maxValue = chartData
        .map((e) => e['value'] as double)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2026),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2D35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Income Breakdown',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final value = data['value'] as double;
                final color = data['color'] as Color;
                final label = data['label'] as String;
                final heightRatio = value / maxValue;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '\$${value.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 800 + (index * 100)),
                          curve: Curves.easeOutCubic,
                          height: 100 * heightRatio,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                color,
                                color.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Color(0xFF848E9C),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomePieChartSection() {
    // Use ONLY real loaded income data from specific APIs - NO DUMMY DATA
    final totalIncome = directTotalIncome +
        levelTPSTotalIncome +
        salaryTotalIncome +
        totalTPSIncome;

    if (totalIncome <= 0) {
      return Container(
        height: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2026),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2D35), width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.pie_chart,
                size: 48,
                color: Color(0xFF848E9C),
              ),
              SizedBox(height: 16),
              Text(
                'No Income Data Available',
                style: TextStyle(
                  color: Color(0xFF848E9C),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Create pie chart data using ONLY real API values - NO DUMMY DATA
    final pieData = [
      if (totalTPSIncome > 0)
        {
          'label': 'Daily TPS',
          'value': totalTPSIncome,
          'color': const Color(0xFF0ECB81)
        },
      if (directTotalIncome > 0)
        {
          'label': 'Direct Income',
          'value': directTotalIncome,
          'color': const Color(0xFFF0B90B)
        },
      if (levelTPSTotalIncome > 0)
        {
          'label': 'Level TPS',
          'value': levelTPSTotalIncome,
          'color': const Color(0xFF4A90E2)
        },
      if (salaryTotalIncome > 0)
        {
          'label': 'Salary',
          'value': salaryTotalIncome,
          'color': const Color(0xFF9C27B0)
        },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2026),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2D35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Income Distribution',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  'Total: \$${totalIncome.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF0ECB81),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBeautifulPieChart(pieData, totalIncome),
        ],
      ),
    );
  }

  Widget _buildBeautifulPieChart(
      List<Map<String, dynamic>> pieData, double totalIncome) {
    if (pieData.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No data to display',
            style: TextStyle(color: Color(0xFF848E9C)),
          ),
        ),
      );
    }

    // Convert to Syncfusion chart data
    final List<IncomeChartData> chartData = pieData.map((data) {
      return IncomeChartData(
        category: data['label'] as String,
        value: data['value'] as double,
        color: data['color'] as Color,
      );
    }).toList();

    return SizedBox(
      height: 280,
      child: SfCircularChart(
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.all(0),
        legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          overflowMode: LegendItemOverflowMode.wrap,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          itemPadding: 4,
          padding: 8,
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'point.x: \$point.y (point.percentage%)',
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 11,
          ),
          color: const Color(0xFF2A2D35),
          borderColor: const Color(0xFF0ECB81),
          borderWidth: 1,
        ),
        series: <CircularSeries>[
          DoughnutSeries<IncomeChartData, String>(
            dataSource: chartData,
            xValueMapper: (IncomeChartData data, _) => data.category,
            yValueMapper: (IncomeChartData data, _) => data.value,
            pointColorMapper: (IncomeChartData data, _) => data.color,
            innerRadius: '55%',
            radius: '80%',
            strokeColor: const Color(0xFF1E2026),
            strokeWidth: 2,
            dataLabelSettings: const DataLabelSettings(
              isVisible: false,
            ),
            enableTooltip: true,
            animationDuration: 1000,
            explode: false,
          ),
        ],
        annotations: <CircularChartAnnotation>[
          CircularChartAnnotation(
            widget: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D35).withOpacity(0.9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF0ECB81).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: Color(0xFF848E9C),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${totalIncome.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF0ECB81),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainPerformanceChart() {
    // Use real loaded income data from specific APIs
    final totalIncome = directTotalIncome +
        levelTPSTotalIncome +
        salaryTotalIncome +
        totalTPSIncome;

    if (totalIncome <= 0) {
      return Container(
        height: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2026),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2D35), width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.bar_chart,
                size: 48,
                color: Color(0xFF848E9C),
              ),
              SizedBox(height: 16),
              Text(
                'No Income Data Available',
                style: TextStyle(
                  color: Color(0xFF848E9C),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2026),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2D35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Income Distribution',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Total: \$${totalIncome.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF0ECB81),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildEnhancedPieChart(),
        ],
      ),
    );
  }

  Widget _buildEnhancedPieChart() {
    // Use real loaded income data from specific APIs
    final totalIncome = directTotalIncome +
        levelTPSTotalIncome +
        salaryTotalIncome +
        totalTPSIncome;

    // Create pie chart data using real API values
    final pieData = [
      {
        'label': 'Daily TPS',
        'value': totalTPSIncome,
        'color': const Color(0xFF0ECB81)
      },
      {
        'label': 'Direct Income',
        'value': directTotalIncome,
        'color': const Color(0xFFF0B90B)
      },
      {
        'label': 'Level TPS',
        'value': levelTPSTotalIncome,
        'color': const Color(0xFF4A90E2)
      },
      {
        'label': 'Salary',
        'value': salaryTotalIncome,
        'color': const Color(0xFF9C27B0)
      },
    ].where((data) => (data['value'] as double) > 0).toList();

    return SizedBox(
      height: 250,
      child: Row(
        children: [
          // Pie Chart
          Expanded(
            flex: 2,
            child: CustomPaint(
              painter: EnhancedPieChartPainter(pieData, totalIncome),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(width: 20),
          // Legend
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: pieData.map((data) {
                final percentage =
                    ((data['value'] as double) / totalIncome * 100);
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: data['color'] as Color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['label'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${(data['value'] as double).toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                              style: const TextStyle(
                                color: Color(0xFF848E9C),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeBreakdownChart() {
    // Use real loaded income data from specific APIs
    final totalIncome = directTotalIncome +
        levelTPSTotalIncome +
        salaryTotalIncome +
        totalTPSIncome;

    if (totalIncome <= 0) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No income data available',
            style: TextStyle(color: Color(0xFF848E9C)),
          ),
        ),
      );
    }

    // Create chart data using real API values
    final chartData = [
      {
        'label': 'Daily TPS',
        'value': totalTPSIncome,
        'color': const Color(0xFF0ECB81)
      },
      {
        'label': 'Direct Income',
        'value': directTotalIncome,
        'color': const Color(0xFFF0B90B)
      },
      {
        'label': 'Level TPS',
        'value': levelTPSTotalIncome,
        'color': const Color(0xFF4A90E2)
      },
      {
        'label': 'Salary',
        'value': salaryTotalIncome,
        'color': const Color(0xFF9C27B0)
      },
    ]
        .where((data) => (data['value'] as double) > 0)
        .toList(); // Only show categories with actual income

    return SizedBox(
      height: 200,
      child: Column(
        children: [
          // Chart visualization
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: chartData.map((data) {
                final percentage = totalIncome > 0
                    ? (data['value'] as double) / totalIncome
                    : 0.0;
                final height = (percentage * 150).clamp(10.0, 150.0);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '\$${(data['value'] as double).toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      width: 30,
                      height: height,
                      decoration: BoxDecoration(
                        color: data['color'] as Color,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            data['color'] as Color,
                            (data['color'] as Color).withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['label'] as String,
                      style: const TextStyle(
                        color: Color(0xFF848E9C),
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomePieChart() {
    // Use real loaded income data from specific APIs
    final totalIncome = directTotalIncome +
        levelTPSTotalIncome +
        salaryTotalIncome +
        totalTPSIncome;

    if (totalIncome <= 0) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2D35).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3A3D45), width: 1),
        ),
        child: const Center(
          child: Text(
            'No income data',
            style: TextStyle(color: Color(0xFF848E9C)),
          ),
        ),
      );
    }

    // Create pie chart data using real API values
    final pieData = [
      {
        'label': 'Daily TPS',
        'value': totalTPSIncome,
        'color': const Color(0xFF0ECB81)
      },
      {
        'label': 'Direct',
        'value': directTotalIncome,
        'color': const Color(0xFFF0B90B)
      },
      {
        'label': 'Level TPS',
        'value': levelTPSTotalIncome,
        'color': const Color(0xFF4A90E2)
      },
      {
        'label': 'Salary',
        'value': salaryTotalIncome,
        'color': const Color(0xFF9C27B0)
      },
    ].where((data) => (data['value'] as double) > 0).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D35).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3D45), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Income Distribution',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                // Pie Chart
                Expanded(
                  flex: 3,
                  child: CustomPaint(
                    painter: PieChartPainter(pieData, totalIncome),
                    child: const SizedBox.expand(),
                  ),
                ),
                const SizedBox(width: 12),
                // Legend
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: pieData.map((data) {
                      final percentage =
                          ((data['value'] as double) / totalIncome * 100);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: data['color'] as Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['label'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      color: Color(0xFF848E9C),
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTPSTrendChart() {
    // Use real TPS history data from API
    if (roiHistoryData == null || roiHistoryData!.data.roiHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2D35).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3A3D45), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Daily TPS Trend',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'No TPS history data available',
                style: TextStyle(
                  color: Color(0xFF848E9C),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Use actual TPS history data from API
    final roiHistory = roiHistoryData!.data.roiHistory;
    final trendData = roiHistory.take(7).map((roi) {
      return {
        'date': roi.roiDate,
        'value': roi.roiAmount,
        'day': [
          'Mon',
          'Tue',
          'Wed',
          'Thu',
          'Fri',
          'Sat',
          'Sun'
        ][roi.roiDate.weekday - 1],
      };
    }).toList();

    if (trendData.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxValue = trendData
        .map((e) => e['value'] as double)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D35).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3D45), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily TPS Trend (7 Days)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0ECB81).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '+${((trendData.last['value'] as double) - (trendData.first['value'] as double)).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF0ECB81),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: trendData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final value = data['value'] as double;
                final height = maxValue > 0
                    ? (value / maxValue * 80).clamp(10.0, 80.0)
                    : 10.0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '\$${value.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration:
                          Duration(milliseconds: 800 + (index * 100).toInt()),
                      curve: Curves.easeOutCubic,
                      width: 20,
                      height: height,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(3)),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            const Color(0xFF0ECB81),
                            const Color(0xFF0ECB81).withOpacity(0.6),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0ECB81).withOpacity(0.3),
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['day'] as String,
                      style: const TextStyle(
                        color: Color(0xFF848E9C),
                        fontSize: 10,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    // Use real loaded income data from specific APIs
    final totalIncome = directTotalIncome +
        levelTPSTotalIncome +
        salaryTotalIncome +
        totalTPSIncome;

    if (totalIncome <= 0) {
      return const SizedBox.shrink();
    }

    // Calculate performance metrics using real data
    final totalInvested = investmentSummary?.totalInvestment ?? 0.0;
    final roiPercentage =
        totalInvested > 0 ? (totalIncome / totalInvested) * 100 : 0.0;

    // Use REAL daily TPS from income summary API - NOT total cumulative
    final dailyAverage =
        incomeSummaryData?.data.incomeBreakdown.dailyRoi ?? 0.0;
    final monthlyProjection = dailyAverage * 30;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'TPS %',
            '${roiPercentage.toStringAsFixed(1)}%',
            roiPercentage >= 0
                ? const Color(0xFF0ECB81)
                : const Color(0xFFFF5722),
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Daily Avg',
            '\$${dailyAverage.toStringAsFixed(2)}',
            const Color(0xFFF0B90B),
            Icons.today,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Monthly Est.',
            '\$${monthlyProjection.toStringAsFixed(2)}',
            const Color(0xFF4A90E2),
            Icons.calendar_month,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D35).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF848E9C),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(Map<String, dynamic> investment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF12151C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                investment['package'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'TPS: ${investment['dailyTPS']}%',
                style: const TextStyle(
                  color: Color(0xFF848E9C),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            '\$${investment['amount'].toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xFF0ECB81),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArbitrageBreakdownItem(ArbitrageInvestment investment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF12151C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Arbitrage Package',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'TPS: ${investment.dailyRoiPercentage}%',
                style: const TextStyle(
                  color: Color(0xFF848E9C),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            '\$${investment.investmentAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xFF0ECB81),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOptions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2026),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2D35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export Reports',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _exportReport('PDF'),
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('Export PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _exportReport('Excel'),
                  icon: const Icon(Icons.table_chart, size: 18),
                  label: const Text('Export Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0ECB81),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportReport(String format) async {
    try {
      if (format == 'PDF') {
        await _downloadPDF();
      } else if (format == 'Excel') {
        await _downloadExcel();
      }
    } catch (e) {
      print('Export error: $e');
      _showErrorToast('Failed to export $format. Please try again.');
    }
  }

  Future<void> _downloadPDF() async {
    try {
      // Create PDF document
      final pdf = pw.Document();

      // Get current date for filename
      final now = DateTime.now();
      final dateStr = '${now.day}-${now.month}-${now.year}';

      // Calculate totals
      final totalIncome = directTotalIncome +
          levelTPSTotalIncome +
          salaryTotalIncome +
          totalTPSIncome;
      final totalInvested = investmentSummary?.totalInvestment ?? 0.0;
      final dailyTPSValue =
          incomeSummaryData?.data.incomeBreakdown.dailyRoi ?? 0.0;

      // Add page to PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey800,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Arbitrade Trading Report',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Generated on: ${now.day}/${now.month}/${now.year}',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey300,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Summary Section
                pw.Text(
                  'Income Summary',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),

                // Income breakdown table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  children: [
                    // Header row
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Inycome Tpe',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Amount (USD)',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    // Data rows
                    if (dailyTPSValue > 0)
                      pw.TableRow(children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Daily TPS')),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                                '\$${dailyTPSValue.toStringAsFixed(2)}')),
                      ]),
                    if (directTotalIncome > 0)
                      pw.TableRow(children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Direct Income')),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                                '\$${directTotalIncome.toStringAsFixed(2)}')),
                      ]),
                    if (levelTPSTotalIncome > 0)
                      pw.TableRow(children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Level TPS Income')),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                                '\$${levelTPSTotalIncome.toStringAsFixed(2)}')),
                      ]),
                    if (salaryTotalIncome > 0)
                      pw.TableRow(children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Salary Income')),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                                '\$${salaryTotalIncome.toStringAsFixed(2)}')),
                      ]),
                    // Total row
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Total Income',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('\$${totalIncome.toStringAsFixed(2)}',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),

                // Investment Summary
                pw.Text(
                  'Investment Summary',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),

                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  children: [
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Metric',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Value',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Total Invested')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child:
                              pw.Text('\$${totalInvested.toStringAsFixed(2)}')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Daily Average TPS')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child:
                              pw.Text('\$${dailyTPSValue.toStringAsFixed(2)}')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Monthly Projection')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                              '\$${(dailyTPSValue * 30).toStringAsFixed(2)}')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('TPS Percentage')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                              '${totalInvested > 0 ? ((totalIncome / totalInvested) * 100).toStringAsFixed(1) : '0.0'}%')),
                    ]),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Save PDF to Downloads folder
      final directory = await _getDownloadsDirectory();
      final fileName = 'arbitrade_report_$dateStr.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      // Show download notification and success message
      await _showDownloadNotification(fileName, file.path, 'PDF');
      _showSuccessToast(
          'PDF downloaded successfully! Tap notification for options.');
    } catch (e) {
      print('PDF download error: $e');
      _showErrorToast('Failed to download PDF. Please try again.');
    }
  }

  Future<void> _downloadExcel() async {
    try {
      // Create Excel workbook
      final excel = excel_lib.Excel.createExcel();
      final sheet = excel['Arbitrade Report'];

      // Get current date for filename
      final now = DateTime.now();
      final dateStr = '${now.day}-${now.month}-${now.year}';

      // Calculate totals
      final totalIncome = directTotalIncome +
          levelTPSTotalIncome +
          salaryTotalIncome +
          totalTPSIncome;
      final totalInvested = investmentSummary?.totalInvestment ?? 0.0;
      final dailyTPSValue =
          incomeSummaryData?.data.incomeBreakdown.dailyRoi ?? 0.0;

      // Add header
      sheet.cell(excel_lib.CellIndex.indexByString('A1')).value =
          'Arbitrade Trading Report';
      sheet.cell(excel_lib.CellIndex.indexByString('A2')).value =
          'Generated on: ${now.day}/${now.month}/${now.year}';

      // Income Summary Section
      sheet.cell(excel_lib.CellIndex.indexByString('A4')).value =
          'INCOME SUMMARY';
      sheet.cell(excel_lib.CellIndex.indexByString('A5')).value = 'Income Type';
      sheet.cell(excel_lib.CellIndex.indexByString('B5')).value =
          'Amount (USD)';

      int row = 6;
      if (dailyTPSValue > 0) {
        sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
            'Daily TPS';
        sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value =
            '\$${dailyTPSValue.toStringAsFixed(2)}';
        row++;
      }

      if (directTotalIncome > 0) {
        sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
            'Direct Income';
        sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value =
            '\$${directTotalIncome.toStringAsFixed(2)}';
        row++;
      }

      if (levelTPSTotalIncome > 0) {
        sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
            'Level TPS Income';
        sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value =
            '\$${levelTPSTotalIncome.toStringAsFixed(2)}';
        row++;
      }

      if (salaryTotalIncome > 0) {
        sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
            'Salary Income';
        sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value =
            '\$${salaryTotalIncome.toStringAsFixed(2)}';
        row++;
      }

      // Total row
      sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
          'TOTAL INCOME';
      sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value =
          '\$${totalIncome.toStringAsFixed(2)}';
      row += 2;

      // Investment Summary Section
      sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
          'INVESTMENT SUMMARY';
      row++;
      sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value = 'Metric';
      sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value = 'Value';
      row++;

      sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
          'Total Invested';
      sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value =
          '\$${totalInvested.toStringAsFixed(2)}';
      row++;

      sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
          'Daily Average TPS';
      sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value =
          '\$${dailyTPSValue.toStringAsFixed(2)}';
      row++;

      sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
          'Monthly Projection';
      sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value =
          '\$${(dailyTPSValue * 30).toStringAsFixed(2)}';
      row++;

      sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
          'TPS Percentage';
      sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value =
          '${totalInvested > 0 ? ((totalIncome / totalInvested) * 100).toStringAsFixed(1) : '0.0'}%';
      row += 2;

      // Investment Details Section
      if (arbitrageInvestments.isNotEmpty) {
        sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
            'ACTIVE INVESTMENTS';
        row++;
        sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
            'Investment Amount';
        sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value =
            'Daily TPS %';
        sheet.cell(excel_lib.CellIndex.indexByString('C$row')).value =
            'Total Earned';
        sheet.cell(excel_lib.CellIndex.indexByString('D$row')).value = 'Status';
        sheet.cell(excel_lib.CellIndex.indexByString('E$row')).value =
            'Days Running';
        row++;

        for (final investment in arbitrageInvestments) {
          sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
              '\$${investment.investmentAmount.toStringAsFixed(2)}';
          sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value =
              '${investment.dailyRoiPercentage}%';
          sheet.cell(excel_lib.CellIndex.indexByString('C$row')).value =
              '\$${investment.totalRoiEarned.toStringAsFixed(2)}';
          sheet.cell(excel_lib.CellIndex.indexByString('D$row')).value =
              investment.status;
          sheet.cell(excel_lib.CellIndex.indexByString('E$row')).value =
              '${investment.daysRunning}/30';
          row++;
        }
      }

      // Save Excel file to Downloads folder
      final directory = await _getDownloadsDirectory();
      final fileName = 'arbitrade_report_$dateStr.xlsx';
      final file = File('${directory.path}/$fileName');
      final bytes = excel.encode();
      if (bytes != null) {
        await file.writeAsBytes(bytes);

        // Show download notification and success message
        await _showDownloadNotification(fileName, file.path, 'Excel');
        _showSuccessToast(
            'Excel downloaded successfully! Tap notification for options.');
      } else {
        _showErrorToast('Failed to generate Excel file');
      }
    } catch (e) {
      print('Excel download error: $e');
      _showErrorToast('Failed to download Excel. Please try again.');
    }
  }

  // Helper method to get Downloads directory - No permissions needed
  Future<Directory> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // Use app's external files directory - no permissions needed
      try {
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          // Create Downloads subfolder in app's external directory
          final downloadsDir = Directory('${directory.path}/Downloads');
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }
          return downloadsDir;
        }
      } catch (e) {
        print('External storage error: $e');
      }
    }
    // Fallback to app documents directory
    return await getApplicationDocumentsDirectory();
  }

  // Show download notification with click to open functionality
  Future<void> _showDownloadNotification(
      String fileName, String filePath, String fileType) async {
    try {
      // Create a simple notification using ScaffoldMessenger
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  fileType == 'PDF' ? Icons.picture_as_pdf : Icons.table_chart,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$fileType Downloaded',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        fileName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0ECB81),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'VIEW',
              textColor: Colors.white,
              onPressed: () => _showFileOptionsDialog(filePath, fileType),
            ),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      print('Notification error: $e');
    }
  }

  // Show file options dialog with OPEN and SHARE buttons
  void _showFileOptionsDialog(String filePath, String fileType) {
    print('Showing file options dialog for: $filePath');
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2D35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(
                fileType == 'PDF' ? Icons.picture_as_pdf : Icons.table_chart,
                color: const Color(0xFF0ECB81),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '$fileType Downloaded',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your report is ready! Choose an option:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              // File path info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2026),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFF0ECB81).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.folder,
                      color: Color(0xFF0ECB81),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        filePath.split('/').last,
                        style: const TextStyle(
                          color: Color(0xFF0ECB81),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            // OPEN Button
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _openFileDirectly(filePath);
              },
              icon: const Icon(
                Icons.open_in_new,
                color: Color(0xFF0ECB81),
                size: 18,
              ),
              label: const Text(
                'OPEN',
                style: TextStyle(
                  color: Color(0xFF0ECB81),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // SHARE Button
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _shareFile(filePath);
              },
              icon: const Icon(
                Icons.share,
                color: Color(0xFF0ECB81),
                size: 18,
              ),
              label: const Text(
                'SHARE',
                style: TextStyle(
                  color: Color(0xFF0ECB81),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Open file directly - Simple approach
  Future<void> _openFileDirectly(String filePath) async {
    try {
      // For Android, use a simple file:// URI approach
      if (Platform.isAndroid) {
        // Try with content:// URI first for Android 11+
        try {
          final fileName = filePath.split('/').last;
          final mimeType = fileName.toLowerCase().endsWith('.pdf')
              ? 'application/pdf'
              : 'application/vnd.ms-excel';

          // Use Intent.ACTION_VIEW with FileProvider
          await launchUrl(
            Uri.parse('content://${filePath.replaceAll(' ', '%20')}'),
            mode: LaunchMode.externalApplication,
          );
          _showSuccessToast('Opening file...');
          return;
        } catch (e) {
          // Fallback to file:// URI
          try {
            final uri = Uri.parse('file://$filePath');
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            _showSuccessToast('Opening file...');
            return;
          } catch (e) {
            // Show error dialog with options
            _showOpenErrorDialog(filePath);
          }
        }
      } else {
        // For iOS, use Uri.file
        final uri = Uri.file(filePath);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        _showSuccessToast('Opening file...');
      }
    } catch (e) {
      // Show error dialog with options
      _showOpenErrorDialog(filePath);
    }
  }

  // Show error dialog with options to share or view location
  void _showOpenErrorDialog(String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2D35),
          title: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 10),
              Text('Cannot Open File', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Unable to open file directly. Would you like to share it instead?',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              Text(
                'File: ${filePath.split('/').last}',
                style: const TextStyle(color: Color(0xFF0ECB81), fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showFileLocationDialog(filePath);
              },
              child: const Text('VIEW LOCATION',
                  style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _shareFile(filePath);
              },
              child: const Text('SHARE',
                  style: TextStyle(color: Color(0xFF0ECB81))),
            ),
          ],
        );
      },
    );
  }

  // Share file using share_plus
  Future<void> _shareFile(String filePath) async {
    try {
      final file = XFile(filePath);
      await Share.shareXFiles(
        [file],
        text: 'Arbitrade Trading Report',
        subject: 'Your trading report is ready!',
      );
    } catch (e) {
      print('Share file error: $e');
      _showErrorToast('Cannot share file');
      _showFileLocationDialog(filePath);
    }
  }

  // Show file location dialog as fallback
  void _showFileLocationDialog(String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2D35),
          title: const Text(
            'File Downloaded',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your report has been saved to:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2026),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  filePath,
                  style: const TextStyle(
                    color: Color(0xFF0ECB81),
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You can find this file in your device\'s file manager.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF0ECB81)),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Custom Pie Chart Painter
class PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double total;

  PieChartPainter(this.data, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        (size.width < size.height ? size.width : size.height) / 2 - 10;

    double startAngle = -90 * (3.14159 / 180); // Start from top

    for (var item in data) {
      final value = item['value'] as double;
      final color = item['color'] as Color;
      final sweepAngle = (value / total) * 2 * 3.14159;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // Draw pie slice
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw border
      final borderPaint = Paint()
        ..color = const Color(0xFF1E2026)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      startAngle += sweepAngle;
    }

    // Draw center circle for donut effect
    final centerPaint = Paint()
      ..color = const Color(0xFF2A2D35)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.4, centerPaint);

    // Draw total amount in center
    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          const TextSpan(
            text: 'Total\n',
            style: TextStyle(
              color: Color(0xFF848E9C),
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text: '\$${total.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Enhanced Pie Chart Painter with better design
class EnhancedPieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double total;

  EnhancedPieChartPainter(this.data, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        (size.width < size.height ? size.width : size.height) / 2 - 20;

    double startAngle = -90 * (3.14159 / 180); // Start from top

    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(
      Offset(center.dx + 4, center.dy + 4),
      radius,
      shadowPaint,
    );

    for (var item in data) {
      final value = item['value'] as double;
      final color = item['color'] as Color;
      final sweepAngle = (value / total) * 2 * 3.14159;

      // Draw pie slice with gradient
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color,
            color.withOpacity(0.7),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw border
      final borderPaint = Paint()
        ..color = const Color(0xFF1E2026)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      startAngle += sweepAngle;
    }

    // Draw center circle for donut effect with gradient
    final centerPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFF2A2D35),
          Color(0xFF1E2026),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.5))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, centerPaint);

    // Draw center border
    final centerBorderPaint = Paint()
      ..color = const Color(0xFF3A3D45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius * 0.5, centerBorderPaint);

    // Draw total amount in center
    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          const TextSpan(
            text: 'Total Income\n',
            style: TextStyle(
              color: Color(0xFF848E9C),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text: '\$${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Beautiful Pie Chart Painter - Modern Design with NO DUMMY DATA
class BeautifulPieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double total;

  BeautifulPieChartPainter(this.data, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        (size.width < size.height ? size.width : size.height) / 2 - 30;
    final innerRadius = radius * 0.6; // For donut effect

    double startAngle = -90 * (3.14159 / 180); // Start from top

    // Draw outer shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawCircle(
      Offset(center.dx + 6, center.dy + 6),
      radius,
      shadowPaint,
    );

    // Draw each segment
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final value = item['value'] as double;
      final color = item['color'] as Color;
      final sweepAngle = (value / total) * 2 * 3.14159;

      // Create gradient for each segment
      final gradient = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [
          color,
          color.withOpacity(0.8),
          color,
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      // Draw main segment
      final paint = Paint()
        ..shader = gradient
            .createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw inner border for donut effect
      final innerBorderPaint = Paint()
        ..color = const Color(0xFF1E2026)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        startAngle,
        sweepAngle,
        false,
        innerBorderPaint,
      );

      // Draw outer border
      final outerBorderPaint = Paint()
        ..color = const Color(0xFF1E2026)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        outerBorderPaint,
      );

      // Draw segment separators
      if (data.length > 1) {
        final separatorPaint = Paint()
          ..color = const Color(0xFF1E2026)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        final endX = center.dx + radius * cos(startAngle + sweepAngle);
        final endY = center.dy + radius * sin(startAngle + sweepAngle);
        final innerEndX =
            center.dx + innerRadius * cos(startAngle + sweepAngle);
        final innerEndY =
            center.dy + innerRadius * sin(startAngle + sweepAngle);

        canvas.drawLine(
          Offset(innerEndX, innerEndY),
          Offset(endX, endY),
          separatorPaint,
        );
      }

      startAngle += sweepAngle;
    }

    // Draw center circle with gradient
    final centerGradient = const RadialGradient(
      colors: [
        Color(0xFF2A2D35),
        Color(0xFF1E2026),
      ],
    );

    final centerPaint = Paint()
      ..shader = centerGradient
          .createShader(Rect.fromCircle(center: center, radius: innerRadius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, innerRadius, centerPaint);

    // Draw center border
    final centerBorderPaint = Paint()
      ..color = const Color(0xFF3A3D45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, innerRadius, centerBorderPaint);

    // Draw total amount in center
    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          const TextSpan(
            text: 'Total Income\n',
            style: TextStyle(
              color: Color(0xFF848E9C),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text: '\$${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Data model for Syncfusion pie chart - NO DUMMY DATA
class IncomeChartData {
  final String category;
  final double value;
  final Color color;

  IncomeChartData({
    required this.category,
    required this.value,
    required this.color,
  });
}
