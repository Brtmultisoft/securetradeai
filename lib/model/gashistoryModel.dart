// To parse this JSON data, do
//
//     final gasHistory = gasHistoryFromJson(jsonString);

import 'dart:convert';

GasHistory gasHistoryFromJson(String str) =>
    GasHistory.fromJson(json.decode(str));

String gasHistoryToJson(GasHistory data) => json.encode(data.toJson());

class GasHistory {
  GasHistory({
    required this.status,
    required this.message,
    required this.responsecode,
    required this.data,
  });

  String status;
  String message;
  String responsecode;
  List<Datum> data;

  factory GasHistory.fromJson(Map<String, dynamic> json) => GasHistory(
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
  Datum({
    required this.id,
    required this.userId,
    required this.cr,
    required this.dr,
    required this.charges,
    required this.descr,
    required this.type,
    this.hashkey,
    this.address,
    this.inCat,
    required this.status,
    required this.createdDate,
    required this.modifiedDate,
  });

  String id;
  String userId;
  String cr;
  String dr;
  String charges;
  String descr;
  String type;
  dynamic hashkey;
  dynamic address;
  dynamic inCat;
  String status;
  DateTime createdDate;
  DateTime modifiedDate;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        userId: json["user_id"],
        cr: json["cr"],
        dr: json["dr"],
        charges: json["charges"],
        descr: json["descr"],
        type: json["type"],
        hashkey: json["hashkey"],
        address: json["address"],
        inCat: json["in_cat"],
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
        "address": address,
        "in_cat": inCat,
        "status": status,
        "created_date": createdDate.toIso8601String(),
        "modified_date": modifiedDate.toIso8601String(),
      };
}
