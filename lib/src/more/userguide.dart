import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/data/api.dart';
import 'package:securetradeai/src/Service/assets_service.dart';

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
      appBar: AppBar(
        backgroundColor: bg,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "user_guide".tr,
          style: const TextStyle(
              fontFamily: fontFamily, fontSize: 20, color: Colors.black),
        ),
      ),
      body: isAPIcalled
          ? Center(
              child: CircularProgressIndicator(color: bg),
            )
          : SingleChildScrollView(
              child: Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Html(
                    data: finaldata,
                  )),
            ),
    );
  }
}
