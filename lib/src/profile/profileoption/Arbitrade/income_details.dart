import 'package:flutter/material.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/method/methods.dart';
import 'package:securetradeai/src/widget/animated_toast.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';

class IncomeDetailsPage extends StatefulWidget {
  final String incomeType;
  final String title;
  final Color color;

  const IncomeDetailsPage({
    Key? key,
    required this.incomeType,
    required this.title,
    required this.color,
  }) : super(key: key);

  @override
  State<IncomeDetailsPage> createState() => _IncomeDetailsPageState();
}

class _IncomeDetailsPageState extends State<IncomeDetailsPage> {
  bool isLoading = false;
  List<Map<String, dynamic>> incomeData = [];
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadIncomeData();
  }

  Future<void> _loadIncomeData() async {
    try {
      setState(() {
        isLoading = true;
      });

      print('🔄 Loading ${widget.incomeType} data for user: $commonuserId');

      List<Map<String, dynamic>> incomes = [];
      double total = 0.0;

      // Use new income management APIs based on income type
      switch (widget.incomeType) {
        case 'direct_income':
          print('📤 Income API Request: getDirectIncome()');
          final directRes = await CommonMethod().getDirectIncome();
          print('📥 Response: ${directRes.status}');

          if (directRes.status == "success") {
            total = directRes.data.totalDirectIncome;
            for (var income in directRes.data.incomeHistory) {
              incomes.add({
                'id': income.id.toString(),
                'amount': income.amount,
                'investment_amount': '',
                'From_Users': income.referenceId.toString(),
                'created_at': income.createdAt.toIso8601String(),
                'type': 'Direct Income',
                'description': income.description,
                'status': income.status,
                'percentage': income.percentage,
              });
            }
          }
          break;

        case 'level_income':
          print('📤 Income API Request: getLevelROIIncome()');
          final levelRes = await CommonMethod().getLevelROIIncome();
          print('📥 Response: ${levelRes.status}');

          if (levelRes.status == "success") {
            total = levelRes.data.totalLevelIncome;
            for (var income in levelRes.data.incomeHistory) {
              incomes.add({
                'id': income.id.toString(),
                'amount': income.amount,
                'investment_amount': '',
                'From_Users': income.referenceId.toString(),
                'created_at': income.createdAt.toIso8601String(),
                'type': 'Level ROI Income',
                'description': income.description,
                'status': income.status,
                'level': income.level,
                'percentage': income.percentage,
              });
            }
          }
          break;

        case 'salary_income':
          print('📤 Income API Request: getSalaryIncome()');
          final salaryRes = await CommonMethod().getSalaryIncome();
          print('📥 Response: ${salaryRes.status}');

          if (salaryRes.status == "success") {
            total = salaryRes.data.totalSalaryIncome;
            for (var income in salaryRes.data.salaryHistory) {
              incomes.add({
                'id': income.id.toString(),
                'amount': income.amount,
                'investment_amount': '',
                'From_Users': '',
                'created_at': income.createdAt.toIso8601String(),
                'type': 'Salary Income',
                'description': income.description,
                'status': income.status,
              });
            }
          }
          break;

        case 'roi':
          print('📤 Income API Request: getDailyRoiHistory()');
          // Get the first active investment ID for ROI history
          final investmentsRes = await CommonMethod().getUserInvestmentsNew();
          if (investmentsRes.status == "success" &&
              investmentsRes.data.arbitrageInvestments.isNotEmpty) {
            final firstInvestment =
                investmentsRes.data.arbitrageInvestments.first;
            final roiRes = await CommonMethod().getDailyRoiHistory(
              investmentId: firstInvestment.id,
              limit: 50, // Get more history
            );
            print('📥 Response: ${roiRes.status}');

            if (roiRes.status == "success") {
              total = roiRes.data.totalRoiEarned;
              for (var roi in roiRes.data.roiHistory) {
                incomes.add({
                  'id': roi.id.toString(),
                  'amount': roi.roiAmount,
                  'investment_amount':
                      firstInvestment.investmentAmount.toString(),
                  'From_Users': 'Investment #${firstInvestment.id}',
                  'created_at': roi.createdAt.toIso8601String(),
                  'type': 'Daily ROI',
                  'description':
                      'Daily ROI ${roi.roiPercentage}% from ${firstInvestment.packageType} package',
                  'status': 'COMPLETED',
                  'roi_date': roi.roiDate.toIso8601String(),
                  'roi_percentage': roi.roiPercentage,
                });
              }
            }
          }
          break;

        default:
          // Fallback for any other income types
          print('⚠️ Unknown income type: ${widget.incomeType}');
          //         'id': income['id']?.toString() ?? '',
          //         'amount': amount,
          //         'investment_amount': income['investment_amount'],
          //         'From_Users': income['From_Users']?.toString(),
          //         'created_at': income['created_at']?.toString() ?? '',
          //         'type': income['type']?.toString() ?? widget.incomeType,
          //       });
          //     }
          //   }
          // }
          break;
      }

      setState(() {
        incomeData = incomes;
        totalAmount = total;
      });

      if (incomes.isEmpty) {
        print('ℹ️ No income data found');
      } else {
        print('✅ Found ${incomes.length} income records');
      }
    } catch (e) {
      print('❌ Exception loading income data: $e');
      _showErrorToast('Failed to load data. Please try again.');
      setState(() {
        incomeData = [];
        totalAmount = 0.0;
      });
    } finally {
      setState(() {
        isLoading = false;
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

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  String _getIncomeTypeDisplay(String type) {
    switch (type) {
      case 'roi':
        return 'Daily ROI';
      case 'direct_roi_income':
        return 'Direct Income';
      case 'level_income':
        return 'Level Income';
      case 'business_income':
        return 'Business Income';
      default:
        return type.replaceAll('_', ' ').toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2234),
      appBar: CommonAppBar.analytics(
        title: widget.title,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadIncomeData,
          ),
        ],
      ),
      // appBar: AppBar(
      //   backgroundColor: const Color(0xFF161A1E), // Binance header color
      //   elevation: 0,
      //   title: Text(
      //     widget.title,
      //     style: const TextStyle(
      //       color: Colors.white,
      //       fontWeight: FontWeight.w500,
      //       fontSize: 18,
      //     ),
      //   ),
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Colors.white),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.refresh, color: Colors.white),
      //       onPressed: _loadIncomeData,
      //     ),
      //   ],
      // ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF0B90B),
              ),
            )
          : Column(
              children: [
                // Summary Card
                _buildSummaryCard(),
                // Income List
                Expanded(
                  child: _buildIncomeList(),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.color.withOpacity(0.1),
            widget.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIncomeIcon(),
                  color: widget.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total " + widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${incomeData.length} transactions',
                      style: const TextStyle(
                        color: Color(0xFF848E9C),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Earned',
                style: TextStyle(
                  color: Color(0xFF848E9C),
                  fontSize: 14,
                ),
              ),
              Text(
                '\$${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: widget.color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIncomeIcon() {
    switch (widget.incomeType) {
      case 'roi':
        return Icons.trending_up;
      case 'direct_income':
        return Icons.person_add;
      case 'level_income':
        return Icons.account_tree;
      case 'business_income':
        return Icons.emoji_events;
      default:
        return Icons.attach_money;
    }
  }

  Widget _buildIncomeList() {
    if (incomeData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIncomeIcon(),
              size: 64,
              color: const Color(0xFF848E9C),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${widget.title} Records',
              style: const TextStyle(
                color: Color(0xFF848E9C),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Income records will appear here',
              style: TextStyle(
                color: Color(0xFF848E9C),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFF0B90B),
      backgroundColor: const Color(0xFF161A1E),
      onRefresh: _loadIncomeData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildCustomTable(),
      ),
    );
  }

  Widget _buildCustomTable() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2026),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFF2A2D35), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row
            Container(
              color: const Color(0xFF2A2D35),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 12,
                      ),
                      child: Text(
                        'S.No',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 12,
                      ),
                      child: Text(
                        'Date & Time',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 12,
                      ),
                      child: Text(
                        'Amount',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 12,
                      ),
                      child: Text(
                        'Referral',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  // Expanded(
                  //   flex: 1,
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(12.0),
                  //     child: Text(
                  //       'Type',
                  //       textAlign: TextAlign.center,
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 12,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            // Data Rows
            ...incomeData.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> income = entry.value;
              return Container(
                color: index % 2 == 0
                    ? const Color(0xFF1E2026)
                    : const Color(0xFF252A32),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 12,
                        ),
                        child: Text(
                          '${index + 1}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 12,
                        ),
                        child: Text(
                          _formatDate(income['created_at']),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 12,
                        ),
                        child: Text(
                          '\$${income['amount'].toStringAsFixed(2)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: widget.color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 12,
                        ),
                        child: Text(
                          income['From_Users']?.toString() ??
                              income['reference_id']?.toString() ??
                              'N/A',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    // Expanded(
                    //   flex: 1,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(12.0),
                    //     child: Text(
                    //       _getIncomeTypeDisplay(income['type']),
                    //       textAlign: TextAlign.center,
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 11,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
