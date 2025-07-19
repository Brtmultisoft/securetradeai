import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:securetradeai/Data/Api.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:http/http.dart' as http;

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  var emailOrMobile = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("forgotPassword".tr)),
      body: Container(
        margin: const EdgeInsets.only(left: 15, right: 15),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
              ),
              Container(
                // child: Image.asset("assets/img/banner4.png"),
                child: Image.asset(
                  "assets/img/logo.png",
                  // height: 80,
                  // width: 250,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    "userid".tr,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xfff3f3f4),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Container(
                  margin: EdgeInsets.only(left: 8),
                  child: TextField(
                      style: TextStyle(color: Colors.white),
                      controller: emailOrMobile,
                      autocorrect: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      )),
                ),
              ),
              SizedBox(height: 30),
              InkWell(
                onTap: _forgotPass,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 1.0],
                      colors: [
                        Colors.green,
                        Colors.blue,
                      ],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                          color: Colors.black12,
                          offset: Offset(2, 4),
                          blurRadius: 5,
                          spreadRadius: 2)
                    ],
                  ),
                  child: Text(
                    'submit'.tr,
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _forgotPass() async {
    if (emailOrMobile.text == "") {
      showtoast("Email or Phone Field is empty", context);
    } else {
      try {
        showLoading(context);
        var bodydata =
            jsonEncode({"EmailorNumber": emailOrMobile.text, "type": "Email"});
        final response =
            await http.post(Uri.parse(forgotPassword), body: bodydata);
        if (response.statusCode != 200) {
          showtoast("internal Server Error", context);
          Navigator.pop(context);
        } else if (response.body != '') {
          var data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            showtoast(data['message'], context);
            print(data);
            Navigator.pop(context);
          } else {
            showtoast(data['message'], context);
            print(data['message']);
            Navigator.pop(context);
          }
        }
      } on SocketException {
        showtoast("Check Internet", context);
        Navigator.pop(context);
        print('Socket Exception');
      }
    }
  }
}
