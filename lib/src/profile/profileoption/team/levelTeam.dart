import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/src/profile/profileoption/Team/teamdetail.dart';
import 'package:securetradeai/data/strings.dart';
import '../../../../Data/Api.dart';
import '../../../Service/assets_service.dart';

class LevelTeam extends StatefulWidget {
  const LevelTeam({Key? key, this.image}) : super(key: key);
  final image;
  @override
  _LevelTeamState createState() => _LevelTeamState();
}

class _LevelTeamState extends State<LevelTeam> {
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
  int level11 = 0;
  int level12 = 0;
  int level13 = 0;
  int level14 = 0;
  int level15 = 0;

  @override
  void initState() {
    super.initState();
    _getTeam();
  }

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
            if (element["level"] == "Level 1") {
              setState(() => level1++);
            }
            if (element["level"] == "Level 2") {
              setState(() => level2++);
            }
            if (element["level"] == "Level 3") {
              setState(() => level3++);
            }
            if (element["level"] == "Level 4") {
              setState(() => level4++);
            }
            if (element["level"] == "Level 5") {
              setState(() => level5++);
            }
            if (element["level"] == "Level 6") {
              setState(() => level6++);
            }
            if (element["level"] == "Level 7") {
              setState(() => level7++);
            }
            if (element["level"] == "Level 8") {
              setState(() => level8++);
            }
            if (element["level"] == "Level 9") {
              setState(() => level9++);
            }
            if (element["level"] == "Level 10") {
              setState(() => level10++);
            }
            if (element["level"] == "Level 11") {
              setState(() => level11++);
            }
            if (element["level"] == "Level 12") {
              setState(() => level12++);
            }
            if (element["level"] == "Level 13") {
              setState(() => level13++);
            }
            if (element["level"] == "Level 14") {
              setState(() => level14++);
            }
            if (element["level"] == "Level 15") {
              setState(() => level15++);
            }
          }
          if (mounted) {
            setState(() {
              teamData = data['data'];
              isAPIcalled = false;
            });
          }
          print(teamData);
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
      print(e);
      setState(() {
        isAPIcalled = false;
      });
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      body: isAPIcalled
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF0B90B)))
          : checkdata
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/img/logo.png", height: 120),
                      const SizedBox(height: 20),
                      const Text(
                        "No team members found",
                        style: TextStyle(color: Colors.white70, fontSize: 16, fontFamily: fontFamily),
                      ),
                    ],
                  ),
                )
              : _getalevelTeam(),
    );
  }

  Widget _getalevelTeam() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2329),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A3A5A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Referral Network",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "View your team members across different levels",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontFamily: fontFamily,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard("Total Members", "${level1 + level2 + level3 + level4 + level5 + level6 + level7 + level8 + level9 + level10 + level11 + level12 + level13 + level14 + level15}"),
                    _buildStatCard("Direct Referrals", "$level1"),
                    _buildStatCard("Active Members", "${teamData.where((e) => e['days_bal'] != "0").length}"),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2329),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2A3A5A)),
            ),
            child: ListTile(
              onTap: () {
                _goToDetailPage("1");
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
              title: const Text(
                "Level 1",
                style: TextStyle(color: Colors.white, fontFamily: fontFamily, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Total: ${level1}",
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
                  style: TextStyle(color: Color(0xFFF0B90B), fontWeight: FontWeight.bold, fontFamily: fontFamily),
                ),
              ),
            ),
          ),
          ListTile(
              onTap: () {
                _goToDetailPage("2");
              },
              leading: CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(
                  widget.image == null
                      ? imagepath + "default.jpg"
                      : imagepath + widget.image,
                ),
              ),
              title: const Text(
                "Level 2",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "Total " + level2.toString(),
                style: TextStyle(color: Colors.white),
              ),
              trailing: const Text(
                "View",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
          ListTile(
              onTap: () {
                _goToDetailPage("3");
              },
              leading: CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(
                  widget.image == null
                      ? imagepath + "default.jpg"
                      : imagepath + widget.image,
                ),
              ),
              title: const Text(
                "Level 3",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "Total " + level3.toString(),
                style: TextStyle(color: Colors.white),
              ),
              trailing: const Text(
                "View",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
          ListTile(
              onTap: () {
                _goToDetailPage("4");
              },
              leading: CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(
                  widget.image == null
                      ? imagepath + "default.jpg"
                      : imagepath + widget.image,
                ),
              ),
              title: const Text(
                "Level 4",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "Total " + level4.toString(),
                style: TextStyle(color: Colors.white),
              ),
              trailing: const Text(
                "View",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
          ListTile(
              onTap: () {
                _goToDetailPage("5");
              },
              leading: CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(
                  widget.image == null
                      ? imagepath + "default.jpg"
                      : imagepath + widget.image,
                ),
              ),
              title: const Text(
                "Level 5",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "Total " + level5.toString(),
                style: TextStyle(color: Colors.white),
              ),
              trailing: const Text(
                "View",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
          ListTile(
              onTap: () {
                _goToDetailPage("6");
              },
              leading: CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(
                  widget.image == null
                      ? imagepath + "default.jpg"
                      : imagepath + widget.image,
                ),
              ),
              title: const Text(
                "Level 6",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "Total " + level6.toString(),
                style: TextStyle(color: Colors.white),
              ),
              trailing: const Text(
                "View",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
          ListTile(
              onTap: () {
                _goToDetailPage("7");
              },
              leading: CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(
                  widget.image == null
                      ? imagepath + "default.jpg"
                      : imagepath + widget.image,
                ),
              ),
              title: const Text(
                "Level 7",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "Total " + level7.toString(),
                style: TextStyle(color: Colors.white),
              ),
              trailing: const Text(
                "View",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
          ListTile(
              onTap: () {
                _goToDetailPage("8");
              },
              leading: CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(
                  widget.image == null
                      ? imagepath + "default.jpg"
                      : imagepath + widget.image,
                ),
              ),
              title: const Text(
                "Level 8",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "Total " + level8.toString(),
                style: TextStyle(color: Colors.white),
              ),
              trailing: const Text(
                "View",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
          ListTile(
              onTap: () {
                _goToDetailPage("9");
              },
              leading: CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(
                  widget.image == null
                      ? imagepath + "default.jpg"
                      : imagepath + widget.image,
                ),
              ),
              title: const Text(
                "Level 9",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "Total " + level9.toString(),
                style: TextStyle(color: Colors.white),
              ),
              trailing: const Text(
                "View",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
          ListTile(
              onTap: () {
                _goToDetailPage("10");
              },
              leading: CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(
                  widget.image == null
                      ? imagepath + "default.jpg"
                      : imagepath + widget.image,
                ),
              ),
              title: const Text(
                "Level 10",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "Total " + level10.toString(),
                style: TextStyle(color: Colors.white),
              ),
              trailing: const Text(
                "View",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
          ListTile(
              onTap: () {
                _goToDetailPage("11");
              },
              leading: CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(
                  widget.image == null
                      ? imagepath + "default.jpg"
                      : imagepath + widget.image,
                ),
              ),
              title: const Text(
                "Level 11",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "Total " + level11.toString(),
                style: TextStyle(color: Colors.white),
              ),
              trailing: const Text(
                "View",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
          ListTile(
              onTap: () {
                _goToDetailPage("12");
              },
              leading: CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(
                  widget.image == null
                      ? imagepath + "default.jpg"
                      : imagepath + widget.image,
                ),
              ),
              title: const Text(
                "Level 12",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "Total " + level12.toString(),
                style: TextStyle(color: Colors.white),
              ),
              trailing: const Text(
                "View",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
          ListTile(
              onTap: () {
                _goToDetailPage("13");
              },
              leading: CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(
                  widget.image == null
                      ? imagepath + "default.jpg"
                      : imagepath + widget.image,
                ),
              ),
              title: const Text(
                "Level 13",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "Total " + level13.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              trailing: const Text(
                "View",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
          ListTile(
              onTap: () {
                _goToDetailPage("14");
              },
              leading: CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(
                  widget.image == null
                      ? imagepath + "default.jpg"
                      : imagepath + widget.image,
                ),
              ),
              title: const Text(
                "Level 14",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "Total " + level14.toString(),
                style: TextStyle(color: Colors.white),
              ),
              trailing: const Text(
                "View",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
          ListTile(
              onTap: () {
                _goToDetailPage("15");
              },
              leading: CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(
                  widget.image == null
                      ? imagepath + "default.jpg"
                      : imagepath + widget.image,
                ),
              ),
              title: const Text(
                "Level 15",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "Total " + level15.toString(),
                style: TextStyle(color: Colors.white),
              ),
              trailing: const Text(
                "View",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
        ],
      ),
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
            builder: (context) => TeamDetail(
                  data: data,
                  level: level.toString(),
                )));
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
        color: const Color(0xFF0B0E11).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3)),
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
              color: accentColor,
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

  Widget _buildEarningsButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2EBD85), Color(0xFF26A17B)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2EBD85).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children:const [
          Text(
            "View Details",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
            ),
          ),
          SizedBox(width: 8),
          Icon(
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
}
