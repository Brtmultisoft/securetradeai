import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static bool isWeb(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 20);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
  }

  // Get responsive margin
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    }
  }

  // Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    if (isDesktop(context)) {
      return baseFontSize * 1.1;
    } else if (isTablet(context)) {
      return baseFontSize * 1.05;
    } else {
      return baseFontSize;
    }
  }

  // Get responsive grid count
  static int getGridCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 2;
    }
  }

  // Get responsive card width
  static double getCardWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (isDesktop(context)) {
      return (screenWidth - 120) / 4; // 4 cards per row with margins
    } else if (isTablet(context)) {
      return (screenWidth - 80) / 3; // 3 cards per row with margins
    } else {
      return (screenWidth - 60) / 2; // 2 cards per row with margins
    }
  }

  // Get responsive container constraints
  static BoxConstraints getResponsiveConstraints(BuildContext context) {
    if (isDesktop(context)) {
      return const BoxConstraints(maxWidth: 1200);
    } else if (isTablet(context)) {
      return const BoxConstraints(maxWidth: 800);
    } else {
      return const BoxConstraints(maxWidth: double.infinity);
    }
  }

  // Get responsive carousel height
  static double getCarouselHeight(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    if (isDesktop(context)) {
      return screenHeight * 0.3;
    } else if (isTablet(context)) {
      return screenHeight * 0.35;
    } else {
      return screenHeight * 0.25;
    }
  }

  // Get responsive bottom navigation height
  static double getBottomNavHeight(BuildContext context) {
    if (isWeb(context)) {
      return 70;
    } else {
      return 60;
    }
  }

  // Get responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    if (isWeb(context)) {
      return 70;
    } else {
      return 56;
    }
  }
}

// Responsive wrapper widget
class ResponsiveWrapper extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWrapper({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (ResponsiveUtils.isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

// Responsive container with max width
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: ResponsiveUtils.getResponsiveConstraints(context),
      padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
      margin: margin ?? ResponsiveUtils.getResponsiveMargin(context),
      child: child,
    );
  }
}