// To parse this JSON data, do
//
//     final tradehistoryModel = tradehistoryModelFromJson(jsonString);

import 'dart:convert';

TradehistoryModel tradehistoryModelFromJson(String str) => TradehistoryModel.fromJson(json.decode(str));

String tradehistoryModelToJson(TradehistoryModel data) => json.encode(data.toJson());

class TradehistoryModel {
    String status;
    String message;
    String responsecode;
    Data data;

    TradehistoryModel({
        required this.status,
        required this.message,
        required this.responsecode,
        required this.data,
    });

    factory TradehistoryModel.fromJson(Map<String, dynamic> json) => TradehistoryModel(
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
    List<Detail> details;
    List<Detail> details2;
    double profitToday;
    double cumulativeProfit;

    Data({
        required this.details,
        required this.details2,
        required this.profitToday,
        required this.cumulativeProfit,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        details: json["details"] != null 
            ? List<Detail>.from(json["details"].map((x) => Detail.fromJson(x)))
            : [],
        details2: json["details2"] != null 
            ? List<Detail>.from(json["details2"].map((x) => Detail.fromJson(x)))
            : [],
        profitToday: (json["profit_today"] ?? 0).toDouble(),
        cumulativeProfit: (json["cumulative_profit"] ?? 0).toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "details": List<dynamic>.from(details.map((x) => x.toJson())),
        "details2": List<dynamic>.from(details2.map((x) => x.toJson())),
        "profit_today": profitToday,
        "cumulative_profit": cumulativeProfit,
    };
}

class Detail {
    String totalbal;
    DateTime createdDate;

    Detail({
        required this.totalbal,
        required this.createdDate,
    });

    factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        totalbal: json["totalbal"]?.toString() ?? "0",
        createdDate: json["created_date"] != null 
            ? DateTime.parse(json["created_date"])
            : DateTime.now(),
    );

    Map<String, dynamic> toJson() => {
        "totalbal": totalbal,
        "created_date": createdDate.toIso8601String(),
    };
}
