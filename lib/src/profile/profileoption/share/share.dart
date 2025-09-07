import 'dart:async';
import 'dart:developer';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';
import 'package:share_plus/share_plus.dart';

class Sharescreen extends StatefulWidget {
  const Sharescreen({Key? key, required this.reffral}) : super(key: key);
  final String reffral;
  @override
  SharescreenState createState() => SharescreenState();
}

class SharescreenState extends State<Sharescreen> {
  bool _isCopied = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    log(widget.reffral.toString());
    super.initState();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.reffral));
    setState(() {
      _isCopied = true;
    });
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _isCopied = false;
      });
    });
    showtoast("Invite code copied to clipboard", context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: CommonAppBar.basic(
        title: "Invite Friends".tr,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top section with gradient background
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1E2329),
                    Color(0xFF0B0E11),
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                children: [
                  const Text(
                    "Invite Friends & Earn Rewards",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Subheading
                  Text(
                    "Turn your network into earnings — invite friends and get rewarded as they trade.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // QR Code section
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2329),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Scan QR Code",
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: BarcodeWidget(
                      barcode: Barcode.qrCode(),
                      color: Colors.black,
                      data: widget.reffral,
                      width: 180,
                      height: 180,
                    ),
                  ),
                ],
              ),
            ),

            // Invite code section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2329),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  const Text(
                    "Your Invite Code",
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B0E11),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: const Color(0xFF2A2E35)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.reffral,
                          style: const TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF0B90B),
                          ),
                        ),
                        GestureDetector(
                          onTap: _copyToClipboard,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _isCopied
                                  ? const Color(0xFF2EBD85)
                                  : const Color(0xFF1E2329),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isCopied ? Icons.check : Icons.copy,
                                  color: _isCopied
                                      ? Colors.white
                                      : const Color(0xFFF0B90B),
                                  size: 18,
                                ),
                                if (_isCopied) ...[
                                  const SizedBox(width: 4),
                                  const Text(
                                    "Copied",
                                    style: TextStyle(
                                      fontFamily: fontFamily,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Share buttons
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2329),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  const Text(
                    "Share With Friends",
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildShareButton(
                        icon: Icons.message,
                        label: "Message",
                        color: const Color(0xFF4A90E2),
                        onTap: () {
                          Share.share(
                            '🚀 *SecureTradeAI - Crypto Trading Platform*\n\n💰 Join me on SecureTradeAI and start earning with automated crypto trading!\n\n✅ *Features:*\n• Automated Trading Bots\n• Real-time Market Analysis\n• Multi-Exchange Support\n• Secure & Reliable Platform\n\n🎁 *Use my invite code:* ${widget.reffral}\n\n🌐 *Download & Register:*\nhttps://securetradeai.com/\n\n💎 Start your crypto journey today!',
                          );
                        },
                      ),
                      _buildShareButton(
                        icon: Icons.email,
                        label: "Email",
                        color: const Color(0xFF2EBD85),
                        onTap: () {
                          Share.share(
                            '🚀 SecureTradeAI - Crypto Trading Platform\n\n💰 Join me on SecureTradeAI and start earning with automated crypto trading!\n\n✅ Features:\n• Automated Trading Bots\n• Real-time Market Analysis\n• Multi-Exchange Support\n• Secure & Reliable Platform\n\n🎁 Use my invite code: ${widget.reffral}\n\n🌐 Download & Register:\nhttps://securetradeai.com/\n\n💎 Start your crypto journey today!',
                            subject: 'Join SecureTradeAI - Crypto Trading Invitation',
                          );
                        },
                      ),
                      _buildShareButton(
                        icon: Icons.share,
                        label: "More",
                        color: const Color(0xFFF0B90B),
                        onTap: () {
                          Share.share(
                            '🚀 *SecureTradeAI - Crypto Trading Platform*\n\n💰 Join me on SecureTradeAI and start earning with automated crypto trading!\n\n✅ *Features:*\n• Automated Trading Bots\n• Real-time Market Analysis\n• Multi-Exchange Support\n• Secure & Reliable Platform\n\n🎁 *Use my invite code:* ${widget.reffral}\n\n🌐 *Download & Register:*\nhttps://securetradeai.com/\n\n💎 Start your crypto journey today!',
                          );
                        },
                      ),
                    ],
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

  Widget _buildShareButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: fontFamily,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem({
    required String title,
    required String value,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E11),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: fontFamily,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF0B90B),
            ),
          ),
        ],
      ),
    );
  }
}
