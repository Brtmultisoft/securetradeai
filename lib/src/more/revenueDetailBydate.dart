import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/src/Service/assets_service.dart';

import '../../Data/Api.dart';
import '../../method/methods.dart';

class RevenueDetailByDate extends StatefulWidget {
  const RevenueDetailByDate(
      {Key? key,
      this.date,
      this.today,
      this.cumulative,
      this.todaycurrentCurrency,
      this.cumulativecurrentCurrecny})
      : super(key: key);
  final date;
  final today;
  final cumulative;
  final todaycurrentCurrency;
  final cumulativecurrentCurrecny;
  @override
  _RevenueDetailByDateState createState() => _RevenueDetailByDateState();
}

class _RevenueDetailByDateState extends State<RevenueDetailByDate> {
  var getRevenueDetail = [];
  var assets;
  List temp = [];
  bool checkData = false;
  var finaldata = [];
  _getRevenueData() async {
    try {
      final data = await CommonMethod().getRevenueDetailByDate(widget.date);
      if (data.status == "success") {
        if (mounted) {
          setState(() {
            getRevenueDetail.addAll(data.data.details);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            checkData = true;
          });
        }
        showtoast(data.message, context);
      }
    } catch (e) {
      print(e);
    }
  }

  _getAssets() async {
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
        for (var element in getRevenueDetail) {
          // print(getRevenueDetail);
          if (element.cryptoPair == e['assets']) {
            if (mounted) {
              setState(() {
                finaldata.add({
                  'id': int.parse(element.id),
                  'orderno': element.originalOrderid,
                  'image': e['assets_img'],
                  'cryptopair': element.cryptoPair,
                  'exchange': element.exchanger,
                  'profit': element.profit,
                  'createtype': element.createdate,
                });
              });
            }
          }
        }
      }
    }
    if (mounted) {
      setState(() {
        finaldata.sort((a, b) => a["id"].compareTo(b["id"]));
        finaldata.sort((a, b) => b["id"].compareTo(a["id"]));
        // print(finaldata);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getRevenueData();
    _getAssets();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height * 0.50;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
              onTap: () {
                _getAssets();
              },
              child: Text(widget.date)),
        ),
        backgroundColor: bg,
        body: Column(
          children: [
            topHeader(widget.today, widget.cumulative),
            Expanded(
                child: getRevenueDetail.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(
                            color: securetradeaicolor),
                      )
                    :
                    // dummyBuilder()
                    ListView.builder(
                        itemCount: finaldata.length,
                        itemBuilder: (context, i) {
                          print(finaldata);
                          return Container(
                              margin: const EdgeInsets.only(
                                  left: 15, right: 15, top: 15),
                              height: 150,
                              decoration: BoxDecoration(
                                color: securetradeaicolor.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 15.0,
                                          backgroundImage: NetworkImage(
                                              finaldata[i]['image']),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Order No : " +
                                              finaldata[i]['orderno'],
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 16),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Sell Currency",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            finaldata[i]['cryptopair'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Exchange",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            finaldata[i]['exchange'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Profit",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                    text: double.parse(
                                                            finaldata[i]
                                                                ['profit'])
                                                        .toStringAsFixed(4),
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black)),
                                                const TextSpan(
                                                    text: ' USDT',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white70)),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Time",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            finaldata[i]['createtype']
                                                .toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ));
                        }))
          ],
        ),
      ),
    );
  }

  Widget dummyBuilder() {
    return ListView.builder(
        itemCount: temp.length,
        itemBuilder: (context, index) {
          return ListTile(
            trailing: Image.network(
              temp[index]['img'],
              height: 19,
            ),
            title: Text(
              temp[index]['name'],
              style: TextStyle(color: Colors.white),
            ),
          );
        });
  }

  Widget topHeader(String today, comulative) {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height * 0.25;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 10,
        ),
        Container(
          margin: EdgeInsets.only(right: 30, left: 30),
          width: double.infinity,
          height: categoryHeight,
          decoration: BoxDecoration(
            color: securetradeaicolor,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          child: Text("today_s_profit".tr,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: fontFamily,
                                  fontWeight: FontWeight.bold))),
                      Flexible(
                        child: Container(
                            child: Text("cumulative_profit".tr,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontFamily: fontFamily,
                                    fontWeight: FontWeight.bold))),
                      )
                    ]),
                SizedBox(
                  height: 5,
                ),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          child: Text("≈$today",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: fontFamily,
                              ))),
                      Flexible(
                        child: Container(
                            child: Text("≈$comulative",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: fontFamily,
                                ))),
                      )
                    ]),
                // SizedBox(
                //   height: 5,
                // ),
                // Container(
                //     child: Text("data_is_counted".tr,
                //         style: TextStyle(
                //           color: Colors.white,
                //           fontSize: 12,
                //           fontFamily: fontfamily,
                //         ))),
                SizedBox(
                  height: 5,
                ),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          child: Text(
                              currentCurrency == "null"
                                  ? "USD"
                                  : currentCurrency,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: fontFamily,
                              ))),
                      Flexible(
                        child: Container(
                            child: Text(
                                currentCurrency == "null"
                                    ? "USD"
                                    : currentCurrency,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: fontFamily,
                                ))),
                      )
                    ]),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          child: Text("≈${widget.todaycurrentCurrency}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: fontFamily,
                              ))),
                      Flexible(
                        child: Container(
                            child: Text("≈${widget.cumulativecurrentCurrecny}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: fontFamily,
                                ))),
                      )
                    ]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
