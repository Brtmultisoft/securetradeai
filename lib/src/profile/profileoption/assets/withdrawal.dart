import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/Data/Api.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/method/methods.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';

import 'package:securetradeai/src/Service/otp_service.dart';
import 'package:securetradeai/src/widget/lottie_loading_widget.dart';

class Withdrawal extends StatefulWidget {
  const Withdrawal({Key? key, this.balance}) : super(key: key);
  final balance;
  @override
  _WithdrawalState createState() => _WithdrawalState();
}

class _WithdrawalState extends State<Withdrawal> {
  // Use common OtpService for sending and verifying OTP
  Future<void> _sendOtp() async {
    setState(() {
      isOtpSending = true;
    });
    OtpService.clearRequestId();
    final response = await OtpService.sendOtpToEmail(
      email: commonEmail, // Use user's email for OTP
      type: "withdrawal",
      context: context,
    );
    setState(() {
      isOtpSent = response.isSuccess;
      isOtpSending = false;
    });
  }

  Future<void> _verifyOtp() async {
    setState(() {
      isOtpVerifying = true;
    });
    final response = await OtpService.verifyOtpCode(
      email: commonEmail,
      otp: otpController.text,
      context: context,
    );
    setState(() {
      isOtpVerified = response.isSuccess;
      isOtpVerifying = false;
    });
  }

  var address = TextEditingController();
  var amount = TextEditingController();
  var otpController = TextEditingController();
  var transpass = TextEditingController();
  var pttnTokenvalue = TextEditingController();

  // Profile data
  bool isLoadingProfile = true;
  String walletAddress = "";
  String earningBalance = "0.00";

  // Amount validation
  String? amountError;
  bool isAmountValid = true;

  // OTP flags
  bool isOtpSent = false;
  bool isOtpVerified = false;
  bool isOtpSending = false;
  bool isOtpVerifying = false;
  String? otpRequestId;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final data = await CommonMethod().getMineData();
      if (data.status == "success" && data.data.isNotEmpty) {
        setState(() {
          walletAddress = data.data[0].walletAddress;
          earningBalance =
              data.data[0].incomeBalance; // Get earning balance from profile
          address.text =
              walletAddress; // Set the wallet address in the controller
          isLoadingProfile = false;
        });

        // Check wallet address immediately after loading
        if (walletAddress.isEmpty) {
          _showWalletAddressDialog();
        }
      } else {
        setState(() {
          isLoadingProfile = false;
        });
        // Show dialog if no data found
        _showWalletAddressDialog();
      }
    } catch (e) {
      print("Error loading profile data: $e");
      setState(() {
        isLoadingProfile = false;
      });
      // Show dialog on error too
      _showWalletAddressDialog();
    }
  }

  void _validateAmount(String value) {
    setState(() {
      if (value.isEmpty) {
        amountError = null;
        isAmountValid = true;
        return;
      }

      try {
        double enteredAmount = double.parse(value);
        double maxBalance = double.parse(earningBalance);

        if (enteredAmount > maxBalance) {
          amountError =
              "Amount cannot exceed earning balance ($earningBalance USDT)";
          isAmountValid = false;
        } else if (enteredAmount <= 0) {
          amountError = "Amount must be greater than 0";
          isAmountValid = false;
        } else {
          amountError = null;
          isAmountValid = true;
        }
      } catch (e) {
        amountError = "Please enter a valid amount";
        isAmountValid = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF0D1321),
        appBar: CommonAppBar.basic(
          title: 'withdrawal'.tr,
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 10, top: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          "${"balance".tr} : ",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      Container(
                        child: isLoadingProfile
                            ? const Text(
                                "Loading...",
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              )
                            : Text(
                                "$earningBalance USDT",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                      )
                    ]),
                const SizedBox(
                  height: 20,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          "${"address".tr} :     ",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xfff3f3f4),
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            color: const Color(
                                0xFF2A2A2A), // Darker background to indicate non-editable
                          ),
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: isLoadingProfile
                                        ? const Text(
                                            "Loading wallet address...",
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                            ),
                                          )
                                        : Text(
                                            walletAddress.isEmpty
                                                ? "No wallet address found"
                                                : walletAddress,
                                            style: TextStyle(
                                              color: walletAddress.isEmpty
                                                  ? Colors.white70
                                                  : Colors.white,
                                              fontSize: 13,
                                            ),
                                          ),
                                  ),
                                  const Icon(
                                    Icons.lock,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ]),
                const SizedBox(
                  height: 20,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          "amount".tr + r"($) : ",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      Expanded(
                        child: Container(
                            child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xfff3f3f4),
                              ),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: TextField(
                                style: const TextStyle(color: Colors.white),
                                controller: amount,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintStyle: const TextStyle(
                                      color: Colors.white70, fontSize: 13),
                                  hintText: "${"amount".tr}(USDT)",
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  _validateAmount(value);
                                },
                              ),
                            ),
                          ),
                        )),
                      )
                    ]),
                // Error message display
                if (amountError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            amountError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),

                if (!isOtpVerified) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: const Text(
                          "OTP : ",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      const Spacer(),
                      Expanded(
                        child: InkWell(
                          onTap: isOtpSending ? null : _sendOtp,
                          child: Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width,
                            // padding: const EdgeInsets.symmetric(vertical: 15),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFF0B90B), // Golden yellow
                                  Color(0xFFFFD700), // Bright gold
                                  Color(0xFFF0B90B), // Golden yellow
                                ],
                                stops: [0.0, 0.5, 1.0],
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(2, 4),
                                    blurRadius: 5,
                                    spreadRadius: 2)
                              ],
                            ),
                            child: isOtpSending
                                ? const LottieLoadingWidget()
                                : Text(
                                    isOtpSent ? "Resend OTP" : "Send OTP",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isOtpSent)
                    Container(
                      child: Container(
                        height: 50,
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xfff3f3f4),
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: TextField(
                              style: const TextStyle(color: Colors.white),
                              controller: otpController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintStyle: TextStyle(
                                    color: Colors.white70, fontSize: 13),
                                hintText: "Please Enter OTP",
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              onChanged: (value) {},
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (isOtpSent)
                    InkWell(
                      onTap: isOtpVerifying ? null : _verifyOtp,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFF0B90B), // Golden yellow
                                Color(0xFFFFD700), // Bright gold
                                Color(0xFFF0B90B), // Golden yellow
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(2, 4),
                                  blurRadius: 5,
                                  spreadRadius: 2)
                            ],
                          ),
                          child: isOtpVerifying
                              ? const LottieLoadingWidget()
                              : const Text(
                                  "Verify OTP",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    )
                ],

                const SizedBox(
                  height: 40,
                ),
                InkWell(
                  onTap: isAmountValid && amountError == null && isOtpVerified
                      ? () {
                          _checkWithdrawalAbleOrNot();
                        }
                      : null,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFF0B90B),
                          Color(0xFFFFD700),
                          Color(0xFFF0B90B),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.black12,
                            offset: Offset(2, 4),
                            blurRadius: 5,
                            spreadRadius: 2)
                      ],
                    ),
                    child: Text(
                      "withdrawal".tr,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  void _showWalletAddressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2A3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: const Color(0xFFF0B90B),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Wallet Address Required',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your wallet address is not set. Please update your profile to add a wallet address before making withdrawals.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0B90B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF0B90B).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFFF0B90B),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Go to Profile → Update wallet address',
                        style: TextStyle(
                          color: Color(0xFFF0B90B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
                // User can then go to Profile tab and update wallet address
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF0B90B),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _checkWithdrawalAbleOrNot() async {
    try {
      showLoading(context);
      if (amount.text == "") {
        showtoast("Amount Field is Empty", context);
        Navigator.pop(context);
      } else if (!isAmountValid || amountError != null) {
        showtoast(amountError ?? "Please enter a valid amount", context);
        Navigator.pop(context);
      } else if (transpass.text == "") {
        showtoast("Transaction Password Field is Empty", context);
        Navigator.pop(context);
      } else {
        final res = await http.post(Uri.parse(getIp),
            body: json.encode({"user_id": commonuserId}));
        if (res.statusCode == 200) {
          var data = jsonDecode(res.body);
          if (data['status'] == "success") {
            if (double.parse(amount.text) <
                double.parse(data['data']['admin_details']['min_withdraw'])) {
              showtoast(
                  "Min Withdrawal value ${data['data']['admin_details']['min_withdraw']}",
                  context);
              Navigator.pop(context);
            } else {
              _withdrawal();
              Navigator.pop(context);
            }
          }
        } else {
          showtoast("Server Error", context);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future _withdrawal() async {
    try {
      showLoading(context);
      var bodydata = jsonEncode({
        "user_id": commonuserId,
        "amount": amount.text,
        "qty": "0.00",
        "address": walletAddress,
        "password": transpass.text
      });
      print(bodydata);
      final resp = await http.post(Uri.parse(withdrawal), body: bodydata);
      if (resp.statusCode != 200) {
        showtoast("Server Error", context);
        Navigator.pop(context);
      } else {
        var jsondata = jsonDecode(resp.body);
        print(jsondata);
        if (jsondata['status'] == "success") {
          showtoast(jsondata['message'], context);
          address.clear();
          amount.clear();
          transpass.clear();
          pttnTokenvalue.clear();
          Navigator.pop(context);
        } else {
          showtoast(jsondata['message'], context);
          Navigator.pop(context);
        }
        // if(jsondata)
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
  }
}
