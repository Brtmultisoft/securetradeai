import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'android_http_client.dart';
import 'web_http_client.dart';
import 'web_proxy_service.dart';

/// Universal HTTP service that handles platform-specific requests
class HttpService {
  /// Make POST request with platform-specific handling
  static Future<http.Response> post(
      String url, {
        Map<String, String>? headers,
        Object? body,
        Duration? timeout,
      }) async {
    final uri = Uri.parse(url);

    try {
      if (kIsWeb) {
        return await WebHttpClient.post(
          uri,
          headers: headers,
          body: body,
          timeout: timeout,
        );
      } else if (Platform.isAndroid) {
        return await AndroidHttpClient.post(
          uri,
          headers: headers,
          body: body,
          timeout: timeout,
        );
      } else {
        // Default HTTP client for other platforms
        final client = http.Client();
        final defaultHeaders = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };
        final finalHeaders = {...defaultHeaders, ...?headers};

        return await client.post(
          uri,
          headers: finalHeaders,
          body: body,
        ).timeout(timeout ?? const Duration(seconds: 30));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ HTTP Service Error: $e');
      }
      rethrow;
    }
  }

  /// Make GET request with platform-specific handling
  static Future<http.Response> get(
      String url, {
        Map<String, String>? headers,
        Duration? timeout,
      }) async {
    final uri = Uri.parse(url);

    try {
      if (kIsWeb) {
        return await WebHttpClient.get(
          uri,
          headers: headers,
          timeout: timeout,
        );
      } else if (Platform.isAndroid) {
        return await AndroidHttpClient.get(
          uri,
          headers: headers,
          timeout: timeout,
        );
      } else {
        // Default HTTP client for other platforms
        final client = http.Client();
        final defaultHeaders = {
          'Accept': 'application/json',
        };
        final finalHeaders = {...defaultHeaders, ...?headers};

        return await client.get(
          uri,
          headers: finalHeaders,
        ).timeout(timeout ?? const Duration(seconds: 30));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ HTTP Service Error: $e');
      }
      rethrow;
    }
  }

  /// Make POST request with JSON body
  static Future<http.Response> postJson(
      String url,
      Map<String, dynamic> data, {
        Map<String, String>? headers,
        Duration? timeout,
      }) async {
    return await post(
      url,
      headers: headers,
      body: json.encode(data),
      timeout: timeout,
    );
  }
}