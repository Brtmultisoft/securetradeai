import 'package:flutter/material.dart';
import 'package:securetradeai/src/Service/assets_service.dart';

// Enhanced Page Route with Custom Transitions
class AnimatedPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final PageTransitionType transitionType;
  final Duration duration;
  final Curve curve;

  AnimatedPageRoute({
    required this.child,
    this.transitionType = PageTransitionType.slideFromRight,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          settings: settings,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(
              child,
              animation,
              secondaryAnimation,
              transitionType,
              curve,
            );
          },
        );

  static Widget _buildTransition(
    Widget child,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    PageTransitionType type,
    Curve curve,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );

    switch (type) {
      case PageTransitionType.slideFromRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slideFromLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slideFromBottom:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slideFromTop:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.fade:
        return FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );

      case PageTransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.fadeScale:
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );

      case PageTransitionType.slideScale:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.3, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );

      case PageTransitionType.rotation:
        return RotationTransition(
          turns: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.size:
        return Align(
          alignment: Alignment.center,
          child: SizeTransition(
            sizeFactor: curvedAnimation,
            child: child,
          ),
        );

      default:
        return child;
    }
  }
}

// Page Transition Types
enum PageTransitionType {
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  slideFromTop,
  fade,
  scale,
  fadeScale,
  slideScale,
  rotation,
  size,
}

// Enhanced Navigation Helper
class AnimatedNavigator {
  // Navigate with slide from right (default)
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    Widget page, {
    PageTransitionType transition = PageTransitionType.slideFromRight,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeInOut,
  }) {
    return Navigator.push<T>(
      context,
      AnimatedPageRoute<T>(
        child: page,
        transitionType: transition,
        duration: duration,
        curve: curve,
      ),
    );
  }

  // Navigate with fade transition
  static Future<T?> pushFade<T extends Object?>(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return push<T>(
      context,
      page,
      transition: PageTransitionType.fade,
      duration: duration,
    );
  }

  // Navigate with scale transition
  static Future<T?> pushScale<T extends Object?>(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return push<T>(
      context,
      page,
      transition: PageTransitionType.scale,
      duration: duration,
      curve: Curves.elasticOut,
    );
  }

  // Navigate with slide from bottom
  static Future<T?> pushFromBottom<T extends Object?>(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return push<T>(
      context,
      page,
      transition: PageTransitionType.slideFromBottom,
      duration: duration,
      curve: Curves.easeOutCubic,
    );
  }

  // Navigate with fade and scale combination
  static Future<T?> pushFadeScale<T extends Object?>(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return push<T>(
      context,
      page,
      transition: PageTransitionType.fadeScale,
      duration: duration,
      curve: Curves.easeOutCubic,
    );
  }

  // Replace current page with animation
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget page, {
    PageTransitionType transition = PageTransitionType.slideFromRight,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeInOut,
    TO? result,
  }) {
    return Navigator.pushReplacement<T, TO>(
      context,
      AnimatedPageRoute<T>(
        child: page,
        transitionType: transition,
        duration: duration,
        curve: curve,
      ),
      result: result,
    );
  }

  // Push and remove all previous routes
  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    BuildContext context,
    Widget page,
    RoutePredicate predicate, {
    PageTransitionType transition = PageTransitionType.slideFromRight,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeInOut,
  }) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      AnimatedPageRoute<T>(
        child: page,
        transitionType: transition,
        duration: duration,
        curve: curve,
      ),
      predicate,
    );
  }
}

// Hero Animation Helper
class AnimatedHero extends StatelessWidget {
  final String tag;
  final Widget child;
  final Duration duration;

  const AnimatedHero({
    Key? key,
    required this.tag,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      transitionOnUserGestures: true,
      child: child,
    );
  }
}
