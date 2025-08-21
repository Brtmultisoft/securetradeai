import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/Data/Api.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/profile/profileoption/assets/swap.dart';
import 'package:securetradeai/src/profile/profileoption/assets/transfer.dart';
import 'package:securetradeai/src/profile/profileoption/assets/withdrawal.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';

import '../../../../method/methods.dart';

class Assets extends StatefulWidget {
  @override
  State<Assets> createState() => _AssetsState();
}

class _AssetsState extends State<Assets> {
  var detailList = [];
  double totalBalance = 0.0;
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
          });
        } else {
          if (count == 1) {
            showtoast("Data not found", context);
            setState(() {
              checkdata = true;
            });
          }
        }
      } else {
        showtoast(data.message, context);
      }
    } catch (e) {
      setState(() {});
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
    _fatchdata();
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
          title: 'Transaction Record',
        ),
        body: Column(
          children: [
            // Balance card
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
                    // Balance label
                    const Text(
                      "Total Balance",
                      style: TextStyle(
                        color: Color(0xFF8A9CC0),
                        fontSize: 14,
                      ),
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

                    // Local currency value
                    if (totalAssetsincr > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "≈ ${totalAssetsincr.toStringAsFixed(2)} ${currentCurrency == "null" ? "USD" : currentCurrency}",
                          style: const TextStyle(
                            color: Color(0xFF8A9CC0),
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.arrow_downward,
                    label: "Withdrawal",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Withdrawal(
                            balance: totalBalance.toStringAsFixed(4),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.swap_horiz,
                    label: "Swap",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Swap(
                            balance: totalBalance.toStringAsFixed(4),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Transaction history
            Expanded(
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
    );
  }

  // Helper method to build action buttons
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    // Theme colors
    const Color mediumBlue = Color(0xFF1A2235);
    const Color lightBlue = Color(0xFF4A6FA5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: mediumBlue,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF2A3A5A),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: lightBlue,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabelFor(dynamic tx) {
    final t = (tx.type ?? '').toString().toLowerCase();
    final d = (tx.descr ?? '').toString().toLowerCase();
    final h = (tx.hashkey ?? '').toString().toLowerCase();

    final isSwap = t.contains('swap') || d.contains('swap') || h.contains('swap') || ((t == 'tfr' || t.contains('transfer')) && (d.contains('gas') || d.contains('gaswallet') || d.contains('gas_wallet') || h.contains('gas')));
    if (isSwap) return (d.contains('gas') || h.contains('gas')) ? 'Swap to Gas Wallet' : 'Swap';

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
                        style:
                            const TextStyle(color: Colors.white54, fontSize: 12))
                  ],
                ),
                const SizedBox(height: 12),
                _kv('Amount', '${isCredit ? '+' : '-'}$amount USD'),
                _kv('Status', status.isEmpty ? '—' : status),
                _kv('Type', typeLabel),
                if (typeLabel.startsWith('Swap') || typeLabel == 'Transfer') ...[
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
