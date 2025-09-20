import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rapidtradeai/data/strings.dart';
import 'package:rapidtradeai/src/Homepage/marginconfig.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';

import '../../Data/Api.dart';
import '../../Method/TradeSettingProvider.dart';

class TradeSetting extends StatefulWidget {
  final coinname;
  TradeSetting({
    Key? key,
    this.coinname,
  }) : super(key: key);

  @override
  _TradeSettingState createState() => _TradeSettingState();
}

class _TradeSettingState extends State<TradeSetting> {
  bool lowCheck = false;
  bool moderate = false;
  bool high = false;
  int commonvalue = 0;
  bool _isLoading = false;
  _getData() {
    final tradesettingfinal =
        Provider.of<TradeSettingProvider>(context, listen: false);
    tradesettingfinal.getTradeSetting(widget.coinname);
  }

  Future<bool> showExitPopup() async {
    return commonvalue != 0
        ? await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0))),
                  content: StatefulBuilder(
                    // You need this, notice the parameters below:
                    builder: (BuildContext context, StateSetter setState) {
                      return SingleChildScrollView(
                          child: Column(children: [
                        Text("Alert",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text(
                            "are you sure you want to set ${commonvalue == 1 ? "Low" : commonvalue == 2 ? "Moderate Risk" : commonvalue == 3 ? "High" : "Low"} risk",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 25,
                              width: 90,
                              decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: [0.0, 1.0],
                                    colors: [
                                      Colors.green,
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
                                  Navigator.pop(context);
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
                              decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: [0.0, 1.0],
                                    colors: [
                                      Colors.green,
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
                                  _commonAPIcallMethod();
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
                          ],
                        )
                      ]));
                    },
                  ),
                );
              },
            ) ??
            false
        : _backmethod(); //if showDialouge had returned null, then return false
  }

  _backmethod() {
    Navigator.pop(context);
  }

  _commonAPIcallMethod() async {
    final tradesettingfinal =
        Provider.of<TradeSettingProvider>(context, listen: false);
    await _updateSetting(
        tradesettingfinal.firstbuy.text,
        tradesettingfinal.switchValue,
        tradesettingfinal.marginCallLimit.text,
        tradesettingfinal.wholPositiontakeProfitratio.text,
        tradesettingfinal.whole_position_take_profit_callback.text,
        tradesettingfinal.buy_in_callbakc.text);
    commonvalue != 0 ? _postrisk(commonvalue.toString()) : null;
    _reset();
  }

  _reset() {
    setState(() {
      lowCheck = false;
      moderate = false;
      high = false;
      commonvalue = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: showExitPopup,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: bg,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            "Trade Setting",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                _commonAPIcallMethod();
              },
              child: Container(
                margin: EdgeInsets.only(right: 20),
                child: const Center(
                  child: Text(
                    "save",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Consumer<TradeSettingProvider>(
              builder: (context, tradesetting, child) {
            return Column(
              children: [
                Container(
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
                  ),
                  height: 50,
                  child: Row(
                    children: const [
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.info,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Text(
                          "The first buy in amount is calculated according to the currency pair. principle and trade unit",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "First Buy in\namount",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 50,
                                child: TextField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}')),
                                  ],
                                  controller: tradesetting.firstbuy,
                                  textAlign: TextAlign.right,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintStyle: TextStyle(color: Colors.grey),
                                    hintText: "0.00",
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 13.0),
                                  ),
                                  onChanged: (v) {},
                                ),
                              ),
                              const Text(
                                'USDT',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Open Position Doubled",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          CupertinoSwitch(
                            activeColor: rapidtradeaicolor,
                            value: tradesetting.switchValue,
                            //  martin_config != '1' ? true : false,
                            onChanged: (value) {
                              setState(() {
                                tradesetting.switchValue = value;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Margin call limit",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 50,
                                child: TextField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}')),
                                  ],
                                  textAlign: TextAlign.right,
                                  controller: tradesetting.marginCallLimit,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintStyle: TextStyle(color: Colors.grey),
                                    hintText: "0.00",
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 13.0),
                                  ),
                                  onChanged: (v) {},
                                ),
                              ),
                              const Text(
                                'Times',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Whole position take\nprofit ratio",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 50,
                                child: TextField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}')),
                                  ],
                                  textAlign: TextAlign.right,
                                  controller:
                                      tradesetting.wholPositiontakeProfitratio,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintStyle: TextStyle(color: Colors.grey),
                                    hintText: "0.00",
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 13.0),
                                  ),
                                  onChanged: (v) {},
                                ),
                              ),
                              const Text(
                                '%',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Whole position take\nprofit callback",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 50,
                                child: TextField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}')),
                                  ],
                                  textAlign: TextAlign.right,
                                  controller: tradesetting
                                      .whole_position_take_profit_callback,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintStyle: TextStyle(color: Colors.grey),
                                    hintText: "0.00",
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 13.0),
                                  ),
                                  onChanged: (v) {},
                                ),
                              ),
                              const Text(
                                '%',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MarginConfig(
                                        coinname: widget.coinname,
                                        calllimit: double.parse(
                                            tradesetting.marginCallLimit.text),
                                      )));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "Margin Configuration",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                            )
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Buy in callback",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 50,
                                child: TextField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}')),
                                  ],
                                  textAlign: TextAlign.right,
                                  controller: tradesetting.buy_in_callbakc,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintStyle: TextStyle(color: Colors.grey),
                                    hintText: "0.00",
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 13.0),
                                  ),
                                  onChanged: (v) {},
                                ),
                              ),
                              const Text(
                                '%',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          height: 30,
                          width: 200,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.2),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                          ),
                          child: const Center(
                            child: Text("RECOMMENDED SETTINGS",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      _low(),
                      SizedBox(
                        height: 10,
                      ),
                      _mediumRisk(),
                      SizedBox(
                        height: 10,
                      ),
                      _highRisk(),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _highRisk() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 3),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: high ? Colors.grey : rapidtradeaicolor,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.transparent.withOpacity(0.38),
          disabledBackgroundColor: Colors.transparent.withOpacity(0.12),
          shadowColor: Colors.transparent,
        ),
        onPressed: () => commonMethod(3),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 20,
                width: 20,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                // child: ...
              ),
              const SizedBox(
                width: 20,
              ),
              const Text(
                'High Risk        ',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mediumRisk() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 3),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: moderate ? Colors.grey : rapidtradeaicolor,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
              color: Colors.black12,
              offset: Offset(2, 4),
              blurRadius: 5,
              spreadRadius: 2)
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.transparent.withOpacity(0.38),
          disabledBackgroundColor: Colors.transparent.withOpacity(0.12),
          shadowColor: Colors.transparent,
        ),
        onPressed: () => commonMethod(2),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 20,
                width: 20,
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                // child: ...
              ),
              const SizedBox(
                width: 20,
              ),
              const Text(
                "Moderate Risk",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _low() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 3),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: lowCheck ? Colors.grey : rapidtradeaicolor,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.transparent.withOpacity(0.38),
          disabledBackgroundColor: Colors.transparent.withOpacity(0.12),
          shadowColor: Colors.transparent,
        ),
        onPressed: () => commonMethod(1),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                // child: ...
              ),
              SizedBox(
                width: 20,
              ),
              const Text(
                'Low Risk        ',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  commonMethod(int number) {
    if (number == 1) {
      setState(() {
        lowCheck = true;
        moderate = false;
        high = false;
        commonvalue = 1;
      });
    } else if (number == 2) {
      setState(() {
        lowCheck = false;
        moderate = true;
        high = false;
        commonvalue = 2;
      });
    } else if (number == 3) {
      setState(() {
        lowCheck = false;
        moderate = false;
        high = true;
        commonvalue = 3;
      });
    } else {
      print('choose a different number!');
    }
  }

  _postrisk(String riskType) async {
    try {
      showLoading(context);
      var bodydata = jsonEncode({
        "user_id": commonuserId,
        "exchange_type": exchanger,
        "assets_type": widget.coinname,
        "risk_type": riskType
      });
      print(bodydata);
      final res =
          await http.post(Uri.parse(tradesetting_riskwwm), body: bodydata);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        print(data);
        if (data['status'] == "success") {
          showtoast("Success", context);
          _getData();
          Navigator.pop(context);
          Navigator.pop(context);
        } else {
          showtoast(data['message'], context);
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } else {
        Navigator.pop(context);
        Navigator.pop(context);
        showtoast("Server Erro", context);
      }
    } catch (e) {
      print(e);
    }
  }

  _updateSetting(String firstBy, martinConfig, martinCallLimit, wpProfit,
      wpCallback, bycalback) async {
    var bodydata = json.encode({
      "user_id": commonuserId,
      "assets_type": widget.coinname,
      "exchange_type": "Binance",
      "first_buy": firstBy,
      "martin_config": martinConfig == true ? "1" : "0",
      "margin_call_limit": martinCallLimit,
      "wp_profit": wpProfit,
      "wp_callback": wpCallback,
      "by_callback": bycalback
    });
    if (firstBy.contains(".")) {
      showtoast("Invalid Value", context);
      return;
    }
    if (firstBy.isEmpty || double.parse(firstBy) < 10) {
      showtoast("Error", context);
    } else if (martinCallLimit == "" ||
        double.parse(martinCallLimit).isNegative ||
        double.parse(martinCallLimit) > 100) {
      showtoast("Error", context);
    } else if (double.parse(wpProfit) <= 0) {
      showtoast("Error", context);
    } else if (double.parse(wpCallback) <= 0) {
      showtoast("Error", context);
    } else if (double.parse(bycalback) <= 0) {
      showtoast("Error", context);
    } else {
      showLoading(context);
      final res = await http.post(Uri.parse(updateTradeSettingFirstPagewwm),
          body: bodydata);
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print(data);
        if (data['status'] == "success") {
          showtoast(data['message'], context);
          _getData();
          Navigator.pop(context);
        } else {
          showtoast(data['message'], context);
          Navigator.pop(context);
        }
      } else {
        showtoast("Server Error", context);
        Navigator.pop(context);
      }
    }
  }
}
