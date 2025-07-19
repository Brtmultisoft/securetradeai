import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securetradeai/method/cycleMethod.dart';
import 'package:securetradeai/src/Service/assets_service.dart';

class CircleTradeIncome extends StatefulWidget {
  const CircleTradeIncome({Key? key}) : super(key: key);

  @override
  _CircleTradeIncomeState createState() => _CircleTradeIncomeState();
}

class _CircleTradeIncomeState extends State<CircleTradeIncome> {
  var FirstBuy = TextEditingController();
  var martinconfig = TextEditingController();
  var martinCallLimit = TextEditingController();
  var WPProfit = TextEditingController();
  var wpCallBack = TextEditingController();
  var bycallback = TextEditingController();
  var marginDrop1 = TextEditingController();
  var marginDrop2 = TextEditingController();
  var marginDrop3 = TextEditingController();
  var marginDrop4 = TextEditingController();
  var marginDrop5 = TextEditingController();
  var marginDrop6 = TextEditingController();
  var marginDrop7 = TextEditingController();
  var marginDrop8 = TextEditingController();
  var marginDrop9 = TextEditingController();
  var marginDrop10 = TextEditingController();
  var marginDrop11 = TextEditingController();
  var marginDrop12 = TextEditingController();
  var marginDrop13 = TextEditingController();
  var marginDrop14 = TextEditingController();
  var marginDrop15 = TextEditingController();
  var multiply1 = TextEditingController();
  var multiply2 = TextEditingController();
  var multiply3 = TextEditingController();
  var multiply4 = TextEditingController();
  var multiply5 = TextEditingController();
  var multiply6 = TextEditingController();
  var multiply7 = TextEditingController();
  var multiply8 = TextEditingController();
  var multiply9 = TextEditingController();
  var multiply10 = TextEditingController();
  var multiply11 = TextEditingController();
  var multiply12 = TextEditingController();
  var multiply13 = TextEditingController();
  var multiply14 = TextEditingController();
  var multiply15 = TextEditingController();
  var cycle = TextEditingController();
  var stockMargin = TextEditingController();
  bool isAPIcalled = false;
  _getTradeData() {
    if (mounted) {
      setState(() {
        isAPIcalled = true;
      });
    }
    final circleTrade = Provider.of<CircleProvider>(context, listen: false);
    circleTrade.getTradeSettingData();
    for (var element in circleTrade.circleTradeSettingData) {
      setState(() {
        FirstBuy.text = element['first_buy'];
        martinconfig.text = element['martin_config'];
        martinCallLimit.text = element['margin_call_limit'];
        WPProfit.text = element['wp_profit'];
        wpCallBack.text = element['wp_callback'];
        bycallback.text = element['by_callback'];
        // call drop start
        marginDrop1.text = element['margin_drop_1'];
        marginDrop2.text = element['margin_drop_2'];
        marginDrop3.text = element['margin_drop_3'];
        marginDrop4.text = element['margin_drop_4'];
        marginDrop5.text = element['margin_drop_5'];
        marginDrop6.text = element['margin_drop_6'];
        marginDrop7.text = element['margin_drop_7'];
        marginDrop8.text = element['margin_drop_8'];
        marginDrop9.text = element['margin_drop_9'];
        marginDrop10.text = element['margin_drop_10'];
        marginDrop11.text = element['margin_drop_11'];
        marginDrop12.text = element['margin_drop_12'];
        marginDrop13.text = element['margin_drop_13'];
        marginDrop14.text = element['margin_drop_14'];
        marginDrop15.text = element['margin_drop_15'];
        // multiply start
        multiply1.text = element['multiply_ration_1'];
        multiply2.text = element['multiply_ration_2'];
        multiply3.text = element['multiply_ration_3'];
        multiply4.text = element['multiply_ration_4'];
        multiply5.text = element['multiply_ration_5'];
        multiply6.text = element['multiply_ration_6'];
        multiply7.text = element['multiply_ration_7'];
        multiply8.text = element['multiply_ration_8'];
        multiply9.text = element['multiply_ration_9'];
        multiply10.text = element['multiply_ration_10'];
        multiply11.text = element['multiply_ration_11'];
        multiply12.text = element['multiply_ration_12'];
        multiply13.text = element['multiply_ration_13'];
        multiply14.text = element['multiply_ration_14'];
        multiply15.text = element['multiply_ration_15'];
        cycle.text = element['cycle'];
        stockMargin.text = element['stock_margin'];
      });
    }
    if (mounted) {
      setState(() {
        isAPIcalled = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getTradeData();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Circle Trade Setting"),
      ),
      body: SingleChildScrollView(
        child: isAPIcalled
            ? Center(
                child: CircularProgressIndicator(color: securetradeaicolor),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  children: [
                    _commonWidget("First Buy", FirstBuy),
                    _commonWidget("Martin Config", martinconfig),
                    _commonWidget("Martin Call Limit", martinCallLimit),
                    _commonWidget("WP Profit", WPProfit),
                    _commonWidget("WP Callback", wpCallBack),
                    _commonWidget("By Callback", bycallback),
                    _commonWidget("Margin Drop 1", marginDrop1),
                    _commonWidget("Margin Drop 2", marginDrop2),
                    _commonWidget("Margin Drop 3", marginDrop3),
                    _commonWidget("Margin Drop 4", marginDrop4),
                    _commonWidget("Margin Drop 5", marginDrop5),
                    _commonWidget("Margin Drop 6", marginDrop6),
                    _commonWidget("Margin Drop 7", marginDrop7),
                    _commonWidget("Margin Drop 8", marginDrop8),
                    _commonWidget("Margin Drop 9", marginDrop9),
                    _commonWidget("Margin Drop 10", marginDrop10),
                    _commonWidget("Margin Drop 11", marginDrop11),
                    _commonWidget("Margin Drop 12", marginDrop12),
                    _commonWidget("Margin Drop 13", marginDrop13),
                    _commonWidget("Margin Drop 14", marginDrop14),
                    _commonWidget("Margin Drop 15", marginDrop15),
                    _commonWidget("Multiply Ratio 1", multiply1),
                    _commonWidget("Multiply Ratio 2", multiply2),
                    _commonWidget("Multiply Ratio 3", multiply3),
                    _commonWidget("Multiply Ratio 4", multiply4),
                    _commonWidget("Multiply Ratio 5", multiply5),
                    _commonWidget("Multiply Ratio 6", multiply6),
                    _commonWidget("Multiply Ratio 7", multiply7),
                    _commonWidget("Multiply Ratio 8", multiply8),
                    _commonWidget("Multiply Ratio 9", multiply9),
                    _commonWidget("Multiply Ratio 10", multiply10),
                    _commonWidget("Multiply Ratio 11", multiply11),
                    _commonWidget("Multiply Ratio 12", multiply12),
                    _commonWidget("Multiply Ratio 13", multiply13),
                    _commonWidget("Multiply Ratio 14", multiply14),
                    _commonWidget("Multiply Ratio 15", multiply15),
                    _commonWidget("Cycle", cycle),
                    _commonWidget("Stock Margin", stockMargin),
                    SizedBox(
                      height: 15,
                    ),
                    _submitButton(context),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _commonWidget(String columnName, controller) {
    return Container(
      margin: EdgeInsets.only(
        top: 10,
        left: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              columnName,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
                child: Container(
              height: 50,
              // width: 200,
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xfff3f3f4),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.white70, fontSize: 13),
                      hintText: columnName,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onChanged: (v) {
                      // setState(() {
                      //   (v == null || v == "")
                      //       ? getnetToken(0.0)
                      //       : getnetToken(double.parse(v));
                      // });
                    },
                  ),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _submitButton(
    context,
  ) {
    return InkWell(
      onTap: () {
        // click();
      },
      child: Container(
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
        // gradient: LinearGradient(
        //     begin: Alignment.centerLeft,
        //     end: Alignment.centerRight,
        //     colors: [Color(0xfffbb448), Color(0xfff7892b)])),
        child: const Text(
          "Save",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
