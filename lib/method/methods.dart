import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:securetradeai/Data/Api.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/model/HomePageBannerModel.dart';
import 'package:securetradeai/model/MineModel.dart';
import 'package:securetradeai/model/NewsModel.dart';
import 'package:securetradeai/model/RevenueDetailBydate.dart';
import 'package:securetradeai/model/TradeHistoryModel.dart';
import 'package:securetradeai/model/levelIncomeModel.dart';
import 'package:securetradeai/model/revenueModel.dart';

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

  // Get user's current balance
  Future<double> getUserBalance() async {
    try {
      final res = await http.post(Uri.parse(usdBalance),
          body: jsonEncode({"user_id": commonuserId}));

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          return double.tryParse(data['data']['balance'].toString()) ?? 0.0;
        }
      }
      return 0.0;
    } catch (e) {
      print("Error getting user balance: $e");
      return 0.0;
    }
  }
}
