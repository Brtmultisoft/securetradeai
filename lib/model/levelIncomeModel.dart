// To parse this JSON data, do
//
//     final levelIncome = levelIncomeFromJson(jsonString);

import 'dart:convert';

LevelIncome levelIncomeFromJson(String str) =>
    LevelIncome.fromJson(json.decode(str));

String levelIncomeToJson(LevelIncome data) => json.encode(data.toJson());

class LevelIncome {
  LevelIncome({
    required this.status,
    required this.message,
    required this.responsecode,
    required this.data,
  });

  String status;
  String message;
  String responsecode;
  Data data;

  factory LevelIncome.fromJson(Map<String, dynamic> json) => LevelIncome(
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
  dynamic profitToday;
  dynamic cumulativeProfit;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        details:
            List<Detail>.from(json["details"].map((x) => Detail.fromJson(x))),
        profitToday: json["profit_today"],
        cumulativeProfit: json["cumulative_profit"],
      );

  Map<String, dynamic> toJson() => {
        "details": List<dynamic>.from(details.map((x) => x.toJson())),
        "profit_today": profitToday,
        "cumulative_profit": cumulativeProfit,
      };
}

class Detail {
  Detail({
    required this.totalbal,
    required this.createdDate,
  });

  String totalbal;
  DateTime createdDate;

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        totalbal: json["totalbal"],
        createdDate: DateTime.parse(json["created_date"]),
      );

  Map<String, dynamic> toJson() => {
        "totalbal": totalbal,
        "created_date": createdDate.toIso8601String(),
      };
}
