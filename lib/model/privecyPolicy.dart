// To parse this JSON data, do
//
//     final privacyPolicy = privacyPolicyFromJson(jsonString);

import 'dart:convert';

PrivacyPolicy privacyPolicyFromJson(String str) =>
    PrivacyPolicy.fromJson(json.decode(str));

String privacyPolicyToJson(PrivacyPolicy data) => json.encode(data.toJson());

class PrivacyPolicy {
  PrivacyPolicy({
    required this.status,
    required this.message,
    required this.responsecode,
    required this.data,
  });

  String status;
  String message;
  String responsecode;
  Data data;

  factory PrivacyPolicy.fromJson(Map<String, dynamic> json) => PrivacyPolicy(
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
    required this.id,
    required this.section,
    required this.name,
    required this.content,
  });

  String id;
  String section;
  String name;
  String content;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        section: json["section"],
        name: json["name"],
        content: json["content"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "section": section,
        "name": name,
        "content": content,
      };
}
