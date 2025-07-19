import 'package:flutter/material.dart';
import 'package:securetradeai/Data/Api.dart';
import 'package:securetradeai/data/strings.dart';
import '../../../../method/methods.dart';
import '../../../Service/assets_service.dart';

class DirectIncome extends StatefulWidget {
  const DirectIncome({Key? key}) : super(key: key);

  @override
  _DirectIncomeState createState() => _DirectIncomeState();
}

class _DirectIncomeState extends State<DirectIncome> {
  var clubDtail = [];
  var data;
  bool isAPIcalled = false;
  bool checkdata = false;
  double todaytotalClubcr = 0.0;
  double cumulativeClub = 0.0;
  Future _getClubIncome() async {
    try {
      setState(() {
        isAPIcalled = true;
      });
      final res = await CommonMethod().getClubIncome();
      if (res.status == "success") {
        clubDtail.addAll(res.data.details.reversed.toList());
        checkdata = clubDtail.isEmpty ? true : false;
        if (mounted) {
          setState(() {
            data = res.data;
            isAPIcalled = false;
          });
        }
      } else {
        showtoast(res.message, context);
      }
    } catch (e) {
      setState(() {
        isAPIcalled = false;
      });
    }
  }

  _getCurrency() async {
    var totalcurrency = await CommonMethod().getCurrency(0.0);
    if (mounted) {
      setState(() {
        todaytotalClubcr =
            data.profitToday == null ? 0.0 : data.profitToday * totalcurrency;
        cumulativeClub = data.cumulativeProfit == null
            ? 0.0
            : data.cumulativeProfit * totalcurrency;
      });
    }
  }

  _fatchData() async {
    await _getClubIncome();
    await _getCurrency();
  }

  @override
  void initState() {
    super.initState();
    _fatchData();
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
                            ? Text(
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
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          todaytotalClubcr.toStringAsFixed(4) +
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
                          cumulativeClub.toStringAsFixed(4) +
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
                    ? Center(
                        child: Image.asset("assets/img/logo.png", height: 200))
                    : ListView.builder(
                        itemCount: clubDtail.length,
                        itemBuilder: (context, i) {
                          var date = DateTime.parse(
                              clubDtail[i].createdDate.toString());
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
                                          clubDtail[i].totalbal.toString() +
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
