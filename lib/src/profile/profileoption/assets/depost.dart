import 'dart:convert';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/Data/Api.dart';
import '../../../Service/assets_service.dart';
import 'package:securetradeai/data/strings.dart';

class Deposit extends StatefulWidget {
  const Deposit({Key? key}) : super(key: key);

  @override
  State<Deposit> createState() => _DepositState();
}

class _DepositState extends State<Deposit> {
  var amount = TextEditingController();
  var hashkey = TextEditingController();
  String quote = "Loading.....";
  
  _getData() async {
    try {
      final res = await http.post(Uri.parse(getIp),
          body: json.encode({"user_id": commonuserId}));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['status'] == "success") {
          print(data);
          setState(() {
            quote = data['data']['admin_details']['admin_depositaddress'];
          });
        }
      } else {
        showtoast("Server Error", context);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12), // Binance dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF161A1E), // Binance header color
        elevation: 0,
        title: Text(
          "deposit".tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deposit Network Selection
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2026), // Binance card background
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A2D35), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Network',
                    style: TextStyle(
                      color: Color(0xFF848E9C), // Binance gray text
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B3139), // Binance input background
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'TRC20',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF848E9C),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Amount Input
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2026), // Binance card background
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A2D35), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Amount',
                    style: TextStyle(
                      color: Color(0xFF848E9C), // Binance gray text
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B3139), // Binance input background
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      controller: amount,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(color: Color(0xFF848E9C), fontSize: 14),
                        hintText: "Enter Amount USD",
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        suffixText: 'USD',
                        suffixStyle: TextStyle(color: Color(0xFF848E9C), fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF848E9C),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Minimum deposit: 10 USD',
                        style: TextStyle(
                          color: Color(0xFF848E9C),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // QR Code Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2026), // Binance card background
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A2D35), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deposit Address',
                    style: TextStyle(
                      color: Color(0xFF848E9C), // Binance gray text
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: BarcodeWidget(
                        barcode: Barcode.qrCode(),
                        color: Colors.black,
                        data: quote,
                        width: 200,
                        height: 200,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B3139), // Binance input background
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            quote,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: quote));
                            showtoast("Copied", context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0B90B).withOpacity(0.1), // Binance yellow with opacity
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.copy,
                                  color: Color(0xFFF0B90B), // Binance yellow
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Copy",
                                  style: TextStyle(
                                    color: Color(0xFFF0B90B), // Binance yellow
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF848E9C),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Send only USDT to this deposit address. Ensure the network is TRC20.',
                          style: TextStyle(
                            color: Color(0xFF848E9C),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Transaction Hash Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2026), // Binance card background
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A2D35), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transaction Hash',
                    style: TextStyle(
                      color: Color(0xFF848E9C), // Binance gray text
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B3139), // Binance input background
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      controller: hashkey,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(color: Color(0xFF848E9C), fontSize: 14),
                        hintText: "Enter transaction hash/ID",
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF848E9C),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Enter the transaction hash/ID to confirm your deposit',
                          style: TextStyle(
                            color: Color(0xFF848E9C),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Submit Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: () {
                  _checkDepostAbleOrNot();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0B90B), // Binance yellow
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "deposit".tr,
                    style: const TextStyle(
                      fontSize: 16, 
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  _checkDepostAbleOrNot() async {
    try {
      if (amount.text == "") {
        showtoast("Amount Field is Empty", context);
      } else if (hashkey.text == "") {
        showtoast("Hashkey Field is Empty", context);
      } else {
        final res = await http.post(Uri.parse(getIp),
            body: json.encode({"user_id": commonuserId}));
        if (res.statusCode == 200) {
          var data = jsonDecode(res.body);
          if (data['status'] == "success") {
            if (double.parse(amount.text) <
                double.parse(data['data']['admin_details']['min_deposit'])) {
              showtoast(
                  "Min Deposit value ${data['data']['admin_details']['min_deposit']}",
                  context);
            } else {
              _depostAmount();
            }
          }
        } else {
          showtoast("Server Error", context);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future _depostAmount() async {
    try {
      showLoading(context);
      final resp = await http.post(Uri.parse(deposit),
          body: jsonEncode({
            "user_id": commonuserId,
            "qty": "0.000",
            "amount": amount.text,
            "hashkey": hashkey.text
          }));
      if (resp.statusCode != 200) {
        showtoast("Server Error", context);
        Navigator.pop(context);
      } else {
        var jsondata = jsonDecode(resp.body);
        if (jsondata['status'] == "success") {
          showtoast(jsondata['message'], context);
          amount.clear();
          hashkey.clear();
          Navigator.pop(context);
        } else {
          showtoast(jsondata['message'], context);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
  }
}
