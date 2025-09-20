import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rapidtradeai/data/api.dart';
import 'package:rapidtradeai/data/strings.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';
import 'package:rapidtradeai/src/utils/common_textfield.dart';
import 'package:rapidtradeai/src/widget/common_app_bar.dart';

class Transfer extends StatefulWidget {
  const Transfer({Key? key, this.balance}) : super(key: key);
  final balance;
  @override
  _TransferState createState() => _TransferState();
}

class _TransferState extends State<Transfer> {
  var amount = TextEditingController();
  var transation_user_id = TextEditingController();

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
              const SizedBox(
                height: 10,
              ),
              Row(children: [
                Text(
                  "${"balance".tr} : ",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
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
              const SizedBox(height: 20),
              CommonTextField(
                  controller: amount, hintText: "${"enteramount".tr} USD"),
              const SizedBox(height: 15),
              CommonTextField(
                  controller: transation_user_id, hintText: "userid".tr),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  _transfer();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(vertical: 10),
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
      } else {
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
