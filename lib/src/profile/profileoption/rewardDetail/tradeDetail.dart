import 'package:flutter/material.dart';
import 'package:securetradeai/Data/Api.dart';
import 'package:securetradeai/data/strings.dart';
import '../../../../method/methods.dart';
import '../../../Service/assets_service.dart';

class UniversalPool extends StatefulWidget {
  const UniversalPool({Key? key}) : super(key: key);

  @override
  _UniversalPoolState createState() => _UniversalPoolState();
}

class _UniversalPoolState extends State<UniversalPool> {
  var tradeDetail = [];
  var data;
  bool isAPIcalled = false;
  bool checkdata = false;
  double todayTradeincr = 0.0;
  double cumulativeincr = 0.0;
  Future _getTradeData() async {
    try {
      setState(() {
        isAPIcalled = true;
      });
      final res = await CommonMethod().getTradeIncome();
      if (res.status == "success") {
        tradeDetail.addAll(res.data.details.reversed.toList());
        checkdata = tradeDetail.length == 0 ? true : false;
        print(checkdata);
        setState(() {
          data = res.data;
          isAPIcalled = false;
        });
      } else {
        showtoast(res.message, context);
      }
    } catch (e) {
      print(e);
      setState(() {
        isAPIcalled = false;
      });
    }
  }

  _getCurrency() async {
    var totalcurrency = await CommonMethod().getCurrency(0.0);
    if (mounted) {
      setState(() {
        todayTradeincr =
            data.profitToday == null ? 0.0 : data.profitToday * totalcurrency;
        cumulativeincr = data.cumulativeProfit == null
            ? 0.0
            : data.cumulativeProfit * totalcurrency;
      });
    }
  }

  _fetchdata() async {
    await _getTradeData();
    await _getCurrency();
  }

  @override
  void initState() {
    super.initState();
    _fetchdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bg,
        body: Column(
          children: [
            Container(
              height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.0],
                  colors: [
                    Colors.green,
                    Colors.blue,
                  ],
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Total Profit Today",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        isAPIcalled
                            ? const Text(
                                "Loading..",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )
                            : Text(
                                data.profitToday == null
                                    ? "0.0"
                                    : double.parse(data.profitToday.toString())
                                        .toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          todayTradeincr.toStringAsFixed(4) +
                              " (${currentCurrency == "null" ? "USD" : currentCurrency})",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5, bottom: 5),
                      child: const VerticalDivider(
                        color: Colors.white70,
                        thickness: 2,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Cumulative Profit",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        isAPIcalled
                            ? Text(
                                "Loading..",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )
                            : Text(
                                data.cumulativeProfit == null
                                    ? "0.0"
                                    : double.parse(
                                            data.cumulativeProfit.toString())
                                        .toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          cumulativeincr.toStringAsFixed(4) +
                              " (${currentCurrency == "null" ? "USD" : currentCurrency})",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            Expanded(
                child: checkdata
                    ? Center(child: Image.asset("assets/img/logo.png",height: 200))
                    : ListView.builder(
                        itemCount: tradeDetail.length,
                        itemBuilder: (context, i) {
                          var date = DateTime.parse(
                              tradeDetail[i].createdDate.toString());
                          var formattedDate =
                              "${date.day}-${date.month}-${date.year}";
                          return isAPIcalled
                              ? Center(
                                  child: CircularProgressIndicator(
                                      color: securetradeaicolor),
                                )
                              : Container(
                                  margin: EdgeInsets.only(top: 10),
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.3),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10.0)),
                                  ),
                                  child: Container(
                                    margin:
                                        EdgeInsets.only(left: 15, right: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          formattedDate.toString(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          tradeDetail[i].totalbal.toString() +
                                              " USDT",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                        }))
          ],
        ));
  }
}
