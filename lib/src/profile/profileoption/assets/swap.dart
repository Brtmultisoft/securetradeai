import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rapidtradeai/data/api.dart';
import 'package:rapidtradeai/data/strings.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';
import 'package:rapidtradeai/src/widget/common_app_bar.dart';

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
              const SizedBox(
                height: 10,
              ),
              Row(children: [
                Text(
                  "balance".tr + " : ",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  "${widget.balance} USD",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ]),
              const SizedBox(
                height: 20,
              ),

              TextField(
                style: const TextStyle(color: Colors.white),
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintStyle: const TextStyle(
                      color: Colors.white70, fontSize: 13),
                  hintText: "enteramount".tr + " USD",
                  filled: true,
                  fillColor: Colors.transparent,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  contentPadding:const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: TradingTheme.secondaryAccent),
                  ),
                ),
              ),
              const SizedBox(
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
                    color: TradingTheme.secondaryAccent,
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
