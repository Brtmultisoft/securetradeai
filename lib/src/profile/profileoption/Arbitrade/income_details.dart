import 'package:flutter/material.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/method/methods.dart';
import 'package:securetradeai/src/widget/animated_toast.dart';

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

      // Use CommonMethod to get income data
      final data = await CommonMethod().getIncomes(widget.incomeType);

      print('📤 Income API Request: getIncomes(${widget.incomeType})');
      print('📥 Response: $data');

      if (data['status'] == true) {
        List<Map<String, dynamic>> incomes = [];
        double total = 0.0;

        if (data['data'] != null && data['data'] is List) {
          print('✅ Found ${data['data'].length} income records');
          for (var income in data['data']) {
            final amount =
                double.tryParse(income['amount']?.toString() ?? '0') ?? 0.0;
            total += amount;

            incomes.add({
              'id': income['id']?.toString() ?? '',
              'amount': amount,
              'investment_amount': income['investment_amount'],
              'From_Users': income['From_Users']?.toString(),
              'created_at': income['created_at']?.toString() ?? '',
              'type': income['type']?.toString() ?? widget.incomeType,
            });
          }
        } else {
          print('ℹ️ No income data found or data is not a list');
        }

        setState(() {
          incomeData = incomes;
          totalAmount = total;
        });
      } else {
        print('⚠️ API returned error: ${data['message'] ?? 'Unknown error'}');
        _showErrorToast(data['message'] ?? 'Failed to load income data');
        setState(() {
          incomeData = [];
          totalAmount = 0.0;
        });
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
      backgroundColor: const Color(0xFF1A2234), // Binance dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF161A1E), // Binance header color
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
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
            onPressed: _loadIncomeData,
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
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: incomeData.length,
        itemBuilder: (context, index) {
          final income = incomeData[index];
          return _buildIncomeItem(income);
        },
      ),
    );
  }

  Widget _buildIncomeItem(Map<String, dynamic> income) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                _getIncomeTypeDisplay(income['type']),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${income['amount'].toStringAsFixed(2)}',
                style: TextStyle(
                  color: widget.color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: Color(0xFF848E9C),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Date : ${_formatDate(income['created_at'])}',
                style: const TextStyle(
                  color: Color(0xFF848E9C),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (income['From_Users'] != null &&
              income['From_Users'].isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.person,
                  color: Color(0xFF848E9C),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'From: ${income['From_Users']}',
                  style: const TextStyle(
                    color: Color(0xFF848E9C),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          const SizedBox(width: 8),
          if (income['investment_amount'] != null &&
              income['investment_amount'].isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.monetization_on_outlined,
                  color: Color(0xFF848E9C),
                  size: 16,
                ),
                Text(
                  ' Investment Amount : \$${income['investment_amount']}',
                  // 'Investment Amount : ${income['investment_amount']}',
                  style: const TextStyle(
                    color: Color(0xFF848E9C),
                    fontSize: 12,
                  ),
                ),
              ],
            )
          ],
        ],
      ),
    );
  }
}
