import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/data/api.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/widget/lottie_loading_widget.dart';

class News extends StatefulWidget {
  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> {
  var newsList = [];
  var scrollController = ScrollController();
  bool updating = false;
  int count = 1;
  bool checkdata = false;
  _getNewsdata() async {
    try {
      final response = await http.post(
        Uri.parse(userNews),
        body: jsonEncode(
            {"user_id": commonuserId, "page": count.toString(), "size": "100"}),
        headers: {'Content-Type': 'application/json', 'Charset': 'utf-8'},
      );
      var data = jsonDecode(response.body);
      if (data['status'] == "success") {
        setState(() {
          newsList.addAll(data['data']);
        });
        return true;
      } else {
        showtoast(data['message'], context);
        setState(() {
          checkdata = count > 1 ? false : true;
        });
        // setState(() => checkdata = true);
        return false;
      }
    } catch (e) {
      print(e);
    }
  }

  checkUpdate() async {
    showLoading(context);
    var scrollpositin = scrollController.position;
    if (scrollpositin.pixels == scrollpositin.maxScrollExtent) {
      setState(() {
        count++;
      });
      _getNewsdata();
    }
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _getNewsdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A2234),
          elevation: 0,
          title: const Text("Order Information",
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.bold)),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A2234),
                Color(0xFF161D2B),
              ],
            ),
          ),
          child: checkdata
              ? Center(
                  child: Image.asset(
                  "assets/img/logo.png",
                  height: 200,
                ))
              : listdata(),
        ));
  }

  Widget listdata() {
    if (newsList.isEmpty) return const Center(child: LottieLoadingWidget.large());
    return NotificationListener<ScrollNotification>(
      onNotification: (noti) {
        if (noti is ScrollEndNotification) {
          checkUpdate();
        }
        return true;
      },
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemBuilder: (c, i) {
                final isBuy = newsList[i]['sell_or_buy'] == 'buy';
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1E293B),
                        Color(0xFF1A2234),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2A3A5A),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: isBuy
                                          ? [
                                              const Color(0xFF00C853)
                                                  .withOpacity(0.2),
                                              const Color(0xFF00C853)
                                                  .withOpacity(0.1),
                                            ]
                                          : [
                                              const Color(0xFFE53935)
                                                  .withOpacity(0.2),
                                              const Color(0xFFE53935)
                                                  .withOpacity(0.1),
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isBuy
                                          ? const Color(0xFF00C853).withOpacity(0.3)
                                          : const Color(0xFFE53935).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    isBuy
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: isBuy
                                        ? const Color(0xFF00C853)
                                        : const Color(0xFFE53935),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  newsList[i]['crypto_pair'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: fontFamily,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A3A5A).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFF2A3A5A).withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                newsList[i]['createdate'],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontFamily: fontFamily,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Average Price',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontFamily: fontFamily,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  newsList[i]['avg_price'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: fontFamily,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Quantity',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontFamily: fontFamily,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  newsList[i]['qty'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: fontFamily,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: newsList.length,
            ),
          ),
          if (updating)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: LottieLoadingWidget.large(),
              ),
            ),
        ],
      ),
    );
  }
}
