import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'web_proxy_service.dart';

/// Web-specific HTTP client with CORS handling
class WebHttpClient {
  /// Make POST request with web-specific configuration
  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
  }) async {
    if (kDebugMode) {
      print('🌐 Web POST Request: $url');
    }
    
    try {
      return await WebProxyService.post(
        url.toString(),
        body: body,
        timeout: timeout,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Web HTTP Error: $e');
      }
      rethrow;
    }
  }
  
  /// Make GET request with web-specific configuration
  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    if (kDebugMode) {
      print('🌐 Web GET Request: $url');
    }
    
    try {
      return await WebProxyService.get(
        url.toString(),
        timeout: timeout,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Web HTTP Error: $e');
      }
      rethrow;
    }
  }
}