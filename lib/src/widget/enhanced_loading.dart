import 'package:flutter/material.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';

// Enhanced Loading Indicator with Multiple Styles
class EnhancedLoading extends StatefulWidget {
  final LoadingType type;
  final Color color;
  final double size;
  final Duration duration;
  final String? text;

  const EnhancedLoading({
    Key? key,
    this.type = LoadingType.pulse,
    this.color = TradingTheme.secondaryAccent,
    this.size = 50.0,
    this.duration = const Duration(milliseconds: 1200),
    this.text,
  }) : super(key: key);

  @override
  State<EnhancedLoading> createState() => _EnhancedLoadingState();
}

class _EnhancedLoadingState extends State<EnhancedLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    switch (widget.type) {
      case LoadingType.pulse:
        _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _controller.repeat(reverse: true);
        break;
      case LoadingType.rotate:
        _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.linear),
        );
        _controller.repeat();
        break;
      case LoadingType.bounce:
        _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
        );
        _controller.repeat(reverse: true);
        break;
      case LoadingType.wave:
        _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _controller.repeat();
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return _buildLoadingWidget();
            },
          ),
        ),
        if (widget.text != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.text!,
            style: TextStyle(
              color: widget.color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingWidget() {
    switch (widget.type) {
      case LoadingType.pulse:
        return Transform.scale(
          scale: 0.5 + (_animation.value * 0.5),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(0.8),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.3),
                  spreadRadius: _animation.value * 10,
                  blurRadius: _animation.value * 20,
                ),
              ],
            ),
          ),
        );

      case LoadingType.rotate:
        return Transform.rotate(
          angle: _animation.value * 2 * 3.14159,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  widget.color,
                  widget.color.withOpacity(0.1),
                  widget.color,
                ],
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0A0E17),
              ),
            ),
          ),
        );

      case LoadingType.bounce:
        return Transform.translate(
          offset: Offset(0, -_animation.value * 20),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, _animation.value * 10),
                ),
              ],
            ),
          ),
        );

      case LoadingType.wave:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_animation.value + delay) % 1.0;
            return Transform.scale(
              scale: 0.5 + (animationValue * 0.5),
              child: Container(
                width: widget.size / 4,
                height: widget.size / 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(0.8),
                ),
              ),
            );
          }),
        );

      default:
        return Container();
    }
  }
}

enum LoadingType {
  pulse,
  rotate,
  bounce,
  wave,
}

// Enhanced Shimmer Effect
class EnhancedShimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;
  final ShimmerDirection direction;

  const EnhancedShimmer({
    Key? key,
    required this.child,
    this.baseColor = const Color(0xFF2B3139),
    this.highlightColor = const Color(0xFF3A4149),
    this.duration = const Duration(milliseconds: 1500),
    this.direction = ShimmerDirection.leftToRight,
  }) : super(key: key);

  @override
  State<EnhancedShimmer> createState() => _EnhancedShimmerState();
}

class _EnhancedShimmerState extends State<EnhancedShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return _createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }

  Shader _createShader(Rect bounds) {
    final stops = [
      (_animation.value - 0.5).clamp(0.0, 1.0),
      _animation.value.clamp(0.0, 1.0),
      (_animation.value + 0.5).clamp(0.0, 1.0),
    ];

    switch (widget.direction) {
      case ShimmerDirection.leftToRight:
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            widget.baseColor,
            widget.highlightColor,
            widget.baseColor,
          ],
          stops: stops,
        ).createShader(bounds);
      case ShimmerDirection.rightToLeft:
        return LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            widget.baseColor,
            widget.highlightColor,
            widget.baseColor,
          ],
          stops: stops,
        ).createShader(bounds);
      case ShimmerDirection.topToBottom:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.baseColor,
            widget.highlightColor,
            widget.baseColor,
          ],
          stops: stops,
        ).createShader(bounds);
      case ShimmerDirection.bottomToTop:
        return LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            widget.baseColor,
            widget.highlightColor,
            widget.baseColor,
          ],
          stops: stops,
        ).createShader(bounds);
    }
  }
}

enum ShimmerDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
}

// Loading Overlay
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final LoadingType loadingType;
  final String? loadingText;
  final Color backgroundColor;
  final Color loadingColor;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.loadingType = LoadingType.pulse,
    this.loadingText,
    this.backgroundColor = const Color(0x80000000),
    this.loadingColor = TradingTheme.secondaryAccent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor,
            child: Center(
              child: EnhancedLoading(
                type: loadingType,
                color: loadingColor,
                text: loadingText,
              ),
            ),
          ),
      ],
    );
  }
}
