// To parse this JSON data, do
//
//     final directIncome = directIncomeFromJson(jsonString);
//     final levelIncome = levelIncomeFromJson(jsonString);
//     final salaryIncome = salaryIncomeFromJson(jsonString);

import 'dart:convert';

// Bot Trading Bonus Models
BotTradingBonusModel botTradingBonusFromJson(String str) =>
    BotTradingBonusModel.fromJson(json.decode(str));

String botTradingBonusToJson(BotTradingBonusModel data) => json.encode(data.toJson());

class BotTradingBonusModel {
  BotTradingBonusModel({
    required this.status,
    required this.message,
    required this.responsecode,
    required this.data,
  });

  String status;
  String message;
  String responsecode;
  BotTradingBonusData data;

  factory BotTradingBonusModel.fromJson(Map<String, dynamic> json) => BotTradingBonusModel(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        responsecode: json["responsecode"] ?? "",
        data: BotTradingBonusData.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "responsecode": responsecode,
        "data": data.toJson(),
      };
}

class BotTradingBonusData {
  BotTradingBonusData({
    required this.details,
    this.profitToday,
    required this.cumulativeProfit,
  });

  List<BotTradingBonusDetail> details;
  String? profitToday;
  double cumulativeProfit;

  factory BotTradingBonusData.fromJson(Map<String, dynamic> json) => BotTradingBonusData(
        details: json["details"] != null
            ? List<BotTradingBonusDetail>.from(
                json["details"].map((x) => BotTradingBonusDetail.fromJson(x)))
            : [],
        profitToday: json["profit_today"],
        cumulativeProfit: (json["cumulative_profit"] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "details": List<dynamic>.from(details.map((x) => x.toJson())),
        "profit_today": profitToday,
        "cumulative_profit": cumulativeProfit,
      };
}

class BotTradingBonusDetail {
  BotTradingBonusDetail({
    required this.totalbal,
    required this.createdDate,
  });

  String totalbal;
  String createdDate;

  factory BotTradingBonusDetail.fromJson(Map<String, dynamic> json) => BotTradingBonusDetail(
        totalbal: json["totalbal"]?.toString() ?? "0.00",
        createdDate: json["created_date"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "totalbal": totalbal,
        "created_date": createdDate,
      };
}

// Direct Income Model
DirectReferralIncomeModel directIncomeFromJson(String str) =>
    DirectReferralIncomeModel.fromJson(json.decode(str));

String directIncomeToJson(DirectReferralIncomeModel data) => json.encode(data.toJson());

class DirectReferralIncomeModel {
  DirectReferralIncomeModel({
    required this.status,
    required this.message,
    required this.responsecode,
    required this.data,
  });

  String status;
  String message;
  String responsecode;
  DirectReferralIncomeData data;

  factory DirectReferralIncomeModel.fromJson(Map<String, dynamic> json) => DirectReferralIncomeModel(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        responsecode: json["responsecode"] ?? "",
        data: DirectReferralIncomeData.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "responsecode": responsecode,
        "data": data.toJson(),
      };
}

class DirectReferralIncomeData {
  DirectReferralIncomeData({
    required this.totalDirectReferralIncome,
    required this.incomeHistory,
  });

  double totalDirectReferralIncome;
  List<DirectReferralIncomeHistory> incomeHistory;

  factory DirectReferralIncomeData.fromJson(Map<String, dynamic> json) => DirectReferralIncomeData(
    totalDirectReferralIncome: (json["total_direct_income"] ?? 0).toDouble(),
        incomeHistory: json["income_history"] != null
            ? List<DirectReferralIncomeHistory>.from(
                json["income_history"].map((x) => DirectReferralIncomeHistory.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "total_direct_income": totalDirectReferralIncome,
        "income_history": List<dynamic>.from(incomeHistory.map((x) => x.toJson())),
      };
}

class DirectReferralIncomeHistory {
  DirectReferralIncomeHistory({
    required this.id,
    required this.amount,
    required this.incomeType,
    required this.description,
    required this.percentage,
    required this.referenceId,
    required this.status,
    required this.createdAt,
  });

  int id;
  double amount;
  String incomeType;
  String description;
  double percentage;
  String referenceId;
  String status;
  DateTime createdAt;

  factory DirectReferralIncomeHistory.fromJson(Map<String, dynamic> json) => DirectReferralIncomeHistory(
        id: int.tryParse(json["id"]?.toString() ?? "0") ?? 0,
        amount: double.tryParse(json["amount"]?.toString() ?? "0") ?? 0.0,
        incomeType: json["income_type"] ?? "",
        description: json["description"] ?? "",
        percentage: json["percentage"] != null
            ? double.tryParse(json["percentage"].toString()) ?? 0.0
            : 0.0,
        referenceId: json["reference_id"]?.toString() ?? "",
        status: json["status"] ?? "",
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "amount": amount,
        "income_type": incomeType,
        "description": description,
        "percentage": percentage,
        "reference_id": referenceId,
        "status": status,
        "created_at": createdAt.toIso8601String(),
      };
}

// Level Income Model
LevelIncomeModel levelIncomeModelFromJson(String str) =>
    LevelIncomeModel.fromJson(json.decode(str));

String levelIncomeModelToJson(LevelIncomeModel data) => json.encode(data.toJson());

class LevelIncomeModel {
  LevelIncomeModel({
    required this.status,
    required this.message,
    required this.responsecode,
    required this.data,
  });

  String status;
  String message;
  String responsecode;
  LevelIncomeData data;

  factory LevelIncomeModel.fromJson(Map<String, dynamic> json) => LevelIncomeModel(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        responsecode: json["responsecode"] ?? "",
        data: LevelIncomeData.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "responsecode": responsecode,
        "data": data.toJson(),
      };
}

class LevelIncomeData {
  LevelIncomeData({
    required this.totalLevelIncome,
    required this.incomeHistory,
  });

  double totalLevelIncome;
  List<LevelIncomeHistory> incomeHistory;

  factory LevelIncomeData.fromJson(Map<String, dynamic> json) => LevelIncomeData(
        totalLevelIncome: (json["total_level_income"] ?? 0).toDouble(),
        incomeHistory: json["income_history"] != null
            ? List<LevelIncomeHistory>.from(
                json["income_history"].map((x) => LevelIncomeHistory.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "total_level_income": totalLevelIncome,
        "income_history": List<dynamic>.from(incomeHistory.map((x) => x.toJson())),
      };
}

class LevelIncomeHistory {
  LevelIncomeHistory({
    required this.id,
    required this.amount,
    required this.incomeType,
    required this.description,
    required this.level,
    required this.percentage,
    required this.referenceId,
    required this.status,
    required this.createdAt,
  });

  int id;
  double amount;
  String incomeType;
  String description;
  int level;
  double percentage;
  String referenceId;
  String status;
  DateTime createdAt;

  factory LevelIncomeHistory.fromJson(Map<String, dynamic> json) => LevelIncomeHistory(
        id: int.tryParse(json["id"]?.toString() ?? "0") ?? 0,
        amount: double.tryParse(json["amount"]?.toString() ?? "0") ?? 0.0,
        incomeType: json["income_type"] ?? "",
        description: json["description"] ?? "",
        level: int.tryParse(json["level"]?.toString() ?? "0") ?? 0,
        percentage: double.tryParse(json["percentage"]?.toString() ?? "0") ?? 0.0,
        referenceId: json["reference_id"]?.toString() ?? "",
        status: json["status"] ?? "",
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "amount": amount,
        "income_type": incomeType,
        "description": description,
        "level": level,
        "percentage": percentage,
        "reference_id": referenceId,
        "status": status,
        "created_at": createdAt.toIso8601String(),
      };
}

// Salary Income Model
SalaryIncomeModel salaryIncomeFromJson(String str) =>
    SalaryIncomeModel.fromJson(json.decode(str));

String salaryIncomeToJson(SalaryIncomeModel data) => json.encode(data.toJson());

class SalaryIncomeModel {
  SalaryIncomeModel({
    required this.status,
    required this.message,
    required this.responsecode,
    required this.data,
  });

  String status;
  String message;
  String responsecode;
  SalaryIncomeData data;

  factory SalaryIncomeModel.fromJson(Map<String, dynamic> json) => SalaryIncomeModel(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        responsecode: json["responsecode"] ?? "",
        data: SalaryIncomeData.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "responsecode": responsecode,
        "data": data.toJson(),
      };
}

class SalaryIncomeData {
  SalaryIncomeData({
    required this.totalSalaryIncome,
    required this.salaryHistory,
  });

  double totalSalaryIncome;
  List<SalaryIncomeHistory> salaryHistory;

  factory SalaryIncomeData.fromJson(Map<String, dynamic> json) {
    List<SalaryIncomeHistory> history = [];

    if (json["salary_history"] != null) {
      history = List<SalaryIncomeHistory>.from(
          json["salary_history"].map((x) => SalaryIncomeHistory.fromJson(x)));
    } else if (json["data"] != null) {
      history = List<SalaryIncomeHistory>.from(
          json["data"].map((x) => SalaryIncomeHistory.fromJson(x)));
    }

    // Calculate total from history if not provided
    double total = (json["total_salary_income"] ?? 0).toDouble();
    if (total == 0.0 && history.isNotEmpty) {
      total = history.fold(0.0, (sum, item) => sum + item.amount);
    }

    return SalaryIncomeData(
      totalSalaryIncome: total,
      salaryHistory: history,
    );
  }

  Map<String, dynamic> toJson() => {
        "total_salary_income": totalSalaryIncome,
        "salary_history": List<dynamic>.from(salaryHistory.map((x) => x.toJson())),
      };
}

class SalaryIncomeHistory {
  SalaryIncomeHistory({
    required this.id,
    required this.amount,
    required this.incomeType,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  int id;
  double amount;
  String incomeType;
  String description;
  String status;
  DateTime createdAt;

  factory SalaryIncomeHistory.fromJson(Map<String, dynamic> json) => SalaryIncomeHistory(
        id: int.tryParse(json["id"]?.toString() ?? "0") ?? 0,
        amount: double.tryParse(json["amount"]?.toString() ?? "0") ?? 0.0,
        incomeType: json["income_type"] ?? "",
        description: json["description"] ?? "",
        status: json["status"] ?? "",
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "amount": amount,
        "income_type": incomeType,
        "description": description,
        "status": status,
        "created_at": createdAt.toIso8601String(),
      };
}
