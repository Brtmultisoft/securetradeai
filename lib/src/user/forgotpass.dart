import 'dart:convert';
import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:securetradeai/Data/Api.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/Service/otp_service.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/src/widget/common_app_bar.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  var emailController = TextEditingController();
  var otpController = TextEditingController();
  var newPasswordController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  // Flow states
  int currentStep = 1; // 1: Email, 2: OTP, 3: New Password
  bool isOtpSent = false;
  bool isOtpVerified = false;
  bool isLoading = false;
  DateTime? otpSentTime;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  final Color _backgroundColor = const Color(0xFF1E2329);
  final Color _cardColor = const Color(0xFF2B3139);
  final Color _primaryColor = const Color(0xFFF0B90B);
  final Color _textColor = const Color(0xFFEAECEF);
  final Color _borderColor = const Color(0xFF474D57);
  final Color _hintColor = const Color(0xFF848E9C);

  @override
  void initState() {
    super.initState();
    OtpService.clearRequestId(); // Clear any previous OTP session
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: CommonAppBar(title: 'forgotPassword'.tr),
      body: Container(
        margin: const EdgeInsets.only(left: 15, right: 15),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.asset("assets/img/logo.png")),

              // Step indicator
              _buildStepIndicator(),
              const SizedBox(height: 30),

              // Dynamic content based on current step
              if (currentStep == 1) _buildEmailStep(),
              if (currentStep == 2) _buildOtpStep(),
              if (currentStep == 3) _buildPasswordStep(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepCircle(1, "Email", currentStep >= 1),
        Container(width: 40, height: 2, color: currentStep >= 2 ? _primaryColor : _borderColor),
        _buildStepCircle(2, "OTP", currentStep >= 2),
        Container(width: 40, height: 2, color: currentStep >= 3 ? _primaryColor : _borderColor),
        _buildStepCircle(3, "Password", currentStep >= 3),
      ],
    );
  }

  Widget _buildStepCircle(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? _primaryColor : _borderColor,
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                color: isActive ? Colors.black : _textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: isActive ? _primaryColor : _hintColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Enter your email address",
          style: TextStyle(
            color: _textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: _cardColor,
            border: Border.all(color: _borderColor),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: TextField(
              style: TextStyle(color: _textColor),
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: "Enter your email",
                hintStyle: TextStyle(color: _hintColor),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _sendOtpForForgotPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.black)
                : const Text(
                    "Send OTP",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Enter OTP sent to ${emailController.text}",
          style: TextStyle(
            color: _textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: _cardColor,
                  border: Border.all(color: isOtpVerified ? Colors.green : _borderColor),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextField(
                    style: TextStyle(color: _textColor),
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    enabled: !isOtpVerified,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      counterText: "",
                      hintText: "Enter OTP",
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
                onPressed: (isLoading || isOtpVerified || !isOtpSent) ? null : _verifyOtpForForgotPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOtpVerified ? Colors.green : _primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        isOtpVerified ? "✓" : "Verify",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (isOtpVerified)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  currentStep = 3;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Continue",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Set New Password",
          style: TextStyle(
            color: _textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // New Password Field
        Text(
          "New Password",
          style: TextStyle(color: _textColor, fontSize: 14),
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
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: TextField(
              style: TextStyle(color: _textColor),
              controller: newPasswordController,
              obscureText: !isNewPasswordVisible,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: "Enter new password",
                hintStyle: TextStyle(color: _hintColor),
                suffixIcon: IconButton(
                  icon: Icon(
                    isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: _hintColor,
                  ),
                  onPressed: () {
                    setState(() {
                      isNewPasswordVisible = !isNewPasswordVisible;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),

        // Confirm Password Field
        Text(
          "Confirm Password",
          style: TextStyle(color: _textColor, fontSize: 14),
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
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: TextField(
              style: TextStyle(color: _textColor),
              controller: confirmPasswordController,
              obscureText: !isConfirmPasswordVisible,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: "Confirm new password",
                hintStyle: TextStyle(color: _hintColor),
                suffixIcon: IconButton(
                  icon: Icon(
                    isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: _hintColor,
                  ),
                  onPressed: () {
                    setState(() {
                      isConfirmPasswordVisible = !isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.black)
                : const Text(
                    "Reset Password",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // Send OTP for forgot password
  Future<void> _sendOtpForForgotPassword() async {
    String emailValue = emailController.text.trim();

    if (emailValue.isEmpty) {
      showtoast("Email field is empty", context);
      return;
    }

    if (!EmailValidator.validate(emailValue)) {
      showtoast("Please enter a valid email", context);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await OtpService.sendOtpToEmail(
        email: emailValue,
        type: "Email",
        context: context,
      );

      if (response.isSuccess) {
        setState(() {
          isOtpSent = true;
          currentStep = 2;
          otpSentTime = DateTime.now();
        });
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Verify OTP for forgot password
  Future<void> _verifyOtpForForgotPassword() async {
    String otpValue = otpController.text.trim();

    if (otpValue.isEmpty) {
      showtoast("OTP field is empty", context);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await OtpService.verifyOtpCode(
        email: emailController.text,
        otp: otpValue,
        context: context,
      );

      if (response.isSuccess) {
        setState(() {
          isOtpVerified = true;
        });
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Reset password
  Future<void> _resetPassword() async {
    String newPassword = newPasswordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty) {
      showtoast("New password field is empty", context);
      return;
    }

    if (confirmPassword.isEmpty) {
      showtoast("Confirm password field is empty", context);
      return;
    }

    if (newPassword != confirmPassword) {
      showtoast("Passwords do not match", context);
      return;
    }

    if (newPassword.length < 6) {
      showtoast("Password must be at least 6 characters", context);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(forgotPassword),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'SecureTradeAI-Mobile-App',
        },
        body: jsonEncode({
          "email": emailController.text,
          "password": newPassword,
          "type": "email",
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          showtoast(data['message'] ?? "Password reset successfully", context);
          Navigator.pop(context); // Go back to login
        } else {
          showtoast(data['message'] ?? 'Password reset failed', context);
        }
      } else {
        showtoast("Server Error: ${response.statusCode}", context);
      }
    } catch (e) {
      showtoast("Network error: ${e.toString()}", context);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
