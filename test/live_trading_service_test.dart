import 'package:flutter_test/flutter_test.dart';
import 'package:securetradeai/src/Service/live_trading_service.dart';

void main() {
  group('LiveTradingService Tests', () {
    late LiveTradingService liveService;

    setUp(() {
      liveService = LiveTradingService();
    });

    tearDown(() {
      liveService.dispose();
    });

    test('should initialize with correct exchange configurations', () {
      final configs = liveService.exchangeConfigs;
      
      expect(configs.containsKey('Binance'), true);
      expect(configs.containsKey('KuCoin'), true);
      expect(configs.containsKey('Coinbase'), true);
      expect(configs.containsKey('Crypto.com'), true);
      expect(configs.containsKey('OKX'), true);
      
      // Test Binance configuration
      final binanceConfig = configs['Binance']!;
      expect(binanceConfig.name, 'Binance');
      expect(binanceConfig.wsUrl, 'wss://stream.binance.com:9443/ws');
      expect(binanceConfig.restUrl, 'https://api.binance.com/api/v3');
      expect(binanceConfig.supportedPairs.isNotEmpty, true);
      expect(binanceConfig.supportedPairs.contains('BTCUSDT'), true);
    });

    test('should return correct exchange pairs', () {
      final binancePairs = liveService.getExchangePairs('Binance');
      expect(binancePairs.isNotEmpty, true);
      expect(binancePairs.contains('BTCUSDT'), true);
      expect(binancePairs.contains('ETHUSDT'), true);
      
      final kucoinPairs = liveService.getExchangePairs('KuCoin');
      expect(kucoinPairs.isNotEmpty, true);
      expect(kucoinPairs.contains('BTC-USDT'), true);
      
      final coinbasePairs = liveService.getExchangePairs('Coinbase');
      expect(coinbasePairs.isNotEmpty, true);
      expect(coinbasePairs.contains('BTC-USD'), true);
    });

    test('should format pairs correctly for different exchanges', () {
      expect(liveService.formatPairForExchange('BTCUSDT', 'Binance'), 'BTCUSDT');
      expect(liveService.formatPairForExchange('BTC-USDT', 'KuCoin'), 'BTC-USDT');
      expect(liveService.formatPairForExchange('BTCUSDT', 'KuCoin'), 'BTC-USDT');
      expect(liveService.formatPairForExchange('BTCUSDT', 'Coinbase'), 'BTC-USDT');
      expect(liveService.formatPairForExchange('BTCUSDT', 'Crypto.com'), 'BTC_USDT');
      expect(liveService.formatPairForExchange('BTCUSDT', 'OKX'), 'BTC-USDT');
    });

    test('should have empty cached data initially', () {
      expect(liveService.cachedTickers.isEmpty, true);
      expect(liveService.cachedOrderBooks.isEmpty, true);
      expect(liveService.recentTrades.isEmpty, true);
    });

    test('should provide stream controllers', () {
      expect(liveService.tickerStream, isNotNull);
      expect(liveService.orderBookStream, isNotNull);
      expect(liveService.tradeStream, isNotNull);
    });

    test('should handle unknown exchange gracefully', () {
      final unknownPairs = liveService.getExchangePairs('UnknownExchange');
      expect(unknownPairs.isEmpty, true);
      
      final formattedPair = liveService.formatPairForExchange('BTCUSDT', 'UnknownExchange');
      expect(formattedPair, 'BTCUSDT');
    });
  });
}
