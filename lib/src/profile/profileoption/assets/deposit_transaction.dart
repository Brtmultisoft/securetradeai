import 'dart:async';

import 'package:flutter/material.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/model/DeposittransactionModel.dart'
    as DepositTransactionModelAlias;
import 'package:securetradeai/src/profile/profileoption/assets/transfer.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';

import '../../../../method/methods.dart';

class DepositTransaction extends StatefulWidget {
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
        if (response.message.contains("not found") || response.message.contains("No data")) {
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
        body: Column(
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
                                  color:
                                      const Color(0xFFF0B90B).withOpacity(0.3),
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

            Expanded(
              child: RefreshIndicator(
                color: lightBlue,
                backgroundColor: mediumBlue,
                onRefresh: () async {
                  setState(() {
                    depositList.clear();
                    page = 1;
                    hasMoreData = true;
                  });
                  await _getDepositDetail();
                  return Future.value();
                },
                child: listData(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget listData() {
    // Theme colors
    const Color lightBlue = Color(0xFF4A6FA5);

    if (loading && depositList.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF4A6FA5)));
    }

    if (checkdata && depositList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.white54,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              "No Deposit History Found",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Your deposit transactions will appear here",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                "Deposit History",
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
            itemCount: depositList.length + (hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == depositList.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Color(0xFF4A6FA5)),
                  ),
                );
              }
              final deposit = depositList[index];
              return depositCard(deposit);
            },
          ),
        ),
      ],
    );
  }

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
}
