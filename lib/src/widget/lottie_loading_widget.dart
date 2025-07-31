import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// A reusable Lottie loading widget that replaces CircularProgressIndicator
/// throughout the application for consistent loading animations.
class LottieLoadingWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final String? message;
  final Color? messageColor;
  final double? messageSize;
  final bool showMessage;
  final EdgeInsets? padding;
  final BoxFit fit;

  const LottieLoadingWidget({
    Key? key,
    this.width,
    this.height,
    this.message,
    this.messageColor,
    this.messageSize,
    this.showMessage = false,
    this.padding,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  /// Small loading indicator (replaces small CircularProgressIndicator)
  const LottieLoadingWidget.small({
    Key? key,
    this.message,
    this.messageColor,
    this.messageSize,
    this.showMessage = false,
    this.padding,
    this.fit = BoxFit.contain,
  })  : width = 24,
        height = 24,
        super(key: key);

  /// Medium loading indicator (default size)
  const LottieLoadingWidget.medium({
    Key? key,
    this.message,
    this.messageColor,
    this.messageSize,
    this.showMessage = false,
    this.padding,
    this.fit = BoxFit.contain,
  })  : width = 48,
        height = 48,
        super(key: key);

  /// Large loading indicator (for full screen loading)
  const LottieLoadingWidget.large({
    Key? key,
    this.message,
    this.messageColor,
    this.messageSize,
    this.showMessage = true,
    this.padding,
    this.fit = BoxFit.contain,
  })  : width = 80,
        height = 80,
        super(key: key);

  /// Full screen loading with message
  const LottieLoadingWidget.fullScreen({
    Key? key,
    this.message = 'Loading...',
    this.messageColor,
    this.messageSize = 16,
    this.padding,
    this.fit = BoxFit.contain,
  })  : width = 100,
        height = 100,
        showMessage = true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget lottieWidget = Lottie.asset(
      'assets/lotties/loading_indicator.json',
      width: width,
      height: height,
      fit: fit,
      repeat: true,
      animate: true,
    );

    if (padding != null) {
      lottieWidget = Padding(
        padding: padding!,
        child: lottieWidget,
      );
    }

    if (!showMessage || message == null) {
      return lottieWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        lottieWidget,
        const SizedBox(height: 16),
        Text(
          message!,
          style: TextStyle(
            color: messageColor ?? Colors.white,
            fontSize: messageSize ?? 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// A centered Lottie loading widget for full screen loading states
class CenteredLottieLoading extends StatelessWidget {
  final String? message;
  final Color? messageColor;
  final double? messageSize;
  final double? width;
  final double? height;
  final Color? backgroundColor;

  const CenteredLottieLoading({
    Key? key,
    this.message,
    this.messageColor,
    this.messageSize,
    this.width,
    this.height,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = LottieLoadingWidget(
      width: width ?? 80,
      height: height ?? 80,
      message: message,
      messageColor: messageColor,
      messageSize: messageSize,
      showMessage: message != null,
    );

    if (backgroundColor != null) {
      content = Container(
        color: backgroundColor,
        child: Center(child: content),
      );
    } else {
      content = Center(child: content);
    }

    return content;
  }
}

/// Extension methods for easy replacement of CircularProgressIndicator
extension LottieLoadingExtensions on Widget {
  /// Wraps the widget with a loading overlay using Lottie animation
  Widget withLottieLoading({
    required bool isLoading,
    String? loadingMessage,
    Color? messageColor,
    Color? overlayColor,
  }) {
    return Stack(
      children: [
        this,
        if (isLoading)
          Container(
            color: overlayColor ?? Colors.black.withOpacity(0.3),
            child: CenteredLottieLoading(
              message: loadingMessage,
              messageColor: messageColor,
            ),
          ),
      ],
    );
  }
}
