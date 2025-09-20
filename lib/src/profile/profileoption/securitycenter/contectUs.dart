import 'package:flutter/material.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ContectUs extends StatefulWidget {
  const ContectUs();

  @override
  State<ContectUs> createState() => _ContectUsState();
}

class _ContectUsState extends State<ContectUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: bg,
        title: const Text("Contact Us",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily)),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: ListView(
          children: [
            SizedBox(height: 15),
            Text(
              "Contact Us",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ContainerDesign("assets/img/logo.png", () async {
                    await launchUrl(Uri.parse("https://rapidtradeai.com/"));
                  }),
                  ContainerDesign("assets/img/whatsapp.png", () async {
                    await launchUrl(
                      Uri.parse(
                          "https://chat.whatsapp.com/IC5qeJvQX1gBddD3sQd1Nu"),
                      mode: LaunchMode.externalNonBrowserApplication,
                    );
                  }),
                  ContainerDesign("assets/img/telegram.png", () async {
                    launchUrl(
                      Uri.parse("https://t.me/trustgroup2023"),
                      mode: LaunchMode.externalNonBrowserApplication,
                    );
                  }),
                  ContainerDesign("assets/img/telephone.png", () async {
                    const url = "tel:+91 8160149688";
                    await launchUrl(Uri.parse(url));
                  }),
                ],
              ),
            ),
            SizedBox(height: 30),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  ContainerDesign("assets/img/email.png", () async {
                    final Uri params = Uri(
                      scheme: 'mailto',
                      path: 'ask@trustcoin.app',
                      // query:
                      //     'subject=App Feedback&body=App Version 3.23', //add subject and body here
                    );

                    var url = params.toString();
                    await launchUrl(Uri.parse(url));
                  }),
                ],
              ),
            ),
            SizedBox(height: 50),
            Text(
              "SOCIAL MEDIA",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 30),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ContainerDesign("assets/img/youtube.png", () async {
                    launchUrl(
                      Uri.parse("https://www.youtube.com/@trustgroup2023"),
                      mode: LaunchMode.externalNonBrowserApplication,
                    );
                  }),
                  ContainerDesign("assets/img/linkedin.png", () {
                    launchUrl(
                      Uri.parse(
                          "https://www.linkedin.com/company/trustgroup2023"),
                      mode: LaunchMode.externalNonBrowserApplication,
                    );
                  }),
                  ContainerDesign("assets/img/instagram.png", () {
                    launchUrl(
                      Uri.parse("https://www.instagram.com/trustgroup2023"),
                      mode: LaunchMode.externalNonBrowserApplication,
                    );
                  }),
                  ContainerDesign("assets/img/facebook.png", () {
                    launchUrl(
                      Uri.parse("https://www.facebook.com/TrustGroup2023"),
                      mode: LaunchMode.externalNonBrowserApplication,
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContainerDesign extends StatelessWidget {
  const ContainerDesign(this.img, this.click);
  final img;
  final Function click;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => click(),
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), //color of shadow
            spreadRadius: 5, //spread radius
            blurRadius: 7, // blur radius
            offset: Offset(0, 2), // changes position of shadow
            //first paramerter of offset is left-right
            //second parameter is top to down
          ),
          //you can set more BoxShadow() here
        ], color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(img),
          ),
        ),
      ),
    );
  }
}
