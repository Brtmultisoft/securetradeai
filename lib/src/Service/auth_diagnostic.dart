import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// DIAGNOSTIC: Authentication service tester
/// Use this to identify login/signup issues
class AuthDiagnostic {
  static const String baseUrl = "https://rapidtradeai.com/myrest/user/";
  static const String loginUrl = "${baseUrl}login";
  static const String registerUrl = "${baseUrl}user_registration";
  static const String otpUrl = "${baseUrl}user_emailotp";

  /// Test basic connectivity to the server
  static Future<Map<String, dynamic>> testConnectivity() async {
    final result = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'tests': <String, dynamic>{},
    };

    // Test 1: Basic website connectivity
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.get(
        Uri.parse('https://rapidtradeai.com/'),
      ).timeout(const Duration(seconds: 10));
      
      result['tests']['website'] = {
        'status': 'success',
        'statusCode': response.statusCode,
        'responseTime': '${stopwatch.elapsedMilliseconds}ms',
        'contentLength': response.body.length,
      };
    } catch (e) {
      result['tests']['website'] = {
        'status': 'failed',
        'error': e.toString(),
      };
    }

    // Test 2: API endpoint connectivity
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'mobile': 'diagnostic_test',
          'password': 'diagnostic_test',
          'type': 'Normal'
        }),
      ).timeout(const Duration(seconds: 15));
      
      result['tests']['login_endpoint'] = {
        'status': 'reachable',
        'statusCode': response.statusCode,
        'responseTime': '${stopwatch.elapsedMilliseconds}ms',
        'responseBody': response.body.length > 500 
            ? '${response.body.substring(0, 500)}...' 
            : response.body,
        'headers': response.headers.toString(),
      };
    } catch (e) {
      result['tests']['login_endpoint'] = {
        'status': 'failed',
        'error': e.toString(),
      };
    }

    // Test 3: Registration endpoint
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'uid': '',
          'email': 'diagnostic@test.com',
          'mobile': '+1234567890',
          'password': 'diagnostic123',
          'type': 'Normal',
          'name': 'Diagnostic Test',
          'otp': '000000',
          'country': 'Test Country',
          'code': 'TEST'
        }),
      ).timeout(const Duration(seconds: 15));
      
      result['tests']['register_endpoint'] = {
        'status': 'reachable',
        'statusCode': response.statusCode,
        'responseTime': '${stopwatch.elapsedMilliseconds}ms',
        'responseBody': response.body.length > 500 
            ? '${response.body.substring(0, 500)}...' 
            : response.body,
      };
    } catch (e) {
      result['tests']['register_endpoint'] = {
        'status': 'failed',
        'error': e.toString(),
      };
    }

    // Test 4: OTP endpoint
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.post(
        Uri.parse(otpUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': 'diagnostic@test.com',
          'type': 'Email'
        }),
      ).timeout(const Duration(seconds: 15));
      
      result['tests']['otp_endpoint'] = {
        'status': 'reachable',
        'statusCode': response.statusCode,
        'responseTime': '${stopwatch.elapsedMilliseconds}ms',
        'responseBody': response.body.length > 500 
            ? '${response.body.substring(0, 500)}...' 
            : response.body,
      };
    } catch (e) {
      result['tests']['otp_endpoint'] = {
        'status': 'failed',
        'error': e.toString(),
      };
    }

    return result;
  }

  /// Test login with proper headers and error handling
  static Future<Map<String, dynamic>> testLogin(String mobile, String password) async {
    final result = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'endpoint': loginUrl,
      'request': {
        'mobile': mobile,
        'password': '***hidden***',
        'type': 'Normal',
      },
    };

    try {
      final stopwatch = Stopwatch()..start();
      
      final requestBody = jsonEncode({
        'mobile': mobile,
        'password': password,
        'type': 'Normal'
      });

      if (kDebugMode) {
        print('🔍 LOGIN DIAGNOSTIC - Request Body: $requestBody');
      }

      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'rapidtradeai-Mobile-App',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 15));

      result['response'] = {
        'statusCode': response.statusCode,
        'responseTime': '${stopwatch.elapsedMilliseconds}ms',
        'headers': response.headers,
        'bodyLength': response.body.length,
        'body': response.body,
      };

      // Parse response if possible
      try {
        final data = jsonDecode(response.body);
        result['parsedResponse'] = data;
        result['success'] = data['status'] == 'success';
      } catch (e) {
        result['parseError'] = e.toString();
        result['success'] = false;
      }

    } catch (e) {
      result['error'] = e.toString();
      result['success'] = false;
      
      if (e is SocketException) {
        result['errorType'] = 'network';
        result['suggestion'] = 'Check internet connection or server availability';
      } else if (e is HttpException) {
        result['errorType'] = 'http';
        result['suggestion'] = 'Server returned an HTTP error';
      } else if (e.toString().contains('timeout')) {
        result['errorType'] = 'timeout';
        result['suggestion'] = 'Server is taking too long to respond';
      } else {
        result['errorType'] = 'unknown';
        result['suggestion'] = 'Unknown error occurred';
      }
    }

    return result;
  }

  /// Test registration with proper headers and error handling
  static Future<Map<String, dynamic>> testRegistration({
    required String email,
    required String mobile,
    required String password,
    required String name,
    required String otp,
    required String country,
    String code = '',
  }) async {
    final result = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'endpoint': registerUrl,
    };

    try {
      final stopwatch = Stopwatch()..start();
      
      final requestBody = jsonEncode({
        'uid': '',
        'email': email,
        'mobile': mobile,
        'password': password,
        'type': 'Normal',
        'name': name,
        'otp': otp,
        'country': country,
        'code': code,
      });

      if (kDebugMode) {
        print('🔍 REGISTRATION DIAGNOSTIC - Request Body: $requestBody');
      }

      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'rapidtradeai-Mobile-App',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 15));

      result['response'] = {
        'statusCode': response.statusCode,
        'responseTime': '${stopwatch.elapsedMilliseconds}ms',
        'headers': response.headers,
        'bodyLength': response.body.length,
        'body': response.body,
      };

      // Parse response if possible
      try {
        final data = jsonDecode(response.body);
        result['parsedResponse'] = data;
        result['success'] = data['status'] == 'success';
      } catch (e) {
        result['parseError'] = e.toString();
        result['success'] = false;
      }

    } catch (e) {
      result['error'] = e.toString();
      result['success'] = false;
      
      if (e is SocketException) {
        result['errorType'] = 'network';
      } else if (e.toString().contains('timeout')) {
        result['errorType'] = 'timeout';
      } else {
        result['errorType'] = 'unknown';
      }
    }

    return result;
  }

  /// Print diagnostic results in a readable format
  static void printResults(Map<String, dynamic> results) {
    if (kDebugMode) {
      print('🔍 ========== AUTH DIAGNOSTIC RESULTS ==========');
      print('Timestamp: ${results['timestamp']}');
      
      if (results.containsKey('tests')) {
        print('\n📊 CONNECTIVITY TESTS:');
        final tests = results['tests'] as Map<String, dynamic>;
        tests.forEach((key, value) {
          final status = value['status'] ?? 'unknown';
          final icon = status == 'success' || status == 'reachable' ? '✅' : '❌';
          print('$icon $key: $status');
          if (value.containsKey('responseTime')) {
            print('   Response Time: ${value['responseTime']}');
          }
          if (value.containsKey('error')) {
            print('   Error: ${value['error']}');
          }
        });
      }
      
      if (results.containsKey('response')) {
        print('\n📡 API RESPONSE:');
        final response = results['response'];
        print('Status Code: ${response['statusCode']}');
        print('Response Time: ${response['responseTime']}');
        print('Body: ${response['body']}');
      }
      
      if (results.containsKey('error')) {
        print('\n❌ ERROR DETAILS:');
        print('Error: ${results['error']}');
        print('Type: ${results['errorType']}');
        if (results.containsKey('suggestion')) {
          print('Suggestion: ${results['suggestion']}');
        }
      }
      
      print('🔍 ============================================');
    }
  }
}
