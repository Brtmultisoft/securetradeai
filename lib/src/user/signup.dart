import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:rapidtradeai/method/privecyPolicyMehtod.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';
import 'package:rapidtradeai/src/Widget/country_picker.dart';
import 'package:rapidtradeai/src/policiesAndAgreement/pricacyPolicies.dart';
import 'package:rapidtradeai/src/policiesAndAgreement/serviceAgreement.dart';
import 'package:rapidtradeai/src/user/login.dart';
import 'package:slider_captcha/slider_captcha.dart';
import 'package:toast/toast.dart';
import 'package:rapidtradeai/data/api.dart';
import 'package:rapidtradeai/src/widget/common_app_bar.dart';

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
  bool isOtpSent = false;
  bool isOtpVerified = false;
  bool isOtpSending = false;
  bool isOtpVerifying = false;
  String? otpRequestId;

  // Modern light blue theme colors for Rapid Trade AI

  final Color _backgroundColor = const Color(0xFF1E2329);
  final Color _cardColor = const Color(0xFF2B3139);
  final Color _primaryColor = const Color(0xFF03DAC6);
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
          margin: const EdgeInsets.symmetric(vertical: 10.0),
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
              const SizedBox(height: 5),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: _cardColor,
                  border: Border.all(color: _borderColor),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 13.0),
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


  Widget _emailFieldWithOtpButton() {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Enter Email",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: _cardColor,
                        border: Border.all(color: _borderColor),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextFormField(
                          style: TextStyle(color: _textColor),
                          controller: email,
                          cursorColor: _primaryColor,
                          maxLines: 1,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 13.0),
                            hintText: "Enter your Email",
                            hintStyle: TextStyle(color: _hintColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isOtpSending ? null : _sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isOtpSending
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(_backgroundColor),
                        ),
                      )
                          : Text(
                        isOtpSent ? "Resend" : "Send OTP",
                        style: TextStyle(
                          color: _backgroundColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpFieldWithVerifyButton() {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Text(
                    "Enter OTP",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: _textColor,
                    ),
                  ),
                  if (isOtpVerified)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: _cardColor,
                        border: Border.all(
                          color: isOtpVerified ? Colors.green : _borderColor,
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextFormField(
                          style: TextStyle(color: _textColor),
                          controller: verificatioCode,
                          cursorColor: _primaryColor,
                          maxLines: 1,
                          enabled: !isOtpVerified,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 13.0),
                            hintText: "Enter your OTP",
                            hintStyle: TextStyle(color: _hintColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (isOtpVerifying || isOtpVerified || !isOtpSent)
                          ? () {
                        print('🔍 VERIFY BUTTON DISABLED - isOtpVerifying: $isOtpVerifying, isOtpVerified: $isOtpVerified, isOtpSent: $isOtpSent');
                      }
                          : () {
                        print('🔍 VERIFY BUTTON CLICKED - Starting verification...');
                        _verifyOtp();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOtpVerified ? Colors.green : _primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isOtpVerifying
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(_backgroundColor),
                        ),
                      )
                          : Text(
                        isOtpVerified ? "Verified" : "Verify",
                        style: TextStyle(
                          color: _backgroundColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
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
          onTap: isOtpVerified ? _showCapChacode : null,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(vertical: 15),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isOtpVerified ? _primaryColor : _primaryColor.withOpacity(0.5),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: isOtpVerified
                      ? _primaryColor.withOpacity(0.3)
                      : _primaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(
              isOtpVerified ? 'Register'.tr : 'Verify OTP First',
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
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    height: 50,
                    decoration: BoxDecoration(
                      color: _cardColor,
                      border: Border.all(color: _borderColor),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
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
          const SizedBox(height: 10),
          _entryField("entername".tr, name),
          const SizedBox(height: 10),
          _entryField("entermobile".tr, mobileno),
          const SizedBox(height: 10),
          _emailFieldWithOtpButton(),
          const SizedBox(height: 10),
          _otpFieldWithVerifyButton(),
          const SizedBox(height: 10),
          _entryField("loginpassword".tr, password, isPassword: true),
          const SizedBox(height: 10),
          _entryField("confirmPass".tr, conformPasword, isPassword: true),
          const SizedBox(height: 10),
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
        child: SizedBox(
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
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
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
      appBar: CommonAppBar(title: 'signUp'.tr),
      body: Column(
        children: [
          _logo(),
          Expanded(
            child: SizedBox(
              height: height,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _title(),
                      const SizedBox(height: 20),
                      _emailPasswordWidget(),
                      bodyContent(),
                      const SizedBox(height: 20),
                      _submitButton(),
                      const SizedBox(height: 30),
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
     } else if (!isOtpVerified) {
  showtoast("Please verify your OTP first", context);
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
              child: SizedBox(
                height: 270,
                child: SliderCaptcha(
                    colorCaptChar: TradingTheme.secondaryAccent,
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

  Future<void> _showCredentialsPopup(String userId, String passwordValue) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: _cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              'Registration Successful',
              style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Please save your login details:', style: TextStyle(color: _hintColor)),
                const SizedBox(height: 12),
                _credentialRow('User ID', userId),
                const SizedBox(height: 8),
                _credentialRow('Password', passwordValue),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Continue', style: TextStyle(color: _primaryColor)),
              ),
            ],
          );
        });
  }

  Widget _credentialRow(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: '$label: ', style: TextStyle(color: _hintColor)),
                  TextSpan(text: value, style: TextStyle(color: _textColor, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              showtoast('$label copied', context);
            },
            icon: Icon(Icons.copy, color: _primaryColor, size: 18),
            tooltip: 'Copy',
          ),
        ],
      ),
    );
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

  Future _sendOtp() async {
    String emailValue = email.text;
    final bool isValid = EmailValidator.validate(emailValue);
    if (email.text == "") {
      showtoast("Email Field is empty", context);
    } else if (isValid != true) {
      showtoast("Email not valid", context);
    } else {
      setState(() {
        isOtpSending = true;
      });
      try {
        print('🔍 OTP REQUEST: ${email.text}');

        final response = await http.post(
          Uri.parse(sendOtp),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'SecureTradeAI-Mobile-App',
          },
          body: jsonEncode({"email": email.text}),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          if (response.body.isNotEmpty) {
            var data = jsonDecode(response.body);
            if (data['status'] == 'success') {
              // Store the requestId from the nested data object
              otpRequestId = data['data']?['requestId']?.toString();

              showtoast("OTP sent successfully", context);
              setState(() {
                isOtpSent = true;
                alert = DateTime.now().add(Duration(minutes: 2));
              });
            } else {
              showtoast(data['message'] ?? 'Failed to send OTP', context);
            }
          } else {
            showtoast("Empty response from server", context);
          }
        } else {
          showtoast("Server Error: ${response.statusCode}", context);
        }
      } catch (e) {
        showtoast("Network error: ${e.toString()}", context);
      } finally {
        setState(() {
          isOtpSending = false;
        });
      }
    }
  }

  Future _verifyOtp() async {
    if (verificatioCode.text == "") {
      showtoast("OTP Field is empty", context);
    } else {
      setState(() {
        isOtpVerifying = true;
      });
      try {

        // Create request body - include requestId only if it exists
        Map<String, dynamic> requestBody = {
          "email": email.text,
          "otp": verificatioCode.text,
        };

        if (otpRequestId != null) {
          requestBody["requestId"] = otpRequestId;
        }

        final response = await http.post(
          Uri.parse(verifyOtp),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'SecureTradeAI-Mobile-App',
          },
          body: jsonEncode(requestBody),
        ).timeout(const Duration(seconds: 15));

        print('🔍 VERIFY OTP RESPONSE: ${response.statusCode} - ${response.body}');

        if (response.statusCode == 200) {
          if (response.body.isNotEmpty) {
            var data = jsonDecode(response.body);
            if (data['status'] == 'success' &&
                data['data'] != null &&
                (data['data']['status'] == 'success' || data['data']['status'] == 'Success')) {
              showtoast("OTP verified successfully", context);
              setState(() {
                isOtpVerified = true;
              });
            } else {
              final errorMsg = data['data']?['message'] ?? data['message'] ?? 'Invalid OTP';
              showtoast(errorMsg, context);
              setState(() {
                isOtpVerified = false;
              });
            }
          } else {
            showtoast("Empty response from server", context);
          }
        } else {
          showtoast("Server Error: ${response.statusCode}", context);
        }
      } catch (e) {
        showtoast("Network error: ${e.toString()}", context);
      } finally {
        setState(() {
          isOtpVerifying = false;
        });
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

      final response = await http.post(
        Uri.parse(ragisterurl),
        headers: {
          'Content-Type': 'application/json',  // FIX: Add required headers
          'Accept': 'application/json',
          'User-Agent': 'rapidtradeai-Mobile-App',
        },
        body: bodydata,
      ).timeout(const Duration(seconds: 15));  // FIX: Add timeout

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          var data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            showtoast(data['message'] ?? 'Registration successful', context);
            Navigator.pop(context);
            String userIdToShow = email.text;
            try {
              final dynamic d = data;
              final dynamic payload = d['data'];
              final dynamic possible =
                  (payload is Map ? (payload['userId'] ?? payload['uid'] ?? payload['user_id']) : null) ??
                  d['uid'] ?? d['userId'] ?? d['user_id'] ?? d['username'];
              if (possible != null && possible.toString().trim().isNotEmpty) {
                userIdToShow = possible.toString();
              }
            } catch (_) {}
            await _showCredentialsPopup(userIdToShow, password.text);
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const LoginPage()));
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
     } on TimeoutException {
      showtoast("Request timeout - server is slow", context);  // FIX: Handle timeout
      Navigator.pop(context);
     } catch (e) {
      showtoast("Registration error: ${e.toString()}", context);  // FIX: Show actual error
      Navigator.pop(context);
      }
  }
}

String formatDuration(Duration d) {
  String f(int n) {
    return n.toString().padLeft(2, '0');
  }

  // We want to round up the remaining time to the nearest second
  d += const Duration(microseconds: 999999);
  return "${f(d.inMinutes)}:${f(d.inSeconds % 60)}";
}
