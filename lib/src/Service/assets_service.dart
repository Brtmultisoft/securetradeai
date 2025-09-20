import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

const String logo = "assets/img/logo.png";
bool checkBalance = false;
Color bg = const Color.fromARGB(255, 248, 249, 250);
Color bg2 = const Color(0xFF1E88E5);
Color appBar = const Color(0xFF2196F3);
const String img1 = "assets/img/1.jpeg";
const String img2 = "assets/img/2.jpg";
const String img3 = "assets/img/3.jpg";
const String fontFamily = "Nunito";
const Color primaryColor = Color(0xFF2196F3);
const Color rapidtradeaicolor = Color(0xFF03DAC6);
const Color backgroundColor = Colors.grey;
final Color shimmer_base = Colors.grey.shade50;
final Color shimmer_highlighted = Colors.blueGrey.shade50;

/// Trading Theme Colors - Modern Light Blue Theme for Rapid Trade AI
class TradingTheme {
  /// Background Colors
  static const Color primaryBackground = Color(0xFF1976D2);
  static const Color secondaryBackground = Color(0xFF2196F3);
  static Color cardBackground = const Color(0xFF2B3139);
  static const Color surfaceBackground = Color(0xFF42A5F5);
static const Color  backgroundColor =   Color(0xFF0C0E12);

  /// Accent Colors
  static const Color primaryAccent = Color(0xFF2196F3); // Light Blue
  static const Color secondaryAccent = Color(0xFF03DAC6); // Bright Cyan
  static const Color successColor = Color(0xFF00B894); // Modern Green
  static const Color errorColor = Color(0xFFE17055); // Modern Red
  static const Color warningColor = Color(0xFFFFB347); // Modern Orange

  /// Text Colors
  static const Color primaryText = Color(0xFFFFFFFF); // White text
  static const Color secondaryText =
  Color(0xFFE3F2FD); // Light blue tinted white
  static const Color hintText = Color(0xFFBBDEFB); // Lighter blue for hints

  /// Border Colors
  static const Color primaryBorder = Color(0xFF64B5F6);
  static const Color secondaryBorder = Color(0xFF90CAF9);

  /// Gradient Colors
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E88E5), Color(0xFF2196F3)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
  );
  static const LinearGradient secondaryAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF03DAC6), Color(0xFF00B894)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF03DAC6), Color(0xFF00B894)],
  );

  /// Trading Specific Colors
  static const Color buyColor = Color(0xFF00B894);
  static const Color sellColor = Color(0xFFE17055);
  static const Color neutralColor = Color(0xFFE3F2FD);

  /// Chart Colors
  static const Color bullishCandle = Color(0xFF00B894);
  static const Color bearishCandle = Color(0xFFE17055);
  static const Color volumeBar = Color(0xFF6B7280);
}

// Future Trading Theme Colors - Keep Original Yellow/Gold Theme for Future Trading
class FutureTradingTheme {
  /// Background Colors
  static const Color primaryBackground = Color(0xFF0F0F23);
  static const Color secondaryBackground = Color(0xFF16213E);
  static const Color cardBackground = Color(0xFF1A1B2E);
  static const Color surfaceBackground = Color(0xFF2D3561);

  // Accent Colors
  static const Color primaryAccent = TradingTheme.secondaryAccent; // Binance Yellow
  static const Color secondaryAccent = Color(0xFF00CEC9); // Bright Cyan
  static const Color successColor = Color(0xFF00B894); // Modern Green
  static const Color errorColor = Color(0xFFE17055); // Modern Red
  static const Color warningColor = Color(0xFFFFB347); // Modern Orange

  // Text Colors
  static const Color primaryText = Color(0xFFDDD6FE);
  static const Color secondaryText = Color(0xFFA5B3F7);
  static const Color hintText = Color(0xFF6B7280);

  // Border Colors
  static const Color primaryBorder = Color(0xFF374151);
  static const Color secondaryBorder = Color(0xFF4B5563);

  // Gradient Colors
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1B2E), Color(0xFF16213E)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [TradingTheme.secondaryAccent, Color(0xFFE6A500)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00CEC9), Color(0xFF00B894)],
  );

  // Trading Specific Colors
  static const Color buyColor = Color(0xFF00B894);
  static const Color sellColor = Color(0xFFE17055);
  static const Color neutralColor = Color(0xFFA5B3F7);

  // Chart Colors
  static const Color bullishCandle = Color(0xFF00B894);
  static const Color bearishCandle = Color(0xFFE17055);
  static const Color volumeBar = Color(0xFF6B7280);
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

// Trading Typography - Original (for const compatibility)
class TradingTypography {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: TradingTheme.secondaryAccent,
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

// Responsive Trading Typography - Web Optimized
class ResponsiveTradingTypography {
  static TextStyle get heading1 => TextStyle(
    fontSize: kIsWeb ? 36 : 24, // 50% bigger for web
    fontWeight: FontWeight.bold,
    color: TradingTheme.secondaryAccent,
    fontFamily: fontFamily,
  );

  static TextStyle get heading2 => TextStyle(
    fontSize: kIsWeb ? 28 : 20, // 40% bigger for web
    fontWeight: FontWeight.w600,
    color: TradingTheme.primaryText,
    fontFamily: fontFamily,
  );

  static TextStyle get heading3 => TextStyle(
    fontSize: kIsWeb ? 24 : 18, // 33% bigger for web
    fontWeight: FontWeight.w500,
    color: TradingTheme.primaryText,
    fontFamily: fontFamily,
  );

  static TextStyle get bodyLarge => TextStyle(
    fontSize: kIsWeb ? 20 : 16, // 25% bigger for web
    fontWeight: FontWeight.normal,
    color: TradingTheme.primaryText,
    fontFamily: fontFamily,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontSize: kIsWeb ? 18 : 14, // 29% bigger for web
    fontWeight: FontWeight.normal,
    color: TradingTheme.primaryText,
    fontFamily: fontFamily,
  );

  static TextStyle get bodySmall => TextStyle(
    fontSize: kIsWeb ? 16 : 12, // 33% bigger for web
    fontWeight: FontWeight.normal,
    color: TradingTheme.secondaryText,
    fontFamily: fontFamily,
  );

  static TextStyle get priceText => TextStyle(
    fontSize: kIsWeb ? 24 : 18, // 33% bigger for web
    fontWeight: FontWeight.bold,
    color: TradingTheme.primaryText,
    fontFamily: fontFamily,
  );

  static TextStyle get priceChangePositive => TextStyle(
    fontSize: kIsWeb ? 18 : 14, // 29% bigger for web
    fontWeight: FontWeight.w500,
    color: TradingTheme.successColor,
    fontFamily: fontFamily,
  );

  static TextStyle get priceChangeNegative => TextStyle(
    fontSize: kIsWeb ? 18 : 14, // 29% bigger for web
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
  static bool? isWeb;
  static bool? isMobile;
  static bool? isTablet;
  static bool? isDesktop;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    width = _mediaQueryData!.size.width;
    height = _mediaQueryData!.size.height;

    // Determine device type
    isWeb = kIsWeb;
    isMobile = width! < 600;
    isTablet = width! >= 600 && width! < 900;
    isDesktop = width! >= 900;

    // Responsive font sizing - Much bigger fonts for web
    if (isMobile!) {
      titleSize = width! * 0.08;
      fontSize = width! * 0.04;
      mFontSize = width! * 0.06;
    } else if (isTablet!) {
      titleSize = width! * 0.08; // Increased from 0.06
      fontSize = width! * 0.05; // Increased from 0.04
      mFontSize = width! * 0.07; // Increased from 0.055
    } else {
      // Desktop - Much bigger fonts for web
      titleSize = width! * 0.08; // Increased from 0.05
      fontSize = width! * 0.05; // Increased from 0.035
      mFontSize = width! * 0.06; // Increased from 0.045
    }

    // Ensure minimum font sizes for readability - Much higher minimums for web
    if (isWeb!) {
      titleSize = titleSize! < 28 ? 28 : titleSize; // Increased from 20
      fontSize = fontSize! < 20 ? 20 : fontSize; // Increased from 16
      mFontSize = mFontSize! < 24 ? 24 : mFontSize; // Increased from 18
    } else {
      titleSize = titleSize! < 16 ? 16 : titleSize;
      fontSize = fontSize! < 12 ? 12 : fontSize;
      mFontSize = mFontSize! < 14 ? 14 : mFontSize;
    }
  }

  // Helper methods for responsive design
  static double getResponsiveWidth(double percentage) {
    return (width ?? 0) * percentage;
  }

  static double getResponsiveHeight(double percentage) {
    return (height ?? 0) * percentage;
  }

  static EdgeInsets getResponsivePadding() {
    if (isMobile ?? true) {
      return const EdgeInsets.all(16);
    } else if (isTablet ?? false) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  static EdgeInsets getResponsiveMargin() {
    if (isMobile ?? true) {
      return const EdgeInsets.all(8);
    } else if (isTablet ?? false) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  static double getResponsiveBorderRadius() {
    if (isMobile ?? true) {
      return 8.0;
    } else if (isTablet ?? false) {
      return 12.0;
    } else {
      return 16.0;
    }
  }

  static int getGridCrossAxisCount({int? mobile, int? tablet, int? desktop}) {
    if (isMobile ?? true) {
      return mobile ?? 2;
    } else if (isTablet ?? false) {
      return tablet ?? 3;
    } else {
      return desktop ?? 4;
    }
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
