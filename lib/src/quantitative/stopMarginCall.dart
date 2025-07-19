import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:provider/provider.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/method/homepageProvider.dart';
import '../../model/repoModel.dart';
import '../homepage/Maintradesetting.dart';
import '../homepage/SubbinMode.dart';
import '../Service/assets_service.dart';

class StopMarginCall extends StatefulWidget {
  const StopMarginCall({Key? key, this.reffral}) : super(key: key);
  final reffral;

  @override
  State<StopMarginCall> createState() => _StopMarginCallState();
}

class _StopMarginCallState extends State<StopMarginCall> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Repo>(builder: (context, startStop, child) {
      return startStop.circledata
          ? Image.asset("assets/img/logo.png", height: 200)
          : exchanger != "Binance"
              ? Consumer<HomePageProvider>(builder: (context, list, child) {
                  return _display1Huobi(list.finalTransactionDataHuobi);
                })
              : ListView.builder(
                  itemCount: startStop.finalTransactionData.length,
                  itemBuilder: (cotext, index) {
                    bool a = double.parse(startStop.finalTransactionData[index]
                            ['priceChange'])
                        .isNegative;
                    var b = startStop.finalTransactionData[index]['symbol']
                        .toString();
                    // print(b.characters.takeLast(4)); // when get last 4 words
                    var finalsymble = b.replaceAll("USDT", "");
                    var finalavg;
                    bool checkavgPrice = false;
                    double currentprice = double.parse(
                        startStop.finalTransactionData[index]['price']);
                    double posqty = double.parse(
                        startStop.finalTransactionData[index]['pos_qty']);
                    double posMultiplyCurrntprice = posqty * currentprice;
                    var CalfinalAVG = posMultiplyCurrntprice -
                        double.parse(
                            startStop.finalTransactionData[index]['pos_amt']);
                    finalavg = CalfinalAVG;
                    checkavgPrice = CalfinalAVG.isNegative;
                    return Visibility(
                      visible: startStop.finalTransactionData[index]
                                  ['stockmargin'] !=
                              "0"
                          ? true
                          : false,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainTradeSetting(
                                        coinurl: startStop
                                                .finalTransactionData[index]
                                            ['coinurl'],
                                        reffralnno: widget.reffral,
                                        coinimg: startStop
                                                .finalTransactionData[index]
                                            ['asset_img'],
                                        compaircoinname: startStop
                                                .finalTransactionData[index]
                                            ['symbol'],
                                        finalCoinName: finalsymble,
                                      )));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            children: [
                              SizedBox(height: 5),
                              Container(
                                  decoration: BoxDecoration(
                                    color: securetradeaicolor.withOpacity(0.7),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                  width: double.infinity,
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        left: 10, right: 10, top: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                    radius: 15.0,
                                                    backgroundImage: startStop
                                                                        .finalTransactionData[
                                                                    index]
                                                                ['asset_img'] ==
                                                            null
                                                        ? const NetworkImage(
                                                            "https://securetradeai.com/assets/images/logo/logo2.png")
                                                        : NetworkImage(startStop
                                                                .finalTransactionData[
                                                            index]['asset_img'])),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                        child: Text(finalsymble,
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .white,
                                                                fontFamily:
                                                                    fontFamily,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))),
                                                    Container(
                                                        child: const Text(
                                                            "/USDT",
                                                            style: TextStyle(
                                                                fontSize: 10,
                                                                color: Colors
                                                                    .white,
                                                                fontFamily:
                                                                    fontFamily,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.white70)),
                                                width: 60,
                                                height: 25,
                                                child: Center(
                                                  child: Text(
                                                    startStop.finalTransactionData[
                                                                    index]
                                                                ['cycle'] ==
                                                            "0"
                                                        ? "Cycle"
                                                        : "One Shot",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                )),
                                            Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.white70)),
                                                width: 60,
                                                height: 25,
                                                child: Center(
                                                  child: Text(
                                                    startStop.finalTransactionData[
                                                            index]['type'] ??
                                                        "",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                )),
                                            Container(
                                                decoration: BoxDecoration(
                                                  color: checkavgPrice
                                                      ? Colors.red
                                                      : Colors.green,
                                                  border: Border.all(
                                                      color: Colors.white70),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(6)),
                                                ),
                                                width: 70,
                                                height: 25,
                                                child: Center(
                                                  child: Text(
                                                      double.parse(finalavg
                                                                  .toString())
                                                              .toStringAsFixed(
                                                                  4) +
                                                          "%",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                )),
                                          ],
                                        ),
                                        const Divider(
                                          color: Colors.grey,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 10),
                                          child: Row(children: <Widget>[
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'quantity'.tr,
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.white,
                                                        fontFamily: fontFamily,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                      text: " " +
                                                          startStop
                                                                  .finalTransactionData[
                                                              index]['qty'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          fontFamily:
                                                              fontFamily)),
                                                ],
                                              ),
                                            ),
                                          ]),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 10),
                                          child: Row(children: <Widget>[
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'price'.tr,
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.white,
                                                        fontFamily: fontFamily,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                      text: " : " +
                                                          startStop
                                                              .finalTransactionData[
                                                                  index]
                                                                  ['price']
                                                              .toString(),
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              fontFamily)),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  const TextSpan(
                                                      text: 'Increase' + " : ",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          fontFamily:
                                                              fontFamily)),
                                                  TextSpan(
                                                      text: startStop
                                                              .finalTransactionData[
                                                          index]['priceChange'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: a
                                                              ? Colors.red
                                                              : Colors.green,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              fontFamily)),
                                                ],
                                              ),
                                            )
                                          ]),
                                        )
                                      ],
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      ),
                    );
                  });
    });
  }

  Widget _display1Huobi(var _data) {
    return ListView.builder(
        itemCount: _data.length,
        itemBuilder: (cotext, index) {
          double increase = _data[index]['priceChange'];
          bool a = increase.isNegative;
          var b = _data[index]['symbol'].toString();
          var finalsymble = b.toUpperCase().replaceAll("USDT", "");
          double currentprice = _data[index]['price'];
          double avgprice = double.parse(_data[index]['avg_price']);
          var current_avg = currentprice - avgprice;
          var finalavg = current_avg / avgprice * 100;
          bool checkavgPrice = finalavg.isNegative;
          return Visibility(
            // visible: _data[index]['stock_margin'] != "0" ? true : false,
            child: InkWell(
              onTap: () {
                _data[index]['type'] == "WWM"
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainTradeSetting(
                                  checkNavigate: "Home",
                                  coinurl: _data[index]['chartimg'],
                                  reffralnno: widget.reffral,
                                  coinimg: _data[index]['asset_img'],
                                  compaircoinname: _data[index]['symbol'],
                                  finalCoinName: finalsymble,
                                )))
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubbinMode(
                                  id: "",
                                  checkNavigate: "Home",
                                  coinurl: _data[index]['chartimg'],
                                  reffralnno: widget.reffral,
                                  coinimg: _data[index]['asset_img'],
                                  compaircoinname: _data[index]['symbol'],
                                  finalCoinName: finalsymble,
                                )));
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    SizedBox(height: 5),
                    Container(
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: double.infinity,
                        child: Container(
                          margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                          radius: 15.0,
                                          backgroundImage: _data[index]
                                                      ['asset_img'] ==
                                                  null
                                              ? const NetworkImage(
                                                  "https://securetradeai.com/assets/images/logo/logo2.png")
                                              : NetworkImage(
                                                  _data[index]['asset_img'])),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                              child: Text(finalsymble,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                      fontFamily: fontFamily,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                          Container(
                                              child: const Text("/USDT",
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white,
                                                      fontFamily: fontFamily,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.white70)),
                                      width: 60,
                                      height: 25,
                                      child: Center(
                                        child: Text(
                                          _data[index]['cycle'] == "0"
                                              ? "Cycle"
                                              : "One Shot",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )),
                                  Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.white70)),
                                      width: 60,
                                      height: 25,
                                      child: Center(
                                        child: Text(
                                          _data[index]['type'] ?? "",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )),
                                  Container(
                                      decoration: BoxDecoration(
                                        color: checkavgPrice
                                            ? Colors.red
                                            : Colors.green,
                                        border:
                                            Border.all(color: Colors.white70),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(6)),
                                      ),
                                      width: 70,
                                      height: 25,
                                      child: Center(
                                        child: Text(
                                            double.parse(finalavg.toString())
                                                    .toStringAsFixed(4) +
                                                "%",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      )),
                                ],
                              ),
                              const Divider(
                                color: Colors.grey,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Row(children: <Widget>[
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'quantity'.tr,
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white,
                                              fontFamily: fontFamily,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                            text: " " + _data[index]['qty'],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontFamily: fontFamily)),
                                      ],
                                    ),
                                  ),
                                ]),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Row(children: <Widget>[
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'price'.tr,
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white,
                                              fontFamily: fontFamily,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                            text: " : " +
                                                _data[index]['price']
                                                    .toString(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                fontFamily: fontFamily)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                            text: 'Increase' + " : ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontFamily: fontFamily)),
                                        TextSpan(
                                            text: increase.toStringAsFixed(4),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: a
                                                    ? Colors.red
                                                    : Colors.green,
                                                fontSize: 14,
                                                fontFamily: fontFamily)),
                                      ],
                                    ),
                                  )
                                ]),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
