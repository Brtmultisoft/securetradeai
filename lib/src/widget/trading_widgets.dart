import 'package:flutter/material.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/widget/lottie_loading_widget.dart';

// Animated Trading Card Widget
class AnimatedTradingCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isSelected;
  final bool showBorder;

  const AnimatedTradingCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.isSelected = false,
    this.showBorder = true,
  }) : super(key: key);

  @override
  State<AnimatedTradingCard> createState() => _AnimatedTradingCardState();
}

class _AnimatedTradingCardState extends State<AnimatedTradingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TradingAnimations.normalAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
          parent: _controller, curve: TradingAnimations.defaultCurve),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
          parent: _controller, curve: TradingAnimations.defaultCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTapDown: (_) => _controller.forward(),
              onTapUp: (_) {
                _controller.reverse();
                if (widget.onTap != null) {
                  Future.delayed(TradingAnimations.fastAnimation, () {
                    widget.onTap!();
                  });
                }
              },
              onTapCancel: () => _controller.reverse(),
              child: Container(
                margin: widget.margin ?? const EdgeInsets.all(8),
                padding: widget.padding ?? const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: TradingTheme.cardGradient,
                  borderRadius: BorderRadius.circular(12),
                  border: widget.showBorder
                      ? Border.all(
                          color: widget.isSelected
                              ? TradingTheme.primaryAccent
                              : TradingTheme.primaryBorder,
                          width: widget.isSelected ? 2 : 1,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Animated Price Display Widget
class AnimatedPriceDisplay extends StatefulWidget {
  final String price;
  final String? previousPrice;
  final TextStyle? textStyle;
  final bool showAnimation;

  const AnimatedPriceDisplay({
    Key? key,
    required this.price,
    this.previousPrice,
    this.textStyle,
    this.showAnimation = true,
  }) : super(key: key);

  @override
  State<AnimatedPriceDisplay> createState() => _AnimatedPriceDisplayState();
}

class _AnimatedPriceDisplayState extends State<AnimatedPriceDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  Color _currentColor = TradingTheme.primaryText;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TradingAnimations.priceUpdateAnimation,
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: TradingTheme.primaryText,
      end: TradingTheme.primaryText,
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(AnimatedPriceDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAnimation &&
        widget.previousPrice != null &&
        widget.price != widget.previousPrice) {
      _animatePriceChange();
    }
  }

  void _animatePriceChange() {
    if (widget.previousPrice == null) return;

    final currentPrice = double.tryParse(widget.price) ?? 0;
    final previousPrice = double.tryParse(widget.previousPrice!) ?? 0;

    if (currentPrice > previousPrice) {
      _currentColor = TradingTheme.successColor;
    } else if (currentPrice < previousPrice) {
      _currentColor = TradingTheme.errorColor;
    }

    _colorAnimation = ColorTween(
      begin: _currentColor,
      end: TradingTheme.primaryText,
    ).animate(_controller);

    _controller.forward().then((_) {
      _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Text(
          widget.price,
          style: (widget.textStyle ?? TradingTypography.priceText).copyWith(
            color: _colorAnimation.value,
          ),
        );
      },
    );
  }
}

// Trading Button Widget
class TradingButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;

  const TradingButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<TradingButton> createState() => _TradingButtonState();
}

class _TradingButtonState extends State<TradingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TradingAnimations.fastAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
          parent: _controller, curve: TradingAnimations.defaultCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: widget.width,
            height: widget.height ?? 48,
            child: ElevatedButton(
              onPressed: widget.isEnabled && !widget.isLoading
                  ? () {
                      _controller.forward().then((_) {
                        _controller.reverse();
                        if (widget.onPressed != null) {
                          widget.onPressed!();
                        }
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    widget.backgroundColor ?? TradingTheme.primaryAccent,
                foregroundColor: widget.textColor ?? Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: TradingTheme.hintText,
              ),
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: const LottieLoadingWidget.small(),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            widget.text,
                            style: TradingTypography.bodyMedium.copyWith(
                              color: widget.textColor ?? Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

// Animated Loading Indicator
class TradingLoadingIndicator extends StatefulWidget {
  final String? message;
  final Color? color;

  const TradingLoadingIndicator({
    Key? key,
    this.message,
    this.color,
  }) : super(key: key);

  @override
  State<TradingLoadingIndicator> createState() =>
      _TradingLoadingIndicatorState();
}

class _TradingLoadingIndicatorState extends State<TradingLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_rotationController, _pulseAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Transform.rotate(
                angle: _rotationController.value * 2 * 3.14159,
                child: const LottieLoadingWidget.medium(),
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: TradingTypography.bodyMedium.copyWith(
              color: TradingTheme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// Trading Pair Selector Widget
class TradingPairSelector extends StatelessWidget {
  final String selectedPair;
  final List<String> availablePairs;
  final Function(String) onPairSelected;
  final bool isLoading;

  const TradingPairSelector({
    Key? key,
    required this.selectedPair,
    required this.availablePairs,
    required this.onPairSelected,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedTradingCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.currency_exchange,
            color: TradingTheme.primaryAccent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trading Pair',
                  style: TradingTypography.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  selectedPair,
                  style: TradingTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: const LottieLoadingWidget.small(),
            )
          else
            Icon(
              Icons.keyboard_arrow_down,
              color: TradingTheme.secondaryText,
            ),
        ],
      ),
    );
  }
}

// Trading Stats Widget
class TradingStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? valueColor;
  final bool showTrend;
  final bool isPositiveTrend;

  const TradingStatsCard({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.valueColor,
    this.showTrend = false,
    this.isPositiveTrend = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedTradingCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: TradingTheme.primaryAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TradingTypography.bodySmall,
                ),
              ),
              if (showTrend)
                Icon(
                  isPositiveTrend ? Icons.trending_up : Icons.trending_down,
                  color: isPositiveTrend
                      ? TradingTheme.successColor
                      : TradingTheme.errorColor,
                  size: 16,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TradingTypography.heading3.copyWith(
              color: valueColor ?? TradingTheme.primaryText,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TradingTypography.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

// Trading Toggle Switch
class TradingToggleSwitch extends StatefulWidget {
  final bool value;
  final Function(bool) onChanged;
  final String? label;
  final bool isEnabled;

  const TradingToggleSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.label,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<TradingToggleSwitch> createState() => _TradingToggleSwitchState();
}

class _TradingToggleSwitchState extends State<TradingToggleSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TradingAnimations.normalAnimation,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: TradingAnimations.defaultCurve,
    );

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TradingToggleSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isEnabled ? () => widget.onChanged(!widget.value) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: TradingTypography.bodyMedium.copyWith(
                color: widget.isEnabled
                    ? TradingTheme.primaryText
                    : TradingTheme.hintText,
              ),
            ),
            const SizedBox(width: 12),
          ],
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: 50,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Color.lerp(
                    TradingTheme.hintText,
                    TradingTheme.primaryAccent,
                    _animation.value,
                  ),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: TradingAnimations.normalAnimation,
                      curve: TradingAnimations.defaultCurve,
                      left: widget.value ? 22 : 2,
                      top: 2,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
