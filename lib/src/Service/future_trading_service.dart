import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:securetradeai/data/api.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/model/future_trading_models.dart';

class FutureTradingService {
  static const Duration _timeout = Duration(seconds: 15);

  /// Get dual side account balance from API
  static Future<FutureAccountSummary?> getDualSideAccountBalance() async {
    try {
      final response = await http
          .post(
            Uri.parse(dualSideAccountBalance),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'user_id': commonuserId,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final apiResponse =
            DualSideAccountBalanceResponse.fromJson(jsonDecode(response.body));

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return _parseAccountBalance(apiResponse.data!);
        } else {
          print('API Error: ${apiResponse.message}');
          return null;
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Network Error: $e');
      return null;
    }
  }

  /// Parse API response to FutureAccountSummary
  static FutureAccountSummary _parseAccountBalance(DualSideAccountData data) {
    // Use main balance values from API
    double totalWalletBalance = data.totalWalletBalance;
    double totalUnrealizedPnl = data.totalUnrealizedPnl;
    double totalMarginBalance = data.totalMarginBalance;
    double availableBalance = data.availableBalance;

    // If main values are 0, calculate from assets
    if (totalWalletBalance == 0.0 && data.assets.isNotEmpty) {
      for (var asset in data.assets) {
        totalWalletBalance += asset.walletBalance;
        totalUnrealizedPnl += asset.unrealizedProfit;
        totalMarginBalance += asset.marginBalance;
        availableBalance += asset.availableBalance;
      }
    }

    return FutureAccountSummary(
      totalWalletBalance: totalWalletBalance,
      futuresBalance:
          totalWalletBalance, // Using wallet balance as futures balance
      unrealizedPnl: totalUnrealizedPnl,
      totalRealizedProfit: 0.0, // Not provided in API, keeping as 0
      openPositionsCount: 0, // Not provided in API, keeping as 0
      todayPnl: totalUnrealizedPnl, // Using unrealized PnL as today's PnL
      currentLeverage: 1.0, // Default leverage
      availableBalance: availableBalance,
      marginBalance: totalMarginBalance,
      maxWithdrawAmount: data.maxWithdrawAmount,
      totalPositionInitialMargin: data.totalPositionInitialMargin,
      totalOpenOrderInitialMargin: data.totalOpenOrderInitialMargin,
      canTrade: data.canTrade,
      canDeposit: data.canDeposit,
      canWithdraw: data.canWithdraw,
    );
  }

  /// Get account balance with error handling and retry logic
  static Future<FutureAccountSummary?> getAccountBalanceWithRetry(
      {int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final result = await getDualSideAccountBalance();
        if (result != null) {
          return result;
        }

        // If not the last attempt, wait before retrying
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      } catch (e) {
        print('Attempt $attempt failed: $e');
        if (attempt == maxRetries) {
          rethrow;
        }
      }
    }
    return null;
  }

  /// Test API connectivity
  static Future<bool> testApiConnectivity() async {
    try {
      final response = await http
          .post(
            Uri.parse(dualSideAccountBalance),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'user_id': 'test',
            }),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
