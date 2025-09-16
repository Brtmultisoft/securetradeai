import 'dart:convert';
import 'package:flutter/material.dart';

// Main response model
class WithdrawalHistoryResponse {
  final String status;
  final String message;
  final String responsecode;
  final WithdrawalHistoryData? data;

  WithdrawalHistoryResponse({
    required this.status,
    required this.message,
    required this.responsecode,
    this.data,
  });

  factory WithdrawalHistoryResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawalHistoryResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      responsecode: json['responsecode'] ?? '',
      data: json['data'] != null ? WithdrawalHistoryData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'responsecode': responsecode,
      'data': data?.toJson(),
    };
  }

  bool get isSuccess => status.toLowerCase() == 'success';
}

// Data container model
class WithdrawalHistoryData {
  final List<WithdrawalTransaction> details;
  final String totalBalance;

  WithdrawalHistoryData({
    required this.details,
    required this.totalBalance,
  });

  factory WithdrawalHistoryData.fromJson(Map<String, dynamic> json) {
    return WithdrawalHistoryData(
      details: (json['details'] as List<dynamic>?)
          ?.map((item) => WithdrawalTransaction.fromJson(item))
          .toList() ?? [],
      totalBalance: json['total_balance']?.toString() ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'details': details.map((item) => item.toJson()).toList(),
      'total_balance': totalBalance,
    };
  }
}

// Individual transaction model
class WithdrawalTransaction {
  final String id;
  final String userId;
  final String cr;
  final String dr;
  final String charges;
  final String qty;
  final String descr;
  final String type;
  final String? hashkey;
  final String address;
  final String status;
  final String createdDate;
  final String modifiedDate;

  WithdrawalTransaction({
    required this.id,
    required this.userId,
    required this.cr,
    required this.dr,
    required this.charges,
    required this.qty,
    required this.descr,
    required this.type,
    this.hashkey,
    required this.address,
    required this.status,
    required this.createdDate,
    required this.modifiedDate,
  });

  factory WithdrawalTransaction.fromJson(Map<String, dynamic> json) {
    return WithdrawalTransaction(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      cr: json['cr']?.toString() ?? '0',
      dr: json['dr']?.toString() ?? '0',
      charges: json['charges']?.toString() ?? '0',
      qty: json['qty']?.toString() ?? '0',
      descr: json['descr']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      hashkey: json['hashkey']?.toString(),
      address: json['address']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdDate: json['created_date']?.toString() ?? '',
      modifiedDate: json['modified_date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'cr': cr,
      'dr': dr,
      'charges': charges,
      'qty': qty,
      'descr': descr,
      'type': type,
      'hashkey': hashkey,
      'address': address,
      'status': status,
      'created_date': createdDate,
      'modified_date': modifiedDate,
    };
  }

  // Helper getters
  double get amount => double.tryParse(dr) ?? 0.0;
  double get chargesAmount => double.tryParse(charges) ?? 0.0;
  
  // Status color helper
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFA500); // Orange
      case 'completed':
      case 'success':
        return const Color(0xFF4CAF50); // Green
      case 'failed':
      case 'rejected':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  // Formatted date helper
  String get formattedDate {
    try {
      final date = DateTime.parse(createdDate);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return createdDate;
    }
  }
}

// Helper function to parse JSON response
WithdrawalHistoryResponse withdrawalHistoryResponseFromJson(String str) {
  return WithdrawalHistoryResponse.fromJson(json.decode(str));
}

// Helper function to convert to JSON string
String withdrawalHistoryResponseToJson(WithdrawalHistoryResponse data) {
  return json.encode(data.toJson());
}
