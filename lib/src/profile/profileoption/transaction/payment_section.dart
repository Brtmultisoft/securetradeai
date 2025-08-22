import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/method/methods.dart';
import 'package:securetradeai/model/DeposittransactionModel.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';

import '../../../../Data/Api.dart';

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

  var detailList = [];
  // double totalBalance = 0.0;
  double totalAssetsincr = 0.0;
  var scrollController = ScrollController();
  bool updating = false;
  int count = 1;
  bool checkdata = false;
  Timer? timer;
  _getDetail() async {
    try {
      final data = await CommonMethod().getAssetTransactionDetail(count);
      if (data.status == "success") {
        if (data.data.details.isNotEmpty) {
          setState(() {
            if (count == 1) {
              // Clear the list if it's the first page
              detailList.clear();
            }
            // Add new items to the list
            detailList.addAll(data.data.details);
            totalBalance = double.tryParse(data.data.totalBalance) ?? 0.0;
            checkdata = false; // Reset checkdata when we have data
          });
        } else {
          if (count == 1) {
            showtoast("Data not found", context);
            setState(() {
              checkdata = true;
              detailList.clear(); // Clear list when no data
            });
          }
        }
      } else {
        // API returned error status
        if (count == 1) {
          showtoast(data.message, context);
          setState(() {
            checkdata = true;
            detailList.clear(); // Clear list on error
          });
        }
      }
    } catch (e) {
      // Exception occurred
      if (count == 1) {
        setState(() {
          checkdata = true;
          detailList.clear(); // Clear list on exception
        });
      }
      print(e);
    }
  }

  _getCurrency() async {
    var totalcurrency = await CommonMethod().getCurrency(0.0);
    if (mounted) {
      setState(() {
        totalAssetsincr = totalBalance * totalcurrency;
      });
    }
  }

  _fatchdata() async {
    await _getDetail();
    await _getCurrency();
    await http.get(Uri.parse("${mainUrl}deposit_autapprove.php"));
    await http.get(Uri.parse("${mainUrl}withdraw_autoapprove.php"));
  }

  checkUpdate() async {
    showLoading(context);
    var scrollposition = scrollController.position;
    if (scrollposition.pixels == scrollposition.maxScrollExtent) {
      setState(() {
        count++;
      });
      await _getDetail();
    }
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    count = 1; // Reset count when screen initializes
    _loadData();
    _fatchdata(); // Load transaction history data
    timer = Timer.periodic(const Duration(minutes: 2), (Timer t) {
      count = 1; // Reset count when refreshing
      _fatchdata();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    print('🔄 PaymentSection: Starting _loadData...');
    try {
      setState(() {
        isLoading = true;
      });
      print('🔄 PaymentSection: Set isLoading = true');

      // Get user profile data which includes balance
      print('🔄 PaymentSection: Getting user data...');
      final userData = await CommonMethod().getMineData();
      if (userData.status == "success" && userData.data.isNotEmpty) {
        setState(() {
          totalBalance = double.tryParse(userData.data[0].balance) ?? 0.0;
        });
        print('✅ PaymentSection: User data loaded, balance: $totalBalance');
      } else {
        print('❌ PaymentSection: User data failed: ${userData.status}');
      }

      // Get deposit/withdrawal transaction data
      try {
        print('🔄 PaymentSection: Getting deposit data...');
        final depositData =
            await CommonMethod().getDepositTransactionDetail(page);
        if (depositData.status == "success") {
          setState(() {
            transactions = depositData.data.details;
          });
          print(
              '✅ PaymentSection: Deposit data loaded, ${transactions.length} transactions');
        } else {
          print('❌ PaymentSection: Deposit data error: ${depositData.message}');
          setState(() {
            transactions = []; // Set empty list if no data
          });
        }
      } catch (depositError) {
        print('❌ PaymentSection: Error getting deposit data: $depositError');
        setState(() {
          transactions = []; // Set empty list on error
        });
      }
    } catch (e) {
      print('❌ PaymentSection: Error loading data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
      print('✅ PaymentSection: Set isLoading = false, loading complete');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF0D1321);
    const Color mediumBlue = Color(0xFF1A2235);
    const Color lightBlue = Color(0xFF4A6FA5);

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
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //       horizontal: 8, vertical: 4),
                        //   decoration: BoxDecoration(
                        //     color: const Color(0xFFF0B90B).withOpacity(
                        //         0.1), // Binance yellow with opacity
                        //     borderRadius: BorderRadius.circular(4),
                        //   ),
                        //   child: const Text(
                        //     'Hide',
                        //     style: TextStyle(
                        //       color: Color(0xFFF0B90B), // Binance yellow
                        //       fontSize: 12,
                        //       fontWeight: FontWeight.w500,
                        //     ),
                        //   ),
                        // ),
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
              // Container(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //   width: double.infinity,
              //   color: const Color(0xFF161A1E), // Binance section header color
              //   child: const Text(
              //     'Transaction History',
              //     style: TextStyle(
              //       color: Colors.white,
              //       fontSize: 16,
              //       fontWeight: FontWeight.w500,
              //     ),
              //   ),
              // ),

              // Transaction filters in Binance style
              // Container(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //   color: const Color(0xFF1E2026), // Binance card background
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: Container(
              //           padding: const EdgeInsets.symmetric(
              //               horizontal: 12, vertical: 8),
              //           decoration: BoxDecoration(
              //             color: const Color(
              //                 0xFF2B3139), // Binance input background
              //             borderRadius: BorderRadius.circular(4),
              //           ),
              //           child: Row(
              //             children: [
              //               const Icon(
              //                 Icons.search,
              //                 color: Color(0xFF848E9C),
              //                 size: 20,
              //               ),
              //               const SizedBox(width: 8),
              //               const Text(
              //                 'Search',
              //                 style: TextStyle(
              //                   color: Color(0xFF848E9C),
              //                   fontSize: 14,
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //       const SizedBox(width: 12),
              //       Container(
              //         padding: const EdgeInsets.symmetric(
              //             horizontal: 12, vertical: 8),
              //         decoration: BoxDecoration(
              //           color:
              //               const Color(0xFF2B3139), // Binance input background
              //           borderRadius: BorderRadius.circular(4),
              //         ),
              //         child: Row(
              //           children: [
              //             const Text(
              //               'Filter',
              //               style: TextStyle(
              //                 color: Color(0xFF848E9C),
              //                 fontSize: 14,
              //               ),
              //             ),
              //             const SizedBox(width: 4),
              //             const Icon(
              //               Icons.filter_list,
              //               color: Color(0xFF848E9C),
              //               size: 20,
              //             ),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              // // Recent Transactions Section
              // Container(
              //   color: const Color(0xFF1E2026), // Binance card background
              //   width: double.infinity,
              //   padding: const EdgeInsets.symmetric(vertical: 8),
              //   child: isLoading
              //       ? Center(
              //           child: Padding(
              //             padding: const EdgeInsets.all(24.0),
              //             child: CircularProgressIndicator(
              //               valueColor: AlwaysStoppedAnimation<Color>(
              //                   const Color(0xFFF0B90B)),
              //             ),
              //           ),
              //         )
              //       : _buildRecentTransactions(),
              // ),

              // Transaction history
              Container(
                height: 300,
                child: RefreshIndicator(
                  color: lightBlue,
                  backgroundColor: mediumBlue,
                  onRefresh: () async {
                    setState(() {
                      count = 1;
                      detailList.clear();
                    });
                    await _fatchdata();
                    return Future.value();
                  },
                  child: listdata(),
                ),
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

  String _typeLabelFor(dynamic tx) {
    final t = (tx.type ?? '').toString().toLowerCase();
    final d = (tx.descr ?? '').toString().toLowerCase();
    final h = (tx.hashkey ?? '').toString().toLowerCase();

    final isSwap = t.contains('swap') ||
        d.contains('swap') ||
        h.contains('swap') ||
        ((t == 'tfr' || t.contains('transfer')) &&
            (d.contains('gas') ||
                d.contains('gaswallet') ||
                d.contains('gas_wallet') ||
                h.contains('gas')));
    if (isSwap)
      return (d.contains('gas') || h.contains('gas'))
          ? 'Swap to Gas Wallet'
          : 'Swap';

    if (t == 'tfr' || t.contains('transfer')) return 'Transfer';
    if (t.contains('dep')) return 'Deposit';
    if (t.contains('with') || t.contains('wd')) return 'Withdrawal';
    return 'Transaction';
  }

  void _showTransactionDetails(dynamic transaction) {
    final bool isCredit = transaction.dr == "0";
    final String amount = isCredit ? transaction.cr : transaction.dr;
    final String typeLabel = _typeLabelFor(transaction);
    final String desc = (transaction.descr ?? '').toString();
    final String dateStr = transaction.createdDate.toString();
    final String status = (transaction.status ?? '').toString();
    final String hash = (transaction.hashkey ?? '').toString();

    String fromText = 'N/A';
    String toText = 'N/A';
    if (typeLabel.startsWith('Swap') || typeLabel == 'Transfer') {
      final lower = desc.toLowerCase();
      if (lower.contains('from') && lower.contains('to')) {
        final parts = lower.split('to');
        if (parts.length >= 2) {
          fromText = parts[0].replaceAll('from', '').trim();
          toText = parts[1].trim();
        }
      }
    }

    showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1A2235),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long, color: Colors.white70),
                    const SizedBox(width: 8),
                    Text(typeLabel,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const Spacer(),
                    Text(dateStr.substring(0, 16),
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12))
                  ],
                ),
                const SizedBox(height: 12),
                _kv('Amount', '${isCredit ? '+' : '-'}$amount USD'),
                _kv('Status', status.isEmpty ? '—' : status),
                _kv('Type', typeLabel),
                if (typeLabel.startsWith('Swap') ||
                    typeLabel == 'Transfer') ...[
                  _kv('From', fromText),
                  _kv('To', toText),
                ],
                if (hash.isNotEmpty) _kv('Hash/Ref', hash),
                if (desc.isNotEmpty) _kv('Description', desc),
                const SizedBox(height: 8),
              ],
            ),
          );
        });
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 110,
              child: Text(k,
                  style: const TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.w500))),
          const SizedBox(width: 8),
          Expanded(
              child: Text(v,
                  style: const TextStyle(color: Colors.white, fontSize: 14))),
        ],
      ),
    );
  }

  Widget listdata() {
    // Theme colors
    const Color darkBlue = Color(0xFF0D1321);
    const Color mediumBlue = Color(0xFF1A2235);
    const Color lightBlue = Color(0xFF4A6FA5);

    if (detailList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4A6FA5)),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (noti) {
        if (noti is ScrollEndNotification) {
          checkUpdate();
        }
        return true;
      },
      child: checkdata
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/img/logo.png",
                    height: 120,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No transactions found",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Section title
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Transaction History",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (c, i) {
                      final transaction = detailList[i];
                      final isCredit = transaction.dr == "0";
                      final amount = isCredit ? transaction.cr : transaction.dr;
                      final formattedDate =
                          transaction.createdDate.toString().substring(0, 16);
                      final typeLabel = _typeLabelFor(transaction);

                      return InkWell(
                        onTap: () => _showTransactionDetails(transaction),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: mediumBlue,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF2A3A5A),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Transaction icon
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: darkBlue,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      isCredit
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                      color:
                                          isCredit ? Colors.green : Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Transaction details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        typeLabel,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if ((transaction.descr ?? '')
                                          .toString()
                                          .isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2.0),
                                          child: Text(
                                            transaction.descr!,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          color: Color(0xFF8A9CC0),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Amount
                                Text(
                                  "${isCredit ? '+' : '-'}$amount USD",
                                  style: TextStyle(
                                    color: isCredit ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: detailList.length,
                  ),
                ),

                if (updating)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Color(0xFF4A6FA5)),
                  )
              ],
            ),
    );
  }
}
