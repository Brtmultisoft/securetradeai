import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:securetradeai/Method/TradeSettingProvider.dart';
import 'package:securetradeai/method/cycleMethod.dart';
import 'package:securetradeai/method/homepageProvider.dart';
import 'package:securetradeai/method/tradeSettingSubbinprovider.dart';
import 'package:securetradeai/src/Service/background_service.dart';
import 'package:securetradeai/src/Service/notification_service.dart';
import 'package:securetradeai/src/language/string.dart';

import 'model/repoModel.dart';
import 'src/Service/bot_service.dart';
import 'src/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start the bot service
  await BotService().startBotService();

  // Initialize the background service
  await initializeBackgroundService();

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
        title: 'SecureTradeAi',
        translations: LocaleString(),
        locale: Get.deviceLocale,
        fallbackLocale: const Locale('en', 'US'),
        theme: ThemeData(
          appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF171d28)),
        ),
        home: const SplashScreen(),
      ),
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
