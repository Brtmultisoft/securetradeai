import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/data/api.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';

class Swap extends StatefulWidget {
  const Swap({Key? key, this.balance}) : super(key: key);
  final balance;
  @override
  _SwapState createState() => _SwapState();
}

class _SwapState extends State<Swap> {
  var amount = TextEditingController();

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
                height: 20,
              ),
              InkWell(
                onTap: () {
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
                  child: Text(
                    "Swap to Gas Wallet",
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
