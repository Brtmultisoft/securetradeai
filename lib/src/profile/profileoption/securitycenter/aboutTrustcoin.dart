import 'package:flutter/material.dart';
import 'package:securetradeai/src/Service/assets_service.dart';

class AboutTrustcoin extends StatefulWidget {
  const AboutTrustcoin();

  @override
  State<AboutTrustcoin> createState() => _AboutTrustcoinState();
}

class _AboutTrustcoinState extends State<AboutTrustcoin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: bg,
        title: const Text("About Us",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily)),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: ListView(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              "TRUST COIN: THE FIRST AI-ALGORITHMIC CRYPTO TRADING & STAKING APP, A SINGLE APP!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Trust Coin have introduced the first ever staking program within the TRADING APP – means double benefit within A SINGLE APP & SYSTEM. The Trust Coin staking plan works with the growth of the applica􏰀on and its userbase. Trust Coin management have taken a major step towards the basic principle of the Blockchain and they have chosen Trust Coin as a fuel to the applica􏰀on, that will bring the Trust Coin Users with first 100% community-based Trust Coin ownership and governance. By Trust Coin staking plans, the growth of the applica􏰀on and demand of the Trust Coin will be boosted. h􏰁ps://www.trustcoin.app",
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
