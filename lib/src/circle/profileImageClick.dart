import 'package:flutter/material.dart';
import 'package:rapidtradeai/Data/Api.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';

class ProfileWidget extends StatefulWidget {
  @override
  final profiledata;
  const ProfileWidget({Key? key, this.profiledata}) : super(key: key);
  State<StatefulWidget> createState() {
    return _ProfileWidgetShape();
  }
}

class _ProfileWidgetShape extends State<ProfileWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text("User Detail"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _profilePic(),
            Padding(
              padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
              child: Text(widget.profiledata['title'] ?? "Title",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 10,
            ),
            _subscriptionCostButton(),
            const Padding(
              padding: EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 0.0),
              child: Divider(
                color: Color(0xff78909c),
                // height: 50.0,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              widget.profiledata['description'] ?? "Description",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                ),
                child: Image.network(imagepath + widget.profiledata['banner']),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _subscriptionCostButton() {
    return InkWell(
      // onTap: _login,
      child: Container(
        height: 50,
        margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
                color: Colors.black12,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
        ),
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: "Subcription Cost ",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.bold),
              ),
              TextSpan(
                  text: widget.profiledata['price'] ?? "0.00",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: fontFamily)),
              const TextSpan(
                  text: "USD",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      fontSize: 12,
                      fontFamily: fontFamily)),
            ],
          ),
        ),
      ),
    );
  }

  Container _profilePic() => Container(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(50.0, 30.0, 50.0, 15.0),
          child: Stack(
            alignment: const Alignment(0.9, 0.9),
            children: <Widget>[
              CircleAvatar(
                backgroundImage:
                    NetworkImage(imagepath + widget.profiledata['image']),
                radius: 50.0,
              ),
            ],
          ),
        ),
      );
}
