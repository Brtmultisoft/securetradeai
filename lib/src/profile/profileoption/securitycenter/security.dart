import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/profile/profileoption/securitycenter/aboutTrustcoin.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/api.dart';
import '../../../sharedpreferences.dart';

class SystemCenter extends StatefulWidget {
  const SystemCenter({Key? key}) : super(key: key);

  @override
  _SystemCenterState createState() => _SystemCenterState();
}

class _SystemCenterState extends State<SystemCenter> {
  String appVersion = "";
  var systemUrl;
  bool isAPcalled = false;
  final List locales = [
    {'name': 'ENGLISH', 'locale': Locale('en', 'US')},
    {'name': 'Arabic', 'locale': Locale('ar', 'AR')},
    {'name': 'हिंदी', 'locale': Locale('hi', 'IN')},
  ];
  final List currency = [
    {
      'symbol': 'Euro',
    },
    {
      'symbol': 'Rupees',
    },
    {
      'symbol': 'USD',
    },
    {
      'symbol': 'Yuan',
    },
    {
      'symbol': 'Pound',
    },
  ];
  showLocaleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0))),
        title: Text('selectLanguage'.tr),
        content: Container(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) => InkWell(
              child: Padding(
                child: Text(locales[index]['name']),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onTap: () => updateLocale(
                locales[index]['locale'],
                context,
              ),
            ),
            separatorBuilder: (context, index) => const Divider(
              color: Colors.black,
            ),
            itemCount: locales.length,
          ),
        ),
      ),
    );
  }

  changeCurrency(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xFF1A2234),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0))),
        title: Text(
          "Select Currency",
          style: TextStyle(color: Colors.white),
        ),
        content: Container(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) => InkWell(
                child: Padding(
                  child: Text(
                    currency[index]['symbol'],
                    style: TextStyle(color: Colors.white),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('currentCurrency', currency[index]['symbol']);
                  showtoast("Currency Select Successfully", context);
                  setState(() {
                    currentCurrency = currency[index]['symbol'];
                  });
                  Navigator.pop(context);
                }),
            separatorBuilder: (context, index) => const Divider(
              color: Colors.grey,
            ),
            itemCount: currency.length,
          ),
        ),
      ),
    );
  }

  updateLocale(Locale locale, BuildContext context) {
    Navigator.of(context).pop();
    setLocale(locale.languageCode, locale.countryCode!);
    lang = locale.languageCode;
    Get.updateLocale(locale);
  }

  getData() async {
    setState(() {
      isAPcalled = true;
    });
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
    try {
      final res = await http.get(Uri.parse(getappVersion));
      if (res.statusCode == 200) {
        var jsonData = jsonDecode(res.body);
        print(jsonData);
        if (jsonData['status'] == "success") {
          setState(() {
            systemUrl = jsonData['data'];
            isAPcalled = false;
          });
        }
      } else {
        setState(() {
          isAPcalled = false;
        });
      }
    } catch (e) {
      setState(() {
        isAPcalled = false;
      });
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A2234),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: appBar,
        title: Text("systemSetting".tr,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily)),
      ),
      body: isAPcalled
          ? Center(
              child: CircularProgressIndicator(color: securetradeaicolor),
            )
          : Container(
              margin: EdgeInsets.only(left: 12, right: 15),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "version".tr,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        "V " + appVersion,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      )
                    ],
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AboutTrustcoin()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "About Us", // not add language
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // GestureDetector(
                  //   onTap: () {
                  //     Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) => const ContectUs()));
                  //   },
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       Text(
                  //         "contectus".tr,
                  //         style: TextStyle(fontWeight: FontWeight.bold),
                  //       ),
                  //       Icon(
                  //         Icons.arrow_forward_ios,
                  //         size: 20,
                  //       )
                  //     ],
                  //   ),
                  // ),
                  // Divider(
                  //   color: Colors.grey,
                  // ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  GestureDetector(
                    onTap: () {
                      changeCurrency(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "currency".tr,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Row(
                          children: [
                            Text(
                              currentCurrency == "null"
                                  ? "USD"
                                  : currentCurrency,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: Colors.white,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
    );
  }
}
