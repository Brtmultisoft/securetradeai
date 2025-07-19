import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:securetradeai/data/api.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import 'package:securetradeai/data/strings.dart';
import '../../../../method/methods.dart';
import '../../../Service/assets_service.dart';

class AllIncome extends StatefulWidget {
  const AllIncome({Key? key}) : super(key: key);

  @override
  _AllIncomeState createState() => _AllIncomeState();
}

class _AllIncomeState extends State<AllIncome> {
  Image? _image;

  GlobalKey previewContainer = GlobalKey();
  int originalSize = 800;
  double levelTotalToday = 0.0;
  double levelcomulatitve = 0.0;
  double clubTotalToday = 0.0;
  double clubcomulatitve = 0.0;
  double tradeTotalToday = 0.0;
  double tradecomulatitve = 0.0;
  double alltodayincome = 0.0;
  double allcumulaticeincome = 0.0;
  double alltodayprofitSharing = 0.0;
  double todayroyalty = 0.0;
  double profitCumulative = 0.0;
  double royaltycumulative = 0.0;
  double royaltytoday = 0.0;
  double stakingprofitToday = 0.0;
  double stakingcumulative = 0.0;
  // multiple currecny counting
  double cumulativeprofitcr = 0.0;
  double allincometodayProfit = 0.0;
  double levelIncomeComulativeCr = 0.0;
  double leveltotalProfitTodayCr = 0.0;
  double todayclubincomeincr = 0.0;
  double cumulicativeClubIncomeincr = 0.0;
  double todaytradeIncomecr = 0.0;
  double cumulativeIncomecr = 0.0;
  double todayprofitincr = 0.0;
  double cumulativeprofitincr = 0.0;
  double raoyltyintodaycr = 0.0;
  double cumulativeroayalty_incr = 0.0;
  double stakingtodayincr = 0.0;
  double stakingcumulativeincr = 0.0;
  bool isLoading = false;
  _getLevelIncome() async {
    try {
      final res = await CommonMethod().getLevelIncomedata();
      if (res.status == "success") {
        var data = res.data;
        // setState(() {
        //   levelTotalToday = double.parse(data.profitToday);
        //   levelcomulatitve = data.cumulativeProfit;
        // });
        setState(() {
          levelTotalToday =
              data.profitToday == null ? 0.0 : double.parse(data.profitToday);
          levelcomulatitve = data.cumulativeProfit == null
              ? 0.0
              : data.cumulativeProfit.toDouble();
        });
        print(levelcomulatitve);
      } else {
        showtoast(res.message, context);
      }
    } catch (e) {
      print(e);
    }
  }

  // _getStakingIncome() async {
  //   try {
  //     final res = await CommonMethod().getStakingIncomedata();
  //     if (res.status == "success") {
  //       var data = res.data;
  //       setState(() {
  //         stakingprofitToday = data.profitToday ?? 0.0;
  //         if (data.cumulativeProfit == null) {
  //           stakingcumulative = 0.0;
  //         } else {
  //           stakingcumulative = data.cumulativeProfit.toDouble();
  //         }
  //       });
  //     } else {
  //       showtoast(res.message, context);
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  _getclubIncome() async {
    try {
      final res = await CommonMethod().getClubIncome();
      if (res.status == "success") {
        var data = res.data;
        setState(() {
          clubTotalToday =
              data.profitToday == null ? 0.0 : double.parse(data.profitToday);
          clubcomulatitve = data.cumulativeProfit == null
              ? 0.0
              : data.cumulativeProfit.toDouble();
        });
      } else {
        showtoast(res.message, context);
      }
    } catch (e) {
      print(e);
    }
  }

  _getTradeIncome() async {
    try {
      final res = await CommonMethod().getTradeIncome();
      if (res.status == "success") {
        var data = res.data;
        setState(() {
          tradeTotalToday =
              data.profitToday == null ? 0.0 : double.parse(data.profitToday);
          tradecomulatitve = data.cumulativeProfit == null
              ? 0.0
              : data.cumulativeProfit.toDouble();
        });
      } else {
        showtoast(res.message, context);
      }
    } catch (e) {
      print(e);
    }
  }

  _commonMethod() {
    setState(() {
      alltodayincome = levelTotalToday +
          clubTotalToday +
          tradeTotalToday +
          todayprofitincr +
          raoyltyintodaycr +
          stakingtodayincr;

      allcumulaticeincome = levelcomulatitve +
          clubcomulatitve +
          tradecomulatitve +
          cumulativeprofitincr +
          cumulativeroayalty_incr +
          stakingcumulativeincr;
    });
  }

  getCurrency() async {
    var totalcurrency = await CommonMethod().getCurrency(0.0);
    if (mounted) {
      setState(() {
        allincometodayProfit = alltodayincome * totalcurrency;
        cumulativeprofitcr = allcumulaticeincome * totalcurrency;
        levelIncomeComulativeCr = levelcomulatitve * totalcurrency;
        leveltotalProfitTodayCr = levelTotalToday * totalcurrency;
        todayclubincomeincr = clubTotalToday * totalcurrency;
        cumulicativeClubIncomeincr = clubcomulatitve * totalcurrency;
        todaytradeIncomecr = tradeTotalToday * totalcurrency;
        cumulativeIncomecr = tradecomulatitve * totalcurrency;
        todayprofitincr = alltodayprofitSharing * totalcurrency;
        cumulativeprofitincr = profitCumulative * totalcurrency;
        raoyltyintodaycr = royaltytoday * totalcurrency;
        cumulativeroayalty_incr = royaltycumulative * totalcurrency;
        stakingtodayincr = stakingprofitToday * totalcurrency;
        stakingcumulativeincr = stakingcumulative * totalcurrency;
      });
    }
  }

  _getprofitsharing() async {
    try {
      final res = await CommonMethod().getprofitSharing();
      if (res.status == "success") {
        var data = res.data;
        setState(() {
          alltodayprofitSharing = data.profitToday == null
              ? 0.0
              : double.parse(data.profitToday.toString());
          profitCumulative = data.cumulativeProfit == null
              ? 0.0
              : data.cumulativeProfit.toDouble();
        });
      } else {
        showtoast(res.message, context);
      }
    } catch (e) {
      print(e);
    }
  }

  _getroaylty() async {
    try {
      final res = await CommonMethod().getroyalty();
      if (res.status == "success") {
        var data = res.data;
        setState(() {
          royaltytoday =
              data.profitToday == null ? 0.0 : double.parse(data.profitToday);
          royaltycumulative = data.cumulativeProfit == null
              ? 0.0
              : data.cumulativeProfit.toDouble();
        });
      } else {
        showtoast(res.message, context);
      }
    } catch (e) {
      print(e);
    }
  }

  _fatchALl() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    await _getLevelIncome();
    await _getclubIncome();
    await _getTradeIncome();
    await _getprofitsharing();
    await _getroaylty();
    await getCurrency();
    await _commonMethod();
    // await _getStakingIncome();
    await getCurrency();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fatchALl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bg,
        body: RepaintBoundary(
          key: previewContainer,
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: securetradeaicolor,
                  ),
                )
              : Container(
                  color: bg,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Text(
                            "allincome".tr,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 60,
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0)),
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
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      allincometodayProfit.toStringAsFixed(4) +
                                          " (${currentCurrency == "null" ? "USD" : currentCurrency})",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
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
                                    Text(
                                      "Cumulative Profit",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      cumulativeprofitcr.toStringAsFixed(4) +
                                          " (${currentCurrency == "null" ? "USD" : currentCurrency})",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: Text(
                            "levelincome".tr,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 60,
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0)),
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
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      leveltotalProfitTodayCr.toString() +
                                          " (${currentCurrency == "null" ? "USD" : currentCurrency})", // change
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
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
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      levelIncomeComulativeCr.toString() +
                                          " (${currentCurrency == "null" ? "USD" : currentCurrency})", // change
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: Text(
                            "Trading Level Income".tr,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 60,
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0)),
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
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      todayclubincomeincr.toString() +
                                          " (${currentCurrency == "null" ? "USD" : currentCurrency})", // change
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
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
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      cumulicativeClubIncomeincr.toString() +
                                          " (${currentCurrency == "null" ? "USD" : currentCurrency})", // change
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: Text(
                            "Reward Income",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 60,
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Total Profit Today",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      todaytradeIncomecr.toString() +
                                          " (${currentCurrency == "null" ? "USD" : currentCurrency})", // change
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
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
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      cumulativeIncomecr.toString() +
                                          " (${currentCurrency == "null" ? "USD" : currentCurrency})", // change
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        // Container(
                        //   child: Text(
                        //     "profitSharingincome".tr,
                        //     style: TextStyle(
                        //       color: Colors.black,
                        //       fontWeight: FontWeight.bold,
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 10,
                        // ),
                        // Container(
                        //   height: 60,
                        //   decoration: const BoxDecoration(
                        //     gradient: LinearGradient(
                        //       begin: Alignment.topCenter,
                        //       end: Alignment.bottomCenter,
                        //       stops: [0.0, 1.0],
                        //       colors: [
                        //         Colors.green,
                        //         Colors.blue,
                        //       ],
                        //     ),
                        //     borderRadius:
                        //         const BorderRadius.all(Radius.circular(10.0)),
                        //   ),
                        //   child: Center(
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                        //       children: [
                        //         Column(
                        //           mainAxisAlignment: MainAxisAlignment.center,
                        //           children: [
                        //             Text(
                        //               "Total Profit Today",
                        //               style: TextStyle(
                        //                   color: Colors.white,
                        //                   fontWeight: FontWeight.bold),
                        //             ),
                        //             SizedBox(
                        //               height: 5,
                        //             ),
                        //             Text(
                        //               todayprofitincr.toString() +
                        //                   " (${currentCurrency == "null" ? "USD" : currentCurrency})", // change
                        //               style: TextStyle(
                        //                   color: Colors.white,
                        //                   fontWeight: FontWeight.bold),
                        //             )
                        //           ],
                        //         ),
                        //         Container(
                        //           margin: EdgeInsets.only(top: 5, bottom: 5),
                        //           child: const VerticalDivider(
                        //             color: Colors.white70,
                        //             thickness: 2,
                        //           ),
                        //         ),
                        //         Column(
                        //           mainAxisAlignment: MainAxisAlignment.center,
                        //           children: [
                        //             const Text(
                        //               "Cumulative Profit",
                        //               style: TextStyle(
                        //                   color: Colors.white,
                        //                   fontWeight: FontWeight.bold),
                        //             ),
                        //             SizedBox(
                        //               height: 5,
                        //             ),
                        //             Text(
                        //               cumulativeprofitincr.toString() +
                        //                   " (${currentCurrency == "null" ? "USD" : currentCurrency})", // change
                        //               style: TextStyle(
                        //                   color: Colors.white,
                        //                   fontWeight: FontWeight.bold),
                        //             ),
                        //           ],
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 10,
                        // ),
                        // Container(
                        //   child: const Text(
                        //     "Royalty Income",
                        //     style: TextStyle(
                        //       color: Colors.black,
                        //       fontWeight: FontWeight.bold,
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 10,
                        // ),
                        // Container(
                        //   height: 60,
                        //   decoration: const BoxDecoration(
                        //     gradient: LinearGradient(
                        //       begin: Alignment.topCenter,
                        //       end: Alignment.bottomCenter,
                        //       stops: [0.0, 1.0],
                        //       colors: [
                        //         Colors.green,
                        //         Colors.blue,
                        //       ],
                        //     ),
                        //     borderRadius:
                        //         const BorderRadius.all(Radius.circular(10.0)),
                        //   ),
                        //   child: Center(
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                        //       children: [
                        //         Column(
                        //           mainAxisAlignment: MainAxisAlignment.center,
                        //           children: [
                        //             Text(
                        //               "Total Profit Today",
                        //               style: TextStyle(
                        //                   color: Colors.white,
                        //                   fontWeight: FontWeight.bold),
                        //             ),
                        //             SizedBox(
                        //               height: 5,
                        //             ),
                        //             Text(
                        //               raoyltyintodaycr.toString() +
                        //                   " (${currentCurrency == "null" ? "USD" : currentCurrency})", // change
                        //               style: TextStyle(
                        //                   color: Colors.white,
                        //                   fontWeight: FontWeight.bold),
                        //             )
                        //           ],
                        //         ),
                        //         Container(
                        //           margin: EdgeInsets.only(top: 5, bottom: 5),
                        //           child: const VerticalDivider(
                        //             color: Colors.white70,
                        //             thickness: 2,
                        //           ),
                        //         ),
                        //         Column(
                        //           mainAxisAlignment: MainAxisAlignment.center,
                        //           children: [
                        //             const Text(
                        //               "Cumulative Profit",
                        //               style: TextStyle(
                        //                   color: Colors.white,
                        //                   fontWeight: FontWeight.bold),
                        //             ),
                        //             SizedBox(
                        //               height: 5,
                        //             ),
                        //             Text(
                        //               cumulativeroayalty_incr.toString() +
                        //                   " (${currentCurrency == "null" ? "USD" : currentCurrency})", // change
                        //               style: TextStyle(
                        //                   color: Colors.white,
                        //                   fontWeight: FontWeight.bold),
                        //             ),
                        //           ],
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 10,
                        // ),
                      ],
                    ),
                  ),
                ),
        ),
        bottomNavigationBar: GestureDetector(
            child: InkWell(
          onTap: () {
            ShareFilesAndScreenshotWidgets().shareScreenshot(
                previewContainer,
                originalSize,
                "Share Screen Shot",
                "Screenshot.png",
                "image/png",
                text: "Hare are my earning details from Trustcoin.");
          },
          child: Container(
              margin: EdgeInsets.only(bottom: 10),
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
              height: 50,
              width: double.infinity,
              child: Center(
                  child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.share_sharp,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "share".tr,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )
                ],
              ))),
        )));
  }
}
