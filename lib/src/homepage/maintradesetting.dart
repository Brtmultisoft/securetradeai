import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rapidtradeai/Data/Api.dart';
import 'package:rapidtradeai/data/strings.dart';
import 'package:rapidtradeai/src/Homepage/tradesetting.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';
import 'package:rapidtradeai/src/homepage/SubbinMode.dart';
import 'package:rapidtradeai/src/profile/profileoption/APIBinding/huobi.dart';
import 'package:rapidtradeai/src/profile/profileoption/Transaction/payment_section.dart';
import 'package:rapidtradeai/src/tabscreen/tabscreen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Method/TradeSettingProvider.dart';
import '../../method/homepageProvider.dart';
import '../../model/repoModel.dart';
import '../profile/profileoption/Transaction/transaction.dart';

class MainTradeSetting extends StatefulWidget {
  final compaircoinname;
  final coinimg;
  final finalCoinName;
  final reffralnno;
  final coinurl;
  final checkNavigate;
  const MainTradeSetting(
      {Key? key,
      this.compaircoinname,
      this.coinimg,
      this.finalCoinName,
      this.reffralnno,
      this.coinurl,
      this.checkNavigate})
      : super(key: key);
  @override
  State<MainTradeSetting> createState() => _MainTradeSettingState();
}

class _MainTradeSettingState extends State<MainTradeSetting> {
  var quantutumdata = [];
  String currentprice = '0.0000';
  Timer? timer;
  String positionAmount = "0.0000";
  String avgprice = "0.0000";
  int numberofmarginCall = 0;
  double finalnumberofmargincall = 0.0;
  String positionQuantity = "0.0";
  bool isAPIcalled = false;
  // String firstby = "0.0";
  // String magincall = "0.0";

  // String earingcallback = "0.0";
  // String buyincallback = "0.0";
  int margincall = 0;
  double returnrate = 0.0;
  bool checkavgPrice = false;
  // var martinConfig;
  int cycle = 0;
  var buttonstatus;
  int start_or_stop_margin = 0;
  double lastAVGPrice = 0.00;
  double finalCMTP = 0.0;
  double finalTPTP = 0.0;
  bool checkCMTP = false;
  bool checkTPTP = false;
  Future _getquantitumData() async {
    if (exchanger == "null" || exchanger == "Binance") {
      if (widget.checkNavigate == "Home") {
        final bannerdata =
            Provider.of<HomePageProvider>(context, listen: false);
        _commonMethod(bannerdata.homePageTxnRecords);
      } else {
        final _getQuantitive = Provider.of<Repo>(context, listen: false);
        _commonMethod(_getQuantitive.quantutumdata);
      }
    } else {
      if (widget.checkNavigate == "Home") {
        final bannerdata =
            Provider.of<HomePageProvider>(context, listen: false);
        _commonMethod(bannerdata.huobidata);
      } else {
        final Huobi = Provider.of<Repo>(context, listen: false);
        _commonMethod(Huobi.huobiAssets);
      }
    }
  }

  _commonMethod(var pricelist) {
    if (exchanger == "null" || exchanger == "Binance") {
      for (var p in pricelist) {
        if (p['symbol'] == widget.compaircoinname) {
          setState(() {
            currentprice = double.parse(p['lastPrice']).toStringAsFixed(18);
          });
          break;
        }
      }
    } else {
      if (widget.checkNavigate != "Home") {
        for (var p in pricelist) {
          if (p['symbol'] == widget.compaircoinname) {
            double a = p['close'];
            setState(() {
              currentprice = a.toStringAsFixed(18);
            });
            break;
          }
        }
      } else {
        for (var p in pricelist) {
          if (p['symbol'] == widget.compaircoinname.toString().toLowerCase()) {
            double a = p['close'];
            setState(() {
              currentprice = a.toStringAsFixed(18);
            });
            break;
          }
        }
      }
    }
    _returnRate();
    _checkAutoSell();
  }

  _returnRate() {
    double currentPrice = double.parse(currentprice);
    double posQty = double.parse(positionQuantity);
    double avgPrice = double.parse(avgprice);

    if (posQty > 0 && avgPrice > 0) {
      // Current position value
      double currentValue = posQty * currentPrice;
      // Initial position value
      double initialValue = posQty * avgPrice;
      // Calculate P/L
      double pnl = currentValue - initialValue;

      setState(() {
        returnrate = pnl;
        checkavgPrice = pnl < 0;
      });
    } else {
      setState(() {
        returnrate = 0.0;
        checkavgPrice = false;
      });
    }
  }

  _checkAutoSell() {
    double currentPrice = double.parse(currentprice);

    // Check if current price has reached take profit trigger price
    if (currentPrice >= finalTPTP) {
      _checkSell();
    }

    // Check if current price has reached margin call trigger price
    if (currentPrice <= finalCMTP) {
      _checkSell();
    }
  }

  Future _getquantitative_txn_record() async {
    setState(() {
      isAPIcalled = true;
    });
    final res = await http.post(Uri.parse(quantitative_txn_recordWWM),
        body: json.encode({
          "user_id": commonuserId,
          "exchange_type": exchanger,
          "assets": widget.compaircoinname
        }));
    print(res.body);
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      if (data['status'] == "success") {
        var finaldata = data['data'] as List;
        // print(finaldata);
        for (var e in finaldata) {
          if (mounted) {
            setState(() {
              positionAmount = e['pos_amt'] == null
                  ? "0.000"
                  : double.parse(e['pos_amt']).toString();
              var localavg = e['avg_price'] == null
                  ? "0.0000"
                  : e['avg_price'].toString().replaceAll(",", "");
              avgprice = double.parse(localavg).toString();
              numberofmarginCall = e['no_margincall'] == null
                  ? 0
                  : int.parse(e['no_margincall']);
              positionQuantity = e['pos_qty'] == null
                  ? "0.000"
                  : double.parse(e['pos_qty']).toString();
              buttonstatus =
                  e['status'] == null ? null : int.parse(e['status']);
              cycle = int.parse(e['cycle']);
              start_or_stop_margin =
                  e['stock_margin'] == null ? 0 : int.parse(e['stock_margin']);
              lastAVGPrice = e['last_avgprice'] == null
                  ? 0.00
                  : double.parse(e['last_avgprice']);
              checkCMTP = e['margin_calldrop'] == "0" ? false : true;
              checkTPTP = e['wp_rasio'] == "0" ? false : true;
            });
          }
        }
        setState(() {
          isAPIcalled = false;
        });
      } else {
        print("data not found");
        setState(() {
          isAPIcalled = false;
        });
      }
    } else {
      setState(() {
        isAPIcalled = false;
      });
      showtoast("Server Error", context);
    }
  }

  _getdata() {
    final tradesettingfinal =
        Provider.of<TradeSettingProvider>(context, listen: false);
    tradesettingfinal.getTradeSetting(widget.compaircoinname);
  }

  _getTradeSetting() async {
    try {
      final res = await http.post(Uri.parse(tradesettingwwm),
          body: json.encode({
            "user_id": commonuserId,
            "exchange_type": exchanger,
            "assets_type": widget.compaircoinname
          }));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['status'] == "success") {
          switch (numberofmarginCall) {
            case 0:
              finalnumberofmargincall =
                  double.parse(data['data']['margin_drop_1']);
              break;
            case 1:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_2']);
              });
              break;
            case 2:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_3']);
              });
              break;
            case 3:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_4']);
              });
              break;
            case 4:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_5']);
              });
              break;
            case 5:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_6']);
              });
              break;
            case 6:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_7']);
              });
              break;
            case 7:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_8']);
              });
              break;
            case 8:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_9']);
              });
              break;
            case 9:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_10']);
              });
              break;
            case 10:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_11']);
              });
              break;
            case 11:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_12']);
              });
              break;
            case 12:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_13']);
              });
              break;
            case 13:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_14']);
              });
              break;
            case 14:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_15']);
              });
              break;
            case 15:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_16']);
              });
              break;
            case 16:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_17']);
              });
              break;
            case 17:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_18']);
              });
              break;
            case 18:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_19']);
              });
              break;
            case 19:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_20']);
              });
              break;
            case 20:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_21']);
              });
              break;
            case 21:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_22']);
              });
              break;
            case 22:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_23']);
              });
              break;
            case 23:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_24']);
              });
              break;
            case 24:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_25']);
              });
              break;
            case 25:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_26']);
              });
              break;
            case 26:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_27']);
              });
              break;
            case 27:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_28']);
              });
              break;
            case 28:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_29']);
              });
              break;
            case 29:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_30']);
              });
              break;
            case 30:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_31']);
              });
              break;
            case 31:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_32']);
              });
              break;
            case 32:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_33']);
              });
              break;
            case 33:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_34']);
              });
              break;
            case 34:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_35']);
              });
              break;
            case 35:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_36']);
              });
              break;
            case 36:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_37']);
              });
              break;
            case 37:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_38']);
              });
              break;
            case 38:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_39']);
              });
              break;
            case 39:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_40']);
              });
              break;
            case 40:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_41']);
              });
              break;
            case 41:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_42']);
              });
              break;
            case 42:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_43']);
              });
              break;
            case 43:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_44']);
              });
              break;
            case 44:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_45']);
              });
              break;
            case 45:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_46']);
              });
              break;
            case 46:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_47']);
              });
              break;
            case 47:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_48']);
              });
              break;
            case 48:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_49']);
              });
              break;
            case 49:
              setState(() {
                finalnumberofmargincall =
                    double.parse(data['data']['margin_drop_50']);
              });
              break;

            default:
              print('choose a different number!');
          }
        } else {
          showtoast(data['message'], context);
        }
      } else {
        print("Server Error");
      }
    } catch (e) {
      print(e);
    }
  }

  _sellorbyCalculation() {
    final tradesettingfinal =
        Provider.of<TradeSettingProvider>(context, listen: false);
    double CMTP = lastAVGPrice * finalnumberofmargincall / 100;
    setState(() => finalCMTP = lastAVGPrice - CMTP);
    double TPTP = double.parse(avgprice.toString()) *
        double.parse(tradesettingfinal.takeprofit) /
        100;
    setState(() => finalTPTP = double.parse(avgprice) + TPTP);
  }

  _fatchData() async {
    await _getdata();
    await _getquantitumData();
    await _getquantitative_txn_record();
    await _getTradeSetting();
    await _sellorbyCalculation();
  }

  @override
  void initState() {
    super.initState();
    _fatchData();
    timer = Timer.periodic(
        const Duration(seconds: 2), (Timer t) => _getquantitumData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Consumer<TradeSettingProvider>(
          builder: (context, tradesetting, child) {
        return Scaffold(
            bottomNavigationBar: Container(
              width: double.infinity,
              height: 40,
              margin: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          const BoxShadow(
                              offset: Offset(10, 10),
                              color: Colors.black38,
                              blurRadius: 20),
                          BoxShadow(
                              offset: Offset(
                                -10,
                                -10,
                              ),
                              color: Colors.white.withOpacity(0.85),
                              blurRadius: 20)
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          disabledForegroundColor:
                              Colors.transparent.withOpacity(0.38),
                          disabledBackgroundColor:
                              Colors.transparent.withOpacity(0.12),
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TradeSetting(
                                        coinname: widget.compaircoinname,
                                      )));
                        },
                        child: Center(
                          child: Text("trade_setting".tr,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.0, 1.0],
                          colors: [
                            primaryColor,
                            Colors.blue,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(10, 10),
                              color: Colors.black38,
                              blurRadius: 20),
                          BoxShadow(
                              offset: Offset(
                                -10,
                                -10,
                              ),
                              color: Colors.white.withOpacity(0.85),
                              blurRadius: 20),
                        ],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          disabledForegroundColor:
                              Colors.transparent.withOpacity(0.38),
                          disabledBackgroundColor:
                              Colors.transparent.withOpacity(0.12),
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          _start_or_pause(tradesetting.firstbuy.text,
                              tradesetting.martinConfig);
                        },
                        child: Center(
                            child: Text(
                                (buttonstatus == null &&
                                        double.parse(avgprice) <= 0)
                                    ? "start".tr
                                    : buttonstatus == 1 &&
                                            double.parse(avgprice) > 0
                                        ? "pause".tr
                                        : buttonstatus == 2 &&
                                                double.parse(avgprice) > 0
                                            ? "start".tr
                                            : "",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            appBar: AppBar(
              backgroundColor: bg,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back, color: Colors.black),
              ),
              title: Text(
                exchanger == "null" ? "Binance" : exchanger,
                style: TextStyle(color: Colors.black),
              ),
              actions: [
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PaymentSection()));
                      },
                      child: Text(
                        'transation_record'.tr,
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                          fontFamily: fontFamily,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: isAPIcalled
                ? Center(
                    child: CircularProgressIndicator(
                    color: rapidtradeaicolor,
                  ))
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                        ),
                        painter: HeaderCurvedContainer(),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            topHeader(),
                            SizedBox(height: 10),
                            Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              height: 200,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      offset: Offset(10, 10),
                                      color: Colors.black38,
                                      blurRadius: 20),
                                  BoxShadow(
                                      offset: Offset(
                                        -10,
                                        -10,
                                      ),
                                      color: Colors.white.withOpacity(0.85),
                                      blurRadius: 20)
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Container(
                                margin: EdgeInsets.only(left: 15, top: 15),
                                child: GridView.count(
                                    shrinkWrap: true,
                                    crossAxisCount: 3,
                                    padding: EdgeInsets.only(top: 10),
                                    childAspectRatio: lang != "ar"
                                        ? MediaQuery.of(context).size.width /
                                            (MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                3)
                                        : MediaQuery.of(context).size.width /
                                            (MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2.6),
                                    mainAxisSpacing: 1.5,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          showdailog(context);
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              "assets/img/cycle.png",
                                              height: 40,
                                              width: 40,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              cycle == 0
                                                  ? "cycle".tr
                                                  : "oneshot".tr,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: fontFamily),
                                            )
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _buy(context),
                                        child: Column(
                                          children: [
                                            Image.asset(
                                              "assets/img/click.png",
                                              height: 40,
                                              width: 40,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              "buy".tr,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: fontFamily),
                                            )
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _sell(context),
                                        child: Column(
                                          children: [
                                            Image.asset(
                                              "assets/img/sell.png",
                                              height: 40,
                                              width: 40,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              "Sell".tr,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: fontFamily),
                                            )
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          startStop(context);
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              start_or_stop_margin == 0
                                                  ? "assets/img/pause.png"
                                                  : "assets/img/start.png",
                                              height: 40,
                                              width: 40,
                                            ),
                                            const SizedBox(height: 5),
                                            Container(
                                              child: Center(
                                                child: Text(
                                                  start_or_stop_margin == 0
                                                      ? "stopMarginCall".tr
                                                      : "startmargincall".tr,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: fontFamily),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          final url = widget.coinurl ?? "";
                                          try {
                                            await launch(url);
                                          } catch (e) {
                                            print(e);
                                          }
                                        },
                                        child: Container(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              "assets/img/2.png",
                                              height: 40,
                                              width: 40,
                                            ),
                                            const SizedBox(height: 5),
                                            Container(
                                              child: const Center(
                                                child: Text(
                                                  "Chart",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: fontFamily),
                                                ),
                                              ),
                                            )
                                          ],
                                        )),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          cancelBot(context);
                                        },
                                        child: Container(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.cancel,
                                                size: 40, color: Colors.red),
                                            SizedBox(height: 5),
                                            Container(
                                              child: Center(
                                                child: Text(
                                                  "Cancel Bot",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: fontFamily),
                                                ),
                                              ),
                                            )
                                          ],
                                        )),
                                      ),
                                    ]),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            disc(),
                            // const SizedBox(
                            //   height: 5,
                            // ),
                            addionalOption(),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                                margin:
                                    const EdgeInsets.only(left: 10, right: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      15), //border corner radius
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey
                                          .withOpacity(0.5), //color of shadow
                                      spreadRadius: 5, //spread radius
                                      blurRadius: 7, // blur radius
                                      offset: const Offset(
                                          0, 2), // changes position of shadow
                                      //first paramerter of offset is left-right
                                      //second parameter is top to down
                                    ),
                                    //you can set more BoxShadow() here
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Column(
                                    children: [
                                      record(
                                        "assets/img/1.png",
                                        "first_buy_in_amount".tr,
                                        tradesetting.firstbuy.text,
                                        "assets/img/2.png",
                                        "margin_call_in_limit".tr,
                                        tradesetting.magincall.toString(),
                                      ),
                                      record(
                                        "assets/img/pie.png",
                                        "take_profit_ratio".tr,
                                        tradesetting.takeprofit,
                                        "assets/img/cycle.png",
                                        "earning_callback".tr,
                                        tradesetting.earingcallback,
                                      ),
                                      record(
                                        "assets/img/5.png",
                                        "margin_call_drop".tr,
                                        finalnumberofmargincall.toString(),
                                        "assets/img/2.png",
                                        "but_in_callback".tr,
                                        tradesetting.buy_in_callbakc.text,
                                      ),
                                    ],
                                  ),
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ));
      }),
    );
  }

  Future<void> cancelBot(
    BuildContext context,
  ) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.center,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            contentPadding: EdgeInsets.only(bottom: 10, left: 20, right: 10),
            title: Center(child: Text('Note :- ')),
            content: Container(
                margin: const EdgeInsets.only(top: 10),
                child: const Text("Are you sure? you want to Cancel Bot.")),
            actions: [
              Container(
                height: 25,
                width: 90,
                decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledForegroundColor:
                        Colors.transparent.withOpacity(0.38),
                    disabledBackgroundColor:
                        Colors.transparent.withOpacity(0.12),
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Center(
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                height: 25,
                width: 70,
                decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledForegroundColor:
                        Colors.transparent.withOpacity(0.38),
                    disabledBackgroundColor:
                        Colors.transparent.withOpacity(0.12),
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: _cancelBot,
                  child: const Center(
                    child: Text(
                      "Yes",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          );
        });
  }

  _cancelBot() async {
    showLoading(context);
    final res = await http.post(Uri.parse(resetBotwwm),
        body: jsonEncode({
          "user_id": commonuserId,
          "assets": widget.compaircoinname,
          "exchange_type": "Binance"
        }));
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      print(data);
      if (data['status'] == "success") {
        showtoast(data['message'], context);
        _getquantitative_txn_record();
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        showtoast("No Active BOT Found", context);
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } else {
      showtoast("Server Error", context);
      Navigator.pop(context);
    }
  }

  Future<void> _sell(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0))),
          content: StatefulBuilder(
            // You need this, notice the parameters below:
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                  height: 350,
                  margin: const EdgeInsets.only(top: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("Sell"),
                        const Divider(thickness: 0.3),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Position Amount"),
                            Text(positionAmount)
                          ],
                        ),
                        const Divider(thickness: 0.3),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("AVG Price"),
                            Text(double.parse(avgprice).toStringAsFixed(4))
                          ],
                        ),
                        Divider(thickness: 0.3),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Position Quantity"),
                            Text(positionQuantity)
                          ],
                        ),
                        const Divider(thickness: 0.3),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Current Price"),
                            Text(double.parse(currentprice).toStringAsFixed(4))
                          ],
                        ),
                        const Divider(thickness: 0.3),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Position Profit\nand loss"),
                            Text(returnrate.toString() == "Infinity"
                                ? "0.000"
                                : returnrate.toStringAsFixed(5) + r" $")
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: 40,
                                width: 70,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    disabledForegroundColor:
                                        Colors.transparent.withOpacity(0.38),
                                    disabledBackgroundColor:
                                        Colors.transparent.withOpacity(0.12),
                                    shadowColor: Colors.transparent,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Center(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 40,
                                width: 90,
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    disabledForegroundColor:
                                        Colors.transparent.withOpacity(0.38),
                                    disabledBackgroundColor:
                                        Colors.transparent.withOpacity(0.12),
                                    shadowColor: Colors.transparent,
                                  ),
                                  onPressed: _checkSell,
                                  child: const Center(
                                    child: Text(
                                      "Confirm",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ])
                      ],
                    ),
                  ));
            },
          ),
        );
      },
    );
  }

  _checkSell() async {
    try {
      showLoading(context);
      // var a = 1 / double.parse(currentprice);
      // var finalamount = double.parse(currentprice) * sellmanual;
      var bodydata = json.encode({
        "user_id": commonuserId,
        "type": exchanger,
        "crypto_pair": widget.compaircoinname,
        "amount": positionAmount.toString(),
        "profit_value": returnrate.toString()
      });
      print(bodydata);
      final res = await http.post(Uri.parse(APIsellmanualwwm), body: bodydata);
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print(data);
        if (data['status'] == "success") {
          showtoast(data['message'], context);
          Navigator.pop(context);
          Navigator.pop(context);
          _getquantitative_txn_record();
        } else {
          showtoast(data['message'], context);
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } else {
        showtoast("Server Error", context);
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
    }
  }

  Widget record(String imgpath, text, amt, imgpath2, disc2, amt2) {
    return Container(
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: Container(
                child: Row(
              children: [
                Image.asset(
                  imgpath,
                  height: 25,
                  width: 25,
                ),
                SizedBox(width: 5),
                Flexible(
                    child: Text(
                  text,
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
                // SizedBox(width: 5),
                Flexible(
                    child: Text(
                  "    $amt",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ))
              ],
            )),
          ),
          Expanded(
            child: Container(
                child: Row(
              children: [
                Image.asset(
                  imgpath2,
                  height: 25,
                  width: 25,
                ),
                SizedBox(width: 5),
                Flexible(
                    child: Text(
                  disc2,
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
                // SizedBox(width: 5),
                Flexible(
                    child: Text(
                  "  $amt2",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ))
              ],
            )),
          ),
        ],
      ),
    );
  }

  _start_or_pause(String firseBy, martinConfig) async {
    if (double.parse(avgprice) <= 0) {
      var finalamount = double.parse(firseBy) * 2;
      try {
        // print("buy");
        showLoading(context);
        Uri finalurl = Uri.parse(
            exchanger == "Binance" ? buymanualwwm : buyManualHuobiWWM);
        var bodyData = json.encode({
          "user_id": commonuserId,
          "type": exchanger,
          "crypto_pair": widget.compaircoinname,
          "amount": martinConfig != "0" ? finalamount.toString() : firseBy
        });
        print(bodyData);
        final res = await http.post(finalurl, body: bodyData);
        if (res.statusCode == 200) {
          var data = jsonDecode(res.body);
          if (data['status'] == "success") {
            showtoast(data['message'], context);
            _getquantitative_txn_record();
            Navigator.pop(context);
          } else {
            showtoast(data['message'], context);
            Navigator.pop(context);
          }
        } else {
          print("server error");
          Navigator.pop(context);
        }
      } catch (e) {
        print(e);
      }
    } else {
      showLoading(context);
      try {
        final res = await http.post(Uri.parse(openOrderStatuswwm),
            body: json.encode({
              "user_id": commonuserId,
              "exchange_type": exchanger,
              "assets": widget.compaircoinname,
              "status": buttonstatus == 1 ? "2" : "1"
            }));
        if (res.statusCode == 200) {
          var data = jsonDecode(res.body);
          if (data['status'] == "success") {
            showtoast(data['message'], context);
            _getquantitative_txn_record();
            Navigator.pop(context);
          } else {
            showtoast(data['message'], context);
            Navigator.pop(context);
          }
        } else {
          print("server error");
          Navigator.pop(context);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Widget addionalOption() {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height * 0.15; // uncomment
    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 10, right: 15, left: 15),
        height: categoryHeight,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                offset: Offset(10, 10), color: Colors.black38, blurRadius: 20),
            BoxShadow(
                offset: Offset(
                  -10,
                  -10,
                ),
                color: Colors.white.withOpacity(0.85),
                blurRadius: 20)
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.add_moderator_outlined),
                SizedBox(width: 5),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Call Margin Trigger Price ",
                      ),
                      TextSpan(
                        text: " < ${finalCMTP.toStringAsFixed(4)}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                checkCMTP ? Colors.green : rapidtradeaicolor),
                      ),
                    ],
                  ),
                ),
              ]),
              SizedBox(
                height: 10,
              ),
              Row(children: [
                Icon(Icons.ads_click_outlined),
                SizedBox(width: 5),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Take Profit Trigger Price ",
                      ),
                      TextSpan(
                        text: " > ${finalTPTP.toStringAsFixed(4)}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                checkTPTP ? Colors.green : rapidtradeaicolor),
                      ),
                    ],
                  ),
                ),
              ]),
            ],
          ),
        ));
  }

  Widget disc() {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height * 0.28; // uncomment
    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 10, right: 15, left: 15),
        height: categoryHeight,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                offset: Offset(10, 10), color: Colors.black38, blurRadius: 20),
            BoxShadow(
                offset: Offset(
                  -10,
                  -10,
                ),
                color: Colors.white.withOpacity(0.85),
                blurRadius: 20)
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Text("opration_reminder".tr,
                  style: TextStyle(
                      fontFamily: fontFamily, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 10,
              ),
              Text("opration_dec".tr,
                  style: TextStyle(
                    fontFamily: fontFamily,
                  )),
            ],
          ),
        ));
  }

  Future<void> _buy(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        var buyInputbox = TextEditingController();
        double newposPrice = 0.0;
        var newqty;
        double EAP = 0.000;
        double EHP = 0.000;
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0))),
          content: StatefulBuilder(
            // You need this, notice the parameters below:
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Buy"),
                    Divider(thickness: 0.3),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text("Position Amount"), Text(positionAmount)],
                    ),
                    Divider(thickness: 0.3),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("AVg Amount"),
                        Text(double.parse(avgprice).toStringAsFixed(4))
                      ],
                    ),
                    Divider(thickness: 0.3),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Position Quantity"),
                        Text(positionQuantity)
                      ],
                    ),
                    Divider(thickness: 0.3),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Current Price"),
                        Text(double.parse(currentprice).toStringAsFixed(4))
                      ],
                    ),
                    Divider(thickness: 0.3),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Position Profit\nand loss"),
                        Text(returnrate.toString() == "Infinity"
                            ? "0.0000"
                            : returnrate.toStringAsFixed(4))
                      ],
                    ),
                    Divider(thickness: 0.3),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Estimated Avg price"),
                        Text(EAP.toString() == "Infinity"
                            ? "0.00"
                            : EAP.toStringAsFixed(4))
                      ],
                    ),
                    Divider(thickness: 0.3),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Estimated holding\nprofit and loss"),
                        Text(EHP.toString() == "Infinity"
                            ? "0.00"
                            : EHP.toStringAsFixed(4))
                      ],
                    ),
                    Divider(thickness: 0.3),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Amount of margin call"),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xfff3f3f4),
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: TextField(
                                keyboardType: TextInputType.number,
                                controller: buyInputbox,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                onChanged: (v) {
                                  // setState(() => EAP = v);
                                  if (v == "") {
                                    print("no value");
                                  } else {
                                    newqty = double.parse(positionQuantity) +
                                        (1 /
                                            double.parse(currentprice) *
                                            double.parse(v));
                                    newposPrice = double.parse(positionAmount) +
                                        double.parse(buyInputbox.text);
                                    setState(() {
                                      EAP = newposPrice / newqty;
                                    });
                                    var estimatedHolding =
                                        double.parse(currentprice) - EAP;
                                    EHP = estimatedHolding / EAP;
                                  }
                                },
                              ),
                            ),
                          ),
                        )),
                        SizedBox(width: 20),
                        Container(
                          height: 50,
                          width: 70,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xfff3f3f4),
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Center(
                            child: Text(
                              "USDT",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 40,
                            width: 70,
                            decoration: BoxDecoration(
                                color: rapidtradeaicolor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                disabledForegroundColor:
                                    Colors.transparent.withOpacity(0.38),
                                disabledBackgroundColor:
                                    Colors.transparent.withOpacity(0.12),
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Center(
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 40,
                            width: 90,
                            decoration: BoxDecoration(
                                color: rapidtradeaicolor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                disabledForegroundColor:
                                    Colors.transparent.withOpacity(0.38),
                                disabledBackgroundColor:
                                    Colors.transparent.withOpacity(0.12),
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: () {
                                buyInputbox.text.isEmpty
                                    ? showtoast("Error", context)
                                    : _BuyManuall(buyInputbox.text);
                              },
                              child: const Center(
                                child: Text(
                                  "Confirm",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ])
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> startStop(
    BuildContext context,
  ) async {
    print(start_or_stop_margin);
    String finaltext = start_or_stop_margin == 0 ? "Stop" : "Start";
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.center,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            contentPadding: EdgeInsets.only(bottom: 10, left: 20, right: 10),
            title: Center(child: Text('Note :- ')),
            content: Container(
                margin: EdgeInsets.only(top: 10),
                child: Text("Are you sure? you want to $finaltext.")),
            actions: [
              Container(
                height: 25,
                width: 90,
                decoration: BoxDecoration(
                    color: rapidtradeaicolor,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledForegroundColor:
                        Colors.transparent.withOpacity(0.38),
                    disabledBackgroundColor:
                        Colors.transparent.withOpacity(0.12),
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Center(
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                height: 25,
                width: 70,
                decoration: BoxDecoration(
                    color: rapidtradeaicolor,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledForegroundColor:
                        Colors.transparent.withOpacity(0.38),
                    disabledBackgroundColor:
                        Colors.transparent.withOpacity(0.12),
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {
                    _start_or_stop_margin();
                  },
                  child: const Center(
                    child: Text(
                      "Yes",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          );
        });
  }

  Future<void> showdailog(
    BuildContext context,
  ) async {
    String finaltext = cycle != 0 ? "Cycle" : "One Shot";
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Container(
            child: AlertDialog(
              actionsAlignment: MainAxisAlignment.center,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0))),
              contentPadding: EdgeInsets.only(bottom: 10, left: 20, right: 10),
              title: Center(child: const Text('Note :- ')),
              content: Container(
                  margin: EdgeInsets.only(top: 10),
                  child:
                      Text("Are you sure? you want to change to $finaltext.")),
              actions: [
                Container(
                  height: 25,
                  width: 90,
                  decoration: BoxDecoration(
                      color: rapidtradeaicolor,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      disabledForegroundColor:
                          Colors.transparent.withOpacity(0.38),
                      disabledBackgroundColor:
                          Colors.transparent.withOpacity(0.12),
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Center(
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  height: 25,
                  width: 70,
                  decoration: BoxDecoration(
                      color: rapidtradeaicolor,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      disabledForegroundColor:
                          Colors.transparent.withOpacity(0.38),
                      disabledBackgroundColor:
                          Colors.transparent.withOpacity(0.12),
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () {
                      _one_shot_to_cycle();
                    },
                    child: const Center(
                      child: Text(
                        "Yes",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
          );
        });
  }

  Widget topHeader() {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height * 0.35;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: 5,
        ),
        Container(
          margin: EdgeInsets.only(right: 20, left: 20),
          width: double.infinity,
          height: categoryHeight,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          // decoration: const BoxDecoration(
          //     borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 25,
                        // width: 50,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.0, 1.0],
                              colors: [
                                primaryColor,
                                Colors.blue,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            disabledForegroundColor:
                                Colors.transparent.withOpacity(0.38),
                            disabledBackgroundColor:
                                Colors.transparent.withOpacity(0.12),
                            shadowColor: Colors.transparent,
                          ),
                          onPressed: () {
                            // _one_shot_to_cycle();
                          },
                          child: const Center(
                            child: Text(
                              "Whole Warehouse Mode",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 25,
                        // width: 50,
                        decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            disabledForegroundColor:
                                Colors.transparent.withOpacity(0.38),
                            disabledBackgroundColor:
                                Colors.transparent.withOpacity(0.12),
                            shadowColor: Colors.transparent,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Center(
                            child: Text(
                              "Sub-Bin Mode",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ]),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Material(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              height: 30,
                              width: 30,
                              child: Center(
                                  child: Image.network(
                                widget.coinimg,
                              )),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                widget.finalCoinName + "/",
                                style: TextStyle(
                                    fontFamily: fontFamily,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "USDT",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontFamily: fontFamily,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        // uncomment
                        width: 75,
                        height: 60,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Center(
                                  child: Text(positionAmount,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: fontFamily)),
                                ),
                              ),
                              Container(
                                child: Center(
                                  child: Text("position_amount".tr + "(USDT)",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontFamily: fontFamily)),
                                ),
                              ),
                            ],
                          ),
                        )),
                    Container(
                        width: 75,
                        height: 60,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Center(
                                  child: Text(avgprice,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: fontFamily)),
                                ),
                              ),
                              Container(
                                child: Center(
                                  child: Text("avgprice".tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontFamily: fontFamily)),
                                ),
                              ),
                            ],
                          ),
                        )),
                    Container(
                        width: 75,
                        height: 60,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(numberofmarginCall.toString(),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: fontFamily)),
                              Container(
                                child: Center(
                                  child: Text("number_off_call_margin".tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontFamily: fontFamily)),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        //uncomment
                        width: 75,
                        height: 80,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Text(positionQuantity,
                              Text(positionQuantity,
                                  maxLines: 2,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: fontFamily)),
                              Container(
                                child: Center(
                                  child: Text(
                                      "position_quantity".tr +
                                          "(${widget.finalCoinName})",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontFamily: fontFamily)),
                                ),
                              ),
                            ],
                          ),
                        )),
                    Container(
                        width: 75,
                        height: 80,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(currentprice,
                                  maxLines: 2,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: fontFamily)),
                              Container(
                                child: Center(
                                  child: Text("current_price".tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontFamily: fontFamily)),
                                ),
                              ),
                            ],
                          ),
                        )),
                    Container(
                        width: 75,
                        height: 80,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                  returnrate.toString() == "Infinity"
                                      ? "0.00"
                                      : returnrate.toStringAsFixed(3) + r" $",
                                  style: TextStyle(
                                      color: checkavgPrice
                                          ? Colors.red
                                          : Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: fontFamily)),
                              Container(
                                child: Center(
                                  child: Text("Floating Profit/Loss",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontFamily: fontFamily)),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  _BuyManuall(String amount) async {
    Uri finalurl =
        Uri.parse(exchanger == "Binance" ? buymanualwwm : buyManualHuobiWWM);
    if (double.parse(amount) < 15) {
      showtoast("minimum amount should be 15 USDT", context);
    } else {
      try {
        showLoading(context);
        var bodydata = jsonEncode({
          "user_id": commonuserId,
          "type": exchanger,
          "crypto_pair": widget.compaircoinname,
          "amount": amount,
        });
        print(bodydata);
        final res = await http.post(finalurl, body: bodydata);
        if (res.statusCode == 200) {
          var data = jsonDecode(res.body);
          if (data['status'] == "success") {
            showtoast(data['message'], context);
            _getquantitative_txn_record();
            Navigator.pop(context);
            Navigator.pop(context);
          } else {
            showtoast(data['message'], context);
            Navigator.pop(context);
            Navigator.pop(context);
          }
        } else {
          print("Server Error");
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  _start_or_stop_margin() async {
    showLoading(context);
    try {
      final res = await http.post(Uri.parse(tradesetting_update_by_columnwwm),
          body: json.encode({
            "user_id": commonuserId,
            "assets_type": widget.compaircoinname,
            "colum_name": "stock_margin",
            "exchange_type": exchanger,
            "colum_value": start_or_stop_margin == 1 ? "0" : "1"
          }));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['status'] == "success") {
          showtoast(data['message'], context);
          Navigator.pop(context);
          Navigator.pop(context);
          _getquantitative_txn_record();
        } else {
          showtoast(data['message'], context);
          Navigator.pop(context);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
  }

  _one_shot_to_cycle() async {
    print(widget.compaircoinname);
    try {
      showLoading(context);
      final res = await http.post(Uri.parse(tradesetting_update_by_columnwwm),
          body: json.encode({
            "user_id": commonuserId,
            "assets_type": widget.compaircoinname,
            "colum_name": "cycle",
            "exchange_type": exchanger,
            "colum_value": cycle == 1 ? "0" : "1"
          }));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print(data);
        if (data['status'] == "success") {
          showtoast(data['message'], context);
          Navigator.pop(context);
          Navigator.pop(context);
          _getquantitative_txn_record();
        } else {
          showtoast("Something Wrong", context);
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } else {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
  }
}

// CustomPainter class to for the header curved-container
class HeaderCurvedContainer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = const Color(0xff000000);
    Path path = Path()
      ..relativeLineTo(0, 100)
      ..quadraticBezierTo(size.width / 2, 100.0, size.width, 100)
      ..relativeLineTo(0, -100)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
