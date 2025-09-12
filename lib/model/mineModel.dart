// To parse this JSON data, do
//
//     final mine = mineFromJson(jsonString);

import 'dart:convert';

Mine mineFromJson(String str) => Mine.fromJson(json.decode(str));

String mineToJson(Mine data) => json.encode(data.toJson());

class Mine {
  String status;
  String message;
  String responsecode;
  List<Datum> data;

  Mine({
    required this.status,
    required this.message,
    required this.responsecode,
    required this.data,
  });

  factory Mine.fromJson(Map<String, dynamic> json) => Mine(
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
  String userId;
  String name;
  String verify;
  String email;
  String walletAddress;
  String image;
  DateTime doa;
  String balance;
  String gasBalance;
  String incomeBalance;
  String earningBalance;
  String rank;
  String country;
  dynamic code;
  String referralCode;
  String daysBal;
  String totalTeam;
  String totalActiveTeam;
  String mobile;
  String totalRoiIncome;
  String totalDirectRoiIncome;
  String totalBusinessIncome;

  Datum(
      {required this.userId,
        required this.name,
        required this.verify,
        required this.email,
        required this.walletAddress,
        required this.image,
        required this.doa,
        required this.balance,
        required this.gasBalance,
        required this.incomeBalance,
        required this.earningBalance,
        required this.rank,
        required this.country,
        this.code,
        required this.referralCode,
        required this.daysBal,
        required this.totalTeam,
        required this.totalActiveTeam,
        required this.mobile,
        required this.totalRoiIncome,
        required this.totalDirectRoiIncome,
        required this.totalBusinessIncome});

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
      userId: json["user_id"] ?? "",
      name: json["name"] ?? "",
      verify: json["verify"] ?? "0",
      email: json["email"] ?? "",
      walletAddress: json["wallet_address"] ?? "",
      image: json["image"] ?? "default.jpg",
      doa: json["doa"] != null ? DateTime.parse(json["doa"]) : DateTime.now(),
      balance: json["balance"] ?? "0",
      gasBalance: json["gas_charges"] ??
          "0", // Fixed: API sends gas_charges, not gas_balance
      incomeBalance: json["income_balance"] ?? "0",
      earningBalance : json['total_earnings']??"0",
      rank: json["rank"] ?? "0",
      country: json["country"] ?? "",
      code: json["code"],
      referralCode: json["referral_code"] ?? "",
      daysBal: json["days_bal"] ?? "0",
      totalTeam: json["total_team"] ?? "0",
      totalActiveTeam: json["active_team"] ??
          "0", // Fixed: API sends active_team, not total_active_team
      mobile: json['mobile'] ?? "",
      totalRoiIncome: json["total_roi_income"] ?? "0",
      totalDirectRoiIncome: json["total_direct_roi_income"] ?? "0",
      totalBusinessIncome: json["total_business_income"] ?? "0");

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "name": name,
    "verify": verify,
    "email": email,
    "wallet_address": walletAddress,
    "image": image,
    "doa": doa.toIso8601String(),
    "balance": balance,
    "gas_charges": gasBalance, // Fixed: API expects gas_charges
    "income_balance": incomeBalance,
    "total_earnings": earningBalance,
    "rank": rank,
    "country": country,
    "code": code,
    "referral_code": referralCode,
    "days_bal": daysBal,
    "total_team": totalTeam,
    "active_team": totalActiveTeam, // Fixed: API expects active_team
    "mobile": mobile,
    "total_roi_income": totalRoiIncome,
    "total_direct_roi_income": totalDirectRoiIncome,
    "total_business_income": totalBusinessIncome
  };
}
