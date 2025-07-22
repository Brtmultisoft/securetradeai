import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/data/strings.dart';

import '../Data/Api.dart';

class Repo extends ChangeNotifier {
  String value = "Binance Balance : 0.0000";
  var final_Quantitative_data = [];
  var quantutumdata = [];
  var homePageTxnRecords = [];
  var finalTransactionData = [];
  var assets = [];
  bool circledata = false;
  var finaltradeSettingData;
  var transactionRecord = [];
  // here is huobi variables
  var huobiAssets = [];
  var finalhuobiData = [];
  void updateBalance(String newTitle) async {
    print(newTitle);
    if (newTitle == "Binance") {
      _getBinanceBalance(newTitle);
    } else {
      _getHuobibalance(newTitle);
    }
  }

  _getBinanceBalance(String finalString) async {
    print("🔍 DEBUG: Fetching $finalString balance for user: $commonuserId");
    print("🔍 DEBUG: API URL: $usdBalance");

    try {
      final res = await http.post(Uri.parse(usdBalance),
          body: jsonEncode({"user_id": commonuserId, "type": finalString}));

      print("🔍 DEBUG: Response status code: ${res.statusCode}");
      print("🔍 DEBUG: Response body: ${res.body}");

      if (res.statusCode != 200) {
        print("❌ Server Error: ${res.statusCode}");
        value = "$finalString Balance : 0.00000";
      } else {
        var resposne = jsonDecode(res.body);
        print("🔍 DEBUG: Parsed response: $resposne");

        if (resposne['status'] == 'success') {
          print("🔍 DEBUG: Success response data: ${resposne['data']}");
          var finalamt = double.parse(resposne['data']).toStringAsFixed(2);
          value = "$finalString Balance : $finalamt";
          print("✅ $finalString Balance set to: $finalamt");
        } else {
          value = "$finalString Balance : 0.00000";
          print("❌ Binance balance get failed - Status: ${resposne['status']}, Message: ${resposne['message'] ?? 'No message'}");
        }
      }
    } catch (e) {
      print("❌ Exception in _getBinanceBalance: $e");
      value = "$finalString Balance : 0.00000";
    }
    notifyListeners();
  }

  _getHuobibalance(String finalString) async {
    final res = await http.post(Uri.parse(huobiBalance),
        body: jsonEncode({"user_id": commonuserId, "type": finalString}));
    if (res.statusCode != 200) {
      print("Server Error");
    } else {
      var resposne = jsonDecode(res.body);
      print(resposne);
      if (resposne['status'] == 'success') {
        value =
            "$finalString Balance : ${double.parse(resposne['data']).toStringAsFixed(6)}";
      } else {
        value = "$finalString Balance : 0.00000";
        print("Binance balance get failed");
      }
    }
    notifyListeners();
  }

  Future<bool> getquantitumData(String serachwords1, int number) async {
    try {
      print("hit");
      final url = Uri.parse("https://api.binance.com/api/v3/ticker/24hr");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        quantutumdata = jsonDecode(response.body);
        if (number == 0) {
          commonMethod(serachwords1);
        } else {
          homepageListdata();
        }
      } else {
        print("exeption");
      }
      return false;
    } on SocketException catch (_) {
      return true;
    } catch (error) {
      print(error);
    }
    notifyListeners();
    return false;
  }

  getpriceData() async {
    final res = await http.get(Uri.parse(cryptoassets));
    var response = jsonDecode(res.body);
    assets = response['data'];
    notifyListeners();
  }

  commonMethod(String serachwords) {
    print("Hitmethod");
    final_Quantitative_data.clear();
    for (var e in assets) {
      for (var element in quantutumdata) {
        // print(element['lastPrice']);
        if (element['symbol'] == e['assets']) {
          final_Quantitative_data.add({
            'symbol': element['symbol'],
            'price': element['lastPrice'],
            'priceChange': element['priceChangePercent'],
            'asset_img': e['assets_img'],
            'status': e['status'],
            'open': element['openPrice'] ??
                element[
                    'lastPrice'], // Use openPrice if available, otherwise lastPrice
            'close': element['lastPrice'], // Add close field with lastPrice
            'high':
                element['highPrice'] ?? element['lastPrice'], // Add high field
            'low': element['lowPrice'] ?? element['lastPrice'], // Add low field
            'volume': element['volume'] ?? "0", // Add volume field
            'quoteVolume':
                element['quoteVolume'] ?? "0", // Add quoteVolume field
            'coinurl': e['chart_image'],
            'searchWords': serachwords
          });
          break;
        }
      }
    }
    notifyListeners();
  }

// hare is start cycle or one shot code
  Future<bool> gettxnAllrecord() async {
    try {
      final res = await http.post(Uri.parse(txnallRecords),
          body: json.encode({"user_id": commonuserId}));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print(data);
        if (data['status'] == "success") {
          transactionRecord = data['data'];
          print(transactionRecord);
          homepageListdata();
        } else {
          circledata = true;
          print("Transaction record not found");
        }
      } else {
        print("Server Error");
      }
      return false;
    } on SocketException catch (exception) {
      return true;
    } catch (error) {
      print(error);
    }
    notifyListeners();
    return false;
  }

  homepageListdata() {
    finalTransactionData.clear();
    List localList = [];
    for (var e in transactionRecord) {
      for (var b in assets) {
        if (e['assets'] == b['assets']) {
          localList.add({
            "id": e['id'],
            "type": e['order_type'],
            'assets_img': b['assets_img'],
            'coinurl': b['chart_image'],
            'assets': e['assets'],
            'cycle': e['cycle'],
            'qty': e['pos_qty'],
            'pos_amt': e['pos_amt'],
            'pos_qty': e['pos_qty'],
            'stock_margin': e['stock_margin']
          });
        }
      }
    }
    for (var twentryfourHr in quantutumdata) {
      for (var c in localList) {
        // print(c['assets']);
        if (c['assets'] == twentryfourHr['symbol']) {
          finalTransactionData.add({
            "id": c['id'],
            "type": c['type'],
            'symbol': twentryfourHr['symbol'],
            'price': twentryfourHr['lastPrice'],
            'priceChange': twentryfourHr['priceChangePercent'],
            'asset_img': c['assets_img'],
            'cycle': c['cycle'],
            'qty': c['qty'],
            'pos_amt': c['pos_amt'],
            'pos_qty': c['pos_qty'],
            'stockmargin': c['stock_margin'],
            'coinurl': c['chart_image']
          });
        }
      }
    }
    notifyListeners();
  }

  // here is huobi code
  getHuobiOfficealAPIdata(String serachwords1) async {
    final res =
        await http.get(Uri.parse("https://api.huobi.pro/market/tickers"));
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      huobiAssets = data['data'];
      getHuobiCommonList(serachwords1);
    } else {
      print("Huobi API error");
    }
    notifyListeners();
  }

  getHuobiCommonList(String serachwords1) {
    finalhuobiData.clear();
    for (var asset in assets) {
      for (var huobiasset in huobiAssets) {
        String a = asset['assets'].toString().toLowerCase();
        if (asset['exchange_type'] == "Huobi" && a == huobiasset['symbol']) {
          finalhuobiData.add({
            'symbol': asset['assets'],
            'close': huobiasset['close'],
            'open': huobiasset['open'],
            'asset_img': asset['assets_img'],
            'status': asset['status'],
            'coinurl': asset['chart_image'],
            'searchWords': serachwords1
          });
          // break;
        }
      }
    }
    notifyListeners();
  }
}
