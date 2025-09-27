import 'dart:convert';
import 'package:securetradeai/src/widget/lottie_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:securetradeai/src/Service/otp_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/data/api.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';

class Transfer extends StatefulWidget {
  const Transfer({Key? key, this.balance}) : super(key: key);
  final balance;
  @override
  _TransferState createState() => _TransferState();
}

class _TransferState extends State<Transfer> {
  var amount = TextEditingController();
  var transation_user_id = TextEditingController();
  var otpController = TextEditingController();
  bool isOtpSent = false;
  bool isOtpVerified = false;
  bool isOtpSending = false;
  bool isOtpVerifying = false;
  String? otpRequestId;

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
      backgroundColor: Colors.black,
      appBar: CommonAppBar.basic(
        title: "transfer".tr,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.only(left: 20),
                child: Row(children: [
                  Container(
                    child: Text(
                      "balance".tr + " : ",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  SizedBox(
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
              SizedBox(
                height: 20,
              ),
              Container(
                  child: Container(
                height: 50,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xfff3f3f4),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: amount,
                      decoration: InputDecoration(
                        hintStyle:
                            TextStyle(color: Colors.white70, fontSize: 13),
                        hintText: "enteramount".tr + " USD",
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              )),
              SizedBox(
                height: 15,
              ),
              Container(
                  child: Container(
                height: 50,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xfff3f3f4),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: transation_user_id,
                      decoration: InputDecoration(
                        hintStyle:
                            TextStyle(color: Colors.white70, fontSize: 13),
                        hintText: "userid".tr,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              )),
              SizedBox(
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
              SizedBox(height: 20,),
              InkWell(
                onTap: isOtpVerified
                    ? () {
                 _transfer();
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
                  child: Text(
                    "transfer".tr,
                    style: const TextStyle(
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
      } else if (transation_user_id.text == "") {
        showtoast("User ID Field is Empty", context);
      }
      else if(otpController.text=="" && !isOtpVerified)
        {
          showtoast("Please Send Otp", context);
        }
        else {
        showLoading(context);
        final resp = await http.post(Uri.parse(transfer),
            body: jsonEncode({
              "user_id": commonuserId,
              "amount": amount.text,
              "transfer_user_id": transation_user_id.text
            }));
        if (resp.statusCode != 200) {
          showtoast("Server Error", context);
          Navigator.pop(context);
        } else {
          var jsondata = jsonDecode(resp.body);
          print(jsondata);
          if (jsondata['status'] == "success") {
            showtoast(jsondata['message'], context);
            amount.clear();
            transation_user_id.clear();
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
