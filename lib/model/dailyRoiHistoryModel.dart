// To parse this JSON data, do
//
//     final dailyRoiHistory = dailyRoiHistoryFromJson(jsonString);

import 'dart:convert';

DailyRoiHistoryModel dailyRoiHistoryFromJson(String str) =>
    DailyRoiHistoryModel.fromJson(json.decode(str));

String dailyRoiHistoryToJson(DailyRoiHistoryModel data) => json.encode(data.toJson());

class DailyRoiHistoryModel {
  DailyRoiHistoryModel({
    required this.status,
    required this.message,
    required this.responsecode,
    required this.data,
  });

  String status;
  String message;
  String responsecode;
  DailyRoiHistoryData data;

  factory DailyRoiHistoryModel.fromJson(Map<String, dynamic> json) => DailyRoiHistoryModel(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        responsecode: json["responsecode"] ?? "",
        data: DailyRoiHistoryData.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "responsecode": responsecode,
        "data": data.toJson(),
      };
}

class DailyRoiHistoryData {
  DailyRoiHistoryData({
    required this.investmentId,
    required this.roiHistory,
    required this.totalRoiEarned,
    required this.averageDailyRoi,
    required this.daysActive,
  });

  int investmentId;
  List<RoiHistoryItem> roiHistory;
  double totalRoiEarned;
  double averageDailyRoi;
  int daysActive;

  factory DailyRoiHistoryData.fromJson(Map<String, dynamic> json) => DailyRoiHistoryData(
        investmentId: int.tryParse(json["investment_id"]?.toString() ?? "0") ?? 0,
        roiHistory: json["roi_history"] != null
            ? List<RoiHistoryItem>.from(
                json["roi_history"].map((x) => RoiHistoryItem.fromJson(x)))
            : [],
        totalRoiEarned: double.tryParse(json["total_roi_earned"]?.toString() ?? "0") ?? 0.0,
        averageDailyRoi: double.tryParse(json["average_daily_roi"]?.toString() ?? "0") ?? 0.0,
        daysActive: int.tryParse(json["days_active"]?.toString() ?? "0") ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "investment_id": investmentId,
        "roi_history": List<dynamic>.from(roiHistory.map((x) => x.toJson())),
        "total_roi_earned": totalRoiEarned,
        "average_daily_roi": averageDailyRoi,
        "days_active": daysActive,
      };
}

class RoiHistoryItem {
  RoiHistoryItem({
    required this.id,
    required this.roiAmount,
    required this.roiPercentage,
    required this.roiDate,
    required this.createdAt,
  });

  int id;
  double roiAmount;
  double roiPercentage;
  DateTime roiDate;
  DateTime createdAt;

  factory RoiHistoryItem.fromJson(Map<String, dynamic> json) => RoiHistoryItem(
        id: int.tryParse(json["id"]?.toString() ?? "0") ?? 0,
        roiAmount: double.tryParse(json["roi_amount"]?.toString() ?? "0") ?? 0.0,
        roiPercentage: double.tryParse(json["roi_percentage"]?.toString() ?? "0") ?? 0.0,
        roiDate: json["roi_date"] != null
            ? DateTime.parse(json["roi_date"])
            : DateTime.now(),
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "roi_amount": roiAmount,
        "roi_percentage": roiPercentage,
        "roi_date": roiDate.toIso8601String().split('T')[0], // Date only
        "created_at": createdAt.toIso8601String(),
      };
}
