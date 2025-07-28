import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/profile/profileoption/Team/enhanced_level_team.dart';
import 'package:securetradeai/src/profile/profileoption/Team/enhanced_rank_team.dart';
import 'package:securetradeai/src/profile/profileoption/Team/enhanced_team_detail.dart';
import 'package:securetradeai/src/profile/profileoption/share/share.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';

import '../../../../Data/Api.dart';

class Team extends StatefulWidget {
  const Team({Key? key, this.image}) : super(key: key);
  final dynamic image;
  @override
  TeamState createState() => TeamState();
}

class TeamState extends State<Team> {
  // Team state variables
  var teamDirect = [];
  bool isAPIcalled = false;
  bool checkdata = false;
  Future _getTeamDirect() async {
    try {
      setState(() {
        isAPIcalled = true;
      });
      final res = await http.post(Uri.parse(teamDetail),
          body: jsonEncode({"user_id": commonuserId}));
      if (res.statusCode != 200) {
        // Store error message
        const errorMsg = "Server Error";
        // Show toast after setState if still mounted
        if (mounted) {
          showtoast(errorMsg, context);
        }
        setState(() {
          isAPIcalled = false;
        });
      } else {
        var data = jsonDecode(res.body);
        // Log API response
        debugPrint("API Response for team direct: ${data['status']}");

        if (data['status'] == "success") {
          var localdata = data['data'] as List;
          teamDirect.clear(); // Clear existing data

          for (var element in localdata) {
            // Check if level exists and is Level 1
            if (element['level'] != null &&
                element['level'].toString() == "Level 1") {
              // Create a complete member object with all available fields
              Map<String, dynamic> memberData = {
                "name": element['name'] ?? "Unknown",
                "days": element['days_bal'] ?? "0",
                "image": element['image'],
                "email": element['email'],
                "mobile": element['mobile'],
                "gender": element['gender'],
                "rank": element['rank'],
                "user_id": element['user_id'],
                "days_bal": element['days_bal'],
                "level": element['level']
              };

              teamDirect.add(memberData);
            }
          }

          setState(() => isAPIcalled = false);
        } else {
          // Store message to show after setState
          final message = data['message'];
          setState(() {
            isAPIcalled = false;
            checkdata = true;
          });
          // Show toast after setState
          if (mounted) {
            showtoast(message, context);
          }
        }
      }
    } catch (e) {
      // Log error
      debugPrint("Error fetching direct team: $e");
      setState(() {
        isAPIcalled = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getTeamDirect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: CommonAppBar.basic(
        title: "My Team".tr,
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF2A3A5A), width: 1),
                ),
              ),
              constraints: const BoxConstraints.expand(height: 50),
              child: TabBar(
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontFamily: fontFamily),
                  labelColor: const Color(0xFFF0B90B),
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: const Color(0xFFF0B90B),
                  tabs: [
                    Tab(text: "Direct Referrals".tr),
                    Tab(text: "Level Network".tr),
                    Tab(text: "Rank Team".tr),
                  ]),
            ),
            Expanded(
              child: TabBarView(children: [
                isAPIcalled
                    ? Center(
                        child: CircularProgressIndicator(
                            color: securetradeaicolor),
                      )
                    : checkdata
                        ? Center(
                            child:
                                Image.asset("assets/img/logo.png", height: 200),
                          )
                        : _getDirect(),
                EnhancedLevelTeam(
                  image: widget.image,
                ),
                EnhancedRankTeam(
                  image: widget.image,
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }

  Widget _getDirect() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero section with stats
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A237E), // Deep blue
                  Color(0xFF0D47A1), // Royal blue
                  Color(0xFF0B0E11), // Dark background
                ],
              ),
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
                    Icons.group,
                    color: Color(0xFFF0B90B),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                // Team title
                const Text(
                  "Direct Referrals",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                ),
                const SizedBox(height: 8),
                // Team subtitle
                Text(
                  "People you've personally invited",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    fontFamily: fontFamily,
                  ),
                ),
                const SizedBox(height: 24),
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard("Total Referrals", "${teamDirect.length}",
                        const Color(0xFF4A90E2)),
                    _buildStatCard(
                        "Active Members",
                        "${teamDirect.where((e) => e['days'] != "0").length}",
                        const Color(0xFF2EBD85)),
                    _buildStatCard(
                        "Inactive",
                        "${teamDirect.where((e) => e['days'] == "0").length}",
                        const Color(0xFFE57373)),
                  ],
                ),
              ],
            ),
          ),

          // Referral list title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0B90B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.people,
                    color: Color(0xFFF0B90B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Your Referrals",
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

          // Referral list
          teamDirect.isEmpty
              ? Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Icon(
                        Icons.people_outline,
                        size: 60,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No referrals yet",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                          fontFamily: fontFamily,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Share your invite code to get started",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                          fontFamily: fontFamily,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: teamDirect.length,
                  itemBuilder: (context, i) {
                    bool isActive = teamDirect[i]['days'] != "0";
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2329),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF2A3A5A)),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              radius: 20.0,
                              backgroundColor: const Color(0xFF0B0E11),
                              backgroundImage: teamDirect[i]['image'] != null &&
                                      teamDirect[i]['image'] != "default.jpg"
                                  ? NetworkImage(
                                      "$imagepath${teamDirect[i]['image']}")
                                  : null,
                              child: teamDirect[i]['image'] == null ||
                                      teamDirect[i]['image'] == "default.jpg"
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  : null,
                            ),
                            title: Text(
                              teamDirect[i]['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (teamDirect[i]['email'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      teamDirect[i]['email'].toString(),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
                                        fontFamily: fontFamily,
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    "Joined ${_getDaysAgo(teamDirect[i]['days'])}",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                      fontFamily: fontFamily,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF2EBD85).withOpacity(0.1)
                                    : const Color(0xFFE57373).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isActive
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: isActive
                                        ? const Color(0xFF2EBD85)
                                        : const Color(0xFFE57373),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isActive ? "Active" : "Inactive",
                                    style: TextStyle(
                                      color: isActive
                                          ? const Color(0xFF2EBD85)
                                          : const Color(0xFFE57373),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      fontFamily: fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Add View Details button
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    // Navigate to team detail page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EnhancedTeamDetail(
                                          data: [teamDirect[i]],
                                          level: teamDirect[i]['level'] != null
                                              ? teamDirect[i]['level']
                                                  .toString()
                                                  .replaceAll('Level ', '')
                                              : '1',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4A90E2)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                          color: const Color(0xFF4A90E2)
                                              .withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          Icons.info_outline,
                                          color: Color(0xFF4A90E2),
                                          size: 14,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          "View Details",
                                          style: TextStyle(
                                            color: Color(0xFF4A90E2),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: fontFamily,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

          // Invite more section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2329),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: const Color(0xFFF0B90B).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0B90B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.card_giftcard,
                        color: Color(0xFFF0B90B),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Text(
                        "Invite More Friends",
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
                const SizedBox(height: 15),
                Text(
                  "Share your invite code with friends and earn up to 40% commission on their trading fees",
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Sharescreen(
                          reffral: commonuserId, // Use user ID as referral code
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
                    child: const Center(
                      child: Text(
                        "Share Invite Code",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E11).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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
              color: color,
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
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  String _getDaysAgo(String days) {
    if (days == "0") return "Recently";
    int daysInt = int.tryParse(days) ?? 0;
    if (daysInt <= 1) return "Today";
    if (daysInt < 7) return "$daysInt days ago";
    if (daysInt < 30) return "${(daysInt / 7).floor()} weeks ago";
    return "${(daysInt / 30).floor()} months ago";
  }
}
