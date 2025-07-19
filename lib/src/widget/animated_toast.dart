import 'package:flutter/material.dart';

class AnimatedToast {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required String status,
    String? amount,
    String? currency,
    int durationSeconds = 5,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        // Auto dismiss after specified seconds
        Future.delayed(Duration(seconds: durationSeconds), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2026),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2D35), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF0B90B).withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success/Error icon with animation
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: status == 'success'
                              ? const Color(0xFF0ECB81).withOpacity(0.2)
                              : const Color(0xFFFF4C4C).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          status == 'success'
                              ? Icons.check_circle
                              : Icons.error,
                          color: status == 'success'
                              ? const Color(0xFF0ECB81)
                              : const Color(0xFFFF4C4C),
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Amount with animation (if provided)
                if (amount != null && currency != null)
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1200),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Text(
                          "$amount $currency",
                          style: const TextStyle(
                            color: Color(0xFFF0B90B),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                if (amount != null && currency != null)
                  const SizedBox(height: 15),

                // Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF848E9C),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),

                // Close button
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0B90B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
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
}
