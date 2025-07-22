import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

const String logo = "assets/img/logo.png";
bool checkBalance = false;
Color bg = const Color.fromARGB(255, 248, 249, 250);
Color bg2 = const Color(0xFF1A2234);
Color appBar = const Color(0xFF161A1E);
const String img1 = "assets/img/1.jpeg";
const String img2 = "assets/img/2.jpg";
const String img3 = "assets/img/3.jpg";
const String fontFamily = "Nunito";
final Color primaryColor = const Color(0xFF45C2DA);
final Color securetradeaicolor = const Color.fromARGB(255, 58, 184, 166);
final Color backgroundColor = Colors.grey;
final Color shimmer_base = Colors.grey.shade50;
final Color shimmer_highlighted = Colors.blueGrey.shade50;

// Trading Theme Colors - Consistent across Spot and Future Trading
class TradingTheme {
  // Background Colors
  static const Color primaryBackground = Color(0xFF0C0E12);
  static const Color secondaryBackground = Color(0xFF161A1E);
  static const Color cardBackground = Color(0xFF1E2026);
  static const Color surfaceBackground = Color(0xFF2B3139);

  // Accent Colors
  static const Color primaryAccent = Color(0xFFF0B90B); // Binance Yellow
  static const Color secondaryAccent = Color(0xFF4A90E2); // Blue
  static const Color successColor = Color(0xFF0ECB81); // Green
  static const Color errorColor = Color(0xFFEA4335); // Red
  static const Color warningColor = Color(0xFFFF9800); // Orange

  // Text Colors
  static const Color primaryText = Color(0xFFEAECEF);
  static const Color secondaryText = Color(0xFF848E9C);
  static const Color hintText = Color(0xFF474D57);

  // Border Colors
  static const Color primaryBorder = Color(0xFF2A3A5A);
  static const Color secondaryBorder = Color(0xFF474D57);

  // Gradient Colors
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E2026), Color(0xFF12151C)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF0B90B), Color(0xFFE6A500)],
  );

  // Trading Specific Colors
  static const Color buyColor = Color(0xFF0ECB81);
  static const Color sellColor = Color(0xFFEA4335);
  static const Color neutralColor = Color(0xFF848E9C);

  // Chart Colors
  static const Color bullishCandle = Color(0xFF0ECB81);
  static const Color bearishCandle = Color(0xFFEA4335);
  static const Color volumeBar = Color(0xFF474D57);
}

// Animation Constants
class TradingAnimations {
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration priceUpdateAnimation = Duration(milliseconds: 150);

  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve slideCurve = Curves.easeOutCubic;
}

// Trading Typography
class TradingTypography {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: TradingTheme.primaryText,
    fontFamily: fontFamily,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: TradingTheme.primaryText,
    fontFamily: fontFamily,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: TradingTheme.primaryText,
    fontFamily: fontFamily,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: TradingTheme.primaryText,
    fontFamily: fontFamily,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: TradingTheme.primaryText,
    fontFamily: fontFamily,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: TradingTheme.secondaryText,
    fontFamily: fontFamily,
  );

  static const TextStyle priceText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: TradingTheme.primaryText,
    fontFamily: fontFamily,
  );

  static const TextStyle priceChangePositive = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: TradingTheme.successColor,
    fontFamily: fontFamily,
  );

  static const TextStyle priceChangeNegative = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: TradingTheme.errorColor,
    fontFamily: fontFamily,
  );
}

// color class

// size class

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? width;
  static double? height;
  static double? titleSize;
  static double? fontSize;
  static double? mFontSize;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    width = _mediaQueryData!.size.width;
    height = _mediaQueryData!.size.height;
    titleSize = _mediaQueryData!.size.width * 0.08;
    fontSize = _mediaQueryData!.size.width * 0.04;
    mFontSize = _mediaQueryData!.size.width * 0.06;
  }
}

showtoast(String text, BuildContext context) {
  ToastContext().init(context); // Required to initialize Toast

  Toast.show(
    text,
    textStyle: const TextStyle(
      color: Colors.black,
      fontSize: 14,
    ),
    webTexColor: Colors.black,
    backgroundColor: const Color.fromRGBO(239, 239, 239, .9),
    border: const Border(
      top: BorderSide(color: Color.fromRGBO(203, 209, 209, 1)),
      bottom: BorderSide(color: Color.fromRGBO(203, 209, 209, 1)),
      right: BorderSide(color: Color.fromRGBO(203, 209, 209, 1)),
      left: BorderSide(color: Color.fromRGBO(203, 209, 209, 1)),
    ),
    backgroundRadius: 6,
  );
}

showLoading(context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => Center(
      child: Container(
        width: 60.0,
        height: 60.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: const Padding(
          padding: EdgeInsets.all(12.0),
          child: CupertinoActivityIndicator(),
        ),
      ),
    ),
  );
}

// language
String lang = '';

class GetColor {
  getcolor() {
    // if (bg == Colors.black) {
    //  bg =  Colors.white;
    // } else {
    //   print("not ok");
    // }
  }
}
