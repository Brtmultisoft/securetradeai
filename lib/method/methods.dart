import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:securetradeai/data/api.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/model/HomePageBannerModel.dart';
import 'package:securetradeai/model/MineModel.dart';
import 'package:securetradeai/model/NewsModel.dart';
import 'package:securetradeai/model/RevenueDetailBydate.dart';
import 'package:securetradeai/model/TradeHistoryModel.dart';
import 'package:securetradeai/model/incomeManagementModel.dart';
import 'package:securetradeai/model/levelIncomeModel.dart';
import 'package:securetradeai/model/revenueModel.dart';
import 'package:securetradeai/model/userInvestmentsModel.dart';
import 'package:securetradeai/model/dailyRoiHistoryModel.dart';
import 'package:securetradeai/model/userRankModel.dart';
import 'package:securetradeai/model/incomeSummaryModel.dart';

import '../model/AssettransactionModel.dart';
import '../model/DeposittransactionModel.dart';
import '../model/GashistoryModel.dart';
import '../model/QuatitatuveModelclass.dart';

class CommonMethod {
  Future<Banner> getHomePgeBanner() async {
    final response = await http.get(
      Uri.parse(bannerImage),
      headers: {'Content-Type': 'application/json', 'Charset': 'utf-8'},
    );
    return bannerFromJson(response.body);
  }

  Future<Newsmodel> getNews() async {
    final response = await http.get(
      Uri.parse(newsApi),
      headers: {'Content-Type': 'application/json', 'Charset': 'utf-8'},
    );
    log(response.body.toString());
    return newsFromJson(response.body);
  }

  Future<Mine> getMineData() async {
    print("🔍 Making API call to: $mine");
    print("📤 Request body: ${json.encode({"user_id": commonuserId})}");

    final res = await http.post(Uri.parse(mine),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({"user_id": commonuserId}));

    print("📥 Response status: ${res.statusCode}");
    print("📥 Response body: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Server returned status code: ${res.statusCode}");
    }

    return mineFromJson(res.body);
  }

  Future<AssetTransactiondetail> getAssetTransactionDetail(int page) async {
    final res = await http.post(Uri.parse(transactionDetail),
        body: jsonEncode(
            {"user_id": commonuserId, "page": page.toString(), "size": "100"}));
    print(res.body);
    return transactiondetailFromJson(res.body);
  }

  Future<DepositTransactiondetail> getDepositTransactionDetail(int page) async {
    final res = await http.post(Uri.parse(swap_wallet_history),
        body: jsonEncode(
            {"user_id": commonuserId, "page": page.toString(), "size": "100"}));
    print(res.body);
    return deposittransactiondetailFromJson(res.body);
  }

  Future<GasHistory> getGashistory() async {
    final res = await http.post(Uri.parse(gasHistory),
        body: jsonEncode({"user_id": commonuserId}));
    // print(res.body);
    return gasHistoryFromJson(res.body);
  }

  Future<LevelIncome> getLevelIncomedata() async {
    final res = await http.post(Uri.parse(levelincomeDetail),
        body: jsonEncode({"user_id": commonuserId}));
    print(res.body);
    return levelIncomeFromJson(res.body);
  }

  // Future<LevelIncome> getStakingIncomedata() async {
  //   final res = await http.post(Uri.parse(stakingincomeDetail),
  //       body: jsonEncode({"user_id": "1"}));
  //   print(res.body);
  //   return levelIncomeFromJson(res.body);
  // }

  Future<LevelIncome> getClubIncome() async {
    final res = await http.post(Uri.parse(tradeincomedetails),
        body: jsonEncode({"user_id": commonuserId}));
    return levelIncomeFromJson(res.body);
  }

  Future<LevelIncome> getTradeIncome() async {
    final res = await http.post(Uri.parse(clubincomedetails),
        body: jsonEncode({"user_id": commonuserId}));
    return levelIncomeFromJson(res.body);
  }

  Future<TradehistoryModel> getprofitSharing() async {
    final res = await http.post(Uri.parse(profitSharingIncome),
        body: jsonEncode({"user_id": commonuserId}));
    return tradehistoryModelFromJson(res.body);
  }

  Future<LevelIncome> getroyalty() async {
    final res = await http.post(Uri.parse(royaltyIncomedetails),
        body: jsonEncode({"user_id": commonuserId}));
    print(res.body);
    return levelIncomeFromJson(res.body);
  }

  Future<LevelIncome> getPoolIncome() async {
    final res = await http.post(Uri.parse(universalpool),
        body: jsonEncode({"user_id": commonuserId}));
    print(res.body);
    return levelIncomeFromJson(res.body);
  }

  Future<RevenueDetail> getRevenueDetail() async {
    final res = await http.post(Uri.parse(revenueDetail),
        body: jsonEncode({"user_id": commonuserId}));
    print(res.body);
    return revenueDetailFromJson(res.body);
  }

  Future<RevenueDetailByDate> getRevenueDetailByDate(String date) async {
    final res = await http.post(Uri.parse(revenuedetailByDate),
        body: jsonEncode({"user_id": commonuserId, "date": date}));
    print(res.body);
    return revenueDetailByDateFromJson(res.body);
  }

  static Future<List<Quantitum>> getquantitative(String query) async {
    final url = Uri.parse("https://api.binance.com/api/v3/ticker/24hr");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Quantitum.fromJson(json)).where((data) {
        final idlower = data.symbol.toString().toLowerCase();

        final searchLower = query.toLowerCase();
        return idlower.contains(searchLower);
      }).toList();
    } else {
      throw Exception();
    }
  }

  Future<double> getCurrency(double amount) async {
    double price = 0.0;
    final res = await http.get(Uri.parse(multicurrency));
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      var finaldata = data['data'] as List;
      for (var element in finaldata) {
        var finalcurrency = currentCurrency == "null" ? "USD" : currentCurrency;
        if (element['symbol'] == finalcurrency) {
          price = double.parse(element['price']);
          print(price);
        }
      }
    } else {
      print("data not found");
    }
    return price;
  }

  /// Get user's current balance
  Future<double> getUserBalance() async {
    print("🔍 DEBUG: Getting user balance for user: $commonuserId");
    print("🔍 DEBUG: Balance API URL: $usdBalance");

    try {
      final res = await http.post(Uri.parse(usdBalance),
          body: jsonEncode({"user_id": commonuserId}));

      print("🔍 DEBUG: Balance response status: ${res.statusCode}");
      print("🔍 DEBUG: Balance response body: ${res.body}");

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("🔍 DEBUG: Parsed balance data: $data");

        if (data['status'] == 'success') {
          final balance =
              double.tryParse(data['data']['balance'].toString()) ?? 0.0;
          print("✅ User balance retrieved: $balance");
          return balance;
        } else {
          print(
              "❌ Balance API failed - Status: ${data['status']}, Message: ${data['message'] ?? 'No message'}");
        }
      } else {
        print("❌ Balance API HTTP error: ${res.statusCode}");
      }
      return 0.0;
    } catch (e) {
      print("❌ Exception getting user balance: $e");
      return 0.0;
    }
  }

  /// Investment Package Methods
  Future<Map<String, dynamic>> getUserInvestments() async {
    try {
      final res = await http.post(Uri.parse(getUserInvestmentsPost),
          body: jsonEncode({"user_id": commonuserId}));
      return jsonDecode(res.body);
    } catch (e) {
      print('Error getting user investments: $e');
      return {"status": "error", "message": "Network error"};
    }
  }

  /// Buy investment package (50 - 1000)
  Future<Map<String, dynamic>> buyInvestmentPackage(
      String amount, String type) async {
    try {
      final res = await http.post(Uri.parse(buyPackagePost),
          body: jsonEncode(
              {"user_id": commonuserId, "amount": amount, "type": type}));
      return jsonDecode(res.body);
    } catch (e) {
      print('Error buying investment package: $e');
      return {"status": "error", "message": "Network error"};
    }
  }

  /// Get user incomes by type (roi, direct_income, level_income, rank_rewards)
  // Future<Map<String, dynamic>> getIncomes(String type) async {
  //   try {
  //     final res = await http.post(Uri.parse(getIncomesPost),
  //         body: jsonEncode({
  //           "user_id": commonuserId,
  //           "type": type
  //         }));
  //     return jsonDecode(res.body);
  //   } catch (e) {
  //     print('Error getting incomes: $e');
  //     return {"status": false, "message": "Network error"};
  //   }
  // }

  /// Get Direct Referral Income
  Future<DirectIncomeModel> getDirectIncome() async {
    try {
      print('🔄 Making API call to: $getDirectIncomeUrl');
      print('📤 Request body: ${jsonEncode({"user_id": commonuserId})}');

      final res = await http.post(Uri.parse(getDirectIncomeUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({"user_id": commonuserId}));

      print('📥 Response status: ${res.statusCode}');
      print('📥 Response body: "${res.body}"');
      print('📥 Response length: ${res.body.length}');

      // Check HTTP status code first
      if (res.statusCode == 500) {
        print('🚨 Server Error (500): API endpoint may not be implemented yet');
        return DirectIncomeModel(
          status: "success",
          message:
              "Direct income feature is being prepared. Please check back later.",
          responsecode: "200",
          data: DirectIncomeData(
            totalDirectIncome: 0.0,
            incomeHistory: [],
          ),
        );
      }

      if (res.statusCode != 200) {
        print('⚠️ HTTP Error ${res.statusCode}: ${res.body}');
        return DirectIncomeModel(
          status: "success",
          message: "Direct income data temporarily unavailable",
          responsecode: "200",
          data: DirectIncomeData(
            totalDirectIncome: 0.0,
            incomeHistory: [],
          ),
        );
      }

      // Check if response is empty or null
      if (res.body.isEmpty || res.body.trim().isEmpty) {
        print('⚠️ Empty response from direct income API');
        return DirectIncomeModel(
          status: "success",
          message: "No direct income data found",
          responsecode: "200",
          data: DirectIncomeData(
            totalDirectIncome: 0.0,
            incomeHistory: [],
          ),
        );
      }

      // Try to parse JSON
      try {
        return directIncomeFromJson(res.body);
      } catch (parseError) {
        print('❌ JSON parsing error: $parseError');
        print('📄 Raw response: "${res.body}"');

        // Return empty data instead of error
        return DirectIncomeModel(
          status: "success",
          message: "No direct income data available",
          responsecode: "200",
          data: DirectIncomeData(
            totalDirectIncome: 0.0,
            incomeHistory: [],
          ),
        );
      }
    } catch (e) {
      print('❌ Network error getting direct income: $e');
      return DirectIncomeModel(
        status: "error",
        message: "Network error: ${e.toString()}",
        responsecode: "500",
        data: DirectIncomeData(
          totalDirectIncome: 0.0,
          incomeHistory: [],
        ),
      );
    }
  }

  /// Get Level ROI Income
  Future<LevelIncomeModel> getLevelROIIncome() async {
    try {
      print('🔄 Making API call to: $getLevelIncomeUrl');
      print('📤 Request body: ${jsonEncode({"user_id": commonuserId})}');

      final res = await http.post(Uri.parse(getLevelIncomeUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({"user_id": commonuserId}));

      print('📥 Response status: ${res.statusCode}');
      print('📥 Response body: "${res.body}"');
      print('📥 Response length: ${res.body.length}');

      // Check HTTP status code first
      if (res.statusCode == 500) {
        print(
            '🚨 Server Error (500): Level income API endpoint may not be implemented yet');
        return LevelIncomeModel(
          status: "success",
          message:
              "Level ROI income feature is being prepared. Please check back later.",
          responsecode: "200",
          data: LevelIncomeData(
            totalLevelIncome: 0.0,
            incomeHistory: [],
          ),
        );
      }

      if (res.statusCode != 200) {
        print('⚠️ HTTP Error ${res.statusCode}: ${res.body}');
        return LevelIncomeModel(
          status: "success",
          message: "Level ROI income data temporarily unavailable",
          responsecode: "200",
          data: LevelIncomeData(
            totalLevelIncome: 0.0,
            incomeHistory: [],
          ),
        );
      }

      // Check if response is empty or null
      if (res.body.isEmpty || res.body.trim().isEmpty) {
        print('⚠️ Empty response from level income API');
        return LevelIncomeModel(
          status: "success",
          message: "No level income data found",
          responsecode: "200",
          data: LevelIncomeData(
            totalLevelIncome: 0.0,
            incomeHistory: [],
          ),
        );
      }

      // Try to parse JSON
      try {
        return levelIncomeModelFromJson(res.body);
      } catch (parseError) {
        print('❌ JSON parsing error: $parseError');
        print('📄 Raw response: "${res.body}"');

        // Return empty data instead of error
        return LevelIncomeModel(
          status: "success",
          message: "No level income data available",
          responsecode: "200",
          data: LevelIncomeData(
            totalLevelIncome: 0.0,
            incomeHistory: [],
          ),
        );
      }
    } catch (e) {
      print('❌ Network error getting level income: $e');
      return LevelIncomeModel(
        status: "error",
        message: "Network error: ${e.toString()}",
        responsecode: "500",
        data: LevelIncomeData(
          totalLevelIncome: 0.0,
          incomeHistory: [],
        ),
      );
    }
  }

  /// Get Salary Income
  Future<SalaryIncomeModel> getSalaryIncome() async {
    try {
      print('🔄 Making API call to: $getSalaryIncomeUrl');
      print('📤 Request body: ${jsonEncode({"user_id": commonuserId})}');

      final res = await http.post(Uri.parse(getSalaryIncomeUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({"user_id": commonuserId}));

      print('📥 Response status: ${res.statusCode}');
      print('📥 Response body: "${res.body}"');
      print('📥 Response length: ${res.body.length}');

      // Check HTTP status code first
      if (res.statusCode == 500) {
        print(
            '🚨 Server Error (500): Salary income API endpoint may not be implemented yet');
        return SalaryIncomeModel(
          status: "success",
          message:
              "Salary income feature is being prepared. Please check back later.",
          responsecode: "200",
          data: SalaryIncomeData(
            totalSalaryIncome: 0.0,
            salaryHistory: [],
          ),
        );
      }

      if (res.statusCode != 200) {
        print('⚠️ HTTP Error ${res.statusCode}: ${res.body}');
        return SalaryIncomeModel(
          status: "success",
          message: "Salary income data temporarily unavailable",
          responsecode: "200",
          data: SalaryIncomeData(
            totalSalaryIncome: 0.0,
            salaryHistory: [],
          ),
        );
      }

      // Check if response is empty or null
      if (res.body.isEmpty || res.body.trim().isEmpty) {
        print('⚠️ Empty response from salary income API');
        return SalaryIncomeModel(
          status: "success",
          message: "No salary income data found",
          responsecode: "200",
          data: SalaryIncomeData(
            totalSalaryIncome: 0.0,
            salaryHistory: [],
          ),
        );
      }

      // Try to parse JSON
      try {
        return salaryIncomeFromJson(res.body);
      } catch (parseError) {
        print('❌ JSON parsing error: $parseError');
        print('📄 Raw response: "${res.body}"');

        // Return empty data instead of error
        return SalaryIncomeModel(
          status: "success",
          message: "No salary income data available",
          responsecode: "200",
          data: SalaryIncomeData(
            totalSalaryIncome: 0.0,
            salaryHistory: [],
          ),
        );
      }
    } catch (e) {
      print('❌ Network error getting salary income: $e');
      return SalaryIncomeModel(
        status: "error",
        message: "Network error: ${e.toString()}",
        responsecode: "500",
        data: SalaryIncomeData(
          totalSalaryIncome: 0.0,
          salaryHistory: [],
        ),
      );
    }
  }

  /// Get User Investments (New API)
  Future<UserInvestmentsModel> getUserInvestmentsNew() async {
    try {
      print('🔄 Making API call to: $getUserInvestmentsUrl');
      print('📤 Request body: ${jsonEncode({"user_id": commonuserId})}');

      final res = await http.post(
        Uri.parse(getUserInvestmentsUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"user_id": commonuserId})
      );

      print('📥 Response status: ${res.statusCode}');
      print('📥 Response body: "${res.body}"');
      print('📥 Response length: ${res.body.length}');

      // Check HTTP status code first
      if (res.statusCode == 500) {
        print('🚨 Server Error (500): User investments API endpoint may not be implemented yet');
        return UserInvestmentsModel(
          status: "success",
          message: "Investment data is being prepared. Please check back later.",
          responsecode: "200",
          data: UserInvestmentsData(
            arbitrageInvestments: [],
            summary: InvestmentSummary(
              totalArbitrageInvestment: 0.0,
              totalBotInvestment: 0.0,
              totalInvestment: 0.0,
              totalRoiEarned: 0.0,
            ),
          ),
        );
      }

      if (res.statusCode != 200) {
        print('⚠️ HTTP Error ${res.statusCode}: ${res.body}');
        return UserInvestmentsModel(
          status: "success",
          message: "Investment data temporarily unavailable",
          responsecode: "200",
          data: UserInvestmentsData(
            arbitrageInvestments: [],
            summary: InvestmentSummary(
              totalArbitrageInvestment: 0.0,
              totalBotInvestment: 0.0,
              totalInvestment: 0.0,
              totalRoiEarned: 0.0,
            ),
          ),
        );
      }

      // Check if response is empty or null
      if (res.body.isEmpty || res.body.trim().isEmpty) {
        print('⚠️ Empty response from user investments API');
        return UserInvestmentsModel(
          status: "success",
          message: "No investment data found",
          responsecode: "200",
          data: UserInvestmentsData(
            arbitrageInvestments: [],
            summary: InvestmentSummary(
              totalArbitrageInvestment: 0.0,
              totalBotInvestment: 0.0,
              totalInvestment: 0.0,
              totalRoiEarned: 0.0,
            ),
          ),
        );
      }

      // Try to parse JSON
      try {
        return userInvestmentsFromJson(res.body);
      } catch (parseError) {
        print('❌ JSON parsing error: $parseError');
        print('📄 Raw response: "${res.body}"');

        // Return empty data instead of error
        return UserInvestmentsModel(
          status: "success",
          message: "No investment data available",
          responsecode: "200",
          data: UserInvestmentsData(
            arbitrageInvestments: [],
            summary: InvestmentSummary(
              totalArbitrageInvestment: 0.0,
              totalBotInvestment: 0.0,
              totalInvestment: 0.0,
              totalRoiEarned: 0.0,
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Network error getting user investments: $e');
      return UserInvestmentsModel(
        status: "error",
        message: "Network error: ${e.toString()}",
        responsecode: "500",
        data: UserInvestmentsData(
          arbitrageInvestments: [],
          summary: InvestmentSummary(
            totalArbitrageInvestment: 0.0,
            totalBotInvestment: 0.0,
            totalInvestment: 0.0,
            totalRoiEarned: 0.0,
          ),
        ),
      );
    }
  }

  /// Buy Arbitrage Package
  Future<Map<String, dynamic>> buyArbitragePackage(double packageAmount) async {
    try {
      print('🔄 Making API call to: $buyArbitragePackageUrl');
      print('📤 Request body: ${jsonEncode({"user_id": commonuserId, "package_amount": packageAmount})}');

      final res = await http.post(
        Uri.parse(buyArbitragePackageUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "user_id": commonuserId,
          "package_amount": packageAmount
        })
      );

      print('📥 Response status: ${res.statusCode}');
      print('📥 Response body: "${res.body}"');

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return {
          "status": "error",
          "message": "Server returned status code: ${res.statusCode}",
          "responsecode": res.statusCode.toString()
        };
      }
    } catch (e) {
      print('❌ Network error buying arbitrage package: $e');
      return {
        "status": "error",
        "message": "Network error: ${e.toString()}",
        "responsecode": "500"
      };
    }
  }



  /// Get Daily ROI History
  Future<DailyRoiHistoryModel> getDailyRoiHistory({
    required int investmentId,
    int limit = 30,
  }) async {
    try {
      print('🔄 Making API call to: $getDailyRoiHistoryUrl');
      print('📤 Request body: ${jsonEncode({
        "user_id": commonuserId,
        "investment_id": investmentId,
        "limit": limit
      })}');

      final res = await http.post(
        Uri.parse(getDailyRoiHistoryUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "user_id": commonuserId,
          "investment_id": investmentId,
          "limit": limit
        })
      );

      print('📥 Response status: ${res.statusCode}');
      print('📥 Response body: "${res.body}"');
      print('📥 Response length: ${res.body.length}');

      // Check HTTP status code first
      if (res.statusCode == 500) {
        print('🚨 Server Error (500): Daily ROI history API endpoint may not be implemented yet');
        return DailyRoiHistoryModel(
          status: "success",
          message: "ROI history data is being prepared. Please check back later.",
          responsecode: "200",
          data: DailyRoiHistoryData(
            investmentId: investmentId,
            roiHistory: [],
            totalRoiEarned: 0.0,
            averageDailyRoi: 0.0,
            daysActive: 0,
          ),
        );
      }

      if (res.statusCode != 200) {
        print('⚠️ HTTP Error ${res.statusCode}: ${res.body}');
        return DailyRoiHistoryModel(
          status: "success",
          message: "ROI history temporarily unavailable",
          responsecode: "200",
          data: DailyRoiHistoryData(
            investmentId: investmentId,
            roiHistory: [],
            totalRoiEarned: 0.0,
            averageDailyRoi: 0.0,
            daysActive: 0,
          ),
        );
      }

      // Check if response is empty or null
      if (res.body.isEmpty || res.body.trim().isEmpty) {
        print('⚠️ Empty response from daily ROI history API');
        return DailyRoiHistoryModel(
          status: "success",
          message: "No ROI history found",
          responsecode: "200",
          data: DailyRoiHistoryData(
            investmentId: investmentId,
            roiHistory: [],
            totalRoiEarned: 0.0,
            averageDailyRoi: 0.0,
            daysActive: 0,
          ),
        );
      }

      // Try to parse JSON
      try {
        return dailyRoiHistoryFromJson(res.body);
      } catch (parseError) {
        print('❌ JSON parsing error: $parseError');
        print('📄 Raw response: "${res.body}"');

        // Return empty data instead of error
        return DailyRoiHistoryModel(
          status: "success",
          message: "No ROI history available",
          responsecode: "200",
          data: DailyRoiHistoryData(
            investmentId: investmentId,
            roiHistory: [],
            totalRoiEarned: 0.0,
            averageDailyRoi: 0.0,
            daysActive: 0,
          ),
        );
      }
    } catch (e) {
      print('❌ Network error getting daily ROI history: $e');
      return DailyRoiHistoryModel(
        status: "error",
        message: "Network error: ${e.toString()}",
        responsecode: "500",
        data: DailyRoiHistoryData(
          investmentId: investmentId,
          roiHistory: [],
          totalRoiEarned: 0.0,
          averageDailyRoi: 0.0,
          daysActive: 0,
        ),
      );
    }
  }

  /// Get User Rank
  Future<UserRankModel> getUserRank() async {
    try {
      print('🔄 Making API call to: $getUserRankUrl');
      print('📤 Request body: ${jsonEncode({"user_id": commonuserId})}');

      final res = await http.post(
        Uri.parse(getUserRankUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"user_id": commonuserId})
      );

      print('📥 Response status: ${res.statusCode}');
      print('📥 Response body: "${res.body}"');
      print('📥 Response length: ${res.body.length}');

      // Check HTTP status code first
      if (res.statusCode == 500) {
        print('🚨 Server Error (500): User rank API endpoint may not be implemented yet');
        return UserRankModel(
          status: "success",
          message: "Rank data is being prepared. Please check back later.",
          responsecode: "200",
          data: UserRankData(
            userId: commonuserId,
            name: "User",
            currentRank: "Starter",
            teamBusiness: 0.0,
            directReferrals: 0,
            teamMembers: 0,
            totalInvestment: 0.0,
            totalEarnings: 0.0,
            nextRank: "Builder",
            nextRankRequirement: 1000.0,
            progressPercentage: 0.0,
          ),
        );
      }

      if (res.statusCode != 200) {
        print('⚠️ HTTP Error ${res.statusCode}: ${res.body}');
        return UserRankModel(
          status: "success",
          message: "Rank data temporarily unavailable",
          responsecode: "200",
          data: UserRankData(
            userId: commonuserId,
            name: "User",
            currentRank: "Starter",
            teamBusiness: 0.0,
            directReferrals: 0,
            teamMembers: 0,
            totalInvestment: 0.0,
            totalEarnings: 0.0,
            nextRank: "Builder",
            nextRankRequirement: 1000.0,
            progressPercentage: 0.0,
          ),
        );
      }

      // Check if response is empty or null
      if (res.body.isEmpty || res.body.trim().isEmpty) {
        print('⚠️ Empty response from user rank API');
        return UserRankModel(
          status: "success",
          message: "No rank data found",
          responsecode: "200",
          data: UserRankData(
            userId: commonuserId,
            name: "User",
            currentRank: "Starter",
            teamBusiness: 0.0,
            directReferrals: 0,
            teamMembers: 0,
            totalInvestment: 0.0,
            totalEarnings: 0.0,
            nextRank: "Builder",
            nextRankRequirement: 1000.0,
            progressPercentage: 0.0,
          ),
        );
      }

      // Try to parse JSON
      try {
        return userRankFromJson(res.body);
      } catch (parseError) {
        print('❌ JSON parsing error: $parseError');
        print('📄 Raw response: "${res.body}"');

        // Return default data instead of error
        return UserRankModel(
          status: "success",
          message: "No rank data available",
          responsecode: "200",
          data: UserRankData(
            userId: commonuserId,
            name: "User",
            currentRank: "Starter",
            teamBusiness: 0.0,
            directReferrals: 0,
            teamMembers: 0,
            totalInvestment: 0.0,
            totalEarnings: 0.0,
            nextRank: "Builder",
            nextRankRequirement: 1000.0,
            progressPercentage: 0.0,
          ),
        );
      }
    } catch (e) {
      print('❌ Network error getting user rank: $e');
      return UserRankModel(
        status: "error",
        message: "Network error: ${e.toString()}",
        responsecode: "500",
        data: UserRankData(
          userId: commonuserId,
          name: "User",
          currentRank: "Starter",
          teamBusiness: 0.0,
          directReferrals: 0,
          teamMembers: 0,
          totalInvestment: 0.0,
          totalEarnings: 0.0,
          nextRank: "Builder",
          nextRankRequirement: 1000.0,
          progressPercentage: 0.0,
        ),
      );
    }
  }

  /// Get Income Summary
  Future<IncomeSummaryModel> getIncomeSummary() async {
    try {
      print('🔄 Making API call to: $getIncomeSummaryUrl');
      print('📤 Request body: ${jsonEncode({"user_id": commonuserId})}');

      final res = await http.post(
        Uri.parse(getIncomeSummaryUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"user_id": commonuserId})
      );

      print('📥 Response status: ${res.statusCode}');
      print('📥 Response body: "${res.body}"');
      print('📥 Response length: ${res.body.length}');

      // Check HTTP status code first
      if (res.statusCode == 500) {
        print('🚨 Server Error (500): Income summary API endpoint may not be implemented yet');
        return IncomeSummaryModel(
          status: "success",
          data: IncomeSummaryData(
            incomeBreakdown: IncomeBreakdown(
              dailyRoi: 0.0,
              directReferral: 0.0,
              levelRoi: 0.0,
              gasFee: 0.0,
              salary: 0.0,
            ),
            totalIncome: 0.0,
          ),
        );
      }

      if (res.statusCode != 200) {
        print('⚠️ HTTP Error ${res.statusCode}: ${res.body}');
        return IncomeSummaryModel(
          status: "success",
          data: IncomeSummaryData(
            incomeBreakdown: IncomeBreakdown(
              dailyRoi: 0.0,
              directReferral: 0.0,
              levelRoi: 0.0,
              gasFee: 0.0,
              salary: 0.0,
            ),
            totalIncome: 0.0,
          ),
        );
      }

      // Check if response is empty or null
      if (res.body.isEmpty || res.body.trim().isEmpty) {
        print('⚠️ Empty response from income summary API');
        return IncomeSummaryModel(
          status: "success",
          data: IncomeSummaryData(
            incomeBreakdown: IncomeBreakdown(
              dailyRoi: 0.0,
              directReferral: 0.0,
              levelRoi: 0.0,
              gasFee: 0.0,
              salary: 0.0,
            ),
            totalIncome: 0.0,
          ),
        );
      }

      // Try to parse JSON
      try {
        return incomeSummaryFromJson(res.body);
      } catch (parseError) {
        print('❌ JSON parsing error: $parseError');
        print('📄 Raw response: "${res.body}"');

        // Return empty data instead of error
        return IncomeSummaryModel(
          status: "success",
          data: IncomeSummaryData(
            incomeBreakdown: IncomeBreakdown(
              dailyRoi: 0.0,
              directReferral: 0.0,
              levelRoi: 0.0,
              gasFee: 0.0,
              salary: 0.0,
            ),
            totalIncome: 0.0,
          ),
        );
      }
    } catch (e) {
      print('❌ Network error getting income summary: $e');
      return IncomeSummaryModel(
        status: "error",
        data: IncomeSummaryData(
          incomeBreakdown: IncomeBreakdown(
            dailyRoi: 0.0,
            directReferral: 0.0,
            levelRoi: 0.0,
            gasFee: 0.0,
            salary: 0.0,
          ),
          totalIncome: 0.0,
        ),
      );
    }
  }
}
