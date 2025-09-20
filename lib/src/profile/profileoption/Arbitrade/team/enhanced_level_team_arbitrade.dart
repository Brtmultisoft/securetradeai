import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rapidtradeai/data/strings.dart';
import 'package:rapidtradeai/src/profile/profileoption/Arbitrade/team/enhanced_team_detail_arbitrade.dart';
import 'package:rapidtradeai/src/widget/lottie_loading_widget.dart';
import 'package:rapidtradeai/Data/Api.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';

class EnhancedArbitradePageLevelTeam extends StatefulWidget {
  const EnhancedArbitradePageLevelTeam({Key? key, this.image}) : super(key: key);
  final image;
  @override
  EnhancedArbitradePageLevelTeamState createState() => EnhancedArbitradePageLevelTeamState();
}

class EnhancedArbitradePageLevelTeamState extends State<EnhancedArbitradePageLevelTeam> {
  bool isAPIcalled = false;
  bool checkdata = false;
  var teamData = [];
  int level1 = 0;
  int level2 = 0;
  int level3 = 0;
  int level4 = 0;
  int level5 = 0;
  int level6 = 0;
  int level7 = 0;
  int level8 = 0;
  int level9 = 0;
  int level10 = 0;

  // Team earnings data
  double totalEarned = 0.0;
  double monthlyTarget = 2000.0;
  double monthlyEarned = 0.0;
  bool isEarningsLoading = false;

  Future _getTeam() async {
    try {
      setState(() {
        isAPIcalled = true;
      });
      final res = await http.post(Uri.parse(teamDetail),
          body: jsonEncode({'user_id': commonuserId}));
      if (res.statusCode != 200) {
        showtoast("Server Error", context);
        setState(() {
          isAPIcalled = false;
        });
      } else {
        var data = jsonDecode(res.body);


        if (data['status'] == "success") {
          // Reset counters
          level1 = level2 = level3 =
              level4 = level5 = level6 = level7 = level8 = level9 = level10 = 0;

          for (var element in data['data']) {
            // Make sure we have a level field
            String levelStr =
                element["level"] != null ? element["level"].toString() : "";

            // Count members by level
            if (levelStr == "Level 1") {
              level1++;
            } else if (levelStr == "Level 2") {
              level2++;
            } else if (levelStr == "Level 3") {
              level3++;
            } else if (levelStr == "Level 4") {
              level4++;
            } else if (levelStr == "Level 5") {
              level5++;
            } else if (levelStr == "Level 6") {
              level6++;
            } else if (levelStr == "Level 7") {
              level7++;
            } else if (levelStr == "Level 8") {
              level8++;
            } else if (levelStr == "Level 9") {
              level9++;
            } else if (levelStr == "Level 10") {
              level10++;
            }
          }

          if (mounted) {
            setState(() {
              teamData = data['data'];
              isAPIcalled = false;
            });
          }
        } else {
          showtoast(data['message'], context);
          if (mounted) {
            setState(() {
              checkdata = true;
              isAPIcalled = false;
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching team data: $e"); // Debug print for errors
      setState(() {
        isAPIcalled = false;
      });
    }
  }

  // Fetch team earnings data from various income sources
  Future<void> _getTeamEarnings() async {
    try {
      setState(() {
        isEarningsLoading = true;
      });

      // Use the CommonMethod class to fetch various income data
      // This combines level income, referral income, etc.
      double totalIncome = 0.0;
      double monthlyIncome = 0.0;

      try {
        // Get level income data
        final levelIncomeRes = await http.post(Uri.parse(levelincomeDetail),
            body: jsonEncode({"user_id": commonuserId}));

        if (levelIncomeRes.statusCode == 200) {
          var data = jsonDecode(levelIncomeRes.body);
          if (data['status'] == "success") {
            var levelData = data['data'];
            if (levelData['cumulative_profit'] != null) {
              totalIncome +=
                  double.tryParse(levelData['cumulative_profit'].toString()) ??
                      0.0;
            }
            if (levelData['profit_today'] != null) {
              monthlyIncome +=
                  double.tryParse(levelData['profit_today'].toString()) ?? 0.0;
            }
          }
        }
      } catch (e) {
        print('Error fetching level income: $e');
      }

      try {
        // Get direct income data
        final directIncomeRes = await http.post(Uri.parse(directIncomeDetail),
            body: jsonEncode({"user_id": commonuserId}));

        if (directIncomeRes.statusCode == 200) {
          var data = jsonDecode(directIncomeRes.body);
          if (data['status'] == "success") {
            var directData = data['data'];
            if (directData['cumulative_profit'] != null) {
              totalIncome +=
                  double.tryParse(directData['cumulative_profit'].toString()) ??
                      0.0;
            }
            if (directData['profit_today'] != null) {
              monthlyIncome +=
                  double.tryParse(directData['profit_today'].toString()) ?? 0.0;
            }
          }
        }
      } catch (e) {
        print('Error fetching direct income: $e');
      }

      // Update state with the fetched data
      setState(() {
        totalEarned = totalIncome;
        monthlyEarned = monthlyIncome;
        isEarningsLoading = false;
      });
    } catch (e) {
      print('Error fetching team earnings: $e');
      setState(() {
        isEarningsLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getTeam();
    _getTeamEarnings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      body: isAPIcalled
          ? const Center(
              child: LottieLoadingWidget.fullScreen(
                  message: 'Loading Team Data...'),
            )
          : checkdata
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/img/logo.png", height: 120),
                      const SizedBox(height: 20),
                      const Text(
                        "No team members found",
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontFamily: fontFamily),
                      ),
                    ],
                  ),
                )
              : _getalevelTeam(),
    );
  }

  Widget _getalevelTeam() {
    // Calculate total earnings (mock data for demonstration)
    int totalMembers = level1 +
        level2 +
        level3 +
        level4 +
        level5 +
        level6 +
        level7 +
        level8 +
        level9 +
        level10;

    int totalActiveMembers = teamData.where((e) => e['days_bal'] != "0").length;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero section with animated gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF0B90B),
              borderRadius: BorderRadius.circular(0),
            ),
            child: Column(
              children: [
                // Team icon with glow effect
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2329).withOpacity(0.3),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF0B90B).withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.people_alt_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                // Team title
                const Text(
                  "Your Referral Network",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                ),
                const SizedBox(height: 8),
                // Team subtitle
                Text(
                  "Build your team and earn commissions",
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontSize: 16,
                    fontFamily: fontFamily,
                  ),
                ),
                const SizedBox(height: 24),
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAnimatedStatCard("Total\nMembers", "$totalMembers",
                        const Color(0xFF4A90E2)),
                    _buildAnimatedStatCard("Direct\nReferrals", "$level1",
                        const Color(0xFFF0B90B)),
                    _buildAnimatedStatCard("Active\nMembers",
                        "$totalActiveMembers", const Color(0xFF2EBD85)),
                  ],
                ),
              ],
            ),
          ),

          // Earnings section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2329),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A3A5A)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isEarningsLoading
                ? const Center(
                    child: LottieLoadingWidget.large(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2EBD85).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.attach_money,
                              color: Color(0xFF2EBD85),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Team Earnings",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Earned",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                  fontFamily: fontFamily,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    "\$${totalEarned.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Color(0xFF2EBD85),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: fontFamily,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2EBD85)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      monthlyEarned > 0
                                          ? "+${(monthlyEarned / (totalEarned > 0 ? totalEarned : 1) * 100).toStringAsFixed(1)}%"
                                          : "0%",
                                      style: const TextStyle(
                                        color: Color(0xFF2EBD85),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: fontFamily,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // _buildEarningsButton(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Earnings progress bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Monthly Target",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                  fontFamily: fontFamily,
                                ),
                              ),
                              Text(
                                "\$${monthlyEarned.toStringAsFixed(2)} / \$${monthlyTarget.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: fontFamily,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              Container(
                                height: 8,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0B0E11),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Container(
                                height: 8,
                                width: MediaQuery.of(context).size.width *
                                    (monthlyEarned / monthlyTarget)
                                        .clamp(0.0, 1.0) *
                                    0.7, // Real progress
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2EBD85),
                                      Color(0xFF4A90E2)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${(monthlyEarned / monthlyTarget * 100).toStringAsFixed(1)}% of monthly target reached",
                            style: TextStyle(
                              fontFamily: fontFamily,
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),

          // Team hierarchy visualization
          // Container(
          //   margin: const EdgeInsets.symmetric(horizontal: 16),
          //   padding: const EdgeInsets.all(20),
          //   decoration: BoxDecoration(
          //     color: const Color(0xFF1E2329),
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(color: const Color(0xFF2A3A5A)),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       const Text(
          //         "Team Hierarchy",
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 18,
          //           fontWeight: FontWeight.bold,
          //           fontFamily: fontFamily,
          //         ),
          //       ),
          //       const SizedBox(height: 8),
          //       Text(
          //         "View your team structure across levels",
          //         style: TextStyle(
          //           color: Colors.white.withOpacity(0.7),
          //           fontSize: 14,
          //           fontFamily: fontFamily,
          //         ),
          //       ),
          //       const SizedBox(height: 20),
          //       _buildHierarchyVisualization(),
          //     ],
          //   ),
          // ),

          // const SizedBox(height: 20),

          // Level title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0B90B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.layers,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Team Levels",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Level 1
          _buildLevelCard("1", level1),

          // Level 2
          _buildLevelCard("2", level2),

          // Level 3
          _buildLevelCard("3", level3),

          // Level 4
          _buildLevelCard("4", level4),

          // Level 5
          _buildLevelCard("5", level5),

          // More levels (collapsed by default)
          ExpansionTile(
            collapsedBackgroundColor: const Color(0xFF1E2329),
            backgroundColor: const Color(0xFF1E2329),
            collapsedIconColor: const Color(0xFFF0B90B),
            iconColor: const Color(0xFFF0B90B),
            title: const Text(
              "More Levels",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
            children: [
              _buildLevelCard("6", level6),
              _buildLevelCard("7", level7),
              _buildLevelCard("8", level8),
              _buildLevelCard("9", level9),
              _buildLevelCard("10", level10)
            ],
          ),

          const SizedBox(height: 30),

          // Referral tips section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2329),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A3A5A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.lightbulb,
                        color: Color(0xFF4A90E2),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Referral Tips",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTipItem(
                  "Share your referral code on social media",
                  "Reach a wider audience by sharing on Twitter, Facebook, and Instagram",
                  Icons.share,
                ),
                const SizedBox(height: 12),
                _buildTipItem(
                  "Create educational content",
                  "Help others understand crypto trading to attract more referrals",
                  Icons.school,
                ),
                const SizedBox(height: 12),
                _buildTipItem(
                  "Engage with your team",
                  "Regular communication helps keep your team active and growing",
                  Icons.forum,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildLevelCard(String level, int count) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2329),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A3A5A)),
      ),
      child: ListTile(
        onTap: () {
          _goToDetailPage(level);
        },
        leading: CircleAvatar(
          radius: 20.0,
          backgroundColor: const Color(0xFF0B0E11),
          backgroundImage: NetworkImage(
            widget.image == null
                ? "${imagepath}default.jpg"
                : "${imagepath}${widget.image}",
          ),
        ),
        title: Text(
          "Level $level",
          style: const TextStyle(
              color: Colors.white,
              fontFamily: fontFamily,
              fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Total: $count",
          style: const TextStyle(color: Colors.white70, fontFamily: fontFamily),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0B0E11),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF2A3A5A)),
          ),
          child: const Text(
            "View",
            style: TextStyle(
                color: Color(0xFFF0B90B),
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily),
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4A90E2),
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontFamily: fontFamily,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E11),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A3A5A)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFF0B90B),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatCard(String title, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0B90B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0B90B), Color(0xFFD4A017)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF0B90B).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            "View Details",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildHierarchyVisualization() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E11),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Level 1 (You)
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: _buildHierarchyNode("You", const Color(0xFFF0B90B), true),
            ),
          ),
          // Connecting lines
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 2,
                height: 20,
                color: const Color(0xFF2A3A5A),
              ),
            ),
          ),
          // Level 2 (Direct referrals)
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHierarchyNode("Level 1", const Color(0xFF4A90E2), false),
                const SizedBox(width: 40),
                _buildHierarchyNode("Level 1", const Color(0xFF4A90E2), false),
                const SizedBox(width: 40),
                _buildHierarchyNode("Level 1", const Color(0xFF4A90E2), false),
              ],
            ),
          ),
          // Connecting lines to level 3
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 2, height: 20, color: const Color(0xFF2A3A5A)),
                const SizedBox(width: 40),
                Container(width: 2, height: 20, color: const Color(0xFF2A3A5A)),
                const SizedBox(width: 40),
                Container(width: 2, height: 20, color: const Color(0xFF2A3A5A)),
              ],
            ),
          ),
          // Level 3
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildHierarchyNode("L2", const Color(0xFF7E57C2), false),
                _buildHierarchyNode("L2", const Color(0xFF7E57C2), false),
                _buildHierarchyNode("L2", const Color(0xFF7E57C2), false),
                _buildHierarchyNode("L2", const Color(0xFF7E57C2), false),
                _buildHierarchyNode("L2", const Color(0xFF7E57C2), false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHierarchyNode(String label, Color color, bool isYou) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isYou ? 40 : 30,
          height: isYou ? 40 : 30,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              isYou ? "Y" : label[0],
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: isYou ? 16 : 12,
              ),
            ),
          ),
        ),
        if (isYou) const SizedBox(height: 4),
        if (isYou)
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: fontFamily,
            ),
          ),
      ],
    );
  }

  _goToDetailPage(String level) {
    var data = [];
    data.clear();
    for (var element in teamData) {
      if (element['level'] == "Level $level") {
        // Pass all available member data instead of just 3 fields
        data.add({
          "image": element['image'],
          "name": element['name'],
          "days": element['days_bal'],
          "days_bal": element['days_bal'], // Alternative key name
          "user_id": element['user_id'],
          "uid": element['uid'], // Make sure uid is included
          "email": element['email'],
          "mobile": element['mobile'],
          "gender": element['gender'],
          "rank": element['rank'],
          "level": element['level'],
          "verify": element['verify'],
          "country": element['country'],
          "referral_code": element['referral_code'],
          "balance": element['balance'],
          "income_balance": element['income_balance'],
          "gas_balance": element['gas_balance'],
          "doa": element['doa'], // Date of activation
        });
      }
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EnhancedTeamDetailArbitrade(
                  data: data,
                  level: level.toString(),
                )));
  }
}
