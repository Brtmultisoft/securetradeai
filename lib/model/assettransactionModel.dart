// To parse this JSON data, do
//
//     final transactiondetail = transactiondetailFromJson(jsonString);

import 'dart:convert';

AssetTransactiondetail transactiondetailFromJson(String str) =>
    AssetTransactiondetail.fromJson(json.decode(str));

String transactiondetailToJson(AssetTransactiondetail data) =>
    json.encode(data.toJson());

class AssetTransactiondetail {
  AssetTransactiondetail({
    required this.status,
    required this.message,
    required this.responsecode,
    required this.data,
  });

  String status;
  String message;
  String responsecode;
  Data data;

  factory AssetTransactiondetail.fromJson(Map<String, dynamic> json) =>
      AssetTransactiondetail(
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
    required this.totalBalance,
  });

  List<Detail> details;
  String totalBalance;

  factory Data.fromJson(Map<String, dynamic> json) {
    var detailsData = json["details"];
    List<Detail> detailsList = [];

    // Handle case where details is a string instead of an array
    if (detailsData is String) {
      try {
        // Try to parse the string as JSON
        var parsedDetails = jsonDecode(detailsData);
        if (parsedDetails is List) {
          detailsList = List<Detail>.from(parsedDetails.map((x) => Detail.fromJson(x)));
        }
      } catch (e) {
        // If parsing fails, set to empty array
        detailsList = [];
      }
    } else if (detailsData is List) {
      detailsList = List<Detail>.from(detailsData.map((x) => Detail.fromJson(x)));
    }

    // Handle case where total_balance is a boolean
    var totalBalanceValue = "0.0";
    var totalBalance = json["total_balance"];
    if (totalBalance is bool) {
      totalBalanceValue = "0.0";
    } else if (totalBalance != null) {
      totalBalanceValue = totalBalance.toString();
    }

    return Data(
      details: detailsList,
      totalBalance: totalBalanceValue,
    );
  }

  Map<String, dynamic> toJson() => {
        "details": List<dynamic>.from(details.map((x) => x.toJson())),
        "total_balance": totalBalance,
      };
}

class Detail {
  Detail({
    required this.id,
    required this.userId,
    required this.cr,
    required this.dr,
    required this.charges,
    this.descr,
    required this.type,
    required this.hashkey,
    required this.status,
    required this.createdDate,
    required this.modifiedDate,
  });

  String id;
  String userId;
  String cr;
  String dr;
  String charges;
  dynamic descr;
  String type;
  dynamic hashkey;
  String status;
  DateTime createdDate;
  DateTime modifiedDate;

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        id: json["id"],
        userId: json["user_id"],
        cr: json["cr"],
        dr: json["dr"],
        charges: json["charges"],
        descr: json["descr"],
        type: json["type"],
        hashkey: json["hashkey"],
        status: json["status"],
        createdDate: DateTime.parse(json["created_date"]),
        modifiedDate: DateTime.parse(json["modified_date"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "cr": cr,
        "dr": dr,
        "charges": charges,
        "descr": descr,
        "type": type,
        "hashkey": hashkey,
        "status": status,
        "created_date": createdDate.toIso8601String(),
        "modified_date": modifiedDate.toIso8601String(),
      };
}
