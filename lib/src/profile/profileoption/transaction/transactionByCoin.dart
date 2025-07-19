import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/data/strings.dart';
import '../../../../Data/Api.dart';

class TransactionByCoin extends StatefulWidget {
  const TransactionByCoin({Key? key, this.coinName}) : super(key: key);
  final coinName;
  @override
  _TransactionByCoinState createState() => _TransactionByCoinState();
}

class _TransactionByCoinState extends State<TransactionByCoin> {
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
            "crypto_pair": widget.coinName,
            "exchanger": exchanger,
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
          print(transactionrecorddata);
          return true;
        } else {
          showtoast(jsondata['message'], context);
          setState(() {
            checkData = true;
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
      } else {
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
                'averageprice': element['avg_price'],
                'name': element['crypto_pair'],
                'exchange': element['exchanger'],
                'trade_type': element['sell_or_buy'],
                'trade_amount': element['trade_amount'],
                'quantity': element['qty'],
                'time': element['createdate']
              });
            });
          }
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
      print(newcoin);
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
        appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: bg,
            title: Text(
              "transactionDetail".tr,
              style: TextStyle(color: Colors.black),
            )),
        body: RefreshIndicator(
            color: Colors.white,
            backgroundColor: bg,
            onRefresh: () {
              Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (a, b, c) => TransactionByCoin(),
                      transitionDuration: Duration(seconds: 0)));
              return Future.value(false);
            },
            child: checkData
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/img/logo.png"),
                      SizedBox(
                        height: 10,
                      ),
                      Text("No Data")
                    ],
                  ))
                : transactioncardDetail())

        // transactioncardDetail()
        );
  }

  Widget transactioncardDetail() {
    if (finaldata.isEmpty)
      return Center(child: CircularProgressIndicator(color: securetradeaicolor));
    return NotificationListener<ScrollNotification>(
      onNotification: (noti) {
        if (noti is ScrollEndNotification) {
          checkUpdate();
        }
        return true;
      },
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              physics: BouncingScrollPhysics(),
              itemBuilder: (c, i) {
                String b = finaldata[i]['name'];
                var finalsymble = b.replaceAll("USDT", "");
                return Container(
                  margin:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  height: 180,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 12.0, right: 15, top: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                                radius: 15.0,
                                backgroundImage:
                                    NetworkImage(finaldata[i]['image'])),
                            const SizedBox(width: 10),
                            Text(
                              finalsymble.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "-",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              finaldata[i]['exchange'].toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "-",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              finaldata[i]['mode'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Order Id',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              finaldata[i]['orderId'],
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Trade Type',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              finaldata[i]['trade_type'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: finaldata[i]['trade_type'] == "SELL"
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Trade Amount',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                      text: finaldata[i]['trade_amount'],
                                      style: TextStyle(color: Colors.white)),
                                  const TextSpan(
                                    text: ' USDT',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Fee',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  finaldata[i]['fee'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                Text(
                                  finaldata[i]['trade_type'] == "SELL"
                                      ? "USDT"
                                      : finaldata[i]['commission_assets'] ??
                                          "null",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Quantity',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                      text: finaldata[i]['quantity'],
                                      style: TextStyle(color: Colors.white)),
                                  TextSpan(
                                    text: " " + finalsymble,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'AVG Price',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                      text: finaldata[i]['averageprice'],
                                      style:
                                          const TextStyle(color: Colors.white)),
                                  // TextSpan(
                                  //   text: " " + finalsymble,
                                  //   style: TextStyle(
                                  //       fontWeight: FontWeight.bold,
                                  //       color: Colors.orange),
                                  // ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Time',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              finaldata[i]['time'],
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
              itemCount: finaldata.length,
            ),
          ),
          // if (updating)
          //   CircularProgressIndicator(
          //     color: Colors.white,
          //   )
        ],
      ),
    );
  }
}
