import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/data/api.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';

class UserGuide extends StatefulWidget {
  const UserGuide({Key? key}) : super(key: key);

  @override
  _UserGuideState createState() => _UserGuideState();
}

class _UserGuideState extends State<UserGuide> {
  bool isAPIcalled = false;
  var finaldata;
  _getData() async {
    setState(() {
      isAPIcalled = true;
    });
    final res = await http.get(Uri.parse(userGuide));
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      print(data);
      if (data['status'] == "success") {
        setState(() {
          finaldata = data['data']['content'];
          isAPIcalled = false;
        });
      }
    } else {
      showtoast("Server Error", context);
      setState(() {
        isAPIcalled = false;
      });
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
      backgroundColor:
          const Color(0xFF1A2234), // Dark background to match app theme
      appBar: CommonAppBar.basic(
        title: "user_guide".tr,
      ),
      body: isAPIcalled
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFFF0B90B)), // Binance yellow
            )
          : SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: Html(
                  data: finaldata,
                  style: {
                    // Style the HTML content to match dark theme
                    "body": Style(
                      color: Colors.white,
                      backgroundColor: const Color(0xFF1A2234),
                    ),
                    "p": Style(
                      color: Colors.white,
                      fontSize: FontSize(16),
                    ),
                    "h1": Style(
                      color: const Color(
                          0xFFF0B90B), // Binance yellow for headings
                      fontSize: FontSize(24),
                      fontWeight: FontWeight.bold,
                    ),
                    "h2": Style(
                      color: const Color(
                          0xFFF0B90B), // Binance yellow for headings
                      fontSize: FontSize(20),
                      fontWeight: FontWeight.bold,
                    ),
                    "h3": Style(
                      color: const Color(
                          0xFFF0B90B), // Binance yellow for headings
                      fontSize: FontSize(18),
                      fontWeight: FontWeight.bold,
                    ),
                    "a": Style(
                      color: const Color(0xFF4A90E2), // Blue for links
                    ),
                    "li": Style(
                      color: Colors.white,
                    ),
                    "ul": Style(
                      color: Colors.white,
                    ),
                    "ol": Style(
                      color: Colors.white,
                    ),
                  },
                ),
              ),
            ),
    );
  }
}
