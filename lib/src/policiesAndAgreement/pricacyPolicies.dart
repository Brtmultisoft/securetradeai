import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';

class PrivacyPolicies extends StatelessWidget {
  final String sub;
  final String content;
  const PrivacyPolicies({Key? key, required this.sub, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: const Text("Privacy Policy"),
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
