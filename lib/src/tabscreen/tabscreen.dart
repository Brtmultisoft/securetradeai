import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/homepage/home.dart';
import 'package:securetradeai/src/news/newspage.dart';
import 'package:securetradeai/src/profile/profile.dart';
import 'package:securetradeai/src/quantitative/quatitativepage.dart';

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
    return Scaffold(
      backgroundColor: bg,
      body: PageView(
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
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Consumer<Repo>(builder: (context, repo, child) {
            return Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
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
                      Icon(
                        Icons.account_balance_wallet,
                        color: Color(0xFF4A90E2),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        repo.value,
                        style: TextStyle(
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
                    constraints: BoxConstraints(),
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
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF4A90E2),
                            ),
                          )
                        : Icon(
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
            width: SizeConfig.width,
            height: 56,
            decoration: BoxDecoration(
              color: Color(0xFF121824),
              border: Border(
                top: BorderSide(
                  color: Color(0xFF2A3A5A),
                  width: 1,
                ),
              ),
            ),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
    return GestureDetector(
      onTap: () => changePage(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF1A2234) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Color(0xFF4A90E2) : Colors.white70,
              size: 20,
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Color(0xFF4A90E2) : Colors.white70,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
