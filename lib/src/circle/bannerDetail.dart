import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:rapidtradeai/data/api.dart';

import '../Service/assets_service.dart';

class BannerDetail extends StatefulWidget {
  const BannerDetail({Key? key, this.bnannerdata}) : super(key: key);
  final bnannerdata;
  @override
  _BannerDetailState createState() => _BannerDetailState();
}

class _BannerDetailState extends State<BannerDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: const Text("Circle",
            style:
                TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold)),
      ),
      bottomSheet: Container(
        color: bg,
        height: 60,
        width: double.infinity,
        child: Container(
          margin: const EdgeInsets.all(
            10,
          ),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              decoration: BoxDecoration(
                // color: Colors.white,Ï
                color: primaryColor.withOpacity(0.2),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              height: 40,
              width: 100,
              child: LikeButton(
                isLiked: widget.bnannerdata['is_like'] == "1" ? true : false,
                size: 30.0,
                circleColor: const CircleColor(
                    start: Color(0xff00ddff), end: Color(0xff0099cc)),
                bubblesColor: const BubblesColor(
                  dotPrimaryColor: Color(0xff33b5e5),
                  dotSecondaryColor: Color(0xff0099cc),
                ),
                likeBuilder: (isLike) {
                  return Icon(
                    Icons.thumb_up,
                    color: isLike ? Colors.lightBlue : Colors.grey,
                    size: 30.0,
                  );
                },
                likeCount: int.parse(widget.bnannerdata['total_like']),
                countBuilder: (int? count, bool isLiked, String text) {
                  var color = isLiked ? Colors.white : Colors.grey;
                  Widget result;
                  if (count == 0) {
                    result = Text(
                      "Like",
                      style: TextStyle(color: color),
                    );
                  } else
                    result = Text(
                      text,
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.bold),
                    );
                  return result;
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                // color: Colors.white,Ï
                color: primaryColor.withOpacity(0.2),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              height: 40,
              width: 100,
              child: LikeButton(
                isLiked: widget.bnannerdata['is_like'] == "2" ? true : false,
                size: 30.0,
                circleColor: const CircleColor(
                    start: Color(0xff00ddff), end: Color(0xff0099cc)),
                bubblesColor: const BubblesColor(
                  dotPrimaryColor: Color(0xff33b5e5),
                  dotSecondaryColor: Color(0xff0099cc),
                ),
                likeBuilder: (bool isLiked) {
                  return Icon(
                    Icons.thumb_down,
                    color: isLiked ? Colors.lightBlue : Colors.grey,
                    size: 30.0,
                  );
                },
                likeCount: int.parse(widget.bnannerdata['total_dislike']),
                countBuilder: (int? count, bool isLiked, String text) {
                  var color = isLiked ? Colors.white : Colors.grey;
                  Widget result;
                  if (count == 0) {
                    result = Text(
                      "Dislike",
                      style: TextStyle(color: color),
                    );
                  } else
                    result = Text(
                      text,
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.bold),
                    );
                  return result;
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                // color: Colors.white,Ï
                color: primaryColor.withOpacity(0.2),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              height: 40,
              width: 120,
              child: LikeButton(
                isLiked:
                    widget.bnannerdata['is_subscribe'] == "1" ? true : false,
                size: 30.0,
                circleColor: const CircleColor(
                    start: Color(0xff00ddff), end: Color(0xff0099cc)),
                bubblesColor: const BubblesColor(
                  dotPrimaryColor: Color(0xff33b5e5),
                  dotSecondaryColor: Color(0xff0099cc),
                ),
                likeBuilder: (bool isLiked) {
                  return Icon(
                    // Icons.notifications,
                    isLiked ? Icons.notifications_active : Icons.notifications,
                    color: isLiked ? Colors.lightBlue : Colors.grey,
                    size: 30.0,
                  );
                },
                likeCount: int.parse(widget.bnannerdata['total_subscribe']),
                countBuilder: (int? count, bool isLiked, String text) {
                  var color = isLiked ? Colors.white : Colors.grey;
                  Widget result;
                  if (count == 0) {
                    result = Text(
                      "Subscribe",
                      style: TextStyle(color: color),
                    );
                  } else
                    result = Text(
                      text,
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.bold),
                    );
                  return result;
                },
              ),
            ),
          ]),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [circleList()],
        ),
      ),
    );
  }

  Widget circleList() {
    return Container(
      // height: MediaQuery.of(context).size.width /
      //     (MediaQuery.of(context).size.height / 440),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {},
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 20.0,
                      backgroundImage: NetworkImage(
                          imagepath + widget.bnannerdata['image'])),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    child: Text(
                      widget.bnannerdata['title'] ?? "",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              widget.bnannerdata['description'],
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => BannerDetail()));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  // image: DecorationImage(fit: BoxFit.cover),
                ),
                child: Image.network(imagepath + widget.bnannerdata['banner']),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // Divider(
            //   thickness: 0.5,
            //   color: Colors.white,
            // )
          ],
        ),
      ),
    );
  }
}
