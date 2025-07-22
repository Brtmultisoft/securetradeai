import 'package:flutter/material.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/method/methods.dart';
import 'package:securetradeai/src/profile/profileoption/Arbitrade/income_details.dart';
import 'package:securetradeai/src/widget/animated_toast.dart';

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
  List<Map<String, dynamic>> myInvestments = [];
  List<Map<String, dynamic>> incomeHistory = [];

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

      final data = await CommonMethod().getUserInvestments();

      print('📤 Investment API Request: getUserInvestments()');
      print('📥 Response: $data');

      if (data['status'] == 'success') {
        List<Map<String, dynamic>> investments = [];

        if (data['data'] != null && data['data'] is List) {
          print('✅ Found ${data['data'].length} investments');
          for (var investment in data['data']) {
            investments.add({
              'package': investment['package_name'] ?? 'Investment Package',
              'amount':
                  double.tryParse(investment['amount']?.toString() ?? '0') ??
                      0.0,
              'dailyROI':
                  double.tryParse(investment['daily_roi']?.toString() ?? '0') ??
                      0.0,
              'startDate': investment['start_date'] != null
                  ? DateTime.tryParse(investment['start_date']) ??
                      DateTime.now()
                  : DateTime.now(),
              'endDate': investment['end_date'] != null
                  ? DateTime.tryParse(investment['end_date']) ??
                      DateTime.now().add(const Duration(days: 30))
                  : DateTime.now().add(const Duration(days: 30)),
              'totalEarned': double.tryParse(
                      investment['total_earned']?.toString() ?? '0') ??
                  0.0,
              'status': investment['status'] ?? 'Active',
            });
          }
        } else {
          print('ℹ️ No investment data found or data is not a list');
        }

        setState(() {
          myInvestments = investments;
        });
        return; // Success, exit early
      }

      // If both APIs fail, set empty list
      print('⚠️ Both investment APIs failed, setting empty list');
      setState(() {
        myInvestments = [];
      });
    } catch (e) {
      print('❌ Exception loading investment data: $e');
      setState(() {
        myInvestments = [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12), // Binance dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF161A1E), // Binance header color
        elevation: 0,
        title: const Text(
          'Investment Panel',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
          : Column(
              children: [
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
                // Tab Views
                Expanded(
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
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E2026), // Binance card dark
            Color(0xFF12151C), // Binance card darker
          ],
        ),
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
                'Available Balance',
                style: TextStyle(
                  color: Color(0xFF848E9C),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0ECB81).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Gas Wallet',
                  style: TextStyle(
                    color: Color(0xFF0ECB81),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${totalBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gas Balance',
                      style: TextStyle(
                        color: Color(0xFF848E9C),
                        fontSize: 12,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Earning Balance',
                      style: TextStyle(
                        color: Color(0xFF848E9C),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${bonusBalance.toStringAsFixed(2)}',
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
                        Icons.trending_up, 'Daily ROI', '3.5% - 4.5%'),
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
                      'Investment Amount',
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
                  'Investment Package',
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
                  'Daily ROI: 3.5% - 4.5%',
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
              '🛒 Purchasing package for user: $commonuserId, amount: $amount');

          // Use CommonMethod to buy investment package
          final data = await CommonMethod()
              .buyInvestmentPackage(amount.toString(), 'investment_package');

          print('📤 Purchase API Request: buyInvestmentPackage()');
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

  Widget _buildMyInvestmentsTab() {
    return RefreshIndicator(
      color: const Color(0xFFF0B90B),
      backgroundColor: const Color(0xFF161A1E),
      onRefresh: _loadData,
      child: myInvestments.isEmpty
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
              itemCount: myInvestments.length,
              itemBuilder: (context, index) {
                final investment = myInvestments[index];
                return _buildInvestmentCard(investment);
              },
            ),
    );
  }

  Widget _buildInvestmentCard(Map<String, dynamic> investment) {
    final DateTime startDate = investment['startDate'];
    final DateTime endDate = investment['endDate'];
    final int daysRemaining = endDate.difference(DateTime.now()).inDays;
    final double progress =
        (DateTime.now().difference(startDate).inDays / 30).clamp(0.0, 1.0);

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
              Text(
                investment['package'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: investment['status'] == 'Active'
                      ? const Color(0xFF0ECB81).withOpacity(0.1)
                      : const Color(0xFF848E9C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  investment['status'],
                  style: TextStyle(
                    color: investment['status'] == 'Active'
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
                    '\$${investment['amount'].toStringAsFixed(2)}'),
              ),
              Expanded(
                child: _buildInvestmentDetail(
                    'Daily ROI', '${investment['dailyROI']}%'),
              ),
              Expanded(
                child: _buildInvestmentDetail('Total Earned',
                    '\$${investment['totalEarned'].toStringAsFixed(2)}'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: const TextStyle(
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
            // Income Overview Cards
            Row(
              children: [
                Expanded(
                  child: _buildIncomeCard('Total ROI Income', totalROIIncome,
                      const Color(0xFF0ECB81), 'roi'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildIncomeCard(
                      'Direct ROI Income',
                      totalDirectROIIncome,
                      const Color(0xFFF0B90B),
                      'direct_roi_income'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildIncomeCard('Level Income', double.parse('0'),
                      const Color(0xFF4A90E2), 'level_income'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildIncomeCard(
                      'Business Income',
                      totalBusinessIncome,
                      const Color(0xFFE53935),
                      'business_income'),
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
                  ...incomeHistory
                      .map((income) => _buildIncomeHistoryItem(income)),
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
    final double totalInvested =
        myInvestments.fold(0.0, (sum, inv) => sum + inv['amount']);
    final double totalEarned =
        myInvestments.fold(0.0, (sum, inv) => sum + inv['totalEarned']);
    final double totalIncome =
        dailyROI + directIncome + levelIncome + businessIncome;

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
                    '\$${(totalDirectROIIncome + totalBusinessIncome + totalROIIncome).toStringAsFixed(2)}',
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
                    '${myInvestments.where((inv) => inv['status'] == 'active ').length}',
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
          if (myInvestments.isEmpty)
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
            ...myInvestments
                .map((investment) => _buildBreakdownItem(investment)),
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
