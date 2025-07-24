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
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
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
      final requestBody = {
        'user_id': userId,
        'symbol': symbol,
        'position_size': positionSize,
        'tp_percentage': tpPercentage,
        'leverage': leverage,
      };

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

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse = DualSideInitResponse.fromJson(responseData);

        if (apiResponse.isSuccess) {
          return apiResponse;
        } else {
          return apiResponse; // Return even if not successful to show error message
        }
      } else {
        return DualSideInitResponse(
          status: 'error',
          message: 'Server error: ${response.statusCode}',
          responsecode: response.statusCode.toString(),
          data: null,
        );
      }
    } catch (e) {
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
      if (symbol != null) if (status != null) if (dateFrom != null ||
          dateTo != null) if (strategyType != null) if (limit !=
              null ||
          offset != null) ;

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

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse = DualSideTradeHistoryResponse.fromJson(responseData);

        if (apiResponse.isSuccess) {
          return apiResponse;
        } else {
          return apiResponse; // Return even if not successful to show error message
        }
      } else {
        return DualSideTradeHistoryResponse(
          status: 'error',
          message: 'Server error: ${response.statusCode}',
          responsecode: response.statusCode.toString(),
          data: null,
        );
      }
    } catch (e) {
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
      if (dateFrom != null || dateTo != null) {}

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

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse =
            DualSideTradingReportResponse.fromJson(responseData);

        if (apiResponse.isSuccess) {
          return apiResponse;
        } else {
          return apiResponse;
        }
      } else {
        return DualSideTradingReportResponse(
          status: 'error',
          message: 'Server error: ${response.statusCode}',
          responsecode: response.statusCode.toString(),
          data: null,
        );
      }
    } catch (e) {
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
      final requestBody = <String, dynamic>{
        'user_id': userId,
      };

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

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse =
            DualSideOpenPositionsResponse.fromJson(responseData);

        if (apiResponse.isSuccess) {
          return apiResponse;
        } else {
          return apiResponse;
        }
      } else {
        return DualSideOpenPositionsResponse(
          status: 'error',
          message: 'Server error: ${response.statusCode}',
          responsecode: response.statusCode.toString(),
          data: null,
        );
      }
    } catch (e) {
      return DualSideOpenPositionsResponse(
        status: 'error',
        message: 'Network error: $e',
        responsecode: '0',
        data: null,
      );
    }
  }

  /// Get dual-side performance report
  static Future<DualSidePerformanceResponse?> getDualSidePerformance({
    required String userId,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
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

      final response = await http
          .post(
            Uri.parse(dualSidePerformance),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse = DualSidePerformanceResponse.fromJson(responseData);

        if (apiResponse.isSuccess) {
          return apiResponse;
        } else {
          return apiResponse;
        }
      } else {
        return DualSidePerformanceResponse(
          status: 'error',
          message: 'Server error: ${response.statusCode}',
          responsecode: response.statusCode.toString(),
          data: null,
        );
      }
    } catch (e) {
      return DualSidePerformanceResponse(
        status: 'error',
        message: 'Network error: $e',
        responsecode: '0',
        data: null,
      );
    }
  }

  /// Get dual-side PnL tracking data
  static Future<DualSidePnlTrackingResponse?> getDualSidePnlTracking({
    required String userId,
    String period = 'daily',
    int limit = 30,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'user_id': userId,
        'period': period,
        'limit': limit,
      };
      final response = await http
          .post(
            Uri.parse(dualSidePnlTracking),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse = DualSidePnlTrackingResponse.fromJson(responseData);

        if (apiResponse.isSuccess) {
          return apiResponse;
        } else {
          return apiResponse;
        }
      } else {
        return DualSidePnlTrackingResponse(
          status: 'error',
          message: 'Server error: ${response.statusCode}',
          responsecode: response.statusCode.toString(),
          data: null,
        );
      }
    } catch (e) {
      return DualSidePnlTrackingResponse(
        status: 'error',
        message: 'Network error: $e',
        responsecode: '0',
        data: null,
      );
    }
  }

  /// Get dual-side strategy monitoring data
  static Future<DualSideMonitorResponse?> getDualSideMonitor({
    required String userId,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'user_id': userId,
      };

      final response = await http
          .post(
            Uri.parse(dualSideMonitor),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse = DualSideMonitorResponse.fromJson(responseData);

        if (apiResponse.isSuccess) {
          return apiResponse;
        } else {
          return apiResponse;
        }
      } else {
        return DualSideMonitorResponse(
          status: 'error',
          message: 'Server error: ${response.statusCode}',
          responsecode: response.statusCode.toString(),
          data: null,
        );
      }
    } catch (e) {
      return DualSideMonitorResponse(
        status: 'error',
        message: 'Network error: $e',
        responsecode: '0',
        data: null,
      );
    }
  }

  /// Get dual-side TP/SL monitoring data
  static Future<DualSideMonitorTpSlResponse?> getDualSideMonitorTpSl({
    required String userId,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'user_id': userId,
      };
      final response = await http
          .post(
            Uri.parse(dualSideMonitorTpSl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse = DualSideMonitorTpSlResponse.fromJson(responseData);

        if (apiResponse.isSuccess) {
          return apiResponse;
        } else {
          return apiResponse;
        }
      } else {
        return DualSideMonitorTpSlResponse(
          status: 'error',
          message: 'Server error: ${response.statusCode}',
          responsecode: response.statusCode.toString(),
          data: null,
        );
      }
    } catch (e) {
      return DualSideMonitorTpSlResponse(
        status: 'error',
        message: 'Network error: $e',
        responsecode: '0',
        data: null,
      );
    }
  }

  /// Execute emergency stop for all strategies
  static Future<DualSideEmergencyStopResponse?> getDualSideEmergencyStop({
    required String userId,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'user_id': userId,
      };

      final response = await http
          .post(
            Uri.parse(dualSideEmergencyStop),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse =
            DualSideEmergencyStopResponse.fromJson(responseData);

        if (apiResponse.isSuccess) {
          return apiResponse;
        } else {
          return apiResponse;
        }
      } else {
        return DualSideEmergencyStopResponse(
          status: 'error',
          message: 'Server error: ${response.statusCode}',
          responsecode: response.statusCode.toString(),
          data: null,
        );
      }
    } catch (e) {
      return DualSideEmergencyStopResponse(
        status: 'error',
        message: 'Network error: $e',
        responsecode: '0',
        data: null,
      );
    }
  }

  /// Get dual-side risk settings
  static Future<DualSideRiskSettingsResponse?> getDualSideRiskSettings({
    required String userId,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'user_id': userId,
      };

      final response = await http
          .post(
            Uri.parse(dualSideRiskSettings),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse = DualSideRiskSettingsResponse.fromJson(responseData);

        if (apiResponse.isSuccess) {
          return apiResponse;
        } else {
          return apiResponse;
        }
      } else {
        return DualSideRiskSettingsResponse(
          status: 'error',
          message: 'Server error: ${response.statusCode}',
          responsecode: response.statusCode.toString(),
          data: null,
        );
      }
    } catch (e) {
      return DualSideRiskSettingsResponse(
        status: 'error',
        message: 'Network error: $e',
        responsecode: '0',
        data: null,
      );
    }
  }

  /// Update dual-side risk settings
  static Future<DualSideRiskSettingsResponse?> updateDualSideRiskSettings({
    required String userId,
    required int maxOpenPositions,
    required double maxDailyLoss,
    required double maxPositionSize,
    required double defaultTpPercentage,
    required double defaultSlPercentage,
    required int maxLeverage,
    bool? autoTpSlEnabled,
    bool? duplicatePositionCheck,
    bool? emergencyStopEnabled,
    double? emergencyStopLossPercentage,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'user_id': userId,
        'max_open_positions': maxOpenPositions,
        'max_daily_loss': maxDailyLoss,
        'max_position_size': maxPositionSize,
        'default_tp_percentage': defaultTpPercentage,
        'default_sl_percentage': defaultSlPercentage,
        'max_leverage': maxLeverage,
      };

      // Add optional parameters if provided
      if (autoTpSlEnabled != null) {
        requestBody['auto_tp_sl_enabled'] = autoTpSlEnabled ? 1 : 0;
      }
      if (duplicatePositionCheck != null) {
        requestBody['duplicate_position_check'] =
            duplicatePositionCheck ? 1 : 0;
      }
      if (emergencyStopEnabled != null) {
        requestBody['emergency_stop_enabled'] = emergencyStopEnabled ? 1 : 0;
      }
      if (emergencyStopLossPercentage != null) {
        requestBody['emergency_stop_loss_percentage'] =
            emergencyStopLossPercentage;
      }

      final response = await http
          .post(
            Uri.parse(dualSideRiskSettings),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse = DualSideRiskSettingsResponse.fromJson(responseData);

        if (apiResponse.isSuccess) {
          return apiResponse;
        } else {
          return apiResponse;
        }
      } else {
        return DualSideRiskSettingsResponse(
          status: 'error',
          message: 'Server error: ${response.statusCode}',
          responsecode: response.statusCode.toString(),
          data: null,
        );
      }
    } catch (e) {
      return DualSideRiskSettingsResponse(
        status: 'error',
        message: 'Network error: $e',
        responsecode: '0',
        data: null,
      );
    }
  }

  /// Get dual-side system health
  static Future<DualSideSystemHealthResponse?> getDualSideSystemHealth() async {
    try {
      final requestBody = <String, dynamic>{};
      final response = await http
          .post(
            Uri.parse(dualSideSystemHealth),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse = DualSideSystemHealthResponse.fromJson(responseData);

        if (apiResponse.isSuccess) {
          return apiResponse;
        } else {
          return apiResponse;
        }
      } else {
        return DualSideSystemHealthResponse(
          status: 'error',
          message: 'Server error: ${response.statusCode}',
          responsecode: response.statusCode.toString(),
          data: null,
        );
      }
    } catch (e) {
      return DualSideSystemHealthResponse(
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
