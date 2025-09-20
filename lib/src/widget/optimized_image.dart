import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:rapidtradeai/src/widget/lottie_loading_widget.dart';

/// OPTIMIZATION: Advanced Image Widget with Progressive Loading and Smart Caching
class OptimizedImage extends StatefulWidget {
  final String? imageUrl;
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableShimmer;
  final Color? shimmerBaseColor;
  final Color? shimmerHighlightColor;
  final Duration cacheDuration;
  final bool enableProgressiveLoading;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  const OptimizedImage({
    Key? key,
    this.imageUrl,
    this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableShimmer = true,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
    this.cacheDuration = const Duration(days: 7),
    this.enableProgressiveLoading = true,
    this.borderRadius = 0,
    this.boxShadow,
  }) : super(key: key);

  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = true;
  bool _hasError = false;
  ImageProvider? _imageProvider;
  
  // OPTIMIZATION: Image cache for better performance
  static final Map<String, Uint8List> _imageCache = {};
  static const int MAX_CACHE_SIZE = 50;

  @override
  void initState() {
    super.initState();
    
    // OPTIMIZATION: Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _loadImage();
  }

  @override
  void didUpdateWidget(OptimizedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // OPTIMIZATION: Reload image if URL or asset path changed
    if (oldWidget.imageUrl != widget.imageUrl || 
        oldWidget.assetPath != widget.assetPath) {
      _loadImage();
    }
  }

  /// OPTIMIZATION: Load image with smart caching and error handling
  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      if (widget.imageUrl != null) {
        await _loadNetworkImage();
      } else if (widget.assetPath != null) {
        await _loadAssetImage();
      }
      
      // OPTIMIZATION: Start fade-in animation
      _animationController.forward();
      
    } catch (e) {
      print("❌ Error loading image: $e");
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  /// OPTIMIZATION: Load network image with caching
  Future<void> _loadNetworkImage() async {
    final url = widget.imageUrl!;
    
    // OPTIMIZATION: Check cache first
    if (_imageCache.containsKey(url)) {
      _imageProvider = MemoryImage(_imageCache[url]!);
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    // OPTIMIZATION: Use CachedNetworkImage for better performance
    _imageProvider = CachedNetworkImageProvider(
      url,
      cacheKey: _generateCacheKey(url),
    );
    
    // OPTIMIZATION: Preload image to check if it loads successfully
    final imageStream = _imageProvider!.resolve(ImageConfiguration.empty);
    final completer = Completer<void>();
    
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        // OPTIMIZATION: Cache the image data
        _cacheImageData(url, info.image);
        
        setState(() {
          _isLoading = false;
        });
        
        imageStream.removeListener(listener);
        completer.complete();
      },
      onError: (exception, stackTrace) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        
        imageStream.removeListener(listener);
        completer.completeError(exception);
      },
    );
    
    imageStream.addListener(listener);
    await completer.future;
  }

  /// OPTIMIZATION: Load asset image with caching
  Future<void> _loadAssetImage() async {
    final assetPath = widget.assetPath!;
    
    // OPTIMIZATION: Check cache first
    if (_imageCache.containsKey(assetPath)) {
      _imageProvider = MemoryImage(_imageCache[assetPath]!);
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    try {
      // OPTIMIZATION: Load asset data
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      
      // OPTIMIZATION: Cache the asset data
      _cacheAssetData(assetPath, bytes);
      
      _imageProvider = MemoryImage(bytes);
      setState(() {
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      rethrow;
    }
  }

  /// OPTIMIZATION: Cache image data efficiently
  void _cacheImageData(String key, ui.Image image) async {
    try {
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final Uint8List bytes = byteData.buffer.asUint8List();
        _addToCache(key, bytes);
      }
    } catch (e) {
      print("⚠️ Failed to cache image data: $e");
    }
  }

  /// OPTIMIZATION: Cache asset data
  void _cacheAssetData(String key, Uint8List bytes) {
    _addToCache(key, bytes);
  }

  /// OPTIMIZATION: Add to cache with size management
  void _addToCache(String key, Uint8List bytes) {
    // OPTIMIZATION: Remove oldest entries if cache is full
    if (_imageCache.length >= MAX_CACHE_SIZE) {
      final firstKey = _imageCache.keys.first;
      _imageCache.remove(firstKey);
    }
    
    _imageCache[key] = bytes;
  }

  /// OPTIMIZATION: Generate cache key
  String _generateCacheKey(String url) {
    return '${url.hashCode}_${widget.width?.toInt() ?? 0}_${widget.height?.toInt() ?? 0}';
  }

  /// OPTIMIZATION: Build shimmer placeholder
  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: widget.shimmerBaseColor ?? const Color(0xFF1A2234),
      highlightColor: widget.shimmerHighlightColor ?? const Color(0xFF2A3A5A),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }

  /// OPTIMIZATION: Build error widget
  Widget _buildErrorWidget() {
    return widget.errorWidget ?? Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2234),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: const Color(0xFF2A3A5A),
          width: 1,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: Color(0xFF848E9C),
          size: 32,
        ),
      ),
    );
  }

  /// OPTIMIZATION: Build image widget with optimizations
  Widget _buildImageWidget() {
    if (_imageProvider == null) {
      return _buildShimmerPlaceholder();
    }

    Widget imageWidget;

    if (widget.imageUrl != null) {
      // OPTIMIZATION: Use CachedNetworkImage for network images
      imageWidget = CachedNetworkImage(
        imageUrl: widget.imageUrl!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheKey: _generateCacheKey(widget.imageUrl!),
        placeholder: (context, url) => widget.placeholder ?? _buildShimmerPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 100),
        memCacheWidth: widget.width?.toInt(),
        memCacheHeight: widget.height?.toInt(),
      );
    } else {
      // OPTIMIZATION: Use Image widget for assets and cached images
      imageWidget = Image(
        image: _imageProvider!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }

    // OPTIMIZATION: Wrap with fade animation
    return FadeTransition(
      opacity: _fadeAnimation,
      child: imageWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_hasError) {
      child = _buildErrorWidget();
    } else if (_isLoading && widget.enableShimmer) {
      child = _buildShimmerPlaceholder();
    } else {
      child = _buildImageWidget();
    }

    // OPTIMIZATION: Apply container decorations if needed
    if (widget.borderRadius > 0 || widget.boxShadow != null) {
      child = Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: widget.boxShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      );
    }

    return child;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

/// OPTIMIZATION: Specialized widget for crypto coin images
class CryptoCoinImage extends StatelessWidget {
  final String symbol;
  final double size;
  final bool showFallback;

  const CryptoCoinImage({
    Key? key,
    required this.symbol,
    this.size = 32,
    this.showFallback = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // OPTIMIZATION: Generate image URL based on symbol
    final imageUrl = _getCoinImageUrl(symbol);
    
    return OptimizedImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: size / 2, // Make it circular
      enableShimmer: true,
      shimmerBaseColor: const Color(0xFF1A2234),
      shimmerHighlightColor: const Color(0xFF2A3A5A),
      errorWidget: showFallback ? _buildFallbackWidget() : null,
    );
  }

  /// OPTIMIZATION: Get coin image URL from multiple sources
  String _getCoinImageUrl(String symbol) {
    final cleanSymbol = symbol.replaceAll('USDT', '').replaceAll('USD', '').toLowerCase();
    
    // OPTIMIZATION: Try multiple CDNs for better reliability
    return 'https://cryptoicons.org/api/icon/$cleanSymbol/200';
  }

  /// OPTIMIZATION: Build fallback widget for unknown coins
  Widget _buildFallbackWidget() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2234),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF2A3A5A),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          symbol.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// OPTIMIZATION: Progressive image loader for large images
class ProgressiveImageLoader extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ProgressiveImageLoader({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  State<ProgressiveImageLoader> createState() => _ProgressiveImageLoaderState();
}

class _ProgressiveImageLoaderState extends State<ProgressiveImageLoader> {
  double _loadingProgress = 0.0;
  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // OPTIMIZATION: Show loading progress
        if (!_isLoaded)
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2234),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LottieLoadingWidget.medium(),
                  const SizedBox(height: 8),
                  Text(
                    '${(_loadingProgress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // OPTIMIZATION: Progressive image loading
        CachedNetworkImage(
          imageUrl: widget.imageUrl,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          progressIndicatorBuilder: (context, url, progress) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _loadingProgress = progress.progress ?? 0.0;
                });
              }
            });
            return const SizedBox.shrink();
          },
          imageBuilder: (context, imageProvider) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _isLoaded = true;
                });
              }
            });
            
            return FadeInImage(
              placeholder: const AssetImage('assets/img/placeholder.png'),
              image: imageProvider,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              fadeInDuration: const Duration(milliseconds: 300),
            );
          },
        ),
      ],
    );
  }
}
