import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rapidtradeai/Data/Api.dart';

class SubscriptionService {
  // Activate subscription for a user
  static Future<Map<String, dynamic>> activateSubscription(String userId) async {
    print('🔄 Activating subscription for user ID: $userId');

    try {
      // Validate user ID
      if (userId.isEmpty || userId == "23") {
        print('❌ Invalid user ID: $userId');
        return {
          'status': 'error',
          'message': 'Invalid user ID. Please log in again.',
        };
      }

      print('📤 Sending request to: $activateSubscriptionUrl');
      final response = await http.post(
        Uri.parse(activateSubscriptionUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"user_id": userId}),
      );

      print('📥 Response status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          print('✅ Subscription activated successfully');
          return data;
        } else {
          print('⚠️ Failed to activate subscription: ${data['message']}');
          return data;
        }
      } else {
        print('❌ Server error: ${response.statusCode}');
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Exception during subscription activation: $e');
      return {
        'status': 'error',
        'message': 'Exception: $e',
      };
    }
  }
}
