import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rapidtradeai/data/api.dart';
import 'package:rapidtradeai/data/strings.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';
import 'package:rapidtradeai/src/widget/common_app_bar.dart';

class ErrorNotification extends StatefulWidget {
  const ErrorNotification({Key? key}) : super(key: key);

  @override
  _ErrorNotificationState createState() => _ErrorNotificationState();
}

class _ErrorNotificationState extends State<ErrorNotification> {
  List data = [];
  List code_or_msg = [];
  bool isAPIcalled = false;
  _getData() async {
    setState(() => isAPIcalled = true);
    final res = await http.post(Uri.parse(errorNotification),
        body:
            jsonEncode({"user_id": commonuserId, "page": "0", "size": "100"}));

    if (res.statusCode != 200) {
      showtoast("Server Error", context);
      setState(() => isAPIcalled = false);
      return;
    }
    final datares = jsonDecode(res.body);
    if (datares['status'] != "success") {
      showtoast(datares['message'], context);
      setState(() => isAPIcalled = false);
      return;
    }
    setState(() {
      data = datares['data'];
    });
    List jsonResponse = [];
    data.forEach((e) {
      var a = jsonDecode(e['response']);
      jsonResponse.add(a);
    });
    jsonResponse.forEach((e) {
      setState(() {
        code_or_msg.add({
          "code": e['code'].toString().replaceAll("-", ""),
          "msg": e['msg']
        });
      });
    });

    setState(() => isAPIcalled = false);
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TradingTheme.backgroundColor,
      appBar: CommonAppBar.analytics(
        title: "Error Notification",
      ),
      body: isAPIcalled
          ? const Center(
              child: CupertinoActivityIndicator(),
            )
          : Column(
              children: [
                Expanded(
                    child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          var a = "2022-09-27 05:32:52"
                              .substring(0, 10)
                              .replaceAll('-', '/');
                          print(a);
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 15, top: 15),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              // height: MediaQuery.of(context).size.height / 5,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF1E2026),
                                    Color(0xFF12151C),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFF2A2D35), width: 1),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        data[index]['assets'],
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const Text(
                                        "-",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        data[index]['bot_type'],
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const Text(
                                        "-",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        data[index]['buy_type'],
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Date',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        a,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    code_or_msg[index]['msg'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }))
              ],
            ),
    );
  }
}
