import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:securetradeai/Data/Api.dart';
import 'package:securetradeai/data/strings.dart';

class WalletService {

  // Generate a new wallet for the user
  static Future<Map<String, dynamic>> generateWallet(String userId) async {
    try {
      final response = await http.post(
        Uri.parse(generateWalletUrl),
        body: json.encode({"user_id": userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Exception: $e',
      };
    }
  }

  // Get deposit history for a user
  static Future<Map<String, dynamic>> getDepositHistory(String userId) async {
    print('🔄 Getting deposit history for user ID: $userId');

    try {
      // Validate user ID
      if (userId.isEmpty || userId == "23") {
        print('❌ Invalid user ID: $userId');
        return {
          'status': 'error',
          'message': 'Invalid user ID. Please log in again.',
        };
      }

      // First try to get history from user profile
      try {
        print('📤 Checking user profile for deposit history');
        final profileResponse = await http.post(
          Uri.parse(mine),
          body: json.encode({"user_id": userId}),
        );

        if (profileResponse.statusCode == 200) {
          final profileData = json.decode(profileResponse.body);
          print('📥 Profile response status: ${profileData['status']}');

          if (profileData['status'] == 'success' &&
              profileData['data'] != null &&
              profileData['data'].isNotEmpty) {

            var userData = profileData['data'][0];
            print('📥 User data keys: ${userData.keys.join(', ')}');

            // Check for wallet_history or transactions field
            if (userData.containsKey('wallet_history') &&
                userData['wallet_history'] != null) {

              var historyData = userData['wallet_history'];

              // Handle case where history is returned as a string
              if (historyData is String) {
                try {
                  historyData = json.decode(historyData);
                  print('✅ Successfully parsed wallet_history string to JSON');
                } catch (e) {
                  print('⚠️ Failed to parse wallet_history string: $e');
                  historyData = [];
                }
              }

              print('✅ Found ${historyData is List ? historyData.length : 0} history items in user profile');
              return {
                'status': 'success',
                'data': {
                  'history': historyData
                }
              };
            } else if (userData.containsKey('transactions') &&
                       userData['transactions'] != null) {

              var historyData = userData['transactions'];

              // Handle case where transactions is returned as a string
              if (historyData is String) {
                try {
                  historyData = json.decode(historyData);
                  print('✅ Successfully parsed transactions string to JSON');
                } catch (e) {
                  print('⚠️ Failed to parse transactions string: $e');
                  historyData = [];
                }
              }

              print('✅ Found ${historyData is List ? historyData.length : 0} transaction items in user profile');
              return {
                'status': 'success',
                'data': {
                  'history': historyData
                }
              };
            }
          }
        }
      } catch (profileError) {
        print('⚠️ Error checking profile for history: $profileError');
      }

      // If we couldn't get history from profile, try the wallet info API
      print('📤 Sending request to wallet info API for history: $getWalletInfoUrl');
      final response = await http.post(
        Uri.parse(getWalletInfoUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"user_id": userId}),
      );

      print('📥 Wallet API response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📥 Wallet API response status: ${data['status']}');

        if (data['status'] == 'success' && data['data'] != null) {
          var historyData = data['data']['history'] ?? [];

          // Handle case where history is returned as a string
          if (historyData is String) {
            try {
              historyData = json.decode(historyData);
              print('✅ Successfully parsed history string to JSON');
            } catch (e) {
              print('⚠️ Failed to parse history string: $e');
              historyData = [];
            }
          }

          print('✅ Found ${historyData is List ? historyData.length : 0} history items from wallet API');
          return {
            'status': 'success',
            'data': {
              'history': historyData
            }
          };
        } else {
          print('⚠️ No history data found in wallet API response');
          return {
            'status': 'success',
            'data': {
              'history': []
            }
          };
        }
      } else {
        print('❌ Server error: ${response.statusCode}');
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Exception during history retrieval: $e');
      return {
        'status': 'error',
        'message': 'Exception: $e',
      };
    }
  }

  // Monitor a wallet for deposits
  static Future<Map<String, dynamic>> monitorWallet(
      String walletAddress, String privateKey) async {
    print('🔄 Monitoring wallet: $walletAddress');
    print('🔄 Private key length: ${privateKey.length}');

    // Validate inputs
    if (walletAddress.isEmpty) {
      print('❌ Empty wallet address');
      return {
        'status': 'error',
        'message': 'Wallet address cannot be empty',
      };
    }

    if (privateKey.isEmpty) {
      print('❌ Empty private key, attempting to retrieve it');

      try {
        // Try to get the private key from the wallet info API
        final result = await getWalletInfo(commonuserId);

        if (result['status'] == 'success' && result['data'] != null) {
          // Try multiple possible field names for private key
          String? retrievedKey;

          if (result['data']['private_key'] != null &&
              result['data']['private_key'].toString().isNotEmpty) {
            retrievedKey = result['data']['private_key'];
            print('✅ Successfully retrieved private_key');
          } else if (result['data']['pay_private_key'] != null &&
                     result['data']['pay_private_key'].toString().isNotEmpty) {
            retrievedKey = result['data']['pay_private_key'];
            print('✅ Successfully retrieved pay_private_key');
          }

          if (retrievedKey != null) {
            print('✅ Successfully retrieved private key from wallet info');
            privateKey = retrievedKey;
          } else {
            print('❌ No private key found in response');
            print('❌ Available fields: ${result['data'].keys.join(', ')}');
            return {
              'status': 'error',
              'message': 'Private key not found in wallet data',
            };
          }
        } else {
          print('❌ Failed to retrieve private key from wallet info');
          return {
            'status': 'error',
            'message': 'Private key is missing and could not be retrieved',
          };
        }
      } catch (e) {
        print('❌ Error retrieving private key: $e');
        return {
          'status': 'error',
          'message': 'Error retrieving private key: $e',
        };
      }
    }

    try {
      print('📤 Sending request to: $monitorWalletUrl');
      final response = await http.post(
        Uri.parse(monitorWalletUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "wallet_address": walletAddress,
          "private_key": privateKey,
        }),
      );

      print('📥 Response status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          print('✅ Wallet monitoring successful');
        } else {
          print('⚠️ Wallet monitoring returned error: ${data['message']}');
        }
        return data;
      } else {
        print('❌ Server error: ${response.statusCode}');
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Exception during wallet monitoring: $e');
      return {
        'status': 'error',
        'message': 'Exception: $e',
      };
    }
  }

  // Get wallet information for a user
  static Future<Map<String, dynamic>> getWalletInfo(String userId) async {
    print('🔄 Getting wallet info for user ID: $userId');

    try {
      // Validate user ID
      if (userId.isEmpty || userId == "23") {
        print('❌ Invalid user ID: $userId');
        return {
          'status': 'error',
          'message': 'Invalid user ID. Please log in again.',
        };
      }

      // First try to get user profile data to check for pay_address
      try {
        print('📤 Checking user profile data for wallet address');
        final profileResponse = await http.post(
          Uri.parse(mine),
          body: json.encode({"user_id": userId}),
        );

        if (profileResponse.statusCode == 200) {
          final profileData = json.decode(profileResponse.body);
          print('📥 Profile response: ${profileResponse.body}');

          // Check if profile data contains pay_address
          if (profileData['status'] == 'success' &&
              profileData['data'] != null &&
              profileData['data'].isNotEmpty) {

            var userData = profileData['data'][0];
            if (userData.containsKey('pay_address') &&
                userData['pay_address'] != null &&
                userData['pay_address'].toString().isNotEmpty) {

              print('✅ Found pay_address in user profile: ${userData['pay_address']}');
              // Try to get private key from multiple possible field names
              String privateKey = '';
              if (userData.containsKey('private_key') &&
                  userData['private_key'] != null &&
                  userData['private_key'].toString().isNotEmpty) {
                privateKey = userData['private_key'];
                print('✅ Found private_key in user profile');
              } else if (userData.containsKey('pay_private_key') &&
                         userData['pay_private_key'] != null &&
                         userData['pay_private_key'].toString().isNotEmpty) {
                privateKey = userData['pay_private_key'];
                print('✅ Found pay_private_key in user profile');
              }

              if (privateKey.isEmpty) {
                print('⚠️ No private key found in user profile, available fields: ${userData.keys.join(', ')}');
              }

              return {
                'status': 'success',
                'data': {
                  'pay_address': userData['pay_address'],
                  'private_key': privateKey,
                  'pay_private_key': privateKey,
                  'balance': userData['balance'] ?? '0.00',
                  'history': userData['wallet_history'] ?? []
                }
              };
            } else {
              print('ℹ️ No pay_address found in user profile');
            }
          }
        }
      } catch (profileError) {
        print('⚠️ Error checking profile data: $profileError');
        // Continue to wallet info API if profile check fails
      }

      print('📤 Sending request to wallet info API: $getWalletInfoUrl');
      final response = await http.post(
        Uri.parse(getWalletInfoUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"user_id": userId}),
      );

      print('📥 Wallet API response status code: ${response.statusCode}');
      print('📥 Wallet API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Wallet info retrieved successfully: ${data['status']}');

        // Check if the user has a pay_address
        if (data['status'] == 'success' &&
            data['data'] != null &&
            data['data']['pay_address'] != null &&
            data['data']['pay_address'].toString().isNotEmpty) {
          print('✅ User has existing wallet address: ${data['data']['pay_address']}');
        } else if (data['status'] == 'success') {
          print('ℹ️ User does not have a wallet address yet');
        }

        return data;
      } else {
        print('❌ Server error: ${response.statusCode}');
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Exception during wallet info retrieval: $e');
      return {
        'status': 'error',
        'message': 'Exception: $e',
      };
    }
  }
}
