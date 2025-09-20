import 'package:flutter/material.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';

/// Common App Bar Types
enum AppBarType {
  basic, // Simple app bar with title and back button
  trading, // Trading themed app bar with gradient badge
  profile, // Profile themed app bar
  analytics, // Analytics/Reports themed app bar
  custom, // Custom themed app bar with custom colors
}

/// Common App Bar Widget - Reusable across the entire application
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final AppBarType type;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? iconColor;
  final String? badgeText;
  final IconData? badgeIcon;
  final int? badgeCount;
  final bool? centerTitle;
  final double elevation;
  final Widget? customTitle;
  final PreferredSizeWidget? bottom;
  final TabBar? tabBar;
  final List<String>? tabTitles;
  final TabController? tabController;
  final bool showDropdown;
  final VoidCallback? onDropdownTap;

  const CommonAppBar({
    Key? key,
    required this.title,
    this.type = AppBarType.basic,
    this.actions,
    this.onBackPressed,
    this.showBackButton = true,
    this.leading,
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
    this.badgeText,
    this.badgeIcon,
    this.badgeCount,
    this.centerTitle = false,
    this.elevation = 0,
    this.customTitle,
    this.bottom,
    this.tabBar,
    this.tabTitles,
    this.tabController,
    this.showDropdown = false,
    this.onDropdownTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: customTitle ?? _buildTransparentTitle(),
      leading: _buildTransparentLeading(context),
      actions: _buildTransparentActions(),
      iconTheme: IconThemeData(color: _getIconColor()),
      bottom: bottom ?? _buildTransparentTabBar(),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
      ),
    );
  }

  /// Build transparent title with no background
  Widget _buildTransparentTitle() {
    // Check if this is a trading title with dropdown
    if (showDropdown) {
      return _buildTradingTitleWithDropdown();
    }

    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 18,
        fontFamily: fontFamily,
        letterSpacing: 0.3,
      ),
    );
  }

  /// Build trading title with dropdown for exchange selection
  Widget _buildTradingTitleWithDropdown() {
    return GestureDetector(
      onTap: onDropdownTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
              fontFamily: fontFamily,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 20,
          ),
        ],
      ),
    );
  }

  /// Build transparent leading button with light border and glow
  Widget? _buildTransparentLeading(BuildContext context) {
    if (leading != null) return leading;

    if (!showBackButton) return null;

    return Container(
      margin: const EdgeInsets.all(6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 6,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 18,
          ),
          onPressed: onBackPressed ?? () => Navigator.pop(context),
          padding: const EdgeInsets.all(8),
        ),
      ),
    );
  }

  /// Build transparent actions with light border and glow
  List<Widget>? _buildTransparentActions() {
    if (actions == null) return null;

    return actions!.map((action) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 6,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: action is IconButton
            ? IconButton(
                icon: action.icon,
                onPressed: action.onPressed,
                color: Colors.white,
                padding: const EdgeInsets.all(8),
              )
            : action,
      );
    }).toList();
  }

  /// Build transparent TabBar with no background
  PreferredSizeWidget? _buildTransparentTabBar() {
    if (tabBar != null) return tabBar;
    if (tabTitles == null || tabTitles!.isEmpty) return null;

    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: Container(
        color: Colors.transparent,
        child: TabBar(
          controller: tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[400],
          indicatorColor: _getAccentColor(),
          indicatorWeight: 2,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: fontFamily,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            fontFamily: fontFamily,
          ),
          tabs: tabTitles!
              .map((title) => Tab(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Text(title),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  /// Build stylish title with modern effects
  Widget _buildStylishTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getAccentColor().withOpacity(0.15),
            _getAccentColor().withOpacity(0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getAccentColor().withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _getAccentColor().withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          fontFamily: fontFamily,
          letterSpacing: 0.5,
          shadows: [
            Shadow(
              color: _getAccentColor().withOpacity(0.3),
              offset: const Offset(0, 1),
              blurRadius: 3,
            ),
            const Shadow(
              color: Colors.black,
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  /// Build clean, minimalist title like in the reference image
  Widget _buildCleanTitle() {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 18,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
      ),
    );
  }

  /// Build stylish leading button with modern effects
  Widget? _buildStylishLeading(BuildContext context) {
    if (leading != null) return leading;

    if (!showBackButton) return null;

    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getAccentColor().withOpacity(0.15),
            _getAccentColor().withOpacity(0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getAccentColor().withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _getAccentColor().withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
          size: 18,
          shadows: [
            Shadow(
              color: _getAccentColor().withOpacity(0.3),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  /// Build stylish actions with modern effects
  List<Widget>? _buildStylishActions() {
    if (actions == null) return null;

    return actions!.map((action) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getAccentColor().withOpacity(0.15),
              _getAccentColor().withOpacity(0.05),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getAccentColor().withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _getAccentColor().withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: action,
      );
    }).toList();
  }

  /// Build clean, minimalist leading button
  Widget? _buildCleanLeading(BuildContext context) {
    if (leading != null) return leading;

    if (!showBackButton) return null;

    return IconButton(
      icon: const Icon(
        Icons.arrow_back_ios,
        color: Colors.white,
        size: 20,
      ),
      onPressed: onBackPressed ?? () => Navigator.pop(context),
      padding: const EdgeInsets.all(12),
    );
  }

  /// Build clean, minimalist actions
  List<Widget>? _buildCleanActions() {
    if (actions == null) return null;

    return actions!.map((action) {
      // If it's an IconButton, ensure it has the right styling
      if (action is IconButton) {
        return IconButton(
          icon: action.icon,
          onPressed: action.onPressed,
          color: Colors.white,
          padding: const EdgeInsets.all(12),
        );
      }
      return action;
    }).toList();
  }

  /// Get stylish gradient background
  LinearGradient _getStylishGradient() {
    if (backgroundColor != null) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          backgroundColor!,
          backgroundColor!.withOpacity(0.8),
          backgroundColor!.withOpacity(0.6),
        ],
        stops: const [0.0, 0.7, 1.0],
      );
    }

    switch (type) {
      case AppBarType.trading:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D3748), // Dark blue-grey
            Color(0xFF1A202C), // Darker
            Color(0xFF0F1419), // Darkest
          ],
          stops: [0.0, 0.7, 1.0],
        );
      case AppBarType.analytics:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D3748), // Dark blue-grey
            Color(0xFF1A202C), // Darker
            Color(0xFF0F1419), // Darkest
          ],
          stops: [0.0, 0.7, 1.0],
        );
      case AppBarType.profile:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D3748), // Dark blue-grey
            Color(0xFF1A202C), // Darker
            Color(0xFF0F1419), // Darkest
          ],
          stops: [0.0, 0.7, 1.0],
        );
      case AppBarType.custom:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor ?? const Color(0xFF2D3748),
            (backgroundColor ?? const Color(0xFF2D3748)).withOpacity(0.8),
            (backgroundColor ?? const Color(0xFF2D3748)).withOpacity(0.6),
          ],
          stops: const [0.0, 0.7, 1.0],
        );
      case AppBarType.basic:
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D3748), // Dark blue-grey
            Color(0xFF1A202C), // Darker
            Color(0xFF0F1419), // Darkest
          ],
          stops: [0.0, 0.7, 1.0],
        );
    }
  }

  /// Build stylish overlay with subtle effects
  Widget _buildStylishOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.02),
              Colors.transparent,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Subtle accent glow
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 100,
                height: 60,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.0,
                    colors: [
                      _getAccentColor().withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get clean background color
  Color _getCleanBackgroundColor() {
    if (backgroundColor != null) return backgroundColor!;

    switch (type) {
      case AppBarType.trading:
        return const Color(0xFF2B2B2B); // Slightly lighter for better contrast
      case AppBarType.analytics:
        return const Color(0xFF2B2B2B);
      case AppBarType.profile:
        return const Color(0xFF2B2B2B);
      case AppBarType.custom:
        return backgroundColor ?? const Color(0xFF2B2B2B);
      case AppBarType.basic:
      default:
        return const Color(0xFF2B2B2B);
    }
  }

  /// Build ultra-modern title with stunning effects
  Widget _buildUltraModernTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getAccentColor().withOpacity(0.15),
            _getAccentColor().withOpacity(0.08),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getAccentColor().withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getAccentColor().withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Accent dot indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getAccentColor(),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getAccentColor().withOpacity(0.6),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Title text
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              fontFamily: fontFamily,
              letterSpacing: 1.0,
              shadows: [
                Shadow(
                  color: _getAccentColor().withOpacity(0.5),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
                const Shadow(
                  color: Colors.black,
                  offset: Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build enhanced title with animations and effects
  Widget _buildEnhancedTitle() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: _buildTitle(),
    );
  }

  /// Build the title widget based on app bar type
  Widget _buildTitle() {
    // Use transparent title for all types to blend with background
    return _buildTransparentTitle();
  }

  /// Build enhanced basic title with glow effect
  Widget _buildEnhancedBasicTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getAccentColor().withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        border: Border.all(
          color: _getAccentColor().withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _getAccentColor().withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Text(
        title,
        style: TextStyle(
          color: _getTitleColor(),
          fontWeight: FontWeight.w700,
          fontSize: 18,
          fontFamily: fontFamily,
          letterSpacing: 0.5,
          shadows: [
            Shadow(
              color: _getAccentColor().withOpacity(0.3),
              offset: const Offset(0, 1),
              blurRadius: 3,
            ),
          ],
        ),
      ),
    );
  }

  /// Build enhanced trading themed title with animated badge
  Widget _buildEnhancedTradingTitle() {
    return Row(
      children: [
        if (badgeIcon != null || badgeText != null || badgeCount != null)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  TradingTheme.secondaryAccent,
                  Color(0xFFE0AA0A),
                  Color(0xFFD4A309),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: TradingTheme.primaryAccent.withOpacity(0.4),
                  spreadRadius: 0,
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (badgeIcon != null)
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      badgeIcon,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                if (badgeIcon != null &&
                    (badgeText != null || badgeCount != null))
                  const SizedBox(width: 8),
                if (badgeText != null)
                  Text(
                    badgeText!,
                    style: TradingTypography.bodyMedium.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                if (badgeCount != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: TradingTypography.bodyMedium.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (badgeIcon != null || badgeText != null || badgeCount != null)
          const SizedBox(width: 18),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              title,
              style: TradingTypography.heading3.copyWith(
                shadows: [
                  Shadow(
                    color: TradingTheme.primaryAccent.withOpacity(0.3),
                    offset: const Offset(0, 1),
                    blurRadius: 4,
                  ),
                ],
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  /// Build ultra-modern analytics title
  Widget _buildUltraModernAnalyticsTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4A90E2).withOpacity(0.15),
            const Color(0xFF4A90E2).withOpacity(0.08),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4A90E2).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Blue accent dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A90E2).withOpacity(0.6),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Title text
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              fontFamily: fontFamily,
              letterSpacing: 1.0,
              shadows: [
                Shadow(
                  color: const Color(0xFF4A90E2).withOpacity(0.5),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
                const Shadow(
                  color: Colors.black,
                  offset: Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Build enhanced analytics themed title without icon
  Widget _buildEnhancedAnalyticsTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4A90E2).withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4A90E2).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Text(
        title,
        style: TradingTypography.heading3.copyWith(
          shadows: [
            Shadow(
              color: const Color(0xFF4A90E2).withOpacity(0.3),
              offset: const Offset(0, 1),
              blurRadius: 4,
            ),
          ],
          letterSpacing: 0.5,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Build enhanced profile themed title
  Widget _buildEnhancedProfileTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00C853).withOpacity(0.2),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00C853).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C853).withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          fontFamily: fontFamily,
          letterSpacing: 0.5,
          shadows: [
            Shadow(
              color: Color(0xFF00C853),
              offset: Offset(0, 1),
              blurRadius: 3,
            ),
          ],
        ),
      ),
    );
  }

  /// Build enhanced custom themed title
  Widget _buildEnhancedCustomTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (titleColor ?? _getAccentColor()).withOpacity(0.2),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (titleColor ?? _getAccentColor()).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (titleColor ?? _getAccentColor()).withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          fontFamily: fontFamily,
          letterSpacing: 0.5,
          shadows: [
            Shadow(
              color: (titleColor ?? _getAccentColor()).withOpacity(0.5),
              offset: const Offset(0, 1),
              blurRadius: 3,
            ),
          ],
        ),
      ),
    );
  }

  /// Build ultra-modern leading widget with stunning effects
  Widget? _buildUltraModernLeading(BuildContext context) {
    if (leading != null) return leading;

    if (!showBackButton) return null;

    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getAccentColor().withOpacity(0.2),
            _getAccentColor().withOpacity(0.1),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getAccentColor().withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getAccentColor().withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
            shadows: [
              Shadow(
                color: _getAccentColor().withOpacity(0.6),
                offset: const Offset(0, 1),
                blurRadius: 4,
              ),
              const Shadow(
                color: Colors.black,
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
      ),
    );
  }

  /// Build enhanced leading widget with glow effect
  Widget? _buildEnhancedLeading(BuildContext context) {
    if (leading != null) return leading;

    if (!showBackButton) return null;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getAccentColor().withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getAccentColor().withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _getAccentColor().withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: _getIconColor(),
          size: 20,
          shadows: [
            Shadow(
              color: _getAccentColor().withOpacity(0.3),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
      ),
    );
  }

  /// Build ultra-modern actions with stunning effects
  List<Widget>? _buildUltraModernActions() {
    if (actions == null) return null;

    return actions!.map((action) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getAccentColor().withOpacity(0.2),
              _getAccentColor().withOpacity(0.1),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getAccentColor().withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _getAccentColor().withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, 0),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
          ),
          child: action,
        ),
      );
    }).toList();
  }

  /// Build enhanced actions with glow effects
  List<Widget>? _buildEnhancedActions() {
    if (actions == null) return null;

    return actions!.map((action) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getAccentColor().withOpacity(0.1),
              Colors.transparent,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getAccentColor().withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _getAccentColor().withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: action,
      );
    }).toList();
  }

  /// Build stylish TabBar for bottom
  PreferredSizeWidget? _buildStylishTabBar() {
    if (tabBar != null) return tabBar;
    if (tabTitles == null || tabTitles!.isEmpty) return null;

    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getAccentColor().withOpacity(0.08),
              Colors.transparent,
            ],
          ),
          border: Border(
            top: BorderSide(
              color: _getAccentColor().withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: TabBar(
          controller: tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[400],
          indicatorColor: _getAccentColor(),
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: fontFamily,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            fontFamily: fontFamily,
          ),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getAccentColor().withOpacity(0.2),
                _getAccentColor().withOpacity(0.1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _getAccentColor().withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          tabs: tabTitles!
              .map((title) => Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Text(
                        title,
                        style: TextStyle(
                          shadows: [
                            Shadow(
                              color: _getAccentColor().withOpacity(0.3),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  /// Build clean, minimalist TabBar for bottom
  PreferredSizeWidget? _buildTabBar() {
    if (tabBar != null) return tabBar;
    if (tabTitles == null || tabTitles!.isEmpty) return null;

    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: Container(
        color: _getCleanBackgroundColor(),
        child: TabBar(
          controller: tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[400],
          indicatorColor: _getAccentColor(),
          indicatorWeight: 2,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: fontFamily,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            fontFamily: fontFamily,
          ),
          tabs: tabTitles!
              .map((title) => Tab(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Text(title),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  /// Build animated background with floating particles
  Widget _buildAnimatedBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 2.0,
            colors: [
              _getAccentColor().withOpacity(0.08),
              _getAccentColor().withOpacity(0.04),
              Colors.transparent,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Floating orbs
            Positioned(
              top: 10,
              right: 30,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: _getAccentColor().withOpacity(0.6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getAccentColor().withOpacity(0.4),
                      spreadRadius: 0,
                      blurRadius: 8,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 25,
              right: 80,
              child: Container(
                width: 2,
                height: 2,
                decoration: BoxDecoration(
                  color: _getAccentColor().withOpacity(0.4),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getAccentColor().withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 6,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 15,
              left: 50,
              child: Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build glass morphism overlay
  Widget _buildGlassMorphismOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
              Colors.transparent,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
      ),
    );
  }

  /// Build ultra-modern flexible space
  Widget? _buildUltraModernFlexibleSpace() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.02),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  /// Build flexible space with animated background
  Widget? _buildFlexibleSpace() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Subtle glow effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    _getAccentColor().withOpacity(0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get ultra-modern gradient with multiple layers and effects
  LinearGradient _getUltraModernGradient() {
    if (backgroundColor != null) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          backgroundColor!,
          backgroundColor!.withOpacity(0.9),
          backgroundColor!.withOpacity(0.7),
        ],
        stops: const [0.0, 0.5, 1.0],
      );
    }

    switch (type) {
      case AppBarType.trading:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A2F36), // Lighter start
            Color(0xFF1E2329), // Mid tone
            Color(0xFF161A1E), // Darker
            Color(0xFF0F1419), // Darkest
            Color(0xFF0A0E13), // Ultra dark
          ],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        );
      case AppBarType.analytics:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1F26), // Lighter start
            Color(0xFF161A1E), // Mid tone
            Color(0xFF0C0E12), // Darker
            Color(0xFF080A0E), // Darkest
            Color(0xFF050609), // Ultra dark
          ],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        );
      case AppBarType.profile:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1F2937), // Lighter start
            Color(0xFF1A2234), // Mid tone
            Color(0xFF161A1E), // Darker
            Color(0xFF0F1419), // Darkest
            Color(0xFF0A0E13), // Ultra dark
          ],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        );
      case AppBarType.custom:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor ?? TradingTheme.secondaryBackground,
            (backgroundColor ?? TradingTheme.secondaryBackground)
                .withOpacity(0.9),
            (backgroundColor ?? TradingTheme.secondaryBackground)
                .withOpacity(0.7),
          ],
          stops: const [0.0, 0.5, 1.0],
        );
      case AppBarType.basic:
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1F2937), // Lighter start
            Color(0xFF1A2234), // Mid tone
            Color(0xFF161A1E), // Darker
            Color(0xFF0F1419), // Darkest
            Color(0xFF0A0E13), // Ultra dark
          ],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        );
    }
  }

  /// Get enhanced background gradient based on app bar type
  LinearGradient _getBackgroundGradient() {
    if (backgroundColor != null) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          backgroundColor!,
          backgroundColor!.withOpacity(0.8),
        ],
      );
    }

    switch (type) {
      case AppBarType.trading:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E2329),
            Color(0xFF161A1E),
            Color(0xFF0F1419),
          ],
          stops: [0.0, 0.6, 1.0],
        );
      case AppBarType.analytics:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0C0E12),
            Color(0xFF161A1E),
            Color(0xFF1A1F26),
          ],
          stops: [0.0, 0.5, 1.0],
        );
      case AppBarType.profile:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF161A1E),
            Color(0xFF1A2234),
            Color(0xFF0F1419),
          ],
          stops: [0.0, 0.5, 1.0],
        );
      case AppBarType.custom:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor ?? TradingTheme.secondaryBackground,
            (backgroundColor ?? TradingTheme.secondaryBackground)
                .withOpacity(0.8),
          ],
        );
      case AppBarType.basic:
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF161A1E),
            Color(0xFF1A2234),
            Color(0xFF0F1419),
          ],
          stops: [0.0, 0.5, 1.0],
        );
    }
  }

  /// Get accent color for glows and highlights
  Color _getAccentColor() {
    switch (type) {
      case AppBarType.trading:
        return TradingTheme.primaryAccent;
      case AppBarType.analytics:
        return const Color(0xFF4A90E2);
      case AppBarType.profile:
        return const Color(0xFF00C853);
      case AppBarType.custom:
        return titleColor ?? TradingTheme.primaryAccent;
      case AppBarType.basic:
      default:
        return TradingTheme.primaryAccent;
    }
  }

  /// Get title color based on app bar type
  Color _getTitleColor() {
    if (titleColor != null) return titleColor!;

    switch (type) {
      case AppBarType.trading:
      case AppBarType.analytics:
        return TradingTheme.primaryText;
      case AppBarType.profile:
      case AppBarType.custom:
      case AppBarType.basic:
      default:
        return Colors.white;
    }
  }

  /// Get icon color based on app bar type
  Color _getIconColor() {
    if (iconColor != null) return iconColor!;

    switch (type) {
      case AppBarType.trading:
      case AppBarType.analytics:
        return TradingTheme.primaryText;
      case AppBarType.profile:
      case AppBarType.custom:
      case AppBarType.basic:
      default:
        return Colors.white;
    }
  }

  @override
  Size get preferredSize {
    double height = kToolbarHeight;

    // Add bottom widget height
    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }
    // Add TabBar height if present
    else if (tabBar != null) {
      height += tabBar!.preferredSize.height;
    }
    // Add custom TabBar height if using tabTitles
    else if (tabTitles != null && tabTitles!.isNotEmpty) {
      height += 48; // Default TabBar height
    }

    return Size.fromHeight(height);
  }

  /// Factory constructor for basic app bar
  factory CommonAppBar.basic({
    required String title,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    bool showBackButton = true,
    bool centerTitle = false,
    TabBar? tabBar,
    List<String>? tabTitles,
    TabController? tabController,
  }) {
    return CommonAppBar(
      title: title,
      type: AppBarType.basic,
      actions: actions,
      onBackPressed: onBackPressed,
      showBackButton: showBackButton,
      centerTitle: centerTitle,
      tabBar: tabBar,
      tabTitles: tabTitles,
      tabController: tabController,
    );
  }

  /// Factory constructor for trading app bar
  factory CommonAppBar.trading({
    required String title,
    String? badgeText,
    IconData? badgeIcon,
    int? badgeCount,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    bool showBackButton = true,
    bool showDropdown = false,
    VoidCallback? onDropdownTap,
  }) {
    return CommonAppBar(
      title: title,
      type: AppBarType.trading,
      badgeText: badgeText,
      badgeIcon: badgeIcon,
      badgeCount: badgeCount,
      actions: actions,
      onBackPressed: onBackPressed,
      showBackButton: showBackButton,
      showDropdown: showDropdown,
      onDropdownTap: onDropdownTap,
    );
  }

  /// Factory constructor for trading app bar with exchange dropdown
  factory CommonAppBar.tradingWithDropdown({
    required String title,
    required VoidCallback onDropdownTap,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    bool showBackButton = true,
  }) {
    return CommonAppBar(
      title: title,
      type: AppBarType.trading,
      actions: actions,
      onBackPressed: onBackPressed,
      showBackButton: showBackButton,
      showDropdown: true,
      onDropdownTap: onDropdownTap,
    );
  }

  /// Factory constructor for analytics app bar
  factory CommonAppBar.analytics({
    required String title,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    bool showBackButton = true,
  }) {
    return CommonAppBar(
      title: title,
      type: AppBarType.analytics,
      actions: actions,
      onBackPressed: onBackPressed,
      showBackButton: showBackButton,
    );
  }

  /// Factory constructor for profile app bar
  factory CommonAppBar.profile({
    required String title,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    bool showBackButton = true,
  }) {
    return CommonAppBar(
      title: title,
      type: AppBarType.profile,
      actions: actions,
      onBackPressed: onBackPressed,
      showBackButton: showBackButton,
    );
  }

  /// Factory constructor for custom app bar
  factory CommonAppBar.custom({
    required String title,
    Color? backgroundColor,
    Color? titleColor,
    Color? iconColor,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    bool showBackButton = true,
    bool centerTitle = false,
    double elevation = 0,
  }) {
    return CommonAppBar(
      title: title,
      type: AppBarType.custom,
      backgroundColor: backgroundColor,
      titleColor: titleColor,
      iconColor: iconColor,
      actions: actions,
      onBackPressed: onBackPressed,
      showBackButton: showBackButton,
      centerTitle: centerTitle,
      elevation: elevation,
    );
  }
}
