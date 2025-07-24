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

  /// Initialize dual-side trading strategy
  static Future<DualSideInitResponse?> initializeDualSideStrategy({
    required String userId,
    required String symbol,
    required double positionSize,
    required double tpPercentage,
    required int leverage,
  }) async {
    try {
      print('🚀 Initializing dual-side strategy for $symbol');
      print('📊 Position Size: $positionSize, TP: $tpPercentage%, Leverage: ${leverage}x');

      final requestBody = {
        'user_id': userId,
        'symbol': symbol,
        'position_size': positionSize,
        'tp_percentage': tpPercentage,
        'leverage': leverage,
      };

      print('📤 Request Body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse(dualSideInit),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse = DualSideInitResponse.fromJson(responseData);

        if (apiResponse.isSuccess) {
          print('✅ Dual-side strategy initialized successfully');
          print('🆔 Pair ID: ${apiResponse.data?.pairId}');
          print('💰 Entry Price: \$${apiResponse.data?.entryPrice}');
          return apiResponse;
        } else {
          print('❌ API Error: ${apiResponse.message}');
          return apiResponse; // Return even if not successful to show error message
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode} - ${response.body}');
        return DualSideInitResponse(
          status: 'error',
          message: 'Server error: ${response.statusCode}',
          responsecode: response.statusCode.toString(),
          data: null,
        );
      }
    } catch (e) {
      print('❌ Network Error: $e');
      return DualSideInitResponse(
        status: 'error',
        message: 'Network error: $e',
        responsecode: '0',
        data: null,
      );
    }
  }

  /// Get dual-side trade history
  static Future<DualSideTradeHistoryResponse?> getDualSideTradeHistory({
    required String userId,
    String? symbol,
    String? status,
    String? dateFrom,
    String? dateTo,
    String? strategyType,
    int? limit,
    int? offset,
  }) async {
    try {
      print('📊 Fetching dual-side trade history...');
      print('👤 User ID: $userId');
      if (symbol != null) print('💱 Symbol: $symbol');
      if (status != null) print('📈 Status: $status');
      if (dateFrom != null || dateTo != null) print('📅 Date Range: ${dateFrom ?? 'N/A'} to ${dateTo ?? 'N/A'}');
      if (strategyType != null) print('🎯 Strategy Type: $strategyType');
      if (limit != null || offset != null) print('📄 Limit: ${limit ?? 'default'}, Offset: ${offset ?? 'default'}');

      // Start with only required parameter
      final requestBody = <String, dynamic>{
        'user_id': userId,
      };

      // Add optional parameters only if provided
      if (symbol != null && symbol.isNotEmpty) {
        requestBody['symbol'] = symbol;
      }
      if (status != null && status.isNotEmpty) {
        requestBody['status'] = status;
      }
      if (dateFrom != null && dateFrom.isNotEmpty) {
        requestBody['date_from'] = dateFrom;
      }
      if (dateTo != null && dateTo.isNotEmpty) {
        requestBody['date_to'] = dateTo;
      }
      if (strategyType != null && strategyType.isNotEmpty) {
        requestBody['strategy_type'] = strategyType;
      }
      if (limit != null) {
        requestBody['limit'] = limit;
      }
      if (offset != null) {
        requestBody['offset'] = offset;
      }

      print('📤 Request Body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse(dualSideTradeHistory),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse = DualSideTradeHistoryResponse.fromJson(responseData);

        if (apiResponse.isSuccess) {
          print('✅ Trade history retrieved successfully');
          print('📊 Total trades: ${apiResponse.data?.totalCount ?? 0}');
          print('📄 Current batch: ${apiResponse.data?.trades.length ?? 0}');
          return apiResponse;
        } else {
          print('❌ API Error: ${apiResponse.message}');
          return apiResponse; // Return even if not successful to show error message
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode} - ${response.body}');
        return DualSideTradeHistoryResponse(
          status: 'error',
          message: 'Server error: ${response.statusCode}',
          responsecode: response.statusCode.toString(),
          data: null,
        );
      }
    } catch (e) {
      print('❌ Network Error: $e');
      return DualSideTradeHistoryResponse(
        status: 'error',
        message: 'Network error: $e',
        responsecode: '0',
        data: null,
      );
    }
  }

  /// Get dual-side trading report
  static Future<DualSideTradingReportResponse?> getDualSideTradingReport({
    required String userId,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      print('📊 Fetching dual-side trading report...');
      print('👤 User ID: $userId');
      if (dateFrom != null || dateTo != null) {
        print('📅 Date Range: ${dateFrom ?? 'N/A'} to ${dateTo ?? 'N/A'}');
      }

      // Start with only required parameter
      final requestBody = <String, dynamic>{
        'user_id': userId,
      };

      // Add optional date parameters
      if (dateFrom != null && dateFrom.isNotEmpty) {
        requestBody['date_from'] = dateFrom;
      }
      if (dateTo != null && dateTo.isNotEmpty) {
        requestBody['date_to'] = dateTo;
      }

      print('📤 Request Body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse(dualSideTradingReport),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse = DualSideTradingReportResponse.fromJson(responseData);

        if (apiResponse.isSuccess) {
          print('✅ Trading report retrieved successfully');
          print('💰 Total PnL: \$${apiResponse.data?.overview.totalPnl ?? 0}');
          return apiResponse;
        } else {
          print('❌ API Error: ${apiResponse.message}');
          return apiResponse;
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode} - ${response.body}');
        return DualSideTradingReportResponse(
          status: 'error',
          message: 'Server error: ${response.statusCode}',
          responsecode: response.statusCode.toString(),
          data: null,
        );
      }
    } catch (e) {
      print('❌ Network Error: $e');
      return DualSideTradingReportResponse(
        status: 'error',
        message: 'Network error: $e',
        responsecode: '0',
        data: null,
      );
    }
  }

  /// Get dual-side open positions
  static Future<DualSideOpenPositionsResponse?> getDualSideOpenPositions({
    required String userId,
  }) async {
    try {
      print('📊 Fetching dual-side open positions...');
      print('👤 User ID: $userId');

      final requestBody = <String, dynamic>{
        'user_id': userId,
      };

      print('📤 Request Body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse(dualSideOpenPositions),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse = DualSideOpenPositionsResponse.fromJson(responseData);

        if (apiResponse.isSuccess) {
          print('✅ Open positions retrieved successfully');
          print('📊 Total positions: ${apiResponse.data?.length ?? 0}');
          return apiResponse;
        } else {
          print('❌ API Error: ${apiResponse.message}');
          return apiResponse;
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode} - ${response.body}');
        return DualSideOpenPositionsResponse(
          status: 'error',
          message: 'Server error: ${response.statusCode}',
          responsecode: response.statusCode.toString(),
          data: null,
        );
      }
    } catch (e) {
      print('❌ Network Error: $e');
      return DualSideOpenPositionsResponse(
        status: 'error',
        message: 'Network error: $e',
        responsecode: '0',
        data: null,
      );
    }
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
