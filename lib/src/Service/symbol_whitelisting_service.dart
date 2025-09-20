import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rapidtradeai/data/api.dart';
import 'package:rapidtradeai/data/strings.dart';

/// Service to handle symbol whitelisting functionality
class SymbolWhitelistingService {
  static const Duration _timeout = Duration(seconds: 15);
  
  // Cache to store whitelisting status to avoid repeated API calls
  static final Map<String, bool> _whitelistCache = {};
  
  /// Check if a symbol is whitelisted for trading
  /// Returns true if whitelisted, false otherwise
  static Future<bool> isSymbolWhitelisted(String symbol) async {
    try {
      // Check cache first
      if (_whitelistCache.containsKey(symbol)) {
        print('📋 Using cached whitelisting status for $symbol: ${_whitelistCache[symbol]}');
        return _whitelistCache[symbol]!;
      }
      
      print('🔄 Checking if symbol $symbol is whitelisted for user $commonuserId');
      
      final requestBody = {
        'user_id': commonuserId,
        'symbol': symbol,
      };
      
      print('📤 Request body: $requestBody');
      
      final response = await http
          .post(
            Uri.parse(testSymbolWhitelistedUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);
      
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Check if the response indicates success
        final status = responseData['status']?.toString().toLowerCase();
        final isWhitelisted = status == 'true';
        
        // Cache the result
        _whitelistCache[symbol] = isWhitelisted;
        
        print('✅ Symbol $symbol whitelisting status: $isWhitelisted');
        return isWhitelisted;
      } else {
        print('❌ Failed to check whitelisting for $symbol: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error checking symbol whitelisting for $symbol: $e');
      return false;
    }
  }
  
  /// Check multiple symbols for whitelisting status
  /// Returns a map of symbol -> whitelisting status
  static Future<Map<String, bool>> checkMultipleSymbols(List<String> symbols) async {
    final results = <String, bool>{};
    
    // Process symbols in parallel for better performance
    final futures = symbols.map((symbol) async {
      final isWhitelisted = await isSymbolWhitelisted(symbol);
      return MapEntry(symbol, isWhitelisted);
    });
    
    final entries = await Future.wait(futures);
    
    for (final entry in entries) {
      results[entry.key] = entry.value;
    }
    
    return results;
  }
  
  /// Check if all provided symbols are whitelisted
  /// Returns true only if ALL symbols are whitelisted
  static Future<bool> areAllSymbolsWhitelisted(List<String> symbols) async {
    if (symbols.isEmpty) return true;
    
    print('🔄 Checking if all ${symbols.length} symbols are whitelisted');
    
    final results = await checkMultipleSymbols(symbols);
    
    // Check if all symbols are whitelisted
    final allWhitelisted = results.values.every((isWhitelisted) => isWhitelisted);
    
    print('📊 Whitelisting results: $results');
    print('✅ All symbols whitelisted: $allWhitelisted');
    
    return allWhitelisted;
  }
  
  /// Clear the whitelisting cache
  /// Useful when user changes or when you want to force refresh
  static void clearCache() {
    _whitelistCache.clear();
    print('🗑️ Whitelisting cache cleared');
  }
  
  /// Get cached whitelisting status for a symbol
  /// Returns null if not cached
  static bool? getCachedStatus(String symbol) {
    return _whitelistCache[symbol];
  }
  
  /// Get all cached whitelisting statuses
  static Map<String, bool> getAllCachedStatuses() {
    return Map.from(_whitelistCache);
  }
}
