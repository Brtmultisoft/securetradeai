import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:rapidtradeai/Method/TradeSettingProvider.dart';
import 'package:rapidtradeai/method/cycleMethod.dart';
import 'package:rapidtradeai/method/homepageProvider.dart';
import 'package:rapidtradeai/method/tradeSettingSubbinprovider.dart';
import 'package:rapidtradeai/src/Service/background_service.dart';
import 'package:rapidtradeai/src/Service/future_trading_background_service.dart';
import 'package:rapidtradeai/src/Service/notification_service.dart';
import 'package:rapidtradeai/src/language/string.dart';

import 'model/repoModel.dart';
import 'src/Service/bot_service.dart';
import 'src/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Start the bot service
  await BotService().startBotService();

  // Initialize the background service
  await initializeBackgroundService();

  // Initialize the future trading background monitoring
  await FutureTradingBackgroundService.initializeFutureTradingMonitoring();

  // Initialize the notification service
  await NotificationService().initialize();

  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Repo>(create: (context) => Repo()),
        ChangeNotifierProvider<TradeSettingProvider>(
            create: (context) => TradeSettingProvider()),
        ChangeNotifierProvider<HomePageProvider>(
            create: (context) => HomePageProvider()),
        ChangeNotifierProvider<CircleProvider>(
            create: (context) => CircleProvider()),
        ChangeNotifierProvider<TradeSettingSubbinProvider>(
            create: (context) => TradeSettingSubbinProvider())
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RapidTradeAI',
        translations: LocaleString(),
        locale: Get.deviceLocale,
        fallbackLocale: const Locale('en', 'US'),
        theme: _buildTheme(),
        home: const SplashScreen(),
      ),
    );
  }

  /// Build responsive theme for web and mobile
  ThemeData _buildTheme() {
    return ThemeData(
      // Use Material 3 design system
      useMaterial3: true,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF03DAC6),
        secondary: Color(0xFF2196F3),
        surface: Color(0xFF1A2234),
        background: Color(0xFF0B0E11),
        error: Color(0xFFCF6679),
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.black,
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF171d28),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          fontFamily: 'Nunito',
        ),
      ),

      // Card theme
      cardTheme: CardTheme(
        color: const Color(0xFF1A2234),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF03DAC6),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF232A3B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.white54),
        labelStyle: const TextStyle(color: Colors.white),
      ),

      // Text theme - Bigger fonts for web
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: Colors.white,
          fontFamily: 'Nunito',
          fontSize: kIsWeb ? 48 : 32, // Increased from 40
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: Colors.white,
          fontFamily: 'Nunito',
          fontSize: kIsWeb ? 42 : 28, // Increased from 34
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: Colors.white,
          fontFamily: 'Nunito',
          fontSize: kIsWeb ? 36 : 24, // Increased from 30
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: Colors.white,
          fontFamily: 'Nunito',
          fontSize: kIsWeb ? 32 : 22, // Increased from 26
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: Colors.white,
          fontFamily: 'Nunito',
          fontSize: kIsWeb ? 28 : 20, // Increased from 24
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: Colors.white,
          fontFamily: 'Nunito',
          fontSize: kIsWeb ? 26 : 18, // Increased from 22
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: Colors.white,
          fontFamily: 'Nunito',
          fontSize: kIsWeb ? 24 : 16, // Increased from 20
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          color: Colors.white,
          fontFamily: 'Nunito',
          fontSize: kIsWeb ? 22 : 14, // Increased from 18
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: Colors.white,
          fontFamily: 'Nunito',
          fontSize: kIsWeb ? 20 : 12, // Increased from 16
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: Colors.white,
          fontFamily: 'Nunito',
          fontSize: kIsWeb ? 24 : 16, // Increased from 20
        ),
        bodyMedium: TextStyle(
          color: Colors.white,
          fontFamily: 'Nunito',
          fontSize: kIsWeb ? 22 : 14, // Increased from 18
        ),
        bodySmall: TextStyle(
          color: Colors.white,
          fontFamily: 'Nunito',
          fontSize: kIsWeb ? 20 : 12, // Increased from 16
        ),
        labelLarge: TextStyle(
          color: Colors.white,
          fontFamily: 'Nunito',
          fontSize: kIsWeb ? 22 : 14, // Increased from 18
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: Colors.white,
          fontFamily: 'Nunito',
          fontSize: kIsWeb ? 20 : 12, // Increased from 16
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: Colors.white,
          fontFamily: 'Nunito',
          fontSize: kIsWeb ? 18 : 10, // Increased from 14
          fontWeight: FontWeight.w500,
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF171d28),
        selectedItemColor: Color(0xFF03DAC6),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
      ),

      // Scaffold background
      scaffoldBackgroundColor: const Color(0xFF1A2234),

      // Font family
      fontFamily: 'Nunito',
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
