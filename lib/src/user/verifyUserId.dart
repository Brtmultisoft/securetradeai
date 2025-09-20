// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:rapidtradeai/src/Service/assets_service.dart';
// import 'package:rapidtradeai/src/User/signup.dart';
// import 'package:http/http.dart' as http;
// import 'package:timer_builder/timer_builder.dart';

// import '../../Data/Api.dart';

// class VerifyUserId extends StatefulWidget {
//   const VerifyUserId({Key? key, this.title}) : super(key: key);

//   final String? title;

//   @override
//   _VerifyUserIdState createState() => _VerifyUserIdState();
// }

// class _VerifyUserIdState extends State<VerifyUserId> {
//   var userId = TextEditingController();
//   bool isAPicalled = false;
//   bool visiblity = false;
//   var email = TextEditingController();
//   late DateTime alert;
//   var info;
//   var otp = TextEditingController();
//   @override
//   void initState() {
//     super.initState();
//     alert = DateTime.now().add(const Duration(seconds: 0));
//   }

//   Widget _submitButton() {
//     return InkWell(
//       onTap: _checkuserId,
//       child: Container(
//         width: MediaQuery.of(context).size.width,
//         padding: EdgeInsets.symmetric(vertical: 15),
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: primaryColor,
//           borderRadius: const BorderRadius.all(Radius.circular(5)),
//           boxShadow: const <BoxShadow>[
//             BoxShadow(
//                 color: Colors.black12,
//                 offset: Offset(2, 4),
//                 blurRadius: 5,
//                 spreadRadius: 2)
//           ],
//         ),
//         child: Text(
//           'submit'.tr,
//           style: TextStyle(fontSize: 20, color: Colors.white),
//         ),
//       ),
//     );
//   }

//   Widget _title() {
//     return Container(
//       height: 200,
//       child: Image.asset(
//         // "assets/img/banner4.png",
//         "assets/img/logo.png",
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     return Scaffold(
//         appBar: AppBar(
//           title: Text("verificationAccount".tr),
//         ),
//         body: Container(
//           color: bg,
//           height: height,
//           child: Stack(
//             children: <Widget>[
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 20),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       SizedBox(height: height * .1),
//                       _title(),
//                       SizedBox(height: 20),
//                       Container(
//                         margin: EdgeInsets.symmetric(vertical: 10),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: <Widget>[
//                             Text(
//                               "userid".tr,
//                               style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                   fontSize: 15),
//                             ),
//                             SizedBox(
//                               height: 5,
//                             ),
//                             Container(
//                               height: 50,
//                               decoration: BoxDecoration(
//                                   border: Border.all(
//                                     color: Color(0xfff3f3f4),
//                                   ),
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(10))),
//                               child: Center(
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(left: 8.0),
//                                   child: TextField(
//                                       style: TextStyle(color: Colors.white),
//                                       controller: userId,
//                                       decoration: const InputDecoration(
//                                         border: InputBorder.none,
//                                         enabledBorder: InputBorder.none,
//                                         focusedBorder: InputBorder.none,
//                                       )),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Visibility(
//                         visible: visiblity,
//                         child: Container(
//                           margin: EdgeInsets.symmetric(vertical: 10),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               const Text(
//                                 "Enter OTP",
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                     fontSize: 15),
//                               ),
//                               SizedBox(
//                                 height: 5,
//                               ),
//                               Container(
//                                 height: 50,
//                                 decoration: BoxDecoration(
//                                     border: Border.all(
//                                       color: Color(0xfff3f3f4),
//                                     ),
//                                     borderRadius:
//                                         BorderRadius.all(Radius.circular(10))),
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 8.0, right: 8),
//                                   child: TextField(
//                                       keyboardType: TextInputType.number,
//                                       maxLines: 1,
//                                       controller: otp,
//                                       style: TextStyle(color: Colors.white),
//                                       decoration: InputDecoration(
//                                         suffix: Container(
//                                           width: 100,
//                                           height: 30,
//                                           decoration: BoxDecoration(
//                                               color: primaryColor,
//                                               borderRadius: BorderRadius.all(
//                                                   Radius.circular(10))),
//                                           child: Center(
//                                             child: TimerBuilder.scheduled(
//                                                 [alert], builder: (context) {
//                                               var now = DateTime.now();
//                                               var reached =
//                                                   now.compareTo(alert) >= 0;
//                                               return !reached
//                                                   ? TimerBuilder.periodic(
//                                                       Duration(seconds: 1),
//                                                       alignment: Duration.zero,
//                                                       builder: (context) {
//                                                       // This function will be called every second until the alert time
//                                                       var now = DateTime.now();
//                                                       var remaining =
//                                                           alert.difference(now);
//                                                       return Text(
//                                                         formatDuration(
//                                                             remaining),
//                                                         style: TextStyle(
//                                                             color:
//                                                                 Colors.white),
//                                                       );
//                                                     })
//                                                   : InkWell(
//                                                       onTap: () {
//                                                         _sendMailOTP(
//                                                             email.text);
//                                                       },
//                                                       child: const Text(
//                                                         "Resend",
//                                                         style: TextStyle(
//                                                             color:
//                                                                 Colors.white),
//                                                       ),
//                                                     );
//                                             }),
//                                           ),
//                                         ),

//                                         border: InputBorder.none,
//                                         enabledBorder: InputBorder.none,
//                                         focusedBorder: InputBorder.none,
//                                         // contentPadding: EdgeInsets.symmetric(vertical: 13.0),

//                                         // border: InputBorder.none,
//                                       )),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       isAPicalled
//                           ? CircularProgressIndicator(
//                               color: rapidtradeaicolor,
//                             )
//                           : _submitButton(),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ));
//   }

//   Future _sendMailOTP(String email) async {
//     try {
//       final response = await http.post(
//         Uri.parse(sendOtp),
//         body: jsonEncode({"email": email, "type": "Email"}),
//       );
//       if (response.statusCode != 200) {
//       } else if (response.body != '') {
//         var data = jsonDecode(response.body);
//         print(response.body);
//         if (data['status'] == 'success') {
//           showtost("OTP send successfully", context);
//           setState(() {
//             alert = DateTime.now().add(const Duration(minutes: 2));
//           });
//           setState(() {
//             visiblity = true;
//           });
//         } else {
//           showtost(data['message'], context);
//           print(data['message']);
//         }
//       }
//     } on SocketException {
//       showtost("Check Internet", context);
//       print('Socket Exception');
//     }
//   }

// // sdkjfhui4534fhmpsjrj
//   _checkuserId() async {
//     if (visiblity) {
//       try {
//         setState(() {
//           isAPicalled = true;
//         });
//         if (otp.text.isEmpty) {
//           showtost("OTP field is Empty", context);
//           setState(() {
//             isAPicalled = false;
//           });
//         } else {
//           final res = await http.post(Uri.parse(emailVerify),
//               body: json.encode({"email": email.text, "otp": otp.text}));
//           if (res.statusCode == 200) {
//             var data = jsonDecode(res.body);
//             if (data['status'] == 'success') {
//               showtost(data['message'], context);
//               print(info);
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const SignUpPage(
//                           // name: info['name'] == null ? "" : info['name'],
//                           // refferdby: info['reffereby'] == null
//                           //     ? ""
//                           //     : info['reffereby'],
//                           // mpbile:
//                           //     info['mobile'] == null ? "" : info['mobile'],
//                           // mail: info['mail'] == null ? "" : info['mail'],
//                           // OTP: data['data']['otp'] == null
//                           //     ? ""
//                           //     : data['data']['otp'],
//                           // uid: info['uid'] == null ? "" : info['uid'],
//                           )));
//               setState(() {
//                 isAPicalled = false;
//               });
//             } else {
//               showtost(data['message'], context);
//               setState(() {
//                 isAPicalled = false;
//               });
//             }
//           } else {
//             showtost("Server Error Try Again", context);
//             setState(() {
//               isAPicalled = false;
//             });
//           }
//         }
//       } catch (e) {
//         print(e);
//         setState(() {
//           isAPicalled = false;
//         });
//       }
//     } else {
//       try {
//         setState(() {
//           isAPicalled = true;
//         });
//         if (userId.text.isEmpty) {
//           showtost("User Id is Empty", context);
//           setState(() {
//             isAPicalled = false;
//           });
//         } else {
//           final res = await http.get(Uri.parse(
//               "https://pttncoin.io/pricing.asmx/GetMember?uid=${userId.text}&ackey=sdkjfhui4534fhmpsjrj"));
//           // "https://pttncoin.io/pricing.asmx/GetMember?uid=520916&ackey=sdkjfhui4534fhmpsjrj"));
//           if (res.statusCode == 200) {
//             var data = jsonDecode(res.body);
//             print(data);
//             if (data['uid'] != null) {
//               showtost("User Found", context);
//               _sendMailOTP(data['mail']);
//               setState(() {
//                 info = data;
//                 email.text = data['mail'];
//                 isAPicalled = false;
//               });
//             } else {
//               showtost(data['status'], context);
//               setState(() {
//                 isAPicalled = false;
//               });
//             }
//           } else {
//             showtost("Server Error Try Again", context);
//             setState(() {
//               isAPicalled = false;
//             });
//           }
//         }
//       } catch (e) {
//         print(e);
//         setState(() {
//           isAPicalled = false;
//         });
//       }
//     }
//   }
// }
