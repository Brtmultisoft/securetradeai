import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/profile/profileoption/support/create.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/data/strings.dart';
import '../../../../data/api.dart';

class Inbox extends StatefulWidget {
  const Inbox({Key? key}) : super(key: key);

  @override
  _InboxState createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  bool isAPIcalled = false;
  bool checkdata = false;
  var finaldata = [];
  _getData() async {
    setState(() {
      isAPIcalled = true;
    });
    final res = await http.post(
      Uri.parse(inbox),
      body: jsonEncode({"user_id": commonuserId}),
      headers: {"Content-Type": "application/json"},
    );
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      if (data['status'] == "success") {
        setState(() {
          finaldata = data['data'] as List;
          isAPIcalled = false;
        });
      } else {
        showtoast(data['message'], context);
        setState(() {
          isAPIcalled = false;
          checkdata = true;
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
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: bg,
      onRefresh: () {
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
                pageBuilder: (a, b, c) => Inbox(),
                transitionDuration: Duration(seconds: 0)));
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            "inbox".tr,
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: isAPIcalled
            ? Center(child: CircularProgressIndicator(color: securetradeaicolor))
            : checkdata
                ? Center(
                    child: Image.asset(
                      "assets/img/logo.png",
                      height: 200,
                    ),
                  )
                : Column(
                    children: [
                      SizedBox(height: 20),
                      Expanded(
                          child: ListView.builder(
                              itemCount: finaldata.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.only(
                                      left: 10, right: 10, bottom: 5),
                                  decoration: BoxDecoration(
                                    color: securetradeaicolor.withOpacity(0.7),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.assignment_outlined,
                                              color: Colors.orange,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  finaldata[index]['subject'] ??
                                                      "",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                ),
                                                SizedBox(
                                                  width: 30,
                                                ),
                                                Text(
                                                  finaldata[index]
                                                          ['createdate'] ??
                                                      "",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          finaldata[index]['msg'] ?? "",
                                          style: TextStyle(
                                            letterSpacing: 0.5,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: const [
                                            Text(
                                              "Reply",
                                              style: TextStyle(
                                                  letterSpacing: 0.5,
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                            Icon(
                                              Icons.forward,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          finaldata[index]['remarks'] ?? "",
                                          style: TextStyle(
                                            letterSpacing: 0.5,
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
        floatingActionButton: SpeedDial(
          foregroundColor: securetradeaicolor,
          backgroundColor: bg,
          animatedIcon: AnimatedIcons.menu_close,
          overlayOpacity: 0.0,
          childPadding: EdgeInsets.symmetric(vertical: 8),
          children: [
            SpeedDialChild(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Create())),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                backgroundColor: securetradeaicolor,
                label: "create".tr),
          ],
        ),
      ),
    );
  }
}
