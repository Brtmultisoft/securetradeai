import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:securetradeai/Data/Api.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/profile/errorNotification/errorNotificaton.dart';
import 'package:securetradeai/src/profile/profileoption/APIBinding/apibinding.dart';
import 'package:securetradeai/src/profile/profileoption/memberCenter/member.dart';
import 'package:securetradeai/src/profile/profileoption/personalInfo.dart';
import 'package:securetradeai/src/profile/profileoption/securitycenter/security.dart';
import 'package:securetradeai/src/profile/profileoption/share/share.dart';
import 'package:securetradeai/src/profile/profileoption/support/inbox.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../method/methods.dart';
import '../user/login.dart';
import 'profileoption/Transaction/transaction.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var minedata = [];
  bool isAPIcalle = false;
  var rem;
  var finalData;
  _getData() async {
    try {
      print(commonuserId);
      setState(() {
        isAPIcalle = true;
      });
      final data = await CommonMethod().getMineData();
      if (data.status == "success") {
        setState(() {
          minedata = data.data;
          for (var e in minedata) {
            finalData = e;
          }

          isAPIcalle = false;
        });
      } else {
        showtoast(data.message, context);
      }
    } catch (e) {
      print(e);
      if (mounted) {
        setState(() {
          isAPIcalle = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: bg,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              setPage(finalData),
              const SizedBox(
                height: 10,
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      child: Column(
                    children: [
                      ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => mamberCenter()));
                          },
                          leading: Image.asset(
                            "assets/img/diamond.png",
                            color: securetradeaicolor,
                            height: 25,
                          ),
                          title: Text(
                            "mamber_center".tr,
                            style: const TextStyle(),
                          ),
                          trailing: Container(
                              height: 50,
                              width: 50,
                              child: const Icon(
                                Icons.arrow_right,
                              ))),
                      ListTile(
                        leading: Icon(Icons.cyclone, color: securetradeaicolor),
                        trailing: const SizedBox(),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Gas",
                              style: TextStyle(),
                            ),
                            isAPIcalle
                                ? const Text("Loading...", style: TextStyle())
                                : Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                            text: 'Bal : ',
                                            style:
                                                TextStyle(color: Colors.grey)),
                                        TextSpan(
                                          text: finalData.gasBalance
                                                  .toString()
                                                  .isEmpty
                                              ? "0.0"
                                              : double.parse(
                                                      finalData.gasBalance)
                                                  .toStringAsFixed(4),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: securetradeaicolor),
                                        ),
                                      ],
                                    ),
                                  )
                          ],
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.card_giftcard,
                            color: securetradeaicolor),
                        trailing: const SizedBox(),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Bonus",
                              style: TextStyle(),
                            ),
                            isAPIcalle
                                ? const Text("Loading...", style: TextStyle())
                                : Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                            text: 'Bal : ',
                                            style:
                                                TextStyle(color: Colors.grey)),
                                        TextSpan(
                                          text: finalData.bonusBalance
                                                  .toString()
                                                  .isEmpty
                                              ? "0.0"
                                              : double.parse(
                                                      finalData.bonusBalance)
                                                  .toStringAsFixed(4),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: securetradeaicolor),
                                        ),
                                      ],
                                    ),
                                  )
                          ],
                        ),
                      ),
                      ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ApiBinding()));
                          },
                          leading: Icon(
                            Icons.attach_file,
                            color: securetradeaicolor,
                          ),
                          title: Text(
                            "api_bindige".tr,
                            style: const TextStyle(),
                          ),
                          trailing: Container(
                              height: 50,
                              width: 50,
                              child: const Icon(
                                Icons.arrow_right,
                              ))),
                      ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Transaction()));
                          },
                          leading: SvgPicture.asset(
                            "assets/img/transaction.svg",
                            width: 20,
                            color: securetradeaicolor,
                          ),
                          title: Text(
                            "transation_record".tr,
                            style: const TextStyle(),
                          ),
                          trailing: Container(
                              height: 50,
                              width: 50,
                              child: const Icon(
                                Icons.arrow_right,
                              ))),
                      ListTile(
                        onTap: () {
                          /*  Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ProfitSharing()));*/
                        },
                        leading: Icon(
                          Icons.history,
                          color: securetradeaicolor,
                        ),
                        title: const Text("Trade History", style: TextStyle()),
                        trailing: Container(
                          height: 50,
                          width: 50,
                          child: const Icon(
                            Icons.arrow_right,
                          ),
                        ),
                      ),
                      ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Sharescreen(
                                  reffral: finalData.referralCode.toString(),
                                ),
                              ),
                            );
                          },
                          leading: Icon(
                            Icons.share_outlined,
                            color: securetradeaicolor,
                          ),
                          title: Text("share".tr, style: const TextStyle()),
                          trailing: Container(
                              height: 50,
                              width: 50,
                              child: const Icon(
                                Icons.arrow_right,
                              ))),
                      ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Inbox()));
                          },
                          leading: Icon(
                            Icons.support,
                            color: securetradeaicolor,
                          ),
                          title: Text("support".tr, style: const TextStyle()),
                          trailing: Container(
                              height: 50,
                              width: 50,
                              child: const Icon(
                                Icons.arrow_right,
                              ))),
                      ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ErrorNotification()));
                          },
                          leading: Icon(
                            Icons.error,
                            color: securetradeaicolor,
                          ),
                          title: const Text("Error Notificaton"),
                          trailing: Container(
                              height: 50,
                              width: 50,
                              child: Icon(
                                Icons.arrow_right,
                                color: securetradeaicolor,
                              ))),
                      ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SystemCenter()));
                          },
                          leading: Icon(
                            Icons.settings,
                            color: securetradeaicolor,
                          ),
                          title: Text("systemSetting".tr,
                              style: const TextStyle()),
                          trailing: const SizedBox(
                              height: 50,
                              width: 50,
                              child: Icon(
                                Icons.arrow_right,
                              ))),
                      ListTile(
                        onTap: () async {
                          SharedPreferences pref =
                              await SharedPreferences.getInstance();
                          pref.remove("emailorpass");
                          pref.remove("password");
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        leading: Icon(
                          Icons.power_settings_new,
                          color: securetradeaicolor,
                        ),
                        title: Text(
                          'logout'.tr,
                          style: const TextStyle(),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget setPage(data) {
    Color red800 = bg;
    return Stack(
      children: <Widget>[
        Container(
          // Background
          color: red800,
          // height: MediaQuery.of(context).size.height * 0.2,
          width: MediaQuery.of(context).size.width,
          // Background
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 10),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PersonalInfo()));
              },
              leading: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 23.0,
                backgroundImage: isAPIcalle
                    ? const NetworkImage(imagepath + "default.jpg")
                    : data.image == null
                        ? const NetworkImage(imagepath + "default.jpg")
                        : NetworkImage(imagepath + data.image),
              ),
              title: Text(
                isAPIcalle
                    ? "Loading.."
                    : (data.name == "" || data.name == null)
                        ? "Admin"
                        : data.name,
                style: const TextStyle(
                    fontFamily: fontFamily, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                isAPIcalle ? "Loading.." : data.email,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: fontFamily,
                ),
              ),
              trailing: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.arrow_right,
                  )),
            ),
            Container(
              height: 70.0,
              decoration: BoxDecoration(
                color: securetradeaicolor.withOpacity(0.7),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30.0)),
              ),
              child: Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                      child: Image.asset(
                    "assets/img/vip.png",
                    color: Colors.white,
                  )),
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 15),
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text(
                            "View Permission",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily),
                          ),
                          isAPIcalle
                              ? const Text(
                                  "Loading",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: fontFamily),
                                )
                              : data.verify == "1"
                                  ? const Text(
                                      "Active",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: fontFamily),
                                    )
                                  : const Text(
                                      "InActive",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: fontFamily),
                                    )
                        ],
                      ),
                    ),
                  ),
                ],
              )),
            ),
          ]),
        ),
      ],
    );
  }
}
