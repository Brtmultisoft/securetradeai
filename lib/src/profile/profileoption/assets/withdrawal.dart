import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/Data/Api.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/method/methods.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';

class Withdrawal extends StatefulWidget {
  const Withdrawal({Key? key, this.balance}) : super(key: key);
  final balance;
  @override
  _WithdrawalState createState() => _WithdrawalState();
}

class _WithdrawalState extends State<Withdrawal> {
  var address = TextEditingController();
  var amount = TextEditingController();
  var transpass = TextEditingController();
  var pttnTokenvalue = TextEditingController();

  // Profile data
  bool isLoadingProfile = true;
  String walletAddress = "";
  String earningBalance = "0.00";

  // Amount validation
  String? amountError;
  bool isAmountValid = true;

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
      } else {
        setState(() {
          isLoadingProfile = false;
        });
      }
    } catch (e) {
      print("Error loading profile data: $e");
      setState(() {
        isLoadingProfile = false;
      });
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
        backgroundColor: const Color(0xFF0A0E17),
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
                // Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Container(
                //         child: Text(
                //           "currency".tr + " : ",
                //           style: TextStyle(
                //               color: Colors.white,
                //               fontWeight: FontWeight.bold,
                //               fontSize: 18),
                //         ),
                //       ),
                //       Container(
                //         child: const Text(
                //           " USD(TRC-20)",
                //           style: const TextStyle(
                //               color: Colors.white,
                //               fontWeight: FontWeight.bold,
                //               fontSize: 16),
                //         ),
                //       )
                //     ]),
                // const SizedBox(
                //   height: 20,
                // ),
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
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          "${"OTP".tr} : ",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 50),
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
                                obscureText: true,
                                style: const TextStyle(color: Colors.white),
                                controller: transpass,
                                decoration: InputDecoration(
                                  hintStyle: const TextStyle(
                                      color: Colors.white70, fontSize: 13),
                                  hintText: "Enter OTP".tr,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        )),
                      )
                    ]),

                const SizedBox(
                  height: 40,
                ),
                InkWell(
                  onTap: isAmountValid && amountError == null
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

  _checkWithdrawalAbleOrNot() async {
    try {
      showLoading(context);
      if (walletAddress.isEmpty) {
        showtoast(
            "Wallet Address not found. Please update your profile.", context);
        Navigator.pop(context);
      } else if (amount.text == "") {
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
        "address": walletAddress, // Use wallet address from profile
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
