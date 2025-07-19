import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:securetradeai/Data/Api.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/data/strings.dart';

class Create extends StatefulWidget {
  const Create({Key? key}) : super(key: key);

  @override
  _CreateState createState() => _CreateState();
}

class _CreateState extends State<Create> {
  var subject = TextEditingController();
  var body = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "create".tr,
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 15, right: 15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: subject,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: securetradeaicolor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: securetradeaicolor,
                    ),
                  ),
                  hintText: 'subject'.tr,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: body,
                maxLines: 8,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: securetradeaicolor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: securetradeaicolor,
                    ),
                  ),
                  hintText: 'body'.tr,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              _submitButton()
            ],
          ),
        ),
      ),
    );
  }

  Future _sendMsg() async {
    showLoading(context);
    if (subject.text.isEmpty) {
      showtoast("Subject field is empty", context);
      Navigator.pop(context);
    } else if (body.text.isEmpty) {
      showtoast("Body field is empty", context);
      Navigator.pop(context);
    } else {
      final res = await http.post(Uri.parse(sendmsg),
          body: jsonEncode({
            "user_id": commonuserId,
            "subject": subject.text,
            "msg": body.text
          }));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['status'] == "success") {
          showtoast(data['message'], context);
          subject.clear();
          body.clear();
          Navigator.pop(context);
        } else {
          showtoast(data['message'], context);
          Navigator.pop(context);
        }
      } else {
        showtoast("Server Error", context);
        Navigator.pop(context);
      }
    }
  }

  Widget _submitButton() {
    return InkWell(
      onTap: _sendMsg,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 1.0],
            colors: [
              primaryColor,
              Colors.blue,
            ],
          ),
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
                color: Colors.black12,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
        ),
        child: Text(
          'submit'.tr,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
