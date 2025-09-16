import 'dart:convert';
import 'package:flutter/material.dart';

// Main response model
class DepositHistoryResponse {
  final String status;
  final String message;
  final String responsecode;
  final DepositHistoryData? data;

  DepositHistoryResponse({
    required this.status,
    required this.message,
    required this.responsecode,
    this.data,
  });

  factory DepositHistoryResponse.fromJson(Map<String, dynamic> json) {
    return DepositHistoryResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      responsecode: json['responsecode'] ?? '',
      data: json['data'] != null ? DepositHistoryData.fromJson(json['data']) : null,
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
class DepositHistoryData {
  final List<DepositTransaction> details;
  final String totalBalance;

  DepositHistoryData({
    required this.details,
    required this.totalBalance,
  });

  factory DepositHistoryData.fromJson(Map<String, dynamic> json) {
    return DepositHistoryData(
      details: (json['details'] as List<dynamic>?)
          ?.map((item) => DepositTransaction.fromJson(item))
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
class DepositTransaction {
  final String id;
  final String userId;
  final String cr;
  final String dr;
  final String charges;
  final String descr;
  final String type;
  final String? hashkey;
  final String? address;
  final String? inCat;
  final String status;
  final String createdDate;
  final String modifiedDate;

  DepositTransaction({
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

  factory DepositTransaction.fromJson(Map<String, dynamic> json) {
    return DepositTransaction(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      cr: json['cr']?.toString() ?? '0',
      dr: json['dr']?.toString() ?? '0',
      charges: json['charges']?.toString() ?? '0',
      descr: json['descr']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      hashkey: json['hashkey']?.toString(),
      address: json['address']?.toString(),
      inCat: json['in_cat']?.toString(),
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
      'descr': descr,
      'type': type,
      'hashkey': hashkey,
      'address': address,
      'in_cat': inCat,
      'status': status,
      'created_date': createdDate,
      'modified_date': modifiedDate,
    };
  }

  // Helper getters
  double get amount => double.tryParse(cr) ?? 0.0; // For deposits, credit is the main amount
  double get chargesAmount => double.tryParse(charges) ?? 0.0;
  
  // Status color helper
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFA500); // Orange
      case 'success':
      case 'completed':
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

  // Transaction type icon helper
  IconData get typeIcon {
    switch (type.toLowerCase()) {
      case 'transfer_in':
        return Icons.call_received;
      case 'deposit':
        return Icons.add_circle;
      case 'bonus':
        return Icons.card_giftcard;
      default:
        return Icons.account_balance_wallet;
    }
  }

  // Transaction type color helper
  Color get typeColor {
    switch (type.toLowerCase()) {
      case 'transfer_in':
        return const Color(0xFF2196F3); // Blue
      case 'deposit':
        return const Color(0xFF4CAF50); // Green
      case 'bonus':
        return const Color(0xFFFF9800); // Orange
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }
}

// Helper function to parse JSON response
DepositHistoryResponse depositHistoryResponseFromJson(String str) {
  return DepositHistoryResponse.fromJson(json.decode(str));
}

// Helper function to convert to JSON string
String depositHistoryResponseToJson(DepositHistoryResponse data) {
  return json.encode(data.toJson());
}
