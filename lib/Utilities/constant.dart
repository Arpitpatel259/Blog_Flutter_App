import 'package:flutter/material.dart';

final kBoxDecorationStyle = BoxDecoration(
  color: const Color(0xFF6CA8F1),
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: const [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);

TextStyle kLabelStyle = const TextStyle(

  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontFamily: 'OpenSans',
);

TextStyle kHintTextStyle = const TextStyle(
  color: Colors.white54,
  fontFamily: 'OpenSans',
);

const kPrimaryColor = Color(0xFF6F35A5);
const kPrimaryLightColor = Color(0xFFF1E6FF);
const kPrimaryColor1 = Color(0xFFFF7643);
const kPrimaryLightColor1 = Color(0xFFFFECDF);
const kSecondaryColor = Color(0xFF979797);
const kTextColor = Color(0xFF757575);

const double defaultPadding = 16.0;