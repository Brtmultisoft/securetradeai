// To parse this JSON data, do
//
//     final usersNews = usersNewsFromJson(jsonString);

import 'dart:convert';

UsersNews usersNewsFromJson(String str) => UsersNews.fromJson(json.decode(str));

String usersNewsToJson(UsersNews data) => json.encode(data.toJson());

class UsersNews {
  UsersNews({
    required this.status,
    required this.message,
    required this.responsecode,
    required this.data,
  });

  String status;
  String message;
  String responsecode;
  List<Datum> data;

  factory UsersNews.fromJson(Map<String, dynamic> json) => UsersNews(
        status: json["status"],
        message: json["message"],
        responsecode: json["responsecode"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "responsecode": responsecode,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    required this.id,
    required this.userId,
    required this.cryptoPair,
    required this.orderNo,
    required this.sellOrBuy,
    required this.exchanger,
    required this.avgPrice,
    required this.qty,
    required this.profit,
    required this.createdate,
    required this.status,
  });

  String id;
  String userId;
  String cryptoPair;
  String orderNo;
  String sellOrBuy;
  String exchanger;
  String avgPrice;
  String qty;
  String profit;
  DateTime createdate;
  String status;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        userId: json["user_id"],
        cryptoPair: json["crypto_pair"],
        orderNo: json["order_no"],
        sellOrBuy: json["sell_or_buy"],
        exchanger: json["exchanger"],
        avgPrice: json["avg_price"],
        qty: json["qty"],
        profit: json["profit"],
        createdate: DateTime.parse(json["createdate"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "crypto_pair": cryptoPair,
        "order_no": orderNo,
        "sell_or_buy": sellOrBuy,
        "exchanger": exchanger,
        "avg_price": avgPrice,
        "qty": qty,
        "profit": profit,
        "createdate": createdate.toIso8601String(),
        "status": status,
      };
}
