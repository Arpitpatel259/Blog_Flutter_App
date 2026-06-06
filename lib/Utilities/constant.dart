import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Modern Design System ---

// Colors
const Color kPrimaryColor = Color(0xFF6366F1);   // Modern Indigo
const Color kAccentColor = Color(0xFF818CF8);    // Lighter Indigo
const Color kSurfaceColor = Colors.white;
const Color kBackgroundColor = Color(0xFFF8FAFC); // Slate 50

const Color kTextPrimary = Color(0xFF0F172A);    // Slate 900
const Color kTextSecondary = Color(0xFF475569);  // Slate 600
const Color kTextLight = Color(0xFF94A3B8);      // Slate 400

const Color kInputBorder = Color(0xFFE2E8F0);    // Slate 200
const Color kInputFill = Color(0xFFF1F5F9);      // Slate 100
const Color kErrorColor = Color(0xFFEF4444);     // Red 500
const Color kSuccessColor = Color(0xFF10B981);   // Emerald 500

// Spacing & Radius
const double kDefaultPadding = 20.0;
const double kDefaultRadius = 16.0;
const double kCardRadius = 24.0;

// Shadows
List<BoxShadow> kSoftShadow = [
  BoxShadow(
    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
    blurRadius: 20,
    offset: const Offset(0, 8),
  ),
];

// Typography (Using Google Fonts for premium feel)
final TextStyle kHeadingStyle = GoogleFonts.plusJakartaSans(
  fontSize: 28,
  fontWeight: FontWeight.w800,
  color: kTextPrimary,
  letterSpacing: -0.5,
);

final TextStyle kTitleStyle = GoogleFonts.plusJakartaSans(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: kTextPrimary,
);

final TextStyle kSubtitleStyle = GoogleFonts.inter(
  fontSize: 16,
  color: kTextSecondary,
  height: 1.6,
);

final TextStyle kLabelStyle = GoogleFonts.inter(
  fontWeight: FontWeight.w600,
  fontSize: 14,
  color: kTextPrimary,
);

final TextStyle kBodyStyle = GoogleFonts.inter(
  fontSize: 14,
  color: kTextSecondary,
  height: 1.5,
);

final TextStyle kButtonStyle = GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.5,
);
