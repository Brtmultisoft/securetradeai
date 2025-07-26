import 'dart:async';
import 'dart:convert';

// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:securetradeai/data/api.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/method/homepageProvider.dart';
import 'package:securetradeai/model/repoModel.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/Service/subscription_service.dart';
import 'package:securetradeai/src/homepage/Maintradesetting.dart';
import 'package:securetradeai/src/homepage/SubbinMode.dart';
import 'package:securetradeai/src/more/revenue.dart';
import 'package:securetradeai/src/more/userguide.dart';
import 'package:securetradeai/src/more/videos.dart';
import 'package:securetradeai/src/profile/profileoption/APIBinding/apibinding.dart';
import 'package:securetradeai/src/profile/profileoption/Allincome.dart';
import 'package:securetradeai/src/profile/profileoption/Arbitrade/arbitrade.dart';
import 'package:securetradeai/src/profile/profileoption/Team/team.dart';
import 'package:securetradeai/src/quantitative/quatitativepage.dart';
import 'package:securetradeai/src/widget/animated_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../future_trading/future_trading_section.dart';
import '../profile/profileoption/Transaction/payment_section.dart';
import '../profile/profileoption/assets/autoDeposit.dart';
import '../profile/profileoption/assets/auto_deposit.dart';
import '../profile/profileoption/share/share.dart';
import '../tabscreen/tabscreen.dart';
import '../versionpopup/popupdesign.dart';

// OPTIMIZATION: Import optimized services and widgets (ready for future use)
// import '../Service/optimized_background_manager.dart';
// import '../Service/optimized_data_processor.dart';
// import '../Service/optimized_bot_service.dart';
// import '../widget/optimized_image.dart';

class Homepage extends StatefulWidget {
  const Homepage({
    Key? key,
    required this.reffral,
  }) : super(key: key);
  final reffral;

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int indexvalue = 0;
  // var items = ['Binance', 'Huobi'];
  // String dropdownvalue = 'Loading';
  String dropdownvalue = 'Binance';

  // List of items in our dropdown menu
  var items = [
    'Binance',
    'Huobi',
    'OKX',
  ];
  var a = GetColor();
  bool isAPIcalled = false;
  Timer? timer;
  Future _checkbaalance() async {
    if (checkBalance) {
      _showDialog();
    }
  }

  _showDialog() async {
    await Future.delayed(const Duration(milliseconds: 50));
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialogBox(
            title: "Notice : ",
            descriptions:
                "Your Wallet Balance is Low, Please Topup your wallet!",
            text: "Ok",
            onclick: () async {
              if (mounted) {
                setState(() {
                  checkBalance = false;
                });
              }

              Navigator.pop(context);
              print('click');
            },
          );
        });
  }

  _getBotSetting() async {
    int statusBot = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final res = await http.post(Uri.parse(getBotsetting),
        body: jsonEncode({"user_id": commonuserId}));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['status'] == "success") {
        setState(() {
          statusBot = int.parse(data['data']);
          botStatus = statusBot.toString();
        });
        prefs.setString('botstatus', data['data'].toString());
      } else {
        showtoast(data['message'], context);
      }
    } else {
      print("server Error");
    }
  }

  _finalFatchdata() async {
    _getExchangeValue();
    final bal = Provider.of<Repo>(context, listen: false);
    final bannerdata = Provider.of<HomePageProvider>(context, listen: false);
    bal.updateBalance(exchanger == "null" ? "Binance" : exchanger);

    bannerdata.getassets();
    exchanger == "Binance"
        ? bannerdata.gettxnAllrecord()
        : bannerdata.gettxnAllrecordHuobi();
    bannerdata.homePageAllRecords(indexvalue);
    bannerdata.getBanner();
    bannerdata.getNewsdata();
    _getBotSetting();
    _checkbaalance();
  }

  _everscountHitMethod() {
    final bannerdata = Provider.of<HomePageProvider>(context, listen: false);
    if (exchanger == "null" || exchanger == "Binance") {
      var a = bannerdata.homePageAllRecords(indexvalue);
      a.then((value) {
        if (value == true) {
          showtoast("No Internet", context);
        }
      });
    } else {
      bannerdata.huobiassets(indexvalue);
    }
  }

  _updateExchangerValue(fexchangevalue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('exchanger', fexchangevalue);
    setState(() {
      exchanger = fexchangevalue;
    });
  }

  _getExchangeValue() {
    setState(() {
      dropdownvalue = exchanger == "null" ? "Binance" : exchanger;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _finalFatchdata();
    _updateRank();
    timer = Timer.periodic(
        const Duration(seconds: 2), (Timer t) => _everscountHitMethod());
  }

  @override
  void initState() {
    super.initState();
    // Moved initialization to didChangeDependencies
  }

  Future<void> _updateRank() async {
    try {
      var response = await http.post(
        Uri.parse(updateRank),
        body: {'user_id': commonuserId},
      );
      if (response.statusCode == 200) {
        print('Rank updated successfully');
        // Optionally, handle the response data or update your UI here
      } else {
        print('Failed to update rank with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Caught error: $e');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // Manage bot subscription
  Future<void> _activateSubscription() async {
    // Store context before async gap
    final BuildContext currentContext = context;
    final bool isActivated = botStatus == "1";
    final String actionText = isActivated ? "Updating" : "Activating";

    // Show loading dialog
    showDialog(
      context: currentContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2026),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2D35), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                    color: isActivated
                        ? const Color(0xFF00C853)
                        : const Color(0xFFF0B90B)),
                const SizedBox(height: 20),
                Text(
                  "$actionText Bot Subscription...",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AutoDeposit1(),
          )).then((value) async {
        if (value != null && value >= 100) {
          final result =
              await SubscriptionService.activateSubscription(commonuserId);
          // Close loading dialog
          if (Navigator.of(currentContext).canPop()) {
            Navigator.of(currentContext).pop();
          }

          if (result['status'] == 'success') {
            // Update bot status locally
            setState(() {
              botStatus = isActivated ? "0" : "1";
            });

            // Save to SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('botstatus', botStatus);

            // Show success toast
            AnimatedToast.show(
              context: currentContext,
              title: isActivated
                  ? "Subscription Updated"
                  : "Subscription Activated!",
              message: result['message'] ??
                  "Your bot subscription has been ${isActivated ? 'updated' : 'activated'} successfully.",
              status: "success",
              amount: "100",
              currency: "USD",
            );
          } else {
            AnimatedToast.show(
              context: currentContext,
              title: "${isActivated ? 'Update' : 'Activation'} Failed",
              message: result['message'] ??
                  "Failed to ${isActivated ? 'update' : 'activate'} subscription. Please try again later.",
              status: "error",
            );
          }
        } else {
          if (Navigator.of(currentContext).canPop()) {
            Navigator.of(currentContext).pop();
          }
          AnimatedToast.show(
            context: currentContext,
            title: "${isActivated ? 'Update' : 'Activation'} Failed",
            message:
                "Failed to ${isActivated ? 'update' : 'activate'} subscription. Please try again later.",
            status: "error",
          );
        }
      });
      // Call the subscription service
      // final result = await SubscriptionService.activateSubscription(commonuserId);

      // Close loading dialog
      // if (Navigator.of(currentContext).canPop()) {
      //   Navigator.of(currentContext).pop();
      // }

      // if (result['status'] == 'success') {
      //   // Update bot status locally
      //   setState(() {
      //     botStatus = isActivated ? "0" : "1";
      //   });

      //   // Save to SharedPreferences
      //   SharedPreferences prefs = await SharedPreferences.getInstance();
      //   prefs.setString('botstatus', botStatus);

      //   // Show success toast
      //   AnimatedToast.show(
      //     context: currentContext,
      //     title: isActivated ? "Subscription Updated" : "Subscription Activated!",
      //     message: result['message'] ?? "Your bot subscription has been ${isActivated ? 'updated' : 'activated'} successfully.",
      //     status: "success",
      //     amount: "100",
      //     currency: "USD",
      //   );
      // } else {
      // Show error toast
      //       Navigator.push(context,MaterialPageRoute(builder:(context) => AutoDeposit(),)).then((value) => {
      //         if(value){

      //         }
      //         else{
      // AnimatedToast.show(
      //           context: currentContext,
      //           title: "${isActivated ? 'Update' : 'Activation'} Failed",
      //           message: result['message'] ?? "Failed to ${isActivated ? 'update' : 'activate'} subscription. Please try again later.",
      //           status: "error",
      //         );

      //         }
      //       });
      //      }
    } catch (e) {
      // Close loading dialog
      if (Navigator.of(currentContext).canPop()) {
        Navigator.of(currentContext).pop();
      }

      // Show error toast
      AnimatedToast.show(
        context: currentContext,
        title: "Error",
        message: "An error occurred: $e",
        status: "error",
      );
    }
  }

  connect() {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: const Color(0xFF4A90E2),
        backgroundColor: const Color(0xFF0A0E17),
        onRefresh: () {
          Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                  pageBuilder: (a, b, c) => Tabscreen(reffral: widget.reffral),
                  transitionDuration: const Duration(milliseconds: 300),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  }));
          return Future.value(false);
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF0A0E17),
          body: DefaultTabController(
            length: 1,
            child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 10.0),
                      Consumer<HomePageProvider>(
                          builder: (context, banner, child) {
                        // return Container();
                        return CarouselSlider.builder(
                          itemCount: banner.bannerList.length,
                          itemBuilder: (context, index, realIndex) {
                            return banner.bannerList.isEmpty
                                ? Shimmer.fromColors(
                                    baseColor: Color(0xFF1A2234),
                                    highlightColor: Color(0xFF2A3A5A),
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      width: double.infinity,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.5,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF1A2234),
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            spreadRadius: 1,
                                            blurRadius: 10,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    margin: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    width: double.infinity,
                                    height: MediaQuery.of(context).size.height *
                                        0.5,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.0),
                                      image: DecorationImage(
                                          image: NetworkImage(path +
                                              banner.bannerList[index]
                                                  .bannerImage),
                                          fit: BoxFit.fill),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          spreadRadius: 1,
                                          blurRadius: 10,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                  );
                          },
                          options: CarouselOptions(
                            initialPage: 1,
                            aspectRatio: 16 / 8,
                            viewportFraction: 1,
                            autoPlay: true,
                            autoPlayAnimationDuration:
                                Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                          ),
                        );
                      }),
                      // Container(
                      //   height: 20,
                      //   margin:
                      //       const EdgeInsets.only(top: 10, left: 10, right: 10),
                      //   child: Row(
                      //     children: [
                      //       // Text(
                      //       //   "topnews".tr + " : ",
                      //       //   style: const TextStyle(
                      //       //       fontWeight: FontWeight.bold,
                      //       //       fontFamily: fontFamily,
                      //       //       color: Color(0xFF4A90E2)),
                      //       // ),
                      //       // Expanded(
                      //       //   child: Consumer<HomePageProvider>(
                      //       //     builder: (context, banner, child) {
                      //       //       return AnimatedTextKit(
                      //       //           isRepeatingAnimation: true,
                      //       //           repeatForever: true,
                      //       //           onTap: () {
                      //       //             Navigator.push(
                      //       //                 context,
                      //       //                 PageRouteBuilder(
                      //       //                     pageBuilder: (context,
                      //       //                             animation,
                      //       //                             secondaryAnimation) =>
                      //       //                         const TopNews(),
                      //       //                     transitionsBuilder: (context,
                      //       //                         animation,
                      //       //                         secondaryAnimation,
                      //       //                         child) {
                      //       //                       return FadeTransition(
                      //       //                         opacity: animation,
                      //       //                         child: child,
                      //       //                       );
                      //       //                     },
                      //       //                     transitionDuration: Duration(
                      //       //                         milliseconds: 300)));
                      //       //           },
                      //       //           animatedTexts: [
                      //       //             RotateAnimatedText(banner.lastnews,
                      //       //                 textStyle: const TextStyle(
                      //       //                     fontWeight: FontWeight.bold,
                      //       //                     fontFamily: fontfamily,
                      //       //                     color: Colors.white)),
                      //       //           ]);
                      //       //     },
                      //       //   ),
                      //       // ),
                      //     ],
                      //   ),
                      // ),
                      const SizedBox(height: 10),
                      options(),
                    ]),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        labelPadding:
                            const EdgeInsets.only(left: 10, right: 10),
                        isScrollable: true,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorColor: const Color(0xFF4A90E2),
                        indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFF4A90E2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4A90E2).withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ]),
                        labelStyle: const TextStyle(fontFamily: fontFamily),
                        tabs: [
                          Tab(
                            child: Container(
                              width: 120,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('openTrade'.tr,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 13)),
                            ),
                          ),
                        ],
                        onTap: (v) {
                          setState(() {
                            indexvalue = v;
                          });
                        },
                      ),
                      Container(
                          margin: const EdgeInsets.only(right: 15),
                          child: DropdownButton(
                            value: dropdownvalue,
                            dropdownColor: const Color(0xFF121824),
                            underline: const SizedBox(),
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                            ),
                            items: items.map((String items) {
                              return DropdownMenuItem(
                                  value: items,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                            backgroundColor: Colors.white,
                                            radius: 15.0,
                                            backgroundImage: AssetImage(items ==
                                                    "Binance"
                                                ? "assets/img/bnb2.png"
                                                : items == "OKX"
                                                    ? "assets/img/okx.jpeg"
                                                    : "assets/img/huboi.png")),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          items,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ));
                            }).toList(),
                            onChanged: (String? newValue) {
                              _updateExchangerValue(newValue);
                              setState(() {
                                final bal =
                                    Provider.of<Repo>(context, listen: false);
                                bal.updateBalance(newValue.toString());
                                dropdownvalue = newValue.toString();
                              });
                              Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          Tabscreen(reffral: widget.reffral),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                      transitionDuration:
                                          const Duration(milliseconds: 300)));
                            },
                          )),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: dropdownvalue != "Binance"
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2234),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Image.asset("assets/img/commingsoon.png"),
                      ),
                    )
                  : Consumer<HomePageProvider>(builder: (context, list, child) {
                      return TabBarView(
                        children: [
                          exchanger == "Binance"
                              ? list.check_TransactionData
                                  ? Container(
                                      margin: const EdgeInsets.only(top: 20),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1A2234),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            spreadRadius: 1,
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Image.asset("assets/img/logo.png"),
                                    )
                                  : list.finalTransactionData.isEmpty
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                              color: Color(0xFF4A90E2)))
                                      : Column(
                                          children: [
                                            Expanded(
                                                child: _display1(
                                                    list.finalTransactionData)),
                                            const SizedBox(
                                              height: 20,
                                            )
                                          ],
                                        )
                              : list.check_TransactionDatahuobi
                                  ? Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1A2234),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            spreadRadius: 1,
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Image.asset("assets/img/logo.png"),
                                    )
                                  : list.finalTransactionDataHuobi.isEmpty
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                              color: Colors.white))
                                      : Column(
                                          children: [
                                            Expanded(
                                                child: _display1Huobi(list
                                                    .finalTransactionDataHuobi)),
                                            const SizedBox(
                                              height: 20,
                                            )
                                          ],
                                        ),
                        ],
                      );
                    }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _display1Huobi(var _data) {
    return ListView.builder(
        itemCount: _data.length,
        itemBuilder: (cotext, index) {
          double increase = _data[index]['priceChange'];
          bool a = increase.isNegative;
          var b = _data[index]['symbol'].toString();
          var finalsymble = b.toUpperCase().replaceAll("USDT", "");
          double currentprice = _data[index]['price'];
          double avgprice = double.parse(_data[index]['avg_price']);
          var current_avg = currentprice - avgprice;
          var finalavg = current_avg / avgprice * 100;
          bool checkavgPrice = finalavg.isNegative;
          return InkWell(
            onTap: () {
              _data[index]['type'] == "WWM"
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainTradeSetting(
                                checkNavigate: "Home",
                                coinurl: _data[index]['chartimg'],
                                reffralnno: widget.reffral,
                                coinimg: _data[index]['asset_img'],
                                compaircoinname: _data[index]['symbol'],
                                finalCoinName: finalsymble,
                              )))
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SubbinMode(
                                id: "",
                                checkNavigate: "Home",
                                coinurl: _data[index]['chartimg'],
                                reffralnno: widget.reffral,
                                coinimg: _data[index]['asset_img'],
                                compaircoinname: _data[index]['symbol'],
                                finalCoinName: finalsymble,
                              )));
            },
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2234),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      border: Border.all(
                        color: const Color(0xFF2A3A5A),
                        width: 1,
                      ),
                    ),
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: double.infinity,
                    child: Container(
                      margin:
                          const EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                      radius: 15.0,
                                      backgroundImage: _data[index]
                                                  ['asset_img'] ==
                                              null
                                          ? const NetworkImage(
                                              "https://securetradeai.com/assets/images/logo/logo2.png")
                                          : NetworkImage(
                                              _data[index]['asset_img'])),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                          child: Text(finalsymble,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: fontFamily,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white))),
                                      Container(
                                          child: const Text("/USDT",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontFamily: fontFamily,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white))),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFF2A3A5A))),
                                  width: 60,
                                  height: 25,
                                  child: Center(
                                    child: Text(
                                      _data[index]['cycle'] == "0"
                                          ? "Cycle"
                                          : "One Shot",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  )),
                              Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFF2A3A5A))),
                                  width: 60,
                                  height: 25,
                                  child: Center(
                                    child: Text(
                                      _data[index]['type'] ?? "",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  )),
                              Container(
                                  decoration: BoxDecoration(
                                    color: checkavgPrice
                                        ? const Color(0xFFE53935)
                                            .withOpacity(0.1)
                                        : const Color(0xFF00C853)
                                            .withOpacity(0.1),
                                    border: Border.all(
                                        color: const Color(0xFF2A3A5A)),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(6)),
                                  ),
                                  width: 70,
                                  height: 25,
                                  child: Center(
                                    child: Text(
                                        double.parse(finalavg.toString())
                                                .toStringAsFixed(3) +
                                            r" $",
                                        style: TextStyle(
                                            color: checkavgPrice
                                                ? const Color(0xFFE53935)
                                                : const Color(0xFF00C853),
                                            fontWeight: FontWeight.bold)),
                                  )),
                            ],
                          ),
                          const Divider(
                            color: Color(0xFF2A3A5A),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: Row(children: <Widget>[
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'quantity'.tr,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontFamily: fontFamily,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                        text: " " + _data[index]['qty'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontFamily: fontFamily)),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: Row(children: <Widget>[
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'price'.tr,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontFamily: fontFamily,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                        text: " : " +
                                            _data[index]['price'].toString(),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            fontFamily: fontFamily)),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                        text: 'Increase' + " : ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontFamily: fontFamily)),
                                    TextSpan(
                                        text: increase.toStringAsFixed(4),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: a
                                                ? const Color(0xFFE53935)
                                                : const Color(0xFF00C853),
                                            fontSize: 14,
                                            fontFamily: fontFamily)),
                                  ],
                                ),
                              )
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _display1(var _data) {
    return ListView.builder(
        itemCount: _data.length,
        itemBuilder: (cotext, index) {
          bool a = double.parse(_data[index]['priceChange']).isNegative;
          var b = _data[index]['symbol'].toString();
          var finalsymble = b.replaceAll("USDT", "");
          var finalavg;
          bool checkavgPrice = false;
          double currentprice = double.parse(_data[index]['price']);
          double posqty = double.parse(_data[index]['pos_qty']);
          double posMultiplyCurrntprice = posqty * currentprice;
          var CalfinalAVG =
              posMultiplyCurrntprice - double.parse(_data[index]['pos_amt']);
          finalavg = CalfinalAVG;
          checkavgPrice = CalfinalAVG.isNegative;
          return InkWell(
            onTap: () {
              _data[index]['type'] == "WWM"
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainTradeSetting(
                          checkNavigate: "Home",
                          coinurl: _data[index]['chartimg'],
                          reffralnno: widget.reffral,
                          coinimg: _data[index]['asset_img'],
                          compaircoinname: _data[index]['symbol'],
                          finalCoinName: finalsymble,
                        ),
                      ))
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SubbinMode(
                                id: _data[index]['id'],
                                checkNavigate: "Home",
                                coinurl: _data[index]['chartimg'],
                                reffralnno: widget.reffral,
                                coinimg: _data[index]['asset_img'],
                                compaircoinname: _data[index]['symbol'],
                                finalCoinName: finalsymble,
                              )));
            },
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2234),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      border: Border.all(
                        color: const Color(0xFF2A3A5A),
                        width: 1,
                      ),
                    ),
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: double.infinity,
                    child: Container(
                      margin:
                          const EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                      radius: 15.0,
                                      backgroundImage: _data[index]
                                                  ['asset_img'] ==
                                              null
                                          ? const NetworkImage(
                                              "https://securetradeai.com/assets/images/logo/logo2.png")
                                          : NetworkImage(
                                              _data[index]['asset_img'])),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                          child: Text(finalsymble,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                  fontFamily: fontFamily,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      Container(
                                          child: const Text("/USDT",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white,
                                                  fontFamily: fontFamily,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFF2A3A5A))),
                                  width: 60,
                                  height: 25,
                                  child: Center(
                                    child: Text(
                                      _data[index]['cycle'] == "0"
                                          ? "Cycle"
                                          : "One Shot",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  )),
                              Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFF2A3A5A))),
                                  width: 60,
                                  height: 25,
                                  child: Center(
                                    child: Text(
                                      _data[index]['type'] ?? "emptys",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  )),
                              Container(
                                  decoration: BoxDecoration(
                                    color: checkavgPrice
                                        ? const Color(0xFFE53935)
                                            .withOpacity(0.1)
                                        : const Color(0xFF00C853)
                                            .withOpacity(0.1),
                                    border: Border.all(
                                        color: const Color(0xFF2A3A5A)),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(6)),
                                  ),
                                  width: 70,
                                  height: 25,
                                  child: Center(
                                    child: Text(
                                        double.parse(finalavg.toString())
                                                .toStringAsFixed(3) +
                                            r" $",
                                        style: TextStyle(
                                            color: checkavgPrice
                                                ? const Color(0xFFE53935)
                                                : const Color(0xFF00C853),
                                            fontWeight: FontWeight.bold)),
                                  )),
                            ],
                          ),
                          const Divider(
                            color: Color(0xFF2A3A5A),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: Row(children: <Widget>[
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'quantity'.tr,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontFamily: fontFamily,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                        text: " " + _data[index]['qty'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontFamily: fontFamily)),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: Row(children: <Widget>[
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'price'.tr,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontFamily: fontFamily,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                        text: " : ${_data[index]['price']}",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            fontFamily: fontFamily)),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                        text: 'Increase' + " : ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontFamily: fontFamily)),
                                    TextSpan(
                                        text: _data[index]['priceChange'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: a
                                                ? const Color(0xFFE53935)
                                                : const Color(0xFF00C853),
                                            fontSize: 14,
                                            fontFamily: fontFamily)),
                                  ],
                                ),
                              )
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget options() {
    // Theme colors
    const Color binanceYellow = Color(0xFFF0B90B);
    const Color cardBorder = Color(0xFF2A3A5A);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // // Bot Subscription button with enhanced design
          // Container(
          //   margin: const EdgeInsets.only(bottom: 12, left: 2, right: 2),
          //   decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //       begin: Alignment.topLeft,
          //       end: Alignment.bottomRight,
          //       colors: [
          //         botStatus == "1"
          //             ? const Color(0xFF0A3D1A)
          //             ? const Color(0xFF0A3D1A)
          //             : const Color(0xFF0F1923),
          //         botStatus == "1"
          //             ? const Color(0xFF052510)
          //             : const Color(0xFF0A1218),
          //       ],
          //     ),
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(
          //       color:
          //           botStatus == "1" ? const Color(0xFF00C853) : binanceYellow,
          //       width: 1.5,
          //     ),
          //     boxShadow: [
          //       BoxShadow(
          //         color: (botStatus == "1"
          //                 ? const Color(0xFF00C853)
          //                 : binanceYellow)
          //             .withOpacity(0.15),
          //         spreadRadius: 0,
          //         blurRadius: 12,
          //         offset: const Offset(0, 4),
          //       ),
          //     ],
          //   ),
          //   // child: Material(
          //   //   color: Colors.transparent,
          //   //   child: InkWell(
          //   //     borderRadius: BorderRadius.circular(12),
          //   //     onTap: botStatus == "1" ? null : () => _activateSubscription(),
          //   //     splashColor: binanceYellow.withOpacity(0.1),
          //   //     highlightColor: binanceYellow.withOpacity(0.05),
          //   //     child: Padding(
          //   //       padding: const EdgeInsets.symmetric(
          //   //           vertical: 16,
          //   //           horizontal: 6), // Reduced horizontal padding
          //   //       child: Row(
          //   //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   //         children: [
          //   //           Row(
          //   //             children: [
          //   //               // Animated icon container with glow effect
          //   //               // Container(
          //   //               //   height: 45,
          //   //               //   width: 45,
          //   //               //   decoration: BoxDecoration(
          //   //               //     gradient: LinearGradient(
          //   //               //       begin: Alignment.topLeft,
          //   //               //       end: Alignment.bottomRight,
          //   //               //       colors: [
          //   //               //         (botStatus == "1"
          //   //               //                 ? const Color(0xFF00C853)
          //   //               //                 : binanceYellow)
          //   //               //             .withOpacity(0.15),
          //   //               //         (botStatus == "1"
          //   //               //                 ? const Color(0xFF00C853)
          //   //               //                 : binanceYellow)
          //   //               //             .withOpacity(0.05),
          //   //               //       ],
          //   //               //     ),
          //   //               //     borderRadius: BorderRadius.circular(10),
          //   //               //     border: Border.all(
          //   //               //       color: (botStatus == "1"
          //   //               //               ? const Color(0xFF00C853)
          //   //               //               : binanceYellow)
          //   //               //           .withOpacity(0.3),
          //   //               //       width: 1.5,
          //   //               //     ),
          //   //               //     boxShadow: [
          //   //               //       BoxShadow(
          //   //               //         color: (botStatus == "1"
          //   //               //                 ? const Color(0xFF00C853)
          //   //               //                 : binanceYellow)
          //   //               //             .withOpacity(0.2),
          //   //               //         spreadRadius: 0,
          //   //               //         blurRadius: 10,
          //   //               //         offset: const Offset(0, 2),
          //   //               //       ),
          //   //               //     ],
          //   //               //   ),
          //   //               //   child: Center(
          //   //               //     child: Image.asset(
          //   //               //       "assets/img/rocket.png",
          //   //               //       color: botStatus == "1"
          //   //               //           ? const Color(0xFF00C853)
          //   //               //           : binanceYellow,
          //   //               //       height: 30,
          //   //               //       width: 30,
          //   //               //     ),
          //   //               //   ),
          //   //               // ),
          //   //               // const SizedBox(width: 10),
          //   //               // Column(
          //   //               //   crossAxisAlignment: CrossAxisAlignment.start,
          //   //               //   mainAxisAlignment: MainAxisAlignment.center,
          //   //               //   children: [
          //   //               //     const Text(
          //   //               //       "Bot Subscription",
          //   //               //       style: TextStyle(
          //   //               //         color: Colors.white,
          //   //               //         fontWeight: FontWeight.bold,
          //   //               //         fontSize: 16,
          //   //               //       ),
          //   //               //     ),
          //   //               //     const SizedBox(height: 4),
          //   //               //     Row(
          //   //               //       children: [
          //   //               //         const Text(
          //   //               //           "Trading automation",
          //   //               //           style: TextStyle(
          //   //               //             color: Color(0xFF848E9C),
          //   //               //             fontSize: 13,
          //   //               //           ),
          //   //               //         ),
          //   //               //         if (botStatus == "1") ...[
          //   //               //           // Show status indicator if activated
          //   //               //           const SizedBox(width: 8),
          //   //               //           Container(
          //   //               //             padding: const EdgeInsets.symmetric(
          //   //               //                 horizontal: 6, vertical: 2),
          //   //               //             decoration: BoxDecoration(
          //   //               //               color: const Color(0xFF00C853)
          //   //               //                   .withOpacity(0.2),
          //   //               //               borderRadius: BorderRadius.circular(4),
          //   //               //             ),
          //   //               //             child: Row(
          //   //               //               mainAxisSize: MainAxisSize.min,
          //   //               //               children: const [
          //   //               //                 Icon(
          //   //               //                   Icons.check_circle,
          //   //               //                   color: Color(0xFF00C853),
          //   //               //                   size: 12,
          //   //               //                 ),
          //   //               //                 SizedBox(width: 4),
          //   //               //                 Text(
          //   //               //                   "Active",
          //   //               //                   style: TextStyle(
          //   //               //                     color: Color(0xFF00C853),
          //   //               //                     fontSize: 10,
          //   //               //                     fontWeight: FontWeight.bold,
          //   //               //                   ),
          //   //               //                 ),
          //   //               //               ],
          //   //               //             ),
          //   //               //           ),
          //   //               //         ],
          //   //               //       ],
          //   //               //     ),
          //   //               //   ],
          //   //               // ),
          //   //             ],
          //   //           ),
          //   //
          //   //           /// Enhanced button with gradient
          //   //           Container(
          //   //             height: 38,
          //   //             width: 68, // Reduced width to fix overflow
          //   //             padding: const EdgeInsets.symmetric(
          //   //                 horizontal: 2), // Reduced padding
          //   //             decoration: BoxDecoration(
          //   //               gradient: LinearGradient(
          //   //                 begin: Alignment.topLeft,
          //   //                 end: Alignment.bottomRight,
          //   //                 colors: [
          //   //                   botStatus == "1"
          //   //                       ? const Color(0xFF00C853)
          //   //                       : const Color(0xFFF0B90B),
          //   //                   botStatus == "1"
          //   //                       ? const Color(0xFF009940)
          //   //                       : const Color(0xFFE0AA0A),
          //   //                 ],
          //   //               ),
          //   //               borderRadius: BorderRadius.circular(8),
          //   //               boxShadow: [
          //   //                 BoxShadow(
          //   //                   color: (botStatus == "1"
          //   //                           ? const Color(0xFF00C853)
          //   //                           : binanceYellow)
          //   //                       .withOpacity(0.3),
          //   //                   spreadRadius: 0,
          //   //                   blurRadius: 8,
          //   //                   offset: const Offset(0, 2),
          //   //                 ),
          //   //               ],
          //   //             ),
          //   //
          //   //             /// subscribed  or subscribe
          //   //             child: Center(
          //   //               child: Text(
          //   //                 botStatus == "1" ? "Subscribed" : "Subscribe",
          //   //                 style: const TextStyle(
          //   //                   color: Colors.black,
          //   //                   fontWeight: FontWeight.bold,
          //   //                   fontSize: 12,
          //   //                 ),
          //   //               ),
          //   //             ),
          //   //           ),
          //   //         ],
          //   //       ),
          //   //     ),
          //   //   ),
          //   // ),
          // ),

          // Section title with yellow indicator

          /// trading
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: binanceYellow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Trading Bots",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          /// Future and Spot trading bots
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF161D2B),
                  Color(0xFF0F1923),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: cardBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.3,
                children: [
                  /// Arbitrade
                  _buildGridOptionItem(
                    icon: "assets/img/stock.png",
                    label: "Arbitrade Trading",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ArbiTradeSection())),
                  ),

                  /// Spot trading
                  _buildGridOptionItem(
                    icon: "assets/img/spot_trading.png",
                    label: "Spot Trading",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SpotTradingService(),
                        )),
                  ),

                  /// future trading
                  _buildGridOptionItem(
                    icon: "assets/img/future_trading.png",
                    label: "Future Trading",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const FutureTradingSection())),
                  ),

                  ///  Api Binding
                  _buildGridOptionItem(
                    icon: "assets/img/api.png",
                    label: "API Binding",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ApiBinding())),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: binanceYellow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Reports",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Trading Tools card with improved grid layout
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF161D2B),
                  Color(0xFF0F1923),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: cardBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.3,
                children: [
                  /// Trading Revenue
                  _buildGridOptionItem(
                    icon: "assets/img/cycle.png",
                    label: "Trading Revenue",
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Revenue())),
                  ),

                  /// Reward Details
                  _buildGridOptionItem(
                    icon: "assets/img/user.png",
                    label: "Reward Details",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AllIncome(initialTabIndex: 2))),
                  ),

                  /// Transactions
                  _buildGridOptionItem(
                    icon: "assets/img/transaction.png",
                    label: "Transactions",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PaymentSection())),
                  ),

                  /// My Team
                  _buildGridOptionItem(
                    icon: "assets/img/team.png",
                    label: "My Team",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Team(image: null))),
                  ),
                ],
              ),
            ),
          ),

          /// Section title with yellow indicator
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: binanceYellow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Fund Management",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          /// Fund Management card with improved grid layout
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF161D2B),
                  Color(0xFF0F1923),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: cardBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.3,
                children: [
                  /// Gas Wallet
                  _buildGridOptionItem(
                    icon: "assets/img/make_money.png",
                    label: "Gas Wallet",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AutoDeposit(),
                      ),
                    ),
                  ),

                  /// Withdrawal Wallet
                  _buildGridOptionItem(
                    icon: "assets/img/money-withdrawal.png",
                    label: "Withdrawal",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AutoDeposit(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Section title with yellow indicator
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: binanceYellow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "More Services",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          /// More Services card with improved grid layout
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF161D2B),
                  Color(0xFF0F1923),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: cardBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.3,
                children: [
                  /// User Guide
                  _buildGridOptionItem(
                    icon: "assets/img/userguide.png",
                    label: "User Guide",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserGuide())),
                  ),

                  /// Videos
                  _buildGridOptionItem(
                    icon: "assets/img/video.png",
                    label: "Videos",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const VideoScreen())),
                  ),

                  /// Invite Friends
                  _buildGridOptionItem(
                    icon: "assets/img/invitefriend.png",
                    label: "Invite Friends",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Sharescreen(reffral: widget.reffral))),
                  ),

                  // Gas Wallet
                  _buildGridOptionItem(
                    icon: "assets/img/make_money.png",
                    label: "Gas Wallet",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AutoDeposit())),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Grid option item for Trading Tools section
  Widget _buildGridOptionItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    // Theme colors
    const Color yellow = Color(0xFFF0B90B);
    const Color cardBorder = Color(0xFF2A3A5A);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        splashColor: yellow.withOpacity(0.1),
        highlightColor: yellow.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2234),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: cardBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative corner accent
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  height: 5,
                  width: 5,
                  decoration: BoxDecoration(
                    color: yellow.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                ),
              ),
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            yellow.withOpacity(0.15),
                            yellow.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: yellow.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: yellow.withOpacity(0.1),
                            spreadRadius: 0,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          icon,
                          color: yellow,
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Widget _dropdown;

  _SliverAppBarDelegate(this._tabBar, this._dropdown);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF0A0E17),
      child: Row(
        children: [
          Expanded(child: _tabBar),
          _dropdown,
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
