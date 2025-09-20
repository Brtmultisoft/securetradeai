// Mock data for auto trading when API fails
class MockData {
  static List<Map<String, dynamic>> getRiskLevels() {
    return [
      {
        'riskLevel': 'Low',
        'description': 'Conservative strategy with lower risk and stable returns',
        'totalPairs': 3,
        'totalVolume': 1500000,
        'avgReturn': '5-10%',
        'isActive': false,
        'pairs': [
          {
            'symbol': 'BTC',
            'icon': 'https://cryptologos.cc/logos/bitcoin-btc-logo.png',
            'price': '45,230.50',
            'priceChange': '+2.3%',
            'strategy': 'DCA',
            'minInvestment': '100',
            'expectedReturn': '5-8%',
          },
          {
            'symbol': 'ETH',
            'icon': 'https://cryptologos.cc/logos/ethereum-eth-logo.png',
            'price': '3,120.75',
            'priceChange': '+1.8%',
            'strategy': 'HODL',
            'minInvestment': '50',
            'expectedReturn': '6-9%',
          },
          {
            'symbol': 'BNB',
            'icon': 'https://cryptologos.cc/logos/bnb-bnb-logo.png',
            'price': '420.30',
            'priceChange': '+0.5%',
            'strategy': 'Grid',
            'minInvestment': '25',
            'expectedReturn': '4-7%',
          },
        ],
      },
      {
        'riskLevel': 'Medium',
        'description': 'Balanced strategy with moderate risk and higher potential returns',
        'totalPairs': 4,
        'totalVolume': 2000000,
        'avgReturn': '10-20%',
        'isActive': false,
        'pairs': [
          {
            'symbol': 'SOL',
            'icon': 'https://cryptologos.cc/logos/solana-sol-logo.png',
            'price': '102.45',
            'priceChange': '+4.2%',
            'strategy': 'Swing',
            'minInvestment': '75',
            'expectedReturn': '10-15%',
          },
          {
            'symbol': 'ADA',
            'icon': 'https://cryptologos.cc/logos/cardano-ada-logo.png',
            'price': '0.58',
            'priceChange': '+2.1%',
            'strategy': 'DCA',
            'minInvestment': '30',
            'expectedReturn': '8-12%',
          },
          {
            'symbol': 'DOT',
            'icon': 'https://cryptologos.cc/logos/polkadot-new-dot-logo.png',
            'price': '7.85',
            'priceChange': '+3.7%',
            'strategy': 'Grid',
            'minInvestment': '40',
            'expectedReturn': '9-14%',
          },
          {
            'symbol': 'AVAX',
            'icon': 'https://cryptologos.cc/logos/avalanche-avax-logo.png',
            'price': '35.20',
            'priceChange': '+5.1%',
            'strategy': 'Momentum',
            'minInvestment': '50',
            'expectedReturn': '12-18%',
          },
        ],
      },
      {
        'riskLevel': 'High',
        'description': 'Aggressive strategy with higher risk and potential for significant returns',
        'totalPairs': 3,
        'totalVolume': 1800000,
        'avgReturn': '20-40%',
        'isActive': false,
        'pairs': [
          {
            'symbol': 'SHIB',
            'icon': 'https://cryptologos.cc/logos/shiba-inu-shib-logo.png',
            'price': '0.00002145',
            'priceChange': '+8.7%',
            'strategy': 'Momentum',
            'minInvestment': '20',
            'expectedReturn': '20-50%',
          },
          {
            'symbol': 'DOGE',
            'icon': 'https://cryptologos.cc/logos/dogecoin-doge-logo.png',
            'price': '0.12',
            'priceChange': '+6.3%',
            'strategy': 'Swing',
            'minInvestment': '25',
            'expectedReturn': '15-40%',
          },
          {
            'symbol': 'MATIC',
            'icon': 'https://cryptologos.cc/logos/polygon-matic-logo.png',
            'price': '0.85',
            'priceChange': '+7.2%',
            'strategy': 'Grid',
            'minInvestment': '30',
            'expectedReturn': '18-35%',
          },
        ],
      },
    ];
  }

  static Map<String, dynamic> getMockSettings(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return {
          "first_buy": "100",
          "wp_profit": "3",
          "margin_call_limit": "10",
          "wp_callback": "1",
          "by_callback": "1",
          "martin_config": true,
          "margin_drop_1": "5",
          "margin_drop_2": "10",
          "margin_drop_3": "15",
          "margin_drop_4": "20",
          "margin_drop_5": "25",
          "margin_drop_6": "30",
          "margin_drop_7": "35",
          "margin_drop_8": "40",
          "margin_drop_9": "45",
          "margin_drop_10": "50"
        };
      case 'medium':
        return {
          "first_buy": "200",
          "wp_profit": "5",
          "margin_call_limit": "15",
          "wp_callback": "2",
          "by_callback": "2",
          "martin_config": true,
          "margin_drop_1": "7",
          "margin_drop_2": "14",
          "margin_drop_3": "21",
          "margin_drop_4": "28",
          "margin_drop_5": "35",
          "margin_drop_6": "42",
          "margin_drop_7": "49",
          "margin_drop_8": "56",
          "margin_drop_9": "63",
          "margin_drop_10": "70"
        };
      case 'high':
        return {
          "first_buy": "300",
          "wp_profit": "8",
          "margin_call_limit": "20",
          "wp_callback": "3",
          "by_callback": "3",
          "martin_config": true,
          "margin_drop_1": "10",
          "margin_drop_2": "20",
          "margin_drop_3": "30",
          "margin_drop_4": "40",
          "margin_drop_5": "50",
          "margin_drop_6": "60",
          "margin_drop_7": "70",
          "margin_drop_8": "80",
          "margin_drop_9": "90",
          "margin_drop_10": "100"
        };
      default:
        return {
          "first_buy": "100",
          "wp_profit": "3",
          "margin_call_limit": "10",
          "wp_callback": "1",
          "by_callback": "1",
          "martin_config": true,
          "margin_drop_1": "5",
          "margin_drop_2": "10",
          "margin_drop_3": "15",
          "margin_drop_4": "20",
          "margin_drop_5": "25",
          "margin_drop_6": "30",
          "margin_drop_7": "35",
          "margin_drop_8": "40",
          "margin_drop_9": "45",
          "margin_drop_10": "50"
        };
    }
  }
}
