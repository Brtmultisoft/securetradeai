import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/homepage/home.dart';
import 'package:securetradeai/src/news/newspage.dart';
import 'package:securetradeai/src/profile/profile.dart';
import 'package:securetradeai/src/quantitative/quatitativepage.dart';
import 'package:securetradeai/src/widget/trading_animations.dart';
import 'package:securetradeai/src/widget/responsive_utils.dart';

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
    return Scaffold(
      backgroundColor: bg,
      body: ResponsiveUtils.isWeb(context)
          ? Row(
              children: [
                // Side navigation for web
                Container(
                  width: 250,
                  decoration: const BoxDecoration(
                    color: Color(0xFF121824),
                    border: Border(
                      right: BorderSide(
                        color: Color(0xFF2A3A5A),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Logo section
                      Container(
                        height: 80,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/img/logo.png',
                              height: 40,
                              width: 40,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'SecureTradeAI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Color(0xFF2A3A5A)),
                      // Navigation items
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          children: [
                            _buildWebNavItem(0, Icons.home, "Home"),
                            _buildWebNavItem(1, Icons.bar_chart, "Spot Trading"),
                            _buildWebNavItem(2, Icons.receipt_long, "Orders"),
                            _buildWebNavItem(3, Icons.person, "Profile"),
                          ],
                        ),
                      ),
                      // Balance section
                      Consumer<Repo>(builder: (context, repo, child) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Color(0xFF2A3A5A),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.account_balance_wallet,
                                color: Color(0xFF4A90E2),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  repo.value,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
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
                                          color: Color(0xFF4A90E2),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.refresh,
                                        color: Color(0xFF4A90E2),
                                        size: 16,
                                      ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                // Main content area
                Expanded(
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
              ],
            )
          : PageView(
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
      bottomNavigationBar: ResponsiveUtils.isWeb(context)
          ? null
          : Column(
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
                              color: Color(0xFF4A90E2),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              repo.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily,
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
                                    color: Color(0xFF4A90E2),
                                  ),
                                )
                              : const Icon(
                                  Icons.refresh,
                                  color: Color(0xFF4A90E2),
                                  size: 16,
                                ),
                        ),
                      ],
                    ),
                  );
                }),
                Container(
                  width: MediaQuery.of(context).size.width,
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
            ),
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
      rippleColor: const Color(0xFF4A90E2),
      onTap: () => changePage(index),
      child: AnimatedContainer(
        duration: TradingAnimations.normalAnimation,
        curve: TradingAnimations.defaultCurve,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A2234) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF4A90E2).withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: TradingAnimations.normalAnimation,
              curve: TradingAnimations.defaultCurve,
              transform: Matrix4.identity()
                ..scale(isSelected ? 1.1 : 1.0),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF4A90E2) : Colors.white70,
                size: 20,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: TradingAnimations.normalAnimation,
              curve: TradingAnimations.defaultCurve,
              style: TextStyle(
                color: isSelected ? const Color(0xFF4A90E2) : Colors.white70,
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

  Widget _buildWebNavItem(int index, IconData icon, String label) {
    final isSelected = currentPage == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => changePage(index),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: TradingAnimations.normalAnimation,
            curve: TradingAnimations.defaultCurve,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1A2234) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(
                      color: const Color(0xFF4A90E2).withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? const Color(0xFF4A90E2) : Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF4A90E2) : Colors.white70,
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
}
