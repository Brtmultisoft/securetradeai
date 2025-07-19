import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

const String logo = "assets/img/logo.png";
bool checkBalance = false;
Color bg = const Color.fromARGB(255, 248, 249, 250);
const String img1 = "assets/img/1.jpeg";
const String img2 = "assets/img/2.jpg";
const String img3 = "assets/img/3.jpg";
const String fontFamily = "Nunito";
final Color primaryColor = const Color(0xFF45C2DA);
final Color securetradeaicolor = const Color.fromARGB(255, 58, 184, 166);
final Color backgroundColor = Colors.grey;
final Color shimmer_base = Colors.grey.shade50;
final Color shimmer_highlighted = Colors.blueGrey.shade50;

// color class

// size class

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? width;
  static double? height;
  static double? titleSize;
  static double? fontSize;
  static double? mFontSize;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    width = _mediaQueryData!.size.width;
    height = _mediaQueryData!.size.height;
    titleSize = _mediaQueryData!.size.width * 0.08;
    fontSize = _mediaQueryData!.size.width * 0.04;
    mFontSize = _mediaQueryData!.size.width * 0.06;
  }
}

showtoast(String text, BuildContext context) {
  ToastContext().init(context); // Required to initialize Toast

  Toast.show(
    text,
    textStyle: const TextStyle(
      color: Colors.black,
      fontSize: 14,
    ),
    webTexColor: Colors.black,
    backgroundColor: const Color.fromRGBO(239, 239, 239, .9),
    border: const Border(
      top: BorderSide(color: Color.fromRGBO(203, 209, 209, 1)),
      bottom: BorderSide(color: Color.fromRGBO(203, 209, 209, 1)),
      right: BorderSide(color: Color.fromRGBO(203, 209, 209, 1)),
      left: BorderSide(color: Color.fromRGBO(203, 209, 209, 1)),
    ),
    backgroundRadius: 6,
  );
}


showLoading(context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => Center(
      child: Container(
        width: 60.0,
        height: 60.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: const Padding(
          padding: EdgeInsets.all(12.0),
          child: CupertinoActivityIndicator(),
        ),
      ),
    ),
  );
}

// language
String lang = '';

class GetColor {
  getcolor() {
    // if (bg == Colors.black) {
    //  bg =  Colors.white;
    // } else {
    //   print("not ok");
    // }
  }
}
