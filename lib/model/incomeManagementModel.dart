// To parse this JSON data, do
//
//     final directIncome = directIncomeFromJson(jsonString);
//     final levelIncome = levelIncomeFromJson(jsonString);
//     final salaryIncome = salaryIncomeFromJson(jsonString);

import 'dart:convert';

// Direct Income Model
DirectIncomeModel directIncomeFromJson(String str) =>
    DirectIncomeModel.fromJson(json.decode(str));

String directIncomeToJson(DirectIncomeModel data) => json.encode(data.toJson());

class DirectIncomeModel {
  DirectIncomeModel({
    required this.status,
    required this.message,
    required this.responsecode,
    required this.data,
  });

  String status;
  String message;
  String responsecode;
  DirectIncomeData data;

  factory DirectIncomeModel.fromJson(Map<String, dynamic> json) => DirectIncomeModel(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        responsecode: json["responsecode"] ?? "",
        data: DirectIncomeData.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "responsecode": responsecode,
        "data": data.toJson(),
      };
}

class DirectIncomeData {
  DirectIncomeData({
    required this.totalDirectIncome,
    required this.incomeHistory,
  });

  double totalDirectIncome;
  List<DirectIncomeHistory> incomeHistory;

  factory DirectIncomeData.fromJson(Map<String, dynamic> json) => DirectIncomeData(
        totalDirectIncome: (json["total_direct_income"] ?? 0).toDouble(),
        incomeHistory: json["income_history"] != null
            ? List<DirectIncomeHistory>.from(
                json["income_history"].map((x) => DirectIncomeHistory.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "total_direct_income": totalDirectIncome,
        "income_history": List<dynamic>.from(incomeHistory.map((x) => x.toJson())),
      };
}

class DirectIncomeHistory {
  DirectIncomeHistory({
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
  int referenceId;
  String status;
  DateTime createdAt;

  factory DirectIncomeHistory.fromJson(Map<String, dynamic> json) => DirectIncomeHistory(
        id: int.tryParse(json["id"]?.toString() ?? "0") ?? 0,
        amount: double.tryParse(json["amount"]?.toString() ?? "0") ?? 0.0,
        incomeType: json["income_type"] ?? "",
        description: json["description"] ?? "",
        percentage: json["percentage"] != null
            ? double.tryParse(json["percentage"].toString()) ?? 0.0
            : 0.0,
        referenceId: json["reference_id"] != null
            ? int.tryParse(json["reference_id"].toString()) ?? 0
            : 0,
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
  int referenceId;
  String status;
  DateTime createdAt;

  factory LevelIncomeHistory.fromJson(Map<String, dynamic> json) => LevelIncomeHistory(
        id: int.tryParse(json["id"]?.toString() ?? "0") ?? 0,
        amount: double.tryParse(json["amount"]?.toString() ?? "0") ?? 0.0,
        incomeType: json["income_type"] ?? "",
        description: json["description"] ?? "",
        level: int.tryParse(json["level"]?.toString() ?? "0") ?? 0,
        percentage: double.tryParse(json["percentage"]?.toString() ?? "0") ?? 0.0,
        referenceId: int.tryParse(json["reference_id"]?.toString() ?? "0") ?? 0,
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
