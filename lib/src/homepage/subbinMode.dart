import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rapidtradeai/data/api.dart';
import 'package:rapidtradeai/data/strings.dart';
import 'package:rapidtradeai/method/tradeSettingSubbinprovider.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';
import 'package:rapidtradeai/src/Service/background_service.dart'
    as background;
import 'package:rapidtradeai/src/homepage/Maintradesetting.dart';
import 'package:rapidtradeai/src/widget/lottie_loading_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../method/homepageProvider.dart';
import '../../model/repoModel.dart';
import '../widget/trading_chart.dart';
import 'tradeSettingSubbin.dart';

class SubbinMode extends StatefulWidget {
  final compaircoinname;
  final coinimg;
  final finalCoinName;
  final reffralnno;
  final coinurl;
  final checkNavigate;
  final String id;
  final String? currentPrice;
  final String? priceChange;
  final String? openPrice;
  final String? highPrice;
  final String? lowPrice;
  final String? volume;
  final String? quoteVolume;
  const SubbinMode(
      {Key? key,
      this.compaircoinname,
      this.coinimg,
      this.finalCoinName,
      this.reffralnno,
      this.coinurl,
      this.checkNavigate,
      required this.id,
      this.currentPrice,
      this.priceChange,
      this.openPrice,
      this.highPrice,
      this.lowPrice,
      this.volume,
      this.quoteVolume})
      : super(key: key);
  @override
  State<SubbinMode> createState() => _SubbinModeState();
}

class _SubbinModeState extends State<SubbinMode> {
  var quantutumdata = [];
  String currentprice = '0.0000';
  Timer? timer;
  String positionAmount = "0.0000";
  String avgprice = "0.0000";
  int numberofmarginCall = 0;
  double finalnumberofmargincall = 0.0;
  String positionQuantity = "0.0";
  bool isAPIcalled = false;
  bool checkCMTP = false;
  bool checkTPTP = false;
  double lastAVGPrice = 0.00;
  double finalCMTP = 0.0;
  double finalTPTP = 0.0;
  double returnrate = 0.0;
  bool checkavgPrice = false;
  int cycle = 0;
  var buttonstatus;
  int start_or_stop_margin = 0;
  bool isInitialized = false;
  bool _backgroundServiceInitialized = false;
  String orderType =
      "loading"; // Track order type from API response, start with "loading" to hide buttons initially

  // Add missing variables
  String high24h = '0.0000';
  String low24h = '0.0000';
  String volume24h = '0.0000';
  String positionquantity = '0.0000';
  String floatingpl = '0.0000';
  String triggerprice = '0.0000';

  Future _getquantitumData() async {
    if (exchanger == "null" || exchanger == "Binance") {
      if (widget.checkNavigate == "Home") {
        final bannerdata =
            Provider.of<HomePageProvider>(context, listen: false);
        _commonMethod(bannerdata.homePageTxnRecords);
      } else {
        final _getQuantitive = Provider.of<Repo>(context, listen: false);
        _commonMethod(_getQuantitive.quantutumdata);
      }
    } else {
      if (widget.checkNavigate == "Home") {
        final bannerdata =
            Provider.of<HomePageProvider>(context, listen: false);
        _commonMethod(bannerdata.huobidata);
      } else {
        final Huobi = Provider.of<Repo>(context, listen: false);
        _commonMethod(Huobi.huobiAssets);
      }
    }
  }

  _commonMethod(var pricelist) {
    if (exchanger == "null" || exchanger == "Binance") {
      for (var p in pricelist) {
        if (p['symbol'] == widget.compaircoinname) {
          setState(() {
            currentprice = double.parse(p['lastPrice']).toStringAsFixed(18);
          });
          break;
        }
      }
    } else {
      if (widget.checkNavigate != "Home") {
        for (var p in pricelist) {
          if (p['symbol'] == widget.compaircoinname) {
            double a = p['close'];
            setState(() {
              currentprice = a.toStringAsFixed(18);
            });
            break;
          }
        }
      } else {
        for (var p in pricelist) {
          if (p['symbol'] == widget.compaircoinname.toString().toLowerCase()) {
            double a = p['close'];
            setState(() {
              currentprice = a.toStringAsFixed(18);
            });
            break;
          }
        }
      }
    }

    // Calculate Floating P/L
    double currentPrice = double.parse(currentprice);
    double posQty = double.parse(positionQuantity);
    double avgPrice = double.parse(avgprice);

    if (posQty > 0 && avgPrice > 0) {
      // Current position value
      double currentValue = posQty * currentPrice;
      // Initial position value
      double initialValue = posQty * avgPrice;
      // Calculate P/L
      double pnl = currentValue - initialValue;

      setState(() {
        returnrate = pnl;
        checkavgPrice = pnl < 0;
      });
    } else {
      setState(() {
        returnrate = 0.0;
        checkavgPrice = false;
      });
    }

    // Calculate Trigger Prices
    if (lastAVGPrice > 0 && finalnumberofmargincall > 0) {
      // Buy Trigger Price (Margin Call)
      double marginCallDrop = lastAVGPrice * (finalnumberofmargincall / 100);
      setState(() {
        finalCMTP = lastAVGPrice - marginCallDrop;
        triggerprice = finalCMTP.toStringAsFixed(4);
      });
    }

    final tradesettingfinal =
        Provider.of<TradeSettingSubbinProvider>(context, listen: false);
    if (avgPrice > 0 && tradesettingfinal.takeprofit.isNotEmpty) {
      // Sell Trigger Price (Take Profit)
      double takeProfitAmount =
          avgPrice * (double.parse(tradesettingfinal.takeprofit) / 100);
      setState(() {
        finalTPTP = avgPrice + takeProfitAmount;
      });
    }

    // Only check auto actions if bot is active and initialized
    if (buttonstatus == 1 &&
        isInitialized &&
        double.parse(positionAmount) > 0 &&
        avgPrice > 0 &&
        lastAVGPrice > 0) {
      _saveBotState();

      if (currentPrice <= finalCMTP) {
        _checkAutoBuy();
      }
      _checkAutoSell();
    }
  }

  _checkAutoBuy() async {
    final tradesettingfinal =
        Provider.of<TradeSettingSubbinProvider>(context, listen: false);
    double currentPrice = double.parse(currentprice);

    print("Checking Auto Buy:");
    print("Bot Status: $buttonstatus");
    print("Margin Call Status: $start_or_stop_margin");
    print("Current Price: $currentPrice");
    print("Last Average Price: $lastAVGPrice");
    print("Margin Call Trigger Price: $finalCMTP");
    print("Number of Margin Calls: $numberofmarginCall");
    print("Margin Call Limit: ${tradesettingfinal.marginCallLimit.text}");
    print("Margin Call Drop %: $finalnumberofmargincall");

    // First check if price is below margin call trigger price
    if (currentPrice > finalCMTP) {
      print("Price not below margin call trigger price, skipping auto-buy");
      return;
    }

    // Validate margin call drop percentage
    if (finalnumberofmargincall <= 0) {
      print(
          "Invalid margin call drop percentage: $finalnumberofmargincall%, skipping auto-buy");
      return;
    }

    // Only proceed if we haven't reached margin call limit
    if (numberofmarginCall <
        int.parse(tradesettingfinal.marginCallLimit.text)) {
      // Calculate price drop percentage from last average price
      double priceDropPercent =
          ((lastAVGPrice - currentPrice) / lastAVGPrice) * 100;
      print("Price Drop Percentage: $priceDropPercent%");

      // Get margin call drop percentage for current margin call number
      if (priceDropPercent >= finalnumberofmargincall) {
        print(
            "Executing margin call buy: Price drop $priceDropPercent% >= ${finalnumberofmargincall}%");

        // Calculate buy amount based on martin config
        double buyAmount = double.parse(tradesettingfinal.firstbuy.text);
        if (tradesettingfinal.switchValue) {
          // If position doubling is enabled
          buyAmount = double.parse(positionAmount) * 2;
        }
        print("Buy Amount: $buyAmount USDT");

        // Execute the buy
        await _BuyManuall(buyAmount.toString());
      } else {
        print("Price drop not sufficient for margin call");
      }
    } else {
      print("Margin call limit reached");
    }
  }

  _checkAutoSell() async {
    final tradesettingfinal =
        Provider.of<TradeSettingSubbinProvider>(context, listen: false);
    double currentPrice = double.parse(currentprice);

    // Calculate current profit percentage
    double currentProfitPercentage =
        ((currentPrice - double.parse(avgprice)) / double.parse(avgprice)) *
            100;

    // Only proceed with sell checks if we're in profit
    if (currentProfitPercentage > 0) {
      // Get the buy in callback percentage
      double buyInCallback =
          double.parse(tradesettingfinal.buy_in_callbakc.text);

      // 1. Take Profit Trigger Price
      if (currentPrice >= finalTPTP) {
        if (currentProfitPercentage >=
            double.parse(tradesettingfinal.earingcallback)) {
          print(
              "Selling at Take Profit Trigger Price: $currentPrice (Profit: $currentProfitPercentage%)");
          _checkSell(context);
          return;
        }
      }

      // 2. Take Profit Ratio
      if (currentProfitPercentage >=
          double.parse(tradesettingfinal.takeprofit)) {
        if (currentProfitPercentage >=
            double.parse(tradesettingfinal.earingcallback)) {
          print("Selling at Take Profit Ratio: $currentProfitPercentage%");
          _checkSell(context);
          return;
        }
      }

      // 3. Buy In Callback (Trailing Stop)
      double peakProfit = currentProfitPercentage;
      double dropFromPeak = peakProfit - currentProfitPercentage;

      if (dropFromPeak >= buyInCallback) {
        print(
            "Selling at Buy In Callback: Drop from peak $dropFromPeak% >= $buyInCallback%");
        _checkSell(context);
        return;
      }
    }
  }

  Future _getquantitative_txn_record() async {
    if (!mounted) return;

    setState(() {
      isAPIcalled = true;
      isInitialized = false; // Reset initialization flag
    });

    try {
      final res = await http
          .post(Uri.parse(quantitative_txn_recordsubbin),
              body: json.encode({
                "user_id": commonuserId,
                "exchange_type": exchanger,
                "assets": widget.compaircoinname
              }))
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Request timed out');
        },
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("API Response: $data"); // Debug log

        if (data['status'] == "success") {
          var finaldata = data['data'] as List;
          bool found = false;

          for (var e in finaldata) {
            if (e['id'] == widget.id) {
              found = true;
              print(
                  "Bot Status Before Update: buttonstatus=$buttonstatus, start_or_stop_margin=$start_or_stop_margin"); // Debug log

              if (!mounted) return;
              setState(() {
                positionAmount = e['pos_amt'] == null
                    ? "0.000"
                    : double.parse(e['pos_amt']).toString();
                var localavg = e['avg_price'] == null
                    ? "0.0000"
                    : e['avg_price'].toString().replaceAll(",", "");
                avgprice = double.parse(localavg).toString();
                numberofmarginCall = e['no_margincall'] == null
                    ? 0
                    : int.parse(e['no_margincall']);
                print(
                    "Number of Margin Calls from API: $numberofmarginCall"); // Debug log
                positionQuantity = e['pos_qty'] == null
                    ? "0.000"
                    : double.parse(e['pos_qty']).toString();
                buttonstatus =
                    e['status'] == null ? null : int.parse(e['status']);
                cycle = int.parse(e['cycle']);
                start_or_stop_margin = e['stock_margin'] == null
                    ? 0
                    : int.parse(e['stock_margin']);
                lastAVGPrice = e['last_avgprice'] == null
                    ? 0.00
                    : double.parse(e['last_avgprice']);
                checkCMTP = e['margin_calldrop'] == "0" ? false : true;
                checkTPTP = e['wp_rasio'] == "0" ? false : true;
                orderType =
                    e['order_type'] ?? ""; // Capture order type from API
                isAPIcalled = false;
              });

              // Calculate margin call trigger price
              _sellorbyCalculation();

              // Only set initialized after we've loaded all data and verified it's valid
              if (double.parse(positionAmount) > 0 &&
                  double.parse(avgprice) > 0 &&
                  lastAVGPrice > 0 &&
                  finalCMTP > 0) {
                // Add check for finalCMTP
                setState(() {
                  isInitialized = true;
                });
                print("Bot initialized successfully with valid data");
                print("Initial Margin Call Trigger Price: $finalCMTP");
              } else {
                print("Bot data invalid, not initializing");
                print("finalCMTP: $finalCMTP");
              }

              print(
                  "Bot Status After Update: buttonstatus=$buttonstatus, start_or_stop_margin=$start_or_stop_margin"); // Debug log
              break;
            }
          }

          if (!found) {
            if (!mounted) return;
            setState(() {
              isAPIcalled = false;
            });
            showtoast("No data found for this bot", context);
          }
        } else {
          if (!mounted) return;
          setState(() {
            isAPIcalled = false;
          });
          showtoast(data['message'] ?? "Something went wrong", context);
        }
      } else {
        if (!mounted) return;
        setState(() {
          isAPIcalled = false;
        });
        showtoast("Server Error", context);
      }
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        isAPIcalled = false;
      });
      print("Request timed out");
      showtoast("Request timed out. Please try again.", context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isAPIcalled = false;
      });
      print("Error in _getquantitative_txn_record: $e");
      showtoast("Error loading data", context);
    }
  }

  _getdata() {
    final tradesettingfinal =
        Provider.of<TradeSettingSubbinProvider>(context, listen: false);
    tradesettingfinal.getTradeSetting(widget.compaircoinname);
  }

  _getTradeSetting() async {
    if (!mounted) return;

    try {
      final res = await http.post(Uri.parse(tradesettingsubbin),
          body: json.encode({
            "user_id": commonuserId,
            "exchange_type": exchanger,
            "assets_type": widget.compaircoinname
          }));

      if (!mounted) return;

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("Trade Settings Response: $data"); // Debug log
        if (data['status'] == "success") {
          print("Current Margin Call Number: $numberofmarginCall"); // Debug log

          // Get the next margin call number (current + 1)
          int nextMarginCall = numberofmarginCall + 1;
          String marginDropKey = 'margin_drop_$nextMarginCall';

          print("Looking for margin drop setting: $marginDropKey"); // Debug log

          if (data['data'].containsKey(marginDropKey)) {
            double newMarginDrop = double.parse(data['data'][marginDropKey]);
            print("Found margin drop setting: $newMarginDrop"); // Debug log

            if (!mounted) return;
            setState(() {
              finalnumberofmargincall = newMarginDrop;
            });
          } else {
            print(
                "No margin drop setting found for call number: $nextMarginCall"); // Debug log
            // If no setting found, use the last available setting
            for (int i = nextMarginCall - 1; i >= 1; i--) {
              String lastKey = 'margin_drop_$i';
              if (data['data'].containsKey(lastKey)) {
                double lastMarginDrop = double.parse(data['data'][lastKey]);
                print(
                    "Using last available margin drop setting: $lastMarginDrop"); // Debug log
                if (!mounted) return;
                setState(() {
                  finalnumberofmargincall = lastMarginDrop;
                });
                break;
              }
            }
          }
        } else {
          if (!mounted) return;
          showtoast(data['message'], context);
        }
      } else {
        print("Server Error");
      }
    } catch (e) {
      print("Error in _getTradeSetting: $e");
    }
  }

  _sellorbyCalculation() {
    final tradesettingfinal =
        Provider.of<TradeSettingSubbinProvider>(context, listen: false);
    double CMTP = lastAVGPrice * finalnumberofmargincall / 100;
    print(CMTP);
    setState(() => finalCMTP = lastAVGPrice - CMTP);
    double TPTP = double.parse(avgprice.toString()) *
        double.parse(tradesettingfinal.takeprofit) /
        100;
    setState(() => finalTPTP = double.parse(avgprice) + TPTP);
  }

  _fatchData() async {
    await _getdata();
    await _getquantitumData();
    await _getquantitative_txn_record();
    await _getTradeSetting();
    await _sellorbyCalculation();
  }

  @override
  void initState() {
    super.initState();

    // Initialize currentprice from widget parameter if provided
    if (widget.currentPrice != null && widget.currentPrice!.isNotEmpty) {
      currentprice = widget.currentPrice!;
    }

    // Initialize returnrate from priceChange parameter if provided
    if (widget.priceChange != null && widget.priceChange!.isNotEmpty) {
      try {
        returnrate = double.parse(widget.priceChange!);
      } catch (e) {
        print("Error parsing priceChange: $e");
      }
    }

    // Initialize market data if provided
    if (widget.highPrice != null && widget.highPrice!.isNotEmpty) {
      high24h = widget.highPrice!;
    }

    if (widget.lowPrice != null && widget.lowPrice!.isNotEmpty) {
      low24h = widget.lowPrice!;
    }

    if (widget.volume != null && widget.volume!.isNotEmpty) {
      volume24h = widget.volume!;
    }

    if (widget.openPrice != null && widget.openPrice!.isNotEmpty) {
      try {
        // Store open price in a variable if needed
        print("Open Price: ${widget.openPrice}");
      } catch (e) {
        print("Error parsing openPrice: $e");
      }
    }

    if (widget.highPrice != null && widget.highPrice!.isNotEmpty) {
      try {
        // Store high price in a variable if needed
        print("High Price: ${widget.highPrice}");
      } catch (e) {
        print("Error parsing highPrice: $e");
      }
    }

    if (widget.lowPrice != null && widget.lowPrice!.isNotEmpty) {
      try {
        // Store low price in a variable if needed
        print("Low Price: ${widget.lowPrice}");
      } catch (e) {
        print("Error parsing lowPrice: $e");
      }
    }

    if (widget.volume != null && widget.volume!.isNotEmpty) {
      try {
        // Store volume in a variable if needed
        print("Volume: ${widget.volume}");
      } catch (e) {
        print("Error parsing volume: $e");
      }
    }

    if (widget.quoteVolume != null && widget.quoteVolume!.isNotEmpty) {
      try {
        // Store quote volume in a variable if needed
        print("Quote Volume: ${widget.quoteVolume}");
      } catch (e) {
        print("Error parsing quoteVolume: $e");
      }
    }

    _fatchData();
    timer = Timer.periodic(
        const Duration(seconds: 2), (Timer t) => _getquantitumData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Color(0xFF1E2329),
      body: SafeArea(
        child: Consumer<TradeSettingSubbinProvider>(
          builder: (context, tradesetting, child) {
            return Scaffold(
              body: Container(
                color: const Color(0xFF1A2234),
                child: isAPIcalled
                    ? const Center(
                        child: LottieLoadingWidget(),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            // Market Overview Section
                            Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF2A3A5A),
                                    Color(0xFF1E293B),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          widget.compaircoinname,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: TradingTheme.secondaryAccent,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '\$${double.parse(currentprice).toStringAsFixed(4)}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _buildMarketInfo(
                                            '24h High', high24h, Colors.green),
                                        const SizedBox(width: 16),
                                        _buildMarketInfo(
                                            '24h Low', low24h, Colors.red),
                                        const SizedBox(width: 16),
                                        _buildMarketInfo('24h Volume',
                                            volume24h, Colors.blue),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Trading Stats Section with updated P/L
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF2A3A5A),
                                    Color(0xFF1E293B),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Trading Stats',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTradingStat(
                                          'Position',
                                          positionQuantity,
                                          Icons.inventory,
                                          Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildTradingStat(
                                          'Margin Calls',
                                          numberofmarginCall.toString(),
                                          Icons.warning,
                                          Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTradingStat(
                                          'Floating P/L',
                                          '${returnrate.toStringAsFixed(4)} USDT',
                                          Icons.trending_up,
                                          checkavgPrice
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildTradingStat(
                                          'Avg Price',
                                          '\$${double.parse(avgprice).toStringAsFixed(4)}',
                                          Icons.price_change,
                                          Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Add Trigger Prices Section
                            _buildTriggerPrices(),

                            // Trading Actions Section
                            Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF2A3A5A),
                                    Color(0xFF1E293B),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Trading Actions',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  GridView.count(
                                    crossAxisCount: 3,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8,
                                    childAspectRatio: 1.2,
                                    children: [
                                      _buildActionButton(
                                        label: 'Cycle',
                                        icon: Icons.refresh,
                                        color: Colors.blue,
                                        onTap: () {
                                          setState(() {
                                            cycle = cycle == 1 ? 0 : 1;
                                            _one_shot_to_cycle();
                                          });
                                        },
                                      ),
                                      // Hide Stop Margin button when order_type is "auto" or still loading
                                      if (orderType != "auto" &&
                                          orderType != "loading")
                                        _buildActionButton(
                                          label: 'Stop Margin',
                                          icon: Icons.stop,
                                          color: Colors.red,
                                          onTap: () {
                                            setState(() {
                                              start_or_stop_margin =
                                                  start_or_stop_margin == 1
                                                      ? 0
                                                      : 1;
                                              _start_or_stop_margin();
                                            });
                                          },
                                        ),
                                      _buildActionButton(
                                        label: 'Chart',
                                        icon: Icons.show_chart,
                                        color: Colors.green,
                                        onTap: () {
                                          showtoast("Chart feature coming soon",
                                              context);
                                        },
                                      ),
                                      // Hide Buy button when order_type is "auto" or still loading
                                      if (orderType != "auto" &&
                                          orderType != "loading")
                                        _buildActionButton(
                                          label: 'Buy',
                                          icon: Icons.add_circle,
                                          color: Colors.green,
                                          onTap: () {
                                            _buy(tradesetting.firstbuy.text);
                                          },
                                        ),
                                      // Hide Sell button when order_type is "auto" or still loading
                                      // if (orderType != "auto" && orderType != "loading")
                                      _buildActionButton(
                                        label: 'Sell',
                                        icon: Icons.remove_circle,
                                        color: Colors.red,
                                        onTap: () {
                                          _sell(context);
                                        },
                                      ),
                                      // Hide Settings button when order_type is "auto"
                                      if (orderType != "auto")
                                        _buildActionButton(
                                          label: 'Settings',
                                          icon: Icons.settings,
                                          color: Colors.blue,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TradeSettingSubbin(
                                                  coinname:
                                                      widget.compaircoinname,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Additional Info Section
                            Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF2A3A5A),
                                    Color(0xFF1E293B),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Additional Info',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Operation Reminder:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '1. After the first buy-in, the system will automatically calculate the next buy-in price based on the drop ratio.\n2. When the price drops to the trigger price, the system will automatically buy in.\n3. When the price rises to the take profit price, the system will automatically sell all positions.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Trigger Price: \$${triggerprice}',
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Trading Chart Section (Moved to bottom)
                            Container(
                              height: 400,
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF2A3A5A),
                                    Color(0xFF1E293B),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox(
                                  height: 400,
                                  child: TradingChart(
                                    symbol: widget.compaircoinname,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                                height:
                                    20), // Add some space before the bottom navigation bar
                          ],
                        ),
                      ),
              ),
              bottomNavigationBar: Container(
                width: double.infinity,
                height: 60,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A2234),
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFF2A3A5A),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    // Hide Settings button when order_type is "auto" or still loading
                    if (orderType != "auto" && orderType != "loading")
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF2A3A5A),
                                Color(0xFF1E293B),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              disabledForegroundColor:
                                  Colors.transparent.withOpacity(0.38),
                              disabledBackgroundColor:
                                  Colors.transparent.withOpacity(0.12),
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TradeSettingSubbin(
                                    coinname: widget.compaircoinname,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.settings,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Settings",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF4A90E2),
                              Color(0xFF2A3A5A),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TradingTheme.secondaryAccent,
                            disabledForegroundColor:
                                Colors.transparent.withOpacity(0.38),
                            disabledBackgroundColor:
                                Colors.transparent.withOpacity(0.12),
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            _start_or_pause(tradesetting.firstbuy.text,
                                tradesetting.martinConfig);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                (buttonstatus == null &&
                                        double.parse(avgprice) <= 0)
                                    ? Icons.play_arrow
                                    : buttonstatus == 1 &&
                                            double.parse(avgprice) > 0
                                        ? Icons.pause
                                        : buttonstatus == 2 &&
                                                double.parse(avgprice) > 0
                                            ? Icons.play_arrow
                                            : Icons.play_arrow,
                                color: Colors.black,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                (buttonstatus == null &&
                                        double.parse(avgprice) <= 0)
                                    ? "Start"
                                    : buttonstatus == 1 &&
                                            double.parse(avgprice) > 0
                                        ? "Pause"
                                        : buttonstatus == 2 &&
                                                double.parse(avgprice) > 0
                                            ? "Start"
                                            : "",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMarketInfo(String label, String value, Color color) {
    // Format the value based on the label
    String formattedValue = value;

    if (label == '24h High' || label == '24h Low') {
      // Try to parse the value as a double and format with 5 decimal places
      try {
        double numValue = double.parse(value);
        formattedValue = numValue.toStringAsFixed(5);
      } catch (e) {
        // Keep original value if parsing fails
      }
      // Add dollar sign for price values
      formattedValue = '\$' + formattedValue;
    } else if (label == '24h Volume') {
      // Try to parse the value as a double and format with appropriate scale
      try {
        double numValue = double.parse(value);
        if (numValue > 1000000) {
          formattedValue = (numValue / 1000000).toStringAsFixed(2) + 'M';
        } else if (numValue > 1000) {
          formattedValue = (numValue / 1000).toStringAsFixed(2) + 'K';
        } else {
          formattedValue = numValue.toStringAsFixed(2);
        }
      } catch (e) {
        // Keep original value if parsing fails
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3A5A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formattedValue,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A3A5A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sell(BuildContext context) async {
    try {
      showLoading(context);
      final res = await http.post(
        Uri.parse(APIsellmanualsubbin),
        body: json.encode({
          "user_id": commonuserId,
          "type": exchanger,
          "crypto_pair": widget.compaircoinname,
          "amount": positionAmount,
        }),
      );

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['status'] == "success") {
          showtoast(data['message'], context);
          _getquantitative_txn_record();
        } else {
          showtoast(data['message'], context);
        }
      } else {
        showtoast("Server Error", context);
      }
    } catch (e) {
      showtoast("Error: $e", context);
    } finally {
      Navigator.pop(context);
    }
  }

  Future<void> showdailog(
    BuildContext context,
  ) async {
    String finaltext = cycle != 0 ? "Cycle" : "One Shot";
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Container(
            child: AlertDialog(
              actionsAlignment: MainAxisAlignment.center,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0))),
              contentPadding:
                  const EdgeInsets.only(bottom: 10, left: 20, right: 10),
              title: const Center(child: Text('Note :- ')),
              content: Container(
                  margin: const EdgeInsets.only(top: 10),
                  child:
                      Text("Are you sure? you want to change to $finaltext.")),
              actions: [
                Container(
                  height: 25,
                  width: 90,
                  decoration: BoxDecoration(
                      color: rapidtradeaicolor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      disabledForegroundColor:
                          Colors.transparent.withOpacity(0.38),
                      disabledBackgroundColor:
                          Colors.transparent.withOpacity(0.12),
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Center(
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  height: 25,
                  width: 70,
                  decoration: BoxDecoration(
                      color: rapidtradeaicolor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      disabledForegroundColor:
                          Colors.transparent.withOpacity(0.38),
                      disabledBackgroundColor:
                          Colors.transparent.withOpacity(0.12),
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () {
                      _one_shot_to_cycle();
                    },
                    child: const Center(
                      child: Text(
                        "Yes",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          );
        });
  }

  Future<void> _buy(String amount) async {
    try {
      if (widget.compaircoinname.isEmpty) {
        showtoast("Invalid trading pair", context);
        return;
      }

      showLoading(context);

      // Create request body with only required fields
      Map<String, String> bodyData = {
        "user_id": commonuserId,
        "type": exchanger,
        "crypto_pair": widget.compaircoinname,
        "amount": amount,
        "order_mode": "self"
      };

      print(
          "Buy Request URL: ${exchanger == "Binance" ? buymanualsubbin : buyManualHuobiSubbin}");
      print("Buy Request Body: $bodyData");

      final res = await http.post(
        Uri.parse(
            exchanger == "Binance" ? buymanualsubbin : buyManualHuobiSubbin),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: bodyData,
      );

      print("Buy Response Status: ${res.statusCode}");
      print("Buy Response Body: ${res.body}");

      if (res.statusCode == 200) {
        if (res.body.toLowerCase().contains('<!doctype html>') ||
            res.body.toLowerCase().contains('<div style')) {
          throw Exception("Server returned an error. Please try again.");
        }

        var data = jsonDecode(res.body);
        if (data['status'] == "success") {
          showtoast(
              data['message'] ?? "Buy order executed successfully", context);
          _getquantitative_txn_record();
        } else {
          showtoast(data['message'] ?? "Buy order failed", context);
        }
      } else {
        showtoast("Server Error: ${res.statusCode}", context);
      }
    } catch (e) {
      print("Error in _buy: $e");
      if (e.toString().contains('SyntaxError')) {
        showtoast("Server error occurred. Please try again.", context);
      } else {
        showtoast("Error executing buy order: ${e.toString()}", context);
      }
    } finally {
      Navigator.pop(context);
    }
  }

  Widget record(String imgpath, text, amt, imgpath2, disc2, amt2) {
    return Container(
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: Container(
                child: Row(
              children: [
                Image.asset(
                  imgpath,
                  height: 25,
                  width: 25,
                ),
                const SizedBox(width: 5),
                Flexible(
                    child: Text(
                  text,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
                // SizedBox(width: 5),
                Flexible(
                    child: Text(
                  "    $amt",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ))
              ],
            )),
          ),
          Expanded(
            child: Container(
                child: Row(
              children: [
                Image.asset(
                  imgpath2,
                  height: 25,
                  width: 25,
                ),
                const SizedBox(width: 5),
                Flexible(
                    child: Text(
                  disc2,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
                // SizedBox(width: 5),
                Flexible(
                    child: Text(
                  "  $amt2",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ))
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget addionalOption() {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height * 0.28; // uncomment
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10, right: 15, left: 15),
        height: categoryHeight,
        decoration: BoxDecoration(
          boxShadow: [
            const BoxShadow(
                offset: Offset(10, 10), color: Colors.black38, blurRadius: 20),
            BoxShadow(
                offset: const Offset(
                  -10,
                  -10,
                ),
                color: Colors.white.withOpacity(0.85),
                blurRadius: 20)
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.add_moderator_outlined),
                const SizedBox(width: 5),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: "Call Margin Trigger Price ",
                      ),
                      TextSpan(
                        text: " < ${finalCMTP.toStringAsFixed(4)}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                checkCMTP ? Colors.green : rapidtradeaicolor),
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(
                height: 10,
              ),
              Row(children: [
                const Icon(Icons.ads_click_outlined),
                const SizedBox(width: 5),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: "Take Profit Trigger Price ",
                      ),
                      TextSpan(
                        text: " > ${finalTPTP.toStringAsFixed(4)}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                checkTPTP ? Colors.green : rapidtradeaicolor),
                      ),
                    ],
                  ),
                ),
              ]),
            ],
          ),
        ));
  }

  _BuyManuall(String amount) async {
    if (!mounted) return;

    Uri finalurl = Uri.parse(
        exchanger == "Binance" ? buymanualsubbin : buyManualHuobiSubbin);
    final tradesettingfinal =
        Provider.of<TradeSettingSubbinProvider>(context, listen: false);
    double minAmount = double.parse(tradesettingfinal.firstbuy.text);

    if (double.parse(amount) < minAmount) {
      showtoast("minimum amount should be $minAmount USDT", context);
      return;
    }

    try {
      showLoading(context);

      // Create request body with only required fields
      Map<String, String> bodyData = {
        "user_id": commonuserId,
        "type": exchanger,
        "crypto_pair": widget.compaircoinname,
        "amount": amount,
        "order_mode": "self"
      };

      print("Buy Manual Request URL: $finalurl");
      print("Buy Manual Request Body: $bodyData");

      final res = await http
          .post(
            finalurl,
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Accept': 'application/json',
            },
            body: bodyData,
          )
          .timeout(const Duration(seconds: 15));

      print("Buy Manual Response Status: ${res.statusCode}");
      print("Buy Manual Response Body: ${res.body}");

      if (!mounted) return;

      if (res.statusCode == 200) {
        if (res.body.toLowerCase().contains('<!doctype html>') ||
            res.body.toLowerCase().contains('<div style')) {
          throw Exception("Server returned an error. Please try again.");
        }

        var data = jsonDecode(res.body);
        if (data['status'] == "success") {
          showtoast(
              data['message'] ?? "Buy order executed successfully", context);
          _getquantitative_txn_record();
          Navigator.pop(context);
        } else {
          showtoast(data['message'] ?? "Buy order failed", context);
          Navigator.pop(context);
        }
      } else {
        showtoast("Server Error: ${res.statusCode}", context);
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error in _BuyManuall: $e");
      if (e.toString().contains('SyntaxError')) {
        showtoast("Server error occurred. Please try again.", context);
      } else {
        showtoast("Error executing buy order: ${e.toString()}", context);
      }
      Navigator.pop(context);
    }
  }

  _start_or_pause(String firseBy, martinConfig) async {
    if (double.parse(avgprice) <= 0) {
      var finalamount = double.parse(firseBy) * 2;
      try {
        // print("buy");
        showLoading(context);
        Uri finalurl = Uri.parse(
            exchanger == "Binance" ? buymanualsubbin : buyManualHuobiSubbin);
        var bodyData = json.encode({
          "user_id": commonuserId,
          "type": exchanger,
          "crypto_pair": widget.compaircoinname,
          "amount": martinConfig != "0" ? finalamount.toString() : firseBy,
          "order_mode": "self"
        });
        print(finalurl);
        final res = await http.post(finalurl, body: bodyData);
        print(res.body);
        if (res.statusCode == 200) {
          var data = jsonDecode(res.body);
          if (data['status'] == "success") {
            showtoast(data['message'], context);
            _getquantitative_txn_record();
            Navigator.pop(context);

            // Save bot state after successful start/pause
            _saveBotState();
          } else {
            showtoast(data['message'], context);
            Navigator.pop(context);
          }
        } else {
          print("server error");
          Navigator.pop(context);
        }
      } catch (e) {
        print(e);
      }
    } else {
      showLoading(context);
      try {
        final res = await http.post(Uri.parse(openOrderStatussubbin),
            body: json.encode({
              "user_id": commonuserId,
              "exchange_type": exchanger,
              "assets": widget.compaircoinname,
              "status": buttonstatus == 1 ? "2" : "1"
            }));
        if (res.statusCode == 200) {
          var data = jsonDecode(res.body);
          if (data['status'] == "success") {
            showtoast(data['message'], context);
            _getquantitative_txn_record();
            Navigator.pop(context);

            // Save bot state after successful start/pause
            _saveBotState();
          } else {
            showtoast(data['message'], context);
            Navigator.pop(context);
          }
        } else {
          print("server error");
          Navigator.pop(context);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Widget disc() {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height * 0.28; // uncomment
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10, right: 15, left: 15),
        height: categoryHeight,
        decoration: BoxDecoration(
          boxShadow: [
            const BoxShadow(
                offset: Offset(10, 10), color: Colors.black38, blurRadius: 20),
            BoxShadow(
                offset: const Offset(
                  -10,
                  -10,
                ),
                color: Colors.white.withOpacity(0.85),
                blurRadius: 20)
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Text("opration_reminder".tr,
                  style: const TextStyle(
                      fontFamily: fontFamily, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 10,
              ),
              Text("opration_dec".tr,
                  style: const TextStyle(
                    fontFamily: fontFamily,
                  )),
            ],
          ),
        ));
  }

  Future<void> cancelBot(
    BuildContext context,
  ) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.center,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            contentPadding:
                const EdgeInsets.only(bottom: 10, left: 20, right: 10),
            title: const Center(child: Text('Note :- ')),
            content: Container(
                margin: const EdgeInsets.only(top: 10),
                child: const Text("Are you sure? you want to Cancel Bot.")),
            actions: [
              Container(
                height: 25,
                width: 90,
                decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledForegroundColor:
                        Colors.transparent.withOpacity(0.38),
                    disabledBackgroundColor:
                        Colors.transparent.withOpacity(0.12),
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Center(
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                height: 25,
                width: 70,
                decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledForegroundColor:
                        Colors.transparent.withOpacity(0.38),
                    disabledBackgroundColor:
                        Colors.transparent.withOpacity(0.12),
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {
                    _cancelBot();
                  },
                  child: const Center(
                    child: Text(
                      "Yes",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          );
        });
  }

  _one_shot_to_cycle() async {
    print(widget.compaircoinname);
    try {
      showLoading(context);
      final res =
          await http.post(Uri.parse(tradesetting_update_by_columnsubbin),
              body: json.encode({
                "user_id": commonuserId,
                "assets_type": widget.compaircoinname,
                "colum_name": "cycle",
                "exchange_type": exchanger,
                "colum_value": cycle == 1 ? "0" : "1"
              }));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print(data);
        if (data['status'] == "success") {
          showtoast(data['message'], context);
          Navigator.pop(context);
          Navigator.pop(context);
          _getquantitative_txn_record();
        } else {
          showtoast("Something Wrong", context);
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } else {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
  }

  Future<void> startStop(
    BuildContext context,
  ) async {
    String finaltext = start_or_stop_margin != 0 ? "Stop" : "Start";
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.center,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            contentPadding:
                const EdgeInsets.only(bottom: 10, left: 20, right: 10),
            title: const Center(child: Text('Note :- ')),
            content: Container(
                margin: const EdgeInsets.only(top: 10),
                child: Text("Are you sure? you want to $finaltext.")),
            actions: [
              Container(
                height: 25,
                width: 90,
                decoration: BoxDecoration(
                    color: rapidtradeaicolor,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledForegroundColor:
                        Colors.transparent.withOpacity(0.38),
                    disabledBackgroundColor:
                        Colors.transparent.withOpacity(0.12),
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Center(
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                height: 25,
                width: 70,
                decoration: BoxDecoration(
                    color: rapidtradeaicolor,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledForegroundColor:
                        Colors.transparent.withOpacity(0.38),
                    disabledBackgroundColor:
                        Colors.transparent.withOpacity(0.12),
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {
                    _start_or_stop_margin();
                  },
                  child: const Center(
                    child: Text(
                      "Yes",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          );
        });
  }

  Widget topHeader() {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height * 0.35;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 5),
        Container(
          margin: const EdgeInsets.only(right: 20, left: 20),
          width: double.infinity,
          height: categoryHeight,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          // decoration: const BoxDecoration(
          //     borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 25,
                        // width: 50,
                        decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            disabledForegroundColor:
                                Colors.transparent.withOpacity(0.38),
                            disabledBackgroundColor:
                                Colors.transparent.withOpacity(0.12),
                            shadowColor: Colors.transparent,
                          ),
                          onPressed: () {
                            print("pathaan");
                            print(widget.checkNavigate);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MainTradeSetting(
                                        compaircoinname: widget.compaircoinname,
                                        coinimg: widget.coinimg,
                                        finalCoinName: widget.finalCoinName,
                                        reffralnno: widget.reffralnno,
                                        coinurl: widget.coinurl,
                                        checkNavigate: widget.checkNavigate)));
                            // Navigator.pop(context);
                          },
                          child: const Center(
                            child: Text(
                              "Whole Warehouse Mode",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 25,
                        // width: 50,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.0, 1.0],
                              colors: [
                                primaryColor,
                                Colors.blue,
                              ],
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            disabledForegroundColor:
                                Colors.transparent.withOpacity(0.38),
                            disabledBackgroundColor:
                                Colors.transparent.withOpacity(0.12),
                            shadowColor: Colors.transparent,
                          ),
                          onPressed: () {
                            // _one_shot_to_cycle();
                          },
                          child: const Center(
                            child: Text(
                              "Sub-Bin Mode",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ]),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Material(
                            child: Container(
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              height: 30,
                              width: 30,
                              child: Center(
                                  child: Image.network(
                                widget.coinimg,
                              )),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                widget.finalCoinName + "/",
                                style: const TextStyle(
                                    fontFamily: fontFamily,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                "USDT",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontFamily: fontFamily,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        // uncomment
                        width: 75,
                        height: 60,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Center(
                                  child: Text(positionAmount,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: fontFamily)),
                                ),
                              ),
                              Container(
                                child: Center(
                                  child: Text("position_amount".tr + "(USDT)",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontFamily: fontFamily)),
                                ),
                              ),
                            ],
                          ),
                        )),
                    Container(
                        width: 75,
                        height: 60,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Center(
                                  child: Text(
                                    double.parse(avgprice).toStringAsFixed(4),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: fontFamily),
                                  ),
                                ),
                              ),
                              Container(
                                child: Center(
                                  child: Text(
                                    "avgprice".tr,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 11, fontFamily: fontFamily),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    Container(
                        width: 75,
                        height: 60,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(numberofmarginCall.toString(),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: fontFamily)),
                              Container(
                                child: Center(
                                  child: Text("number_off_call_margin".tr,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontFamily: fontFamily)),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        //uncomment
                        width: 75,
                        height: 80,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Text(positionQuantity,
                              Text(positionQuantity,
                                  maxLines: 2,
                                  overflow: TextOverflow.fade,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: fontFamily)),
                              Container(
                                child: Center(
                                  child: Text(
                                      "position_quantity".tr +
                                          "(${widget.finalCoinName})",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontFamily: fontFamily)),
                                ),
                              ),
                            ],
                          ),
                        )),
                    Container(
                        width: 75,
                        height: 80,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                returnrate.toString() == "Infinity"
                                    ? "0.00"
                                    : returnrate.toStringAsFixed(3) + r" $",
                                style: TextStyle(
                                    color: checkavgPrice
                                        ? Colors.red
                                        : Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: fontFamily),
                              ),
                              Container(
                                child: const Center(
                                  child: Text(
                                    "Floating Profit/Loss",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 11, fontFamily: fontFamily),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  _cancelBot() async {
    showLoading(context);
    final res = await http.post(Uri.parse(resetBotsubbin),
        body: jsonEncode({
          "user_id": commonuserId,
          "assets": widget.compaircoinname,
          "exchange_type": exchanger
        }));
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      print(data);
      if (data['status'] == "success") {
        showtoast(data['message'], context);
        _getquantitative_txn_record();
        Navigator.pop(context);
        Navigator.pop(context);

        // Clear bot state from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('bot_state');
        print("✅ Bot state cleared from SharedPreferences");
      } else {
        showtoast("No Active BOT Found", context);
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } else {
      showtoast("Server Error", context);
      Navigator.pop(context);
    }
  }

  _start_or_stop_margin() async {
    showLoading(context);
    try {
      final res =
          await http.post(Uri.parse(tradesetting_update_by_columnsubbin),
              body: json.encode({
                "user_id": commonuserId,
                "assets_type": widget.compaircoinname,
                "colum_name": "stock_margin",
                "exchange_type": exchanger,
                "colum_value": start_or_stop_margin == 1 ? "0" : "1"
              }));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['status'] == "success") {
          showtoast(data['message'], context);
          Navigator.pop(context);
          Navigator.pop(context);
          _getquantitative_txn_record();

          // Save bot state after successful margin call toggle
          _saveBotState();
        } else {
          showtoast(data['message'], context);
          Navigator.pop(context);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
  }

  Future<void> _saveBotState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Create a map with all the bot state
      final botState = {
        'id': widget.id,
        'isActive': buttonstatus == 1, // Only save as active if status is 1
        'userId': commonuserId,
        'exchangeType': exchanger,
        'assetType': widget.compaircoinname,
        'positionAmount': positionAmount,
        'avgPrice': avgprice,
        'numberOfMarginCalls': numberofmarginCall,
        'lastAVGPrice': lastAVGPrice,
        'marginCallTriggerPrice': finalCMTP.toString(),
        'takeProfitTriggerPrice': finalTPTP.toString(),
        'currentPrice': currentprice,
        'status': buttonstatus,
        'tradeSettings': {
          'marginCallsEnabled': start_or_stop_margin == 1,
          'marginCallLimit':
              Provider.of<TradeSettingSubbinProvider>(context, listen: false)
                  .marginCallLimit
                  .text,
          'marginCallDrop': finalnumberofmargincall,
          'takeProfit':
              Provider.of<TradeSettingSubbinProvider>(context, listen: false)
                  .takeprofit,
          'earningCallback':
              Provider.of<TradeSettingSubbinProvider>(context, listen: false)
                  .earingcallback,
          'buyInCallback':
              Provider.of<TradeSettingSubbinProvider>(context, listen: false)
                  .buy_in_callbakc
                  .text,
          'firstBuyAmount':
              Provider.of<TradeSettingSubbinProvider>(context, listen: false)
                  .firstbuy
                  .text,
          'positionDoubling':
              Provider.of<TradeSettingSubbinProvider>(context, listen: false)
                  .switchValue,
        }
      };

      // Get existing bot states
      final existingStatesJson = prefs.getString('bot_states') ?? '[]';
      List<dynamic> existingStates = json.decode(existingStatesJson);

      // Remove any existing state for this bot
      existingStates.removeWhere((state) => state['id'] == widget.id);

      // Only add the bot if it's active
      if (buttonstatus == 1) {
        existingStates.add(botState);
        print("✅ Added active bot to states: ${widget.compaircoinname}");
      }

      // Save all states back to SharedPreferences
      await prefs.setString('bot_states', json.encode(existingStates));
      print("✅ Bot states saved successfully");
      print(
          "📊 Total active bots: ${existingStates.where((state) => state['isActive'] == true).length}");
      print(
          "💾 Active bot details: ${existingStates.where((state) => state['isActive'] == true).map((e) => e['assetType']).toList()}");

      // Initialize background service if not already initialized
      if (!_backgroundServiceInitialized) {
        await initializeBackgroundService();
      }
    } catch (e) {
      print("❌ Error saving bot state: $e");
    }
  }

  Future<void> initializeBackgroundService() async {
    try {
      await background.initializeBackgroundService();
      _backgroundServiceInitialized = true;
      print("✅ Background service initialized");
    } catch (e) {
      print("❌ Error initializing background service: $e");
    }
  }

  bool isBackgroundMode() {
    if (!mounted) return true;
    final route = ModalRoute.of(context);
    if (route == null) return true;
    return !route.isCurrent;
  }

  Widget _buildTradingStat(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3A5A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Add _checkSell method
  Future<void> _checkSell(BuildContext context) async {
    try {
      showLoading(context);
      final res = await http.post(
        Uri.parse(APIsellmanualsubbin),
        body: json.encode({
          "user_id": commonuserId,
          "type": exchanger,
          "crypto_pair": widget.compaircoinname,
          "amount": positionAmount,
        }),
      );

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['status'] == "success") {
          showtoast(data['message'], context);
          _getquantitative_txn_record();
        } else {
          showtoast(data['message'], context);
        }
      } else {
        showtoast("Server Error", context);
      }
    } catch (e) {
      showtoast("Error: $e", context);
    } finally {
      Navigator.pop(context);
    }
  }

  // Add Trigger Prices Section
  Widget _buildTriggerPrices() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A3A5A),
            Color(0xFF1E293B),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trigger Prices',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTradingStat(
                  'Buy Trigger',
                  '\$${finalCMTP.toStringAsFixed(4)}',
                  Icons.arrow_downward,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTradingStat(
                  'Sell Trigger',
                  '\$${finalTPTP.toStringAsFixed(4)}',
                  Icons.arrow_upward,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInformation() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B3139),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF474D57)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Order Information',
              style: TextStyle(
                color: Color(0xFFEAECEF),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(color: Color(0xFF474D57), height: 1),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: quantutumdata.length,
            itemBuilder: (context, index) {
              final order = quantutumdata[index];
              final isBuy = order['side']?.toString().toLowerCase() == 'buy';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFF474D57),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isBuy
                                    ? const Color(0xFF2EBD85).withOpacity(0.1)
                                    : const Color(0xFFF6465D).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isBuy ? 'BUY' : 'SELL',
                                style: TextStyle(
                                  color: isBuy
                                      ? const Color(0xFF2EBD85)
                                      : const Color(0xFFF6465D),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              order['symbol'] ?? '',
                              style: const TextStyle(
                                color: Color(0xFFEAECEF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          order['status'] ?? '',
                          style: TextStyle(
                            color: order['status']?.toString().toLowerCase() ==
                                    'filled'
                                ? const Color(0xFF2EBD85)
                                : const Color(0xFFEAECEF).withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount',
                              style: TextStyle(
                                color: const Color(0xFFEAECEF).withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${order['amount'] ?? '0.00'} USDT',
                              style: const TextStyle(
                                color: Color(0xFFEAECEF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Price',
                              style: TextStyle(
                                color: const Color(0xFFEAECEF).withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${order['price'] ?? '0.00'} USDT',
                              style: const TextStyle(
                                color: Color(0xFFEAECEF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (order['profit'] != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Profit: ',
                            style: TextStyle(
                              color: const Color(0xFFEAECEF).withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${order['profit']} USDT',
                            style: TextStyle(
                              color: (double.tryParse(
                                              order['profit']?.toString() ??
                                                  '0') ??
                                          0) >=
                                      0
                                  ? const Color(0xFF2EBD85)
                                  : const Color(0xFFF6465D),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// CustomPainter class to for the header curved-container
class HeaderCurvedContainer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = const Color(0xff000000);
    Path path = Path()
      ..relativeLineTo(0, 100)
      ..quadraticBezierTo(size.width / 2, 100.0, size.width, 100)
      ..relativeLineTo(0, -100)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
