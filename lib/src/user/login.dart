import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;
import 'package:rapidtradeai/Data/Api.dart';
import 'package:rapidtradeai/data/strings.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';
import 'package:rapidtradeai/src/tabscreen/tabscreen.dart';
import 'package:rapidtradeai/src/user/forgotpass.dart';
import 'package:rapidtradeai/src/user/signup.dart';
import 'package:rapidtradeai/src/widget/lottie_loading_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slider_captcha/slider_captcha.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  var userId = TextEditingController();
  var password = TextEditingController();
  bool isAPicalled = false;
  bool _finalisPassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isInitialized = false;

  // Binance theme colors
  final Color _backgroundColor = const Color(0xFF1E2329);
  final Color _cardColor = const Color(0xFF2B3139);
  final Color _primaryColor = const Color(0xFF03DAC6);
  final Color _textColor = const Color(0xFFEAECEF);
  final Color _borderColor = const Color(0xFF474D57);
  final Color _hintColor = const Color(0xFF848E9C);



  @override
  void initState() {
    super.initState();
    _checkLogin();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Initialize all animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Mark as initialized
    _isInitialized = true;

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  _checkLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.containsKey('emailorpass') && pref.containsKey('password')) {
      setState(() {
        botStatus = pref.getString('botstatus').toString();
        emailormobile = pref.getString('emailorpass').toString();
        passwordvalue = pref.getString('password').toString();
        commonuserId = pref.getString('userid').toString();
        commonEmail = pref.getString('userEmail').toString();
        currentCurrency = pref.getString('currentCurrency').toString();
        exchanger = pref.getString('exchanger') ?? "Binance";
      });
      _checkLog(emailormobile, passwordvalue);
    } else {
      if (mounted) {
        setState(() {
          currentCurrency = "USD";
        });
      }
      print('no data');
    }
  }

  _checkLog(String user, pass) async {
    try {
      setState(() {
        isAPicalled = true;
      });

      var bodydata =
          jsonEncode({"mobile": user, "password": pass, "type": "Normal"});

      print('🔍 LOGIN REQUEST: $bodydata'); // Debug logging

      final response = await http
          .post(
            Uri.parse(loginUrl),
            headers: {
              'Content-Type': 'application/json', // FIX: Add required headers
              'Accept': 'application/json',
              'User-Agent': 'rapidtradeai-Mobile-App',
            },
            body: bodydata,
          )
          .timeout(const Duration(seconds: 15)); // FIX: Add timeout

      print(
          '🔍 LOGIN RESPONSE: ${response.statusCode} - ${response.body}'); // Debug logging

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          var data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Tabscreen(
                          reffral: data['data']['referral_code'],
                        )));
          } else {
            showtoast(data['message'] ?? 'Login failed', context);
          }
        } else {
          showtoast("Empty response from server", context);
        }
      } else {
        showtoast("Server Error: ${response.statusCode}",
            context); // FIX: Show actual error code
      }
    } on SocketException {
      showtoast("No internet connection", context);
      print('Socket Exception');
    } on TimeoutException {
      showtoast(
          "Request timeout - server is slow", context); // FIX: Handle timeout
      print('Timeout Exception');
    } catch (e) {
      showtoast(
          "Login error: ${e.toString()}", context); // FIX: Show actual error
      print('LOGIN ERROR: $e');
    } finally {
      setState(() {
        isAPicalled = false;
      });
    }
  }

  Widget _title() {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: Image.asset(
            "assets/img/logo.png",
            height: 200,
            width: 200,
          ),
        ),
        FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            "Welcome Back",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
        ),
        const SizedBox(height: 10),
        FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            "Sign in to continue trading",
            style: TextStyle(
              fontSize: 16,
              color: _hintColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _marketStatItem(String pair, String price, String change, bool isUp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pair,
          style: TextStyle(
            color: _hintColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          price,
          style: TextStyle(
            color: _textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          change,
          style: TextStyle(
            color: isUp ? const Color(0xFF0ECB81) : const Color(0xFFF6465D),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _securityTips() {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.security, color: _primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Security Tips",
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _securityTipItem("Enable 2FA for extra security"),
              _securityTipItem("Never share your API keys"),
              _securityTipItem("Use strong, unique passwords"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _securityTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: _primaryColor, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: _hintColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: InkWell(
          onTap: _showCapChacode,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(vertical: 15),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(
              'login'.tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _backgroundColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailPasswordWidget() {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    return Column(
      children: <Widget>[
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-0.2, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          )),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "userid".tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: _cardColor,
                      border: Border.all(color: _borderColor),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        style: TextStyle(color: _textColor),
                        controller: userId,
                        cursorColor: _primaryColor,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter your email or user id",
                          hintStyle: TextStyle(color: _hintColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.2, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          )),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "loginpassword".tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: _cardColor,
                      border: Border.all(color: _borderColor),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: password,
                        cursorColor: _primaryColor,
                        obscureText: _finalisPassword,
                        style: TextStyle(color: _textColor),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _finalisPassword = !_finalisPassword;
                              });
                            },
                            icon: Icon(
                              _finalisPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: _hintColor,
                            ),
                          ),
                          border: InputBorder.none,
                          hintText: "Enter your password",
                          hintStyle: TextStyle(color: _hintColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * .05),
                  _title(),
                  SizedBox(height: 40),
                  _securityTips(),
                  _emailPasswordWidget(),
                  const SizedBox(height: 20),
                  isAPicalled
                      ? Container(
                          height: 50,
                          child: Center(
                            child: const LottieLoadingWidget.medium(),
                          ),
                        )
                      : _submitButton(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "New here?",
                        style: TextStyle(color: _hintColor),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()),
                          );
                        },
                        child: Text(
                          "Create an Account",
                          style: TextStyle(color: _primaryColor),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPassword()),
                      );
                    },
                    child: Text(
                      "Forgot Password",
                      style: TextStyle(color: _primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (userId.text == "") {
      showtoast("User-Id is empty", context);
    } else if (password.text == "") {
      showtoast("Password is empty", context);
    } else {
      try {
        setState(() {
          isAPicalled = true;
        });

        var bodydata = jsonEncode({
          "mobile": userId.text,
          "password": password.text,
          "type": "Normal"
        });

        print('🔍 LOGIN REQUEST: $bodydata'); // Debug logging

        final response = await http
            .post(
              Uri.parse(loginUrl),
              headers: {
                'Content-Type': 'application/json', // FIX: Add required headers
                'Accept': 'application/json',
                'User-Agent': 'rapidtradeai-Mobile-App',
              },
              body: bodydata,
            )
            .timeout(const Duration(seconds: 15)); // FIX: Add timeout

        print(
            '🔍 LOGIN RESPONSE: ${response.statusCode} - ${response.body}'); // Debug logging

        if (response.statusCode == 200) {
          if (response.body.isNotEmpty) {
            var data = jsonDecode(response.body);
            if (data['status'] == 'success') {
              prefs.setString('emailorpass', userId.text);
              prefs.setString('password', password.text);
              prefs.setString('userid', data['data']['user_id']);
              prefs.setString('userEmail', data['data']['email']);
              setState(() {
                botStatus = "";
                commonuserId = data['data']['user_id'];
                commonEmail = data['data']['email'];
                emailormobile = userId.text;
                passwordvalue = password.text;
              });
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Tabscreen(
                            reffral: data['data']['referral_code'],
                          )));
            } else {
              showtoast(data['message'] ?? 'Login failed', context);
              Navigator.pop(context);
            }
          } else {
            showtoast("Empty response from server", context);
            Navigator.pop(context);
          }
        } else {
          showtoast("Server Error: ${response.statusCode}",
              context); // FIX: Show actual error code
          Navigator.pop(context);
        }
      } on SocketException {
        showtoast("No internet connection", context);
      } on TimeoutException {
        showtoast(
            "Request timeout - server is slow", context); // FIX: Handle timeout
      } catch (e) {
        showtoast(
            "Login error: ${e.toString()}", context); // FIX: Show actual error
        print('LOGIN ERROR: $e');
      } finally {
        setState(() {
          isAPicalled = false;
        });
      }
    }
  }

  _showCapChacode() {
    if (userId.text == "") {
      showtoast("User-Id is empty", context);
    } else if (password.text == "") {
      showtoast("Password is empty", context);
    } else {
      showCaptcha(context);
    }
  }

  void showCaptcha(
    BuildContext context,
  ) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 270,
                child: SliderCaptcha(
                    colorCaptChar: TradingTheme.secondaryAccent,
                    titleStyle: TextStyle(color: Colors.white),
                    image: Image.asset(
                      "assets/img/tradingbot.png",
                      fit: BoxFit.fill,
                    ),
                    onConfirm: (v) async {
                      v ? _login() : null;
                    }),
              ),
            ),
          );
        });
  }
}
