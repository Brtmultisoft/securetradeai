import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Web responsive utilities for RapidTradeAI
class ResponsiveUtils {
  // Breakpoints for different screen sizes
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;

  // Maximum content width for web - Reduced to minimize spacing
  static const double maxContentWidth = 1000; // Reduced from 1400
  static const double maxMobileWidth = 480;

  /// Check if current platform is web
  static bool get isWeb => kIsWeb;

  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else if (width < largeDesktopBreakpoint) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Check if device is desktop or larger
  static bool isDesktop(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.desktop || deviceType == DeviceType.largeDesktop;
  }

  /// Get responsive padding based on screen size - Reduced spacing for web
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(16); // Reduced from 24
    } else {
      return const EdgeInsets.all(16); // Reduced from 32
    }
  }

  /// Get responsive margin based on screen size - Reduced spacing for web
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(8);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(8); // Reduced from 16
    } else {
      return const EdgeInsets.all(10); // Reduced from 24
    }
  }

  /// Get responsive font size - Much bigger text for web
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return baseFontSize;
      case DeviceType.tablet:
        return baseFontSize * 1.4; // Increased from 1.2
      case DeviceType.desktop:
        return baseFontSize * 1.8; // Increased from 1.4 to 1.8
      case DeviceType.largeDesktop:
        return baseFontSize * 2.0; // Increased from 1.6 to 2.0
    }
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseIconSize) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return baseIconSize;
      case DeviceType.tablet:
        return baseIconSize * 1.2;
      case DeviceType.desktop:
        return baseIconSize * 1.4;
      case DeviceType.largeDesktop:
        return baseIconSize * 1.6;
    }
  }

  /// Get grid cross axis count based on screen size
  static int getGridCrossAxisCount(BuildContext context, {int? mobileCount, int? tabletCount, int? desktopCount}) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobileCount ?? 2;
      case DeviceType.tablet:
        return tabletCount ?? 3;
      case DeviceType.desktop:
        return desktopCount ?? 4;
      case DeviceType.largeDesktop:
        return (desktopCount ?? 4) + 1;
    }
  }

  /// Get responsive card width
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isMobile(context)) {
      return screenWidth - 32; // Full width with padding
    } else if (isTablet(context)) {
      return (screenWidth - 48) / 2; // Two cards per row
    } else {
      return (screenWidth - 64) / 3; // Three cards per row
    }
  }

  /// Get responsive dialog width
  static double getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isMobile(context)) {
      return screenWidth * 0.9;
    } else if (isTablet(context)) {
      return screenWidth * 0.7;
    } else {
      return screenWidth * 0.5;
    }
  }

  /// Get responsive table column widths
  static List<double> getTableColumnWidths(BuildContext context, int columnCount) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - getResponsivePadding(context).horizontal;
    
    if (isMobile(context)) {
      // Mobile: Compact columns
      return List.generate(columnCount, (index) => availableWidth / columnCount);
    } else {
      // Desktop/Tablet: More spacious columns
      final baseWidth = availableWidth / columnCount;
      return List.generate(columnCount, (index) => baseWidth);
    }
  }

  /// Get responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    if (isMobile(context)) {
      return kToolbarHeight;
    } else {
      return kToolbarHeight + 8; // Slightly taller for desktop
    }
  }

  /// Get responsive bottom navigation height
  static double getBottomNavHeight(BuildContext context) {
    if (isMobile(context)) {
      return kBottomNavigationBarHeight;
    } else {
      return kBottomNavigationBarHeight + 8;
    }
  }

  /// Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context, double baseBorderRadius) {
    if (isMobile(context)) {
      return baseBorderRadius;
    } else if (isTablet(context)) {
      return baseBorderRadius * 1.2;
    } else {
      return baseBorderRadius * 1.5;
    }
  }

  /// Get responsive elevation
  static double getResponsiveElevation(BuildContext context, double baseElevation) {
    if (isMobile(context)) {
      return baseElevation;
    } else {
      return baseElevation * 1.5; // More elevation for desktop
    }
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return baseSpacing;
      case DeviceType.tablet:
        return baseSpacing * 1.2;
      case DeviceType.desktop:
        return baseSpacing * 1.5;
      case DeviceType.largeDesktop:
        return baseSpacing * 1.8;
    }
  }

  /// Center content with max width for web
  static Widget centerContent(BuildContext context, Widget child, {double? maxWidth}) {
    if (!isWeb || isMobile(context)) {
      return child;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? maxContentWidth,
        ),
        child: child,
      ),
    );
  }

  /// Responsive container with proper constraints
  static Widget responsiveContainer({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? (isDesktop(context) ? maxContentWidth : double.infinity),
      ),
      padding: padding ?? getResponsivePadding(context),
      margin: margin ?? getResponsiveMargin(context),
      child: child,
    );
  }
}

/// Device type enumeration
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Responsive widget builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    return builder(context, deviceType);
  }
}

/// Responsive layout widget
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}
