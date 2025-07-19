import 'dart:io';
import 'package:flutter/material.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewExample extends StatefulWidget {
  WebviewExample({Key? key, this.title, this.url}) : super(key: key);
  final title;
  final url;
  @override
  _WebviewExampleState createState() => _WebviewExampleState();
}

class _WebviewExampleState extends State<WebviewExample> {
  int position = 1;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: IndexedStack(index: position, children: <Widget>[
          WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
            onPageStarted: (value) {
              setState(() {
                position = 1;
              });
            },
            onPageFinished: (value) {
              setState(() {
                position = 0;
              });
            },
          ),
          Container(
            child: Center(
                child: CircularProgressIndicator(
              color: securetradeaicolor,
            )),
          ),
        ]));
  }
}
