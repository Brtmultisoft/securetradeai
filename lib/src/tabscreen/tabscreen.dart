import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapidtradeai/data/strings.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';
import 'package:rapidtradeai/src/homepage/home.dart';
import 'package:rapidtradeai/src/news/newspage.dart';
import 'package:rapidtradeai/src/profile/profile.dart';
import 'package:rapidtradeai/src/quantitative/quatitativepage.dart';
import 'package:rapidtradeai/src/utils/responsive_utils.dart';
import 'package:rapidtradeai/src/widget/responsive_layout_wrapper.dart';
import 'package:rapidtradeai/src/widget/trading_animations.dart';

import '../../model/repoModel.dart';

class Tabscreen extends StatefulWidget {
  const Tabscreen({Key? key, this.reffral}) : super(key: key);
  final reffral;
  @override
  _TabscreenState createState() => _TabscreenState();
}

class _TabscreenState extends State<Tabscreen> {
  late PageController _controller;
  int currentPage = 0;
  bool showornot = true;
  bool refreshTime = false;
  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  void changePage(int id) {
    setState(() {
      _controller.jumpToPage(id);
      currentPage = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    // Check if we're on web and desktop
    final isWebDesktop = kIsWeb && SizeConfig.isDesktop!;

    return Scaffold(
      backgroundColor: bg,
      body: isWebDesktop ? _buildWebDesktopLayout() : _buildMobileLayout(),
      bottomNavigationBar: isWebDesktop ? null : _buildBottomNavigation(),
    );
  }

  Widget logout() {
    return InkWell(
      onTap: () {
        print('object');
      },
      // child: ,
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currentPage == index;
    return RippleAnimation(
      rippleColor: TradingTheme.secondaryAccent,
      onTap: () => changePage(index),
      child: AnimatedContainer(
        duration: TradingAnimations.normalAnimation,
        curve: TradingAnimations.defaultCurve,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? TradingTheme.secondaryAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: TradingTheme.secondaryAccent.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: TradingAnimations.normalAnimation,
              curve: TradingAnimations.defaultCurve,
              transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
              child: Icon(
                icon,
                color: isSelected ? Colors.black : Colors.white70,
                size: 20,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: TradingAnimations.normalAnimation,
              curve: TradingAnimations.defaultCurve,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: _controller,
      children: [
        Homepage(reffral: widget.reffral),
        SpotTradingService(
          reffralno: widget.reffral,
        ),
        News(),
        const Profile()
      ],
    );
  }

  Widget _buildWebDesktopLayout() {
    return Row(
      children: [
        // Side navigation for desktop
        Container(
          width: 250,
          color: const Color(0xFF161A1E),
          child: Column(
            children: [
              // Logo/Header
              Container(
                height: 80,
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: Text(
                    'RapidTradeAI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Divider(color: Color(0xFF2A3A5A), height: 1),
              // Navigation items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildSideNavItem(0, Icons.home, "Home"),
                    _buildSideNavItem(1, Icons.bar_chart, "Spot Trading"),
                    _buildSideNavItem(2, Icons.receipt_long, "Orders"),
                    _buildSideNavItem(3, Icons.person, "Me"),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Main content area
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _controller,
              children: [
                Homepage(reffral: widget.reffral),
                SpotTradingService(
                  reffralno: widget.reffral,
                ),
                News(),
                const Profile()
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideNavItem(int index, IconData icon, String label) {
    final isSelected = currentPage == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => changePage(index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF03DAC6).withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: const Color(0xFF03DAC6), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? const Color(0xFF03DAC6) : Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF03DAC6) : Colors.white70,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Consumer<Repo>(builder: (context, repo, child) {
          return Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF121824),
              border: Border(
                top: BorderSide(
                  color: Color(0xFF2A3A5A),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: Color(0xFF03DAC6),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      repo.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    setState(() => refreshTime = true);
                    final bal = Provider.of<Repo>(context, listen: false);
                    await Future.delayed(
                        const Duration(seconds: 3),
                            () => bal.updateBalance(
                            exchanger == "null" ? "Binance" : exchanger));
                    setState(() => refreshTime = false);
                  },
                  icon: refreshTime
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF03DAC6),
                    ),
                  )
                      : const Icon(
                    Icons.refresh,
                    color: Color(0xFF03DAC6),
                    size: 16,
                  ),
                ),
              ],
            ),
          );
        }),
        Container(
          width: SizeConfig.width,
          height: 56,
          decoration: const BoxDecoration(
            color: Color(0xFF121824),
            border: Border(
              top: BorderSide(
                color: Color(0xFF2A3A5A),
                width: 1,
              ),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home, "Home"),
                _buildNavItem(1, Icons.bar_chart, "Spot Trading"),
                _buildNavItem(2, Icons.receipt_long, "Orders"),
                _buildNavItem(3, Icons.person, "Me"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
