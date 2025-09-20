import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Android-specific HTTP client configuration
class AndroidHttpClient {
  static http.Client? _client;
  
  /// Get configured HTTP client for Android
  static http.Client getClient() {
    if (_client != null) return _client!;
    
    _client = http.Client();
    
    // Configure for Android if needed
    if (!kIsWeb && Platform.isAndroid) {
      if (kDebugMode) {
        print('🤖 Configuring HTTP client for Android');
      }
    }
    
    return _client!;
  }
  
  /// Make POST request with Android-specific configuration
  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
  }) async {
    final client = getClient();
    
    // Default headers for Android
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'rapidtradeai-Android-App',
      'Connection': 'keep-alive',
    };
    
    // Merge with provided headers
    final finalHeaders = {...defaultHeaders, ...?headers};
    
    if (kDebugMode) {
      print('🌐 Android POST Request:');
      print('   URL: $url');
      print('   Headers: $finalHeaders');
      print('   Body: $body');
    }
    
    try {
      final response = await client.post(
        url,
        headers: finalHeaders,
        body: body,
      ).timeout(timeout ?? const Duration(seconds: 15));
      
      if (kDebugMode) {
        print('📱 Android Response:');
        print('   Status: ${response.statusCode}');
        print('   Headers: ${response.headers}');
        print('   Body: ${response.body}');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Android HTTP Error: $e');
      }
      rethrow;
    }
  }
  
  /// Make GET request with Android-specific configuration
  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final client = getClient();
    
    // Default headers for Android
    final defaultHeaders = {
      'Accept': 'application/json',
      'User-Agent': 'rapidtradeai-Android-App',
      'Connection': 'keep-alive',
    };
    
    // Merge with provided headers
    final finalHeaders = {...defaultHeaders, ...?headers};
    
    if (kDebugMode) {
      print('🌐 Android GET Request:');
      print('   URL: $url');
      print('   Headers: $finalHeaders');
    }
    
    try {
      final response = await client.get(
        url,
        headers: finalHeaders,
      ).timeout(timeout ?? const Duration(seconds: 15));
      
      if (kDebugMode) {
        print('📱 Android Response:');
        print('   Status: ${response.statusCode}');
        print('   Headers: ${response.headers}');
        print('   Body Length: ${response.body.length}');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Android HTTP Error: $e');
      }
      rethrow;
    }
  }
  
  /// Dispose of the client
  static void dispose() {
    _client?.close();
    _client = null;
    if (kDebugMode) {
      print('🛑 Android HTTP client disposed');
    }
  }
}
