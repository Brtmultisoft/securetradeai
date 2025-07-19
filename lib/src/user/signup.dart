import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/Data/Api.dart';
import 'package:securetradeai/method/privecyPolicyMehtod.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/Widget/country_picker.dart';
import 'package:securetradeai/src/policiesAndAgreement/pricacyPolicies.dart';
import 'package:securetradeai/src/policiesAndAgreement/serviceAgreement.dart';
import 'package:securetradeai/src/user/login.dart';
import 'package:slider_captcha/slider_captcha.dart';
import 'package:toast/toast.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  String code = '';
  bool checkedStatus = false;
  ValueNotifier<bool> pressed = ValueNotifier(false);
  final _formKey = GlobalKey<FormState>();
  bool isEnabled = true;
  var contry = TextEditingController();
  var name = TextEditingController();
  var email = TextEditingController();
  var mobileno = TextEditingController();
  var password = TextEditingController();
  var conformPasword = TextEditingController();
  var verificatioCode = TextEditingController();
  var invitationCode = TextEditingController();
  late DateTime alert;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isInitialized = false;

  // Binance theme colors
  final Color _backgroundColor = const Color(0xFF1E2329);
  final Color _cardColor = const Color(0xFF2B3139);
  final Color _primaryColor = const Color(0xFFF0B90B);
  final Color _textColor = const Color(0xFFEAECEF);
  final Color _borderColor = const Color(0xFF474D57);
  final Color _hintColor = const Color(0xFF848E9C);

  @override
  void initState() {
    super.initState();
    alert = DateTime.now().add(const Duration(seconds: 0));

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

  Widget _logo() {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Image.asset(
          "assets/img/logo.png",
          height: 200,
          width: 200,
        ),
      ),
    );
  }

  Widget _title() {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        "Create Your Trading Account",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _textColor,
        ),
      ),
    );
  }

  Widget _entryField(String title, TextEditingController controller,
      {bool isPassword = false}) {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 5),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: _cardColor,
                  border: Border.all(color: _borderColor),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextFormField(
                    style: TextStyle(color: _textColor),
                    controller: controller,
                    cursorColor: _primaryColor,
                    maxLines: 1,
                    obscureText: isPassword,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 13.0),
                      hintText: "Enter your $title",
                      hintStyle: TextStyle(color: _hintColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(
              'Register'.tr,
              style: TextStyle(
                fontSize: 20,
                color: _backgroundColor,
                fontWeight: FontWeight.bold,
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

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Country",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    height: 50,
                    decoration: BoxDecoration(
                      color: _cardColor,
                      border: Border.all(color: _borderColor),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Row(
                      children: [
                        CountryPicker2(
                          callBackFunction: _codecallBackFunction,
                          headerText: 'Select Country code',
                          headerBackgroundColor: _primaryColor,
                          headerTextColor: _textColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          _entryField("entername".tr, name),
          SizedBox(height: 10),
          _entryField("entermobile".tr, mobileno),
          SizedBox(height: 10),
          _entryField("Enter Email", email),
          SizedBox(height: 10),
          _entryField("loginpassword".tr, password, isPassword: true),
          SizedBox(height: 10),
          _entryField("confirmPass".tr, conformPasword, isPassword: true),
          SizedBox(height: 10),
          _entryField("Enter OTP", verificatioCode),
          SizedBox(height: 10),
          _entryField("Invitation Code", invitationCode),
        ],
      ),
    );
  }

  Widget bodyContent() {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          child: Row(
            children: [
              Transform.scale(
                scale: 1,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    unselectedWidgetColor: _textColor,
                  ),
                  child: Checkbox(
                    activeColor: _primaryColor,
                    value: checkedStatus,
                    onChanged: (bool? value) {
                      setState(() {
                        checkedStatus = value ?? false;
                      });
                    },
                  ),
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'ihave'.tr,
                      style: TextStyle(color: _textColor),
                    ),
                    TextSpan(
                      text: 'theService'.tr,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _navigatAgreement();
                        },
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                    TextSpan(
                      text: 'and'.tr,
                      style: TextStyle(color: _textColor),
                    ),
                    TextSpan(
                      text: 'userprivcy'.tr,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _navigatPrivacyPolicies();
                        },
                      style: TextStyle(
                        color: _primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        title: Text(
          "signUp".tr,
          style: TextStyle(color: _textColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _logo(),
          Expanded(
            child: Container(
              height: height,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _title(),
                      SizedBox(height: 20),
                      _emailPasswordWidget(),
                      bodyContent(),
                      SizedBox(height: 20),
                      _submitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showCapChacode() {
    String emailtxt = email.text;
    final bool isValid = EmailValidator.validate(emailtxt);
    if (name.text == "") {
      showtoast("Name Field is empty", context);
    } else if (email.text == "") {
      showtoast("Email Field is empty", context);
    } else if (password.text == "") {
      showtoast("Password Field is empty", context);
    } else if (conformPasword.text == "") {
      showtoast("Confirm Password Field is empty", context);
    } else if (verificatioCode.text == "") {
      showtoast("Verification Field is empty", context);
    } else if (password.text != conformPasword.text) {
      showtoast("Password not match", context);
    } else if (checkedStatus == false) {
      showtoast(
          "Please Accecpt service and agreement and privacy policies", context);
    } else if (isValid != true) {
      showtoast("Email Not valid", context);
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
                    image: Image.asset(
                      "assets/img/tradingbot.png",
                      fit: BoxFit.fill,
                    ),
                    onConfirm: (v) async {
                      v ? _submitData() : null;
                    }),
              ),
            ),
          );
        });
  }

  void _codecallBackFunction(String name, String dialCode, String flag) {
    setState(() {
      contry.text = name;
      code = dialCode;
    });
  }

  _navigatPrivacyPolicies() async {
    showLoading(context);
    var data = await PolicyMethod().getPrivicyPolicyData();
    if (data.status == "success" || data.responsecode == 200) {
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PrivacyPolicies(
                    sub: data.data.name,
                    content: data.data.content,
                  )));
    } else {
      showtoast("Data Not found", context);
    }
    print(data.status);
  }

  _navigatAgreement() async {
    showLoading(context);
    var data = await PolicyMethod().getAgreeMent();
    if (data.status == "success" || data.responsecode == 200) {
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ServiceAgreement(
                    sub: data.data.name,
                    content: data.data.content,
                  )));
    } else {
      showtoast("Data Not found", context);
    }
    print(data.status);
  }

  Future _sendMailOTP() async {
    String emailtxt = email.text;
    final bool isValid = EmailValidator.validate(emailtxt);
    if (email.text == "") {
      showtoast("Email Field is empty", context);
    } else if (isValid != true) {
      showtoast("Email not valid", context);
    } else {
      setState(() {
        alert = DateTime.now().add(Duration(minutes: 2));
      });
      try {
        print('🔍 OTP REQUEST: ${email.text}'); // Debug logging

        final response = await http.post(
          Uri.parse(sendOtp),
          headers: {
            'Content-Type': 'application/json',  // FIX: Add required headers
            'Accept': 'application/json',
            'User-Agent': 'SecureTradeAI-Mobile-App',
          },
          body: jsonEncode({"email": email.text, "type": "Email"}),
        ).timeout(const Duration(seconds: 15));  // FIX: Add timeout

        print('🔍 OTP RESPONSE: ${response.statusCode} - ${response.body}'); // Debug logging

        if (response.statusCode == 200) {
          if (response.body.isNotEmpty) {
            var data = jsonDecode(response.body);
            if (data['status'] == 'success') {
              showtoast("OTP sent successfully", context);
            } else {
              showtoast(data['message'] ?? 'Failed to send OTP', context);
            }
          } else {
            showtoast("Empty response from server", context);
          }
        } else {
          showtoast("Server Error: ${response.statusCode}", context);  // FIX: Show actual error code
        }

      } on SocketException {
        showtoast("No internet connection", context);
        print('Socket Exception');
      } on TimeoutException {
        showtoast("Request timeout - server is slow", context);  // FIX: Handle timeout
        print('Timeout Exception');
      } catch (e) {
        showtoast("OTP error: ${e.toString()}", context);  // FIX: Show actual error
        print('OTP ERROR: $e');
      }
    }
  }

  Future _submitData() async {
    try {
      showLoading(context);
      var bodydata = jsonEncode({
        // "uid": widget.uid,
        "uid": "",
        "email": email.text,
        "mobile": code + mobileno.text,
        "password": password.text,
        "type": "Normal",
        "name": name.text,
        "otp": verificatioCode.text,
        "country": contry.text,
        "code": invitationCode.text
      });

      print('🔍 SIGNUP REQUEST: $bodydata'); // Debug logging

      final response = await http.post(
        Uri.parse(ragisterurl),
        headers: {
          'Content-Type': 'application/json',  // FIX: Add required headers
          'Accept': 'application/json',
          'User-Agent': 'SecureTradeAI-Mobile-App',
        },
        body: bodydata,
      ).timeout(const Duration(seconds: 15));  // FIX: Add timeout

      print('🔍 SIGNUP RESPONSE: ${response.statusCode} - ${response.body}'); // Debug logging

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          var data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            showtoast(data['message'] ?? 'Registration successful', context);
            Navigator.pop(context);
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LoginPage()));
          } else {
            showtoast(data['message'] ?? 'Registration failed', context);
            Navigator.pop(context);
          }
        } else {
          showtoast("Empty response from server", context);
          Navigator.pop(context);
        }
      } else {
        showtoast("Server Error: ${response.statusCode}", context);  // FIX: Show actual error code
        Navigator.pop(context);
      }

    } on SocketException {
      showtoast("No internet connection", context);
      Navigator.pop(context);
      print('Socket Exception');
    } on TimeoutException {
      showtoast("Request timeout - server is slow", context);  // FIX: Handle timeout
      Navigator.pop(context);
      print('Timeout Exception');
    } catch (e) {
      showtoast("Registration error: ${e.toString()}", context);  // FIX: Show actual error
      Navigator.pop(context);
      print('SIGNUP ERROR: $e');
    }
  }
}

String formatDuration(Duration d) {
  String f(int n) {
    return n.toString().padLeft(2, '0');
  }

  // We want to round up the remaining time to the nearest second
  d += Duration(microseconds: 999999);
  return "${f(d.inMinutes)}:${f(d.inSeconds % 60)}";
}
