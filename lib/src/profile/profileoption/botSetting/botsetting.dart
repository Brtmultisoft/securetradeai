import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:securetradeai/Data/Api.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:securetradeai/data/strings.dart';

class BotSetting extends StatefulWidget {
  const BotSetting({Key? key}) : super(key: key);

  @override
  _BotSettingState createState() => _BotSettingState();
}

class _BotSettingState extends State<BotSetting> {
  int statusBot = 0;
  bool isAPIcalled = false;
  _getBotSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => isAPIcalled = true);
    final res = await http.post(Uri.parse(getBotsetting),
        body: jsonEncode({"user_id": commonuserId}));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      print(data);
      if (data['status'] == "success") {
        setState(() {
          statusBot = int.parse(data['data']);
          botStatus = statusBot.toString();
        });
        prefs.setString('botstatus', data['data'].toString());
        setState(() => isAPIcalled = false);
      } else {
        showtoast(data['message'], context);
        setState(() => isAPIcalled = false);
      }
    } else {
      print("server Error");
      setState(() => isAPIcalled = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _getBotSetting();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text("Bot Setting"),
      ),
      body: isAPIcalled
          ? Center(
              child: CircularProgressIndicator(
                color: securetradeaicolor,
              ),
            )
          : Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      _chengeBot(0);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      height: 50,
                      child: Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset("assets/img/robot.svg",
                                    width: 18, height: 18, color: Colors.white),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Martin Bot",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              ],
                            ),
                            Visibility(
                              visible: statusBot == 0 ? true : false,
                              child: Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      _chengeBot(1);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      height: 50,
                      child: Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset("assets/img/robot.svg",
                                    width: 18, height: 18, color: Colors.white),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Automatic Trustcoin",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              ],
                            ),
                            Visibility(
                              visible: statusBot == 1 ? true : false,
                              child: Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  _chengeBot(int status) async {
    showLoading(context);
    try {
      final res = await http.post(Uri.parse(updateBot),
          body: jsonEncode(
              {"user_id": commonuserId, "bot_status": status.toString()}));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        print(data);
        if (data['status'] == "success") {
          _getBotSetting();
          Navigator.pop(context);
        } else {
          showtoast(data['message'], context);
          Navigator.pop(context);
        }
      } else {
        print("Server Error");
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
      Navigator.pop(context);
    }
  }
}
