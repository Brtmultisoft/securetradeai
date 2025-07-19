// To parse this JSON data, do
//
//     final news = newsFromJson(jsonString);

import 'dart:convert';

Newsmodel newsFromJson(String str) => Newsmodel.fromJson(json.decode(str));

String newsToJson(Newsmodel data) => json.encode(data.toJson());

class Newsmodel {
  Newsmodel({
    required this.status,
    required this.message,
    required this.responsecode,
    required this.data,
  });

  String status;
  String message;
  String responsecode;
  List<Datum> data;

  factory Newsmodel.fromJson(Map<String, dynamic> json) => Newsmodel(
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
    required this.title,
    required this.message,
    this.matchId,
    this.contestId,
    this.type,
    this.userIds,
    required this.createdDate,
    required this.modifiedDate,
  });

  String id;
  String title;
  String message;
  dynamic matchId;
  dynamic contestId;
  dynamic type;
  dynamic userIds;
  DateTime createdDate;
  DateTime modifiedDate;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        title: json["title"],
        message: json["message"],
        matchId: json["match_id"],
        contestId: json["contest_id"],
        type: json["type"],
        userIds: json["user_ids"],
        createdDate: DateTime.parse(json["created_date"]),
        modifiedDate: DateTime.parse(json["modified_date"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "message": message,
        "match_id": matchId,
        "contest_id": contestId,
        "type": type,
        "user_ids": userIds,
        "created_date": createdDate.toIso8601String(),
        "modified_date": modifiedDate.toIso8601String(),
      };
}
