import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/Data/Api.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/method/methods.dart';

class HomePageProvider extends ChangeNotifier {
  List bannerList = [];
  String lastnews = "Loading..";
  var homePageTxnRecords = [];
  var transactionRecordhuobi = [];
  var homepageHot24 = [];
  var transactionRecord = [];
  var finalTransactionData = [];
  var finalTransactionDataHuobi = [];
  var locallist24 = [];
  bool check_TransactionData = false;
  bool check_TransactionDatahuobi = false;
  var assets = [];
  // huobi variables start
  var huobidata = [];
  var finalHuobiList = [];
  // huobi 24 list of data
  getBanner() async {
    final data = await CommonMethod().getHomePgeBanner();
    if (data.status == "success") {
      bannerList.addAll(data.data);
    } else {
      print("banner list Not found");
    }
  }

  getNewsdata() async {
    try {
      final data = await CommonMethod().getNews();
      if (data.status == "success") {
        lastnews = data.data.first.message;
      } else {}
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

// hare is start finallist of data code
  getassets() async {
    final res = await http.get(Uri.parse(cryptoassets));
    var response = jsonDecode(res.body);
    assets = response['data'];
    notifyListeners();
  }

  gettxnAllrecord() async {
    finalTransactionData.clear();
    transactionRecord.clear();
    check_TransactionData = false;
    try {
      final res = await http.post(Uri.parse(txnallRecords),
          body: json.encode({"user_id": commonuserId}));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['status'] == "success") {
          transactionRecord = data['data'];
        } else {
          check_TransactionData = true;
        }
      } else {
        print("Server Error");
      }
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  gettxnAllrecordHuobi() async {
    transactionRecord.clear();
    try {
      final res = await http.post(Uri.parse(txnallRecordshuobi),
          body: json.encode({"user_id": commonuserId}));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['status'] == "success") {
          transactionRecordhuobi = data['data'];
        } else {
          check_TransactionDatahuobi = true;
        }
      } else {
        print("Server Error");
      }
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  Future<bool> homePageAllRecords(int index) async {
    try {
      final url = Uri.parse("https://api.binance.com/api/v3/ticker/24hr");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        homePageTxnRecords = jsonDecode(response.body);
        if (index == 0) {
          homepageListdata(homePageTxnRecords, transactionRecord);
        }
      } else {
        print("exeption");
      }
      return false;
    } on SocketException catch (exception) {
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  homepageListdata(List priceData, List TransactionList) {
    finalTransactionData.clear();
    List localList = [];
    for (var e in TransactionList) {
      for (var b in assets) {
        if (e['assets'] == b['assets']) {
          localList.add({
            "id": e['id'] ?? "",
            "type": e['order_type'] ?? "",
            'assets_img': b['assets_img'] ?? "",
            'assets': e['assets'] ?? "",
            'cycle': e['cycle'] ?? "0",
            'qty': e['pos_qty'] ?? "0",
            'pos_amt': e['pos_amt'] ?? "0",
            'pos_qty': e['pos_qty'] ?? "0",
            'chartimg': b['chart_image'] ?? ""
          });
        }
      }
    }
    for (var twentryfourHr in priceData) {
      for (var c in localList) {
        if (c['assets'] == twentryfourHr['symbol']) {
          finalTransactionData.add({
            "id": c['id'],
            "type": c['type'],
            'symbol': twentryfourHr['symbol'] ?? "",
            'price': twentryfourHr['lastPrice'] ?? "0",
            'priceChange': twentryfourHr['priceChangePercent'] ?? "0",
            'asset_img': c['assets_img'],
            'cycle': c['cycle'],
            'qty': c['qty'],
            'pos_amt': c['pos_amt'],
            'pos_qty': c['pos_qty'],
            'chartimg': c['chartimg']
          });
        }
      }
    }
    notifyListeners();
  }

  homepageListdataHuobi(List priceData, List TransactionList) {
    finalTransactionDataHuobi.clear();
    List localList = [];
    for (var e in TransactionList) {
      for (var b in assets) {
        if (e['assets'] == b['assets']) {
          localList.add({
            "type": e['order_type'] ?? "",
            'assets_img': b['assets_img'] ?? "",
            'assets': e['assets'] ?? "",
            'cycle': e['cycle'] ?? "0",
            "stock_margin": e['stock_margin'] ?? "0",
            'qty': e['pos_qty'] ?? "0",
            'avgPrice': (e['avg_price'] ?? "0").toString().replaceAll(",", ""),
            'chartimg': b['chart_image'] ?? ""
          });
        }
      }
    }
    for (var twentryfourHr in priceData) {
      for (var c in localList) {
        if (c['assets'] == twentryfourHr['symbol'] ||
            c['assets'] == twentryfourHr['symbol'].toString().toLowerCase()) {
          var a = (twentryfourHr['close'] ?? 0) - (twentryfourHr['open'] ?? 0);
          double finalpercent = a / (twentryfourHr['open'] ?? 1) * 100;
          finalTransactionDataHuobi.add({
            "type": c['type'],
            'symbol': twentryfourHr['symbol'] ?? "",
            'price': twentryfourHr['close'] ?? 0,
            'priceChange': finalpercent,
            'asset_img': c['assets_img'],
            'cycle': c['cycle'],
            "stock_margin": c['stock_margin'],
            'qty': c['qty'],
            'avg_price': c['avgPrice'],
            'chartimg': c['chartimg'],
          });
        }
      }
    }
    notifyListeners();
  }
  //when click user homepage hot button

  // when user select huobi exchanger
  huobiassets(int index) async {
    final res =
        await http.get(Uri.parse("https://api.huobi.pro/market/tickers"));
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      huobidata = data['data'];
      if (index == 0) {
        homepageListdataHuobi(huobidata, transactionRecordhuobi);
      } else if (index == 1) {
        huobicommonMethod();
      } else if (index == 2) {
      } else {
        print("huobiassets Error");
      }
    } else {
      print("huobi server error");
    }
  }

  huobicommonMethod() {
    finalHuobiList.clear();
    for (var huobiAssets in assets) {
      // print(huobiAssets['assets']);
      for (var huobiAPI in huobidata) {
        String a = huobiAssets['assets'].toString().toLowerCase();
        if (huobiAssets['exchange_type'] == "Huobi" &&
            a == huobiAPI['symbol']) {
          var a = huobiAPI['close'] - huobiAPI['open'];
          double finalpercent = a / huobiAPI['open'] * 100;
          finalHuobiList.add({
            'coinname': huobiAssets['assets'].toString().toUpperCase(),
            'coinimg': huobiAssets['assets_img'],
            'close': huobiAPI['close'],
            'open': huobiAPI['open'],
            'coinurl': huobiAssets['chart_image'],
            'finalprecent': finalpercent
          });
        }
      }
    }
    finalHuobiList
        .sort((a, b) => b["finalprecent"].compareTo(a["finalprecent"]));
    notifyListeners();
  }

  // perfect Bot Call API
}
