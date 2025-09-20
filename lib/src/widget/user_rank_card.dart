import 'package:flutter/material.dart';
import 'package:rapidtradeai/model/userRankModel.dart';

import '../Service/assets_service.dart';

class UserRankCard extends StatelessWidget {
  final UserRankData rankData;
  final VoidCallback? onTap;

  const UserRankCard({
    Key? key,
    required this.rankData,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getRankColor(rankData.currentRank).withOpacity(0.1),
              _getRankColor(rankData.currentRank).withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getRankColor(rankData.currentRank).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with rank and progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getRankIcon(rankData.currentRank),
                          color: _getRankColor(rankData.currentRank),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          rankData.currentRank,
                          style: TextStyle(
                            color: _getRankColor(rankData.currentRank),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rankData.name,
                      style: const TextStyle(
                        color: Color(0xFF848E9C),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getRankColor(rankData.currentRank).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${rankData.progressPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: _getRankColor(rankData.currentRank),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress to ${rankData.nextRank}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '\$${rankData.teamBusiness.toStringAsFixed(0)} / \$${rankData.nextRankRequirement.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF848E9C),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: rankData.progressPercentage / 100,
                  backgroundColor: const Color(0xFF2A2D35),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getRankColor(rankData.currentRank),
                  ),
                  minHeight: 6,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Stats grid
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Team Business',
                    '\$${rankData.teamBusiness.toStringAsFixed(0)}',
                    Icons.business,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Direct Referrals',
                    '${rankData.directReferrals}',
                    Icons.person_add,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Team Members',
                    '${rankData.teamMembers}',
                    Icons.group,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Total Earnings',
                    '\$${rankData.totalEarnings.toStringAsFixed(2)}',
                    Icons.account_balance_wallet,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2026),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A2D35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF848E9C),
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF848E9C),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(String rank) {
    switch (rank.toLowerCase()) {
      case 'starter':
        return const Color(0xFF848E9C);
      case 'builder':
        return const Color(0xFF4A90E2);
      case 'leader':
        return const Color(0xFF0ECB81);
      case 'manager':
        return TradingTheme.secondaryAccent;
      case 'director':
        return const Color(0xFFE53935);
      case 'executive':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF848E9C);
    }
  }

  IconData _getRankIcon(String rank) {
    switch (rank.toLowerCase()) {
      case 'starter':
        return Icons.star_border;
      case 'builder':
        return Icons.build;
      case 'leader':
        return Icons.trending_up;
      case 'manager':
        return Icons.supervisor_account;
      case 'director':
        return Icons.business_center;
      case 'executive':
        return Icons.diamond;
      default:
        return Icons.star_border;
    }
  }
}
