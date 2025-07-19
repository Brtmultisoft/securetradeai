import 'dart:async';
import 'dart:convert';
import 'package:securetradeai/data/strings.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:securetradeai/Data/Api.dart';
import '../../../Service/assets_service.dart';
import '../../../Service/wallet_service.dart';

class AutoDeposit extends StatefulWidget {
  const AutoDeposit({Key? key}) : super(key: key);

  @override
  State<AutoDeposit> createState() => _AutoDepositState();
}

class _AutoDepositState extends State<AutoDeposit> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var amount = TextEditingController();

  // Wallet data
  String walletAddress = "Loading...";
  String privateKey = "";
  bool isAddressLoading = true;
  bool isHistoryLoading = true;
  String selectedNetwork = "BEP20";
  List<String> networks = ["BEP20"];
  String transactionStatus = "Waiting for deposit...";
  double? detectedAmount;
  List<dynamic> depositHistory = [];

  // User balance
  String userBalance = "0.00";
  bool isBalanceLoading = true;

  // Balance is now updated directly when wallet info is fetched

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkExistingWallet();
    _loadDepositHistory();
  }

  // Check if user already has a wallet address
  Future<void> _checkExistingWallet() async {
    setState(() {
      isAddressLoading = true;
    });

    // Validate user ID
    if (commonuserId.isEmpty || commonuserId == "23") {
      setState(() {
        walletAddress = "Error: Invalid user ID";
        isAddressLoading = false;
      });

      final BuildContext currentContext = context;
      Future.microtask(() => showtoast("Please log in again to access deposit features", currentContext));
      return;
    }

    try {
      // Show user ID being used
      print('🔍 Checking wallet for user ID: $commonuserId');

      final result = await WalletService.getWalletInfo(commonuserId);

      // Debug log the response
      print('🔍 Wallet info response: ${result.toString()}');

      if (result['status'] == 'success') {
        // Check if user has a pay_address
        if (result['data'] != null &&
            result['data']['pay_address'] != null &&
            result['data']['pay_address'].toString().isNotEmpty) {
          // User already has a wallet address
          print('✅ Found existing wallet address: ${result['data']['pay_address']}');
          print('✅✅✅✅found balance ${result['data']}');
          final balance = result['data']['balance'] ?? '0.00';
          setState(() {
            walletAddress = result['data']['pay_address'];
            privateKey = result['data']['pay_private_key '] ?? '';
            isAddressLoading = false;
            userBalance = balance.toString();
            isBalanceLoading = false;
          });

          // Show success toast
          final BuildContext currentContext = context;
          Future.microtask(() => showtoast("Using your existing wallet address", currentContext));
        } else {
          // User doesn't have a wallet address, generate one
          print('ℹ️ No existing wallet found, generating new wallet');
          _generateWallet();
        }
      } else {
        // Error getting wallet info, try generating a new wallet
        print('⚠️ Error getting wallet info: ${result['message']}');
        _generateWallet();
      }
    } catch (e) {
      // Error checking existing wallet, try generating a new wallet
      print('❌ Exception checking existing wallet: $e');
      _generateWallet();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    amount.dispose();
    super.dispose();
  }

  // Generate a wallet for the user
  Future<void> _generateWallet() async {
    setState(() {
      isAddressLoading = true;
    });

    try {
      print('🔍 Generating new wallet for user ID: $commonuserId');
      final result = await WalletService.generateWallet(commonuserId);
      print('🔍 Generate wallet response: ${result.toString()}');

      if (result['status'] == 'success') {
        print('✅ Successfully generated new wallet address: ${result['data']['wallet_address']}');
        // Try to get balance from wallet info
        final balance = result['data']['balance'] ?? '0.00';
        setState(() {
          walletAddress = result['data']['wallet_address'];
          privateKey = result['data']['pay_private_key'];
          isAddressLoading = false;
          userBalance = balance.toString();
          isBalanceLoading = false;
        });

        // Show success toast
        final BuildContext currentContext = context;
        Future.microtask(() => showtoast("New wallet address generated successfully", currentContext));
      } else {
        print('❌ Failed to generate wallet: ${result['message']}');
        setState(() {
          walletAddress = "Error generating wallet";
          isAddressLoading = false;
        });

        final BuildContext currentContext = context;
        Future.microtask(() => showtoast(result['message'] ?? "Failed to generate wallet", currentContext));
      }
    } catch (e) {
      print('❌ Exception generating wallet: $e');
      setState(() {
        walletAddress = "Error generating wallet";
        isAddressLoading = false;
      });

      final BuildContext currentContext = context;
      Future.microtask(() => showtoast("Error: $e", currentContext));
    }
  }

  // Load deposit history
  Future<void> _loadDepositHistory() async {
    setState(() {
      isHistoryLoading = true;
    });

    try {
      print('🔍 Loading deposit history for user: $commonuserId');
      final result = await WalletService.getDepositHistory(commonuserId);

      if (result['status'] == 'success') {
        var historyData = result['data']['history'];
        print('✅ Successfully retrieved deposit history: ${historyData is List ? historyData.length : 0} items');

        // Format the history data if needed
        if (historyData is List && historyData.isNotEmpty) {
          // Ensure each history item has required fields
          historyData = historyData.map((item) {
            // Convert item to Map if it's not already
            Map<String, dynamic> historyItem = item is Map ? Map<String, dynamic>.from(item) : {};

            // Ensure required fields exist
            historyItem['amount'] = historyItem['amount'] ?? '0.00';
            historyItem['date'] = historyItem['date'] ?? historyItem['timestamp'] ?? 'Unknown';
            historyItem['status'] = historyItem['status'] ?? 'completed';
            historyItem['hash'] = historyItem['hash'] ?? historyItem['txid'] ?? historyItem['transaction_id'] ?? 'Unknown';

            return historyItem;
          }).toList();
        }

        setState(() {
          depositHistory = historyData ?? [];
          isHistoryLoading = false;
        });
      } else {
        print('❌ Failed to load deposit history: ${result['message']}');
        setState(() {
          depositHistory = [];
          isHistoryLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading deposit history: $e');
      setState(() {
        depositHistory = [];
        isHistoryLoading = false;
      });
    }
  }

  // Check for payment
  Future<void> _checkPayment() async {
    // Store context before async gap
    final BuildContext currentContext = context;

    // Debug print wallet information
    print('🔍 Checking payment with wallet address: $walletAddress');
    print('🔍 Private key length: ${privateKey.length}');
    print('🔍 User ID: $commonuserId');

    // Validate user ID
    if (commonuserId.isEmpty || commonuserId == "23") {
      print('❌ Invalid user ID: $commonuserId');
      Future.microtask(() => showtoast("Please log in again to access deposit features", currentContext));
      return;
    }

    // Validate wallet address and private key
    if (walletAddress.isEmpty || walletAddress == "Loading..." || walletAddress == "Error generating wallet") {
      print('❌ Invalid wallet address: $walletAddress');
      Future.microtask(() => showtoast("Invalid wallet address. Please refresh the page.", currentContext));
      return;
    }

    if (privateKey.isEmpty) {
      print('❌ Empty private key');

      // Try to refresh wallet info
      try {
        print('🔄 Attempting to refresh wallet info');
        final result = await WalletService.getWalletInfo(commonuserId);

        if (result['status'] == 'success' &&
            result['data'] != null) {

          // Try multiple possible field names for private key
          String? retrievedKey;

          if (result['data']['private_key'] != null &&
              result['data']['private_key'].toString().isNotEmpty) {
            retrievedKey = result['data']['private_key'];
            print('✅ Successfully retrieved private_key');
          } else if (result['data']['pay_private_key'] != null &&
                     result['data']['pay_private_key'].toString().isNotEmpty) {
            retrievedKey = result['data']['pay_private_key'];
            print('✅ Successfully retrieved pay_private_key');
          }

          if (retrievedKey != null) {
            print('✅ Successfully retrieved private key: ${retrievedKey.substring(0, 5)}...');
            privateKey = retrievedKey;
          } else {
            print('❌ No private key found in response');
            print('❌ Available fields: ${result['data'].keys.join(', ')}');
            Future.microtask(() => showtoast("Private key not found in wallet data", currentContext));
            return;
          }
        } else {
          print('❌ Failed to retrieve private key');
          Future.microtask(() => showtoast("Could not retrieve wallet information. Please try again later.", currentContext));
          return;
        }
      } catch (e) {
        print('❌ Error refreshing wallet info: $e');
        Future.microtask(() => showtoast("Error retrieving wallet information: $e", currentContext));
        return;
      }
    }

    setState(() {
      transactionStatus = "Checking for payment...";
    });

    showLoading(currentContext);

    try {
      print('📤 Sending monitor wallet request with address: $walletAddress');
      final result = await WalletService.monitorWallet(walletAddress, privateKey);
      print('📥 Monitor wallet response: ${result.toString()}');

      // Check if widget is still mounted before using context
      if (!mounted) return;

      Navigator.pop(currentContext); // Close loading dialog

      if (result['status'] == 'success') {
        // Check for the new response format
        if (result['data'] != null &&
            result['data']['monitoring_result'] != null &&
            result['data']['monitoring_result']['found'] == true) {

          // Extract amount from the new response format
          final amount = result['data']['monitoring_result']['amount'];
          final currency = result['data']['monitoring_result']['currency'] ?? 'USDT';
          final message = result['data']['monitoring_result']['message'] ?? 'Transfer completed successfully';

          print('✅ Payment detected: $amount $currency');
          setState(() {
            transactionStatus = "Payment detected!";
            detectedAmount = double.parse(amount.toString());
          });

          // Refresh history
          _loadDepositHistory();

          // Show animated success toast
          _showSuccessToast(amount, currency, message, currentContext);

        // Check for the old response format as fallback
        } else if (result['data'] != null && result['data']['deposit_found'] == true) {
          print('✅ Payment detected (old format): ${result['data']['amount']}');
          setState(() {
            transactionStatus = "Payment detected!";
            detectedAmount = double.parse(result['data']['amount'].toString());
          });

          // Refresh history
          _loadDepositHistory();

          // Show animated success toast
          _showSuccessToast(result['data']['amount'], 'USDT', 'Transfer completed successfully', currentContext);
        } else {
          print('ℹ️ No payment found yet');
          setState(() {
            transactionStatus = "No payment found yet.";
          });

          Future.microtask(() => showtoast("No payment found yet. Please try again after making the payment.", currentContext));
        }
      } else {
        print('❌ Error checking payment: ${result['message']}');
        setState(() {
          transactionStatus = "Error checking payment";
        });

        Future.microtask(() => showtoast(result['message'] ?? "Error checking payment", currentContext));
      }
    } catch (e) {
      // Check if widget is still mounted before using context
      if (!mounted) return;

      print('❌ Exception checking payment: $e');
      Navigator.pop(currentContext); // Close loading dialog
      setState(() {
        transactionStatus = "Error: $e";
      });

      Future.microtask(() => showtoast("Error: $e", currentContext));
    }
  }



  // Show animated success toast for deposit
  void _showSuccessToast(dynamic amount, String currency, String message, BuildContext context) {
    // Format amount to 4 decimal places
    String formattedAmount = double.parse(amount.toString()).toStringAsFixed(4);

    // Create a custom animated toast
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        // Auto dismiss after 5 seconds
        Future.delayed(Duration(seconds: 5), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF1E2026),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF2A2D35), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFF0B90B).withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon with animation
                TweenAnimationBuilder(
                  duration: Duration(milliseconds: 800),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Color(0xFF0ECB81).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Color(0xFF0ECB81),
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),

                // Success message
                Text(
                  "Deposit Successful!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),

                // Amount with animation
                TweenAnimationBuilder(
                  duration: Duration(milliseconds: 1200),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Text(
                        "$formattedAmount $currency",
                        style: TextStyle(
                          color: Color(0xFFF0B90B),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 15),

                // Status message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF848E9C),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 20),

                // Close button
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Color(0xFFF0B90B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "Close",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12), // Binance dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF161A1E), // Binance header color
        elevation: 0,
        title: Text(
          "Gas Deposit".tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF0B90B), // Binance yellow
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF848E9C),
          tabs: const [
            Tab(text: 'Deposit'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Deposit Tab
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Balance Section
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2026), // Dark blue card background
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2A3A5A), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Balance',
                        style: TextStyle(
                          color: Color(0xFF8A9CC0), // Light blue text
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D1321),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.account_balance_wallet,
                                    color: Color(0xFF4A6FA5),
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Available USD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          isBalanceLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF4A6FA5),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  userBalance,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFF8A9CC0),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Deposit USDT to increase your balance. Only BEP20 network is supported.',
                              style: TextStyle(
                                color: Color(0xFF8A9CC0),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount Input
                // Container(
                //   margin: const EdgeInsets.symmetric(horizontal: 16),
                //   padding: const EdgeInsets.all(16),
                //   decoration: BoxDecoration(
                //     color: const Color(0xFF1E2026), // Binance card background
                //     borderRadius: BorderRadius.circular(8),
                //     border: Border.all(color: const Color(0xFF2A2D35), width: 1),
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       const Text(
                //         'Amount',
                //         style: TextStyle(
                //           color: Color(0xFF848E9C), // Binance gray text
                //           fontSize: 14,
                //         ),
                //       ),
                //       // const SizedBox(height: 12),
                //       // Container(
                //       //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                //       //   decoration: BoxDecoration(
                //       //     color: const Color(0xFF2B3139), // Binance input background
                //       //     borderRadius: BorderRadius.circular(4),
                //       //   ),
                //       //   child: TextField(
                //       //     style: const TextStyle(color: Colors.white, fontSize: 16),
                //       //     controller: amount,
                //       //     keyboardType: TextInputType.number,
                //       //     decoration: const InputDecoration(
                //       //       hintStyle: TextStyle(color: Color(0xFF848E9C), fontSize: 14),
                //       //       hintText: "Enter Amount USD",
                //       //       border: InputBorder.none,
                //       //       enabledBorder: InputBorder.none,
                //       //       focusedBorder: InputBorder.none,
                //       //       suffixText: 'USD',
                //       //       suffixStyle: TextStyle(color: Color(0xFF848E9C), fontSize: 14),
                //       //     ),
                //       //   ),
                //       // ),

                //       const SizedBox(height: 12),
                //       Row(
                //         children: const [
                //           Icon(
                //             Icons.info_outline,
                //             color: Color(0xFF848E9C),
                //             size: 16,
                //           ),
                //           SizedBox(width: 8),
                //           Text(
                //             'Minimum deposit: 10 USD',
                //             style: TextStyle(
                //               color: Color(0xFF848E9C),
                //               fontSize: 12,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ],
                //   ),
                // ),

                const SizedBox(height: 16),

                // QR Code Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2026), // Binance card background
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2A2D35), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Deposit Address',
                        style: TextStyle(
                          color: Color(0xFF848E9C), // Binance gray text
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: isAddressLoading
                            ? const CircularProgressIndicator(
                                color: Color(0xFFF0B90B),
                              )
                            : Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: BarcodeWidget(
                                  barcode: Barcode.qrCode(),
                                  color: Colors.black,
                                  data: walletAddress,
                                  width: 200,
                                  height: 200,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B3139), // Binance input background
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                walletAddress,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                final BuildContext currentContext = context;
                                Clipboard.setData(ClipboardData(text: walletAddress));
                                Future.microtask(() => showtoast("Copied", currentContext));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0B90B).withOpacity(0.1), // Binance yellow with opacity
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.copy,
                                      color: Color(0xFFF0B90B), // Binance yellow
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "Copy",
                                      style: TextStyle(
                                        color: Color(0xFFF0B90B), // Binance yellow
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF848E9C),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Send only USDT to this deposit address. Ensure the network is $selectedNetwork.',
                              style: const TextStyle(
                                color: Color(0xFF848E9C),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Payment Status Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2026), // Binance card background
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2A2D35), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Status',
                        style: TextStyle(
                          color: Color(0xFF848E9C), // Binance gray text
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B3139), // Binance input background
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            detectedAmount != null
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF0ECB81),
                                    size: 24,
                                  )
                                : const Icon(
                                    Icons.info,
                                    color: Color(0xFFF0B90B),
                                    size: 24,
                                  ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transactionStatus,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (detectedAmount != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Amount: $detectedAmount USD',
                                      style: const TextStyle(
                                        color: Color(0xFFF0B90B),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFF848E9C),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Send the exact amount to the address above. Click "Confirm USDT Deposit" after sending to verify your payment.',
                              style: TextStyle(
                                color: Color(0xFF848E9C),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Confirm USDT Deposit Button
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap: () {
                      _checkPayment();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0B90B), // Binance yellow
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "Confirm USDT Deposit".tr,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // History Tab
          isHistoryLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFF0B90B),
                  ),
                )
              : depositHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Color(0xFF848E9C),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No deposit history found',
                            style: TextStyle(
                              color: Color(0xFF848E9C),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: depositHistory.length,
                      itemBuilder: (context, index) {
                        final deposit = depositHistory[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2026),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF2A2D35), width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${deposit['amount']} USD',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: deposit['status'] == 'completed'
                                          ? const Color(0xFF0ECB81).withOpacity(0.1)
                                          : deposit['status'] == 'pending'
                                              ? const Color(0xFFF0B90B).withOpacity(0.1)
                                              : const Color(0xFFFF4C4C).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      deposit['status'].toUpperCase(),
                                      style: TextStyle(
                                        color: deposit['status'] == 'completed'
                                            ? const Color(0xFF0ECB81)
                                            : deposit['status'] == 'pending'
                                                ? const Color(0xFFF0B90B)
                                                : const Color(0xFFFF4C4C),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Date: ${deposit['date']}',
                                style: const TextStyle(
                                  color: Color(0xFF848E9C),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'TxID: ${deposit['hash']}',
                                      style: const TextStyle(
                                        color: Color(0xFF848E9C),
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      final BuildContext currentContext = context;
                                      Clipboard.setData(ClipboardData(text: deposit['hash']));
                                      Future.microtask(() => showtoast("Copied", currentContext));
                                    },
                                    child: const Icon(
                                      Icons.copy,
                                      color: Color(0xFFF0B90B),
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
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
