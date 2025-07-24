const String mainUrl = "https://securetradeai.com/";
const String path = "${mainUrl}uploads/offers/";
const String imagepath = "${mainUrl}uploads/user/";
const String url = "${mainUrl}myrest/user/";
const String ragisterurl = "${url}user_registration";
const String sendOtp = "${url}user_emailotp";
const String sendWithdrawalOTP = "${url}withdraw_emailotp";
const String sendTransferOTP = "${url}transfer_emailotp";
const String gasWalletOPT = "${url}gaswallet_emailotp";
const String SwapOTP = "${url}swap_emailotp";
const String forgotPassword = "${url}forget_password";
const String loginUrl = "${url}login";
const String updateRank = "${url}update_rank";
const String privacyPolicy = "${url}privacy_policy";
const String agreeMent = "${url}terms_condition";
const String bannerImage = "${url}offer_banner";
const String newsApi = "${mainUrl}myrest/website/all_news";
const String mine = "${url}mine";
const String updatename = "${url}edit_name";
const String updateUserProfile = "${url}update_user_profile_image";
const String transactionDetail = "${url}my_account_transaction";
const String swap_wallet_history = "${url}swap_wallet_history";
const String gasHistory = "${url}swap_wallet_history";
const String deposit = "${url}deposit";
const String withdrawal = "${url}withdraw";
const String transfer = "${url}transfer";
const String gasTransfer = "${url}gas_togas_transfer";
const String swap = "${url}swap_wallet";
const String getIp = "${url}adminip";
const String apibindingOtp = "${url}apibindingotp";
const String bindingAPi = "${url}bindingapi";
const String team = "${url}level_team";
const String teamDetail = "${url}my_downline";
const String transactionrecord = "${url}transaction_record";
const String updatepassword = "${url}update_password";
const String levelincomeDetail = "${url}level_incomedetails";
const String stakingincomeDetail = "${url}royalty_incomedetails";
const String directIncomeDetail = "${url}direct_incomedetails";
const String universalpool = "${url}universal_pool_incomedetails";
const String tradeincomedetails = "${url}trade_incomedetails";
const String clubincomedetails = "${url}club_incomedetails";
const String getappVersion = "${url}appversion";
const String userActivation = "${url}user_activation";
const String userNews = "${url}news";
const String revenueDetail = "${url}revenue_details";
const String revenuedetailByDate = "${url}revenue_bydate";
const String getversion = "${url}appversion";
const String updateEmail = "${url}edit_emailid";
const String usdBalance = "${url}user_usdtbalance";
const String tradesettingwwm = "${url}trade_setting_wwm";
const String tradesettingsubbin = "${url}trade_setting_subbin";
const String cryptoassets = "${url}crypto_assets";
const String videos = "${url}video_details";
const String notice = "${url}apibinding_terms_condition";
const String inbox = "${url}my_ticket";
const String sendmsg = "${url}create_ticket";
const String tradeSettingUpdatesubbin = "${url}trade_setting_update_subbin";
const String tradeSettingUpdatewwm = "${url}trade_setting_update_wwm";

// ignore: constant_identifier_names
const String quantitative_txn_recordWWM = "${url}quantitative_txn_record_wwm";
const String quantitative_txn_recordsubbin =
    "${url}quantitative_txn_record_subbin";
const String perfectBot_txt_record = "${url}quantitative_txn_record_perfectbot";
const String emailVerify = "${url}emailotp_verify";
const String txnallRecords = "${url}quantitative_txn_allrecord";
const String txnallRecordshuobi = "${url}quantitative_txn_allrecord_huobi";
const String tradesetting_update_by_columnwwm =
    "${url}trade_setting_updatebycolum_wwm";
const String tradesetting_update_by_columnsubbin =
    "${url}trade_setting_updatebycolum_subbin";
const String resettradesettingwwm = "${url}trade_setting_reset_wwm";
const String resettradesettingsubbin = "${url}trade_setting_reset_subbin";
const String openOrderStatuswwm = "${url}open_orderstatus_wwm";
const String openOrderStatussubbin = "${url}open_orderstatus_subbin";
const String buyManualPerfect = '${url}buy_manual_perfectbot';
const String userGuide = "${url}user_guide";
const String resetBotwwm = "${url}bot_reset_wwm";
const String resetBotsubbin = "${url}bot_reset_subbin";
const String APIsellmanualwwm = "${url}sell_manual_wwm";
const String APIsellmanualsubbin = "${url}sell_manual_subbin";
const String buymanualwwm = "${url}buy_manual_wwm";
const String buymanualsubbin = "${url}buy_manual_subbin";
const String updateTradeSettingFirstPagewwm =
    "${url}trade_setting_updatefront_wwm";
const String updateTradeSettingFirstPagesubbin =
    "${url}trade_setting_updatefront_subbin";
const String multicurrency = "${url}multicurrency";
const String huobiBalance = "${url}user_usdtbalance_huobi";
const String circleData = "${url}approve_circledetails";
const String cirlceTradeSettingData = "${url}user_circledetails";
const String createCircle = "${url}check_user_circle";
const String profitSharingIncome = "${url}profit_sharing_incomedetails";
const String royaltyIncomedetails = "${url}royalty_incomedetails";
const String royaltyincome = "${url}royalty_incomedetails";
const String getBotsetting = "${url}perfectbot_status";
const String updateBot = "${url}perfectbot_status_update";
const String openOrder_perfectBot = "${url}openorder_perfectbot";
const String openOrder_updown = "${url}openorder_updown";
const String openOrder_reset = "${url}perfectbot_reset";
const String gerPerfect_or_updown =
    "${url}quantitative_txn_allrecord_perfectbot";
const String tradesetting_riskwwm = "${url}trade_setting_risk_wwm";
const String tradesetting_risksubbin = "${url}trade_setting_risk_subbin";
const String tradeAdminSetting = "${url}get_setting_trade_setting_risk_subbin";
const String StakingROI = "${url}staking_roi";
const String buyManualHuobiWWM = "${url}buy_huobi_manual_wwm";
const String buyManualHuobiSubbin = "${url}buy_huobi_manual_subbin";
const String stakingHistory = "${url}my_staking";
const String price = "${url}coin_price";
const String stakingpack = "${url}staking_pack";
const String errorNotification = "${url}binance_errors";

// Wallet API endpoints
const String generateWalletUrl = "${url}generate_wallet";
const String monitorWalletUrl = "${url}monitor_wallet";
const String getWalletInfoUrl = "${url}get_wallet_info";

// Subscription API endpoints
const String activateSubscriptionUrl = "${url}activate_subscription";

// Investment Package API endpoints
const String buyPackagePost = "${url}buy_package";
const String getUserInvestmentsPost = "${url}get_user_investments";
const String getIncomesPost = "${url}get_incomes";

// Future Trading API endpoints
const String dualSideAccountBalance = "${url}dual_side_account_balance";
const String dualSideInit = "${url}dual_side_init";
const String dualSideTradeHistory = "${url}dual_side_trade_history";
const String dualSideTradingReport = "${url}dual_side_trading_report";
const String dualSideOpenPositions = "${url}dual_side_open_positions";
const String dualSidePerformance = "${url}dual_side_performance";
