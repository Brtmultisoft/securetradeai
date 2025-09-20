import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:rapidtradeai/src/Service/assets_service.dart';

import '../../../../Data/Api.dart';

class NoticeCarefully extends StatefulWidget {
  const NoticeCarefully({Key? key}) : super(key: key);

  @override
  _NoticeCarefullyState createState() => _NoticeCarefullyState();
}

class _NoticeCarefullyState extends State<NoticeCarefully> {
  bool isAPIcalled = false;
  var finaldata;
  _getData() async {
    setState(() {
      isAPIcalled = true;
    });
    final res = await http.get(Uri.parse(notice));
    if (res.statusCode != 200) {
      showtoast("Server Error", context);
      setState(() {
        isAPIcalled = false;
      });
    } else {
      var data = jsonDecode(res.body);
      if (data['status'] == "success") {
        setState(() {
          finaldata = data['data']['content'];
          isAPIcalled = false;
        });
      } else {
        showtoast(data['message'], context);
        setState(() {
          isAPIcalled = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notice")),
      body: isAPIcalled
          ? Center(
              child: CircularProgressIndicator(color: rapidtradeaicolor),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [Html(data: finaldata)],
                ),
              ),
            ),
    );
  }
}
