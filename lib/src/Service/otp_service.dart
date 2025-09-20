import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rapidtradeai/data/api.dart';
import 'package:rapidtradeai/model/otpModel.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';

class OtpService {
  static String? _currentRequestId;

  /// Send OTP to email
  static Future<OtpSendResponse> sendOtpToEmail({
    required String email,
    String? type,
    required BuildContext context,
  }) async {
    try {

      final requestBody = OtpSendRequest(email: email, type: type);

      final response = await http.post(
        Uri.parse(sendOtp), // This is the API constant from api.dart
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'SecureTradeAI-Mobile-App',
        },
        body: jsonEncode(requestBody.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        final otpResponse = OtpSendResponse.fromJson(data);

        if (otpResponse.isSuccess) {
          // Store requestId from nested data object
          _currentRequestId = data['data']?['requestId']?.toString();

          showtoast("OTP sent successfully", context);
          return otpResponse;
        } else {
          showtoast(otpResponse.message, context);
          return otpResponse;
        }
      } else {
        final errorResponse = OtpSendResponse(
          status: 'error',
          message: 'Server Error: ${response.statusCode}',
        );
        showtoast(errorResponse.message, context);
        return errorResponse;
      }
    } catch (e) {
      final errorResponse = OtpSendResponse(
        status: 'error',
        message: 'Network error: ${e.toString()}',
      );
      showtoast(errorResponse.message, context);
      return errorResponse;
    }
  }

  /// Verify OTP
  static Future<OtpVerifyResponse> verifyOtpCode({
    required String email,
    required String otp,
    required BuildContext context,
  }) async {
    try {

      final requestBody = OtpVerifyRequest(
        email: email,
        otp: otp,
        requestId: _currentRequestId ?? '',
      );

      final response = await http.post(
        Uri.parse(verifyOtp),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'SecureTradeAI-Mobile-App',
        },
        body: jsonEncode(requestBody.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        final verifyResponse = OtpVerifyResponse.fromJson(data);

        if (verifyResponse.isSuccess) {
          showtoast("OTP verified successfully", context);
          return verifyResponse;
        } else {
          final errorMsg = verifyResponse.data?.message ?? verifyResponse.message ?? 'Invalid OTP';
          showtoast(errorMsg, context);
          return verifyResponse;
        }
      } else {
        final errorResponse = OtpVerifyResponse(
          status: 'error',
          message: 'Server Error: ${response.statusCode}',
        );
        showtoast(errorResponse.message, context);
        return errorResponse;
      }
    } catch (e) {
      final errorResponse = OtpVerifyResponse(
        status: 'error',
        message: 'Network error: ${e.toString()}',
      );
      showtoast(errorResponse.message, context);
      return errorResponse;
    }
  }

  /// Get current request ID
  static String? get currentRequestId => _currentRequestId;

  /// Clear request ID (call this when starting a new OTP flow)
  static void clearRequestId() {
    _currentRequestId = null;
  }

  /// Check if OTP flow is ready for verification
  static bool get isReadyForVerification => _currentRequestId != null;
}
