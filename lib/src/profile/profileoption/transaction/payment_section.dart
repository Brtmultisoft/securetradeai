import 'package:flutter/material.dart';
import 'package:securetradeai/method/methods.dart';
import 'package:securetradeai/model/DeposittransactionModel.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';

class PaymentSection extends StatefulWidget {
  const PaymentSection({Key? key}) : super(key: key);

  @override
  State<PaymentSection> createState() => _PaymentSectionState();
}

class _PaymentSectionState extends State<PaymentSection> {
  double totalBalance = 0.0;
  bool isLoading = true;
  String currentCurrency = "USD";
  List<Detail> transactions = [];
  int page = 1;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Get user profile data which includes balance
      final userData = await CommonMethod().getMineData();
      if (userData.status == "success" && userData.data.isNotEmpty) {
        setState(() {
          totalBalance = double.tryParse(userData.data[0].balance) ?? 0.0;
        });
      }

      // Get deposit/withdrawal transaction data
      final depositData =
          await CommonMethod().getDepositTransactionDetail(page);
      if (depositData.status == "success") {
        setState(() {
          transactions = depositData.data.details;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      appBar: CommonAppBar.basic(
        title: 'Transaction Record',
      ),
      body: RefreshIndicator(
        color: const Color(0xFFF0B90B), // Binance yellow
        backgroundColor: const Color(0xFF161A1E),
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Balance Card with Binance style
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                    const Text(
                      'Total Balance',
                      style: TextStyle(
                        color: Color(0xFF848E9C), // Binance gray text
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        isLoading
                            ? Container(
                                width: 100,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              )
                            : Text(
                                '${totalBalance.toStringAsFixed(4)} $currentCurrency',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0B90B).withOpacity(
                                0.1), // Binance yellow with opacity
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Hide',
                            style: TextStyle(
                              color: Color(0xFFF0B90B), // Binance yellow
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Estimated Value',
                      style: TextStyle(
                        color: Color(0xFF848E9C), // Binance gray text
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '≈ ${totalBalance.toStringAsFixed(2)} USD',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons in Binance style
              // Container(
              //   margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              //   padding: const EdgeInsets.all(16),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFF1E2026), // Binance card background
              //     borderRadius: BorderRadius.circular(12),
              //     border: Border.all(color: const Color(0xFF2A2D35), width: 1),
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: [
              //       _buildActionButton(
              //         icon: Icons.arrow_upward,
              //         label: "Deposit",
              //         onTap: () {
              //           Navigator.push(
              //             context,
              //             MaterialPageRoute(builder: (context) => const Deposit()),
              //           );
              //         },
              //       ),
              //       _buildActionButton(
              //         icon: Icons.arrow_downward,
              //         label: "Withdraw",
              //         onTap: () {
              //           Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (context) => Withdrawal(
              //                 balance: totalBalance.toStringAsFixed(4),
              //               ),
              //             ),
              //           );
              //         },
              //       ),
              //       _buildActionButton(
              //         icon: Icons.arrow_forward,
              //         label: "Transfer",
              //         onTap: () {
              //           Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (context) => Transfer(
              //                 balance: totalBalance.toStringAsFixed(4),
              //               ),
              //             ),
              //           );
              //         },
              //       ),
              //       _buildActionButton(
              //         icon: Icons.swap_horiz,
              //         label: "Swap",
              //         onTap: () {
              //           Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (context) => Swap(
              //                 balance: totalBalance.toStringAsFixed(4),
              //               ),
              //             ),
              //           );
              //         },
              //       ),
              //     ],
              //   ),
              // ),

              // Transaction History Header in Binance style
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                width: double.infinity,
                color: const Color(0xFF161A1E), // Binance section header color
                child: const Text(
                  'Transaction History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Transaction filters in Binance style
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xFF1E2026), // Binance card background
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(
                              0xFF2B3139), // Binance input background
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: Color(0xFF848E9C),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Search',
                              style: TextStyle(
                                color: Color(0xFF848E9C),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF2B3139), // Binance input background
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Filter',
                            style: TextStyle(
                              color: Color(0xFF848E9C),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.filter_list,
                            color: Color(0xFF848E9C),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Recent Transactions Section
              Container(
                color: const Color(0xFF1E2026), // Binance card background
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: isLoading
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFFF0B90B)),
                          ),
                        ),
                      )
                    : _buildRecentTransactions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2B3139), // Binance button background
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFF0B90B), // Binance yellow
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF848E9C), // Binance gray text
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.receipt_long,
                color: Color(0xFF848E9C),
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'No transactions found',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your transaction history will appear here',
                style: TextStyle(
                  color: Color(0xFF848E9C),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var transaction in transactions)
          _buildTransactionItem(
            type: transaction.cr != "0" ? 'Deposit' : 'Withdrawal',
            amount: transaction.cr != "0"
                ? double.tryParse(transaction.cr) ?? 0.0
                : double.tryParse(transaction.dr) ?? 0.0,
            date: transaction.createdDate,
            status: transaction.status?.toString() ?? 'Pending',
          ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required String type,
    required double amount,
    required DateTime date,
    required String status,
  }) {
    final isDeposit = type == 'Deposit';
    final statusColor = status == 'Completed'
        ? const Color(0xFF0ECB81)
        : const Color(0xFFF0B90B);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2026), // Binance card background
        border: Border(
            bottom: BorderSide(color: const Color(0xFF2A2D35), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDeposit
                  ? const Color(0xFF0ECB81).withOpacity(0.1)
                  : const Color(0xFFEA4335).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isDeposit ? Icons.arrow_upward : Icons.arrow_downward,
              color:
                  isDeposit ? const Color(0xFF0ECB81) : const Color(0xFFEA4335),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: const Color(0xFF848E9C), // Binance gray text
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isDeposit ? '+' : '-'}${amount.toStringAsFixed(4)} $currentCurrency',
                style: TextStyle(
                  color: isDeposit
                      ? const Color(0xFF0ECB81)
                      : const Color(0xFFEA4335),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
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
}
