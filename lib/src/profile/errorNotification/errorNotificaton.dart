import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/data/api.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/data/strings.dart';

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
        body: jsonEncode({"user_id": commonuserId, "page": "0", "size": "100"}));

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
      appBar: AppBar(
        title: InkWell(onTap: _getData, child: Text("Error Notification")),
      ),
      body: isAPIcalled
          ? Center(
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
                                top: 8.0, left: 8, right: 8),
                            child: Container(
                              padding: EdgeInsets.all(12),
                              height: MediaQuery.of(context).size.height/ 5,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20.0)),
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
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "-",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        data[index]['bot_type'],
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "-",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
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
                                  SizedBox(
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
                                  SizedBox(
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
