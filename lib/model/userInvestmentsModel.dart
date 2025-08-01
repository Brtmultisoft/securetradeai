import 'dart:convert';

UserInvestmentsModel userInvestmentsFromJson(String str) =>
    UserInvestmentsModel.fromJson(json.decode(str));

String userInvestmentsToJson(UserInvestmentsModel data) =>
    json.encode(data.toJson());

class UserInvestmentsModel {
  UserInvestmentsModel({
    required this.status,
    required this.message,
    required this.responsecode,
    required this.data,
  });

  String status;
  String message;
  String responsecode;
  UserInvestmentsData data;

  factory UserInvestmentsModel.fromJson(Map<String, dynamic> json) =>
      UserInvestmentsModel(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        responsecode: json["responsecode"] ?? "",
        data: UserInvestmentsData.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "responsecode": responsecode,
        "data": data.toJson(),
      };
}

class UserInvestmentsData {
  UserInvestmentsData({
    required this.arbitrageInvestments,
    required this.summary,
  });

  List<ArbitrageInvestment> arbitrageInvestments;
  InvestmentSummary summary;

  factory UserInvestmentsData.fromJson(Map<String, dynamic> json) =>
      UserInvestmentsData(
        arbitrageInvestments: json["arbitrage_investments"] != null
            ? List<ArbitrageInvestment>.from(json["arbitrage_investments"]
                .map((x) => ArbitrageInvestment.fromJson(x)))
            : [],
        // Pass the root json data to InvestmentSummary since totals are at root level
        summary: InvestmentSummary.fromJson(json),
      );

  Map<String, dynamic> toJson() => {
        "arbitrage_investments":
            List<dynamic>.from(arbitrageInvestments.map((x) => x.toJson())),
        "summary": summary.toJson(),
      };
}

class ArbitrageInvestment {
  ArbitrageInvestment({
    required this.id,
    required this.packageType,
    required this.investmentAmount,
    required this.dailyRoiPercentage,
    required this.dailyRoiAmount,
    required this.totalRoiEarned,
    required this.status,
    required this.startDate,
    required this.daysRunning,
  });

  int id;
  String packageType;
  double investmentAmount;
  double dailyRoiPercentage;
  double dailyRoiAmount;
  double totalRoiEarned;
  String status;
  DateTime startDate;
  int daysRunning;

  factory ArbitrageInvestment.fromJson(Map<String, dynamic> json) =>
      ArbitrageInvestment(
        id: int.tryParse(json["id"]?.toString() ?? "0") ?? 0,
        packageType: json["package_type"] ?? "",
        investmentAmount:
            double.tryParse(json["investment_amount"]?.toString() ?? "0") ??
                0.0,
        dailyRoiPercentage:
            double.tryParse(json["daily_roi_percentage"]?.toString() ?? "0") ??
                0.0,
        dailyRoiAmount:
            double.tryParse(json["daily_roi_amount"]?.toString() ?? "0") ?? 0.0,
        totalRoiEarned:
            double.tryParse(json["total_roi_earned"]?.toString() ?? "0") ?? 0.0,
        status: json["status"] ?? "",
        startDate: json["start_date"] != null
            ? DateTime.parse(json["start_date"])
            : DateTime.now(),
        daysRunning: json["days_running"] != null
            ? int.tryParse(json["days_running"].toString()) ?? 0
            : DateTime.now()
                .difference(json["start_date"] != null
                    ? DateTime.parse(json["start_date"])
                    : DateTime.now())
                .inDays,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "package_type": packageType,
        "investment_amount": investmentAmount,
        "daily_roi_percentage": dailyRoiPercentage,
        "daily_roi_amount": dailyRoiAmount,
        "total_roi_earned": totalRoiEarned,
        "status": status,
        "start_date": startDate.toIso8601String(),
        "days_running": daysRunning,
      };
}

class InvestmentSummary {
  InvestmentSummary({
    required this.totalArbitrageInvestment,
    required this.totalBotInvestment,
    required this.totalInvestment,
    required this.total_arbitrage_investment,
    required this.totalRoiEarned,
  });

  double totalArbitrageInvestment;
  double totalBotInvestment;
  double totalInvestment;
  double total_arbitrage_investment;
  double totalRoiEarned;

  factory InvestmentSummary.fromJson(Map<String, dynamic> json) =>
      InvestmentSummary(
        totalArbitrageInvestment: double.tryParse(
                json["total_arbitrage_investment"]?.toString() ?? "0") ??
            0.0,
        totalBotInvestment:
            double.tryParse(json["total_bot_investment"]?.toString() ?? "0") ??
                0.0,
        totalInvestment:
            double.tryParse(json["total_investment"]?.toString() ?? "0") ?? 0.0,
        total_arbitrage_investment: double.tryParse(
                json["total_arbitrage_investment"]?.toString() ?? "0") ??
            0.0,
        // Handle both possible field names for TPS earned
        totalRoiEarned: double.tryParse(
                (json["total_roi_earned"] ?? json["total_profit_earned"] ?? "0")
                    .toString()) ??
            0.0,
      );

  Map<String, dynamic> toJson() => {
        "total_arbitrage_investment": totalArbitrageInvestment,
        "total_bot_investment": totalBotInvestment,
        "total_investment": totalInvestment,
        "total_arbitrage_investment": total_arbitrage_investment,
        "total_roi_earned": totalRoiEarned,
      };
}
