import 'dart:async';
import 'dart:developer';
import 'package:securetradeai/data/strings.dart';
import 'package:flutter/material.dart';
import 'package:securetradeai/data/api.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/profile/errorNotification/errorNotificaton.dart';
import 'package:securetradeai/src/profile/profileoption/APIBinding/apibinding.dart';
import 'package:securetradeai/src/profile/profileoption/personalInfo.dart';
import 'package:securetradeai/src/profile/profileoption/securitycenter/security.dart';
import 'package:securetradeai/src/profile/profileoption/share/share.dart';
import 'package:securetradeai/src/profile/profileoption/Team/team.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../method/methods.dart';
import '../user/login.dart';
import '../profile/profileoption/assets/assets.dart';
import '../profile/profileoption/assets/deposit_transaction.dart';
import 'profileoption/Transaction/payment_section.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var minedata = [];
  bool isAPIcalle = false;
  var rem;
  var finalData;

  Future<void> _launchURL() async {
    const url = 'https://t.me/your_chat_link';
    final Uri uri = Uri.parse(url);

    // Use the new url_launcher API
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  _getData() async {
    try {
      print("🔍 Profile: Starting data fetch for user ID: $commonuserId");

      if (commonuserId == null || commonuserId.isEmpty) {
        print("❌ Profile: User ID is null or empty!");
        showtoast("User ID not found. Please login again.", context);
        return;
      }

      setState(() {
        isAPIcalle = true;
      });

      final data = await CommonMethod().getMineData();
      print("📥 Profile: API response status: ${data.status}");
      print("📥 Profile: API response message: ${data.message}");

      if (data.status == "success") {
        print("✅ Profile: Data received successfully");
        setState(() {
          minedata = data.data;
          for (var e in minedata) {
            finalData = e;
          }
          isAPIcalle = false;
        });
      } else {
        print("❌ Profile: API returned error: ${data.message}");
        setState(() {
          isAPIcalle = false;
        });
        showtoast(data.message, context);
      }
    } catch (e) {
      print("❌ Profile: Exception occurred: ${e.toString()}");
      if (mounted) {
        setState(() {
          isAPIcalle = false;
        });
        showtoast("Error loading profile data: ${e.toString()}", context);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2234),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E293B),
                    Color(0xFF1A2234),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF2A3A5A),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF4A90E2),
                          Color(0xFF2A3A5A),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A90E2).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Account Overview",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontFamily: fontFamily,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          finalData?.name ?? "User",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontFamily,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          finalData?.email ?? "",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontFamily: fontFamily,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1E293B),
                          Color(0xFF1A2234),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF2A3A5A),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                      child: Column(
                    children: [
                        _buildMenuItem(
                          icon: Icons.account_balance_wallet,
                          title: "Gas Balance",
                          subtitle: isAPIcalle
                              ? "Loading..."
                              : "${finalData?.balance ?? "0.0"} USD",
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (context) => DepositTransaction(),
                              ),
                            );
                          },
                        ),
                        const Divider(
                          color: Color(0xFF2A3A5A),
                          height: 1,
                        ),
                        _buildMenuItem(
                          icon: Icons.attach_money,
                          title: "Earning Balance",
                          subtitle: isAPIcalle
                              ? "Loading..."
                              : "${finalData?.incomeBalance ?? "0.0"} USD",
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Assets(),
                              ),
                            );
                          },
                                        ),
                                      ],
                                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1E293B),
                          Color(0xFF1A2234),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF2A3A5A),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.person,
                          title: "Personal Info",
                          subtitle: "Manage your account details",
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PersonalInfo(),
                              ),
                            );
                          },
                        ),
                        const Divider(
                          color: Color(0xFF2A3A5A),
                          height: 1,
                        ),
                        _buildMenuItem(
                          icon: Icons.security,
                          title: "Security Center",
                          subtitle: "Manage your security settings",
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (context) => const SystemCenter(),
                              ),
                            );
                          },
                        ),
                        const Divider(
                          color: Color(0xFF2A3A5A),
                          height: 1,
                        ),
                        _buildMenuItem(
                          icon: Icons.api,
                          title: "API Binding",
                          subtitle: "Manage your API keys",
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (context) => const ApiBinding(),
                              ),
                            );
                          },
                        ),
                        const Divider(
                          color: Color(0xFF2A3A5A),
                          height: 1,
                        ),
                        _buildMenuItem(
                          icon: Icons.history,
                          title: "Transaction History",
                          subtitle: "View your transaction records",
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (context) => const PaymentSection(),
                              ),
                            );
                          },
                        ),
                        const Divider(
                          color: Color(0xFF2A3A5A),
                          height: 1,
                        ),
                        _buildMenuItem(
                          icon: Icons.share,
                          title: "Share",
                          subtitle: "Share with friends",
                          onTap: () {
                            log(finalData.toString());
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Sharescreen(
                                  reffral: finalData?.referralCode ?? "",
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(
                          color: Color(0xFF2A3A5A),
                          height: 1,
                        ),
                        _buildMenuItem(
                          icon: Icons.people,
                          title: "My Team",
                          subtitle: "View your referral network",
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (context) => Team(
                                  image: finalData?.image,
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(
                          color: Color(0xFF2A3A5A),
                          height: 1,
                        ),
                        _buildMenuItem(
                          icon: Icons.support,
                          title: "Support",
                          subtitle: "Get help and support",
                          onTap: _launchURL,
                        ),
                        const Divider(
                          color: Color(0xFF2A3A5A),
                          height: 1,
                        ),
                        _buildMenuItem(
                          icon: Icons.error,
                          title: "Error Notification",
                          subtitle: "View error notifications",
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (context) => const ErrorNotification(),
                              ),
                            );
                          },
                        ),
                        const Divider(
                          color: Color(0xFF2A3A5A),
                          height: 1,
                        ),
                        _buildMenuItem(
                          icon: Icons.logout,
                          title: "Logout",
                          subtitle: "Sign out of your account",
                        onTap: () async {
                            SharedPreferences pref = await SharedPreferences.getInstance();
                          pref.remove("emailorpass");
                          pref.remove("password");
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A3A5A).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF4A90E2),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
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
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget setPage(data) {
    Color red800 = bg;
    return Stack(
      children: <Widget>[
        Container(
          // Background
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 10),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PersonalInfo()));
              },
              leading: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 23.0,
                backgroundImage: isAPIcalle
                    ? const NetworkImage(imagepath + "default.jpg")
                    : data.image == null
                        ? const NetworkImage(imagepath + "default.jpg")
                        : NetworkImage(imagepath + data.image),
              ),
              title: Text(
                isAPIcalle
                    ? "Loading.."
                    : (data.name == "" || data.name == null)
                        ? "Admin"
                        : data.name,
                style: const TextStyle(
                    fontFamily: fontFamily, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                isAPIcalle ? "Loading.." : data.email,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: fontFamily,
                ),
              ),
              trailing: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.arrow_right,
                  )),
            ),
            Container(
              height: 70.0,
              child: Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                      child: Image.asset(
                    "assets/img/vip.png",
                    color: Colors.white,
                  )),
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 15),
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text(
                            "View Permission",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily),
                          ),
                          isAPIcalle
                              ? const Text(
                                  "Loading",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: fontFamily),
                                )
                              : data.verify == "1"
                                  ? const Text(
                                      "Active",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: fontFamily),
                                    )
                                  : const Text(
                                      "InActive",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: fontFamily),
                                    )
                        ],
                      ),
                    ),
                  ),
                ],
              )),
              decoration: BoxDecoration(
                color: securetradeaicolor.withOpacity(0.7),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30.0)),
              ),
            ),
          ]),
          color: red800,
          // height: MediaQuery.of(context).size.height * 0.2,
          width: MediaQuery.of(context).size.width,
        ),
      ],
    );
  }
}
