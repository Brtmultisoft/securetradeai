import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/Service/otp_service.dart';
import 'package:securetradeai/src/profile/profileoption/APIBinding/notice_carefully_page.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';
import 'package:securetradeai/src/widget/lottie_loading_widget.dart';
import 'package:timer_builder/timer_builder.dart';

import '../../../../Data/Api.dart';
import '../../../User/signup.dart';

class BinanaceBinding extends StatefulWidget {
  const BinanaceBinding({Key? key}) : super(key: key);

  @override
  _BinanaceBindingState createState() => _BinanaceBindingState();
}

class _BinanaceBindingState extends State<BinanaceBinding> {
  String ipvalue = "Loading...";
  bool checkedStatus = false;
  var admindetail;
  var bindingDetail;
  bool isAPIcallded = false;
  var apiKey = TextEditingController();
  var secretKey = TextEditingController();
  var verificatation = TextEditingController();
  late DateTime alert;

  // OTP verification states
  bool isOtpSent = false;
  bool isOtpVerified = false;
  bool isOtpSending = false;
  bool isOtpVerifying = false;
  Future _getdata() async {
    setState(() {
      isAPIcallded = true;
    });
    setState(() {
      alert = DateTime.now().add(const Duration(seconds: 0));
    });
    final res = await http.post(Uri.parse(getIp),
        body: jsonEncode({"user_id": commonuserId, "type": "Binance"}));
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      print(data);
      if (data['status'] == 'success') {
        setState(() {
          ipvalue = data['data']['admin_details']['value'];
        });
        setState(() {
          isAPIcallded = false;
        });
        if (data['data']['binding_details'] != null) {
          setState(() {
            apiKey.text = data['data']['binding_details']['api_key'].toString();
            secretKey.text =
                data['data']['binding_details']['secret_key'].toString();
            // bindingDetail = data['data']['binding_details'];
            setState(() {
              isAPIcallded = false;
            });
          });
        } else {
          showtoast("Binding Detail not Found", context);
          setState(() {
            isAPIcallded = false;
          });
        }
      } else {
        showtoast("Server Error", context);
        setState(() {
          isAPIcallded = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getdata();
    alert = DateTime.now().add(const Duration(seconds: 0));
    OtpService.clearRequestId(); // Clear any previous OTP session
  }

  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = lang == 'ar'
        ? MediaQuery.of(context).size.height / 5
        : MediaQuery.of(context).size.height / 5;
    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      appBar: CommonAppBar.basic(
        title: "Binance Binding".tr,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10, right: 15, left: 15),
                height: categoryHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF2B3139),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF2A3A5A)),
                ),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                              left: 15, top: 15, right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("notice".tr,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: fontFamily)),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 15, top: 5, right: 15),
                          child: Text("binanc_notice_1".tr,
                              style: const TextStyle(color: Colors.white)),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 15, top: 5, right: 15),
                          child: Text("binance_notice_2".tr,
                              style: const TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  ],
                )),
            Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10, right: 15, left: 15),
                height: lang == 'ar'
                    ? MediaQuery.of(context).size.height / 2.3
                    : MediaQuery.of(context).size.height / 2.7,
                decoration: BoxDecoration(
                  color: const Color(0xFF2B3139),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF2A3A5A)),
                ),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                              left: 15, top: 15, right: 15),
                          child: Text("ip_group_binding".tr,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: fontFamily)),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 15, top: 5, right: 15),
                          child: Text("if_group_dec".tr,
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(left: 15, top: 15, right: 15),
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B3139),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF2A3A5A)),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // SizedBox(width: 10),
                            Text(ipvalue,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: fontFamily)),

                            IconButton(
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: ipvalue));
                                  showtoast("Copy", context);
                                },
                                icon:
                                    const Icon(Icons.copy, color: Colors.white))
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10, right: 15, left: 15),
              height: MediaQuery.of(context).size.height / 2.8,
              decoration: BoxDecoration(
                color: const Color(0xFF2B3139),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2A3A5A)),
              ),
              child: Column(children: [
                Container(
                  margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                  child: Row(
                    children: [
                      Text("api_key".tr + "     ",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily)),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                            child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: TextField(
                                  controller: apiKey,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintStyle: TextStyle(
                                        fontSize: 13, color: Colors.white),
                                    hintText: "Enter API Key",
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  )),
                            ),
                          ),
                        )),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Container(
                  margin: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  child: Row(
                    children: [
                      Text("secret_key".tr,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily)),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                            child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: TextField(
                                  controller: secretKey,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintStyle: TextStyle(
                                        fontSize: 13, color: Colors.white),
                                    hintText: "Enter Secret key",
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  )),
                            ),
                          ),
                        )),
                      ),
                    ],
                  ),
                ),const SizedBox(height: 5),
                const Divider(
                  color: Colors.grey,
                  indent: 15,
                  endIndent: 15,
                ),
                const SizedBox(height: 5),
                Container(
                  margin: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  child: Row(
                    children: [
                      Text("verificationCode".tr,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily)),
                      const SizedBox(width: 10),


                      // Verify Button (shown when OTP is sent but not verified)
                      if (isOtpSent && !isOtpVerified)
                        Container(
                          height: 35,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.0, 1.0],
                              colors: [primaryColor, Colors.blue],
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: isOtpVerifying ? null : _verifyOtpForBinding,
                            child: isOtpVerifying
                                ? const SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: LottieLoadingWidget.large()
                                  )
                                : const Text(
                                    'Verify',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),

                      // Send OTP Button (with timer)
                      if (!isOtpSent || isOtpVerified)
                        Container(
                          child: TimerBuilder.scheduled([alert], builder: (context) {
                            var now = DateTime.now();
                            var reached = now.compareTo(alert) >= 0;
                            return !reached
                                ? const SizedBox.shrink()
                                : Container(
                                    // width: 80,
                                    height: 35,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        stops: [0.0, 1.0],
                                        colors: [primaryColor, Colors.blue],
                                      ),
                                      borderRadius:
                                          const BorderRadius.all(Radius.circular(5)),
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                      ),
                                      onPressed: isOtpSending ? null : _sendOtpForBinding,
                                      child: isOtpSending
                                          ? const SizedBox(
                                              width: 15,
                                              height: 15,
                                              child: LottieLoadingWidget()
                                            )
                                          : const Text(
                                              'Send OTP',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                    ),
                                  );
                          }),
                        ),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(left: 15 , right: 15 , top: 15),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: isOtpVerified ? Colors.green : Colors.white,
                      ),
                      borderRadius:
                      const BorderRadius.all(Radius.circular(10))),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextField(
                          keyboardType: TextInputType.number,
                          controller: verificatation,
                          enabled: !isOtpVerified,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(
                                fontSize: 13, color: Colors.white),
                            hintText: "Enter OTP",
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          )),
                    ),
                  ),
                ),
              ]),
            ),
            bodyContent(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 150,
                  margin:
                      const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 1.0],
                      colors: [
                        primaryColor,
                        Colors.blue,

                      ],
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                          color: Colors.black12,
                          offset: Offset(2, 4),
                          blurRadius: 5,
                          spreadRadius: 2)
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      disabledForegroundColor:
                          Colors.transparent.withOpacity(0.38),
                      disabledBackgroundColor:
                          Colors.transparent.withOpacity(0.12),
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: isOtpVerified ? () {
                      binddata();
                    } : null,
                    child: const Text(
                      "Bind",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  width: 150,
                  margin:
                      const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 1.0],
                      colors: [
                        primaryColor,
                        Colors.blue,
                      ],
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      disabledForegroundColor:
                          Colors.transparent.withOpacity(0.38),
                      disabledBackgroundColor:
                          Colors.transparent.withOpacity(0.12),
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () {
                      unbinddata();
                    },
                    child: const Text(
                      "Un-Bind",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  bodyContent() {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15),
      width: double.infinity,
      child: Row(
        children: [
          Transform.scale(
              scale: 1,
              child: Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: primaryColor,
                ),
                child: Checkbox(
                  activeColor: primaryColor,
                  value: checkedStatus,
                  onChanged: (bool? value) {
                    setState(() {
                      print(checkedStatus);
                      checkedStatus = value ?? false;
                    });
                  },
                ),
              )),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'ihaveAPIbinding'.tr,
                    style: const TextStyle(color: Colors.white)),
                TextSpan(
                  text: 'theRisk'.tr,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NoticeCarefully()));
                    },
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: securetradeaicolor),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Send OTP for API binding
  Future<void> _sendOtpForBinding() async {
    if (commonEmail == "") {
      showtoast("Please relogin and try again", context);
      return;
    }

    setState(() {
      isOtpSending = true;
    });

    try {
      final response = await OtpService.sendOtpToEmail(
        email: commonEmail,
        type: "Email",
        context: context,
      );

      if (response.isSuccess) {
        setState(() {
          isOtpSent = true;
          alert = DateTime.now().add(const Duration(minutes: 2));
        });
      }
    } finally {
      setState(() {
        isOtpSending = false;
      });
    }
  }

  // Verify OTP for API binding
  Future<void> _verifyOtpForBinding() async {
    String otpValue = verificatation.text.trim();

    if (otpValue.isEmpty) {
      showtoast("OTP field is empty", context);
      return;
    }

    setState(() {
      isOtpVerifying = true;
    });

    try {
      final response = await OtpService.verifyOtpCode(
        email: commonEmail,
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
        isOtpVerifying = false;
      });
    }
  }

  Future unbinddata() async {
    try {
      if (verificatation.text == "") {
        showtoast("Please Enter OTP", context);
      } else if (checkedStatus != true) {
        showtoast("Please accept checkbox", context);
      } else {
        showLoading(context);
        final resp = await http.post(Uri.parse(bindingAPi),
            body: jsonEncode({
              "user_id": commonuserId,
              "type": "Binance",
              "api_key": "",
              "secret_key": "",
              "admin_ip": ipvalue,
              "email": commonEmail,
              "otp": verificatation.text,
              "requestId": OtpService.currentRequestId
            }));
        if (resp.statusCode != 200) {
          showtoast("Server Error", context);
          Navigator.pop(context);
        } else {
          var jsondata = jsonDecode(resp.body);
          print(jsondata);
          if (jsondata['status'] == "success") {
            showtoast(jsondata['message'], context);
            apiKey.clear();
            secretKey.clear();
            verificatation.clear();
            Navigator.pop(context);
            _getdata();
          } else {
            showtoast(jsondata['message'], context);
            Navigator.pop(context);
          }
          // if(jsondata)
        }
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
  }

  Future binddata() async {
    try {
      if (apiKey.text == "") {
        showtoast("APIKey Field is Empty", context);
      } else if (secretKey.text == "") {
        showtoast("Secret Key Field is Empty", context);
      } else if (verificatation.text == "") {
        showtoast("Please Enter OTP", context);
      } else if (checkedStatus != true) {
        showtoast("Please accept checkbox", context);
      } else {
        showLoading(context);
        final resp = await http.post(Uri.parse(bindingAPi),
            body: jsonEncode({
              "user_id": commonuserId,
              "type": "Binance",
              "api_key": apiKey.text,
              "secret_key": secretKey.text,
              "admin_ip": ipvalue,
              "email": commonEmail,
              "otp": verificatation.text,
              "requestId": OtpService.currentRequestId
            }));
        if (resp.statusCode != 200) {
          showtoast("Server Error", context);
          Navigator.pop(context);
        } else {
          var jsondata = jsonDecode(resp.body);
          print(jsondata);
          if (jsondata['status'] == "success") {
            showtoast(jsondata['message'], context);
            apiKey.clear();
            secretKey.clear();
            verificatation.clear();
            Navigator.pop(context);
            _getdata();
          } else {
            showtoast(jsondata['message'], context);
            Navigator.pop(context);
          }
          // if(jsondata)
        }
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
  }
}
