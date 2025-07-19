import 'dart:convert';

/// Function to parse JSON data into DepositTransactiondetail object
DepositTransactiondetail deposittransactiondetailFromJson(String str) =>
    DepositTransactiondetail.fromJson(json.decode(str));

/// Function to convert DepositTransactiondetail object to JSON string
String deposittransactiondetailToJson(DepositTransactiondetail data) =>
    json.encode(data.toJson());

/// Class representing the main deposit transaction detail object
class DepositTransactiondetail {
  DepositTransactiondetail({
    required this.status,
    required this.message,
    required this.responsecode,
    required this.data,
  });

  String status;
  String message;
  String responsecode;
  Data data;

  /// Factory method to create DepositTransactiondetail object from JSON
  factory DepositTransactiondetail.fromJson(Map<String, dynamic> json) =>
      DepositTransactiondetail(
        status: json["status"],
        message: json["message"],
        responsecode: json["responsecode"],
        data: Data.fromJson(json["data"]),
      );

  /// Method to convert DepositTransactiondetail object to JSON
  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "responsecode": responsecode,
        "data": data.toJson(),
      };
}

/// Class representing the data within the transaction, including total balance and details
class Data {
  Data({
    required this.details,
    this.totalBalance,
  });

  List<Detail> details;
  double? totalBalance;

  /// Factory method to create Data object from JSON
  factory Data.fromJson(dynamic json) {
    List<Detail> parsedDetails = [];
    
    // Handle the case where json is a List
    if (json is List) {
      parsedDetails = json.map((item) => Detail.fromJson(item)).toList();
    }

    // Calculate total balance from all transactions
    double calculatedTotalBalance = 0.0;
    for (var detail in parsedDetails) {
      if (detail.cr != "0") {
        calculatedTotalBalance += double.tryParse(detail.cr) ?? 0.0;
      }
      if (detail.dr != "0") {
        calculatedTotalBalance -= double.tryParse(detail.dr) ?? 0.0;
      }
    }

    return Data(
      details: parsedDetails,
      totalBalance: calculatedTotalBalance,
    );
  }

  /// Method to convert Data object to JSON
  Map<String, dynamic> toJson() => {
        "data": details.map((detail) => detail.toJson()).toList(),
        "total_balance": totalBalance,
      };
}

/// Class representing the details of a single transaction
class Detail {
  Detail({
    required this.id,
    required this.userId,
    required this.cr,
    required this.dr,
    required this.charges,
    this.descr,
    this.type,
    this.hashkey,
    this.address,
    this.inCat,
    this.status,
    this.royaltyStatus,
    required this.createdDate,
    required this.modifiedDate,
  });

  String id;
  String userId;
  String cr;
  String dr;
  String charges;
  String? descr;
  String? type;
  dynamic hashkey;
  dynamic address;
  dynamic inCat;
  dynamic status;
  dynamic royaltyStatus;
  DateTime createdDate;
  DateTime modifiedDate;

  /// Factory method to create Detail object from JSON
  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
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
        royaltyStatus: json["royalty_status"],
        createdDate: DateTime.parse(json["created_date"]),
        modifiedDate: DateTime.parse(json["modified_date"]),
      );

  /// Method to convert Detail object to JSON
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
        "royalty_status": royaltyStatus,
        "created_date": createdDate.toIso8601String(),
        "modified_date": modifiedDate.toIso8601String(),
      };
}
