// To parse this JSON data, do
//
//     final revenueDetailByDate = revenueDetailByDateFromJson(jsonString);

import 'dart:convert';

RevenueDetailByDate revenueDetailByDateFromJson(String str) =>
    RevenueDetailByDate.fromJson(json.decode(str));

String revenueDetailByDateToJson(RevenueDetailByDate data) =>
    json.encode(data.toJson());

class RevenueDetailByDate {
  RevenueDetailByDate({
    required this.status,
    required this.message,
    required this.responsecode,
    required this.data,
  });

  String status;
  String message;
  String responsecode;
  Data data;

  factory RevenueDetailByDate.fromJson(Map<String, dynamic> json) =>
      RevenueDetailByDate(
        status: json["status"],
        message: json["message"],
        responsecode: json["responsecode"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "responsecode": responsecode,
        "data": data.toJson(),
      };
}

class Data {
  Data({
    required this.details,
    required this.profitToday,
    required this.cumulativeProfit,
  });

  List<Detail> details;
  double profitToday;
  double cumulativeProfit;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        details:
            List<Detail>.from(json["details"].map((x) => Detail.fromJson(x))),
        profitToday: json["profit_today"].toDouble(),
        cumulativeProfit: json["cumulative_profit"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "details": List<dynamic>.from(details.map((x) => x.toJson())),
        "profit_today": profitToday,
        "cumulative_profit": cumulativeProfit,
      };
}

class Detail {
  Detail({
    required this.id,
    required this.userId,
    required this.cryptoPair,
    required this.orderNo,
    required this.orderRef,
    required this.originalOrderid,
    required this.sellOrBuy,
    required this.exchanger,
    required this.avgPrice,
    required this.qty,
    required this.commissionPrice,
    required this.profit,
    required this.tradeAmount,
    required this.mode,
    required this.createdate,
    required this.status,
  });

  String id;
  String userId;
  String cryptoPair;
  String orderNo;
  String orderRef;
  dynamic originalOrderid;
  String sellOrBuy;
  String exchanger;
  String avgPrice;
  String qty;
  String commissionPrice;
  String profit;
  String tradeAmount;
  String mode;
  DateTime createdate;
  String status;

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        id: json["id"],
        userId: json["user_id"],
        cryptoPair: json["crypto_pair"],
        orderNo: json["order_no"],
        orderRef: json["order_ref"],
        originalOrderid: json["original_orderid"],
        sellOrBuy: json["sell_or_buy"],
        exchanger: json["exchanger"],
        avgPrice: json["avg_price"],
        qty: json["qty"],
        commissionPrice: json["commission_price"],
        profit: json["profit"],
        tradeAmount: json["trade_amount"],
        mode: json["mode"],
        createdate: DateTime.parse(json["createdate"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "crypto_pair": cryptoPair,
        "order_no": orderNo,
        "order_ref": orderRef,
        "original_orderid": originalOrderid,
        "sell_or_buy": sellOrBuy,
        "exchanger": exchanger,
        "avg_price": avgPrice,
        "qty": qty,
        "commission_price": commissionPrice,
        "profit": profit,
        "trade_amount": tradeAmount,
        "mode": mode,
        "createdate": createdate.toIso8601String(),
        "status": status,
      };
}
