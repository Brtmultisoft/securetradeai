import 'package:flutter/material.dart';
import 'package:securetradeai/Data/Api.dart';
import 'package:securetradeai/src/Service/assets_service.dart';


class TeamDetailArbitrade extends StatefulWidget {
  const TeamDetailArbitrade({Key? key, required this.data, this.level})
      : super(key: key);
  final List data;
  final level;
  @override
  _TeamDetailArbitradeState createState() => _TeamDetailArbitradeState();
}

class _TeamDetailArbitradeState extends State<TeamDetailArbitrade> {
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
            widget.level == null ? "" : "Level : " + widget.level.toString()),
      ),
      body: widget.data.isEmpty
          ? Center(
              child: Image.asset("assets/img/nologodata.png",height: 200),
            )
          : _getDirect(),
    );
  }

  Widget _getDirect() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: ListView.builder(
          itemCount: widget.data.length,
          itemBuilder: (context, i) {
            return ListTile(
              leading: CircleAvatar(
                radius: 20.0,
                backgroundImage: widget.data[i]['image'] == null
                    ? const NetworkImage(imagepath + "default.jpg")
                    : NetworkImage(
                        imagepath + widget.data[i]['image'],
                      ),
              ),
              title: Text(
                widget.data[i]['name'],
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              trailing: Column(
                children: [
                  Icon(
                    (int.parse(widget.data[i]['days']) < 0 ||
                            int.parse(widget.data[i]['days']) == 0)
                        ? Icons.close
                        : Icons.check,
                    color: (int.parse(widget.data[i]['days']) < 0 ||
                            int.parse(widget.data[i]['days']) == 0)
                        ? Colors.red
                        : Colors.green,
                  ),
                  Text(
                    (int.parse(widget.data[i]['days']) < 0 ||
                            int.parse(widget.data[i]['days']) == 0)
                        ? "InActive"
                        : "Active",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            );
          }),
    );
  }
}
