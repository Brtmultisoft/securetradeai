import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
import 'package:securetradeai/src/profile/profileoption/assets/withdrawal.dart';
import 'package:securetradeai/src/quantitative/quatitativepage.dart';
import 'package:securetradeai/src/widget/animated_toast.dart';
import 'package:securetradeai/src/widget/enhanced_loading.dart';
import 'package:securetradeai/src/widget/lottie_loading_widget.dart';
import 'package:securetradeai/src/widget/page_transitions.dart';
import 'package:securetradeai/src/widget/trading_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
    _checkAppVersion(); // Add version check on home screen load
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
      } else {}
    } catch (e) {}
  }

  // Method to launch URL in browser
  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {}
    } catch (e) {}
  }

  // Version check method
  Future<void> _checkAppVersion() async {
    try {
      print('🔍 Starting version check process...');
      print('🌐 API Endpoint: $getversion');

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      print('📱 Current app version: ${packageInfo.version}');
      print('📱 App name: ${packageInfo.appName}');
      print('📱 Package name: ${packageInfo.packageName}');
      print('📱 Build number: ${packageInfo.buildNumber}');

      print('🚀 Making API request to version check endpoint...');

      // Add a timeout to prevent getting stuck
      final res = await http
          .get(Uri.parse(getversion))
          .timeout(Duration(seconds: 10), onTimeout: () {
        print('⚠️ Version check timed out after 10 seconds');
        return http.Response('{"status":"timeout"}', 408);
      });

      print('📡 HTTP Status Code: ${res.statusCode}');
      print('📡 Response Headers: ${res.headers}');
      print('🌐 Raw API Response: ${res.body}');

      if (res.statusCode != 200) {
        print('❌ Version check failed with HTTP status: ${res.statusCode}');
        print('⚠️ Continuing with app execution');
        return;
      }

      var jsondata = jsonDecode(res.body);
      print('📋 Parsed JSON data: $jsondata');

      if (jsondata['status'] == "success") {
        String serverVersion = jsondata['version'].toString();
        String currentVersion = packageInfo.version.toString();

        // Extract major version number for comparison (e.g., "2.0.0" -> "2")
        String currentMajorVersion = currentVersion.split('.')[0];

        print('🔍 VERSION COMPARISON:');
        print('   📦 Server version: "$serverVersion"');
        print('   📱 Current version: "$currentVersion"');
        print('   📱 Current major version: "$currentMajorVersion"');
        print('   🔄 Versions match: ${serverVersion == currentMajorVersion}');

        // Fixed version check logic - compare server version with major version
        if (serverVersion != currentMajorVersion) {
          print('🚨 UPDATE REQUIRED!');
          print('   ⬆️ Server has version: $serverVersion');
          print('   📱 App has version: $currentVersion');
          print('   🔔 Showing update dialog...');

          if (mounted) {
            showDialog(
                context: context,
                barrierDismissible:
                    false, // Prevent dismissing by tapping outside
                builder: (BuildContext context) {
                  return CustomDialogBox(
                    title: "Update Required",
                    descriptions:
                        "A new version is available. Please update to continue using the app.",
                    text: "Download Latest Version",
                    onclick: () {
                      print(
                          '🌐 User clicked update button, redirecting to website...');
                      // Redirect to website for download instead of app store
                      _launchURL('https://securetradeai.com');
                    },
                  );
                });
          }
        } else {
          print('✅ VERSION CHECK PASSED!');
          print(
              '   📱 App is up to date with version: $currentVersion (major: $currentMajorVersion)');
          print('   ➡️ Continuing with normal app flow...');
        }
      } else {
        print('❌ API returned error status: ${jsondata['status']}');
        print('📋 Full response: $jsondata');
        print('⚠️ Continuing with app execution despite version check failure');
      }
    } catch (e) {
      print('❌ Error in version check: $e');
      print('🔍 Exception details: ${e.toString()}');
      print('⚠️ Continuing with app execution despite version check error');
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
                const LottieLoadingWidget.medium(),
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
        color: const Color(0xFFF0B90B),
        backgroundColor: const Color(0xFF0A0E17),
        strokeWidth: 3.0,
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
          // Add a subtle gradient background
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0E17),
                  Color(0xFF0F1419),
                  Color(0xFF0A0E17),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: DefaultTabController(
              length: 1,
              child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 15.0),
                        _homeHeader(context),
                        // Enhanced banner carousel with better styling
                        FadeSlideTransition(
                          delay: const Duration(milliseconds: 200),
                          child: Consumer<HomePageProvider>(
                              builder: (context, banner, child) {
                            return CarouselSlider.builder(
                              itemCount: banner.bannerList.length,
                              itemBuilder: (context, index, realIndex) {
                                return banner.bannerList.isEmpty
                                    ? EnhancedShimmer(
                                        baseColor: const Color(0xFF1A2234),
                                        highlightColor: const Color(0xFF2A3A5A),
                                        direction: ShimmerDirection.leftToRight,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              30,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.5,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1A2234),
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFF0B90B)
                                                    .withOpacity(0.1),
                                                spreadRadius: 0,
                                                blurRadius: 20,
                                                offset: const Offset(0, 8),
                                              ),
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.4),
                                                spreadRadius: 0,
                                                blurRadius: 15,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                30,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.5,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          child: Stack(
                                            children: [
                                              // Background image
                                              Positioned.fill(
                                                child: Image.network(
                                                  path +
                                                      banner.bannerList[index]
                                                          .bannerImage,
                                                  fit: BoxFit.fill,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      color: const Color(
                                                          0xFF1A2234),
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons
                                                              .image_not_supported,
                                                          color:
                                                              Color(0xFF848E9C),
                                                          size: 50,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              // Gradient overlay for better text readability
                                              Positioned.fill(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                      colors: [
                                                        Colors.transparent,
                                                        Colors.black
                                                            .withOpacity(0.3),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Decorative corner accent
                                              Positioned(
                                                top: 15,
                                                right: 15,
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFF0B90B)
                                                            .withOpacity(0.9),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: const Color(
                                                                0xFFF0B90B)
                                                            .withOpacity(0.3),
                                                        spreadRadius: 0,
                                                        blurRadius: 8,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Text(
                                                    'Featured',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                              },
                              options: CarouselOptions(
                                initialPage: 0,
                                aspectRatio: 16 / 8,
                                viewportFraction: 1.0,
                                autoPlay: true,
                                autoPlayAnimationDuration:
                                    const Duration(milliseconds: 1000),
                                autoPlayCurve: Curves.easeInOutCubic,
                                enlargeCenterPage: false,
                                scrollDirection: Axis.horizontal,
                              ),
                            );
                          }),
                        ),
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
                                  color:
                                      const Color(0xFF4A90E2).withOpacity(0.3),
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
                    : Consumer<HomePageProvider>(
                        builder: (context, list, child) {
                        return SizedBox.shrink(
                          child: TabBarView(
                            children: [
                              exchanger == "Binance"
                                  ? list.check_TransactionData
                                      ? Container(
                                          margin:
                                              const EdgeInsets.only(top: 20),
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1A2234),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                spreadRadius: 1,
                                                blurRadius: 10,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Image.asset(
                                              "assets/img/logo.png"),
                                        )
                                      : list.finalTransactionData.isEmpty
                                          ? const Center(
                                              child:
                                                  LottieLoadingWidget.medium())
                                          : _display1(list.finalTransactionData)
                                  : list.check_TransactionDatahuobi
                                      ? Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1A2234),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                spreadRadius: 1,
                                                blurRadius: 10,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Image.asset(
                                              "assets/img/logo.png"),
                                        )
                                      : list.finalTransactionDataHuobi.isEmpty
                                          ? const Center(
                                              child:
                                                  LottieLoadingWidget.medium())
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
                          ),
                        );
                      }),
              ),
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

          /// Enhanced Trading Bots section header
          Container(
            margin: const EdgeInsets.only(top: 20, bottom: 15),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  binanceYellow.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: binanceYellow.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        binanceYellow,
                        binanceYellow.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: binanceYellow.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Trading Bots",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: binanceYellow.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "4 Tools",
                    style: TextStyle(
                      color: binanceYellow,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Enhanced Future and Spot trading bots container
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E2329),
                  Color(0xFF181C22),
                  Color(0xFF161A1E),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFF0B90B).withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF0B90B).withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  spreadRadius: 0,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
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
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 100),
                    child: _buildGridOptionItem(
                      icon: "assets/img/stock.png",
                      label: "Arbitrade Trading",
                      onTap: () => AnimatedNavigator.pushFadeScale(
                          context, const ArbiTradeSection()),
                    ),
                  ),

                  /// Spot trading
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 200),
                    child: _buildGridOptionItem(
                      icon: "assets/img/spot_trading.png",
                      label: "Spot Trading",
                      onTap: () => AnimatedNavigator.pushFadeScale(
                          context, const SpotTradingService()),
                    ),
                  ),

                  /// future trading
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 300),
                    child: _buildGridOptionItem(
                      icon: "assets/img/future_trading.png",
                      label: "Future Trading",
                      onTap: () => AnimatedNavigator.pushFadeScale(
                          context, const FutureTradingSection()),
                    ),
                  ),

                  ///  Api Binding
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 400),
                    child: _buildGridOptionItem(
                      icon: "assets/img/api.png",
                      label: "API Binding",
                      onTap: () => AnimatedNavigator.pushFromBottom(
                          context, const ApiBinding()),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Enhanced Reports section header
          Container(
            margin: const EdgeInsets.only(top: 20, bottom: 15),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFF4A90E2).withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4A90E2).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF4A90E2),
                        Color(0xFF357ABD),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A90E2).withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Reports",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Analytics",
                    style: TextStyle(
                      color: Color(0xFF4A90E2),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Enhanced Trading Tools card with improved styling
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E2329),
                  Color(0xFF181C22),
                  Color(0xFF161A1E),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF4A90E2).withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  spreadRadius: 0,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
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
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 600),
                    child: _buildGridOptionItem(
                      icon: "assets/img/cycle.png",
                      label: "Trading Revenue",
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Revenue())),
                    ),
                  ),

                  /// Reward Details
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 700),
                    child: _buildGridOptionItem(
                      icon: "assets/img/user.png",
                      label: "Bot Trading Bonus",
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AllIncome(initialTabIndex: 2))),
                    ),
                  ),

                  /// Transactions
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 800),
                    child: _buildGridOptionItem(
                      icon: "assets/img/transaction.png",
                      label: "Transactions",
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PaymentSection())),
                    ),
                  ),

                  /// My Team
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 900),
                    child: _buildGridOptionItem(
                      icon: "assets/img/team.png",
                      label: "My Team",
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Team(image: null))),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Enhanced Fund Management section header
          Container(
            margin: const EdgeInsets.only(top: 20, bottom: 15),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFF00C853).withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00C853).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF00C853),
                        Color(0xFF00A843),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C853).withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Fund Management",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Manage",
                    style: TextStyle(
                      color: Color(0xFF00C853),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Enhanced Fund Management card with improved styling
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E2329),
                  Color(0xFF181C22),
                  Color(0xFF161A1E),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00C853).withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00C853).withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  spreadRadius: 0,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
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
                        builder: (context) => const Withdrawal(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Enhanced More Services section header
          Container(
            margin: const EdgeInsets.only(top: 20, bottom: 15),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFFE91E63).withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE91E63).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFE91E63),
                        Color(0xFFC2185B),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE91E63).withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "More Services",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Support",
                    style: TextStyle(
                      color: Color(0xFFE91E63),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Enhanced More Services card with improved styling
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E2329),
                  Color(0xFF181C22),
                  Color(0xFF161A1E),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE91E63).withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE91E63).withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  spreadRadius: 0,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Grid option item with better animations and styling
  Widget _buildGridOptionItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    // Theme colors
    const Color yellow = Color(0xFFF0B90B);
    const Color cardBorder = Color(0xFF2A3A5A);

    return RippleAnimation(
      rippleColor: yellow,
      onTap: onTap,
      child: AnimatedContainer(
        duration: TradingAnimations.normalAnimation,
        curve: TradingAnimations.defaultCurve,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E2329),
                Color(0xFF181C22),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cardBorder.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: yellow.withOpacity(0.05),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated background glow effect
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.0,
                      colors: [
                        yellow.withOpacity(0.02),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Decorative corner accent with glow
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    color: yellow.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: yellow.withOpacity(0.4),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
              // Main content with enhanced styling
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Enhanced icon container with multiple layers
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            yellow.withOpacity(0.2),
                            yellow.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: yellow.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: yellow.withOpacity(0.15),
                            spreadRadius: 0,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: PulseAnimation(
                          duration: const Duration(seconds: 2),
                          minScale: 0.95,
                          maxScale: 1.05,
                          child: Image.asset(
                            icon,
                            color: yellow,
                            height: 28,
                            width: 28,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.apps,
                                color: yellow,
                                size: 28,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Enhanced text with better typography
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.2,
                        height: 1.2,
                      ),
                      maxLines: 2,
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

  Widget _homeHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Row(
        children: [
          const Text(
            'Home',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Notifications',
            onPressed: _openNotifications,
            icon: const Icon(Icons.notifications_none, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<void> _openNotifications() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121824),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _NotificationsSheet(fetch: _fetchNotifications),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchNotifications() async {
    try {
      final res = await http.get(Uri.parse(userNotificationsUrl));
      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          final List list = data['data'] is List ? data['data'] : [];
          return list
              .map((e) => {
                    'title': e['title']?.toString() ?? 'Notification',
                    'message': e['message']?.toString() ?? '',
                    'created_at': e['created_at']?.toString() ?? '',
                  })
              .cast<Map<String, dynamic>>()
              .toList();
        }
      }
    } catch (_) {}
    return [];
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

class _NotificationsSheet extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function() fetch;
  const _NotificationsSheet({Key? key, required this.fetch}) : super(key: key);

  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text('Notifications',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF4A90E2))),
                  );
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No notifications',
                        style: TextStyle(color: Colors.white70)),
                  );
                }
                return Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: Color(0xFF2A3A5A)),
                    itemBuilder: (context, i) {
                      final n = items[i];
                      final createdAt = n['created_at'];
                      String when = createdAt;
                      try {
                        if (createdAt != null &&
                            createdAt.toString().isNotEmpty) {
                          final dt = DateTime.tryParse(createdAt);
                          if (dt != null) {
                            when = DateFormat('yMMMd • HH:mm').format(dt);
                          }
                        }
                      } catch (_) {}
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        leading: const Icon(Icons.notifications,
                            color: Color(0xFF4A90E2)),
                        title: Text(n['title'] ?? 'Notification',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((n['message'] ?? '').toString().isNotEmpty)
                              Text(n['message'],
                                  style:
                                      const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text(when,
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
