import 'package:flutter/material.dart';
import 'package:securetradeai/Data/Api.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';

class EnhancedTeamDetailArbitrade extends StatefulWidget {
  const EnhancedTeamDetailArbitrade({Key? key, required this.data, this.level})
      : super(key: key);
  final List data;
  final level;
  @override
  EnhancedTeamDetailArbitradeState createState() => EnhancedTeamDetailArbitradeState();
}

class EnhancedTeamDetailArbitradeState extends State<EnhancedTeamDetailArbitrade> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: CommonAppBar.basic(
        title: widget.level == null ? "" : "Level ${widget.level}",
      ),
      body: widget.data.isEmpty ? _buildEmptyState() : _buildTeamList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/img/logo.png", height: 120),
          const SizedBox(height: 20),
          const Text(
            "No team members found at this level",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Share your invite code to grow your network",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamList() {
    // Debug print to see the data structure
    print("Team data: ${widget.data}");

    // Calculate statistics
    int totalMembers = widget.data.length;
    int activeMembers = widget.data.where((e) {
      try {
        return int.parse(e['days_bal'] != null
                ? e['days_bal'].toString()
                : e['days'].toString()) >
            0;
      } catch (error) {
        print("Error parsing days: $error");
        return false;
      }
    }).length;
    int inactiveMembers = totalMembers - activeMembers;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header with level info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFF0B90B),
            ),
            child: Column(
              children: [
                // Level icon with glow effect
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
                  child: Text(
                    widget.level.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontFamily,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Level title
                Text(
                  "Level ${widget.level} Members",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                ),
                const SizedBox(height: 8),
                // Level subtitle
                Text(
                  "Members in your network at level ${widget.level}",
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
                    _buildStatCard("Total\nMembers", "$totalMembers",
                        const Color(0xFF4A90E2)),
                    _buildStatCard("Active\nMembers", "$activeMembers",
                        const Color(0xFF2EBD85)),
                    _buildStatCard("Inactive\nMembers", "$inactiveMembers",
                        const Color(0xFFE57373)),
                  ],
                ),
              ],
            ),
          ),

          // Member list title
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
                  "Member List",
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

          // Member list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.data.length,
            itemBuilder: (context, i) {
              bool isActive = int.parse(widget.data[i]['days_bal'] != null
                      ? widget.data[i]['days_bal'].toString()
                      : widget.data[i]['days'].toString()) >
                  0;
              String memberRank = widget.data[i]['rank'] != null
                  ? widget.data[i]['rank'].toString()
                  : "0";
              String memberEmail = widget.data[i]['email'] != null
                  ? widget.data[i]['email'].toString()
                  : "";
              String memberPhoneNumber = widget.data[i]['mobile'] != null
                  ? widget.data[i]['mobile'].toString()
                  : "";

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2329),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2A3A5A)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 24.0,
                            backgroundColor: const Color(0xFF0B0E11),
                            backgroundImage: widget.data[i]['image'] != null &&
                                    widget.data[i]['image'] != "default.jpg"
                                ? NetworkImage(
                                    "${imagepath}${widget.data[i]['image']}")
                                : null,
                            child: widget.data[i]['image'] == null ||
                                    widget.data[i]['image'] == "default.jpg"
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 24,
                                  )
                                : null,
                          ),
                          if (isActive)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2EBD85),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF0B0E11),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.data[i]['name'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (memberRank != "0")
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                _getRankColor(memberRank).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getRankName(memberRank),
                                style: TextStyle(
                                  color: _getRankColor(memberRank),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: fontFamily,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Show rank for all levels
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "Rank: ${_getRankName(memberRank)}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                fontFamily: fontFamily,
                              ),
                            ),
                          ),
                          // // Show commission for all levels
                          // Padding(
                          //   padding: const EdgeInsets.only(top: 4),
                          //   child: Text(
                          //     "Commission: ${_getCommissionRate(widget.level)}%",
                          //     style: TextStyle(
                          //       color: Colors.white.withOpacity(0.7),
                          //       fontSize: 12,
                          //       fontFamily: fontFamily,
                          //     ),
                          //   ),
                          // ),
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
                              isActive ? Icons.check_circle : Icons.cancel,
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
                      onTap: () {
                        _showMemberDetails(widget.data[i]);
                      },
                    ),
                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 80,  bottom: 12),
                      child: Row(

                        children: [
                          _buildMiniActionButton("Details", Icons.info_outline,
                              const Color(0xFF4A90E2), () {
                                _showMemberDetails(widget.data[i]);
                              }),
                          // const SizedBox(width: 8),
                          // if (widget.data[i]['mobile'] != null)
                          //   _buildMiniActionButton("Call", Icons.call, const Color(0xFF2EBD85), () {}),
                          // const SizedBox(width: 8),
                          // _buildMiniActionButton("Message", Icons.message, const Color(0xFFF0B90B), () {}),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Info card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2329),
              borderRadius: BorderRadius.circular(12),
              border:
              Border.all(color: const Color(0xFF4A90E2).withOpacity(0.3)),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Color(0xFF4A90E2),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Text(
                        "About Level Rewards",
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
                  "Level ${widget.level} members help you unlock earnings every time they trade. The bigger your network, the greater your rewards \nkeep climbing!",
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
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

  void _showMemberDetails(Map<String, dynamic> member) {
    // Debug print to see what data we're getting


    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2329),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Safely extract values with proper null checks and defaults
        bool isActive = false;
        try {
          String daysValue = member['days_bal'] != null
              ? member['days_bal'].toString()
              : (member['days'] != null ? member['days'].toString() : "0");
          isActive = int.parse(daysValue) > 0;
        } catch (e) {
          print("Error parsing days: $e");
        }

        // Extract all member details with proper null checks
        String memberName =
        member['name'] != null ? member['name'].toString() : "Unknown";
        String memberRank =
        member['rank'] != null ? member['rank'].toString() : "0";
        // String memberEmail =
        //     member['email'] != null ? member['email'].toString() : "";
        String memberMobile =
        member['mobile'] != null ? member['mobile'].toString() : "";

        String total_investment =
        member['total_investment'] != null ? member['total_investment'].toString() : "";
        // String memberGender = member['gender'] != null
        //     ? member['gender'].toString()
        //     : "Not specified";
        //     : "Not specified";Search
        String memberId =
        member['user_id'] != null ? member['user_id'].toString() : "";
        String memberUId =
        member['uid'] != null ? member['uid'].toString() : "N/A";

        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.65,
          child: SingleChildScrollView(
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
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50.0,
                      backgroundColor: const Color(0xFF0B0E11),
                      backgroundImage: member['image'] != null &&
                          member['image'] != "default.jpg"
                          ? NetworkImage("${imagepath}${member['image']}")
                          : null,
                      child: member['image'] == null ||
                          member['image'] == "default.jpg"
                          ? const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 50,
                      )
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF2EBD85)
                            : const Color(0xFFE57373),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF1E2329), width: 2),
                      ),
                      child: Icon(
                        isActive ? Icons.check : Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  memberName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                ),
                // if (memberEmail.isNotEmpty)
                //   Padding(
                //     padding: const EdgeInsets.only(top: 4),
                //     child: Text(
                //       memberEmail,
                //       style: TextStyle(
                //         color: Colors.white.withOpacity(0.7),
                //         fontSize: 14,
                //         fontFamily: fontFamily,
                //       ),
                //     ),
                //   ),
                const SizedBox(height: 12),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF2EBD85).withOpacity(0.1)
                        : const Color(0xFFE57373).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? "Active Member" : "Inactive Member",
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFF2EBD85)
                          : const Color(0xFFE57373),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: fontFamily,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Member details section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0E11),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A3A5A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Member Details",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontFamily,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Show only UID, Rank, and Commission for all levels
                      _buildDetailRow("User UID", memberUId, Icons.badge),
                      // const Divider(color: Color(0xFF2A3A5A)),

                      if (widget.level == "1") ...[
                        const Divider(color: Color(0xFF2A3A5A)),
                        _buildDetailRow("Mobile Number", memberMobile, Icons.phone),
                        // const Divider(color: Color(0xFF2A3A5A)),
                      ],
                      const Divider(color: Color(0xFF2A3A5A)),
                      _buildDetailRow("Rank", _getRankName(memberRank),
                          Icons.military_tech),
                      const Divider(color: Color(0xFF2A3A5A)),const Divider(color: Color(0xFF2A3A5A)),
                      _buildDetailRow("Total Investment", total_investment,
                          Icons.military_tech),

                      // const Divider(color: Color(0xFF2A3A5A), height: 24),
                      // _buildDetailRow(
                      //     "Commission Rate",
                      //     "${_getCommissionRate(widget.level)}%",
                      //     Icons.attach_money),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // // Action buttons
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     _buildActionButton(
                //         "Message", Icons.message, const Color(0xFF4A90E2)),
                //     _buildActionButton(
                //         "Call", Icons.call, const Color(0xFF2EBD85)),
                //     _buildActionButton(
                //         "Share", Icons.share, const Color(0xFFF0B90B)),
                //   ],
                // ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFF1E2329),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFFF0B90B),
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: fontFamily,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRankName(String rank) {
    switch (rank) {
      case "0":
        return "One Star";
      case "1":
        return "Two Star";
      case "2":
        return "Three Star";
      case "3":
        return "Four Star";
      case "4":
        return "Diamond";
      case "6":
        return "Five Star";
      default:
        return "Newcomer";
    }
  }

  Color _getRankColor(String rank) {
    switch (rank) {
      case "0":
        return const Color(0xFF78909C); // Grey
      case "1":
        return const Color(0xFFCD7F32); // Bronze
      case "2":
        return const Color(0xFFC0C0C0); // Silver
      case "3":
        return const Color(0xFFFFD700); // Gold
      case "4":
        return const Color(0xFFE5E4E2); // Platinum
      case "5":
        return const Color(0xFF40E0D0); // Diamond
      case "6":
        return const Color(0xFF212121); // Black Diamond
      default:
        return const Color(0xFF78909C); // Grey
    }
  }

  Widget _buildMiniActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberInfoItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFF0B0E11),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFFF0B90B),
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
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
            style: const TextStyle(
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
            style: const TextStyle(
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

  String _getDaysAgo(String days) {
    if (days == "0") return "Recently";
    int daysInt = int.tryParse(days) ?? 0;
    if (daysInt <= 1) return "Today";
    if (daysInt < 7) return "$daysInt days ago";
    if (daysInt < 30) return "${(daysInt / 7).floor()} weeks ago";
    return "${(daysInt / 30).floor()} months ago";
  }

  int _getCommissionRate(String level) {
    int levelInt = int.tryParse(level.toString()) ?? 1;
    switch (levelInt) {
      case 1:
        return 20;
      case 2:
        return 10;
      case 3:
        return 5;
      default:
        return 2;
    }
  }
}
