import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rapidtradeai/data/api.dart';
import 'package:rapidtradeai/data/strings.dart';

class TradeSettingProvider extends ChangeNotifier {
  var firstbuy = TextEditingController();
  bool switchValue = false;
  String takeprofit = "0.0";
  String earingcallback = "0.0";
  var martinConfig;
  String magincall = "0.0";
  var marginCallLimit = TextEditingController();
  var wholPositiontakeProfitratio = TextEditingController();
  var whole_position_take_profit_callback = TextEditingController();
  var buy_in_callbakc = TextEditingController();
  getTradeSetting(String coinname) async {
    var bodydata = jsonEncode({
      "user_id": commonuserId,
      "exchange_type": exchanger,
      "assets_type": coinname
    });
    print(bodydata);
    final res = await http.post(Uri.parse(tradesettingwwm), body: bodydata);
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      print(data);
      if (data["status"] == "success") {
        firstbuy.text = data['data']['first_buy'].toString();
        takeprofit = data['data']['wp_profit'];
        earingcallback = data['data']['wp_callback'];
        magincall = data['data']['margin_call_limit'];
        martinConfig = data['data']['martin_config'];
        switchValue = data['data']['martin_config'] == "1" ? true : false;
        marginCallLimit.text = data['data']['margin_call_limit'].toString();
        wholPositiontakeProfitratio.text = data['data']['wp_profit'].toString();
        whole_position_take_profit_callback.text =
            data['data']['wp_callback'].toString();
        buy_in_callbakc.text = data['data']['by_callback'].toString();
      } else {
        print(data['data']);
      }
    } else {
      print("Server Error");
    }
    notifyListeners();
  }

  updateTadeSetting(coinname) async {
    final res = await http.post(Uri.parse(updateTradeSettingFirstPagewwm),
        body: jsonEncode({
          "user_id": commonuserId,
          "assets_type": coinname,
          "exchange_type": "Binance",
          "first_buy": firstbuy,
          "martin_config": martinConfig,
          "margin_call_limit": marginCallLimit,
          "wp_profit": wholPositiontakeProfitratio,
          "wp_callback": whole_position_take_profit_callback,
          "by_callback": buy_in_callbakc
        }));
    if (res.statusCode == 200) {
      print(res.body);
    } else {
      print("Sever Error");
    }
  }
}

// here is subbin mode Provider class
