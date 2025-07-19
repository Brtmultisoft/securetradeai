import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/method/tradeSettingSubbinprovider.dart';
import 'package:securetradeai/src/Homepage/subbinMarginConfig.dart';
import 'package:securetradeai/src/Service/assets_service.dart';

import '../../data/api.dart';

class TradeSettingSubbin extends StatefulWidget {
  final coinname;
  TradeSettingSubbin({
    Key? key,
    this.coinname,
  }) : super(key: key);

  @override
  _TradeSettingSubbinState createState() => _TradeSettingSubbinState();
}

class _TradeSettingSubbinState extends State<TradeSettingSubbin> {
  _getData() {
    final tradesettingfinal =
        Provider.of<TradeSettingSubbinProvider>(context, listen: false);
    tradesettingfinal.getTradeSetting(widget.coinname);
  }

  _backmethod() {
    Navigator.pop(context);
  }

  _commonAPIcallMethod() async {
    print("click");
    final tradesettingfinal =
        Provider.of<TradeSettingSubbinProvider>(context, listen: false);
    _updateSetting(
        tradesettingfinal.firstbuy.text,
        tradesettingfinal.switchValue,
        tradesettingfinal.marginCallLimit.text,
        tradesettingfinal.wholPositiontakeProfitratio.text,
        tradesettingfinal.whole_position_take_profit_callback.text,
        tradesettingfinal.buy_in_callbakc.text);
    _reset();
  }

  _reset() {
    setState(() {
      // Remove risk-related resets
    });
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showExitPopup();
        if (shouldPop) {
          Navigator.of(context).pop();
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Trade Settings",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldPop = await showExitPopup();
              if (shouldPop) {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 15),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () {
                  _commonAPIcallMethod();
                },
                child: const Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Consumer<TradeSettingSubbinProvider>(
            builder: (context, tradesetting, child) {
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1E293B),
                          Color(0xFF0F172A),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF2D3548),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A90E2).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                color: Color(0xFF4A90E2),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                "The first buy in amount is calculated according to the currency pair principle and trade unit",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1E293B),
                          Color(0xFF0F172A),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF2D3548),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSettingRow(
                          "First Buy Amount",
                          tradesetting.firstbuy,
                          "USDT",
                          "Enter amount",
                          Icons.account_balance_wallet,
                        ),
                        const Divider(color: Color(0xFF2D3548)),
                        _buildSwitchRow(
                          "Open Position Doubled",
                          tradesetting.switchValue,
                          (value) {
                            setState(() {
                              tradesetting.switchValue = value;
                            });
                          },
                          Icons.compare_arrows,
                        ),
                        const Divider(color: Color(0xFF2D3548)),
                        _buildSettingRow(
                          "Margin Call Limit",
                          tradesetting.marginCallLimit,
                          "Times",
                          "Enter limit",
                          Icons.warning_amber_rounded,
                        ),
                        const Divider(color: Color(0xFF2D3548)),
                        _buildSettingRow(
                          "Whole Position Take Profit Ratio",
                          tradesetting.wholPositiontakeProfitratio,
                          "%",
                          "Enter ratio",
                          Icons.trending_up,
                        ),
                        const Divider(color: Color(0xFF2D3548)),
                        _buildSettingRow(
                          "Whole Position Take Profit Callback",
                          tradesetting.whole_position_take_profit_callback,
                          "%",
                          "Enter callback",
                          Icons.refresh,
                        ),
                        const Divider(color: Color(0xFF2D3548)),
                        _buildMarginConfigButton(
                          "Margin Configuration",
                          widget.coinname,
                          tradesetting.marginCallLimit.text,
                          Icons.settings,
                        ),
                        const Divider(color: Color(0xFF2D3548)),
                        _buildSettingRow(
                          "Buy In Callback",
                          tradesetting.buy_in_callbakc,
                          "%",
                          "Enter callback",
                          Icons.shopping_cart,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, TextEditingController controller,
      String unit, String hint, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF4A90E2).withOpacity(0.3),
                        const Color(0xFF4A90E2).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF4A90E2),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              Container(
                width: 80,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A2234),
                      Color(0xFF0F172A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF2D3548),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle:
                        const TextStyle(color: Colors.white30, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF4A90E2).withOpacity(0.3),
                      const Color(0xFF4A90E2).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  unit,
                  style: const TextStyle(
                    color: Color(0xFF4A90E2),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
      String label, bool value, Function(bool) onChanged, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF4A90E2).withOpacity(0.3),
                        const Color(0xFF4A90E2).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF4A90E2),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.0,
            child: CupertinoSwitch(
              activeColor: const Color(0xFF4A90E2),
              trackColor: const Color(0xFF2D3548),
              value: value,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarginConfigButton(
      String label, String coinname, String callLimit, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MarginConfigSubbin(
              coinname: coinname,
              calllimit: double.parse(callLimit),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF4A90E2).withOpacity(0.3),
                          const Color(0xFF4A90E2).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      icon,
                      color: const Color(0xFF4A90E2),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2D3548),
                    Color(0xFF1A2234),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> showExitPopup() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'Exit Settings',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Are you sure you want to exit? Any unsaved changes will be lost.',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFF4A90E2),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Exit',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  _updateSetting(String firstBy, martinConfig, martinCallLimit, wpProfit,
      wpCallback, bycalback) async {
    var bodydata = json.encode({
      "user_id": commonuserId,
      "assets_type": widget.coinname,
      "exchange_type": exchanger,
      "first_buy": firstBy,
      "martin_config": martinConfig == true ? "1" : "0",
      "margin_call_limit": martinCallLimit,
      "wp_profit": wpProfit,
      "wp_callback": wpCallback,
      "by_callback": bycalback
    });
    print(bodydata);
    if (firstBy.contains(".")) {
      showtoast("Invalid Value", context);
      return;
    }
    if (firstBy.isEmpty || double.parse(firstBy) < 10) {
      showtoast("Error", context);
    } else if (martinCallLimit == "" ||
        double.parse(martinCallLimit).isNegative ||
        double.parse(martinCallLimit) > 100) {
      showtoast("Error", context);
    } else if (double.parse(wpProfit) <= 0) {
      showtoast("Error", context);
    } else if (double.parse(wpCallback) <= 0) {
      showtoast("Error", context);
    } else if (double.parse(bycalback) <= 0) {
      showtoast("Error", context);
    } else {
      showLoading(context);
      final res = await http.post(Uri.parse(updateTradeSettingFirstPagesubbin),
          body: bodydata);
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['status'] == "success") {
          showtoast(data['message'], context);
          _getData();
          Navigator.pop(context);
        } else {
          showtoast(data['message'], context);
          Navigator.pop(context);
        }
      } else {
        showtoast("Server Error", context);
        Navigator.pop(context);
      }
    }
  }
}
