import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/data/api.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/Service/otp_service.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';

class Swap extends StatefulWidget {
  const Swap({Key? key, this.balance}) : super(key: key);
  final balance;
  @override
  _SwapState createState() => _SwapState();
}

class _SwapState extends State<Swap> {
  var amount = TextEditingController();
// OTP flags
  bool isOtpSent = false;
  bool isOtpVerified = false;
  bool isOtpSending = false;
  bool isOtpVerifying = false;
  String? otpRequestId;

  var otpController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1321),
      appBar: CommonAppBar.basic(
        title: "Swap",
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.only(left: 20),
                child: Row(children: [
                  Container(
                    child: Text(
                      "balance".tr + " : ",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                    child: Text(
                      widget.balance.toString() + " USD",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ]),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                  child: Container(
                height: 50,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xfff3f3f4),
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: amount,
                      decoration: InputDecoration(
                        hintStyle:
                            const TextStyle(color: Colors.white70, fontSize: 13),
                        hintText: "${"enteramount".tr} USD",
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              )),
              const SizedBox(
                height: 20,
              ),
              // OTP flow (same as Withdrawal)
              if (!isOtpSent) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: isOtpSending ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF0B90B),
                      foregroundColor: Colors.black,
                    ),
                    child: isOtpSending
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Text('Send OTP'),
                  ),
                ),
              ] else if (isOtpSent && !isOtpVerified) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xfff3f3f4)),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextField(
                            controller: otpController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Enter OTP',
                              hintStyle: TextStyle(color: Colors.white70, fontSize: 13),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isOtpVerifying ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF0B90B),
                        foregroundColor: Colors.black,
                      ),
                      child: isOtpVerifying
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Text('Verify'),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon(Icons.verified, color: Colors.green, size: 18),
                    SizedBox(width: 6),
                    Text('OTP Verified', style: TextStyle(color: Colors.green)),
                  ],
                ),
              ],
              const SizedBox(height: 12),

              InkWell(
                onTap: () {
                  if (!isOtpVerified) {
                    showtoast("Please verify OTP first", context);
                    return;
                  }
                  _transfer();
                },
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
                  child: const Text(
                    "Swap to Gas Wallet",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
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

  Future _transfer() async {
    try {
      if (amount.text == "") {
        showtoast("Amount Field is Empty", context);
      } else {
        showLoading(context);
        final resp = await http.post(Uri.parse(swap),
            body: jsonEncode({"user_id": commonuserId, "amount": amount.text}));
        print(resp.statusCode);
        print(resp.body);
        if (resp.statusCode != 200) {
          showtoast("Server Error", context);
          Navigator.pop(context);
        } else {
          var jsondata = jsonDecode(resp.body);
          print(jsondata);
          if (jsondata['status'] == "success") {
            showtoast(jsondata['message'], context);
            amount.clear();
            Navigator.pop(context);
            Navigator.pop(context);
          } else {
            showtoast(jsondata['message'], context);
            Navigator.pop(context);
          }
        }
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
  }
}
