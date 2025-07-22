import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/profile/profileoption/APIBinding/binance.dart';

import '../../../../data/api.dart';

class ApiBinding extends StatefulWidget {
  const ApiBinding({Key? key}) : super(key: key);

  @override
  _ApiBindingState createState() => _ApiBindingState();
}

class _ApiBindingState extends State<ApiBinding> {
  bool binanceisAPIcallded = false;
  bool huobiAPIcalled = false;
  bool checkbinance = false;
  bool chechuobi = false;
  _getBinance() async {
    try {
      setState(() {
        binanceisAPIcallded = true;
      });
      final res = await http.post(Uri.parse(getIp),
          body: jsonEncode({"user_id": commonuserId, "type": "Binance"}));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print(data);
        if (data['status'] == 'success') {
          if (data['data']['binding_details'] != null) {
            setState(() {
              checkbinance = true;
              binanceisAPIcallded = false;
            });
          } else {
            print('Binance data not found');
            setState(() {
              binanceisAPIcallded = false;
            });
          }
        } else {
          showtoast("Server Error", context);
          setState(() {
            binanceisAPIcallded = false;
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  _getHuobi() async {
    try {
      setState(() {
        huobiAPIcalled = true;
      });
      final res = await http.post(Uri.parse(getIp),
          body: jsonEncode({"user_id": commonuserId, "type": "Huobi"}));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          if (data['data']['binding_details'] != null) {
            setState(() {
              chechuobi = true;
              huobiAPIcalled = false;
            });
          } else {
            print('Hubai data not found');
            setState(() {
              huobiAPIcalled = false;
            });
          }
        } else {
          showtoast("Server Error", context);
          setState(() {
            huobiAPIcalled = false;
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fatchdata();
  }

  fatchdata() {
    _getBinance();
    _getHuobi();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height * 0.15;
    return Scaffold(
        backgroundColor: const Color(0xFF0C0E12),
        appBar: AppBar(
            backgroundColor: const Color(0xFF161A1E),
            title: Text(
              "api_bindige".tr,
              style: TextStyle(
                  fontFamily: fontFamily, fontSize: 20, color: Colors.white),
            ),
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ))),
        body: Column(
          children: [
            Container(
                margin: EdgeInsets.only(top: 30, right: 15, left: 15),
                height: categoryHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF2B3139),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF2A3A5A)),
                ),
                child: Center(
                    child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BinanaceBinding(),
                      ),
                    );
                  },
                  leading: Image.asset(
                    "assets/img/bnb2.png",
                    color: Colors.white,
                    height: 80,
                  ),
                  title: Row(
                    children: [
                      Text(
                        "Binance",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontFamily),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Container(
                        width: 90,
                        height: 25,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white60),
                          color: checkbinance ? Colors.green : Colors.red,
                          // color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Center(
                            child: Text(
                          binanceisAPIcallded
                              ? "Loading.."
                              : checkbinance
                                  ? "Configured"
                                  : "Configure",
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily),
                        )),
                      )
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white),
                ))),
            // Container(
            //     margin: EdgeInsets.only(top: 10, right: 15, left: 15),
            //     height: categoryHeight,
            //     decoration: BoxDecoration(
            //       gradient: LinearGradient(
            //         begin: Alignment.topCenter,
            //         end: Alignment.bottomCenter,
            //         stops: [0.0, 1.0],
            //         colors: [
            //           primaryColor,
            //           Colors.blue,
            //         ],
            //       ),
            //       // color: Colors.redAccent,
            //       borderRadius: BorderRadius.circular(16.0),
            //     ),
            //     child: Center(
            //         child: Center(
            //             child: ListTile(
            //       onTap: () {
            //         Navigator.push(context,
            //             MaterialPageRoute(builder: (context) => Huobi()));
            //       },
            //       leading: Image.asset(
            //         "assets/img/huboi.png",
            //         color: Colors.white,
            //       ),
            //       title: Row(
            //         children: [
            //           const Text(
            //             "Huobi",
            //             style: TextStyle(
            //                 color: Colors.white,
            //                 fontWeight: FontWeight.bold,
            //                 fontFamily: fontfamily),
            //           ),
            //           SizedBox(
            //             width: 15,
            //           ),
            //           Container(
            //             width: 100,
            //             height: 25,
            //             decoration: BoxDecoration(
            //               border: Border.all(color: Colors.white60),
            //               color: chechuobi ? Colors.green : Colors.red,
            //               // color: Colors.redAccent,
            //               borderRadius: BorderRadius.circular(16.0),
            //             ),
            //             child: Center(
            //                 child: Text(
            //               huobiAPIcalled
            //                   ? "Loading.."
            //                   : chechuobi
            //                       ? "Configured"
            //                       : "Configure",
            //               style: TextStyle(
            //                   fontSize: 14,
            //                   fontWeight: FontWeight.bold,
            //                   color: Colors.white,
            //                   fontFamily: fontfamily),
            //             )),
            //           )
            //         ],
            //       ),
            //       trailing: Icon(Icons.arrow_forward_ios_rounded,
            //           color: Colors.white),
            //     )))),
          ],
        ));
  }
}
