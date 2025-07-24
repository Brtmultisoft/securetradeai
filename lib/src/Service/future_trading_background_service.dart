import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/src/Service/future_trading_service.dart';
import 'package:securetradeai/src/Service/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

// Future Trading Background Task Names
const String futureMonitoringTaskName =
    "com.securetradeai.future.monitoringTask";
const String futureTpSlMonitoringTaskName =
    "com.securetradeai.future.tpslMonitoringTask";

class FutureTradingBackgroundService {
  static Timer? _monitoringTimer;
  static Timer? _tpslMonitoringTimer;
  static bool _isMonitoringActive = false;
  static bool _isTpSlMonitoringActive = false;

  // Monitoring intervals (in seconds) - Same as spot trading
  static const int STRATEGY_MONITORING_INTERVAL = 1; // Every 1 second
  static const int TPSL_MONITORING_INTERVAL = 1; // Every 1 second

  // Activity tracking
  static int _consecutiveEmptyChecks = 0;
  static int _totalTpHits = 0;
  static int _totalTpSlExecutions = 0;
  static DateTime? _lastActivityTime;

  /// Initialize Future Trading Background Monitoring
  static Future<void> initializeFutureTradingMonitoring() async {
    try {
      print('🔵 INITIALIZING FUTURE TRADING BACKGROUND MONITORING...');

      // Ensure plugins are initialized
      WidgetsFlutterBinding.ensureInitialized();

      // Start fallback monitoring services first
      await _initializeFallbackMonitoringServices();
      print('✅ Fallback monitoring services started');

      // For mobile platforms, try to use Workmanager
      if (!kIsWeb) {
        try {
          await Future.any([
            Workmanager()
                .initialize(
                  _futureMonitoringCallbackDispatcher,
                  isInDebugMode: true,
                )
                .timeout(Duration(seconds: 5)),
            Future.delayed(Duration(seconds: 5))
          ]);
          print('✅ FUTURE TRADING WORKMANAGER INITIALIZED');

          // Register monitoring tasks
          await _registerFutureMonitoringTasks();
        } catch (e) {
          print('⚠️ FUTURE TRADING WORKMANAGER INITIALIZATION FAILED: $e');
          print('ℹ️ Continuing with fallback monitoring services only');
        }
      }
    } catch (e) {
      print('❌ ERROR IN FUTURE TRADING BACKGROUND SERVICE INITIALIZATION: $e');
      print('ℹ️ Ensuring fallback monitoring services are running');
      await _initializeFallbackMonitoringServices();
    }
  }

  /// Initialize fallback monitoring services using Timers
  static Future<void> _initializeFallbackMonitoringServices() async {
    try {
      print('🔄 INITIALIZING FALLBACK FUTURE TRADING MONITORING SERVICES...');

      // Stop existing timers if any
      await stopFutureTradingMonitoring();

      // Start strategy monitoring timer
      _monitoringTimer = Timer.periodic(
        Duration(seconds: STRATEGY_MONITORING_INTERVAL),
        (timer) async {
          if (_isMonitoringActive) {
            await _executeStrategyMonitoring();
          }
        },
      );
      _isMonitoringActive = true;
      // Start TP/SL monitoring timer
      _tpslMonitoringTimer = Timer.periodic(
        Duration(seconds: TPSL_MONITORING_INTERVAL),
        (timer) async {
          if (_isTpSlMonitoringActive) {
            await _executeTpSlMonitoring();
          }
        },
      );
      _isTpSlMonitoringActive = true;
      print(
          '✅ TP/SL monitoring timer started (${TPSL_MONITORING_INTERVAL}s interval)');

      print('✅ FALLBACK FUTURE TRADING MONITORING SERVICES INITIALIZED');
    } catch (e) {
      print('❌ ERROR INITIALIZING FALLBACK MONITORING SERVICES: $e');
    }
  }

  /// Register Workmanager tasks for future trading monitoring
  static Future<void> _registerFutureMonitoringTasks() async {
    try {
      // Register strategy monitoring task
      await Workmanager().registerPeriodicTask(
        'future_strategy_monitoring',
        futureMonitoringTaskName,
        frequency: Duration(minutes: 1), // Minimum allowed by Workmanager
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        backoffPolicy: BackoffPolicy.exponential,
      );

      // Register TP/SL monitoring task
      await Workmanager().registerPeriodicTask(
        'future_tpsl_monitoring',
        futureTpSlMonitoringTaskName,
        frequency: Duration(minutes: 1), // Minimum allowed by Workmanager
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        backoffPolicy: BackoffPolicy.exponential,
      );
    } catch (e) {}
  }

  /// Execute strategy monitoring
  static Future<void> _executeStrategyMonitoring() async {
    try {
      // First check if there are any open positions
      final openPositionsCount = await _getOpenPositionsCount();

      if (openPositionsCount == 0) {
        print('monitoring open position 0');
        return;
      }

      print(
          '🔍 Checking strategy monitoring - Open positions: $openPositionsCount');
      final response = await FutureTradingService.getDualSideMonitor(
        userId: commonuserId,
      );

      if (response != null && response.isSuccess && response.data != null) {
        final monitorData = response.data!;

        // Check for TP hits
        if (monitorData.tpHits > 0) {
          _totalTpHits += monitorData.tpHits;
          _lastActivityTime = DateTime.now();
          _consecutiveEmptyChecks = 0;

          print('TP hits: ${monitorData.tpHits}');

          // Send notification for TP hits
          await _sendTpHitNotification(monitorData.tpHits);

          // Save activity to preferences
          await _saveMonitoringActivity('tp_hits', monitorData.tpHits);
        }

        // Check for strategy updates
        if (monitorData.strategiesUpdated.isNotEmpty) {
          _lastActivityTime = DateTime.now();
          _consecutiveEmptyChecks = 0;

          print('Strategies updated: ${monitorData.strategiesUpdated.length}');

          // Send notification for strategy updates
          await _sendStrategyUpdateNotification(monitorData.strategiesUpdated);

          // Save activity to preferences
          await _saveMonitoringActivity(
              'strategy_updates', monitorData.strategiesUpdated.length);
        }

        // Update monitoring stats
        await _updateMonitoringStats(monitorData);

        if (!monitorData.hasActivity) {
          _consecutiveEmptyChecks++;
        } else {}
      } else {
        _consecutiveEmptyChecks++;
        print('⚠️ Strategy monitoring failed - No data received');
      }
    } catch (e) {
      _consecutiveEmptyChecks++;
      print('❌ Strategy monitoring error: $e');
    }
  }

  /// Execute TP/SL monitoring
  static Future<void> _executeTpSlMonitoring() async {
    try {
      // First check if there are any open positions
      final openPositionsCount = await _getOpenPositionsCount();

      if (openPositionsCount == 0) {
        return; // Silent when no positions
      }

      print(
          '🎯 Checking TP/SL monitoring - Open positions: $openPositionsCount');
      final response = await FutureTradingService.getDualSideMonitorTpSl(
        userId: commonuserId,
      );

      if (response != null && response.isSuccess && response.data != null) {
        final tpslData = response.data!;

        // Check for TP/SL executions
        if (tpslData.executedTpSl > 0) {
          _totalTpSlExecutions += tpslData.executedTpSl;
          _lastActivityTime = DateTime.now();

          // Send notification for TP/SL executions
          await _sendTpSlExecutionNotification(
              tpslData.executedTpSl, tpslData.executedPositions);

          // Save activity to preferences
          await _saveMonitoringActivity(
              'tpsl_executions', tpslData.executedTpSl);
        }

        if (tpslData.executedTpSl > 0) {
        } else {}
      } else {}
    } catch (e) {}
  }

  /// Get count of open positions
  static Future<int> _getOpenPositionsCount() async {
    try {
      final response = await FutureTradingService.getDualSideOpenPositions(
        userId: commonuserId,
      );

      if (response != null && response.isSuccess && response.data != null) {
        return response.data!.length;
      }

      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Send TP hit notification
  static Future<void> _sendTpHitNotification(int tpHits) async {
    try {
      final notificationService = NotificationService();
      await notificationService.showTradeNotification(
        title: '🎯 Take Profit Hit!',
        body: '$tpHits position(s) reached take profit target',
        payload: 'future_tp_hit',
      );
    } catch (e) {
      // Silent error handling
    }
  }

  /// Send strategy update notification
  static Future<void> _sendStrategyUpdateNotification(
      List<String> updatedStrategies) async {
    try {
      final strategiesText = updatedStrategies.length > 3
          ? '${updatedStrategies.take(3).join(', ')} and ${updatedStrategies.length - 3} more'
          : updatedStrategies.join(', ');

      final notificationService = NotificationService();
      await notificationService.showTradeNotification(
        title: '🔄 Strategy Updated',
        body: 'Strategies updated: $strategiesText',
        payload: 'future_strategy_update',
      );
    } catch (e) {
      // Silent error handling
    }
  }

  /// Send TP/SL execution notification
  static Future<void> _sendTpSlExecutionNotification(
      int executions, List<String> positions) async {
    try {
      final positionsText = positions.length > 2
          ? '${positions.take(2).join(', ')} and ${positions.length - 2} more'
          : positions.join(', ');

      final notificationService = NotificationService();
      await notificationService.showTradeNotification(
        title: '⚡ TP/SL Executed',
        body: '$executions execution(s): $positionsText',
        payload: 'future_tpsl_execution',
      );
    } catch (e) {
      // Silent error handling
    }
  }

  /// Save monitoring activity to SharedPreferences
  static Future<void> _saveMonitoringActivity(
      String activityType, int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final dateKey =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Save daily activity count
      final dailyKey = 'future_${activityType}_$dateKey';
      final currentCount = prefs.getInt(dailyKey) ?? 0;
      await prefs.setInt(dailyKey, currentCount + count);

      // Save last activity timestamp
      await prefs.setString('future_last_activity', now.toIso8601String());

      // Save total activity count
      final totalKey = 'future_total_$activityType';
      final totalCount = prefs.getInt(totalKey) ?? 0;
      await prefs.setInt(totalKey, totalCount + count);
    } catch (e) {
      // Silent error handling
    }
  }

  /// Update monitoring statistics
  static Future<void> _updateMonitoringStats(dynamic monitorData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      // Save monitoring stats
      final statsData = {
        'last_check': now.toIso8601String(),
        'strategies_checked': monitorData.strategiesChecked,
        'tp_hits': monitorData.tpHits,
        'strategies_updated_count': monitorData.strategiesUpdated.length,
        'consecutive_empty_checks': _consecutiveEmptyChecks,
        'total_tp_hits': _totalTpHits,
        'total_tpsl_executions': _totalTpSlExecutions,
      };

      await prefs.setString('future_monitoring_stats', jsonEncode(statsData));
    } catch (e) {
      // Silent error handling
    }
  }

  /// Get monitoring statistics
  static Future<Map<String, dynamic>> getMonitoringStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('future_monitoring_stats');

      if (statsJson != null) {
        return jsonDecode(statsJson);
      }

      return {
        'last_check': null,
        'strategies_checked': 0,
        'tp_hits': 0,
        'strategies_updated_count': 0,
        'consecutive_empty_checks': 0,
        'total_tp_hits': _totalTpHits,
        'total_tpsl_executions': _totalTpSlExecutions,
      };
    } catch (e) {
      return {};
    }
  }

  /// Stop future trading monitoring
  static Future<void> stopFutureTradingMonitoring() async {
    try {
      // Cancel timers
      _monitoringTimer?.cancel();
      _tpslMonitoringTimer?.cancel();

      _isMonitoringActive = false;
      _isTpSlMonitoringActive = false;

      // Cancel Workmanager tasks
      if (!kIsWeb) {
        try {
          await Workmanager().cancelByUniqueName('future_strategy_monitoring');
          await Workmanager().cancelByUniqueName('future_tpsl_monitoring');
        } catch (e) {
          // Silent error handling
        }
      }
    } catch (e) {
      // Silent error handling
    }
  }

  /// Check if monitoring is active
  static bool get isMonitoringActive =>
      _isMonitoringActive || _isTpSlMonitoringActive;

  /// Get monitoring status
  static Map<String, dynamic> getMonitoringStatus() {
    return {
      'strategy_monitoring_active': _isMonitoringActive,
      'tpsl_monitoring_active': _isTpSlMonitoringActive,
      'consecutive_empty_checks': _consecutiveEmptyChecks,
      'total_tp_hits': _totalTpHits,
      'total_tpsl_executions': _totalTpSlExecutions,
      'last_activity_time': _lastActivityTime?.toIso8601String(),
    };
  }
}

/// Workmanager callback dispatcher for future trading monitoring
@pragma('vm:entry-point')
void _futureMonitoringCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      switch (taskName) {
        case futureMonitoringTaskName:
          await FutureTradingBackgroundService._executeStrategyMonitoring();
          break;
        case futureTpSlMonitoringTaskName:
          await FutureTradingBackgroundService._executeTpSlMonitoring();
          break;
      }

      return true;
    } catch (e) {
      return false;
    }
  });
}
