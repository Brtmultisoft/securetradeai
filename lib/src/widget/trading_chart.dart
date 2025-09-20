import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';

class TradingChart extends StatefulWidget {
  final String symbol;
  
  const TradingChart({Key? key, required this.symbol}) : super(key: key);

  @override
  _TradingChartState createState() => _TradingChartState();
}

class _TradingChartState extends State<TradingChart> {
  bool isLoading = true;
  bool hasError = false;

  String _getTradingViewWidget(String symbol) {
    String cleanSymbol = symbol.toUpperCase().replaceAll(' ', '');
    return '''
      <!DOCTYPE html>
      <html style="height: 100%; width: 100%; margin: 0; padding: 0;">
        <head>
          <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0'>
          <style>
            body { 
              margin: 0; 
              padding: 0;
              height: 100%; 
              width: 100%;
              background: #0F172A;
              display: flex;
            }
            #container {
              flex: 1;
              min-height: 400px;
            }
          </style>
        </head>
        <body>
          <div id="container"></div>
          <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
          <script type="text/javascript">
            new TradingView.widget({
              "autosize": true,
              "fullscreen": true,
              "width": "100%",
              "height": "100%",
              "symbol": "BINANCE:${cleanSymbol}",
              "interval": "1",
              "timezone": "exchange",
              "theme": "dark",
              "style": "1",
              "toolbar_bg": "#0F172A",
              "enable_publishing": false,
              "hide_side_toolbar": false,
              "allow_symbol_change": true,
              "save_image": false,
              "container_id": "container"
            });
          </script>
        </body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: WebView(
        initialUrl: 'about:blank',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          webViewController.loadUrl(Uri.dataFromString(
            _getTradingViewWidget(widget.symbol),
            mimeType: 'text/html',
            encoding: utf8
          ).toString());
        },
        onPageFinished: (String url) {
          setState(() {
            isLoading = false;
          });
        },
        backgroundColor: const Color(0xFF0F172A),
        gestureNavigationEnabled: false,
      ),
    );
  }
} 