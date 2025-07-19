import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:securetradeai/src/Service/assets_service.dart';

class ServiceAgreement extends StatelessWidget {
  final String sub;
  final String content;
  const ServiceAgreement({Key? key, required this.sub, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: const Text("Terms and Conditions"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Html(data: content)],
          ),
        ),
      ),
    );
  }
}
