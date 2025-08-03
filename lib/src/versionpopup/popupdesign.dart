import 'package:flutter/material.dart';

class CustomDialogBox extends StatefulWidget {
  final String title, descriptions, text;
  final Function onclick;
  const CustomDialogBox({
    Key? key,
    required this.title,
    required this.descriptions,
    required this.text,
    required this.onclick,
  }) : super(key: key);

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back button from dismissing the dialog
        return false;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: contentBox(context),
      ),
    );
  }

  contentBox(context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2329), // App's dark background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF474D57), // App's border color
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 0,
          ),
          BoxShadow(
            color:
                const Color(0xFFF0B90B).withOpacity(0.1), // Binance yellow glow
            offset: const Offset(0, 0),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // App Logo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2B3139), // Card background
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF0B90B).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Image.asset(
              "assets/img/logo.png",
              height: 60,
              width: 60,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEAECEF), // App's primary text color
              fontFamily: "Nunito",
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            widget.descriptions,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF848E9C), // App's secondary text color
              fontFamily: "Nunito",
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Update Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF0B90B), // Binance yellow
                  Color(0xFFE6A500), // Darker yellow
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF0B90B).withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                widget.onclick();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2329), // Dark text on yellow button
                      fontFamily: "Nunito",
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Warning text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEA4335).withOpacity(0.1), // Red background
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFEA4335).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFEA4335),
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "App will not work until updated",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFEA4335),
                      fontFamily: "Nunito",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
