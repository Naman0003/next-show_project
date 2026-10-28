import 'package:flutter/material.dart';

class AppTokens {
  AppTokens._();

  // Radii
  static const double radiusCard = 26.0;
  static const double radiusPill = 100.0;
  static const double radiusButton = 16.0;

  // Spacing
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 12.0;
  static const double spaceLG = 16.0;
  static const double spaceXL = 20.0;
  static const double spaceXXL = 24.0;

  // Dock Clearance
  // Ensures that scrollable content on each page never gets covered by the
  // floating glass dock when scrolled all the way to the bottom.
  // Dock dimensions: 52 (height) + 16 (glass vertical pad) + 16 (dock bottom margin) +
  // system bottom safe area inset (gesture bar) + 24 (breathing space).
  static double dockClearance(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return 108.0 + bottomInset;
  }

  static const double dockClearanceBase = 128.0;

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> navShadow = [
    BoxShadow(
      color: Color(0x29000000),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];
}
