import 'dart:convert';
import 'package:securetradeai/data/strings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/src/Service/assets_service.dart';
import '../../../../Data/Api.dart';

class Rank extends StatefulWidget {
  const Rank({Key? key, this.image}) : super(key: key);
  final image;

  @override
  _RankState createState() => _RankState();
}

class _RankState extends State<Rank> {
  bool isAPIcalled = false;
  bool checkdata = false;
  var teamData;
  int p0 = 0;
  int p1 = 0;
  int p2 = 0;
  int p3 = 0;
  int p4 = 0;
  int p5 = 0;
  int p6 = 0;

  Future _getTeam() async {
    print(commonuserId);
    try {
      setState(() {
        isAPIcalled = true;
      });
      final res = await http.post(Uri.parse(teamDetail),
          body: jsonEncode({'user_id': commonuserId}));
      if (res.statusCode != 200) {
        showtoast("Server Error", context);
        setState(() {
          isAPIcalled = false;
        });
      } else {
        var data = jsonDecode(res.body);
        if (data['status'] == "success") {
          var localdata = data['data'] as List;
          for (var element in localdata) {
            if (element["rank"] == "0"  ) {
              setState(() => p0++);
            }
            if (element["rank"] == "1") {
              setState(() => p1++);
            }
            if (element["rank"] == "2") {
              setState(() => p2++);
            }
            if (element["rank"] == "3") {
              setState(() => p3++);
            }
            if (element["rank"] == "4") {
              setState(() => p4++);
            }
            if (element["rank"] == "5") {
              setState(() => p5++);
            }
            if (element["rank"] == "6") {
              setState(() => p6++);
            }
          }
          if (mounted) {
            setState(() {
              teamData = data['data'];
              isAPIcalled = false;
            });
          }

          print(teamData);
        } else {
          showtoast(data['message'], context);
          if (mounted) {
            setState(() {
              checkdata = true;
              isAPIcalled = false;
            });
          }
        }
      }
    } catch (e) {
      print(e);
      setState(() {
        isAPIcalled = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getTeam();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: isAPIcalled
          ? Center(
              child: CircularProgressIndicator(color: securetradeaicolor),
            )
          : checkdata
              ? Center(
                  child: Image.asset("assets/img/logo.png",height: 200),
                )
              : _getRank(),
    );
  }

  Widget _getRank() {
    return SingleChildScrollView(
      child: Column(
        children: [
           ListTile(
            leading: CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(
                widget.image == null
                    ? imagepath + "default.jpg"
                    : imagepath + widget.image,
              ),
            ),
            title: const Text(
              "Z 0",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Total Team " + p0.toString(),
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(
                widget.image == null
                    ? imagepath + "default.jpg"
                    : imagepath + widget.image,
              ),
            ),
            title: const Text(
              "Z 1",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Total Team " + p1.toString(),
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(
                widget.image == null
                    ? imagepath + "default.jpg"
                    : imagepath + widget.image,
              ),
            ),
            title: const Text(
              "Z 2",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Total Team " + p2.toString(),
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(
                widget.image == null
                    ? imagepath + "default.jpg"
                    : imagepath + widget.image,
              ),
            ),
            title: const Text(
              "Z 3",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Total Team " + p3.toString(),
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(
                widget.image == null
                    ? imagepath + "default.jpg"
                    : imagepath + widget.image,
              ),
            ),
            title: const Text(
              "Z 4",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Total Team " + p4.toString(),
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(
                widget.image == null
                    ? imagepath + "default.jpg"
                    : imagepath + widget.image,
              ),
            ),
            title: const Text(
              "Z 5",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Total Team " + p5.toString(),
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(
                widget.image == null
                    ? imagepath + "default.jpg"
                    : imagepath + widget.image,
              ),
            ),
            title: const Text(
              "Z 6",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Total Team " + p6.toString(),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
