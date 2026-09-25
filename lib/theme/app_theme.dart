import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UnoPalette {
  final Color bgBase;
  final Color bgSurface;
  final Color bgElevated;
  final Color div;
  final Color accent;
  final Color output;
  final Color live;
  final Color confirmed;
  final Color inferred;
  final Color neutral;
  final Color text;
  final Color textSec;

  const UnoPalette({
    required this.bgBase,
    required this.bgSurface,
    required this.bgElevated,
    required this.div,
    required this.accent,
    required this.output,
    required this.live,
    required this.confirmed,
    required this.inferred,
    required this.neutral,
    required this.text,
    required this.textSec,
  });

  static const dark = UnoPalette(
    bgBase: Color(0xFF181816),
    bgSurface: Color(0xFF21211E),
    bgElevated: Color(0xFF2A2A26),
    div: Color(0xFF33332E),
    accent: Color(0xFFDA7756),
    output: Color(0xFFE59866),
    live: Color(0xFF52B788),
    confirmed: Color(0xFFE07A5F),
    inferred: Color(0xFFDA7756),
    neutral: Color(0xFF68A090),
    text: Color(0xFFF0EFEA),
    textSec: Color(0xFFA3A199),
  );

  static const light = UnoPalette(
    bgBase: Color(0xFFFAF8F5),
    bgSurface: Color(0xFFF3EFE6),
    bgElevated: Color(0xFFFFFFFF),
    div: Color(0xFFE6E5DF),
    accent: Color(0xFFDA7756),
    output: Color(0xFFC97A3E),
    live: Color(0xFF3B9B85),
    confirmed: Color(0xFFC05A6E),
    inferred: Color(0xFFD96B43),
    neutral: Color(0xFF4A7C6E),
    text: Color(0xFF1D1C1A),
    textSec: Color(0xFF706E6B),
  );

  // Query tiers
  static const queryCold = Color(0xFF6EC8B8);
  static const queryWarm = Color(0xFFE8A455);
  static const queryHot = Color(0xFFD4725A);

  // Confidence tiers
  static const confConfirmed = Color(0xFFD4909A);
  static const confUncertain = Color(0xFFD4A843);
  static const confInsufficient = Color(0xFFA89070);

  // Entity types
  static const entityService = Color(0xFF6EC8B8);
  static const entityDecision = Color(0xFFE8A455);
  static const entityCommit = Color(0xFFD4A843);
  static const entityTicket = Color(0xFFD4909A);
  static const entityThread = Color(0xFFD4725A);
  static const entityPerson = Color(0xFFA89070);
}

class UnoTypography {
  static TextStyle displaySerif({
    required UnoPalette palette,
    double fontSize = 26,
    FontWeight fontWeight = FontWeight.w400,
    double lineHeight = 1.2,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return GoogleFonts.instrumentSerif(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: palette.text,
      fontStyle: fontStyle,
      height: lineHeight,
    );
  }

  static TextStyle brandSerif({
    required UnoPalette palette,
    double fontSize = 17,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.youngSerif(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: palette.text,
      letterSpacing: -0.2,
    );
  }

  static TextStyle mono({
    required Color color,
    double fontSize = 11,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0.5,
  }) {
    return GoogleFonts.ibmPlexMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle body({
    required Color color,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    double height = 1.5,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }
}
