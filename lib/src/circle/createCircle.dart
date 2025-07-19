// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:securetradeai/src/Service/assets_service.dart';

// import '../../Data/Api.dart';

// class CreateCircle extends StatefulWidget {
//   const CreateCircle({Key? key}) : super(key: key);

//   @override
//   _CreateCircleState createState() => _CreateCircleState();
// }

// class _CreateCircleState extends State<CreateCircle> {
//   var text = TextEditingController();
//   var title = TextEditingController();
//   var price = TextEditingController();

//   File? imageFile;
//   String filePath = '';
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: bg,
//       appBar: AppBar(
//         title: const Text("Create Circle"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: SingleChildScrollView(
//           child: Column(children: [
//             Container(
//               // height: 50,
//               decoration: BoxDecoration(
//                   border: Border.all(
//                     color: Color(0xfff3f3f4),
//                   ),
//                   borderRadius: BorderRadius.all(Radius.circular(10))),
//               child: Center(
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 8.0),
//                   child: TextField(
//                       style: TextStyle(color: Colors.white),
//                       controller: title,
//                       decoration: const InputDecoration(
//                         hintStyle: TextStyle(color: Colors.white70),
//                         hintText: "Circle title",
//                         border: InputBorder.none,
//                         enabledBorder: InputBorder.none,
//                         focusedBorder: InputBorder.none,
//                       )),
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             Container(
//               // height: 50,
//               decoration: BoxDecoration(
//                   border: Border.all(
//                     color: Color(0xfff3f3f4),
//                   ),
//                   borderRadius: BorderRadius.all(Radius.circular(10))),
//               child: Center(
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 8.0),
//                   child: TextField(
//                       keyboardType: TextInputType.number,
//                       style: TextStyle(color: Colors.white),
//                       controller: price,
//                       decoration: const InputDecoration(
//                         hintStyle: TextStyle(color: Colors.white70),
//                         hintText: "Price",
//                         border: InputBorder.none,
//                         enabledBorder: InputBorder.none,
//                         focusedBorder: InputBorder.none,
//                       )),
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             Container(
//               // height: 50,
//               decoration: BoxDecoration(
//                   border: Border.all(
//                     color: Color(0xfff3f3f4),
//                   ),
//                   borderRadius: BorderRadius.all(Radius.circular(10))),
//               child: Center(
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 8.0),
//                   child: TextField(
//                       maxLines: 5,
//                       style: TextStyle(color: Colors.white),
//                       controller: text,
//                       decoration: const InputDecoration(
//                         hintStyle: TextStyle(color: Colors.white70),
//                         hintText: "Write something here...",
//                         border: InputBorder.none,
//                         enabledBorder: InputBorder.none,
//                         focusedBorder: InputBorder.none,
//                       )),
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             imageFile == null
//                 ? Container()
//                 : Stack(
//                     children: [
//                       Container(
//                         color: Colors.white,
//                         child: Image.file(
//                           imageFile!,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       Container(
//                           alignment: Alignment.topRight,
//                           child: IconButton(
//                               onPressed: () => showsnakbar(context),
//                               icon: Icon(
//                                 Icons.edit,
//                                 color: Colors.white,
//                               ))),
//                     ],
//                   ),
//             Visibility(
//               visible: imageFile != null ? false : true,
//               child: InkWell(
//                 onTap: () => showsnakbar(context),
//                 child: Row(
//                   children: const [
//                     Icon(
//                       Icons.image,
//                       color: Colors.white,
//                     ),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     Text(
//                       "Image",
//                       style: TextStyle(
//                           color: Colors.white, fontWeight: FontWeight.bold),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 80),
//           ]),
//         ),
//       ),
//       bottomSheet: Container(color: bg, height: 70, child: _submitButton()),
//     );
//   }

//   Widget _submitButton() {
//     return InkWell(
//       onTap: _CreateCircle,
//       child: Container(
//         margin: EdgeInsets.all(10),
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
//           "Submit",
//           style: TextStyle(fontSize: 20, color: Colors.white),
//         ),
//       ),
//     );
//   }

//   showsnakbar(context) {
//     showModalBottomSheet(
//         context: context,
//         backgroundColor: Colors.transparent,
//         builder: (BuildContext bc) {
//           return Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Container(
//               height: 100.0,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(30.0),
//               ),
//               child: Padding(
//                   padding: const EdgeInsets.all(15.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Column(
//                         children: [
//                           IconButton(
//                               onPressed: () {
//                                 _getFromGallery(ImageSource.gallery);
//                               },
//                               icon: Icon(
//                                 Icons.image,
//                                 size: 40,
//                               )),
//                           Text("Gallery")
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           IconButton(
//                               onPressed: () {
//                                 _getFromGallery(ImageSource.camera);
//                               },
//                               icon: Icon(Icons.camera, size: 40)),
//                           Text("Camera")
//                         ],
//                       )
//                     ],
//                   )),
//             ),
//           );
//         });
//   }

//   _getFromGallery(ImageSource source) async {
//     PickedFile? pickedFile = await ImagePicker().pickImage(
//       source: source,
//       maxWidth: 1800,
//       maxHeight: 1800,
//     );
//     if (pickedFile != null) {
//       setState(() {
//         imageFile = File(pickedFile.path);
//         print(imageFile);
//         // _updateProfile();
//         filePath = File(pickedFile.path).toString();
//         Navigator.pop(context);
//       });
//     }
//   }

//   _CreateCircle() async {
//     if (title.text.isEmpty) {
//       showtost("Title is empty", context);
//     } else if (text.text.isEmpty) {
//       showtost("Discription is empty", context);
//     } else if (price.text.isEmpty) {
//       showtost("Price is empty", context);
//     } else {
//       showLoading(context);
//       var bytes = await imageFile!.readAsBytesSync();
//       var base = await base64Encode(bytes);
//       var bodydata = jsonEncode({
//         'user_id': commonuserId,
//         "title": title.text,
//         "description": text.text,
//         "price": price.text,
//         'circle_banner_image': base,
//       });
//       print(bodydata);
//       final response = await http.post(Uri.parse(createCircle), body: bodydata);
//       switch (response.statusCode) {
//         case 200:
//           var data = jsonDecode(response.body);
//           print(data);
//           if (data['status'] == "success") {
//             showtost("Circle Create Success", context);
//             title.clear();
//             text.clear();
//             price.clear();
//             imageFile = null;
//             Navigator.pop(context);
//           } else {
//             showtost("User already have a circle", context);
//             title.clear();
//             text.clear();
//             price.clear();
//             imageFile = null;
//             Navigator.pop(context);
//           }
//           break;
//         case 401:
//           print('Invalid Details');
//           Navigator.pop(context);
//           break;
//         default:
//           print('Exception');
//           Navigator.pop(context);
//       }
//     }
//   }
// }
