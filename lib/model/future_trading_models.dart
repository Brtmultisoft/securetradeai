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
