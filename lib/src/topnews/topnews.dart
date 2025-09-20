import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../method/methods.dart';

class TopNews extends StatefulWidget {
  const TopNews({Key? key}) : super(key: key);
  @override
  _TopNewsState createState() => _TopNewsState();
}

class _TopNewsState extends State<TopNews> {
  var newsList = [];
  bool isAPIcalled = false;
  _getNewsdata() async {
    try {
      setState(() {
        isAPIcalled = true;
      });
      final data = await CommonMethod().getNews();

      if (data.status == "success") {
        setState(() {
          newsList.addAll(data.data);
          newsList.sort((a, b) {
            // log(a.createdDate.toString());
            //sorting in ascending order
            return DateTime.parse(a.createdDate)
                .compareTo(DateTime.parse(b.createdDate));
          });
          isAPIcalled = false;
        });
      } else {
        setState(() {
          isAPIcalled = false;
        });
        showtoast(data.message, context);
      }
    } catch (e) {
      setState(() {
        isAPIcalled = false;
      });
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _getNewsdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text("topnews".tr),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Expanded(
              child: ListView.builder(
                  itemCount: newsList.length,
                  itemBuilder: (context, index) {
                    // log(newsList[index].message.toString());
                    final text = newsList[index].message.toString();
                    RegExp exp = RegExp(
                        r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
                    Iterable<RegExpMatch> matches = exp.allMatches(text);
                    return Container(
                      margin: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                      decoration: BoxDecoration(
                        color: rapidtradeaicolor.withOpacity(0.7),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.assignment_outlined,
                                      color: Colors.orange,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          newsList[index].title,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                        Text(
                                          newsList[index]
                                              .createdDate
                                              .toString()
                                              .split(".")
                                              .first,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Visibility(
                                  visible: matches.isNotEmpty ? true : false,
                                  child: IconButton(
                                      onPressed: () async {
                                        String value = "";
                                        if (matches.length == 1) {
                                          for (var i in matches) {
                                            value =
                                                text.substring(i.start, i.end);
                                          }
                                          if (value.contains("https://")) {
                                            await launchUrl(Uri.parse(value));

                                            return;
                                          }
                                          showtoast(
                                              "$value URL not Valid", context);
                                          return;
                                        }
                                        _displayURL(context, matches, text);
                                      },
                                      icon: Icon(Icons.public,
                                          color: Colors.white)),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              newsList[index].message,
                              style: TextStyle(
                                letterSpacing: 0.5,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }))
        ],
      ),
    );
  }

  void _displayURL(
      BuildContext context, Iterable<RegExpMatch> value, String text) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding:
                const EdgeInsets.only(bottom: 10, left: 20, right: 10),
            title: const Text('Select URL'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i in value)
                  TextButton(
                      onPressed: () async {
                        if (text
                            .substring(i.start, i.end)
                            .contains("https://")) {
                          await launchUrl(
                              Uri.parse(text.substring(i.start, i.end)));
                          return;
                        }
                        showtoast("URL not Valid", context);
                      },
                      child: Text(text.substring(i.start, i.end)))
              ],
            ),
          );
        });
  }
}
