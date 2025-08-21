import 'package:flutter/material.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';

class AboutTrustcoin extends StatefulWidget {
  const AboutTrustcoin();

  @override
  State<AboutTrustcoin> createState() => _AboutTrustcoinState();
}

class _AboutTrustcoinState extends State<AboutTrustcoin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg2,
      appBar: CommonAppBar.basic(
        title: "About Us",
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: ListView(
          children: [
            SizedBox(height: 20),
            Text(
              "SECURE TRADE: AI-POWERED CRYPTO TRADING PLATFORM BUILT FOR TRUST AND PERFORMANCE",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Secure Trade is a next-generation AI-driven crypto trading platform engineered to provide a safe, transparent, and efficient trading experience for all levels of investors. At its core, Secure Trade uses intelligent algorithms that analyze market trends in real time to optimize buy and sell signals, minimizing human error and maximizing profit potential.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 15),
            Text(
              "The platform is designed with robust security features, including end-to-end encryption, two-factor authentication (2FA), and decentralized data protocols, ensuring user data and funds remain protected at all times. Secure Trade also incorporates smart risk management strategies, automatically adjusting trades based on market volatility and user-defined thresholds.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 15),
            Text(
              "Unlike traditional platforms, Secure Trade empowers users with full transparency — from real-time trade execution to complete access to performance analytics. Whether you're staking, trading, or holding, the platform offers a seamless experience through its intuitive interface and 24/7 AI bot support.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 15),
            Text(
              "Secure Trade isn't just a trading tool — it's a complete ecosystem built to foster financial growth, security, and user empowerment in the crypto world.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
