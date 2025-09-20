// To parse this JSON data, do
//
//     final incomeSummary = incomeSummaryFromJson(jsonString);

import 'dart:convert';

IncomeSummaryModel incomeSummaryFromJson(String str) =>
    IncomeSummaryModel.fromJson(json.decode(str));

String incomeSummaryToJson(IncomeSummaryModel data) => json.encode(data.toJson());

class IncomeSummaryModel {
  IncomeSummaryModel({
    required this.status,
    required this.data,
  });

  String status;
  IncomeSummaryData data;

  factory IncomeSummaryModel.fromJson(Map<String, dynamic> json) => IncomeSummaryModel(
        status: json["status"] ?? "",
        data: IncomeSummaryData.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
      };
}

class IncomeSummaryData {
  IncomeSummaryData({
    required this.incomeBreakdown,
    required this.totalIncome,
  });

  IncomeBreakdown incomeBreakdown;
  double totalIncome;

  factory IncomeSummaryData.fromJson(Map<String, dynamic> json) => IncomeSummaryData(
        incomeBreakdown: IncomeBreakdown.fromJson(json["income_breakdown"] ?? {}),
        totalIncome: double.tryParse(json["total_income"]?.toString() ?? "0") ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        "income_breakdown": incomeBreakdown.toJson(),
        "total_income": totalIncome,
      };
}

class IncomeBreakdown {
  IncomeBreakdown({
    required this.dailyRoi,
    required this.directReferral,
    required this.levelRoi,
    required this.gasFee,
    required this.salary,
  });

  double dailyRoi;
  double directReferral;
  double levelRoi;
  double gasFee;
  double salary;

  factory IncomeBreakdown.fromJson(Map<String, dynamic> json) => IncomeBreakdown(
        dailyRoi: double.tryParse(json["DAILY_ROI"]?.toString() ?? "0") ?? 0.0,
        directReferral: double.tryParse(json["DIRECT_REFERRAL"]?.toString() ?? "0") ?? 0.0,
        levelRoi: double.tryParse(json["LEVEL_ROI"]?.toString() ?? "0") ?? 0.0,
        gasFee: double.tryParse(json["GAS_FEE"]?.toString() ?? "0") ?? 0.0,
        salary: double.tryParse(json["SALARY"]?.toString() ?? "0") ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        "DAILY_ROI": dailyRoi,
        "DIRECT_REFERRAL": directReferral,
        "LEVEL_ROI": levelRoi,
        "GAS_FEE": gasFee,
        "SALARY": salary,
      };
}
