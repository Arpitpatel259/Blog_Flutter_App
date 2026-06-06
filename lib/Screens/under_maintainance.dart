import 'package:blog/Authentication/authentication.dart';
import 'package:blog/Utilities/constant.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class UnderMaintainance extends StatefulWidget {
  const UnderMaintainance({super.key});

  @override
  State<UnderMaintainance> createState() => _UnderMaintainanceState();
}

class _UnderMaintainanceState extends State<UnderMaintainance> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurfaceColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/AppUnderMaintainance.json',
                height: 280,
                width: 280,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.settings_suggest_rounded, size: 100, color: kAccentColor),
              ),
              const SizedBox(height: 24),
              Text(
                "Under Maintenance",
                textAlign: TextAlign.center,
                style: kTitleStyle,
              ),
              const SizedBox(height: 12),
              Text(
                "We're currently performing some scheduled updates to improve your experience. Please check back in a few minutes.",
                textAlign: TextAlign.center,
                style: kSubtitleStyle,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    AuthMethods().checkIfAlreadyLogin();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: kSurfaceColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kDefaultRadius),
                    ),
                  ),
                  child: const Text(
                    "Check Again",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
