import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/src/Service/assets_service.dart';

import '../../../../Data/Api.dart';

class EnhancedRankTeam extends StatefulWidget {
  const EnhancedRankTeam({Key? key, this.image}) : super(key: key);
  final image;

  @override
  EnhancedRankTeamState createState() => EnhancedRankTeamState();
}

class EnhancedRankTeamState extends State<EnhancedRankTeam> {
  bool isAPIcalled = false;
  bool checkdata = false;
  var teamData;
  int p0 = 0;
  int p1 = 0;
  int p2 = 0;
  int p3 = 0;
  int p4 = 0;
  int p5 = 0;
  int p6 = 0;

  // Rank names and descriptions
  final List<Map<String, dynamic>> rankInfo = [
    {
      'name': 'Newcomer',
      'description': 'Just getting started',
      'color': Colors.white,
      'icon': Icons.star_border,
      'benefits': ['Basic trading features', 'Standard support'],
      'requirements': 'No requirements'
    },
    {
      'name': 'Bronze',
      'description': 'Building your network',
      'color': Color(0xFFCD7F32),
      'icon': Icons.workspace_premium,
      'benefits': ['5% trading fee discount', 'Priority support'],
      'requirements': '5 active referrals'
    },
    {
      'name': 'Silver',
      'description': 'Growing steadily',
      'color': Color(0xFFC0C0C0),
      'icon': Icons.workspace_premium,
      'benefits': ['10% trading fee discount', 'VIP support', 'Weekly reports'],
      'requirements': '15 active referrals'
    },
    {
      'name': 'Gold',
      'description': 'Established networker',
      'color': Color(0xFFFFD700),
      'icon': Icons.workspace_premium,
      'benefits': [
        '15% trading fee discount',
        'Dedicated account manager',
        'Advanced analytics'
      ],
      'requirements': '30 active referrals'
    },
    {
      'name': 'Platinum',
      'description': 'Professional networker',
      'color': Color(0xFFE5E4E2),
      'icon': Icons.diamond,
      'benefits': [
        '20% trading fee discount',
        'Exclusive events access',
        'Premium tools'
      ],
      'requirements': '50 active referrals'
    },
    {
      'name': 'Diamond',
      'description': 'Elite networker',
      'color': Color(0xFF40E0D0),
      'icon': Icons.diamond,
      'benefits': [
        '25% trading fee discount',
        'Exclusive investment opportunities',
        'Custom solutions'
      ],
      'requirements': '100 active referrals'
    },
    {
      'name': 'Black Diamond',
      'description': 'Legendary networker',
      'color': Color(0xFF212121),
      'icon': Icons.diamond,
      'benefits': [
        '30% trading fee discount',
        'Revenue sharing',
        'Global events access'
      ],
      'requirements': '200+ active referrals'
    },
  ];

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
          var localdata = data['data'] as List;
          for (var element in localdata) {
            if (element["rank"] == "0") {
              setState(() => p0++);
            }
            if (element["rank"] == "1") {
              setState(() => p1++);
            }
            if (element["rank"] == "2") {
              setState(() => p2++);
            }
            if (element["rank"] == "3") {
              setState(() => p3++);
            }
            if (element["rank"] == "4") {
              setState(() => p4++);
            }
            if (element["rank"] == "5") {
              setState(() => p5++);
            }
            if (element["rank"] == "6") {
              setState(() => p6++);
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
      setState(() {
        isAPIcalled = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getTeam();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      body: isAPIcalled
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF0B90B)),
            )
          : checkdata
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/img/logo.png", height: 120),
                      const SizedBox(height: 20),
                      const Text(
                        "No rank data available",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ],
                  ),
                )
              : _getRank(),
    );
  }

  Widget _getRank() {
    // Calculate total members
    int totalMembers = p0 + p1 + p2 + p3 + p4 + p5 + p6;

    // Determine user's current rank (for demo purposes)
    int userRank = 0;
    if (p1 >= 5) userRank = 1;
    if (p2 >= 15) userRank = 2;
    if (p3 >= 30) userRank = 3;
    if (p4 >= 50) userRank = 4;
    if (p5 >= 100) userRank = 5;
    if (p6 >= 200) userRank = 6;

    // Calculate progress to next rank
    int nextRankRequirement = 5;
    if (userRank == 1) nextRankRequirement = 15;
    if (userRank == 2) nextRankRequirement = 30;
    if (userRank == 3) nextRankRequirement = 50;
    if (userRank == 4) nextRankRequirement = 100;
    if (userRank == 5) nextRankRequirement = 200;

    int currentReferrals = 0;
    switch (userRank) {
      case 0:
        currentReferrals = p0;
        break;
      case 1:
        currentReferrals = p1;
        break;
      case 2:
        currentReferrals = p2;
        break;
      case 3:
        currentReferrals = p3;
        break;
      case 4:
        currentReferrals = p4;
        break;
      case 5:
        currentReferrals = p5;
        break;
      case 6:
        currentReferrals = p6;
        break;
    }

    double progressPercentage = userRank < 6
        ? (currentReferrals / nextRankRequirement).clamp(0.0, 1.0)
        : 1.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero section with current rank
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF0B90B),
            ),
            child: Column(
              children: [
                // Rank badge
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.9),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: rankInfo[userRank]['color'].withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      rankInfo[userRank]['icon'],
                      color: Colors.white,
                      size: 50,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Rank name
                Text(
                  rankInfo[userRank]['name'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                ),
                const SizedBox(height: 8),
                // Rank description
                Text(
                  rankInfo[userRank]['description'],
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
                    _buildStatCard("Total\nMembers", "$totalMembers",
                        const Color(0xFF4A90E2)),
                    _buildStatCard("Current\nRank", "${userRank + 1}/7",
                        rankInfo[userRank]['color']),
                    _buildStatCard("Active\nReferrals", "$currentReferrals",
                        const Color(0xFF2EBD85)),
                  ],
                ),

                // Progress to next rank
                if (userRank < 6) ...[
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Progress to ${rankInfo[userRank + 1]['name']}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: fontFamily,
                        ),
                      ),
                      Text(
                        "$currentReferrals/$nextRankRequirement referrals",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      Container(
                        height: 10,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      Container(
                        height: 10,
                        width: MediaQuery.of(context).size.width *
                            progressPercentage *
                            0.9,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              rankInfo[userRank]['color'],
                              rankInfo[userRank + 1]['color'],
                            ],
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userRank < 6
                        ? "Need ${nextRankRequirement - currentReferrals} more referrals to reach ${rankInfo[userRank + 1]['name']}"
                        : "You've reached the highest rank!",
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 12,
                      fontFamily: fontFamily,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Current rank benefits
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2329),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: rankInfo[userRank]['color'].withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFFF0B90B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.card_giftcard,
                        color: Color(0xFFF0B90B),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Text(
                        "Your Rank Benefits",
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...List.generate(
                  rankInfo[userRank]['benefits'].length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFFF0B90B),
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          rankInfo[userRank]['benefits'][index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0E11),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Requirements:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontFamily,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rankInfo[userRank]['requirements'],
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
            ),
          ),

          // Rank levels title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF0B90B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(0xFFF0B90B),
                      )),
                  child: const Icon(
                    Icons.leaderboard,
                    color: Color(0xFFF0B90B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "All Rank Levels",
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

          // Rank levels
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rankInfo.length,
            itemBuilder: (context, i) {
              bool isCurrentRank = i == userRank;
              bool isLocked = i > userRank;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isCurrentRank
                      ? Color(0xFFF0B90B).withOpacity(0.9)
                      : const Color(0xFF1E2329),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isCurrentRank ? Colors.white : const Color(0xFF2A3A5A),
                  ),
                ),
                child: ListTile(
                  leading: Stack(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: rankInfo[i]['color']
                              .withOpacity(isLocked ? 0.1 : 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: rankInfo[i]['color']
                                .withOpacity(isLocked ? 0.3 : 1.0),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          rankInfo[i]['icon'],
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      if (isCurrentRank)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2EBD85),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF0B0E11),
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 8,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Row(
                    children: [
                      Text(
                        rankInfo[i]['name'],
                        style: TextStyle(
                          color: isLocked
                              ? Colors.white.withOpacity(0.5)
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontFamily,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isCurrentRank)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: rankInfo[i]['color'].withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "CURRENT",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    rankInfo[i]['description'],
                    style: TextStyle(
                      color: isLocked
                          ? Colors.white.withOpacity(0.3)
                          : Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontFamily: fontFamily,
                    ),
                  ),
                  trailing: isLocked
                      ? const Icon(
                          Icons.lock,
                          color: Colors.white24,
                          size: 16,
                        )
                      : Icon(
                          Icons.check_circle,
                          color: rankInfo[i]['color'],
                          size: 16,
                        ),
                  onTap: () {
                    _showRankDetails(i);
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showRankDetails(int rankIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2329),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        bool isCurrentRank = rankIndex == 0; // For demo purposes
        bool isLocked = rankIndex > 0; // For demo purposes

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: rankInfo[rankIndex]['color'].withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: rankInfo[rankIndex]['color'],
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      rankInfo[rankIndex]['icon'],
                      color: rankInfo[rankIndex]['color'],
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rankInfo[rankIndex]['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontFamily,
                        ),
                      ),
                      Text(
                        rankInfo[rankIndex]['description'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFF2A3A5A)),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Benefits",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ...List.generate(
                rankInfo[rankIndex]['benefits'].length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: rankInfo[rankIndex]['color'],
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        rankInfo[rankIndex]['benefits'][index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B0E11),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Requirements:",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rankInfo[rankIndex]['requirements'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0B90B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
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
}
