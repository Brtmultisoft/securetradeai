import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Web proxy service to handle CORS issues
class WebProxyService {
  static const String corsProxy = 'https://cors-anywhere.herokuapp.com/';
  static const String altProxy = 'https://api.allorigins.win/raw?url=';
  
  static Future<http.Response> get(String url, {Duration? timeout}) async {
    if (!kIsWeb) {
      return await http.get(Uri.parse(url)).timeout(timeout ?? const Duration(seconds: 15));
    }
    
    try {
      // Try direct request first
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('🔄 Direct request failed, trying proxy: $e');
      }
      
      // Try with CORS proxy
      try {
        final proxyUrl = '$altProxy${Uri.encodeComponent(url)}';
        return await http.get(Uri.parse(proxyUrl)).timeout(timeout ?? const Duration(seconds: 15));
      } catch (proxyError) {
        if (kDebugMode) {
          print('❌ Proxy request also failed: $proxyError');
        }
        rethrow;
      }
    }
  }
  
  static Future<http.Response> post(String url, {Object? body, Duration? timeout}) async {
    if (!kIsWeb) {
      return await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(timeout ?? const Duration(seconds: 15));
    }

    try {
      // For web, try direct POST first
      return await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(timeout ?? const Duration(seconds: 15));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Web POST failed: $e');
      }
      rethrow;
    }
  }

  /// Get image with CORS handling for web
  static Future<http.Response> getImage(String imageUrl) async {
    if (kDebugMode) {
      print('🖼️ Fetching image: $imageUrl');
    }

    if (!kIsWeb) {
      return await http.get(Uri.parse(imageUrl));
    }

    try {
      // Try direct request first
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'Accept': 'image/*',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ Direct image fetch successful');
        }
        return response;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Direct image fetch failed (CORS): $e');
        print('🔄 Trying proxy for image...');
      }
    }

    // Fallback to proxy for CORS issues
    try {
      final proxyUrl = '$altProxy${Uri.encodeComponent(imageUrl)}';
      final response = await http.get(
        Uri.parse(proxyUrl),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print('✅ Proxy image fetch successful');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Proxy image fetch failed: $e');
      }
      rethrow;
    }
  }
}