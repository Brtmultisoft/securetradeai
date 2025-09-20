import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';
import 'package:http/http.dart' as http;
import 'package:rapidtradeai/data/strings.dart';
import '../../../../Data/Api.dart';

class Transaction extends StatefulWidget {
  const Transaction({Key? key}) : super(key: key);

  @override
  _TransactionState createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  // Binance theme colors
  final Color backgroundColor = Color(0xFF1E2329);
  final Color cardColor = Color(0xFF2B3139);
  final Color primaryColor = TradingTheme.secondaryAccent;
  final Color successColor = Color(0xFF2EBD85);
  final Color dangerColor = Color(0xFFF6465D);
  final Color textColor = Colors.white;
  final Color secondaryTextColor = Color(0xFF848E9C);
  final Color borderColor = Color(0xFF373C3F);

  var transactionrecorddata;
  var scrollController = ScrollController();
  var assets;
  bool updating = false;
  int count = 1;
  var finaldata = [];
  bool checkData = false;

  _getTransactionDetail(int page) async {
    try {
      final res = await http.post(Uri.parse(transactionrecord),
          body: jsonEncode({
            "user_id": commonuserId,
            "page": page.toString(),
            "size": "100"
          }));
      if (res.statusCode != 200) {
        showtoast("Serve Error", context);
      } else {
        var jsondata = jsonDecode(res.body);
        if (jsondata['status'] == "success") {
          if (mounted) {
            setState(() {
              transactionrecorddata = jsondata['data'];
            });
          }
          return true;
        } else {
          showtoast(jsondata['message'], context);
          setState(() {
            checkData = page > 1 ? false : true;
          });
          return false;
        }
      }
    } catch (e) {
      print(e);
    }
  }

  _getpriceData() async {
    final res = await http.get(Uri.parse(cryptoassets));
    var response = jsonDecode(res.body);
    if (mounted) {
      setState(() {
        assets = response['data'];
      });
      _commonMethod();
    }
  }

  _commonMethod() {
    for (var e in assets) {
      if (checkData) {
        print('no data');
        return;
      }
      for (var element in transactionrecorddata) {
        if (element['crypto_pair'] == e['assets']) {
          setState(() {
            finaldata.add({
              'id': int.parse(element['id']),
              'commission_assets': element['commission_assets'],
              'fee': element['commission_price'],
              'orderId': element['original_orderid'],
              'mode': element['mode'],
              'image': e['assets_img'],
              'name': element['crypto_pair'],
              'exchange': element['exchanger'],
              'trade_type': element['sell_or_buy'],
              'trade_amount': element['trade_amount'],
              'quantity': element['qty'],
              'rate': element['current_price'],
              'time': element['createdate']
            });
          });
        }
      }
    }
    setState(() {
      finaldata.sort((a, b) => a["id"].compareTo(b["id"]));
      finaldata.sort((a, b) => b["id"].compareTo(a["id"]));
    });
  }

  checkUpdate() async {
    setState(() {
      updating = true;
    });
    showLoading(context);
    var scrollpositin = scrollController.position;
    if (scrollpositin.pixels == scrollpositin.maxScrollExtent) {
      setState(() {
        count++;
      });
      var newcoin = await _getTransactionDetail(count);
      if (newcoin) {
        _commonMethod();
      }
    }
    setState(() {
      updating = false;
    });
    Navigator.pop(context);
  }

  _getdata() async {
    await _getTransactionDetail(count);
    await _getpriceData();
  }

  @override
  void initState() {
    super.initState();
    _getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          "Transaction History",
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: textColor),
            onPressed: () {
              // TODO: Implement filter functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: secondaryTextColor, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Search transactions",
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Icon(Icons.qr_code_scanner, color: textColor),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: primaryColor,
              backgroundColor: cardColor,
              onRefresh: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (a, b, c) => Transaction(),
                    transitionDuration: Duration(seconds: 0),
                  ),
                );
                return Future.value(false);
              },
              child: checkData
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            color: secondaryTextColor,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No Transactions Found",
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : transactioncardDetail(),
            ),
          ),
        ],
      ),
    );
  }

  Widget transactioncardDetail() {
    if (finaldata.isEmpty)
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      );
    return NotificationListener<ScrollNotification>(
      onNotification: (noti) {
        if (noti is ScrollEndNotification) {
          checkUpdate();
        }
        return true;
      },
      child: ListView.builder(
        controller: scrollController,
        physics: BouncingScrollPhysics(),
        itemBuilder: (c, i) {
          String b = finaldata[i]['name'];
          var finalsymble = b.replaceAll("USDT", "");
          final isBuy = finaldata[i]['trade_type'] == 'BUY';
          
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Image.network(
                        finaldata[i]['image'],
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        finalsymble,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isBuy ? successColor.withOpacity(0.1) : dangerColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          finaldata[i]['trade_type'],
                          style: TextStyle(
                            color: isBuy ? successColor : dangerColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quantity',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${finaldata[i]['quantity']} $finalsymble',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rate',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '\$${finaldata[i]['rate']}',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amount',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '\$${finaldata[i]['trade_amount']}',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: borderColor,
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: secondaryTextColor,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            finaldata[i]['time'],
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.receipt,
                            color: secondaryTextColor,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Order ID: ${finaldata[i]['orderId']}',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
