// To parse this JSON data, do
//
//     final banner = bannerFromJson(jsonString);

import 'dart:convert';

Banner bannerFromJson(String str) => Banner.fromJson(json.decode(str));

String bannerToJson(Banner data) => json.encode(data.toJson());

class Banner {
  Banner({
    required this.status,
    required this.message,
    required this.responsecode,
    required this.data,
  });

  String status;
  String message;
  String responsecode;
  List<Datum> data;

  factory Banner.fromJson(Map<String, dynamic> json) => Banner(
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
    required this.contestId,
    required this.bannerImage,
    required this.discountInPercent,
    this.code,
    required this.link,
    required this.type,
    required this.createdDate,
    required this.modifiedDate,
  });

  String id;
  dynamic contestId;
  String bannerImage;
  dynamic discountInPercent;
  dynamic code;
  String link;
  String type;
  DateTime createdDate;
  DateTime modifiedDate;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        contestId: json["contest_id"],
        bannerImage: json["banner_image"],
        discountInPercent: json["discount_in_percent"],
        code: json["code"],
        link: json["link"],
        type: json["type"],
        createdDate: DateTime.parse(json["created_date"]),
        modifiedDate: DateTime.parse(json["modified_date"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "contest_id": contestId,
        "banner_image": bannerImage,
        "discount_in_percent": discountInPercent,
        "code": code,
        "link": link,
        "type": type,
        "created_date": createdDate.toIso8601String(),
        "modified_date": modifiedDate.toIso8601String(),
      };
}
