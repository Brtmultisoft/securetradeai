import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rapidtradeai/data/api.dart';
import 'package:rapidtradeai/data/strings.dart';

class CircleProvider extends ChangeNotifier {
  var circledata = [];
  var circleTradeSettingData = [];
  Future<bool> getCircleDataMethod(int page) async {
    final res = await http.post(Uri.parse(circleData),
        body: jsonEncode(
            {"user_id": commonuserId, "page": page.toString(), "size": "100"}));
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      if (data['status'] == "success") {
        circledata = data['data'];
      } else {
        print(data['message']);
      }
      notifyListeners();
      return false;
    } else {
      print("Circle data not found");
      return true;
    }
  }

  // trade setting get data method
  getTradeSettingData() async {
    final res = await http.post(Uri.parse(cirlceTradeSettingData),
        body: jsonEncode({"user_id": commonuserId}));
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      if (data['status'] == "success") {
        circleTradeSettingData = data['data'];
      } else {
        print(data['message']);
      }
    } else {
      print("CircelTradeSetting data not found");
    }
    notifyListeners();
  }
}
