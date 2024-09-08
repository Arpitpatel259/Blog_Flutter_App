import 'package:blog/Authentication/authentication.dart';
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
      backgroundColor: const Color(0xffffffff),
      body: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Lottie.asset(
                'assets/animations/AppUnderMaintainance.json',
                // Replace with your local Lottie JSON file path
                height: 300,
                width: 300,
                fit: BoxFit.cover,
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: Text(
                  "Under Maintanance :-(",
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    fontSize: 20,
                    color: Color(0xff000000),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: Text(
                  "Please check back soon just putting little touch up on some pretty updates.",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    color: Color(0xff727272),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: MaterialButton(
                  onPressed: () {
                    AuthMethods().checkIfAlreadyLogin();
                  },
                  color: const Color(0xff3a57e8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26.0),
                  ),
                  padding: const EdgeInsets.all(16),
                  textColor: const Color(0xffffffff),
                  height: 45,
                  minWidth: MediaQuery.of(context).size.width * 0.6,
                  child: const Text(
                    "Check Again",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
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
