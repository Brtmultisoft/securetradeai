import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';
import 'package:http/http.dart' as http;
import 'package:timer_builder/timer_builder.dart';
import 'package:rapidtradeai/data/strings.dart';
import '../../../../Data/Api.dart';
import '../../../User/signup.dart';

class Huobi extends StatefulWidget {
  const Huobi({Key? key}) : super(key: key);

  @override
  _HuobiState createState() => _HuobiState();
}

class _HuobiState extends State<Huobi> {
  String ipvalue = "Loading...";
  bool checkedStatus = false;
  var apiKey = TextEditingController();
  var secretKey = TextEditingController();
  var verificatation = TextEditingController();
  late DateTime alert;
  bool isAPIcallded = false;
  Future _getdata() async {
    setState(() {
      isAPIcallded = true;
    });
    final res = await http.post(Uri.parse(getIp),
        body: jsonEncode({"user_id": commonuserId, "type": "Huobi"}));
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        print(data);
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
          showtoast("Huobi Detail not Found", context);
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
    alert = DateTime.now().add(Duration(seconds: 0));
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = lang == 'ar'
        ? MediaQuery.of(context).size.height / 5.5
        : MediaQuery.of(context).size.height / 5.5;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Text(
          "huobi".tr,
          style: TextStyle(fontFamily: fontFamily, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 10, right: 15, left: 15),
                height: categoryHeight,
                decoration: BoxDecoration(
                   gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.0],
                  colors: [
                    Colors.green,
                    Colors.blue,
                  ],
                ),
                  // color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 15, top: 15, right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("notice".tr,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: fontFamily)),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 15, top: 5, right: 15),
                          child: Text("binanc_notice_1".tr,
                              style: TextStyle(color: Colors.white)),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 15, top: 5, right: 15),
                          child: Text("binance_notice_2".tr,
                              style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  ],
                )),
            Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 10, right: 15, left: 15),
                height: lang == 'ar'
                    ? MediaQuery.of(context).size.height / 2.3
                    : MediaQuery.of(context).size.height / 2.3,
                decoration: BoxDecoration(
                   gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.0],
                  colors: [
                    Colors.green,
                    Colors.blue,
                  ],
                ),
                  // color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 15, top: 15, right: 15),
                          child: Text("ip_group_binding".tr,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: fontFamily)),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 15, top: 5, right: 15),
                          child: Text("if_group_dec_for_huobi".tr,
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 15, top: 15, right: 15),
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        // color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // SizedBox(width: 10),
                            Text(ipvalue,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: fontFamily)),

                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: ipvalue));
                                showtoast("Copy", context);
                              },
                              child: Text("copy".tr,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: fontFamily)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 10, right: 15, left: 15),
              height: MediaQuery.of(context).size.height / 3,
              decoration: BoxDecoration(
                 gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.0],
                  colors: [
                    Colors.green,
                    Colors.blue,
                  ],
                ),
                // color: Colors.redAccent,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(children: [
                Container(
                  margin: EdgeInsets.only(left: 15, right: 15, top: 15),
                  child: Row(
                    children: [
                      Text("api_key".tr + "     ",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily)),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                            child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: TextField(
                                  style: TextStyle(color: Colors.white),
                                  controller: apiKey,
                                  decoration: const InputDecoration(
                                    hintStyle: TextStyle(fontSize: 13),
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
                Divider(),
                Container(
                  margin: EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  child: Row(
                    children: [
                      Text("secret_key".tr,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily)),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                            child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: TextField(
                                  style: TextStyle(color: Colors.white),
                                  controller: secretKey,
                                  decoration: const InputDecoration(
                                    hintStyle: TextStyle(fontSize: 13),
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
                ),
                Divider(),
                Container(
                  margin: EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  child: Row(
                    children: [
                      Text("Verification Code",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily)),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                            child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: TextField(
                                  style: TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.number,
                                  controller: verificatation,
                                  decoration: const InputDecoration(
                                    hintStyle: TextStyle(fontSize: 13),
                                    hintText: "Enter OTP",
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  )),
                            ),
                          ),
                        )),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        child:
                            TimerBuilder.scheduled([alert], builder: (context) {
                          var now = DateTime.now();
                          var reached = now.compareTo(alert) >= 0;
                          return !reached
                              ? TimerBuilder.periodic(Duration(seconds: 1),
                                  alignment: Duration.zero, builder: (context) {
                                  // This function will be called every second until the alert time
                                  var now = DateTime.now();
                                  var remaining = alert.difference(now);
                                  return Text(
                                    formatDuration(remaining),
                                    style: TextStyle(color: Colors.white),
                                  );
                                })
                              : InkWell(
                                  onTap: () {
                                    _sendMailOTP();
                                  },
                                  child: Text(
                                    'Send',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                        }),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            bodyContent(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    binddata();
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                    width: 150,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                       gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.0],
                  colors: [
                    Colors.green,
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
                    // gradient: LinearGradient(
                    //     begin: Alignment.centerLeft,
                    //     end: Alignment.centerRight,
                    //     colors: [Color(0xfffbb448), Color(0xfff7892b)])),
                    child: Text(
                      "Bind",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    unbinddata();
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                    width: 150,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.0],
                  colors: [
                    Colors.green,
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
                    // gradient: LinearGradient(
                    //     begin: Alignment.centerLeft,
                    //     end: Alignment.centerRight,
                    //     colors: [Color(0xfffbb448), Color(0xfff7892b)])),
                    child: const Text(
                      "Un-Bind",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  bodyContent() {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15),
      width: double.infinity,
      child: Row(
        children: [
          Transform.scale(
              scale: 1,
              child: Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: Colors.white,
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
                    style: TextStyle(color: Colors.white)),
                TextSpan(
                  text: 'theRisk'.tr,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // _navigatAgreement();
                      print('object');
                    },
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: rapidtradeaicolor),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future _sendMailOTP() async {
    if (commonEmail == "") {
      showtoast("Please relogin and try again", context);
    } else {
      setState(() {
        alert = DateTime.now().add(Duration(minutes: 2));
      });
      try {
        final response = await http.post(
          Uri.parse(apibindingOtp),
          body: jsonEncode({"email": commonEmail}),
        );
        if (response.statusCode != 200) {
        } else if (response.body != '') {
          var data = jsonDecode(response.body);
          print(data);
          if (data['status'] == 'success') {
            showtoast("OTP send successfully", context);
          } else {
            showtoast(data['message'], context);
            print(data['message']);
          }
        }
      } on SocketException {
        showtoast("Check Internet", context);
        print('Socket Exception');
      }
    }
  }

  Future binddata() async {
    print("Click");
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
              "type": "Huobi",
              "api_key": apiKey.text,
              "secret_key": secretKey.text,
              "admin_ip": ipvalue,
              "email": commonEmail,
              "otp": verificatation.text
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
              "type": "Huobi",
              "api_key": "",
              "secret_key": "",
              "admin_ip": ipvalue,
              "email": commonEmail,
              "otp": verificatation.text
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
