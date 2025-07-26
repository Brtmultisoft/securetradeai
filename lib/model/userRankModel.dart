// To parse this JSON data, do
//
//     final userRank = userRankFromJson(jsonString);

import 'dart:convert';

UserRankModel userRankFromJson(String str) =>
    UserRankModel.fromJson(json.decode(str));

String userRankToJson(UserRankModel data) => json.encode(data.toJson());

class UserRankModel {
  UserRankModel({
    required this.status,
    required this.message,
    required this.responsecode,
    required this.data,
  });

  String status;
  String message;
  String responsecode;
  UserRankData data;

  factory UserRankModel.fromJson(Map<String, dynamic> json) => UserRankModel(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        responsecode: json["responsecode"] ?? "",
        data: UserRankData.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "responsecode": responsecode,
        "data": data.toJson(),
      };
}

class UserRankData {
  UserRankData({
    required this.userId,
    required this.name,
    required this.currentRank,
    required this.teamBusiness,
    required this.directReferrals,
    required this.teamMembers,
    required this.totalInvestment,
    required this.totalEarnings,
    required this.nextRank,
    required this.nextRankRequirement,
    required this.progressPercentage,
  });

  String userId;
  String name;
  String currentRank;
  double teamBusiness;
  int directReferrals;
  int teamMembers;
  double totalInvestment;
  double totalEarnings;
  String nextRank;
  double nextRankRequirement;
  double progressPercentage;

  factory UserRankData.fromJson(Map<String, dynamic> json) => UserRankData(
        userId: json["user_id"]?.toString() ?? "",
        name: json["name"] ?? "",
        currentRank: json["current_rank"] ?? "",
        teamBusiness: double.tryParse(json["team_business"]?.toString() ?? "0") ?? 0.0,
        directReferrals: int.tryParse(json["direct_referrals"]?.toString() ?? "0") ?? 0,
        teamMembers: int.tryParse(json["team_members"]?.toString() ?? "0") ?? 0,
        totalInvestment: double.tryParse(json["total_investment"]?.toString() ?? "0") ?? 0.0,
        totalEarnings: double.tryParse(json["total_earnings"]?.toString() ?? "0") ?? 0.0,
        nextRank: json["next_rank"] ?? "",
        nextRankRequirement: double.tryParse(json["next_rank_requirement"]?.toString() ?? "0") ?? 0.0,
        progressPercentage: double.tryParse(json["progress_percentage"]?.toString() ?? "0") ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "name": name,
        "current_rank": currentRank,
        "team_business": teamBusiness,
        "direct_referrals": directReferrals,
        "team_members": teamMembers,
        "total_investment": totalInvestment,
        "total_earnings": totalEarnings,
        "next_rank": nextRank,
        "next_rank_requirement": nextRankRequirement,
        "progress_percentage": progressPercentage,
      };
}
