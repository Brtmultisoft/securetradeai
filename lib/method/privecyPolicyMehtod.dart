import 'package:http/http.dart' as http;
import 'package:rapidtradeai/Data/Api.dart';
import 'package:rapidtradeai/model/privecyPolicy.dart';

class PolicyMethod {
  getPrivicyPolicyData() async {
    try {
      final response = await http.get(
        Uri.parse(privacyPolicy),
        headers: {'Content-Type': 'application/json', 'Charset': 'utf-8'},
      );
      if (response.statusCode == 200) {
        return privacyPolicyFromJson(response.body);
      } else {
        print("something wrong");
      }
    } catch (e) {
      print(e);
    }
  }

  getAgreeMent() async {
    try {
      final response = await http.get(
        Uri.parse(agreeMent),
        headers: {'Content-Type': 'application/json', 'Charset': 'utf-8'},
      );
      if (response.statusCode == 200) {
        return privacyPolicyFromJson(response.body);
      } else {
        print("something wrong");
      }
    } catch (e) {
      print(e);
    }
  }
}
