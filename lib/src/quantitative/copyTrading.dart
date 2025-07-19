import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:securetradeai/Data/Api.dart';
import 'package:securetradeai/model/repoModel.dart';
import 'package:securetradeai/src/Homepage/SubbinMode.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/method/homepageProvider.dart';

class CopyTrading extends StatefulWidget {
  const CopyTrading({Key? key}) : super(key: key);

  @override
  State<CopyTrading> createState() => _CopyTradingState();
}

class _CopyTradingState extends State<CopyTrading> {
  String searchWords = "";
  bool isVisible = true;
  List<Map<String, dynamic>> traders = [];
  bool isLoading = true;
  Map<String, bool> activeCopyTrading = {};

  @override
  void initState() {
    super.initState();
    _loadTraders();
  }

  void _loadTraders() {
    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        traders = [
          {
            'id': '1',
            'name': 'Alex Thompson',
            'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
            'profit': '15.8',
            'trades': '156',
            'followers': '2.3K',
            'winRate': '78',
            'totalVolume': '1.2M',
            'minInvestment': '100',
            'copyFee': '2%',
            'strategy': 'Swing Trading',
            'experience': '5 years',
            'description': 'Specialized in crypto swing trading with focus on BTC and ETH pairs.',
          },
          {
            'id': '2',
            'name': 'Sarah Chen',
            'avatar': 'https://randomuser.me/api/portraits/women/2.jpg',
            'profit': '12.5',
            'trades': '89',
            'followers': '1.8K',
            'winRate': '82',
            'totalVolume': '890K',
            'minInvestment': '50',
            'copyFee': '1.5%',
            'strategy': 'Scalping',
            'experience': '3 years',
            'description': 'Expert in high-frequency trading with quick entry and exit points.',
          },
          {
            'id': '3',
            'name': 'Michael Rodriguez',
            'avatar': 'https://randomuser.me/api/portraits/men/3.jpg',
            'profit': '18.2',
            'trades': '234',
            'followers': '3.1K',
            'winRate': '75',
            'totalVolume': '2.1M',
            'minInvestment': '200',
            'copyFee': '2.5%',
            'strategy': 'Trend Following',
            'experience': '7 years',
            'description': 'Long-term trend analysis with focus on market cycles.',
          },
          {
            'id': '4',
            'name': 'Emma Wilson',
            'avatar': 'https://randomuser.me/api/portraits/women/4.jpg',
            'profit': '9.7',
            'trades': '67',
            'followers': '1.2K',
            'winRate': '85',
            'totalVolume': '750K',
            'minInvestment': '75',
            'copyFee': '1.8%',
            'strategy': 'Breakout Trading',
            'experience': '4 years',
            'description': 'Specialized in identifying and trading breakout patterns.',
          },
          {
            'id': '5',
            'name': 'David Kim',
            'avatar': 'https://randomuser.me/api/portraits/men/5.jpg',
            'profit': '21.3',
            'trades': '178',
            'followers': '4.2K',
            'winRate': '80',
            'totalVolume': '3.2M',
            'minInvestment': '150',
            'copyFee': '2.2%',
            'strategy': 'Momentum Trading',
            'experience': '6 years',
            'description': 'Expert in momentum trading with focus on volume analysis.',
          },
        ];
        
        // Initialize active copy trading
        for (var trader in traders) {
          activeCopyTrading[trader['id']] = false;
        }
        
        isLoading = false;
      });
    });
  }

  void _toggleCopyTrading(String traderId) {
    setState(() {
      activeCopyTrading[traderId] = !(activeCopyTrading[traderId] ?? false);
      
      // Show confirmation dialog
      if (activeCopyTrading[traderId] == true) {
        _showActivationDialog(traderId);
      } else {
        _showDeactivationDialog(traderId);
      }
    });
  }

  void _showActivationDialog(String traderId) {
    final trader = traders.firstWhere((t) => t['id'] == traderId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2234),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2A3A5A)),
        ),
        title: const Text(
          'Start Copy Trading',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to start copy trading with ${trader['name']}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Strategy', trader['strategy']?.toString() ?? 'Not specified'),
            _buildInfoRow('Experience', trader['experience']?.toString() ?? 'Not specified'),
            _buildInfoRow('Min Investment', '\$${trader['minInvestment']?.toString() ?? "0"}'),
            _buildInfoRow('Copy Fee', trader['copyFee']?.toString() ?? 'Not specified'),
            const SizedBox(height: 16),
            Text(
              trader['description'] ?? 'No description available.',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                activeCopyTrading[traderId] = false;
              });
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF5C9CE6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showSuccessDialog(traderId, true);
              },
              child: const Text('Start Copying', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeactivationDialog(String traderId) {
    final trader = traders.firstWhere((t) => t['id'] == traderId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2234),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2A3A5A)),
        ),
        title: const Text(
          'Stop Copy Trading',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to stop copy trading with ${trader['name']}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                activeCopyTrading[traderId] = true;
              });
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE53935), Color(0xFFEF5350)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showSuccessDialog(traderId, false);
              },
              child: const Text('Stop Copying', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String traderId, bool activated) {
    final trader = traders.firstWhere((t) => t['id'] == traderId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2234),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2A3A5A)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              activated ? Icons.check_circle : Icons.info_outline,
              color: activated ? const Color(0xFF00C853) : const Color(0xFFE53935),
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              activated ? 'Copy Trading Started' : 'Copy Trading Stopped',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              activated 
                  ? 'You are now copy trading with ${trader['name']}'
                  : 'You have stopped copy trading with ${trader['name']}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF5C9CE6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0E17),
      child: Column(
        children: [
      

          // Market Overview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF121824),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF2A3A5A),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Market Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildMarketOverviewCard(
                        'Active Traders',
                        '${traders.length}',
                        '+5.2%',
                        Icons.people,
                        const Color(0xFF4A90E2),
                      ),
                      const SizedBox(width: 16),
                      _buildMarketOverviewCard(
                        'Total Volume',
                        '\$2.5M',
                        '+3.8%',
                        Icons.bar_chart,
                        const Color(0xFFFF9800),
                      ),
                      const SizedBox(width: 16),
                      _buildMarketOverviewCard(
                        'Avg. Return',
                        '12.5%',
                        '+1.2%',
                        Icons.trending_up,
                        const Color(0xFF00C853),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF121824),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF2A3A5A),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2234),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF2A3A5A),
                        width: 1,
                      ),
                    ),
                    child: const TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search traders...',
                        hintStyle: TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.search, color: Color(0xFF4A90E2)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2234),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF2A3A5A),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, color: Color(0xFF4A90E2)),
                    onPressed: () {
                      // Add filter functionality
                    },
                  ),
                ),
              ],
            ),
          ),

          // Traders List
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4A90E2),
                    ),
                  )
                : traders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.grey[400],
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No traders available',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: traders.length,
                        itemBuilder: (context, index) {
                          final trader = traders[index];
                          final isActive = activeCopyTrading[trader['id']] ?? false;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A2234),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isActive ? const Color(0xFF00C853) : const Color(0xFF2A3A5A),
                                width: isActive ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _showTraderDetails(trader),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      /// Trader Info
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundImage: NetworkImage(trader['avatar'] ?? ""),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  trader['name'] ?? "",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  trader['strategy'] ?? 'Not specified',
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF00C853).withOpacity(0.1),
                                              border: Border.all(
                                                color: const Color(0xFF00C853),
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              '+${trader['profit']}%',
                                              style: const TextStyle(
                                                color: Color(0xFF00C853),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      const Divider(color: Color(0xFF2A3A5A)),
                                      const SizedBox(height: 16),
                                      // Performance Stats
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildPerformanceStat('Win Rate', '${trader['winRate']}%', Icons.check_circle, const Color(0xFF00C853)),
                                          _buildPerformanceStat('Followers', trader['followers'], Icons.people, const Color(0xFF4A90E2)),
                                          _buildPerformanceStat('Trades', trader['trades'], Icons.swap_horiz, const Color(0xFFFF9800)),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      // Copy Button
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF4A90E2),
                                              Color(0xFF5C9CE6),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF4A90E2).withOpacity(0.3),
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () => _toggleCopyTrading(trader['id']),
                                            borderRadius: BorderRadius.circular(8),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              child: Center(
                                                child: Text(
                                                  isActive ? 'Copying' : 'Copy Trader',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketOverviewCard(String title, String value, String change, IconData icon, Color color) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2234),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2A3A5A),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: change.startsWith('+') 
                ? const Color(0xFF00C853).withOpacity(0.1)
                : const Color(0xFFE53935).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              change,
              style: TextStyle(
                color: change.startsWith('+') ? const Color(0xFF00C853) : const Color(0xFFE53935),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showCopyTradingDialog(Map<String, dynamic> trader) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.white.withOpacity(0.1))
        ),
        title: Text(
          'Copy ${trader['username']}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Investment Amount (USDT)',
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1))
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1))
                ),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                labelText: 'Max Trades Per Day',
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1))
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1))
                ),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement copy trading logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)
              ),
            ),
            child: const Text('Start Copying'),
          ),
        ],
      ),
    );
  }

  void _showTraderDetails(Map<String, dynamic> trader) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(trader['profile_image']),
            ),
            const SizedBox(height: 15),
            Text(
              trader['username'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Profit: \$${trader['total_profit']}',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailColumn('Success Rate', '${trader['success_rate']}%'),
                _buildDetailColumn('Total Trades', trader['total_trades']),
                _buildDetailColumn('Followers', trader['total_followers']),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Preferred Trading Pairs',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: trader['preferred_pairs'].map<Widget>((pair) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pair,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 14
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showCopyTradingDialog(trader);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
                ),
              ),
              child: const Text(
                'Copy Trades',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold
          ),
        ),
      ],
    );
  }
}