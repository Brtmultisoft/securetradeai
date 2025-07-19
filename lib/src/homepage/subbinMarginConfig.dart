import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/src/Service/assets_service.dart';

import '../../Data/Api.dart';

class MarginConfigSubbin extends StatefulWidget {
  const MarginConfigSubbin({Key? key, this.coinname, this.calllimit})
      : super(key: key);
  final coinname;
  final calllimit;
  @override
  _MarginConfigSubbinState createState() => _MarginConfigSubbinState();
}

class _MarginConfigSubbinState extends State<MarginConfigSubbin> {
  var marginfirstCall = TextEditingController();
  var marginsecoundndcall = TextEditingController();
  var marginthird = TextEditingController();
  var marginforth = TextEditingController();
  var marginfivth = TextEditingController();
  var marginsix = TextEditingController();
  var marginseven = TextEditingController();
  var margineigth = TextEditingController();
  var marginnine = TextEditingController();
  var marginten = TextEditingController();
  var margineleven = TextEditingController();
  var margintwel = TextEditingController();
  var marginthirteen = TextEditingController();
  var marginforteen = TextEditingController();
  var marginfivteen = TextEditingController();
  var marginsixteen = TextEditingController();
  var marginseventeen = TextEditingController();
  var margineigteen = TextEditingController();
  var marginnineteen = TextEditingController();
  var margintwentry = TextEditingController();
  var margin21 = TextEditingController();
  var margin22 = TextEditingController();
  var margin23 = TextEditingController();
  var margin24 = TextEditingController();
  var margin25 = TextEditingController();
  var margin26 = TextEditingController();
  var margin27 = TextEditingController();
  var margin28 = TextEditingController();
  var margin29 = TextEditingController();
  var margin30 = TextEditingController();
  var margin31 = TextEditingController();
  var margin32 = TextEditingController();
  var margin33 = TextEditingController();
  var margin34 = TextEditingController();
  var margin35 = TextEditingController();
  var margin36 = TextEditingController();
  var margin37 = TextEditingController();
  var margin38 = TextEditingController();
  var margin39 = TextEditingController();
  var margin40 = TextEditingController();
  var margin41 = TextEditingController();
  var margin42 = TextEditingController();
  var margin43 = TextEditingController();
  var margin44 = TextEditingController();
  var margin45 = TextEditingController();
  var margin46 = TextEditingController();
  var margin47 = TextEditingController();
  var margin48 = TextEditingController();
  var margin49 = TextEditingController();
  var margin50 = TextEditingController();
///////////////////////////////////////////////////////////////////////////
  var multiplyfirstCall = TextEditingController();
  var multiplysecoundndcall = TextEditingController();
  var multiplythird = TextEditingController();
  var multiplyforth = TextEditingController();
  var multiplyfivth = TextEditingController();
  var multiplysix = TextEditingController();
  var multiplyseven = TextEditingController();
  var multiplyeigth = TextEditingController();
  var multiplynine = TextEditingController();
  var multiplyten = TextEditingController();
  var multiplyleven = TextEditingController();
  var multiplytwel = TextEditingController();
  var multiplythirteen = TextEditingController();
  var multiplyforteen = TextEditingController();
  var multiplyfivteen = TextEditingController();
  var multiply16 = TextEditingController();
  var multiply17 = TextEditingController();
  var multiply18 = TextEditingController();
  var multiply19 = TextEditingController();
  var multiply20 = TextEditingController();
  var multiply21 = TextEditingController();
  var multiply22 = TextEditingController();
  var multiply23 = TextEditingController();
  var multiply24 = TextEditingController();
  var multiply25 = TextEditingController();
  var multiply26 = TextEditingController();
  var multiply27 = TextEditingController();
  var multiply28 = TextEditingController();
  var multiply29 = TextEditingController();
  var multiply30 = TextEditingController();
  var multiply31 = TextEditingController();
  var multiply32 = TextEditingController();
  var multiply33 = TextEditingController();
  var multiply34 = TextEditingController();
  var multiply35 = TextEditingController();
  var multiply36 = TextEditingController();
  var multiply37 = TextEditingController();
  var multiply38 = TextEditingController();
  var multiply39 = TextEditingController();
  var multiply40 = TextEditingController();
  var multiply41 = TextEditingController();
  var multiply42 = TextEditingController();
  var multiply43 = TextEditingController();
  var multiply44 = TextEditingController();
  var multiply45 = TextEditingController();
  var multiply46 = TextEditingController();
  var multiply47 = TextEditingController();
  var multiply48 = TextEditingController();
  var multiply49 = TextEditingController();
  var multiply50 = TextEditingController();

  bool isAPIcalled = false;
  _getdata() async {
    setState(() {
      isAPIcalled = true;
    });
    print(commonuserId);
    final res = await http.post(Uri.parse(tradesettingsubbin),
        body: json.encode({
          "user_id": commonuserId,
          "exchange_type": "Binance",
          "assets_type": widget.coinname
        }));
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        setState(() {
          marginfirstCall.text = data['data']['margin_drop_1'] ?? "";
          marginsecoundndcall.text = data['data']['margin_drop_2'] ?? "";
          marginthird.text = data['data']['margin_drop_3'] ?? "";
          marginforth.text = data['data']['margin_drop_4'] ?? "";
          marginfivth.text = data['data']['margin_drop_5'] ?? "";
          marginsix.text = data['data']['margin_drop_6'] ?? "";
          marginseven.text = data['data']['margin_drop_7'] ?? "";
          margineigth.text = data['data']['margin_drop_8'] ?? "";
          marginnine.text = data['data']['margin_drop_9'] ?? "";
          marginten.text = data['data']['margin_drop_10'] ?? "";
          margineleven.text = data['data']['margin_drop_11'] ?? "";
          margintwel.text = data['data']['margin_drop_12'] ?? "";
          marginthirteen.text = data['data']['margin_drop_13'] ?? "";
          marginforteen.text = data['data']['margin_drop_14'] ?? "";
          marginfivteen.text = data['data']['margin_drop_15'] ?? "";
          marginsixteen.text = data['data']['margin_drop_16'] ?? "";
          marginseventeen.text = data['data']['margin_drop_17'] ?? "";
          margineigteen.text = data['data']['margin_drop_18'] ?? "";
          marginnineteen.text = data['data']['margin_drop_19'] ?? "";
          margintwentry.text = data['data']['margin_drop_20'] ?? "";
          margin21.text = data['data']['margin_drop_21'] ?? "";
          margin22.text = data['data']['margin_drop_22'] ?? "";
          margin23.text = data['data']['margin_drop_23'] ?? "";
          margin24.text = data['data']['margin_drop_24'] ?? "";
          margin25.text = data['data']['margin_drop_25'] ?? "";
          margin26.text = data['data']['margin_drop_26'] ?? "";
          margin27.text = data['data']['margin_drop_27'] ?? "";
          margin28.text = data['data']['margin_drop_28'] ?? "";
          margin29.text = data['data']['margin_drop_29'] ?? "";
          margin30.text = data['data']['margin_drop_30'] ?? "";
          margin31.text = data['data']['margin_drop_31'] ?? "";
          margin32.text = data['data']['margin_drop_32'] ?? "";
          margin33.text = data['data']['margin_drop_33'] ?? "";
          margin34.text = data['data']['margin_drop_34'] ?? "";
          margin35.text = data['data']['margin_drop_35'] ?? "";
          margin36.text = data['data']['margin_drop_36'] ?? "";
          margin37.text = data['data']['margin_drop_37'] ?? "";
          margin38.text = data['data']['margin_drop_38'] ?? "";
          margin39.text = data['data']['margin_drop_39'] ?? "";
          margin40.text = data['data']['margin_drop_40'] ?? "";
          margin41.text = data['data']['margin_drop_41'] ?? "";
          margin42.text = data['data']['margin_drop_42'] ?? "";
          margin43.text = data['data']['margin_drop_43'] ?? "";
          margin44.text = data['data']['margin_drop_44'] ?? "";
          margin45.text = data['data']['margin_drop_45'] ?? "";
          margin46.text = data['data']['margin_drop_46'] ?? "";
          margin47.text = data['data']['margin_drop_47'] ?? "";
          margin48.text = data['data']['margin_drop_48'] ?? "";
          margin49.text = data['data']['margin_drop_49'] ?? "";
          margin50.text = data['data']['margin_drop_50'] ?? "";

          multiplyfirstCall.text = data['data']['multiply_ration_1'] ?? "";
          multiplysecoundndcall.text = data['data']['multiply_ration_2'] ?? "";
          multiplythird.text = data['data']['multiply_ration_3'] ?? "";
          multiplyforth.text = data['data']['multiply_ration_4'] ?? "";
          multiplyfivth.text = data['data']['multiply_ration_5'] ?? "";
          multiplysix.text = data['data']['multiply_ration_6'] ?? "";
          multiplyseven.text = data['data']['multiply_ration_7'] ?? "";
          multiplyeigth.text = data['data']['multiply_ration_8'] ?? "";
          multiplynine.text = data['data']['multiply_ration_9'] ?? "";
          multiplyten.text = data['data']['multiply_ration_10'] ?? "";
          multiplyleven.text = data['data']['multiply_ration_11'] ?? "";
          multiplytwel.text = data['data']['multiply_ration_12'] ?? "";
          multiplythirteen.text = data['data']['multiply_ration_13'] ?? "";
          multiplyforteen.text = data['data']['multiply_ration_14'] ?? "";
          multiplyfivteen.text = data['data']['multiply_ration_15'] ?? "";
          multiply16.text = data['data']['multiply_ration_16'] ?? "";
          multiply17.text = data['data']['multiply_ration_17'] ?? "";
          multiply18.text = data['data']['multiply_ration_18'] ?? "";
          multiply19.text = data['data']['multiply_ration_19'] ?? "";
          multiply20.text = data['data']['multiply_ration_20'] ?? "";
          multiply21.text = data['data']['multiply_ration_21'] ?? "";
          multiply22.text = data['data']['multiply_ration_22'] ?? "";
          multiply23.text = data['data']['multiply_ration_23'] ?? "";
          multiply24.text = data['data']['multiply_ration_24'] ?? "";
          multiply25.text = data['data']['multiply_ration_25'] ?? "";
          multiply26.text = data['data']['multiply_ration_26'] ?? "";
          multiply27.text = data['data']['multiply_ration_27'] ?? "";
          multiply28.text = data['data']['multiply_ration_28'] ?? "";
          multiply29.text = data['data']['multiply_ration_29'] ?? "";
          multiply30.text = data['data']['multiply_ration_30'] ?? "";
          multiply31.text = data['data']['multiply_ration_31'] ?? "";
          multiply32.text = data['data']['multiply_ration_32'] ?? "";
          multiply33.text = data['data']['multiply_ration_33'] ?? "";
          multiply34.text = data['data']['multiply_ration_34'] ?? "";
          multiply35.text = data['data']['multiply_ration_35'] ?? "";
          multiply36.text = data['data']['multiply_ration_36'] ?? "";
          multiply37.text = data['data']['multiply_ration_37'] ?? "";
          multiply38.text = data['data']['multiply_ration_38'] ?? "";
          multiply39.text = data['data']['multiply_ration_39'] ?? "";
          multiply40.text = data['data']['multiply_ration_40'] ?? "";
          multiply41.text = data['data']['multiply_ration_41'] ?? "";
          multiply42.text = data['data']['multiply_ration_42'] ?? "";
          multiply43.text = data['data']['multiply_ration_43'] ?? "";
          multiply44.text = data['data']['multiply_ration_44'] ?? "";
          multiply45.text = data['data']['multiply_ration_45'] ?? "";
          multiply46.text = data['data']['multiply_ration_46'] ?? "";
          multiply47.text = data['data']['multiply_ration_47'] ?? "";
          multiply48.text = data['data']['multiply_ration_48'] ?? "";
          multiply49.text = data['data']['multiply_ration_49'] ?? "";
          multiply50.text = data['data']['multiply_ration_50'] ?? "";

          isAPIcalled = false;
        });
      }
    } else {
      setState(() {
        isAPIcalled = false;
      });
      showtoast("Server Error", context);
    }
  }

  @override
  void initState() {
    super.initState();
    _getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Margin Configuration",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 15),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4A90E2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: _updateMarginConfig,
              child: Text(
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
      body: isAPIcalled
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4A90E2),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1E293B),
                          Color(0xFF0F172A),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFF2D3548),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF4A90E2).withOpacity(0.3),
                                    Color(0xFF4A90E2).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "Margin Call Drop",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF4A90E2).withOpacity(0.3),
                                    Color(0xFF4A90E2).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "Multiply Ratio",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Visibility(
                          visible: (widget.calllimit < 1) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget("First Call", marginfirstCall,
                                  multiplyfirstCall)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 2) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget("2nd Call",
                                  marginsecoundndcall, multiplysecoundndcall)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 3) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "3rd Call", marginthird, multiplythird)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 4) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "4th Call", marginforth, multiplyforth)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 5) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "5th Call", marginfivth, multiplyfivth)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 6) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "6th Call", marginsix, multiplysix)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 7) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "7th Call", marginseven, multiplyseven)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 8) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "8th Call", margineigth, multiplyeigth)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 9) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "9th Call", marginnine, multiplynine)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 10) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "10th Call", marginten, multiplyten)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 11) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "11th Call", margineleven, multiplyleven)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 12) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "12th Call", margintwel, multiplytwel)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 13) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget("13th Call", marginthirteen,
                                  multiplythirteen)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 14) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "14th Call", marginforteen, multiplyforteen)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 15) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "15th Call", marginfivteen, multiplyfivteen)),
                        ),
                        // ------------------------------------------------------------------------
                        Visibility(
                          visible: (widget.calllimit < 16) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "16th Call", marginsixteen, multiply16)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 17) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "17th Call", marginseventeen, multiply17)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 18) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "18th Call", margineigteen, multiply18)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 19) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "19th Call", marginnineteen, multiply19)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 20) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "20 Call", margintwentry, multiply20)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 21) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "21 Call", margin21, multiply21)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 22) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "22th Call", margin22, multiply22)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 23) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "23th Call", margin23, multiply23)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 24) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "24th Call", margin24, multiply24)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 25) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "25th Call", margin25, multiply25)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 26) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "26th Call", margin26, multiply26)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 27) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "27th Call", margin27, multiply27)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 28) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "28th Call", margin28, multiply28)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 29) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "29th Call", margin29, multiply29)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 30) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "30th Call", margin30, multiply30)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 31) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "31 Call", margin31, multiply31)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 32) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "32th Call", margin32, multiply32)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 33) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "33th Call", margin33, multiply33)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 34) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "34th Call", margin34, multiply34)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 35) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "35th Call", margin35, multiply35)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 36) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "36th Call", margin36, multiply36)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 37) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "37th Call", margin37, multiply37)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 38) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "38th Call", margin38, multiply38)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 39) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "39th Call", margin39, multiply39)),
                        ),

                        Visibility(
                          visible: (widget.calllimit < 40) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "40th Call", margin40, multiply40)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 41) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "41th Call", margin41, multiply41)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 42) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "42th Call", margin42, multiply42)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 43) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "43th Call", margin43, multiply43)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 44) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "44th Call", margin44, multiply44)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 45) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "45th Call", margin45, multiply45)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 46) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "46th Call", margin46, multiply46)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 47) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "47th Call", margin47, multiply47)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 48) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "48th Call", margin48, multiply48)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 49) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "49th Call", margin49, multiply49)),
                        ),
                        Visibility(
                          visible: (widget.calllimit < 50) ? false : true,
                          child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              child: commonWidget(
                                  "50th Call", margin50, multiply50)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget commonWidget(String id, TextEditingController controller,
      TextEditingController multipleycontroller) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Color(0xFF2D3548),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            id,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF1A2234),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Color(0xFF2D3548),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          textAlign: TextAlign.center,
                          controller: controller,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "0.00",
                            hintStyle: TextStyle(color: Colors.white30),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '%',
                          style: TextStyle(
                            color: Color(0xFF4A90E2),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF1A2234),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Color(0xFF2D3548),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    textAlign: TextAlign.center,
                    controller: multipleycontroller,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "0.00",
                      hintStyle: TextStyle(color: Colors.white30),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _updateMarginConfig() async {
    showLoading(context);
    try {
      var bodydata = jsonEncode({
        "user_id": commonuserId,
        "assets_type": widget.coinname,
        "margin_drop_1": marginfirstCall.text,
        "margin_drop_2": marginsecoundndcall.text,
        "margin_drop_3": marginthird.text,
        "margin_drop_4": marginforth.text,
        "margin_drop_5": marginfivth.text,
        "margin_drop_6": marginsix.text,
        "margin_drop_7": marginseven.text,
        "margin_drop_8": margineigth.text,
        "margin_drop_9": marginnine.text,
        "margin_drop_10": marginten.text,
        "margin_drop_11": margineleven.text,
        "margin_drop_12": margintwel.text,
        "margin_drop_13": marginthirteen.text,
        "margin_drop_14": marginforteen.text,
        "margin_drop_15": marginfivteen.text,
        "margin_drop_16": marginsixteen.text,
        "margin_drop_17": marginseventeen.text,
        "margin_drop_18": margineigteen.text,
        "margin_drop_19": marginnineteen.text,
        "margin_drop_20": margintwentry.text,
        "margin_drop_21": margin21.text,
        "margin_drop_22": margin22.text,
        "margin_drop_23": margin23.text,
        "margin_drop_24": margin24.text,
        "margin_drop_25": margin25.text,
        "margin_drop_26": margin26.text,
        "margin_drop_27": margin27.text,
        "margin_drop_28": margin28.text,
        "margin_drop_29": margin29.text,
        "margin_drop_30": margin30.text,
        "margin_drop_31": margin31.text,
        "margin_drop_32": margin32.text,
        "margin_drop_33": margin33.text,
        "margin_drop_34": margin34.text,
        "margin_drop_35": margin35.text,
        "margin_drop_36": margin36.text,
        "margin_drop_37": margin37.text,
        "margin_drop_38": margin38.text,
        "margin_drop_39": margin39.text,
        "margin_drop_40": margin40.text,
        "margin_drop_41": margin41.text,
        "margin_drop_42": margin42.text,
        "margin_drop_43": margin43.text,
        "margin_drop_44": margin44.text,
        "margin_drop_45": margin45.text,
        "margin_drop_46": margin46.text,
        "margin_drop_47": margin47.text,
        "margin_drop_48": margin48.text,
        "margin_drop_49": margin49.text,
        "margin_drop_50": margin50.text,
        "multiply_ration_1": multiplyfirstCall.text,
        "multiply_ration_2": multiplysecoundndcall.text,
        "multiply_ration_3": multiplythird.text,
        "multiply_ration_4": multiplyforth.text,
        "multiply_ration_5": multiplyfivth.text,
        "multiply_ration_6": multiplysix.text,
        "multiply_ration_7": multiplyseven.text,
        "multiply_ration_8": multiplyeigth.text,
        "multiply_ration_9": multiplynine.text,
        "multiply_ration_10": multiplyten.text,
        "multiply_ration_11": multiplyleven.text,
        "multiply_ration_12": multiplytwel.text,
        "multiply_ration_13": multiplythirteen.text,
        "multiply_ration_14": multiplyforteen.text,
        "multiply_ration_15": multiplyfivteen.text,
        "multiply_ration_16": multiply16.text,
        "multiply_ration_17": multiply17.text,
        "multiply_ration_18": multiply18.text,
        "multiply_ration_19": multiply19.text,
        "multiply_ration_20": multiply20.text,
        "multiply_ration_21": multiply21.text,
        "multiply_ration_22": multiply22.text,
        "multiply_ration_23": multiply23.text,
        "multiply_ration_24": multiply24.text,
        "multiply_ration_25": multiply25.text,
        "multiply_ration_26": multiply26.text,
        "multiply_ration_27": multiply27.text,
        "multiply_ration_28": multiply28.text,
        "multiply_ration_29": multiply29.text,
        "multiply_ration_30": multiply30.text,
        "multiply_ration_31": multiply31.text,
        "multiply_ration_32": multiply32.text,
        "multiply_ration_33": multiply33.text,
        "multiply_ration_34": multiply34.text,
        "multiply_ration_35": multiply35.text,
        "multiply_ration_36": multiply36.text,
        "multiply_ration_37": multiply37.text,
        "multiply_ration_38": multiply38.text,
        "multiply_ration_39": multiply39.text,
        "multiply_ration_40": multiply40.text,
        "multiply_ration_41": multiply41.text,
        "multiply_ration_42": multiply42.text,
        "multiply_ration_43": multiply43.text,
        "multiply_ration_44": multiply44.text,
        "multiply_ration_45": multiply45.text,
        "multiply_ration_46": multiply46.text,
        "multiply_ration_47": multiply47.text,
        "multiply_ration_48": multiply48.text,
        "multiply_ration_49": multiply49.text,
        "multiply_ration_50": multiply50.text,
        "exchange_type": exchanger
      });
      print(bodydata);
      final res =
          await http.post(Uri.parse(tradeSettingUpdatesubbin), body: bodydata);
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        // print(data);
        if (data['status'] == "success") {
          showtoast(data['message'], context);
          Navigator.pop(context);
          Navigator.pop(context);
        } else {
          showtoast(data['message'], context);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print(e);
    }
  }
}
