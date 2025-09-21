import 'dart:async';
import 'package:flutter/material.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/model/DeposittransactionModel.dart'
    as DepositTransactionModelAlias;
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/profile/profileoption/assets/transfer.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';
import 'package:securetradeai/model/deposit_history_model.dart'
    as deposit_history_model;
import 'package:securetradeai/src/widget/lottie_loading_widget.dart';
import '../../../../method/methods.dart';

class DepositTransaction extends StatefulWidget {
  const DepositTransaction({Key? key}) : super(key: key);

  @override
  State<DepositTransaction> createState() => _DepositTransactionState();
}

class _DepositTransactionState extends State<DepositTransaction> {
  List<DepositTransactionModelAlias.Detail> depositList = [];
  bool loading = false;
  bool checkdata = false;
  bool hasMoreData = true;
  int page = 1;
  int itemsPerPage = 10; // Number of items per page
  var scrollController = ScrollController();
  Timer? timer;
  double totalBalance = 0.0;
  String userId = commonuserId; // Get user ID from global variable

  // Deposit history state
  List<deposit_history_model.DepositTransaction> depositHistory = [];
  bool isLoadingHistory = false;
  bool showHistory = false;
  int historyPage = 1;
  final int historyPageSize = 10;
  String historyTotalBalance = "0.00";

  @override
  void initState() {
    super.initState();
    _getDepositDetail();
    timer = Timer.periodic(
        const Duration(minutes: 2), (Timer t) => _getDepositDetail());

    // Add scroll listener
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.8) {
        if (!loading && hasMoreData) {
          _loadMoreDeposits();
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    scrollController.dispose(); // Dispose the controller
    super.dispose();
  }

  Future<void> _loadDepositHistory({bool isRefresh = false}) async {
    if (isRefresh) {
      historyPage = 1;
      depositHistory.clear();
    }

    setState(() {
      isLoadingHistory = true;
    });

    try {
      final response = await CommonMethod().getDepositHistory(
        page: historyPage,
        size: historyPageSize,
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          if (isRefresh) {
            depositHistory = response.data!.details;
          } else {
            depositHistory.addAll(response.data!.details);
          }
          historyTotalBalance = response.data!.totalBalance;
          isLoadingHistory = false;
        });
      } else {
        setState(() {
          isLoadingHistory = false;
        });
        // Show error message if needed
      }
    } catch (e) {
      setState(() {
        isLoadingHistory = false;
      });
      print("Error loading deposit history: $e");
    }
  }

  // Fetch the deposit transaction details
  _getDepositDetail() async {
    if (loading) return;

    setState(() {
      loading = true;
    });
    try {
      // Get user profile data which includes balance
      final mineResponse = await CommonMethod().getMineData();

      if (mineResponse.status == "success" && mineResponse.data.isNotEmpty) {
        // Get the balance from the profile data
        final userData = mineResponse.data[0];
        totalBalance = double.tryParse(userData.balance) ?? 100.0;
      } else {
        // If API fails, use a default value for demo
        totalBalance = 100.0;
      }

      // Get deposit transactions
      final response = await CommonMethod().getDepositTransactionDetail(page);
      if (response.status == "success") {
        final transactionData = response.data.details;

        setState(() {
          // Clear the list if it's the first page
          if (page == 1) {
            depositList.clear();
          }

          // Add new transactions to the list and sort by date (newest first)
          depositList.addAll(transactionData);

          // Sort the list by date (newest first)
          depositList.sort((a, b) => b.createdDate.compareTo(a.createdDate));

          // Check if we have more data based on the response
          hasMoreData = transactionData.length >= itemsPerPage;

          if (depositList.isEmpty) {
            checkdata = true;
          }
        });
      } else {
        // Handle specific error messages
        if (response.message.contains("not found") ||
            response.message.contains("No data")) {
          setState(() {
            checkdata = true;
            depositList.clear();
          });
        } else {
          _showToast(response.message);
        }
        hasMoreData = false;
      }
    } catch (e) {
      setState(() {
        checkdata = true;
        depositList.clear();
      });
      hasMoreData = false;
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  _loadMoreDeposits() async {
    if (!loading && hasMoreData) {
      setState(() {
        page++;
      });
      await _getDepositDetail();

      // Make sure the list is sorted after loading more data
      setState(() {
        depositList.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      });
    }
  }

  // Utility to show toast messages
  void _showToast(String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Theme colors
    const Color darkBlue = Color(0xFF0D1321);
    const Color mediumBlue = Color(0xFF1A2235);
    const Color lightBlue = Color(0xFF4A6FA5);

    return SafeArea(
      child: Scaffold(
        backgroundColor: darkBlue,
        appBar: CommonAppBar.basic(
          title: 'Deposit Transactions',
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Balance card with transfer button
              Container(
                margin: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: mediumBlue,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 0,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Balance label and transfer button row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Current Balance",
                            style: TextStyle(
                              color: Color(0xFF8A9CC0),
                              fontSize: 14,
                            ),
                          ),
                          // Transfer button
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Transfer(balance: totalBalance),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0B90B),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF0B90B)
                                        .withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.send,
                                    color: Colors.black,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Transfer",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Balance amount with USD
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            totalBalance.toStringAsFixed(2),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text(
                              "USD",
                              style: TextStyle(
                                color: Color(0xFF8A9CC0),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded(
              //   child: RefreshIndicator(
              //     color: lightBlue,
              //     backgroundColor: mediumBlue,
              //     onRefresh: () async {
              //       setState(() {
              //         depositList.clear();
              //         page = 1;
              //         hasMoreData = true;
              //       });
              //       await _getDepositDetail();
              //       return Future.value();
              //     },
              //     child: listData(),
              //   ),
              // ),

              // Deposit History Section
              const SizedBox(height: 20),
              _buildHistoryToggleButton(),
              if (showHistory) ...[
                const SizedBox(height: 20),
                _buildDepositHistorySection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Widget listData() {
  //   // Theme colors
  //   const Color lightBlue = Color(0xFF4A6FA5);
  //
  //   if (loading && depositList.isEmpty) {
  //     return const Center(
  //         child: CircularProgressIndicator(color: Color(0xFF4A6FA5)));
  //   }
  //
  //   if (checkdata && depositList.isEmpty) {
  //     return Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: const [
  //           Icon(
  //             Icons.account_balance_wallet_outlined,
  //             color: Colors.white54,
  //             size: 64,
  //           ),
  //           SizedBox(height: 16),
  //           Text(
  //             "No Deposit History Found",
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 18,
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //           SizedBox(height: 8),
  //           Text(
  //             "Your deposit transactions will appear here",
  //             style: TextStyle(
  //               color: Colors.white54,
  //               fontSize: 14,
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  //
  //   return Column(
  //     children: [
  //       // Section title
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //         child: Row(
  //           children: [
  //             Container(
  //               width: 4,
  //               height: 16,
  //               decoration: BoxDecoration(
  //                 color: lightBlue,
  //                 borderRadius: BorderRadius.circular(2),
  //               ),
  //             ),
  //             const SizedBox(width: 8),
  //             const Text(
  //               "Deposit History",
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 16,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //
  //       Expanded(
  //         child: ListView.builder(
  //           controller: scrollController,
  //           itemCount: depositList.length + (hasMoreData ? 1 : 0),
  //           itemBuilder: (context, index) {
  //             if (index == depositList.length) {
  //               return const Center(
  //                 child: Padding(
  //                   padding: EdgeInsets.all(8.0),
  //                   child: CircularProgressIndicator(color: Color(0xFF4A6FA5)),
  //                 ),
  //               );
  //             }
  //             final deposit = depositList[index];
  //             return depositCard(deposit);
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget depositCard(DepositTransactionModelAlias.Detail deposit) {
    // Theme colors
    const Color darkBlue = Color(0xFF0D1321);
    const Color mediumBlue = Color(0xFF1A2235);
    const Color lightBlue = Color(0xFF4A6FA5);

    // Determine colors and icons based on status
    Color statusColor;
    IconData statusIcon;
    String statusText = deposit.status ?? "Unknown";

    // Format date
    String formattedDate =
        "${deposit.createdDate.day}/${deposit.createdDate.month}/${deposit.createdDate.year} ${deposit.createdDate.hour}:${deposit.createdDate.minute.toString().padLeft(2, '0')}";

    switch (statusText.toLowerCase()) {
      case "confirm":
        statusColor = const Color(0xFF00C853);
        statusIcon = Icons.check_circle;
        break;
      case "pending":
        statusColor = lightBlue;
        statusIcon = Icons.pending;
        break;
      case "reject":
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: mediumBlue,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: statusColor.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status and amount
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: darkBlue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      statusIcon,
                      color: statusColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  deposit.cr != "0"
                      ? "+${deposit.cr} USD"
                      : "-${deposit.dr} USD",
                  style: TextStyle(
                    color: statusText.toLowerCase() == "confirm"
                        ? (deposit.cr != "0"
                            ? const Color(0xFF00C853)
                            : Colors.red)
                        : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Transaction details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  deposit.descr ?? "Description not available",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Transaction details in a grid
                _buildDetailRow("Transaction ID", "#${deposit.id}"),
                _buildDetailRow("Date", formattedDate),
                _buildDetailRow("Type", deposit.type ?? "N/A"),
                if (deposit.charges != "0")
                  _buildDetailRow("Charges", "${deposit.charges} USD"),

                // Show hashkey if available
                if (deposit.hashkey != null &&
                    deposit.hashkey.toString() != "null")
                  _buildDetailRow("Hash Key", deposit.hashkey.toString(),
                      isHashKey: true),

                // Show address if available
                if (deposit.address != null &&
                    deposit.address.toString() != "null")
                  _buildDetailRow("Address", deposit.address.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build detail rows
  Widget _buildDetailRow(String label, String value, {bool isHashKey = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                color: Color(0xFF8A9CC0),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: isHashKey
                ? Row(
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          // Copy to clipboard functionality would go here
                        },
                        child: const Icon(
                          Icons.copy,
                          color: Color(0xFF4A6FA5),
                          size: 16,
                        ),
                      ),
                    ],
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryToggleButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          setState(() {
            showHistory = !showHistory;
          });
          if (showHistory && depositHistory.isEmpty) {
            _loadDepositHistory(isRefresh: true);
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border:
                Border.all(color: TradingTheme.primaryAccent.withOpacity(0.5)),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                showHistory ? Icons.history_toggle_off : Icons.history,
                color: TradingTheme.primaryAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                showHistory ? "Hide Deposit History" : "View Deposit History",
                style: const TextStyle(
                  fontSize: 16,
                  color: TradingTheme.primaryAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepositHistorySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TradingTheme.primaryAccent.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TradingTheme.primaryAccent.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.history,
                      color: TradingTheme.primaryAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Deposit History",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => _loadDepositHistory(isRefresh: true),
                      child: const Icon(
                        Icons.refresh,
                        color: TradingTheme.primaryAccent,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                if (historyTotalBalance != "0.00") ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TradingTheme.primaryAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: TradingTheme.primaryAccent.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet,
                          color: TradingTheme.primaryAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Total Balance: ",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "$historyTotalBalance USDT",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Content
          if (isLoadingHistory)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: LottieLoadingWidget.medium(),
              ),
            )
          else if (depositHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: const [
                    Icon(
                      Icons.history,
                      color: Colors.white54,
                      size: 48,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No deposit history found",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            _buildHistoryList(),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: depositHistory.length,
        itemBuilder: (context, index) {
          final transaction = depositHistory[index];
          return _buildTransactionCard(transaction);
        },
      ),
    );
  }

  Widget _buildTransactionCard(
      deposit_history_model.DepositTransaction transaction) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TradingTheme.primaryAccent.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TradingTheme.primaryAccent.withOpacity(0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.all(0),
          backgroundColor: const Color(0xFF2A3A4A),
          collapsedBackgroundColor: const Color(0xFF2A3A4A),
          iconColor: const Color(0xFF4A6FA5),
          collapsedIconColor: TradingTheme.primaryAccent.withOpacity(0.5),
          title: Row(
            children: [
              Icon(
                transaction.typeIcon,
                color: transaction.typeColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${transaction.amount.toStringAsFixed(2)} USDT",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      transaction.type,
                      style: TextStyle(
                        color: transaction.typeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: transaction.statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: transaction.statusColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      transaction.status,
                      style: TextStyle(
                        color: transaction.statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.formattedDate,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            _buildDetailedTransactionInfo(transaction),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedTransactionInfo(
      deposit_history_model.DepositTransaction transaction) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF1A2A3A),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transaction Details Section
          _buildDetailSection(
            "Transaction Details",
            Icons.receipt_long,
            [
              _buildDetailRow("Transaction ID", "#${transaction.id}"),
              _buildDetailRow("User ID", transaction.userId),
              _buildDetailRow("Type", transaction.type),
              _buildDetailRow(
                  "Description",
                  transaction.descr.isNotEmpty
                      ? transaction.descr
                      : "No description"),
            ],
          ),

          const SizedBox(height: 16),

          // Amount Details Section
          _buildDetailSection(
            "Amount Details",
            Icons.monetization_on,
            [
              _buildDetailRow("Credit Amount", "${transaction.cr} USDT"),
              _buildDetailRow("Debit Amount", "${transaction.dr} USDT"),
              if (transaction.chargesAmount > 0)
                _buildDetailRow("Charges", "${transaction.charges} USDT"),
            ],
          ),

          const SizedBox(height: 16),

          // Additional Info Section
          // _buildDetailSection(
          //   "Additional Information",
          //   Icons.info_outline,
          //   [
          //     if (transaction.address != null && transaction.address!.isNotEmpty)
          //       _buildDetailRow("Address", transaction.address!),
          //     if (transaction.hashkey != null && transaction.hashkey!.isNotEmpty)
          //       _buildDetailRow("Hash Key", transaction.hashkey!, isHashKey: true),
          //     if (transaction.inCat != null && transaction.inCat!.isNotEmpty)
          //       _buildDetailRow("Category", transaction.inCat!),
          //   ],
          // ),

          const SizedBox(height: 16),

          // Timestamps Section
          _buildDetailSection(
            "Timestamps",
            Icons.access_time,
            [
              _buildDetailRow("Created Date", transaction.formattedDate),
              _buildDetailRow(
                  "Modified Date", _formatDate(transaction.modifiedDate)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
      String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color:  TradingTheme.primaryAccent, size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: TradingTheme.primaryAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1321).withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: TradingTheme.primaryAccent.withOpacity(0.1)),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }
}
