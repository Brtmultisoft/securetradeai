import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:securetradeai/src/Homepage/SubbinMode.dart';
import 'package:securetradeai/src/quantitative/copyTrading.dart';
import 'package:securetradeai/src/quantitative/autoTrading.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/tabscreen/tabscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/repoModel.dart';
import '../../method/homepageProvider.dart';
import 'package:securetradeai/data/strings.dart';

class Quantitative extends StatefulWidget {
  const Quantitative({Key? key, this.reffralno}) : super(key: key);
  final reffralno;
  @override
  _QuantitativeState createState() => _QuantitativeState();
}

class _QuantitativeState extends State<Quantitative> {
  int value = 0;
  Timer? timer;
  var assets = [];
  bool visiblile = false;
  String searchWords = "";
  String dropdownvalue = 'Binance';
  var searchText = TextEditingController();

  // List of items in our dropdown menu
  var items = [
    'Binance',
    'Huobi',
    'OKX',
  ];
  _getquantitativedata_with_provider() {
    if (exchanger == "Binance" || exchanger == "null") {
      if (value == 0) {
        allmethod();
      } else if (value == 1) {
        final cycle = Provider.of<Repo>(context, listen: false);
        var b = cycle.getquantitumData("", 1);
        Future.delayed(const Duration(minutes: 1, seconds: 30),
            () => cycle.getpriceData());
        Future.delayed(const Duration(minutes: 1, seconds: 30),
            () => cycle.gettxnAllrecord());
        b.then((value) {
          if (value == true) {
            showtoast("No Internet", context);
          }
        });
      } else if (value == 2) {
        final cycle = Provider.of<Repo>(context, listen: false);
        var b = cycle.getquantitumData("", 1);
        Future.delayed(const Duration(minutes: 1, seconds: 30),
            () => cycle.getpriceData());
        Future.delayed(const Duration(minutes: 1, seconds: 30),
            () => cycle.gettxnAllrecord());
        b.then((value) {
          if (value == true) {
            showtoast("No Internet", context);
          }
        });
      } else {
        final cycle = Provider.of<Repo>(context, listen: false);
        var b = cycle.getquantitumData("", 1);
        Future.delayed(const Duration(minutes: 1, seconds: 30),
            () => cycle.getpriceData());
        Future.delayed(const Duration(minutes: 1, seconds: 30),
            () => cycle.gettxnAllrecord());
        b.then((value) {
          if (value == true) {
            showtoast("No Internet", context);
          }
        });
      }
    } else {
      final _getQuantitive = Provider.of<Repo>(context, listen: false);
      _getQuantitive.getHuobiOfficealAPIdata(searchWords);
      // using circle
      final bannerdata = Provider.of<HomePageProvider>(context, listen: false);
      bannerdata.huobiassets(0);
    }
  }

  allmethod() {
    final _getQuantitive = Provider.of<Repo>(context, listen: false);
    var a = _getQuantitive.getquantitumData(searchWords, 0);
    a.then((value) {
      if (value == true) {
        showtoast("No Internet", context);
      }
    });
  }

  searchbytab(String val) {
        setState(() {
          searchWords = val;
        });
  }

  @override
  void initState() {
    super.initState();
    final _getQuantitive = Provider.of<Repo>(context, listen: false);
    _getQuantitive.getpriceData();
    _getQuantitive.gettxnAllrecord();
    _getExchangeValue();
    timer = Timer.periodic(const Duration(seconds: 2),
        (Timer t) => _getquantitativedata_with_provider());
  }

  _getExchangeValue() {
    setState(() {
      dropdownvalue = exchanger == "null" ? "Binance" : exchanger;
    });
  }

  _updateExchangerValue(fexchangevalue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('exchanger', fexchangevalue);
    setState(() {
      exchanger = fexchangevalue;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
          title: Row(
        children: [
          Text(exchanger == "null" ? "Binance" : exchanger),
          const SizedBox(
            width: 20,
          ),
          Container(
            child: DropdownButton(
              dropdownColor: const Color(0xFF171d28),
              value: dropdownvalue,
              underline: const SizedBox(),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              items: items.map((String items) {
                return DropdownMenuItem(
                    value: items,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        items,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ));
              }).toList(),
              onChanged: (String? newValue) {
                _updateExchangerValue(newValue);
                setState(() {
                  final bal = Provider.of<Repo>(context, listen: false);
                  bal.updateBalance(newValue.toString());
                  dropdownvalue = newValue.toString();
                });
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Tabscreen(reffral: widget.reffralno)));
              },
            ),
          )
        ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Self Trading'),
              // Tab(text: 'Cycle Trading'),
              // Tab(text: 'One Shot'),
              // Tab(text: 'Stop Margin Call'),
              Tab(text: 'Auto Trading'),
              Tab(text: 'Copy Trading'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Consumer<Repo>(builder: (context, repo, child) {
              return (exchanger == "null" || exchanger == "Binance")
                  ? repo.final_Quantitative_data.isEmpty
                      ? Center(child: CircularProgressIndicator(color: securetradeaicolor))
          : Column(
              children: [
                            // Header Section
                            // Container(
                            //   padding: EdgeInsets.all(16),
                            //   decoration: BoxDecoration(
                            //     color: Color(0xFF121824),
                            //     border: Border(
                            //       bottom: BorderSide(
                            //         color: Color(0xFF2A3A5A),
                            //         width: 1,
                            //       ),
                            //     ),
                            //   ),
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       Row(
                            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //         children: [
                            //           Text(
                            //             'Self Trading',
                            //             style: TextStyle(
                            //               color: Colors.white,
                            //               fontSize: 24,
                            //               fontWeight: FontWeight.bold,
                            //             ),
                            //           ),
                            //           Row(
                            //             children: [
                            //               Text(
                            //                 '24h Change',
                            //                 style: TextStyle(
                            //                   color: Colors.white70,
                            //                   fontSize: 14,
                            //                 ),
                            //               ),
                            //               SizedBox(width: 5),
                            //               Icon(Icons.arrow_upward, color: Color(0xFF00C853), size: 16),
                            //             ],
                            //           ),
                            //         ],
                            //       ),
                            //       SizedBox(height: 8),
                            //       Text(
                            //         'Trade cryptocurrencies with advanced tools and real-time data',
                            //         style: TextStyle(
                            //           color: Colors.grey[400],
                            //           fontSize: 14,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),

                            // Market Overview
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Color(0xFF121824),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFF2A3A5A),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Market Overview',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _buildMarketOverviewCard(
                                          'Total Market Cap',
                                          '\$1.2T',
                                          '+2.5%',
                                          Icons.show_chart,
                                          const Color(0xFF4A90E2),
                                        ),
                                        const SizedBox(width: 12),
                                        _buildMarketOverviewCard(
                                          '24h Volume',
                                          '\$48.5B',
                                          '+1.8%',
                                          Icons.bar_chart,
                                          const Color(0xFFFF9800),
                                        ),
                                        const SizedBox(width: 12),
                                        _buildMarketOverviewCard(
                                          'BTC Dominance',
                                          '42.5%',
                                          '-0.3%',
                                          Icons.currency_bitcoin,
                                          const Color(0xFFF7931A),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Search and Filter Section
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Color(0xFF121824),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFF2A3A5A),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                  child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1A2234),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFF2A3A5A),
                                          width: 1,
                                        ),
                                      ),
                      child: TextField(
                          controller: searchText,
                          onChanged: (value) {
                                          searchbytab(value);
                          },
                                        style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                                          hintText: 'Search coin...',
                                          hintStyle: TextStyle(color: Colors.white70),
                                          prefixIcon: Icon(Icons.search, color: Color(0xFF4A90E2)),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                        Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A2234),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFF2A3A5A),
                                        width: 1,
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.filter_list, color: Color(0xFF4A90E2)),
                                      onPressed: () {
                                        // Add filter functionality
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Coins List
                        Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                itemCount: repo.final_Quantitative_data.length,
                                itemBuilder: (context, index) {
                                  final open = double.tryParse(repo.final_Quantitative_data[index]['open']?.toString() ?? '0') ?? 0;
                                  final close = double.tryParse(repo.final_Quantitative_data[index]['close']?.toString() ?? '0') ?? 0;
                                  final volume = double.tryParse(repo.final_Quantitative_data[index]['volume']?.toString() ?? '0') ?? 0;
                                  final quoteVolume = double.tryParse(repo.final_Quantitative_data[index]['quoteVolume']?.toString() ?? '0') ?? 0;

                                  double finalincrse = 0;
                                  if (open != 0) {
                                    finalincrse = ((close - open) / open) * 100;
                                  }

                                  var b = repo.final_Quantitative_data[index]['symbol']?.toString() ?? '';
                                  var finalsymble = b.replaceAll("usdt", "").replaceAll("USDT", "");

                                  bool isVisible = true;
                                  if (searchWords.isNotEmpty) {
                                    isVisible = finalsymble.toLowerCase().contains(searchWords.toLowerCase());
                                  }

                                              return Visibility(
                                    visible: isVisible,
                                                child: Visibility(
                                      visible: repo.final_Quantitative_data[index]['status'] != "0" ? false : true,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1A2234),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFF2A3A5A),
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 10,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                  builder: (context) => SubbinMode(
                                                                        id: "",
                                                    coinurl: repo.final_Quantitative_data[index]['coinurl'],
                                                    reffralnno: widget.reffralno,
                                                    coinimg: repo.final_Quantitative_data[index]['asset_img'],
                                                    compaircoinname: repo.final_Quantitative_data[index]['symbol'],
                                                    finalCoinName: finalsymble,
                                                    currentPrice: close.toStringAsFixed(5),
                                                    priceChange: finalincrse.toStringAsFixed(3),
                                                    openPrice: open.toStringAsFixed(5),
                                                    highPrice: repo.final_Quantitative_data[index]['high']?.toString() ?? '0.00000',
                                                    lowPrice: repo.final_Quantitative_data[index]['low']?.toString() ?? '0.00000',
                                                    volume: repo.final_Quantitative_data[index]['volume']?.toString() ?? '0.00000',
                                                    quoteVolume: repo.final_Quantitative_data[index]['quoteVolume']?.toString() ?? '0.00000',
                                                  ),
                                                ),
                                              );
                                            },
                                            borderRadius: BorderRadius.circular(12),
                                                    child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                      child: Column(
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                      /// Coin Icon and Name
                                                      Expanded(
                                                        flex: 2,
                                                        child: Row(
                                                                          children: [
                                                            Container(
                                                              padding: const EdgeInsets.all(6),
                                                              decoration: BoxDecoration(
                                                                color: const Color(0xFF121824),
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              child: Image.network(
                                                                repo.final_Quantitative_data[index]['asset_img'] ?? "https://securetradeai.com/assets/securetradeai/assets/images/logo.png",
                                                                width: 24,
                                                                height: 24,
                                                                fit: BoxFit.cover,
                                                                errorBuilder: (context, error, stackTrace) {
                                                                  return const Icon(Icons.currency_bitcoin, color: Colors.white70, size: 16);
                                                                },
                                                              ),
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                Text(
                                                                  finalsymble.toUpperCase(),
                                                                  style: const TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                                const Text(
                                                                  "USDT",
                                                                  style: TextStyle(
                                                                    color: Colors.white70,
                                                                    fontSize: 10,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      /// Price and Change
                                                      Expanded(
                                                        flex: 2,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              '\$${close.toStringAsFixed(5)}',
                                                              style: const TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                                    ),
                                                            SizedBox(height: 1,),
                                                                    Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                              decoration: BoxDecoration(
                                                                color: finalincrse >= 0
                                                                  ? const Color(0xFF00C853).withOpacity(0.1)
                                                                  : const Color(0xFFE53935).withOpacity(0.1),
                                                                borderRadius: BorderRadius.circular(4),
                                                              ),
                                                                      child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                  Icon(
                                                                    finalincrse >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                                                                    color: finalincrse >= 0 ? const Color(0xFF00C853) : const Color(0xFFE53935),
                                                                    size: 10,
                                                                  ),
                                                                  const SizedBox(width: 2),
                                                                  Text(
                                                                    '${finalincrse.toStringAsFixed(3)}%',
                                                                    style: TextStyle(
                                                                      color: finalincrse >= 0 ? const Color(0xFF00C853) : const Color(0xFFE53935),
                                                                      fontSize: 10,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(width: 10,),
                                                      /// Trade Button
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            gradient: const LinearGradient(
                                                              colors: [
                                                                Color(0xFF4A90E2),
                                                                Color(0xFF5C9CE6),
                                                              ],
                                                              begin: Alignment.topLeft,
                                                              end: Alignment.bottomRight,
                                                            ),
                                                            borderRadius: BorderRadius.circular(6),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: const Color(0xFF4A90E2).withOpacity(0.3),
                                                                blurRadius: 5,
                                                                offset: const Offset(0, 2),
                                                              ),
                                                            ],
                                                          ),
                                                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                                          child: const Center(
                                                            child: Text(
                                                              'Trade',
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  const Divider(color: Color(0xFF2A3A5A), height: 1),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      _buildStatItem(
                                                        'Current Price',
                                                        '\$${close.toStringAsFixed(2)}',
                                                      ),
                                                      _buildStatItem(
                                                        'Open Price',
                                                        '\$${open.toStringAsFixed(2)}',
                                                      ),
                                                      _buildStatItem(
                                                        '24h Change',
                                                        '${finalincrse.toStringAsFixed(2)}%',
                                                        isPositive: finalincrse >= 0,
                                                      ),
                                                    ],
                                                  ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                  : repo.finalhuobiData.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : Huobi(repo.finalhuobiData);
            }),
            // Self Trading tab is already included above
            const AutoTrading(),
            const CopyTrading(),

          ],
        ),
            ),
    );
  }

  Widget Huobi(var data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (cotext, index) {
          // get increse with null safety
          final open = double.tryParse(data[index]['open']?.toString() ?? '0') ?? 0;
          final close = double.tryParse(data[index]['close']?.toString() ?? '0') ?? 0;
          double finalincrse = 0;

          if (open != 0) {
            finalincrse = ((close - open) / open) * 100;
          }

          var b = data[index]['symbol']?.toString() ?? '';
          var finalsymble = b.replaceAll("usdt", "").replaceAll("USDT", "");

          // Fix search functionality for Huobi section
          bool isVisible = true;
          if (searchWords.isNotEmpty) {
            isVisible = finalsymble.toLowerCase().contains(searchWords.toLowerCase());
          }

          return Visibility(
            visible: isVisible,
            child: Visibility(
              visible: data[index]['status'] != "0" ? false : true,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SubbinMode(
                                id: "",
                                coinurl: data[index]['coinurl'],
                                reffralnno: widget.reffralno,
                                coinimg: data[index]['asset_img'],
                                compaircoinname: data[index]['symbol'],
                                finalCoinName: finalsymble,
                              )));
                },
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 2),
                      Container(
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.2),
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                            radius: 15.0,
                                            backgroundImage: data[index]
                                                        ['asset_img'] ==
                                                    null
                                                ? const NetworkImage(
                                                    "https://securetradeai.com/assets/securetradeai/assets/images/logo.png")
                                                : NetworkImage(
                                                    data[index]['asset_img'])),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                                child: Text(
                                                    finalsymble.toUpperCase(),
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
                                                color: Colors.white70)),
                                        width: 60,
                                        height: 25,
                                        child: const Center(
                                          child: Text(
                                            "Cycle",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        )),
                                    Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.2),
                                          border:
                                              Border.all(color: Colors.white70),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(6)),
                                        ),
                                        width: 60,
                                        height: 25,
                                        child: const Center(
                                          child: Text(
                                            "0.00 %",
                                            style: TextStyle(
                                                color: Colors.white70),
                                          ),
                                        )),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.grey,
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
                                          const TextSpan(
                                              text: '  0.0000',
                                              style: TextStyle(
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
                                                  data[index]['close']
                                                      .toString(),
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
                                              text: finalincrse
                                                  .toStringAsFixed(4),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: finalincrse.isNegative
                                                      ? Colors.red
                                                      : Colors.green,
                                                  fontSize: 14,
                                                  fontFamily: fontFamily)),
                                        ],
                                      ),
                                    )
                                  ]),
                                )
                              ],
                            ),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildMarketOverviewCard(String title, String value, String change, IconData icon, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2234),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2A3A5A),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: change.startsWith('+')
                ? const Color(0xFF00C853).withOpacity(0.1)
                : const Color(0xFFE53935).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              change,
              style: TextStyle(
                color: change.startsWith('+') ? const Color(0xFF00C853) : const Color(0xFFE53935),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {bool? isPositive}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: isPositive != null
              ? (isPositive ? const Color(0xFF00C853) : const Color(0xFFE53935))
              : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
