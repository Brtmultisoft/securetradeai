import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rapidtradeai/Data/Api.dart';
import 'package:rapidtradeai/data/strings.dart';
import 'package:rapidtradeai/method/methods.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';
import 'package:rapidtradeai/src/widget/common_app_bar.dart';

import 'package:rapidtradeai/src/Service/otp_service.dart';
import 'package:rapidtradeai/src/widget/lottie_loading_widget.dart';
import 'package:rapidtradeai/model/withdrawal_history_model.dart';

class Withdrawal extends StatefulWidget {
  const Withdrawal({Key? key, this.balance}) : super(key: key);
  final balance;
  @override
  _WithdrawalState createState() => _WithdrawalState();
}

class _WithdrawalState extends State<Withdrawal> {
  // Use common OtpService for sending and verifying OTP
  Future<void> _sendOtp() async {
    setState(() {
      isOtpSending = true;
    });
    OtpService.clearRequestId();
    final response = await OtpService.sendOtpToEmail(
      email: commonEmail, // Use user's email for OTP
      type: "withdrawal",
      context: context,
    );
    setState(() {
      isOtpSent = response.isSuccess;
      isOtpSending = false;
    });
  }

  Future<void> _verifyOtp() async {
    setState(() {
      isOtpVerifying = true;
    });
    final response = await OtpService.verifyOtpCode(
      email: commonEmail,
      otp: otpController.text,
      context: context,
    );
    setState(() {
      isOtpVerified = response.isSuccess;
      isOtpVerifying = false;
    });
  }

  var address = TextEditingController();
  var amount = TextEditingController();
  var otpController = TextEditingController();
  var transpass = TextEditingController();
  var pttnTokenvalue = TextEditingController();

  // Profile data
  bool isLoadingProfile = true;
  String walletAddress = "";
  String earningBalance = "0.00";

  // Amount validation
  String? amountError;
  bool isAmountValid = true;

  // OTP flags
  bool isOtpSent = false;
  bool isOtpVerified = false;
  bool isOtpSending = false;
  bool isOtpVerifying = false;
  String? otpRequestId;

  // Withdrawal history state
  List<WithdrawalTransaction> withdrawalHistory = [];
  bool isLoadingHistory = false;
  bool showHistory = false;
  int currentPage = 1;
  final int pageSize = 10;
  String totalBalance = "0.00";

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadWithdrawalHistory({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 1;
      withdrawalHistory.clear();
    }

    setState(() {
      isLoadingHistory = true;
    });

    try {
      final response = await CommonMethod().getWithdrawalHistory(
        page: currentPage,
        size: pageSize,
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          if (isRefresh) {
            withdrawalHistory = response.data!.details;
          } else {
            withdrawalHistory.addAll(response.data!.details);
          }
          totalBalance = response.data!.totalBalance;
          isLoadingHistory = false;
        });
      } else {
        setState(() {
          isLoadingHistory = false;
        });
        showtoast(response.message, context);
      }
    } catch (e) {
      setState(() {
        isLoadingHistory = false;
      });
      showtoast("Failed to load withdrawal history", context);
      print("Error loading withdrawal history: $e");
    }
  }

  Future<void> _loadProfileData() async {
    try {
      final data = await CommonMethod().getMineData();
      if (data.status == "success" && data.data.isNotEmpty) {
        setState(() {
          walletAddress = data.data[0].walletAddress;
          earningBalance =
              data.data[0].incomeBalance; // Get earning balance from profile
          address.text =
              walletAddress; // Set the wallet address in the controller
          isLoadingProfile = false;
        });

        // Check wallet address immediately after loading
        if (walletAddress.isEmpty) {
          _showWalletAddressDialog();
        }
      } else {
        setState(() {
          isLoadingProfile = false;
        });
        // Show dialog if no data found
        _showWalletAddressDialog();
      }
    } catch (e) {
      print("Error loading profile data: $e");
      setState(() {
        isLoadingProfile = false;
      });
      // Show dialog on error too
      _showWalletAddressDialog();
    }
  }

  void _validateAmount(String value) {
    setState(() {
      if (value.isEmpty) {
        amountError = null;
        isAmountValid = true;
        return;
      }

      try {
        double enteredAmount = double.parse(value);
        double maxBalance = double.parse(earningBalance);

        if (enteredAmount > maxBalance) {
          amountError =
          "Amount cannot exceed earning balance ($earningBalance USDT)";
          isAmountValid = false;
        } else if (enteredAmount <= 0) {
          amountError = "Amount must be greater than 0";
          isAmountValid = false;
        } else {
          amountError = null;
          isAmountValid = true;
        }
      } catch (e) {
        amountError = "Please enter a valid amount";
        isAmountValid = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF0D1321),
        appBar: CommonAppBar.basic(
          title: 'withdrawal'.tr,
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 10, top: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          "${"balance".tr} : ",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      Container(
                        child: isLoadingProfile
                            ? const Text(
                          "Loading...",
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        )
                            : Text(
                          "$earningBalance USDT",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      )
                    ]),
                const SizedBox(
                  height: 20,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          "${"address".tr} :     ",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xfff3f3f4),
                            ),
                            borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                            color: const Color(
                                0xFF2A2A2A), // Darker background to indicate non-editable
                          ),
                          child: Center(
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: isLoadingProfile
                                        ? const Text(
                                      "Loading wallet address...",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    )
                                        : Text(
                                      walletAddress.isEmpty
                                          ? "No wallet address found"
                                          : walletAddress,
                                      style: TextStyle(
                                        color: walletAddress.isEmpty
                                            ? Colors.white70
                                            : Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.lock,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ]),
                const SizedBox(
                  height: 20,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          "amount".tr + r"($) : ",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      Expanded(
                        child: Container(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xfff3f3f4),
                                  ),
                                  borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: TextField(
                                    style: const TextStyle(color: Colors.white),
                                    controller: amount,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintStyle: const TextStyle(
                                          color: Colors.white70, fontSize: 13),
                                      hintText: "${"amount".tr}(USDT)",
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      _validateAmount(value);
                                    },
                                  ),
                                ),
                              ),
                            )),
                      )
                    ]),
                // Error message display
                if (amountError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            amountError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),

                if (!isOtpVerified) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: const Text(
                          "OTP : ",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      const Spacer(),
                      Expanded(
                        child: InkWell(
                          onTap: isOtpSending ? null : _sendOtp,
                          child: Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width,
                            // padding: const EdgeInsets.symmetric(vertical: 15),
                            alignment: Alignment.center,
                            decoration:  BoxDecoration(
                              color: TradingTheme.secondaryAccent,
                              borderRadius:
                              BorderRadius.all(Radius.circular(5)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(2, 4),
                                    blurRadius: 5,
                                    spreadRadius: 2)
                              ],
                            ),
                            child: isOtpSending
                                ? const LottieLoadingWidget()
                                : Text(
                              isOtpSent ? "Resend OTP" : "Send OTP",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isOtpSent)
                    Container(
                      child: Container(
                        height: 50,
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xfff3f3f4),
                            ),
                            borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: TextField(
                              style: const TextStyle(color: Colors.white),
                              controller: otpController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintStyle: TextStyle(
                                    color: Colors.white70, fontSize: 13),
                                hintText: "Please Enter OTP",
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              onChanged: (value) {},
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (isOtpSent)
                    InkWell(
                      onTap: isOtpVerifying ? null : _verifyOtp,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                           color: TradingTheme.secondaryAccent,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(2, 4),
                                  blurRadius: 5,
                                  spreadRadius: 2)
                            ],
                          ),
                          child: isOtpVerifying
                              ? const LottieLoadingWidget()
                              : const Text(
                            "Verify OTP",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                ],

                const SizedBox(
                  height: 40,
                ),
                InkWell(
                  onTap: isAmountValid && amountError == null && isOtpVerified
                      ? () {
                    _checkWithdrawalAbleOrNot();
                  }
                      : null,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: TradingTheme.secondaryAccent,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.black12,
                            offset: Offset(2, 4),
                            blurRadius: 5,
                            spreadRadius: 2)
                      ],
                    ),
                    child: Text(
                      "withdrawal".tr,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Withdrawal History Section
                const SizedBox(height: 30),
                _buildHistoryToggleButton(),
                if (showHistory) ...[
                  const SizedBox(height: 20),
                  _buildWithdrawalHistorySection(),
                ],
              ],
            ),
          ),
        ));
  }

  void _showWalletAddressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2A3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: const Color(0xFFF0B90B),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Wallet Address Required',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your wallet address is not set. Please update your profile to add a wallet address before making withdrawals.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0B90B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF0B90B).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFFF0B90B),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Go to Profile → Update wallet address',
                        style: TextStyle(
                          color: Color(0xFFF0B90B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
                // User can then go to Profile tab and update wallet address
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF0B90B),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _checkWithdrawalAbleOrNot() async {
    try {
      showLoading(context);
      if (amount.text == "") {
        showtoast("Amount Field is Empty", context);
        Navigator.pop(context);
      } else if (!isAmountValid || amountError != null) {
        showtoast(amountError ?? "Please enter a valid amount", context);
        Navigator.pop(context);
      }
      // else if (transpass.text == "") {
      //   showtoast("Transaction Password Field is Empty", context);
      //   Navigator.pop(context);
      // }
      else {
        final res = await http.post(Uri.parse(getIp),
            body: json.encode({"user_id": commonuserId}));
        if (res.statusCode == 200) {
          var data = jsonDecode(res.body);
          if (data['status'] == "success") {
            if (double.parse(amount.text) <
                double.parse(data['data']['admin_details']['min_withdraw'])) {
              showtoast(
                  "Min Withdrawal value ${data['data']['admin_details']['min_withdraw']}",
                  context);
              Navigator.pop(context);
            } else {
              _withdrawal();
              Navigator.pop(context);
            }
          }
        } else {
          showtoast("Server Error", context);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future _withdrawal() async {
    try {
      showLoading(context);
      var bodydata = jsonEncode({
        "user_id": commonuserId,
        "amount": amount.text,
        "qty": "0.00",
        "address": walletAddress,
        "password": transpass.text
      });
      print(bodydata);
      final resp = await http.post(Uri.parse(withdrawal), body: bodydata);
      if (resp.statusCode != 200) {
        showtoast("Server Error", context);
        Navigator.pop(context);
      } else {
        var jsondata = jsonDecode(resp.body);
        print(jsondata);
        if (jsondata['status'] == "success") {
          showtoast(jsondata['message'], context);
          address.clear();
          amount.clear();
          transpass.clear();
          pttnTokenvalue.clear();
          Navigator.pop(context);
        } else {
          showtoast(jsondata['message'], context);
          Navigator.pop(context);
        }
        // if(jsondata)
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
  }

  Widget _buildHistoryToggleButton() {
    return InkWell(
      onTap: () {
        setState(() {
          showHistory = !showHistory;
        });
        if (showHistory && withdrawalHistory.isEmpty) {
          _loadWithdrawalHistory(isRefresh: true);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: TradingTheme.secondaryAccent.withOpacity(0.5)),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              showHistory ? Icons.history_toggle_off : Icons.history,
              color: TradingTheme.secondaryAccent,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              showHistory ? "Hide History" : "View Withdrawal History",
              style: const TextStyle(
                fontSize: 16,
                color: TradingTheme.secondaryAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalHistorySection() {
    return Container(padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),

      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A3A4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration:  BoxDecoration(
           color: TradingTheme.secondaryAccent.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.history,
                      color: TradingTheme.secondaryAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Withdrawal History",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => _loadWithdrawalHistory(isRefresh: true),
                      child: const Icon(
                        Icons.refresh,
                        color: TradingTheme.secondaryAccent,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                if (totalBalance != "0.00") ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TradingTheme.secondaryAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                      color: TradingTheme.secondaryAccent.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet,
                          color: TradingTheme.secondaryAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Total Balance: ",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "$totalBalance USDT",
                          style: const TextStyle(
                            color: TradingTheme.secondaryAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 10,),
          /// Content
          if (isLoadingHistory)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: LottieLoadingWidget.medium(),
              ),
            )
          else if (withdrawalHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: const [
                    Icon(
                      Icons.history,
                      color: Colors.white54,
                      size: 48,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No withdrawal history found",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
              // _buildHistorySummary(),
              _buildHistoryList(),

            ],

        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: withdrawalHistory.length,
      separatorBuilder: (context, index) => const Divider(
        color: Color(0xFF2A3A4A),
        height: 1,
      ),
      itemBuilder: (context, index) {
        final transaction = withdrawalHistory[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(WithdrawalTransaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3A4A).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A4A5A).withOpacity(0.5)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: const Color(0xFFF0B90B),
        collapsedIconColor: Colors.white70,
        title: Row(
          children: [
            // Amount
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${transaction.amount.toStringAsFixed(2)} USDT",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    transaction.type,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: transaction.statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: transaction.statusColor),
              ),
              child: Text(
                transaction.status,
                style: TextStyle(
                  color: transaction.statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            transaction.formattedDate,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ),
        children: [
          _buildDetailedTransactionInfo(transaction),
        ],
      ),
    );
  }

  Widget _buildDetailedTransactionInfo(WithdrawalTransaction transaction) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A3A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Transaction Details Header
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: const Color(0xFFF0B90B),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                "Transaction Details",
                style: TextStyle(
                  color: Color(0xFFF0B90B),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // All Transaction Fields
          _buildDetailRow("Transaction ID", transaction.id),
          _buildDetailRow("User ID", transaction.userId),
          _buildDetailRow("Type", transaction.type),
          _buildDetailRow("Description", transaction.descr),

          const SizedBox(height: 8),
          const Divider(color: Color(0xFF3A4A5A), height: 1),
          const SizedBox(height: 8),

          // Amount Details
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: const Color(0xFFF0B90B),
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                "Amount Details",
                style: TextStyle(
                  color: Color(0xFFF0B90B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          _buildDetailRow("Debit Amount", "${transaction.amount.toStringAsFixed(2)} USDT",
              valueColor: Colors.redAccent),
          _buildDetailRow("Credit Amount", "${double.tryParse(transaction.cr)?.toStringAsFixed(2) ?? '0.00'} USDT",
              valueColor: Colors.greenAccent),
          _buildDetailRow("Quantity", "${double.tryParse(transaction.qty)?.toStringAsFixed(2) ?? '0.00'} USDT"),
          _buildDetailRow("Charges", "${transaction.chargesAmount.toStringAsFixed(2)} USDT",
              valueColor: transaction.chargesAmount > 0 ? Colors.orange : Colors.white70),

          const SizedBox(height: 8),
          const Divider(color: Color(0xFF3A4A5A), height: 1),
          const SizedBox(height: 8),

          // Address Details
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: const Color(0xFFF0B90B),
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                "Wallet Address",
                style: TextStyle(
                  color: Color(0xFFF0B90B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1321),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2A3A4A)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    transaction.address.isEmpty ? "No address provided" : transaction.address,
                    style: TextStyle(
                      color: transaction.address.isEmpty ? Colors.white54 : Colors.white,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                if (transaction.address.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      // Copy to clipboard functionality
                      showtoast("Address copied to clipboard", context);
                    },
                    child: Icon(
                      Icons.copy,
                      color: const Color(0xFFF0B90B),
                      size: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),
          const Divider(color: Color(0xFF3A4A5A), height: 1),
          const SizedBox(height: 8),

          // Hash Key (if available)
          if (transaction.hashkey != null && transaction.hashkey!.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.tag,
                  color: const Color(0xFFF0B90B),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Transaction Hash",
                  style: TextStyle(
                    color: Color(0xFFF0B90B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1321),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A3A4A)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      transaction.hashkey!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      showtoast("Hash copied to clipboard", context);
                    },
                    child: Icon(
                      Icons.copy,
                      color: const Color(0xFFF0B90B),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: Color(0xFF3A4A5A), height: 1),
            const SizedBox(height: 8),
          ],

          // Timestamps
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: const Color(0xFFF0B90B),
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                "Timestamps",
                style: TextStyle(
                  color: Color(0xFFF0B90B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          _buildDetailRow("Created Date", transaction.formattedDate),
          _buildDetailRow("Modified Date", _formatDate(transaction.modifiedDate)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }
}
