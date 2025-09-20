// To parse this JSON data, do
//
//     final revenueDetail = revenueDetailFromJson(jsonString);

import 'dart:convert';

RevenueDetail revenueDetailFromJson(String str) =>
    RevenueDetail.fromJson(json.decode(str));

String revenueDetailToJson(RevenueDetail data) => json.encode(data.toJson());

class RevenueDetail {
  RevenueDetail({
    required this.status,
    required this.message,
    required this.responsecode,
    required this.data,
  });

  String status;
  String message;
  String responsecode;
  Data data;

  factory RevenueDetail.fromJson(Map<String, dynamic> json) => RevenueDetail(
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
    required this.totalbal,
    required this.createdate,
    required this.cryptoPair,
    required this.profit,
    required this.sellOrBuy,
    required this.exchanger,
  });

  final String id;
  final String totalbal;
  final DateTime createdate;
  final String cryptoPair;
  final String profit;
  final String sellOrBuy;
  final String exchanger;

  factory Detail.fromJson(Map<String, dynamic> json) {
    try {
      return Detail(
        id: json["id"]?.toString() ?? "",
        totalbal: json["totalbal"]?.toString() ?? "0",
        createdate: json["createdate"] != null 
            ? DateTime.parse(json["createdate"]) 
            : DateTime.now(),
        cryptoPair: json["crypto_pair"]?.toString() ?? "",
        profit: json["profit"]?.toString() ?? "0",
        sellOrBuy: json["sell_or_buy"]?.toString() ?? "",
        exchanger: json["exchanger"]?.toString() ?? "",
      );
    } catch (e) {
      print("Error parsing Detail: $e");
      return Detail(
        id: "",
        totalbal: "0",
        createdate: DateTime.now(),
        cryptoPair: "",
        profit: "0",
        sellOrBuy: "",
        exchanger: "",
      );
    }
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "totalbal": totalbal,
        "createdate": createdate.toIso8601String(),
        "crypto_pair": cryptoPair,
        "profit": profit,
        "sell_or_buy": sellOrBuy,
        "exchanger": exchanger,
      };
}
