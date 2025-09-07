import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Service/web_proxy_service.dart';

/// Custom image widget that handles CORS issues for web
class CorsImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final AlignmentGeometry alignment;

  const CorsImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For web, use custom CORS handling
    if (kIsWeb) {
      return _buildWebImage();
    }
    
    // For mobile, use cached network image
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      alignment: alignment,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
    );
  }

  Widget _buildWebImage() {
    return FutureBuilder<Widget>(
      future: _loadWebImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return placeholder ?? _buildPlaceholder();
        }
        
        if (snapshot.hasError) {
          if (kDebugMode) {
            print('❌ Image load error: ${snapshot.error}');
          }
          return errorWidget ?? _buildErrorWidget();
        }
        
        return snapshot.data ?? (errorWidget ?? _buildErrorWidget());
      },
    );
  }

  Future<Widget> _loadWebImage() async {
    try {
      // Try to load image with CORS handling
      final response = await WebProxyService.getImage(imageUrl);
      
      if (response.statusCode == 200) {
        return Image.memory(
          response.bodyBytes,
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          alignment: alignment,
          errorBuilder: (context, error, stackTrace) {
            if (kDebugMode) {
              print('❌ Image.memory error: $error');
            }
            return errorWidget ?? _buildErrorWidget();
          },
        );
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to load image with proxy: $e');
      }
      
      // Fallback to regular Image.network with error handling
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        alignment: alignment,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? _buildPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          if (kDebugMode) {
            print('❌ Image.network fallback error: $error');
          }
          return errorWidget ?? _buildErrorWidget();
        },
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: Colors.grey[600],
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Image not available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Extension to easily replace Image.network calls
extension ImageNetworkExtension on Image {
  static Widget corsNetwork(
    String src, {
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return CorsImage(
      imageUrl: src,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}
