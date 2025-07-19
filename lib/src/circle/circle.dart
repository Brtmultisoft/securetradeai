// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:get/get.dart';
// import 'package:like_button/like_button.dart';
// import 'package:provider/provider.dart';
// import 'package:securetradeai/Data/Api.dart';
// import 'package:securetradeai/Method/cycleMethod.dart';
// import 'package:securetradeai/src/Circle/CircleTradeSetting.dart';
// import 'package:securetradeai/src/Circle/CreateCircle.dart';
// import 'package:securetradeai/src/Circle/bannerDetail.dart';
// import 'package:securetradeai/src/Circle/circleIncome.dart';
// import 'package:securetradeai/src/Circle/menuitem.dart';
// import 'package:securetradeai/src/Service/assets_service.dart';
// import 'profileImageClick.dart';

// class Robot extends StatefulWidget {
//   const Robot({Key? key}) : super(key: key);

//   @override
//   _RobotState createState() => _RobotState();
// }

// class _RobotState extends State<Robot> {
//   int like = 0;
//   bool checkData = false;
//   bool finalisLiked = false;
//   var scrollController = ScrollController();
//   bool updating = false;
//   int count = 1;
//   _getData() {
//     final circle = Provider.of<CircleProvider>(context, listen: false);
//     final hasdataornot = circle.getCircleDataMethod(count);
//     hasdataornot.then((value) {
//       setState(() {
//         checkData = value;
//       });
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _getData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: bg,
//       appBar: AppBar(
//         backgroundColor: bg,
//         title: Text("circle".tr,
//             style:
//                 TextStyle(fontFamily: fontfamily, fontWeight: FontWeight.bold)),
//         actions: [
//           Center(
//             child: Row(
//               children: [
//                 Text(
//                   "Filter",
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 Container(
//                   margin: EdgeInsets.only(right: 10),
//                   child: DropdownButtonHideUnderline(
//                     child: DropdownButton2(
//                       customButton: const Icon(
//                         Icons.filter_alt,
//                         size: 30,
//                         color: Colors.white,
//                       ),
//                       customItemsIndexes: const [3],
//                       customItemsHeight: 8,
//                       items: [
//                         ...MenuItems.firstItems.map(
//                           (item) => DropdownMenuItem<MenuItem>(
//                             value: item,
//                             child: MenuItems.buildItem(item),
//                           ),
//                         ),
//                       ],
//                       onChanged: (value) {
//                         MenuItems.onChanged(context, value as MenuItem);
//                       },
//                       itemHeight: 48,
//                       itemPadding: const EdgeInsets.only(left: 16, right: 16),
//                       dropdownWidth: 160,
//                       dropdownPadding: const EdgeInsets.symmetric(vertical: 10),
//                       dropdownDecoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(4),
//                         color: bg,
//                       ),
//                       dropdownElevation: 8,
//                       offset: const Offset(0, 8),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//       floatingActionButton: SpeedDial(
//         backgroundColor: bg,
//         animatedIcon: AnimatedIcons.menu_close,
//         overlayOpacity: 0.0,
//         childPadding: EdgeInsets.symmetric(vertical: 8),
//         children: [
//           SpeedDialChild(
//               onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const CircleTradeIncome())),
//               child: Icon(
//                 Icons.pie_chart,
//                 color: Colors.white,
//               ),
//               backgroundColor: primaryColor,
//               label: "tradeSetting".tr),
//           SpeedDialChild(
//               onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const CircleIncome())),
//               child: Icon(
//                 Icons.attach_money,
//                 color: Colors.white,
//               ),
//               backgroundColor: primaryColor,
//               label: "income".tr),
//           SpeedDialChild(
//               onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const CreateCircle())),
//               child: Icon(
//                 Icons.add,
//                 color: Colors.white,
//               ),
//               backgroundColor: primaryColor,
//               label: "createCircle".tr),
//         ],
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Consumer<CircleProvider>(builder: (context, circle, child) {
//             return checkData
//                 ? Center(child: Image.asset("assets/img/nodata.png"))
//                 : circle.circledata.isEmpty
//                     ? Container(
//                         child: const Center(
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                           ),
//                         ),
//                       )
//                     : Expanded(
//                         child: ListView.builder(
//                             itemCount: circle.circledata.length,
//                             itemBuilder: (context, index) {
//                               var finaldata = circle.circledata[index];
//                               return circleList(finaldata);
//                             }));
//           })
//         ],
//       ),
//     );
//   }

//   Widget circleList(var data) {
//     return Container(
//       width: double.infinity,
//       child: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             InkWell(
//               onTap: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) =>
//                             ProfileWidget(profiledata: data)));
//               },
//               child: Row(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(10000.0),
//                     child: CachedNetworkImage(
//                       height: 50,
//                       width: 50,
//                       imageUrl: imagepath + data['image'],
//                       placeholder: (context, url) => CircularProgressIndicator(
//                         color: Colors.white,
//                       ),
//                       errorWidget: (context, url, error) => Icon(Icons.error),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 10,
//                   ),
//                   Container(
//                     child: Text(
//                       data['title'],
//                       style: TextStyle(
//                           color: Colors.white, fontWeight: FontWeight.bold),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 5,
//             ),
//             InkWell(
//               onTap: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => BannerDetail(
//                               bnannerdata: data,
//                             )));
//               },
//               child: Container(
//                   height: MediaQuery.of(context).size.width /
//                       (MediaQuery.of(context).size.height / 400),
//                   decoration: BoxDecoration(
//                     color: primaryColor.withOpacity(0.2),
//                     borderRadius: BorderRadius.all(Radius.circular(20)),
//                   ),
//                   child:
//                       Center(child: Image.network(imagepath + data['banner']))),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//               Container(
//                 decoration: BoxDecoration(
//                   // color: Colors.white,Ï
//                   color: primaryColor.withOpacity(0.2),
//                   borderRadius: BorderRadius.all(Radius.circular(20)),
//                 ),
//                 height: 40,
//                 width: 100,
//                 child: LikeButton(
//                   isLiked: data['is_like'] == "1" ? true : false,
//                   size: 30.0,
//                   circleColor: const CircleColor(
//                       start: Color(0xff00ddff), end: Color(0xff0099cc)),
//                   bubblesColor: const BubblesColor(
//                     dotPrimaryColor: Color(0xff33b5e5),
//                     dotSecondaryColor: Color(0xff0099cc),
//                   ),
//                   likeBuilder: (isLike) {
//                     return Icon(
//                       Icons.thumb_up,
//                       color: isLike ? Colors.lightBlue : Colors.grey,
//                       size: 30.0,
//                     );
//                   },
//                   likeCount: int.parse(data['total_like']),
//                   countBuilder: (int? count, bool isLiked, String text) {
//                     var color = isLiked ? Colors.white : Colors.grey;
//                     Widget result;
//                     if (count == 0) {
//                       result = Text(
//                         "Like",
//                         style: TextStyle(color: color),
//                       );
//                     } else
//                       result = Text(
//                         text,
//                         style: TextStyle(
//                             color: color, fontWeight: FontWeight.bold),
//                       );
//                     return result;
//                   },
//                 ),
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   // color: Colors.white,Ï
//                   color: primaryColor.withOpacity(0.2),
//                   borderRadius: BorderRadius.all(Radius.circular(20)),
//                 ),
//                 height: 40,
//                 width: 100,
//                 child: LikeButton(
//                   isLiked: data['is_like'] == "2" ? true : false,
//                   size: 30.0,
//                   circleColor: const CircleColor(
//                       start: Color(0xff00ddff), end: Color(0xff0099cc)),
//                   bubblesColor: const BubblesColor(
//                     dotPrimaryColor: Color(0xff33b5e5),
//                     dotSecondaryColor: Color(0xff0099cc),
//                   ),
//                   likeBuilder: (bool isLiked) {
//                     return Icon(
//                       Icons.thumb_down,
//                       color: isLiked ? Colors.lightBlue : Colors.grey,
//                       size: 30.0,
//                     );
//                   },
//                   likeCount: int.parse(data['total_dislike']),
//                   countBuilder: (int? count, bool isLiked, String text) {
//                     var color = isLiked ? Colors.white : Colors.grey;
//                     Widget result;
//                     if (count == 0) {
//                       result = Text(
//                         "Dislike",
//                         style: TextStyle(color: color),
//                       );
//                     } else
//                       result = Text(
//                         text,
//                         style: TextStyle(
//                             color: color, fontWeight: FontWeight.bold),
//                       );
//                     return result;
//                   },
//                 ),
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   // color: Colors.white,Ï
//                   color: primaryColor.withOpacity(0.2),
//                   borderRadius: BorderRadius.all(Radius.circular(20)),
//                 ),
//                 height: 40,
//                 width: 120,
//                 child: LikeButton(
//                   isLiked: data['is_subscribe'] == "1" ? true : false,
//                   size: 30.0,
//                   circleColor: const CircleColor(
//                       start: Color(0xff00ddff), end: Color(0xff0099cc)),
//                   bubblesColor: const BubblesColor(
//                     dotPrimaryColor: Color(0xff33b5e5),
//                     dotSecondaryColor: Color(0xff0099cc),
//                   ),
//                   likeBuilder: (bool isLiked) {
//                     return Icon(
//                       // Icons.notifications,
//                       isLiked
//                           ? Icons.notifications_active
//                           : Icons.notifications,
//                       color: isLiked ? Colors.lightBlue : Colors.grey,
//                       size: 30.0,
//                     );
//                   },
//                   likeCount: int.parse(data['total_subscribe']),
//                   countBuilder: (int? count, bool isLiked, String text) {
//                     var color = isLiked ? Colors.white : Colors.grey;
//                     Widget result;
//                     if (count == 0) {
//                       result = Text(
//                         "Subscribe",
//                         style: TextStyle(color: color),
//                       );
//                     } else
//                       result = Text(
//                         text,
//                         style: TextStyle(
//                             color: color, fontWeight: FontWeight.bold),
//                       );
//                     return result;
//                   },
//                 ),
//               ),
//             ]),
//             // Divider(
//             //   thickness: 0.5,
//             //   color: Colors.white,
//             // )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/cupertino.dart';

class Robot extends StatelessWidget {
  const Robot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Image.asset("assets/img/commingsoon.png")),
    );
  }
}
