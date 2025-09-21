import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/widget/lottie_loading_widget.dart';
import 'package:securetradeai/Data/Api.dart';
import 'package:securetradeai/method/methods.dart';
import 'package:securetradeai/model/userRankModel.dart';

class EnhancedRankTeamArbitrade extends StatefulWidget {
  const EnhancedRankTeamArbitrade({Key? key, this.image}) : super(key: key);
  final image;

  @override
  EnhancedRankTeamArbitradeState createState() => EnhancedRankTeamArbitradeState();
}

class EnhancedRankTeamArbitradeState extends State<EnhancedRankTeamArbitrade> {
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

  // User rank data from API
  UserRankModel? _userRankModel;
  int _apiUserRankIndex = 0;

  int _indexFromApiRank(String rank) {
    final normalized = rank.trim().toLowerCase();
    if (normalized.isEmpty || normalized == 'no rank' || normalized == 'norank') {
      return 0;
    }
    // Case-insensitive exact match
    final names = rankInfo.map((e) => (e['name'] as String)).toList();
    final lowerNames = names.map((s) => s.toLowerCase()).toList();
    int idx = lowerNames.indexOf(normalized);

    // Synonyms/legacy labels
    if (idx == -1) {
      final Map<String, String> synonyms = {
        'grand legend': 'Crypto Legend',
        'crown ambassador': 'Crown Ambassador',
        'promotor': 'Promoter',
      };
      final mapped = synonyms[normalized];
      if (mapped != null) {
        idx = names.indexOf(mapped);
      }
    }

    return (idx >= 0 && idx < rankInfo.length) ? idx : 0;
  }

  Future<void> _loadUserRank() async {
    try {
      final data = await CommonMethod().getUserRank();
      if (mounted && data.status == 'success') {
        setState(() {
          _userRankModel = data;
          _apiUserRankIndex = _indexFromApiRank(data.data.currentRank);
        });
      }
    } catch (e) {
      // Keep defaults on error
    }
  }

  final List<Map<String, dynamic>> rankInfo = [
    {
      'name': 'No Rank',
      'description': 'New to the platform',
      'color': Colors.white,
      'icon': Icons.star_border,
      'benefits': ['Basic trading features', 'Standard support'],
      'requirements': 'No requirements',
    },
    {
      'name': 'Promoter',
      'description': 'Starting your journey',
      'color': const Color(0xFF4A90E2),
      'icon': Icons.star_border,
      'benefits': ['Basic trading features', 'Standard support'],
      'requirements': 'Team Business: \$10,000',
      'teamBusiness': '\$10,000',
      'salaryIncome': '\$25 Monthly',
      'remark': 'for 12 Months',
    },
    {
      'name': 'Builder',
      'description': 'Building your network',
      'color': const Color(0xFF2EBD85),
      'icon': Icons.build,
      'benefits': ['Enhanced trading features', 'Priority support'],
      'requirements': 'Team Business: \$20,000',
      'teamBusiness': '\$20,000',
      'salaryIncome': '\$50 Monthly',
      'remark': 'for 12 Months',
    },
    {
      'name': 'Leader',
      'description': 'Leading your team',
      'color': const Color(0xFFCD7F32),
      'icon': Icons.workspace_premium,
      'benefits': ['5% trading fee discount', 'VIP support'],
      'requirements': 'Team Business: \$50,000',
      'teamBusiness': '\$50,000',
      'salaryIncome': '\$125 Monthly',
      'remark': 'for 12 Months',
    },
    {
      'name': 'Manager',
      'description': 'Managing operations',
      'color': const Color(0xFFC0C0C0),
      'icon': Icons.manage_accounts,
      'benefits': ['10% trading fee discount', 'Advanced analytics', 'Weekly reports'],
      'requirements': 'Team Business: \$100,000',
      'teamBusiness': '\$100,000',
      'salaryIncome': '\$300 Monthly',
      'remark': 'for 12 Months',
    },
    {
      'name': 'Director',
      'description': 'Directing growth',
      'color': const Color(0xFFFFD700),
      'icon': Icons.star,
      'benefits': [
        '15% trading fee discount',
        'Dedicated account manager',
        'Premium tools'
      ],
      'requirements': 'Team Business: \$200,000',
      'teamBusiness': '\$200,000',
      'salaryIncome': '\$600 Monthly',
      'remark': 'for 12 Months',
    },
    {
      'name': 'Executive',
      'description': 'Executive level',
      'color': const Color(0xFFE5E4E2),
      'icon': Icons.diamond,
      'benefits': [
        '20% trading fee discount',
        'Exclusive events access',
        'Executive privileges'
      ],
      'requirements': 'Team Business: Executive',
      'teamBusiness': 'Executive',
      'salaryIncome': '\$1500 Monthly',
      'remark': 'for 12 Months',
    },
    {
      'name': 'Crown Ambassador',
      'description': 'Crown level achievement',
      'color': const Color(0xFF9C27B0),
      'icon': Icons.emoji_events,
      'benefits': [
        '25% trading fee discount',
        'Crown privileges',
        'Ambassador status'
      ],
      'requirements': 'Team Business: \$1,000,000',
      'teamBusiness': '\$1,000,000',
      'salaryIncome': '\$4000 Monthly',
      'remark': 'for 12 Months',
    },
    {
      'name': 'Crypto Legend',
      'description': 'Legendary status',
      'color': const Color(0xFFFF5722),
      'icon': Icons.military_tech,
      'benefits': [
        '30% trading fee discount',
        'Legend privileges',
        'Ultimate status'
      ],
      'requirements': 'Team Business: \$2,000,000',
      'teamBusiness': '\$2,000,000',
      'salaryIncome': '\$10,000 Monthly',
      'remark': 'for 12 Months',
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
    _loadUserRank();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      body: isAPIcalled
          ? const Center(
              child: LottieLoadingWidget.large(),
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
    // Calculate total members for display only
    int totalMembers = p0 + p1 + p2 + p3 + p4 + p5 + p6;

    // Determine user's current rank from API
    int userRank = _apiUserRankIndex;

    // Progress/requirements come from API; not computed locally

    int currentReferrals = totalMembers;

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
                    _buildStatCard("Current\nRank", "${userRank + 1}/${rankInfo.length}",
                        rankInfo[userRank]['color']),
                    _buildStatCard("Active\nReferrals", "$currentReferrals",
                        const Color(0xFF2EBD85)),
                  ],
                ),

                // Progress to next rank
                // if (userRank < 6) ...[
                //   // const SizedBox(height: 30),
                //   // Row(
                //   //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   //   children: [
                //   //     Text(
                //   //       "Progress to ${rankInfo[userRank + 1]['name']}",
                //   //       style: const TextStyle(
                //   //         color: Colors.black,
                //   //         fontSize: 14,
                //   //         fontFamily: fontFamily,
                //   //       ),
                //   //     ),
                //   //     Text(
                //   //       "$currentReferrals/$nextRankRequirement referrals",
                //   //       style: const TextStyle(
                //   //         color: Colors.black,
                //   //         fontSize: 14,
                //   //         fontFamily: fontFamily,
                //   //       ),
                //   //     ),
                //   //   ],
                //   // ),
                //   // const SizedBox(height: 10),
                //   // Stack(
                //   //   children: [
                //   //     Container(
                //   //       height: 10,
                //   //       width: double.infinity,
                //   //       decoration: BoxDecoration(
                //   //         color: Colors.white.withOpacity(0.1),
                //   //         borderRadius: BorderRadius.circular(5),
                //   //       ),
                //   //     ),
                //   //     Container(
                //   //       height: 10,
                //   //       width: MediaQuery.of(context).size.width *
                //   //           progressPercentage *
                //   //           0.9,
                //   //       decoration: BoxDecoration(
                //   //         gradient: LinearGradient(
                //   //           colors: [
                //   //             rankInfo[userRank]['color'],
                //   //             rankInfo[userRank + 1]['color'],
                //   //           ],
                //   //         ),
                //   //         borderRadius: BorderRadius.circular(5),
                //   //       ),
                //   //     ),
                //   //   ],
                //   // ),
                //   // const SizedBox(height: 10),
                //   // Text(
                //   //   userRank < 6
                //   //       ? "Need ${nextRankRequirement - currentReferrals} more referrals to reach ${rankInfo[userRank + 1]['name']}"
                //   //       : "You've reached the highest rank!",
                //   //   style: TextStyle(
                //   //     color: Colors.black.withOpacity(0.7),
                //   //     fontSize: 12,
                //   //     fontFamily: fontFamily,
                //   //   ),
                //   // ),
                // ],
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
