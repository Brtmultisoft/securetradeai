import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:securetradeai/method/methods.dart';

class TransactionDetails extends StatefulWidget {
  const TransactionDetails({Key? key}) : super(key: key);

  @override
  _TransactionDetailsState createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> with SingleTickerProviderStateMixin {
  // Binance theme colors
  final Color backgroundColor = Color(0xFF1E2329);
  final Color cardColor = Color(0xFF2B3139);
  final Color primaryColor = Color(0xFFF0B90B);
  final Color successColor = Color(0xFF2EBD85);
  final Color dangerColor = Color(0xFFF6465D);
  final Color textColor = Colors.white;
  final Color secondaryTextColor = Color(0xFF848E9C);
  final Color borderColor = Color(0xFF373C3F);

  late TabController _tabController;
  bool isLoading = false;
  String currentCurrency = "USD";
  double totalCurrency = 1.0;

  // Transaction Data
  List<Map<String, dynamic>> transactions = [];
  double totalAmount = 0.0;
  double todayAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

      // TODO: Load transaction data from API
      // For now using dummy data
      setState(() {
        transactions = [
          {
            'type': 'Deposit',
            'amount': 100.0,
            'date': DateTime.now().subtract(Duration(days: 1)),
            'status': 'Completed',
          },
          {
            'type': 'Withdrawal',
            'amount': -50.0,
            'date': DateTime.now().subtract(Duration(days: 2)),
            'status': 'Completed',
          },
          {
            'type': 'Trade',
            'amount': 25.0,
            'date': DateTime.now().subtract(Duration(days: 3)),
            'status': 'Completed',
          },
        ];
        totalAmount = transactions.fold(0.0, (sum, item) => sum + (item['amount'] as double));
        todayAmount = transactions
            .where((item) => (item['date'] as DateTime).isAfter(DateTime.now().subtract(Duration(days: 1))))
            .fold(0.0, (sum, item) => sum + (item['amount'] as double));
      });
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
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
      length: 2,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          title: Text(
            'Transaction Details',
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
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: Container(
              color: backgroundColor,
              child: TabBar(
                controller: _tabController,
                indicatorColor: primaryColor,
                indicatorWeight: 3,
                labelColor: primaryColor,
                unselectedLabelColor: secondaryTextColor,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(text: 'All'),
                  Tab(text: 'Today'),
                ],
              ),
            ),
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
                  _buildAllTransactionsView(),
                  _buildTodayTransactionsView(),
                ],
              ),
      ),
    );
  }

  Widget _buildAllTransactionsView() {
    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: cardColor,
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildTransactionOverview(totalAmount),
            _buildTransactionList(transactions),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayTransactionsView() {
    final todayTransactions = transactions
        .where((item) => (item['date'] as DateTime).isAfter(DateTime.now().subtract(Duration(days: 1))))
        .toList();

    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: cardColor,
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildTransactionOverview(todayAmount),
            _buildTransactionList(todayTransactions),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionOverview(double amount) {
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
                  Icons.account_balance_wallet,
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
                      'Total Transactions',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${(amount * totalCurrency).toStringAsFixed(2)} $currentCurrency',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
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

  Widget _buildTransactionList(List<Map<String, dynamic>> transactions) {
    if (transactions.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16),
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

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final amount = transaction['amount'] as double;
        final date = transaction['date'] as DateTime;
        final type = transaction['type'] as String;
        final status = transaction['status'] as String;

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
                  type,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(amount * totalCurrency).toStringAsFixed(2)} $currentCurrency',
                  style: TextStyle(
                    color: amount >= 0 ? successColor : dangerColor,
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
                    DateFormat('MMM dd, yyyy HH:mm').format(date),
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: status == 'Completed' ? successColor.withOpacity(0.1) : dangerColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: status == 'Completed' ? successColor : dangerColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 