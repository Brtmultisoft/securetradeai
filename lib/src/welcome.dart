import 'dart:async';
import 'dart:convert';
import 'package:securetradeai/data/strings.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/src/versionpopup/popupdesign.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/api.dart';
import '../method/methods.dart';
import '../model/MineModel.dart';
import 'user/login.dart';

// Define the MineData class
class MineData {
  final String status;
  final List<dynamic> data;

  MineData({required this.status, required this.data});
}

class WelcomePage extends StatefulWidget {
  WelcomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  double avlBalance = 0.0;
  double minbalance = 0.0;
  var minedata = [];
  bool checkbalance = false;

  // Method to launch URL in browser
  Future<void> _launchURL(String url) async {
    try {
      print('🌐 LAUNCHING URL: $url');
      final Uri uri = Uri.parse(url);
      print('🔗 Parsed URI: $uri');

      if (await canLaunchUrl(uri)) {
        print('✅ URL can be launched, opening in external browser...');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('🚀 URL launched successfully');
      } else {
        print('❌ Could not launch URL: $url');
        print('⚠️ URL launcher failed - URL may be invalid or no browser available');
      }
    } catch (e) {
      print('❌ Error launching URL: $e');
      print('🔍 Exception details: ${e.toString()}');
    }
  }

  Future _getAppInfo() async {
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
      final res = await http.get(Uri.parse(getversion))
          .timeout(Duration(seconds: 10), onTimeout: () {
        print('⚠️ Version check timed out after 10 seconds, proceeding to login');
        return http.Response('{"status":"timeout"}', 408);
      });

      print('📡 HTTP Status Code: ${res.statusCode}');
      print('📡 Response Headers: ${res.headers}');
      print('🌐 Raw API Response: ${res.body}');

      if (res.statusCode != 200) {
        print('❌ Version check failed with HTTP status: ${res.statusCode}');
        print('⚠️ Proceeding to login due to API failure');
        _proceedToLogin();
        return;
      }

      var jsondata = jsonDecode(res.body);
      print('📋 Parsed JSON data: $jsondata');

      if (jsondata['status'] == "success") {
        String serverVersion = jsondata['version'].toString();
        String currentVersion = packageInfo.version.toString();

        print('🔍 VERSION COMPARISON:');
        print('   📦 Server version: "$serverVersion"');
        print('   📱 Current version: "$currentVersion"');
        print('   🔄 Versions match: ${serverVersion == currentVersion}');

        // Fixed version check logic
        if (serverVersion != currentVersion) {
          print('🚨 UPDATE REQUIRED!');
          print('   ⬆️ Server has version: $serverVersion');
          print('   📱 App has version: $currentVersion');
          print('   🔔 Showing update dialog...');

          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return CustomDialogBox(
                  title: "Update Now",
                  descriptions:
                      "New update available, Please update before Use.",
                  text: "Download Latest Version",
                  onclick: () {
                    print('🌐 User clicked update button, redirecting to website...');
                    // Redirect to website for download instead of app store
                    _launchURL('https://securetradeai.com');
                  },
                );
              });
        } else {
          print('✅ VERSION CHECK PASSED!');
          print('   📱 App is up to date with version: $currentVersion');
          print('   ➡️ Proceeding to login...');
          _proceedToLogin();
        }
      } else {
        print('❌ API returned error status: ${jsondata['status']}');
        print('📋 Full response: $jsondata');
        print('⚠️ Proceeding to login despite version check failure');
        _proceedToLogin();
      }
    } catch (e) {
      print('❌ Error in version check: $e');
      _proceedToLogin();
    }
  }
  
  // Helper method to proceed to login
  void _proceedToLogin() {
    if (mounted) {
      Timer(
          const Duration(seconds: 1),
          () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const LoginPage())));
    }
  }

  _getbalace() async {
    try {
      final res = await http.post(Uri.parse(getIp),
          body: json.encode({"user_id": commonuserId}))
          .timeout(Duration(seconds: 10), onTimeout: () {
        print('⚠️ Balance check timed out');
        return http.Response('{"status":"timeout"}', 408);
      });
      
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print('💰 Balance data: $data');
        if (data['status'] == "success") {
          setState(() {
            minbalance =
                double.parse(data['data']['admin_details']['min_wallet']);
          });
        } else {
          print('⚠️ Balance check failed: ${data['message']}');
        }
      } else {
        print('⚠️ Server Error in balance check: ${res.statusCode}');
      }
    } catch (e) {
      print('❌ Error in balance check: $e');
    }
  }

  _getusdBalance() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      if (!pref.containsKey('userid')) {
        print("⚠️ No user ID found in preferences");
        return;
      }
      
      setState(() {
        commonuserId = pref.getString('userid').toString();
      });
      
      print('🔍 Fetching USD balance for user: $commonuserId');
      
      // Use a try-catch with timeout to prevent hanging
      try {
        final data = await CommonMethod().getMineData()
            .timeout(Duration(seconds: 10), onTimeout: () {
          print('⚠️ USD balance check timed out');
          return Mine(
            status: "timeout",
            message: "Request timed out",
            responsecode: "408",
            data: []
          );
        });
        
        if (data.status == "success" && data.data.isNotEmpty) {
          setState(() {
            minedata = data.data;
            for (var element in minedata) {
              try {
                avlBalance = double.parse(element.gasBalance) +
                    double.parse(element.bonusBalance);
                print('💰 Available balance: $avlBalance');
              } catch (e) {
                print('⚠️ Error parsing balance values: $e');
              }
            }
          });
        } else {
          print('⚠️ USD balance check failed: ${data.status}');
        }
      } catch (e) {
        print('❌ Error in USD balance check: $e');
      }
    } catch (e) {
      print('❌ Error in _getusdBalance: $e');
    }
  }

  _commonMethod() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    print('💰 Balance check: $avlBalance, Min balance: $minbalance, Check balance: $checkbalance');
    if (pref.containsKey('userid')) {
      if (avlBalance < minbalance) {
        setState(() {
          checkbalance = true;
        });
      } else {
        setState(() {
          checkbalance = false;
        });
      }
    } else {
      setState(() {
        checkbalance = false;
      });
    }
  }

  _fatchData() async {
    print('📥 Starting data fetch...');
    
    // Add a timeout to the entire data fetch process
    try {
      await Future.any([
        _fetchDataWithTimeout(),
        Future.delayed(Duration(seconds: 15)).then((_) {
          print('⚠️ Data fetch timed out, proceeding to login');
          _proceedToLogin();
          return null;
        })
      ]);
    } catch (e) {
      print('❌ Error in data fetch: $e');
      _proceedToLogin();
    }
  }
  
  Future<void> _fetchDataWithTimeout() async {
    // Run each operation individually with its own error handling
    try {
      await _getbalace();
    } catch (e) {
      print('❌ Error in balance check: $e');
    }
    
    try {
      await _getusdBalance();
    } catch (e) {
      print('❌ Error in USD balance check: $e');
    }
    
    try {
      await _commonMethod();
    } catch (e) {
      print('❌ Error in common method: $e');
    }
    
    // Check app version and proceed to login
    try {
      await _getAppInfo();
    } catch (e) {
      print('❌ Error in app version check: $e');
      // If there's an error, still proceed to login
      _proceedToLogin();
    }
    
    print('✅ Data fetch completed');
  }

  @override
  void initState() {
    super.initState();
    print('🚀 Welcome page initialized');
    _fatchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      // bottomSheet: Container(
      //   alignment: Alignment.center,
      //   height: 40,
      //   child: CupertinoActivityIndicator(color: securetradeaicolor),
      // ),
      body: Image.asset(
        "assets/img/kbsplash.gif",
        fit: BoxFit.cover, // Use BoxFit.cover to fill both width and height
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context)
            .size
            .width, // Add width to match the screen width
      ),
    );
  }
}
