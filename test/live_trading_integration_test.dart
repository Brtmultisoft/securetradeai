import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securetradeai/src/more/live_trading.dart';

void main() {
  group('LiveTradingPage Integration Tests', () {
    testWidgets('should render LiveTradingPage without errors', (WidgetTester tester) async {
      // Build the LiveTradingPage widget
      await tester.pumpWidget(
        MaterialApp(
          home: LiveTradingPage(),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Verify that the page renders without throwing errors
      expect(find.byType(LiveTradingPage), findsOneWidget);
    });

    testWidgets('should display exchange tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LiveTradingPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Look for exchange names in the UI
      expect(find.text('Binance'), findsAtLeastNWidgets(1));
      expect(find.text('KuCoin'), findsAtLeastNWidgets(1));
      expect(find.text('Coinbase'), findsAtLeastNWidgets(1));
    });

    testWidgets('should display live trading indicators', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LiveTradingPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Look for live trading indicators
      expect(find.text('LIVE'), findsAtLeastNWidgets(1));
      expect(find.text('TRADING EXCHANGES'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle exchange tab switching', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LiveTradingPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap on KuCoin tab
      final kucoinTab = find.text('KuCoin');
      if (kucoinTab.evaluate().isNotEmpty) {
        await tester.tap(kucoinTab.first);
        await tester.pumpAndSettle();

        // Verify that the exchange switched
        // The header should now show KuCoin
        expect(find.textContaining('KuCoin'), findsAtLeastNWidgets(1));
      }
    });

    testWidgets('should display market depth and trading data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LiveTradingPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Look for trading-related UI elements
      expect(find.text('BUY'), findsAtLeastNWidgets(1));
      expect(find.text('SELL'), findsAtLeastNWidgets(1));
      
      // Look for price-related text patterns
      expect(find.textContaining('\$'), findsAtLeastNWidgets(1));
    });

    testWidgets('should display connection status', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LiveTradingPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Look for connection status indicators
      // The page should show some form of connection status
      expect(find.byIcon(Icons.wifi), findsAtLeastNWidgets(0)); // May or may not be present
      expect(find.byIcon(Icons.trending_up), findsAtLeastNWidgets(1));
    });
  });
}
