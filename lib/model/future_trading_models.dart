// Future Trading Account Summary Model
class FutureAccountSummary {
  final double totalWalletBalance;
  final double futuresBalance;
  final double unrealizedPnl;
  final double totalRealizedProfit;
  final int openPositionsCount;
  final double todayPnl;
  final double currentLeverage;
  final double availableBalance;
  final double marginBalance;
  final double maxWithdrawAmount;
  final double totalPositionInitialMargin;
  final double totalOpenOrderInitialMargin;
  final bool canTrade;
  final bool canDeposit;
  final bool canWithdraw;

  FutureAccountSummary({
    required this.totalWalletBalance,
    required this.futuresBalance,
    required this.unrealizedPnl,
    required this.totalRealizedProfit,
    required this.openPositionsCount,
    required this.todayPnl,
    this.currentLeverage = 1.0,
    required this.availableBalance,
    required this.marginBalance,
    required this.maxWithdrawAmount,
    required this.totalPositionInitialMargin,
    required this.totalOpenOrderInitialMargin,
    required this.canTrade,
    required this.canDeposit,
    required this.canWithdraw,
  });

  factory FutureAccountSummary.fromJson(Map<String, dynamic> json) {
    return FutureAccountSummary(
      totalWalletBalance:
          double.tryParse(json['totalWalletBalance']?.toString() ?? '0') ?? 0.0,
      futuresBalance:
          double.tryParse(json['futuresBalance']?.toString() ?? '0') ?? 0.0,
      unrealizedPnl:
          double.tryParse(json['unrealizedPnl']?.toString() ?? '0') ?? 0.0,
      totalRealizedProfit:
          double.tryParse(json['totalRealizedProfit']?.toString() ?? '0') ??
              0.0,
      openPositionsCount:
          int.tryParse(json['openPositionsCount']?.toString() ?? '0') ?? 0,
      todayPnl: double.tryParse(json['todayPnl']?.toString() ?? '0') ?? 0.0,
      currentLeverage:
          double.tryParse(json['currentLeverage']?.toString() ?? '1') ?? 1.0,
      availableBalance:
          double.tryParse(json['availableBalance']?.toString() ?? '0') ?? 0.0,
      marginBalance:
          double.tryParse(json['marginBalance']?.toString() ?? '0') ?? 0.0,
      maxWithdrawAmount:
          double.tryParse(json['maxWithdrawAmount']?.toString() ?? '0') ?? 0.0,
      totalPositionInitialMargin:
          double.tryParse(json['totalPositionInitialMargin']?.toString() ?? '0') ?? 0.0,
      totalOpenOrderInitialMargin:
          double.tryParse(json['totalOpenOrderInitialMargin']?.toString() ?? '0') ?? 0.0,
      canTrade: json['canTrade'] ?? true,
      canDeposit: json['canDeposit'] ?? true,
      canWithdraw: json['canWithdraw'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalWalletBalance': totalWalletBalance,
      'futuresBalance': futuresBalance,
      'unrealizedPnl': unrealizedPnl,
      'totalRealizedProfit': totalRealizedProfit,
      'openPositionsCount': openPositionsCount,
      'todayPnl': todayPnl,
      'currentLeverage': currentLeverage,
      'availableBalance': availableBalance,
      'marginBalance': marginBalance,
    };
  }
}

// Future Trading Symbol Model
class FutureSymbol {
  final String symbol;
  final String baseAsset;
  final String quoteAsset;
  final double currentPrice;
  final double priceChange24h;
  final double priceChangePercent24h;
  final double volume24h;
  final double high24h;
  final double low24h;
  final int maxLeverage;
  final double minOrderSize;
  final double tickSize;

  FutureSymbol({
    required this.symbol,
    required this.baseAsset,
    required this.quoteAsset,
    required this.currentPrice,
    required this.priceChange24h,
    required this.priceChangePercent24h,
    required this.volume24h,
    required this.high24h,
    required this.low24h,
    required this.maxLeverage,
    required this.minOrderSize,
    required this.tickSize,
  });

  factory FutureSymbol.fromJson(Map<String, dynamic> json) {
    return FutureSymbol(
      symbol: json['symbol'] ?? '',
      baseAsset: json['baseAsset'] ?? '',
      quoteAsset: json['quoteAsset'] ?? '',
      currentPrice:
          double.tryParse(json['currentPrice']?.toString() ?? '0') ?? 0.0,
      priceChange24h:
          double.tryParse(json['priceChange24h']?.toString() ?? '0') ?? 0.0,
      priceChangePercent24h:
          double.tryParse(json['priceChangePercent24h']?.toString() ?? '0') ??
              0.0,
      volume24h: double.tryParse(json['volume24h']?.toString() ?? '0') ?? 0.0,
      high24h: double.tryParse(json['high24h']?.toString() ?? '0') ?? 0.0,
      low24h: double.tryParse(json['low24h']?.toString() ?? '0') ?? 0.0,
      maxLeverage: int.tryParse(json['maxLeverage']?.toString() ?? '1') ?? 1,
      minOrderSize:
          double.tryParse(json['minOrderSize']?.toString() ?? '0') ?? 0.0,
      tickSize: double.tryParse(json['tickSize']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'baseAsset': baseAsset,
      'quoteAsset': quoteAsset,
      'currentPrice': currentPrice,
      'priceChange24h': priceChange24h,
      'priceChangePercent24h': priceChangePercent24h,
      'volume24h': volume24h,
      'high24h': high24h,
      'low24h': low24h,
      'maxLeverage': maxLeverage,
      'minOrderSize': minOrderSize,
      'tickSize': tickSize,
    };
  }
}

// Dual Side Open Positions Response Models
class DualSideOpenPositionsResponse {
  final String status;
  final String message;
  final String responsecode;
  final List<DualSideOpenPosition>? data;

  DualSideOpenPositionsResponse({
    required this.status,
    required this.message,
    required this.responsecode,
    this.data,
  });

  factory DualSideOpenPositionsResponse.fromJson(Map<String, dynamic> json) {
    return DualSideOpenPositionsResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      responsecode: json['responsecode'] ?? '',
      data: json['data'] != null
          ? List<DualSideOpenPosition>.from(
              json['data'].map((x) => DualSideOpenPosition.fromJson(x)))
          : null,
    );
  }

  bool get isSuccess => status == 'success';
}

class DualSideOpenPosition {
  final int id;
  final String symbol;
  final String side; // 'BUY' or 'SELL'
  final String positionSide; // 'LONG' or 'SHORT'
  final double quantity;
  final double entryPrice;
  final double currentPrice;
  final double unrealizedPnl;
  final double pnlPercentage;
  final double? tpPrice;
  final double? slPrice;
  final String status;
  final String strategyId;
  final int leverage;
  final double marginUsed;

  DualSideOpenPosition({
    required this.id,
    required this.symbol,
    required this.side,
    required this.positionSide,
    required this.quantity,
    required this.entryPrice,
    required this.currentPrice,
    required this.unrealizedPnl,
    required this.pnlPercentage,
    this.tpPrice,
    this.slPrice,
    required this.status,
    required this.strategyId,
    required this.leverage,
    required this.marginUsed,
  });

  factory DualSideOpenPosition.fromJson(Map<String, dynamic> json) {
    return DualSideOpenPosition(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      symbol: json['symbol'] ?? '',
      side: json['side'] ?? '',
      positionSide: json['side'] ?? '', // API doesn't have positionSide, use side
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      entryPrice: double.tryParse(json['entry_price']?.toString() ?? '0') ?? 0.0,
      currentPrice: double.tryParse(json['current_price']?.toString() ?? '0') ?? 0.0,
      unrealizedPnl: double.tryParse(json['unrealized_pnl']?.toString() ?? '0') ?? 0.0,
      pnlPercentage: double.tryParse(json['pnl_percentage']?.toString() ?? '0') ?? 0.0,
      tpPrice: json['tp_price'] != null ? double.tryParse(json['tp_price']?.toString() ?? '0') : null,
      slPrice: json['sl_price'] != null ? double.tryParse(json['sl_price']?.toString() ?? '0') : null,
      status: json['status'] ?? '',
      strategyId: json['pair_id'] ?? '', // Use pair_id as strategy_id
      leverage: int.tryParse(json['leverage']?.toString() ?? '1') ?? 1,
      marginUsed: double.tryParse(json['margin_used']?.toString() ?? '0') ?? 0.0,
    );
  }

  // Convert to FuturePosition for compatibility with existing UI
  FuturePosition toFuturePosition() {
    // Convert BUY/SELL to LONG/SHORT for UI display
    String uiSide = side == 'BUY' ? 'LONG' : 'SHORT';

    return FuturePosition(
      id: id.toString(),
      symbol: symbol,
      side: uiSide, // Convert BUY -> LONG, SELL -> SHORT
      entryPrice: entryPrice,
      currentPrice: currentPrice,
      quantity: quantity,
      leverage: leverage.toDouble(),
      unrealizedPnl: unrealizedPnl,
      realizedPnl: 0.0, // Not provided in API
      profitPercent: pnlPercentage,
      marginUsed: marginUsed,
      liquidationPrice: 0.0, // Not provided in API, could be calculated
      openTime: DateTime.now(), // Not provided in API
      status: status,
      takeProfitPrice: tpPrice,
      stopLossPrice: slPrice,
    );
  }
}

// Future Trading Position Model
class FuturePosition {
  final String id;
  final String symbol;
  final String side; // 'LONG' or 'SHORT'
  final double entryPrice;
  final double currentPrice;
  final double quantity;
  final double leverage;
  final double unrealizedPnl;
  final double realizedPnl;
  final double profitPercent;
  final double marginUsed;
  final double liquidationPrice;
  final DateTime openTime;
  final String status; // 'OPEN', 'CLOSED', 'LIQUIDATED'
  final double? takeProfitPrice;
  final double? stopLossPrice;

  FuturePosition({
    required this.id,
    required this.symbol,
    required this.side,
    required this.entryPrice,
    required this.currentPrice,
    required this.quantity,
    required this.leverage,
    required this.unrealizedPnl,
    required this.realizedPnl,
    required this.profitPercent,
    required this.marginUsed,
    required this.liquidationPrice,
    required this.openTime,
    required this.status,
    this.takeProfitPrice,
    this.stopLossPrice,
  });

  factory FuturePosition.fromJson(Map<String, dynamic> json) {
    return FuturePosition(
      id: json['id']?.toString() ?? '',
      symbol: json['symbol'] ?? '',
      side: json['side'] ?? 'LONG',
      entryPrice: double.tryParse(json['entryPrice']?.toString() ?? '0') ?? 0.0,
      currentPrice:
          double.tryParse(json['currentPrice']?.toString() ?? '0') ?? 0.0,
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      leverage: double.tryParse(json['leverage']?.toString() ?? '1') ?? 1.0,
      unrealizedPnl:
          double.tryParse(json['unrealizedPnl']?.toString() ?? '0') ?? 0.0,
      realizedPnl:
          double.tryParse(json['realizedPnl']?.toString() ?? '0') ?? 0.0,
      profitPercent:
          double.tryParse(json['profitPercent']?.toString() ?? '0') ?? 0.0,
      marginUsed: double.tryParse(json['marginUsed']?.toString() ?? '0') ?? 0.0,
      liquidationPrice:
          double.tryParse(json['liquidationPrice']?.toString() ?? '0') ?? 0.0,
      openTime: DateTime.tryParse(json['openTime']?.toString() ?? '') ??
          DateTime.now(),
      status: json['status'] ?? 'OPEN',
      takeProfitPrice: json['takeProfitPrice'] != null
          ? double.tryParse(json['takeProfitPrice'].toString())
          : null,
      stopLossPrice: json['stopLossPrice'] != null
          ? double.tryParse(json['stopLossPrice'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'side': side,
      'entryPrice': entryPrice,
      'currentPrice': currentPrice,
      'quantity': quantity,
      'leverage': leverage,
      'unrealizedPnl': unrealizedPnl,
      'realizedPnl': realizedPnl,
      'profitPercent': profitPercent,
      'marginUsed': marginUsed,
      'liquidationPrice': liquidationPrice,
      'openTime': openTime.toIso8601String(),
      'status': status,
      'takeProfitPrice': takeProfitPrice,
      'stopLossPrice': stopLossPrice,
    };
  }

  bool get isLong => side.toUpperCase() == 'LONG';
  bool get isShort => side.toUpperCase() == 'SHORT';
  bool get isProfit => unrealizedPnl > 0;
  bool get isOpen => status.toUpperCase() == 'OPEN';
}

// Future Trading Order Model
class FutureOrder {
  final String id;
  final String symbol;
  final String side; // 'BUY' or 'SELL'
  final String positionSide; // 'LONG' or 'SHORT'
  final String type; // 'MARKET', 'LIMIT', 'STOP_MARKET'
  final double quantity;
  final double? price;
  final double? stopPrice;
  final double leverage;
  final String status; // 'NEW', 'FILLED', 'CANCELED', 'REJECTED'
  final DateTime createTime;
  final DateTime? updateTime;
  final double? executedPrice;
  final double? executedQuantity;
  final String? errorMessage;
  final double? takeProfitPrice;
  final double? stopLossPrice;

  FutureOrder({
    required this.id,
    required this.symbol,
    required this.side,
    required this.positionSide,
    required this.type,
    required this.quantity,
    this.price,
    this.stopPrice,
    required this.leverage,
    required this.status,
    required this.createTime,
    this.updateTime,
    this.executedPrice,
    this.executedQuantity,
    this.errorMessage,
    this.takeProfitPrice,
    this.stopLossPrice,
  });

  factory FutureOrder.fromJson(Map<String, dynamic> json) {
    return FutureOrder(
      id: json['id']?.toString() ?? '',
      symbol: json['symbol'] ?? '',
      side: json['side'] ?? 'BUY',
      positionSide: json['positionSide'] ?? 'LONG',
      type: json['type'] ?? 'MARKET',
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      stopPrice: json['stopPrice'] != null
          ? double.tryParse(json['stopPrice'].toString())
          : null,
      leverage: double.tryParse(json['leverage']?.toString() ?? '1') ?? 1.0,
      status: json['status'] ?? 'NEW',
      createTime: DateTime.tryParse(json['createTime']?.toString() ?? '') ??
          DateTime.now(),
      updateTime: json['updateTime'] != null
          ? DateTime.tryParse(json['updateTime'].toString())
          : null,
      executedPrice: json['executedPrice'] != null
          ? double.tryParse(json['executedPrice'].toString())
          : null,
      executedQuantity: json['executedQuantity'] != null
          ? double.tryParse(json['executedQuantity'].toString())
          : null,
      errorMessage: json['errorMessage'],
      takeProfitPrice: json['takeProfitPrice'] != null
          ? double.tryParse(json['takeProfitPrice'].toString())
          : null,
      stopLossPrice: json['stopLossPrice'] != null
          ? double.tryParse(json['stopLossPrice'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'side': side,
      'positionSide': positionSide,
      'type': type,
      'quantity': quantity,
      'price': price,
      'stopPrice': stopPrice,
      'leverage': leverage,
      'status': status,
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime?.toIso8601String(),
      'executedPrice': executedPrice,
      'executedQuantity': executedQuantity,
      'errorMessage': errorMessage,
      'takeProfitPrice': takeProfitPrice,
      'stopLossPrice': stopLossPrice,
    };
  }

  bool get isFilled => status.toUpperCase() == 'FILLED';
  bool get isPending => status.toUpperCase() == 'NEW';
  bool get isCanceled => status.toUpperCase() == 'CANCELED';
  bool get isRejected => status.toUpperCase() == 'REJECTED';
  bool get isLongPosition => positionSide.toUpperCase() == 'LONG';
  bool get isShortPosition => positionSide.toUpperCase() == 'SHORT';
}

// Future Trading History Model
class FutureTradeHistory {
  final String id;
  final String symbol;
  final String side; // 'LONG' or 'SHORT'
  final double entryPrice;
  final double exitPrice;
  final double quantity;
  final double leverage;
  final double realizedPnl;
  final double profitPercent;
  final Duration tradeDuration;
  final DateTime openTime;
  final DateTime closeTime;
  final String closeReason; // 'MANUAL', 'TP', 'SL', 'LIQUIDATION'
  final double fees;

  FutureTradeHistory({
    required this.id,
    required this.symbol,
    required this.side,
    required this.entryPrice,
    required this.exitPrice,
    required this.quantity,
    required this.leverage,
    required this.realizedPnl,
    required this.profitPercent,
    required this.tradeDuration,
    required this.openTime,
    required this.closeTime,
    required this.closeReason,
    required this.fees,
  });

  factory FutureTradeHistory.fromJson(Map<String, dynamic> json) {
    final openTime =
        DateTime.tryParse(json['openTime']?.toString() ?? '') ?? DateTime.now();
    final closeTime = DateTime.tryParse(json['closeTime']?.toString() ?? '') ??
        DateTime.now();

    return FutureTradeHistory(
      id: json['id']?.toString() ?? '',
      symbol: json['symbol'] ?? '',
      side: json['side'] ?? 'LONG',
      entryPrice: double.tryParse(json['entryPrice']?.toString() ?? '0') ?? 0.0,
      exitPrice: double.tryParse(json['exitPrice']?.toString() ?? '0') ?? 0.0,
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      leverage: double.tryParse(json['leverage']?.toString() ?? '1') ?? 1.0,
      realizedPnl:
          double.tryParse(json['realizedPnl']?.toString() ?? '0') ?? 0.0,
      profitPercent:
          double.tryParse(json['profitPercent']?.toString() ?? '0') ?? 0.0,
      tradeDuration: closeTime.difference(openTime),
      openTime: openTime,
      closeTime: closeTime,
      closeReason: json['closeReason'] ?? 'MANUAL',
      fees: double.tryParse(json['fees']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'side': side,
      'entryPrice': entryPrice,
      'exitPrice': exitPrice,
      'quantity': quantity,
      'leverage': leverage,
      'realizedPnl': realizedPnl,
      'profitPercent': profitPercent,
      'openTime': openTime.toIso8601String(),
      'closeTime': closeTime.toIso8601String(),
      'closeReason': closeReason,
      'fees': fees,
    };
  }

  bool get isProfit => realizedPnl > 0;
  bool get isLong => side.toUpperCase() == 'LONG';
  bool get isShort => side.toUpperCase() == 'SHORT';
  String get formattedDuration {
    final hours = tradeDuration.inHours;
    final minutes = tradeDuration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

// Future Trading Settings Model
class FutureSettings {
  final double defaultLeverage;
  final double defaultTakeProfitPercent;
  final double defaultStopLossPercent;
  final double defaultRiskPerTrade;
  final bool isDarkTheme;
  final bool notificationsEnabled;
  final bool tradeExecutedNotification;
  final bool tpSlHitNotification;
  final bool liquidationWarningNotification;
  final bool apiErrorNotification;
  final String preferredOrderType; // 'MARKET', 'LIMIT'
  final bool autoAddMargin;
  final double marginRatio;

  FutureSettings({
    this.defaultLeverage = 10.0,
    this.defaultTakeProfitPercent = 2.0,
    this.defaultStopLossPercent = 1.0,
    this.defaultRiskPerTrade = 1.0,
    this.isDarkTheme = true,
    this.notificationsEnabled = true,
    this.tradeExecutedNotification = true,
    this.tpSlHitNotification = true,
    this.liquidationWarningNotification = true,
    this.apiErrorNotification = true,
    this.preferredOrderType = 'MARKET',
    this.autoAddMargin = false,
    this.marginRatio = 0.8,
  });

  factory FutureSettings.fromJson(Map<String, dynamic> json) {
    return FutureSettings(
      defaultLeverage:
          double.tryParse(json['defaultLeverage']?.toString() ?? '10') ?? 10.0,
      defaultTakeProfitPercent: double.tryParse(
              json['defaultTakeProfitPercent']?.toString() ?? '2') ??
          2.0,
      defaultStopLossPercent:
          double.tryParse(json['defaultStopLossPercent']?.toString() ?? '1') ??
              1.0,
      defaultRiskPerTrade:
          double.tryParse(json['defaultRiskPerTrade']?.toString() ?? '1') ??
              1.0,
      isDarkTheme: json['isDarkTheme'] ?? true,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      tradeExecutedNotification: json['tradeExecutedNotification'] ?? true,
      tpSlHitNotification: json['tpSlHitNotification'] ?? true,
      liquidationWarningNotification:
          json['liquidationWarningNotification'] ?? true,
      apiErrorNotification: json['apiErrorNotification'] ?? true,
      preferredOrderType: json['preferredOrderType'] ?? 'MARKET',
      autoAddMargin: json['autoAddMargin'] ?? false,
      marginRatio:
          double.tryParse(json['marginRatio']?.toString() ?? '0.8') ?? 0.8,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultLeverage': defaultLeverage,
      'defaultTakeProfitPercent': defaultTakeProfitPercent,
      'defaultStopLossPercent': defaultStopLossPercent,
      'defaultRiskPerTrade': defaultRiskPerTrade,
      'isDarkTheme': isDarkTheme,
      'notificationsEnabled': notificationsEnabled,
      'tradeExecutedNotification': tradeExecutedNotification,
      'tpSlHitNotification': tpSlHitNotification,
      'liquidationWarningNotification': liquidationWarningNotification,
      'apiErrorNotification': apiErrorNotification,
      'preferredOrderType': preferredOrderType,
      'autoAddMargin': autoAddMargin,
      'marginRatio': marginRatio,
    };
  }

  FutureSettings copyWith({
    double? defaultLeverage,
    double? defaultTakeProfitPercent,
    double? defaultStopLossPercent,
    double? defaultRiskPerTrade,
    bool? isDarkTheme,
    bool? notificationsEnabled,
    bool? tradeExecutedNotification,
    bool? tpSlHitNotification,
    bool? liquidationWarningNotification,
    bool? apiErrorNotification,
    String? preferredOrderType,
    bool? autoAddMargin,
    double? marginRatio,
  }) {
    return FutureSettings(
      defaultLeverage: defaultLeverage ?? this.defaultLeverage,
      defaultTakeProfitPercent:
          defaultTakeProfitPercent ?? this.defaultTakeProfitPercent,
      defaultStopLossPercent:
          defaultStopLossPercent ?? this.defaultStopLossPercent,
      defaultRiskPerTrade: defaultRiskPerTrade ?? this.defaultRiskPerTrade,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      tradeExecutedNotification:
          tradeExecutedNotification ?? this.tradeExecutedNotification,
      tpSlHitNotification: tpSlHitNotification ?? this.tpSlHitNotification,
      liquidationWarningNotification:
          liquidationWarningNotification ?? this.liquidationWarningNotification,
      apiErrorNotification: apiErrorNotification ?? this.apiErrorNotification,
      preferredOrderType: preferredOrderType ?? this.preferredOrderType,
      autoAddMargin: autoAddMargin ?? this.autoAddMargin,
      marginRatio: marginRatio ?? this.marginRatio,
    );
  }
}

// Future Trading Log Model
class FutureLog {
  final String id;
  final DateTime timestamp;
  final String type; // 'API_REQUEST', 'API_RESPONSE', 'ERROR', 'INFO'
  final String message;
  final Map<String, dynamic>? data;
  final String? errorCode;
  final String level; // 'INFO', 'WARNING', 'ERROR', 'DEBUG'

  FutureLog({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.message,
    this.data,
    this.errorCode,
    this.level = 'INFO',
  });

  factory FutureLog.fromJson(Map<String, dynamic> json) {
    return FutureLog(
      id: json['id']?.toString() ?? '',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      type: json['type'] ?? 'INFO',
      message: json['message'] ?? '',
      data: json['data'],
      errorCode: json['errorCode'],
      level: json['level'] ?? 'INFO',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'message': message,
      'data': data,
      'errorCode': errorCode,
      'level': level,
    };
  }

  bool get isError => level.toUpperCase() == 'ERROR';
  bool get isWarning => level.toUpperCase() == 'WARNING';
  bool get isInfo => level.toUpperCase() == 'INFO';
}

// Future Trading Notification Model
class FutureNotification {
  final String id;
  final String title;
  final String message;
  final String
      type; // 'TRADE_EXECUTED', 'TP_HIT', 'SL_HIT', 'LIQUIDATION_WARNING', 'API_ERROR'
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String priority; // 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'

  FutureNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
    this.priority = 'MEDIUM',
  });

  factory FutureNotification.fromJson(Map<String, dynamic> json) {
    return FutureNotification(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'INFO',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      isRead: json['isRead'] ?? false,
      data: json['data'],
      priority: json['priority'] ?? 'MEDIUM',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'data': data,
      'priority': priority,
    };
  }

  bool get isCritical => priority.toUpperCase() == 'CRITICAL';
  bool get isHigh => priority.toUpperCase() == 'HIGH';
  bool get isMedium => priority.toUpperCase() == 'MEDIUM';
  bool get isLow => priority.toUpperCase() == 'LOW';
}

// API Response Models
class DualSideAccountBalanceResponse {
  final String status;
  final String message;
  final String responseCode;
  final DualSideAccountData? data;

  DualSideAccountBalanceResponse({
    required this.status,
    required this.message,
    required this.responseCode,
    this.data,
  });

  factory DualSideAccountBalanceResponse.fromJson(Map<String, dynamic> json) {
    return DualSideAccountBalanceResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      responseCode: json['responsecode'] ?? '',
      data: json['data'] != null
          ? DualSideAccountData.fromJson(json['data'])
          : null,
    );
  }

  bool get isSuccess => status.toLowerCase() == 'success';
}

class DualSideAccountData {
  final double totalWalletBalance;
  final double totalUnrealizedPnl;
  final double totalMarginBalance;
  final double totalPositionInitialMargin;
  final double totalOpenOrderInitialMargin;
  final double availableBalance;
  final double maxWithdrawAmount;
  final bool canTrade;
  final bool canDeposit;
  final bool canWithdraw;
  final List<AssetBalance> assets;

  DualSideAccountData({
    required this.totalWalletBalance,
    required this.totalUnrealizedPnl,
    required this.totalMarginBalance,
    required this.totalPositionInitialMargin,
    required this.totalOpenOrderInitialMargin,
    required this.availableBalance,
    required this.maxWithdrawAmount,
    required this.canTrade,
    required this.canDeposit,
    required this.canWithdraw,
    required this.assets,
  });

  factory DualSideAccountData.fromJson(Map<String, dynamic> json) {
    return DualSideAccountData(
      totalWalletBalance:
          double.tryParse(json['total_wallet_balance']?.toString() ?? '0') ??
              0.0,
      totalUnrealizedPnl:
          double.tryParse(json['total_unrealized_pnl']?.toString() ?? '0') ??
              0.0,
      totalMarginBalance:
          double.tryParse(json['total_margin_balance']?.toString() ?? '0') ??
              0.0,
      totalPositionInitialMargin: double.tryParse(
              json['total_position_initial_margin']?.toString() ?? '0') ??
          0.0,
      totalOpenOrderInitialMargin: double.tryParse(
              json['total_open_order_initial_margin']?.toString() ?? '0') ??
          0.0,
      availableBalance:
          double.tryParse(json['available_balance']?.toString() ?? '0') ?? 0.0,
      maxWithdrawAmount:
          double.tryParse(json['max_withdraw_amount']?.toString() ?? '0') ??
              0.0,
      canTrade: json['can_trade'] ?? true,
      canDeposit: json['can_deposit'] ?? true,
      canWithdraw: json['can_withdraw'] ?? true,
      assets: (json['assets'] as List?)
              ?.map((asset) => AssetBalance.fromJson(asset))
              .toList() ??
          [],
    );
  }
}

class AssetBalance {
  final String asset;
  final double walletBalance;
  final double unrealizedProfit;
  final double marginBalance;
  final double maintMargin;
  final double initialMargin;
  final double positionInitialMargin;
  final double openOrderInitialMargin;
  final double maxWithdrawAmount;
  final double crossWalletBalance;
  final double crossUnPnl;
  final double availableBalance;
  final bool marginAvailable;
  final int updateTime;

  AssetBalance({
    required this.asset,
    required this.walletBalance,
    required this.unrealizedProfit,
    required this.marginBalance,
    required this.maintMargin,
    required this.initialMargin,
    required this.positionInitialMargin,
    required this.openOrderInitialMargin,
    required this.maxWithdrawAmount,
    required this.crossWalletBalance,
    required this.crossUnPnl,
    required this.availableBalance,
    required this.marginAvailable,
    required this.updateTime,
  });

  factory AssetBalance.fromJson(Map<String, dynamic> json) {
    return AssetBalance(
      asset: json['asset'] ?? '',
      walletBalance:
          double.tryParse(json['walletBalance']?.toString() ?? '0') ?? 0.0,
      unrealizedProfit:
          double.tryParse(json['unrealizedProfit']?.toString() ?? '0') ?? 0.0,
      marginBalance:
          double.tryParse(json['marginBalance']?.toString() ?? '0') ?? 0.0,
      maintMargin:
          double.tryParse(json['maintMargin']?.toString() ?? '0') ?? 0.0,
      initialMargin:
          double.tryParse(json['initialMargin']?.toString() ?? '0') ?? 0.0,
      positionInitialMargin:
          double.tryParse(json['positionInitialMargin']?.toString() ?? '0') ??
              0.0,
      openOrderInitialMargin:
          double.tryParse(json['openOrderInitialMargin']?.toString() ?? '0') ??
              0.0,
      maxWithdrawAmount:
          double.tryParse(json['maxWithdrawAmount']?.toString() ?? '0') ?? 0.0,
      crossWalletBalance:
          double.tryParse(json['crossWalletBalance']?.toString() ?? '0') ?? 0.0,
      crossUnPnl: double.tryParse(json['crossUnPnl']?.toString() ?? '0') ?? 0.0,
      availableBalance:
          double.tryParse(json['availableBalance']?.toString() ?? '0') ?? 0.0,
      marginAvailable: json['marginAvailable'] ?? true,
      updateTime: int.tryParse(json['updateTime']?.toString() ?? '0') ?? 0,
    );
  }
}

// Dual Side Init Response Models
class DualSideInitResponse {
  final String status;
  final String message;
  final String responsecode;
  final DualSideInitData? data;

  DualSideInitResponse({
    required this.status,
    required this.message,
    required this.responsecode,
    this.data,
  });

  factory DualSideInitResponse.fromJson(Map<String, dynamic> json) {
    return DualSideInitResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      responsecode: json['responsecode'] ?? '',
      data: json['data'] != null ? DualSideInitData.fromJson(json['data']) : null,
    );
  }

  bool get isSuccess => status == 'success';
}

class DualSideInitData {
  final String pairId;
  final double entryPrice;
  final double longTp;
  final double shortTp;
  final int longPositionId;
  final int shortPositionId;
  final int strategyId;

  DualSideInitData({
    required this.pairId,
    required this.entryPrice,
    required this.longTp,
    required this.shortTp,
    required this.longPositionId,
    required this.shortPositionId,
    required this.strategyId,
  });

  factory DualSideInitData.fromJson(Map<String, dynamic> json) {
    return DualSideInitData(
      pairId: json['pair_id'] ?? '',
      entryPrice: (json['entry_price'] ?? 0.0).toDouble(),
      longTp: (json['long_tp'] ?? 0.0).toDouble(),
      shortTp: (json['short_tp'] ?? 0.0).toDouble(),
      longPositionId: json['long_position_id'] ?? 0,
      shortPositionId: json['short_position_id'] ?? 0,
      strategyId: json['strategy_id'] ?? 0,
    );
  }
}

// Dual Side Trade History Response Models
class DualSideTradeHistoryResponse {
  final String status;
  final String message;
  final String responsecode;
  final DualSideTradeHistoryData? data;

  DualSideTradeHistoryResponse({
    required this.status,
    required this.message,
    required this.responsecode,
    this.data,
  });

  factory DualSideTradeHistoryResponse.fromJson(Map<String, dynamic> json) {
    return DualSideTradeHistoryResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      responsecode: json['responsecode'] ?? '',
      data: json['data'] != null ? DualSideTradeHistoryData.fromJson(json['data']) : null,
    );
  }

  bool get isSuccess => status == 'success';
}

class DualSideTradeHistoryData {
  final List<DualSideTradeRecord> trades;
  final int totalCount;
  final bool hasMore;

  DualSideTradeHistoryData({
    required this.trades,
    required this.totalCount,
    required this.hasMore,
  });

  factory DualSideTradeHistoryData.fromJson(Map<String, dynamic> json) {
    return DualSideTradeHistoryData(
      trades: json['trades'] != null
          ? List<DualSideTradeRecord>.from(json['trades'].map((x) => DualSideTradeRecord.fromJson(x)))
          : [],
      totalCount: json['total_count'] ?? 0,
      hasMore: json['has_more'] ?? false,
    );
  }
}

class DualSideTradeRecord {
  final int id;
  final String symbol;
  final String side;
  final double quantity;
  final double entryPrice;
  final double? exitPrice; // Can be null for open positions
  final double realizedPnl;
  final double unrealizedPnl;
  final double commission;
  final double netPnl;
  final DateTime entryTime;
  final DateTime? exitTime; // Can be null for open positions
  final String strategyId;
  final String status;
  final String pairId;

  DualSideTradeRecord({
    required this.id,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.entryPrice,
    this.exitPrice,
    required this.realizedPnl,
    required this.unrealizedPnl,
    required this.commission,
    required this.netPnl,
    required this.entryTime,
    this.exitTime,
    required this.strategyId,
    required this.status,
    required this.pairId,
  });

  factory DualSideTradeRecord.fromJson(Map<String, dynamic> json) {
    return DualSideTradeRecord(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      symbol: json['symbol']?.toString() ?? '',
      side: json['side']?.toString() ?? 'BUY',
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      entryPrice: double.tryParse(json['entry_price']?.toString() ?? '0') ?? 0.0,
      exitPrice: json['exit_price'] != null
          ? double.tryParse(json['exit_price'].toString())
          : null,
      realizedPnl: double.tryParse(json['pnl']?.toString() ?? '0') ?? 0.0,
      unrealizedPnl: double.tryParse(json['unrealized_pnl']?.toString() ?? '0') ?? 0.0,
      commission: double.tryParse(json['commission']?.toString() ?? '0') ?? 0.0,
      netPnl: double.tryParse(json['net_pnl']?.toString() ?? '0') ?? 0.0,
      entryTime: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      exitTime: json['closed_at'] != null
          ? DateTime.tryParse(json['closed_at'].toString())
          : null,
      strategyId: json['pair_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'UNKNOWN',
      pairId: json['pair_id']?.toString() ?? '',
    );
  }

  // Convert to FutureTradeHistory for UI compatibility
  FutureTradeHistory toFutureTradeHistory() {
    // Handle nullable exitTime and exitPrice for open positions
    final closeTime = exitTime ?? DateTime.now();
    final duration = closeTime.difference(entryTime);
    final actualExitPrice = exitPrice ?? entryPrice; // Use entry price if no exit price
    final profitPercent = entryPrice > 0 ? ((actualExitPrice - entryPrice) / entryPrice) * 100 : 0.0;

    // Determine close reason based on status
    String closeReason = 'MANUAL';
    if (status == 'OPEN') {
      closeReason = 'OPEN';
    } else if (unrealizedPnl > 0) {
      closeReason = 'TP'; // Take profit
    } else if (unrealizedPnl < 0) {
      closeReason = 'SL'; // Stop loss
    }

    return FutureTradeHistory(
      id: id.toString(),
      symbol: symbol,
      side: side == 'BUY' ? 'LONG' : 'SHORT',
      entryPrice: entryPrice,
      exitPrice: actualExitPrice,
      quantity: quantity,
      leverage: 1.0, // Default leverage, can be enhanced later
      realizedPnl: status == 'OPEN' ? unrealizedPnl : realizedPnl,
      profitPercent: profitPercent,
      tradeDuration: duration,
      openTime: entryTime,
      closeTime: closeTime,
      closeReason: closeReason,
      fees: commission,
    );
  }

  bool get isProfit => (status == 'OPEN' ? unrealizedPnl : realizedPnl) > 0;
  bool get isLong => side == 'BUY';
  bool get isShort => side == 'SELL';
  bool get isOpen => status == 'OPEN';
  bool get isClosed => status == 'CLOSED';
}

// Dual Side Performance Response Model
class DualSidePerformanceResponse {
  final String status;
  final String message;
  final String responsecode;
  final List<DailyPerformanceRecord>? data;

  DualSidePerformanceResponse({
    required this.status,
    required this.message,
    required this.responsecode,
    this.data,
  });

  factory DualSidePerformanceResponse.fromJson(Map<String, dynamic> json) {
    return DualSidePerformanceResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      responsecode: json['responsecode'] ?? '',
      data: json['data'] != null && json['data'] is List
          ? List<DailyPerformanceRecord>.from(
              json['data'].map((x) => DailyPerformanceRecord.fromJson(x)))
          : null,
    );
  }

  bool get isSuccess => status == 'success';
}

// Daily Performance Record Model (matches your database structure)
class DailyPerformanceRecord {
  final int id;
  final int strategyId;
  final String userId;
  final String symbol;
  final String date;
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double dailyPnl;
  final double cumulativePnl;
  final double maxDrawdown;
  final double winRate;
  final double avgProfitPerTrade;
  final String createdAt;

  DailyPerformanceRecord({
    required this.id,
    required this.strategyId,
    required this.userId,
    required this.symbol,
    required this.date,
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.dailyPnl,
    required this.cumulativePnl,
    required this.maxDrawdown,
    required this.winRate,
    required this.avgProfitPerTrade,
    required this.createdAt,
  });

  factory DailyPerformanceRecord.fromJson(Map<String, dynamic> json) {
    return DailyPerformanceRecord(
      id: json['id'] ?? 0,
      strategyId: json['strategy_id'] ?? 0,
      userId: json['user_id'] ?? '',
      symbol: json['symbol'] ?? '',
      date: json['date'] ?? '',
      totalTrades: json['total_trades'] ?? 0,
      winningTrades: json['winning_trades'] ?? 0,
      losingTrades: json['losing_trades'] ?? 0,
      dailyPnl: double.tryParse(json['daily_pnl']?.toString() ?? '0') ?? 0.0,
      cumulativePnl: double.tryParse(json['cumulative_pnl']?.toString() ?? '0') ?? 0.0,
      maxDrawdown: double.tryParse(json['max_drawdown']?.toString() ?? '0') ?? 0.0,
      winRate: double.tryParse(json['win_rate']?.toString() ?? '0') ?? 0.0,
      avgProfitPerTrade: double.tryParse(json['avg_profit_per_trade']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'strategy_id': strategyId,
      'user_id': userId,
      'symbol': symbol,
      'date': date,
      'total_trades': totalTrades,
      'winning_trades': winningTrades,
      'losing_trades': losingTrades,
      'daily_pnl': dailyPnl,
      'cumulative_pnl': cumulativePnl,
      'max_drawdown': maxDrawdown,
      'win_rate': winRate,
      'avg_profit_per_trade': avgProfitPerTrade,
      'created_at': createdAt,
    };
  }

  // Helper getters
  bool get isProfit => dailyPnl > 0;
  bool get hasDrawdown => maxDrawdown < 0;
  String get formattedDate {
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }
}

// Dual Side PnL Tracking Response Model
class DualSidePnlTrackingResponse {
  final String status;
  final String message;
  final String responsecode;
  final PnlTrackingData? data;

  DualSidePnlTrackingResponse({
    required this.status,
    required this.message,
    required this.responsecode,
    this.data,
  });

  factory DualSidePnlTrackingResponse.fromJson(Map<String, dynamic> json) {
    return DualSidePnlTrackingResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      responsecode: json['responsecode'] ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? PnlTrackingData.fromJson(json['data'])
          : null,
    );
  }

  bool get isSuccess => status == 'success';
}

// PnL Tracking Data Model
class PnlTrackingData {
  final String period;
  final List<PnlTrackingRecord> pnlTracking;

  PnlTrackingData({
    required this.period,
    required this.pnlTracking,
  });

  factory PnlTrackingData.fromJson(Map<String, dynamic> json) {
    return PnlTrackingData(
      period: json['period'] ?? '',
      pnlTracking: json['pnl_tracking'] != null && json['pnl_tracking'] is List
          ? List<PnlTrackingRecord>.from(
              json['pnl_tracking'].map((x) => PnlTrackingRecord.fromJson(x)))
          : [],
    );
  }
}

// PnL Tracking Record Model
class PnlTrackingRecord {
  final String period;
  final int tradeCount;
  final int winningTrades;
  final int losingTrades;
  final double totalPnl;
  final double avgPnl;
  final double bestTrade;
  final double worstTrade;
  final double totalVolume;

  PnlTrackingRecord({
    required this.period,
    required this.tradeCount,
    required this.winningTrades,
    required this.losingTrades,
    required this.totalPnl,
    required this.avgPnl,
    required this.bestTrade,
    required this.worstTrade,
    required this.totalVolume,
  });

  factory PnlTrackingRecord.fromJson(Map<String, dynamic> json) {
    return PnlTrackingRecord(
      period: json['period'] ?? '',
      tradeCount: json['trade_count'] ?? 0,
      winningTrades: json['winning_trades'] ?? 0,
      losingTrades: json['losing_trades'] ?? 0,
      totalPnl: double.tryParse(json['total_pnl']?.toString() ?? '0') ?? 0.0,
      avgPnl: double.tryParse(json['avg_pnl']?.toString() ?? '0') ?? 0.0,
      bestTrade: double.tryParse(json['best_trade']?.toString() ?? '0') ?? 0.0,
      worstTrade: double.tryParse(json['worst_trade']?.toString() ?? '0') ?? 0.0,
      totalVolume: double.tryParse(json['total_volume']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'trade_count': tradeCount,
      'winning_trades': winningTrades,
      'losing_trades': losingTrades,
      'total_pnl': totalPnl,
      'avg_pnl': avgPnl,
      'best_trade': bestTrade,
      'worst_trade': worstTrade,
      'total_volume': totalVolume,
    };
  }

  // Helper getters
  bool get isProfit => totalPnl > 0;
  double get winRate => tradeCount > 0 ? (winningTrades / tradeCount) * 100 : 0.0;
  bool get hasPositiveBestTrade => bestTrade > 0;
  bool get hasNegativeWorstTrade => worstTrade < 0;
}

// Dual Side Monitor Response Model
class DualSideMonitorResponse {
  final String status;
  final String message;
  final String responsecode;
  final MonitorData? data;

  DualSideMonitorResponse({
    required this.status,
    required this.message,
    required this.responsecode,
    this.data,
  });

  factory DualSideMonitorResponse.fromJson(Map<String, dynamic> json) {
    return DualSideMonitorResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      responsecode: json['responsecode'] ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? MonitorData.fromJson(json['data'])
          : null,
    );
  }

  bool get isSuccess => status == 'success';
}

// Monitor Data Model
class MonitorData {
  final int tpHits;
  final int strategiesChecked;
  final List<String> strategiesUpdated;
  final String lastCheck;

  MonitorData({
    required this.tpHits,
    required this.strategiesChecked,
    required this.strategiesUpdated,
    required this.lastCheck,
  });

  factory MonitorData.fromJson(Map<String, dynamic> json) {
    return MonitorData(
      tpHits: json['tp_hits'] ?? 0,
      strategiesChecked: json['strategies_checked'] ?? 0,
      strategiesUpdated: json['strategies_updated'] != null && json['strategies_updated'] is List
          ? List<String>.from(json['strategies_updated'])
          : [],
      lastCheck: json['last_check'] ?? '',
    );
  }

  bool get hasActivity => tpHits > 0 || strategiesUpdated.isNotEmpty;
}

// Dual Side Monitor TP/SL Response Model
class DualSideMonitorTpSlResponse {
  final String status;
  final String message;
  final String responsecode;
  final MonitorTpSlData? data;

  DualSideMonitorTpSlResponse({
    required this.status,
    required this.message,
    required this.responsecode,
    this.data,
  });

  factory DualSideMonitorTpSlResponse.fromJson(Map<String, dynamic> json) {
    return DualSideMonitorTpSlResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      responsecode: json['responsecode'] ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? MonitorTpSlData.fromJson(json['data'])
          : null,
    );
  }

  bool get isSuccess => status == 'success';
}

// Monitor TP/SL Data Model
class MonitorTpSlData {
  final int executedTpSl;
  final int positionsChecked;
  final List<String> executedPositions;
  final String lastCheck;

  MonitorTpSlData({
    required this.executedTpSl,
    required this.positionsChecked,
    required this.executedPositions,
    required this.lastCheck,
  });

  factory MonitorTpSlData.fromJson(Map<String, dynamic> json) {
    return MonitorTpSlData(
      executedTpSl: json['executed_tp_sl'] ?? 0,
      positionsChecked: json['positions_checked'] ?? 0,
      executedPositions: json['executed_positions'] != null && json['executed_positions'] is List
          ? List<String>.from(json['executed_positions'])
          : [],
      lastCheck: json['last_check'] ?? '',
    );
  }

  bool get hasExecutions => executedTpSl > 0;
}

// Dual Side Emergency Stop Response Model
class DualSideEmergencyStopResponse {
  final String status;
  final String message;
  final String responsecode;
  final EmergencyStopData? data;

  DualSideEmergencyStopResponse({
    required this.status,
    required this.message,
    required this.responsecode,
    this.data,
  });

  factory DualSideEmergencyStopResponse.fromJson(Map<String, dynamic> json) {
    return DualSideEmergencyStopResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      responsecode: json['responsecode'] ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? EmergencyStopData.fromJson(json['data'])
          : null,
    );
  }

  bool get isSuccess => status == 'success';
}

// Emergency Stop Data Model
class EmergencyStopData {
  final int stoppedStrategies;
  final int totalStrategies;
  final List<String> errors;

  EmergencyStopData({
    required this.stoppedStrategies,
    required this.totalStrategies,
    required this.errors,
  });

  factory EmergencyStopData.fromJson(Map<String, dynamic> json) {
    return EmergencyStopData(
      stoppedStrategies: json['stopped_strategies'] ?? 0,
      totalStrategies: json['total_strategies'] ?? 0,
      errors: json['errors'] != null && json['errors'] is List
          ? List<String>.from(json['errors'])
          : [],
    );
  }

  bool get hasStoppedItems => stoppedStrategies > 0;
  bool get hasErrors => errors.isNotEmpty;
  String get stopSummary => 'Stopped $stoppedStrategies of $totalStrategies strategies';
}

// Dual Side Risk Settings Response Model
class DualSideRiskSettingsResponse {
  final String status;
  final String message;
  final String responsecode;
  final RiskSettingsData? data;

  DualSideRiskSettingsResponse({
    required this.status,
    required this.message,
    required this.responsecode,
    this.data,
  });

  factory DualSideRiskSettingsResponse.fromJson(Map<String, dynamic> json) {
    return DualSideRiskSettingsResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      responsecode: json['responsecode'] ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? RiskSettingsData.fromJson(json['data'])
          : null,
    );
  }

  bool get isSuccess => status == 'success';
}

// Risk Settings Data Model
class RiskSettingsData {
  final String id;
  final String userId;
  final int maxOpenPositions;
  final double maxDailyLoss;
  final double maxPositionSize;
  final double defaultTpPercentage;
  final double defaultSlPercentage;
  final int maxLeverage;
  final bool autoTpSlEnabled;
  final bool duplicatePositionCheck;
  final bool emergencyStopEnabled;
  final double emergencyStopLossPercentage;
  final String createdAt;
  final String updatedAt;

  RiskSettingsData({
    required this.id,
    required this.userId,
    required this.maxOpenPositions,
    required this.maxDailyLoss,
    required this.maxPositionSize,
    required this.defaultTpPercentage,
    required this.defaultSlPercentage,
    required this.maxLeverage,
    required this.autoTpSlEnabled,
    required this.duplicatePositionCheck,
    required this.emergencyStopEnabled,
    required this.emergencyStopLossPercentage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RiskSettingsData.fromJson(Map<String, dynamic> json) {
    return RiskSettingsData(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      maxOpenPositions: int.tryParse(json['max_open_positions']?.toString() ?? '0') ?? 0,
      maxDailyLoss: double.tryParse(json['max_daily_loss']?.toString() ?? '0') ?? 0.0,
      maxPositionSize: double.tryParse(json['max_position_size']?.toString() ?? '0') ?? 0.0,
      defaultTpPercentage: double.tryParse(json['default_tp_percentage']?.toString() ?? '0') ?? 0.0,
      defaultSlPercentage: double.tryParse(json['default_sl_percentage']?.toString() ?? '0') ?? 0.0,
      maxLeverage: int.tryParse(json['max_leverage']?.toString() ?? '0') ?? 0,
      autoTpSlEnabled: json['auto_tp_sl_enabled']?.toString() == '1',
      duplicatePositionCheck: json['duplicate_position_check']?.toString() == '1',
      emergencyStopEnabled: json['emergency_stop_enabled']?.toString() == '1',
      emergencyStopLossPercentage: double.tryParse(json['emergency_stop_loss_percentage']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'max_open_positions': maxOpenPositions,
      'max_daily_loss': maxDailyLoss,
      'max_position_size': maxPositionSize,
      'default_tp_percentage': defaultTpPercentage,
      'default_sl_percentage': defaultSlPercentage,
      'max_leverage': maxLeverage,
      'auto_tp_sl_enabled': autoTpSlEnabled ? '1' : '0',
      'duplicate_position_check': duplicatePositionCheck ? '1' : '0',
      'emergency_stop_enabled': emergencyStopEnabled ? '1' : '0',
      'emergency_stop_loss_percentage': emergencyStopLossPercentage,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper getters
  String get formattedMaxDailyLoss => '\$${maxDailyLoss.toStringAsFixed(2)}';
  String get formattedMaxPositionSize => maxPositionSize.toStringAsFixed(8);
  String get formattedTpPercentage => '${defaultTpPercentage.toStringAsFixed(2)}%';
  String get formattedSlPercentage => '${defaultSlPercentage.toStringAsFixed(2)}%';
  String get formattedEmergencyStopPercentage => '${emergencyStopLossPercentage.toStringAsFixed(2)}%';
}

// Dual Side Trading Report Response Models
class DualSideTradingReportResponse {
  final String status;
  final String message;
  final String responsecode;
  final DualSideTradingReportData? data;

  DualSideTradingReportResponse({
    required this.status,
    required this.message,
    required this.responsecode,
    this.data,
  });

  factory DualSideTradingReportResponse.fromJson(Map<String, dynamic> json) {
    return DualSideTradingReportResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      responsecode: json['responsecode'] ?? '',
      data: json['data'] != null ? DualSideTradingReportData.fromJson(json['data']) : null,
    );
  }

  bool get isSuccess => status == 'success';
}

class DualSideTradingReportData {
  final ReportPeriod period;
  final TradingOverview overview;
  final PositionAnalysis positionAnalysis;
  final List<SymbolBreakdown> symbolBreakdown;
  final RiskMetrics riskMetrics;

  DualSideTradingReportData({
    required this.period,
    required this.overview,
    required this.positionAnalysis,
    required this.symbolBreakdown,
    required this.riskMetrics,
  });

  factory DualSideTradingReportData.fromJson(Map<String, dynamic> json) {
    return DualSideTradingReportData(
      period: ReportPeriod.fromJson(json['period'] ?? {}),
      overview: TradingOverview.fromJson(json['overview'] ?? {}),
      positionAnalysis: PositionAnalysis.fromJson(json['position_analysis'] ?? {}),
      symbolBreakdown: json['symbol_breakdown'] != null
          ? List<SymbolBreakdown>.from(json['symbol_breakdown'].map((x) => SymbolBreakdown.fromJson(x)))
          : [],
      riskMetrics: RiskMetrics.fromJson(json['risk_metrics'] ?? {}),
    );
  }
}

class ReportPeriod {
  final String from;
  final String to;

  ReportPeriod({required this.from, required this.to});

  factory ReportPeriod.fromJson(Map<String, dynamic> json) {
    return ReportPeriod(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }
}

class TradingOverview {
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double winRate;
  final double totalPnl;
  final double unrealizedPnl;
  final double totalVolume;
  final double bestTrade;
  final double worstTrade;
  final double avgTradePnl;
  final double profitFactor;

  TradingOverview({
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.winRate,
    required this.totalPnl,
    required this.unrealizedPnl,
    required this.totalVolume,
    required this.bestTrade,
    required this.worstTrade,
    required this.avgTradePnl,
    required this.profitFactor,
  });

  factory TradingOverview.fromJson(Map<String, dynamic> json) {
    return TradingOverview(
      totalTrades: json['total_trades'] ?? 0,
      winningTrades: json['winning_trades'] ?? 0,
      losingTrades: json['losing_trades'] ?? 0,
      winRate: (json['win_rate'] ?? 0.0).toDouble(),
      totalPnl: (json['total_pnl'] ?? 0.0).toDouble(),
      unrealizedPnl: (json['unrealized_pnl'] ?? 0.0).toDouble(),
      totalVolume: (json['total_volume'] ?? 0.0).toDouble(),
      bestTrade: (json['best_trade'] ?? 0.0).toDouble(),
      worstTrade: (json['worst_trade'] ?? 0.0).toDouble(),
      avgTradePnl: (json['avg_trade_pnl'] ?? 0.0).toDouble(),
      profitFactor: (json['profit_factor'] ?? 0.0).toDouble(),
    );
  }
}

class PositionAnalysis {
  final int longTrades;
  final int shortTrades;
  final double longPnl;
  final double shortPnl;
  final double longWinRate;
  final double shortWinRate;

  PositionAnalysis({
    required this.longTrades,
    required this.shortTrades,
    required this.longPnl,
    required this.shortPnl,
    required this.longWinRate,
    required this.shortWinRate,
  });

  factory PositionAnalysis.fromJson(Map<String, dynamic> json) {
    return PositionAnalysis(
      longTrades: json['long_trades'] ?? 0,
      shortTrades: json['short_trades'] ?? 0,
      longPnl: (json['long_pnl'] ?? 0.0).toDouble(),
      shortPnl: (json['short_pnl'] ?? 0.0).toDouble(),
      longWinRate: (json['long_win_rate'] ?? 0.0).toDouble(),
      shortWinRate: (json['short_win_rate'] ?? 0.0).toDouble(),
    );
  }
}

class SymbolBreakdown {
  final String symbol;
  final int trades;
  final double pnl;
  final double winRate;

  SymbolBreakdown({
    required this.symbol,
    required this.trades,
    required this.pnl,
    required this.winRate,
  });

  factory SymbolBreakdown.fromJson(Map<String, dynamic> json) {
    return SymbolBreakdown(
      symbol: json['symbol'] ?? '',
      trades: json['trades'] ?? 0,
      pnl: (json['pnl'] ?? 0.0).toDouble(),
      winRate: (json['win_rate'] ?? 0.0).toDouble(),
    );
  }
}

class RiskMetrics {
  final double maxDrawdown;
  final double sharpeRatio;
  final double volatility;

  RiskMetrics({
    required this.maxDrawdown,
    required this.sharpeRatio,
    required this.volatility,
  });

  factory RiskMetrics.fromJson(Map<String, dynamic> json) {
    return RiskMetrics(
      maxDrawdown: (json['max_drawdown'] ?? 0.0).toDouble(),
      sharpeRatio: (json['sharpe_ratio'] ?? 0.0).toDouble(),
      volatility: (json['volatility'] ?? 0.0).toDouble(),
    );
  }
}
