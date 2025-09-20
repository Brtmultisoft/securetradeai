import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rapidtradeai/Data/Api.dart';
import 'package:rapidtradeai/data/strings.dart';
import 'package:rapidtradeai/src/tabscreen/tabscreen.dart';
import 'package:rapidtradeai/src/user/login.dart';
import 'package:rapidtradeai/src/versionpopup/popupdesign.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _fadeAnimation;

// TradingView inspired colors
  final Color _backgroundColor = const Color(0xFF131722);
  final Color _primaryColor = const Color(0xFF03DAC6);
  final Color _secondaryColor = const Color(0xFF787B86);
  final Color _textColor = const Color(0xFFD1D4DC);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    // Check authentication state after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _checkAuthenticationState();
    });
  }

  // Check if user is already logged in
  Future<void> _checkAuthenticationState() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();

      // Check if login credentials are stored
      if (pref.containsKey('emailorpass') && pref.containsKey('password')) {
        String emailormobile = pref.getString('emailorpass').toString();
        String passwordvalue = pref.getString('password').toString();

        print('🔍 Found stored credentials, attempting auto-login...');

        // Attempt auto-login with stored credentials
        bool loginSuccess = await _attemptAutoLogin(emailormobile, passwordvalue);

        if (loginSuccess) {
          print('✅ Auto-login successful, navigating to home');
          return; // Navigation handled in _attemptAutoLogin
        } else {
          print('❌ Auto-login failed, navigating to login page');
          _navigateToLogin();
        }
      } else {
        print('ℹ️ No stored credentials found, navigating to login page');
        _navigateToLogin();
      }
    } catch (e) {
      print('❌ Error checking authentication state: $e');
      _navigateToLogin();
    }
  }

  // Attempt to login with stored credentials
  Future<bool> _attemptAutoLogin(String mobile, String password) async {
    try {
      var bodydata = jsonEncode({
        "mobile": mobile,
        "password": password,
        "type": "Normal"
      });

      final response = await http
          .post(
            Uri.parse(loginUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'User-Agent': 'rapidtradeai-Mobile-App',
            },
            body: bodydata,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Update global variables
          setState(() {
            commonuserId = data['data']['user_id'];
            commonEmail = data['data']['email'];
          });

          // Navigate to home screen
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Tabscreen(
                  reffral: data['data']['referral_code'],
                ),
              ),
            );
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      print('❌ Auto-login error: $e');
      return false;
    }
  }

  // Navigate to login page
  void _navigateToLogin() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // Animated background elements
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(animation: _controller),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animation.value,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _backgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            "assets/img/logo.png",
                            width: 150,
                            height: 150,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    "Rapid Trade AI",
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    "Professional Trading Platform",
                    style: TextStyle(
                      color: _primaryColor,
                      fontSize: 18,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  width: 250,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      backgroundColor: _backgroundColor,
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                      minHeight: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final Animation<double> animation;

  BackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2962FF).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.3 + (animation.value * 50),
      size.width,
      size.height * 0.3,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
