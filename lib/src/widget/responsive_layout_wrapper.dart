import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rapidtradeai/src/utils/responsive_utils.dart';

/// Responsive layout wrapper that adapts the app layout for different screen sizes
class ResponsiveLayoutWrapper extends StatelessWidget {
  final Widget child;
  final bool centerContent;
  final double? maxWidth;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const ResponsiveLayoutWrapper({
    Key? key,
    required this.child,
    this.centerContent = true,
    this.maxWidth,
    this.padding,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // Add responsive padding
    if (padding != null || ResponsiveUtils.isWeb) {
      content = Padding(
        padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
        child: content,
      );
    }

    // Center content for web desktop view
    if (ResponsiveUtils.isWeb && centerContent && ResponsiveUtils.isDesktop(context)) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? ResponsiveUtils.maxContentWidth,
          ),
          child: content,
        ),
      );
    }

    // Add background color if specified
    if (backgroundColor != null) {
      content = Container(
        color: backgroundColor,
        child: content,
      );
    }

    return content;
  }
}

/// Responsive scaffold wrapper with proper web layout
class ResponsiveScaffold extends StatelessWidget {
  final Widget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool centerContent;
  final double? maxWidth;

  const ResponsiveScaffold({
    Key? key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.centerContent = true,
    this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar as PreferredSizeWidget?,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: ResponsiveLayoutWrapper(
        // centerContent: centerContent,
        maxWidth: maxWidth,
        child: body,
      ),
      bottomNavigationBar: ResponsiveUtils.isWeb && ResponsiveUtils.isDesktop(context)
          ? null // Hide bottom nav on desktop web
          : bottomNavigationBar,
    );
  }
}

/// Responsive card widget with proper sizing
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;

  const ResponsiveCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin ?? ResponsiveUtils.getResponsiveMargin(context),
      child: Card(
        color: color,
        elevation: elevation ?? ResponsiveUtils.getResponsiveElevation(context, 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? 
              BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context, 12.0)),
        ),
        child: 
          // padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
         child,
      
      ),
    );
  }
}

/// Responsive grid view with proper sizing
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double? childAspectRatio;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveGridView({
    Key? key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.childAspectRatio,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveUtils.getGridCrossAxisCount(
      context,
      mobileCount: mobileColumns,
      tabletCount: tabletColumns,
      desktopCount: desktopColumns,
    );

    return GridView.count(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio ?? 1.0,
      mainAxisSpacing: mainAxisSpacing ?? ResponsiveUtils.getResponsiveSpacing(context, 8.0),
      crossAxisSpacing: crossAxisSpacing ?? ResponsiveUtils.getResponsiveSpacing(context, 8.0),
      // padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
      shrinkWrap: shrinkWrap,
      physics: physics,
      children: children,
    );
  }
}

/// Responsive text widget with proper sizing
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? baseFontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    Key? key,
    this.style,
    this.baseFontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use much bigger base font size for web
    final adjustedBaseFontSize = baseFontSize != null
        ? (kIsWeb ? baseFontSize! * 1.6 : baseFontSize!) // Increased from 1.2 to 1.6
        : null;
    final responsiveFontSize = adjustedBaseFontSize != null
        ? ResponsiveUtils.getResponsiveFontSize(context, adjustedBaseFontSize)
        : null;

    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(
        fontSize: responsiveFontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive button with proper sizing
class ResponsiveButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsets? padding;
  final double? borderRadius;
  final double? elevation;
  final Size? minimumSize;

  const ResponsiveButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.elevation,
    this.minimumSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? ResponsiveUtils.getResponsiveBorderRadius(context, 8.0),
          ),
        ),
        elevation: elevation ?? ResponsiveUtils.getResponsiveElevation(context, 2.0),
        minimumSize: minimumSize,
      ),
      child: child,
    );
  }
}

/// Responsive dialog wrapper
class ResponsiveDialog extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final EdgeInsets? contentPadding;

  const ResponsiveDialog({
    Key? key,
    required this.child,
    this.title,
    this.actions,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dialogWidth = ResponsiveUtils.getDialogWidth(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
        ),
      ),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Padding(
                padding: ResponsiveUtils.getResponsivePadding(context),
                child: ResponsiveText(
                  title!,
                  baseFontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            Flexible(
              child: Padding(
                padding: contentPadding ?? ResponsiveUtils.getResponsivePadding(context),
                child: child,
              ),
            ),
            if (actions != null)
              Padding(
                padding: ResponsiveUtils.getResponsivePadding(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
