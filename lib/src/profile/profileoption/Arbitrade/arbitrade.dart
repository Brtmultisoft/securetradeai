import 'package:flutter/material.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/method/methods.dart';
import 'package:securetradeai/model/incomeManagementModel.dart';
import 'package:securetradeai/model/incomeSummaryModel.dart';
import 'package:securetradeai/model/userInvestmentsModel.dart';
import 'package:securetradeai/model/userRankModel.dart';
import 'package:securetradeai/src/profile/profileoption/Arbitrade/income_details.dart';
import 'package:securetradeai/src/widget/animated_toast.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';

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
  double dailyROI = 0.0;
  double directIncome = 0.0;
  double levelIncome = 0.0;
  double businessIncome = 0.0;
  double totalROIIncome = 0.0;
  double totalDirectROIIncome = 0.0;
  double totalBusinessIncome = 0.0;
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

  // New Income Management Data
  DirectIncomeModel? directIncomeData;
  double directTotalIncome = 0.0;
  List<DirectIncomeHistory> directIncomeHistory = [];

  LevelIncomeModel? levelROIIncomeData;
  double levelROITotalIncome = 0.0;
  List<LevelIncomeHistory> levelROIIncomeHistory = [];

  SalaryIncomeModel? salaryIncomeData;
  double salaryTotalIncome = 0.0;
  List<SalaryIncomeHistory> salaryIncomeHistory = [];

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

      // Load user balance data and income totals
      final userData = await CommonMethod().getMineData();
      if (userData.status == "success" && userData.data.isNotEmpty) {
        final userInfo = userData.data[0];
        setState(() {
          gasBalance = double.tryParse(userInfo.balance) ?? 0.0;

          bonusBalance = double.tryParse(userInfo.incomeBalance) ?? 0.0;
          totalBalance = gasBalance + bonusBalance;

          // Extract income totals from mine API response
          totalROIIncome = double.tryParse(userInfo.totalRoiIncome) ?? 0.0;
          totalDirectROIIncome =
              double.tryParse(userInfo.totalDirectRoiIncome) ?? 0.0;
          totalBusinessIncome =
              double.tryParse(userInfo.totalBusinessIncome) ?? 0.0;
        });
      }

      // Load investment data
      await _loadInvestmentData();

      // Load new income management data
      await Future.wait([
        _loadDirectIncome(),
        _loadLevelROIIncome(),
        _loadSalaryIncome(),
        _loadUserRank(),
        _loadIncomeSummary(),
      ]);
    } catch (e) {
      print('Error loading data: $e');
      _showErrorToast('Failed to load data. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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

  Future<void> _loadLevelROIIncome() async {
    try {
      final res = await CommonMethod().getLevelROIIncome();
      if (res.status == "success") {
        setState(() {
          levelROIIncomeData = res;
          levelROITotalIncome = res.data.totalLevelIncome;
          levelROIIncomeHistory = res.data.incomeHistory;
        });
      }
    } catch (e) {
      print('Error loading level ROI income: $e');
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12), // Binance dark background
      appBar: CommonAppBar.analytics(
        title: 'Investment Panel',
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
                        'Top-Up Balance',
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
          Divider(
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
          // First row: Daily ROI and Direct Referral
          Row(
            children: [
              Expanded(
                child: _buildIncomeItem(
                  'Daily ROI',
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
          // Second row: Level ROI and Gas Fee
          Row(
            children: [
              Expanded(
                child: _buildIncomeItem(
                  'Level ROI',
                  breakdown.levelRoi,
                  Icons.layers,
                  const Color(0xFFF0B90B),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _buildIncomeItem(
                  'Gas Fee',
                  breakdown.gasFee,
                  Icons.local_gas_station,
                  const Color(0xFF848E9C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Third row: Salary (full width)
          _buildIncomeItem(
            'Salary',
            breakdown.salary,
            Icons.account_balance_wallet,
            const Color(0xFF9C27B0),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeItem(
      String label, double amount, IconData icon, Color color) {
    return Container(
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
        ],
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
                      Icons.diamond,
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

          // Progress to next rank
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

          const SizedBox(height: 16),

          // Quick stats row
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  'Team Business',
                  '\$${rankData.teamBusiness.toStringAsFixed(0)}',
                  Icons.business,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStat(
                  'Team Members',
                  '${rankData.teamMembers}',
                  Icons.group,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStat(
                  'Total Earnings',
                  '\$${rankData.totalEarnings.toStringAsFixed(0)}',
                  Icons.account_balance_wallet,
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
                                'Flexible investment from \$50 to \$1000',
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
                        Icons.trending_up, 'Daily ROI', '0.33% - 0.55%'),
                    const SizedBox(height: 12),
                    _buildFeatureRow(Icons.schedule, 'Duration', '30 Days'),
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
                        hintText: 'Enter amount (50 - 1000)',
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
                        if (amount < 50) {
                          return 'Minimum investment is \$50';
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
                        Expanded(child: _buildQuickAmountButton('50')),
                        const SizedBox(width: 8),
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
                  'Daily ROI: 0.33% - 0.55%',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Duration: 30 Days',
                  style: TextStyle(color: Colors.white),
                ),
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
            print('✅ Package purchased successfully');

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
            print('❌ Purchase failed: ${data['message']}');
            _showErrorToast(data['message'] ?? 'Failed to purchase package.');
          }
        } catch (e) {
          print('❌ Exception during purchase: $e');
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
      print('📤 User Rank API Request: getUserRank()');
      print('📥 Response Status: ${data.status}');

      // Print detailed rank data
      print('🏆 ===== USER RANK DATA =====');
      print('📊 Status: ${data.status}');

      if (data.status == 'success') {
        final rankData = data.data;
        print('👤 User Name: ${rankData.name}');
        print('🎖️ Current Rank: ${rankData.currentRank}');
        print('⬆️ Next Rank: ${rankData.nextRank}');
        print(
            '💼 Team Business: \$${rankData.teamBusiness.toStringAsFixed(2)}');
        print('👥 Team Members: ${rankData.teamMembers}');
        print(
            '💰 Total Earnings: \$${rankData.totalEarnings.toStringAsFixed(2)}');
        print(
            '📈 Progress Percentage: ${rankData.progressPercentage.toStringAsFixed(1)}%');
        print(
            '🎯 Next Rank Requirement: \$${rankData.nextRankRequirement.toStringAsFixed(2)}');
        print('🏆 ===========================');

        setState(() {
          userRankData = data;
        });

        print('✅ User rank loaded successfully: ${data.data.currentRank}');
        return; // Success, exit early
      }

      print('⚠️ User rank API failed with status: ${data.status}');
      setState(() {
        userRankData = null;
      });
    } catch (e) {
      print('❌ Exception loading user rank data: $e');
      print('❌ Exception type: ${e.runtimeType}');
      setState(() {
        userRankData = null;
      });
    }
  }

  Future<void> _loadIncomeSummary() async {
    try {
      print('🔄 Loading income summary data for user: $commonuserId');

      final data = await CommonMethod().getIncomeSummary();
      print('📤 Income Summary API Request: getIncomeSummary()');
      print('📥 Response Status: ${data.status}');

      // Print detailed income summary data
      print('💰 ===== INCOME SUMMARY DATA =====');
      print('📊 Status: ${data.status}');

      if (data.status == 'success') {
        final incomeData = data.data;
        final breakdown = incomeData.incomeBreakdown;

        print(
            '💵 Total Income: \$${incomeData.totalIncome.toStringAsFixed(2)}');
        print('📈 Income Breakdown:');
        print('  📊 Daily ROI: \$${breakdown.dailyRoi.toStringAsFixed(2)}');
        print(
            '  👥 Direct Referral: \$${breakdown.directReferral.toStringAsFixed(2)}');
        print('  🔗 Level ROI: \$${breakdown.levelRoi.toStringAsFixed(2)}');
        print('  ⛽ Gas Fee: \$${breakdown.gasFee.toStringAsFixed(2)}');
        print('  💼 Salary: \$${breakdown.salary.toStringAsFixed(2)}');
        print('💰 ===============================');

        setState(() {
          incomeSummaryData = data;
        });

        print(
            '✅ Income summary loaded successfully: Total \$${data.data.totalIncome.toStringAsFixed(2)}');
        return; // Success, exit early
      }

      print('⚠️ Income summary API failed, setting empty data');
      setState(() {
        incomeSummaryData = null;
      });
    } catch (e) {
      print('❌ Exception loading income summary data: $e');
      setState(() {
        incomeSummaryData = null;
      });
    }
  }

  /// Get Daily ROI value from income summary API data
  double _getTotalROIFromIncomeSummary() {
    if (incomeSummaryData == null) {
      // Fallback to old data if income summary is not available
      return totalROIIncome;
    }

    // Use the daily_roi from the API response (0.49)
    final dailyROIValue = incomeSummaryData!.data.incomeBreakdown.dailyRoi;

    print('🔢 Using Daily ROI from API:');
    print('  📊 Daily ROI: \$${dailyROIValue.toStringAsFixed(2)}');
    print('  🎯 This is the ROI income value from API');

    return dailyROIValue;
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
                    '\$${investment.investmentAmount.toStringAsFixed(2)}'),
              ),
              Expanded(
                child: _buildInvestmentDetail(
                    'Daily ROI', '${investment.dailyRoiPercentage}%'),
              ),
              Expanded(
                child: _buildInvestmentDetail('Total Earned',
                    '\$${investment.totalRoiEarned.toStringAsFixed(2)}'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(
                  color: Color(0xFF848E9C),
                  fontSize: 12,
                ),
              ),
              Text(
                '$daysRemaining days remaining',
                style: const TextStyle(
                  color: Color(0xFF848E9C),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF2A2D35),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0ECB81)),
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
                      'Level ROI Income',
                      levelROITotalIncome,
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
                    'Total ROI Income',
                    _getTotalROIFromIncomeSummary(),
                    const Color(0xFFE53935),
                    'roi'
                  ),
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
                  ...levelROIIncomeHistory.map((income) =>
                      _buildNewIncomeHistoryItem(
                          'Level ROI Income',
                          income.amount,
                          income.createdAt,
                          income.status,
                          income.description)),
                  ...salaryIncomeHistory.map((income) =>
                      _buildNewIncomeHistoryItem('Salary Income', income.amount,
                          income.createdAt, income.status, income.description)),
                  // Show existing income history if no new data
                  // if (directIncomeHistory.isEmpty &&
                  //     levelROIIncomeHistory.isEmpty &&
                  //     salaryIncomeHistory.isEmpty)
                  //   ...incomeHistory
                  //       .map((income) => _buildIncomeHistoryItem(income)),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary Cards
            _buildReportSummaryCard(),
            const SizedBox(height: 16),
            // Performance Chart Placeholder
            _buildPerformanceChart(),
            const SizedBox(height: 16),
            // Investment Breakdown
            _buildInvestmentBreakdown(),
            const SizedBox(height: 16),
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
    final double totalIncome = dailyROI +
        directIncome +
        levelIncome +
        businessIncome +
        directTotalIncome +
        levelROITotalIncome +
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
                    '\$${(totalDirectROIIncome + totalBusinessIncome + totalROIIncome + directTotalIncome + levelROITotalIncome + salaryTotalIncome).toStringAsFixed(2)}',
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
              Expanded(
                child: _buildSummaryItem(
                    'Today\'s Income',
                    '\$${totalIncome.toStringAsFixed(2)}',
                    const Color(0xFFE53935)),
              ),
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
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2026),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2D35), width: 1),
      ),
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
            'Performance Chart',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(
              color: Color(0xFF848E9C),
              fontSize: 14,
            ),
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
                'ROI: ${investment['dailyROI']}%',
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
                'ROI: ${investment.dailyRoiPercentage}%',
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

  void _exportReport(String format) {
    _showSuccessToast('$format export feature coming soon!');
  }
}
