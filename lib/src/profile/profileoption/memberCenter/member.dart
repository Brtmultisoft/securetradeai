import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/src/Service/assets_service.dart';

import '../../../../Data/Api.dart';
import '../../../../method/methods.dart';

class mamberCenter extends StatefulWidget {
  mamberCenter({
    Key? key,
  }) : super(key: key);

  @override
  _mamberCenterState createState() => _mamberCenterState();
}

class _mamberCenterState extends State<mamberCenter> {
  bool closeTopContainer = false;
  bool isAPIcalle = false;
  var finalData;
  var minedata;
  String convertedDateTime = "";

  _getData() async {
    try {
      setState(() {
        isAPIcalle = true;
      });
      final data = await CommonMethod().getMineData();
      if (data.status == "success") {
        setState(() {
          minedata = data.data;
          minedata.forEach((e) {
            finalData = e;
          });
          DateTime now = DateTime.parse(finalData.doa.toString());
          convertedDateTime =
              "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
          print(convertedDateTime);
          isAPIcalle = false;
        });
      } else {
        showtoast(data.message, context);
      }
    } catch (e) {
      print(e);
      setState(() {
        isAPIcalle = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height * 0.25;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: bg,
            iconTheme: IconThemeData(color: Colors.black),
            title: Text(
              //"securetradeai".tr,
              "Secure Trade Ai",
              style: TextStyle(color: Colors.black),
            )),
        body: isAPIcalle
            ? Center(
                child: CircularProgressIndicator(color: securetradeaicolor),
              )
            : Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.2,
                        ),
                        painter: HeaderCurvedContainer(),
                      ),
                      topHeader('today', 'cumulative'),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                            child: Text("vip_mamver_rights".tr,
                                style: TextStyle(
                                    fontFamily: fontFamily,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16))),
                        Container(
                          margin: EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Material(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: [0.0, 1.0],
                                      colors: [
                                        Colors.green,
                                        Colors.blue,
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                  height: 40,
                                  width: 40,
                                  child: Center(
                                      child: SvgPicture.asset(
                                          "assets/img/robot.svg",
                                          width: 18,
                                          height: 18,
                                          color: Colors.white)),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      child: Text(
                                    "direct_recommend".tr,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: fontFamily),
                                  )),
                                  SizedBox(height: 5),
                                  Container(
                                      child: Text(
                                    "robot_activation_direct".tr,
                                    style: TextStyle(
                                        fontSize: 10, fontFamily: fontFamily),
                                  ))
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          margin: EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Material(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: [0.0, 1.0],
                                      colors: [
                                        Colors.green,
                                        Colors.blue,
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                  height: 40,
                                  width: 40,
                                  child: Center(
                                      child: Image.asset("assets/img/team.png",
                                          width: 20,
                                          height: 20,
                                          color: Colors.white)),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      child: Text(
                                    "team_reward".tr,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: fontFamily),
                                  )),
                                  SizedBox(height: 5),
                                  Container(
                                      child: Text(
                                    "profit_distrubution".tr,
                                    style: TextStyle(
                                        fontSize: 10, fontFamily: fontFamily),
                                  ))
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                            child: Text("mamber_uses".tr,
                                style: TextStyle(
                                    fontFamily: fontFamily,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16))),
                        SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                margin: EdgeInsets.only(left: 10, right: 10),
                                child: Text(
                                  "1".tr,
                                  style: TextStyle(
                                      fontSize: 11, fontFamily: fontFamily),
                                )),
                            Container(
                                margin: EdgeInsets.only(left: 10, right: 10),
                                child: Text(
                                  "2".tr,
                                  style: TextStyle(
                                      fontSize: 11, fontFamily: fontFamily),
                                ))
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }

  String maskEmail(String email) {
    int atIndex = email.indexOf('@');
    if (atIndex <= 3) {
      // If the email has 3 or fewer characters before the '@', just mask it all.
      return email.replaceRange(1, atIndex, '*' * (atIndex - 1));
    } else {
      // Mask all characters after the first 3 and before the '@'.
      return email.replaceRange(3, atIndex, '****');
    }
  }

  Widget topHeader(String today, comulative) {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height * 0.15;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 10,
        ),
        Container(
          margin: EdgeInsets.only(right: 10, left: 10),
          width: double.infinity,
          height: categoryHeight,
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
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            margin: EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 20.0,
                          backgroundImage: finalData.image == null
                              ? NetworkImage(imagepath + "default.jpg")
                              : NetworkImage(imagepath + finalData.image),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                finalData.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                "Email: ${maskEmail(finalData.email)}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                "DOA: ${convertedDateTime}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (finalData.daysBal.toString() == '0')
                      ElevatedButton(
                        onPressed: () {
                          // Action when the button is clicked and daysBal is 0
                          _showActivationDialog(
                              context, finalData); // Pass finalData here
                          print('Active button pressed!');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red, // Background color of the button
                          foregroundColor:
                              Colors.white, // Text color of the button
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Active',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[
                              300], // Light grey to resemble a disabled button
                          borderRadius:
                              BorderRadius.circular(8.0), // Rounded corners
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 3.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Active',
                              style: TextStyle(
                                color: Colors.grey[
                                    600], // Slightly darker grey for the text
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8.0), // Space between text and icon
                            Icon(
                              Icons.check_circle,
                              color: Colors
                                  .green, // Green color for the check mark
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showActivationDialog(BuildContext context, finalData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ID Active'),
          content: Text(
            'Activation Fee \$50 will be deducted. Are you sure you want to continue?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _activateUser(finalData); // Pass finalData to _activateUser
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _activateUser(finalData) async {
    try {
      // Set the headers for JSON content
      var headers = {
        'Content-Type': 'application/json',
      };

      // Convert the body to JSON
      var body = jsonEncode({
        'user_id': finalData.userId,
      });

      // Send the POST request with headers and JSON body
      var response = await http.post(
        Uri.parse(userActivation),
        headers: headers,
        body: body,
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Parse the response body
        var responseBody = jsonDecode(response.body);

        if (responseBody['status'] == 'success') {
          // Handle success case
          _showMessage(context,
              responseBody['message'] ?? 'User activated successfully.');
          print('User activated successfully.');
        } else if (responseBody['status'] == 'error') {
          // Handle error case
          _showMessage(
              context, responseBody['message'] ?? 'Failed to activate user');
          print('Failed to activate user');
        } else {
          // Handle unexpected status
          print('Unexpected response status: ${responseBody['status']}');
        }
      } else {
        // Handle HTTP error response
        print('Failed to activate user. HTTP Status: ${response.statusCode}');
      }
    } catch (e) {
      // Catch and handle any errors that occur
      print('Error: $e');
    }
  }
}

void _showMessage(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Activation Status'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

// CustomPainter class to for the header curved-container
class HeaderCurvedContainer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = bg;
    Path path = Path()
      ..relativeLineTo(0, 80)
      ..quadraticBezierTo(size.width / 2, 80.0, size.width, 80)
      ..relativeLineTo(0, -80)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
