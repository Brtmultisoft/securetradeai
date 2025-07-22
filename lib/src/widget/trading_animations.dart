import 'package:flutter/material.dart';
import 'package:securetradeai/src/Service/assets_service.dart';

// Slide In Animation Widget
class SlideInAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Offset beginOffset;
  final Duration duration;

  const SlideInAnimation({
    Key? key,
    required this.child,
    this.delay = Duration.zero,
    this.beginOffset = const Offset(0, 0.3),
    this.duration = const Duration(milliseconds: 600),
  }) : super(key: key);

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: TradingAnimations.slideCurve,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: TradingAnimations.defaultCurve,
    ));

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
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
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

// Scale In Animation Widget
class ScaleInAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double beginScale;
  final Duration duration;

  const ScaleInAnimation({
    Key? key,
    required this.child,
    this.delay = Duration.zero,
    this.beginScale = 0.0,
    this.duration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  State<ScaleInAnimation> createState() => _ScaleInAnimationState();
}

class _ScaleInAnimationState extends State<ScaleInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: TradingAnimations.bounceCurve,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: TradingAnimations.defaultCurve,
    ));

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
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
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

// Staggered List Animation
class StaggeredListAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDelay;
  final Axis direction;

  const StaggeredListAnimation({
    Key? key,
    required this.children,
    this.itemDelay = const Duration(milliseconds: 100),
    this.direction = Axis.vertical,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return SlideInAnimation(
          delay: Duration(milliseconds: index * itemDelay.inMilliseconds),
          beginOffset: direction == Axis.vertical 
              ? const Offset(0, 0.3) 
              : const Offset(0.3, 0),
          child: child,
        );
      }).toList(),
    );
  }
}

// Pulse Animation Widget
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final bool repeat;

  const PulseAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(seconds: 1),
    this.minScale = 0.95,
    this.maxScale = 1.05,
    this.repeat = true,
  }) : super(key: key);

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
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
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

// Shimmer Loading Animation
class TradingShimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const TradingShimmer({
    Key? key,
    required this.child,
    this.baseColor = const Color(0xFF2B3139),
    this.highlightColor = const Color(0xFF3A4149),
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<TradingShimmer> createState() => _TradingShimmerState();
}

class _TradingShimmerState extends State<TradingShimmer>
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
      begin: -1.0,
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
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

// Floating Action Animation
class FloatingActionAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const FloatingActionAnimation({
    Key? key,
    required this.child,
    this.onTap,
  }) : super(key: key);

  @override
  State<FloatingActionAnimation> createState() => _FloatingActionAnimationState();
}

class _FloatingActionAnimationState extends State<FloatingActionAnimation>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _tapController;
  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _tapController = AnimationController(
      duration: TradingAnimations.fastAnimation,
      vsync: this,
    );

    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: TradingAnimations.defaultCurve,
    ));
  }

  @override
  void dispose() {
    _floatController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_floatAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: (_) => _tapController.forward(),
              onTapUp: (_) {
                _tapController.reverse();
                if (widget.onTap != null) {
                  Future.delayed(TradingAnimations.fastAnimation, () {
                    widget.onTap!();
                  });
                }
              },
              onTapCancel: () => _tapController.reverse(),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
