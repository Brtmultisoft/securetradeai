import 'package:flutter/material.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/method/methods.dart';
import 'package:securetradeai/src/widget/animated_toast.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';
import 'package:securetradeai/src/widget/lottie_loading_widget.dart';

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
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;

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
                'From_Users': income.referenceId,
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
          print('📤 Income API Request: getLevelTPSIncome()');
          final levelRes = await CommonMethod().getLevelTPSIncome();
          print('📥 Response: ${levelRes.status}');

          if (levelRes.status == "success") {
            total = levelRes.data.totalLevelIncome;
            for (var income in levelRes.data.incomeHistory) {
              incomes.add({
                'id': income.id.toString(),
                'amount': income.amount,
                'investment_amount': '',
                'From_Users': income.referenceId,
                'created_at': income.createdAt.toIso8601String(),
                'type': 'Level TPS Income',
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
          // Get the first active investment ID for TPS history
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
                  'type': 'Daily TPS',
                  'description':
                      'Daily TPS ${roi.roiPercentage}% from ${firstInvestment.packageType} package',
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

  // Date picker methods
  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: widget.color,
              onPrimary: Colors.black,
              surface: const Color(0xFF1A2234),
              onSurface: Colors.white,
              background: const Color(0xFF0B0E11),
              onBackground: Colors.white,
              secondary: widget.color,
              onSecondary: Colors.black,
            ),
            dialogBackgroundColor: const Color(0xFF1A2234),
            textTheme: const TextTheme(
              headlineMedium: TextStyle(color: Colors.white),
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
              labelLarge: TextStyle(color: Colors.white),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: widget.color,
              onPrimary: Colors.black,
              surface: const Color(0xFF1A2234),
              onSurface: Colors.white,
              background: const Color(0xFF0B0E11),
              onBackground: Colors.white,
              secondary: widget.color,
              onSecondary: Colors.black,
            ),
            dialogBackgroundColor: const Color(0xFF1A2234),
            textTheme: const TextTheme(
              headlineMedium: TextStyle(color: Colors.white),
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
              labelLarge: TextStyle(color: Colors.white),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _clearDateFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  String _getIncomeTypeDisplay(String type) {
    switch (type) {
      case 'roi':
        return 'Daily TPS';
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
          ? Center(
              child: LottieLoadingWidget.large(
                message: 'Loading ${widget.title}...',
                messageColor: Colors.white,
              ),
            )
          : Column(
              children: [
                // Search Bar and Date Filters
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      // Search Bar
                      TextField(
                        decoration: InputDecoration(
                          hintText:
                              'Search by referral, investment, or description',
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF232A3B),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 0),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.trim();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      // Date Filter Row
                      Row(
                        children: [
                          // Start Date
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectStartDate(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF232A3B),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        color: Colors.white54, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _startDate != null
                                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                            : 'Start Date',
                                        style: TextStyle(
                                          color: _startDate != null
                                              ? Colors.white
                                              : Colors.white54,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // End Date
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectEndDate(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF232A3B),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        color: Colors.white54, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _endDate != null
                                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                            : 'End Date',
                                        style: TextStyle(
                                          color: _endDate != null
                                              ? Colors.white
                                              : Colors.white54,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Clear Filters Button
                          InkWell(
                            onTap: () => _clearDateFilters(),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: widget.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.clear,
                                color: widget.color,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                      widget.title.toLowerCase().contains('total')
                          ? widget.title
                          : "Total ${widget.title}",
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
                    // Filter indicator
                    if (_searchQuery.isNotEmpty || _startDate != null || _endDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_alt,
                              color: widget.color,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Filters active',
                              style: TextStyle(
                                color: widget.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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
    // Apply both search and date filters
    final filteredData = incomeData.where((income) {
      // Search filter
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final fourthCol = _getFourthColumnData(income).toLowerCase();
        final descr =
            (income['description'] ?? '').toString().toLowerCase();
        matchesSearch = fourthCol.contains(query) || descr.contains(query);
      }

      // Date filter
      bool matchesDate = true;
      if (_startDate != null || _endDate != null) {
        try {
          final incomeDate = DateTime.parse(income['created_at']);
          if (_startDate != null) {
            matchesDate = matchesDate &&
                incomeDate.isAfter(_startDate!.subtract(const Duration(days: 1)));
          }
          if (_endDate != null) {
            matchesDate = matchesDate &&
                incomeDate.isBefore(_endDate!.add(const Duration(days: 1)));
          }
        } catch (e) {
          // If date parsing fails, exclude the item
          matchesDate = false;
        }
      }

      return matchesSearch && matchesDate;
    }).toList();
    if (filteredData.isEmpty) {
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
            Text(
              _searchQuery.isNotEmpty || _startDate != null || _endDate != null
                  ? 'No records match your filters'
                  : 'Income records will appear here',
              style: const TextStyle(
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
        child: _buildCustomTable(filteredData),
      ),
    );
  }

  Widget _buildCustomTable([List<Map<String, dynamic>>? dataOverride]) {
    final data = dataOverride ?? incomeData;

    // ✅ Reverse only if it's Level TPS
    final displayData =
        widget.incomeType == 'level_income' ? data.reversed.toList() : data;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2026),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFF2A2D35), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row
            Container(
              color: const Color(0xFF2A2D35),
              child: Row(
                children: [
                  SizedBox(
                    width: _shouldShowFifthColumn() ? 40 : 50,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 6,
                      ),
                      child: Text(
                        'S.No',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 12,
                      ),
                      child: Text(
                        'Date & Time',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: _shouldShowFifthColumn() ? 60 : 80,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      child: Text(
                        'Amount',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  if (_shouldShowFourthColumn())
                    SizedBox(
                      width: _shouldShowFifthColumn() ? 90 : 110,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 12,
                        ),
                        child: Text(
                          _getFourthColumnHeader(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  if (_shouldShowFifthColumn())
                    const Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 12,
                        ),
                        child: Text(
                          'Description',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Data Rows
            ...displayData.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> income = entry.value;

              return Container(
                color: index % 2 == 0
                    ? const Color(0xFF1E2026)
                    : const Color(0xFF252A32),
                child: Row(
                  children: [
                    SizedBox(
                      width: _shouldShowFifthColumn() ? 40 : 50,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 12,
                        ),
                        child: Text(
                          // ✅ numbering logic:
                          widget.incomeType == 'level_income'
                              ? '${displayData.length - index}' // highest first for Level TPS
                              : '${index + 1}', // normal numbering for others
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 12,
                        ),
                        child: Text(
                          _formatDate(income['created_at']),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: _shouldShowFifthColumn() ? 60 : 80,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 12,
                        ),
                        child: Text(
                          '\$${income['amount'].toStringAsFixed(2)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: widget.color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (_shouldShowFourthColumn())
                      SizedBox(
                        width: _shouldShowFifthColumn() ? 90 : 110,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 12,
                          ),
                          child: Text(
                            _getFourthColumnData(income),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    if (_shouldShowFifthColumn())
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 12,
                          ),
                          child: Text(
                            income['description']?.toString() ?? 'N/A',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Helper method to determine if fourth column should be shown
  bool _shouldShowFourthColumn() {
    String titleLower = widget.title.toLowerCase();
    return titleLower.contains('direct') ||
        titleLower.contains('total roi') ||
        titleLower.contains('level');
  }

  // Helper method to determine if fifth column should be shown (for Level TPS and Salary description)
  bool _shouldShowFifthColumn() {
    String titleLower = widget.title.toLowerCase();
    return titleLower.contains('level') || titleLower.contains('salary');
  }

  // Helper method to get fourth column header text
  String _getFourthColumnHeader() {
    String titleLower = widget.title.toLowerCase();
    if (titleLower.contains('total roi')) {
      return 'Investment';
    } else if (titleLower.contains('direct')) {
      return 'From User';
    } else if (titleLower.contains('level')) {
      return 'From User';
    }
    return 'level';
  }

  // Helper method to get fourth column data
  String _getFourthColumnData(Map<String, dynamic> income) {
    String titleLower = widget.title.toLowerCase();
    if (titleLower.contains('total roi')) {
      // For Total TPS, show investment amount
      return income['investment_amount']?.toString() ?? 'N/A';
    } else if (titleLower.contains('direct')) {
      // For Direct Income, show referral ID
      return (income['From_Users']?.toString().isNotEmpty == true)
          ? income['From_Users'].toString()
          : (income['reference_id']?.toString().isNotEmpty == true)
              ? income['reference_id'].toString()
              : 'N/A';
    } else if (titleLower.contains('level')) {
      // For Level TPS Income, show referral ID (same as direct income)
      return (income['From_Users']?.toString().isNotEmpty == true)
          ? income['From_Users'].toString()
          : (income['reference_id']?.toString().isNotEmpty == true)
              ? income['reference_id'].toString()
              : 'N/A';
    }
    return 'N/A';
  }
}
