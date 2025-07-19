import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../Data/Api.dart';
import '../../../Service/assets_service.dart';

class TeamDetail extends StatefulWidget {
  const TeamDetail({Key? key, required this.data, this.level})
      : super(key: key);
  final List data;
  final level;
  @override
  _TeamDetailState createState() => _TeamDetailState();
}

class _TeamDetailState extends State<TeamDetail> {
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
