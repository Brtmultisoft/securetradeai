import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../Data/Api.dart';

class Quantitative extends StatefulWidget {
  const Quantitative({Key? key}) : super(key: key);

  @override
  _QuantitativeState createState() => _QuantitativeState();
}

class _QuantitativeState extends State<Quantitative> {
  bool isAPIcalled = false;
  var finaldata;
  bool checkdata = false;
  _getData() async {
    setState(() {
      isAPIcalled = true;
    });
    final res = await http.get(Uri.parse(videos));
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      print(data);
      if (data['status'] == "success") {
        setState(() {
          finaldata = data['data'];
          isAPIcalled = false;
        });
        return;
      }
      setState(() {
        isAPIcalled = false;
        checkdata = true;
      });
    }
    setState(() {
      isAPIcalled = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            "Videos".tr,
            style: const TextStyle(
                fontFamily: fontFamily, fontSize: 20, color: Colors.black),
          ),
        ),
        body: isAPIcalled
            ? Center(
                child: CircularProgressIndicator(color: securetradeaicolor),
              )
            : checkdata
                ? Container(
                    child: Center(
                        child: Image.asset(
                      "assets/img/logo.png",
                      height: 200,
                    )),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                            itemCount: finaldata.length,
                            itemBuilder: (context, index) {
                              // var a = finaldata[index]['video_link']
                              //     .toString()
                              //     .replaceAll('&lt;', "<");
                              // var b = a.replaceAll('&gt;', ">");
                              // print(b);
                              final YoutubePlayerController _controller =
                                  YoutubePlayerController(
                                initialVideoId: finaldata[index]['video_link'],
                                flags: const YoutubePlayerFlags(
                                  autoPlay: true,
                                  mute: false,
                                ),
                              );
                              return Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10),
                                    Container(
                                      margin: EdgeInsets.only(left: 10),
                                      child: Text(
                                        finaldata[index]['title'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    YoutubePlayer(
                                      controller: _controller,
                                      liveUIColor: Colors.amber,
                                    ),
                                    Divider()
                                  ],
                                ),
                              );
                            }),
                      )
                    ],
                  ));
  }
}
