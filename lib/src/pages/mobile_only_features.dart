import 'package:flutter/material.dart';
import 'package:securetradeai/src/widget/responsive_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:securetradeai/src/widget/trading_animations.dart';

class MobileOnlyFeaturesPage extends StatelessWidget {
  final String? specificFeature;

  const MobileOnlyFeaturesPage({
    Key? key,
    this.specificFeature,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171d28),
        title: Text(
          specificFeature != null
              ? '$specificFeature - Mobile Required'
              : 'Mobile Trading Features',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E2A3A), Color(0xFF2A3A4A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF3A4A5A), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0B90B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.phone_android,
                          color: Color(0xFFF0B90B),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Text(
                          'Mobile Device Required',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    specificFeature != null
                        ? '$specificFeature is optimized for mobile devices and requires native mobile functionality to work properly. Please download our mobile app to access this feature.'
                        : 'These advanced trading features are optimized for mobile devices and require native mobile functionality to work properly.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Features Grid
            const Text(
              'Available on Mobile App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            
            GridView.count(
              crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(context),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.2,
              children: [
                // Spot Trading
                _buildMobileFeatureCard(
                  context,
                  icon: "assets/img/spot_trading.png",
                  title: "Spot Trading",
                  description: "Real-time spot trading with live market data",
                  features: [
                    "Live price updates",
                    "Instant order execution",
                    "Real-time notifications"
                  ],
                  onTap: () => _showMobileRequiredDialog(context, "Spot Trading"),
                ),

                // Future Trading
                _buildMobileFeatureCard(
                  context,
                  icon: "assets/img/future_trading.png",
                  title: "Future Trading",
                  description: "Advanced futures trading with leverage",
                  features: [
                    "Leverage trading",
                    "Stop-loss automation",
                    "Position management"
                  ],
                  onTap: () => _showMobileRequiredDialog(context, "Future Trading"),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Download App Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF0B90B), Color(0xFFE6A509)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.download,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Download Mobile App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Get the full trading experience with our mobile app',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _downloadApp(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFF0B90B),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Download Android App',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileFeatureCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required List<String> features,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2A3A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3A4A5A), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  icon,
                  width: 24,
                  height: 24,
                  color: const Color(0xFFF0B90B),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFFF0B90B),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  // Download app method
  void _downloadApp() async {
    const String apkUrl = 'https://securetradeai.com/assets/royalking/assets/APK/securetradeai.apk';

    try {
      final Uri url = Uri.parse(apkUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback: Show download dialog with manual link
        _showManualDownloadDialog(apkUrl);
      }
    } catch (e) {
      // Error handling: Show manual download dialog
      _showManualDownloadDialog(apkUrl);
    }
  }

  void _showManualDownloadDialog(String apkUrl) {
    // Show a snackbar or toast with the download link
    // This is a fallback when automatic download fails
  }

  void _showMobileRequiredDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2A3A),
          title: Row(
            children: const [
              Icon(
                Icons.phone_android,
                color: Color(0xFFF0B90B),
              ),
              SizedBox(width: 10),
              Text(
                'Mobile Required',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Text(
            '$featureName requires a mobile device to function properly. Please download our mobile app to access this feature.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFFF0B90B)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _downloadApp();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF0B90B),
              ),
              child: const Text('Download App'),
            ),
          ],
        );
      },
    );
  }


}
