import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ClubDetail extends StatefulWidget {
  const ClubDetail({Key? key}) : super(key: key);

  @override
  _ClubDetailState createState() => _ClubDetailState();
}

class _ClubDetailState extends State<ClubDetail> {
  // Binance theme colors
  final Color backgroundColor = Color(0xFF1E2329);
  final Color cardColor = Color(0xFF2B3139);
  final Color primaryColor = Color(0xFFF0B90B);
  final Color successColor = Color(0xFF2EBD85);
  final Color dangerColor = Color(0xFFF6465D);
  final Color textColor = Colors.white;
  final Color secondaryTextColor = Color(0xFF848E9C);
  final Color borderColor = Color(0xFF373C3F);

  bool isLoading = false;
  Map<String, dynamic> clubData = {};
  List<Map<String, dynamic>> members = [];

  @override
  void initState() {
    super.initState();
    _loadClubData();
  }

  Future<void> _loadClubData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        clubData = {
          'clubName': 'Diamond Club',
          'level': 'Diamond',
          'totalMembers': 156,
          'activeMembers': 134,
          'totalEarnings': 45678.90,
          'monthlyEarnings': 3456.78,
        };

        members = List.generate(10, (index) => {
          'name': 'Member ${index + 1}',
          'level': 'Level ${(index % 3) + 1}',
          'joinDate': DateTime.now().subtract(Duration(days: index * 7)),
          'earnings': (1000.0 / (index + 1)).toStringAsFixed(2),
          'status': index % 4 == 0 ? 'Inactive' : 'Active',
        });
      });
    } catch (e) {
      print('Error loading club data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Club Details',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: _loadClubData,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primaryColor,
        backgroundColor: cardColor,
        onRefresh: _loadClubData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildClubOverview(),
              _buildClubStats(),
              _buildMembersList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClubOverview() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.diamond,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clubData['clubName'] ?? '',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        clubData['level'] ?? '',
                        style: TextStyle(
                          color: primaryColor,
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
        ],
      ),
    );
  }

  Widget _buildClubStats() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard(
                'Total Members',
                clubData['totalMembers']?.toString() ?? '0',
                Icons.people,
              ),
              SizedBox(width: 12),
              _buildStatCard(
                'Active Members',
                clubData['activeMembers']?.toString() ?? '0',
                Icons.person,
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard(
                'Total Earnings',
                '${clubData['totalEarnings']?.toStringAsFixed(2) ?? '0.00'} USDT',
                Icons.account_balance_wallet,
              ),
              SizedBox(width: 12),
              _buildStatCard(
                'Monthly Earnings',
                '${clubData['monthlyEarnings']?.toStringAsFixed(2) ?? '0.00'} USDT',
                Icons.calendar_today,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: primaryColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Members',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            final bool isActive = member['status'] == 'Active';

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Text(
                    member['name'][0],
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      member['name'],
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${member['earnings']} USDT',
                      style: TextStyle(
                        color: successColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Joined ${DateFormat('MMM dd, yyyy').format(member['joinDate'])}',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive
                              ? successColor.withOpacity(0.1)
                              : dangerColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          member['status'],
                          style: TextStyle(
                            color: isActive ? successColor : dangerColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
} 