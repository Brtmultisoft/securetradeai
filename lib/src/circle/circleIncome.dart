import 'package:flutter/material.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';

class CircleIncome extends StatefulWidget {
  const CircleIncome({Key? key}) : super(key: key);

  @override
  _CircleIncomeState createState() => _CircleIncomeState();
}

class _CircleIncomeState extends State<CircleIncome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Circle Income"),
      ),
      body: Column(
        children: [Expanded(child: _CircleIncome())],
      ),
    );
  }

  Widget _CircleIncome() {
    return ListView.builder(itemBuilder: (context, index) {
      return Container(
        height: 80,
        margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.2),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "1-1-2022",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Subcription Fee from Id 1234567",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "100 USD",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
