// lib/widgets/next_show_logo.dart
//
// Placeholder wordmark until the real logo asset (director's-chair mark,
// see apps/user_app/assets/moodboard.jpg) is provided as a clean
// transparent SVG/PNG export. Swap the icon in NextShowLogo.icon below
// once that file exists — everything else (gradient, type) already
// matches the moodboard's "logo direction" panel.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class NextShowLogo extends StatelessWidget {
  final double fontSize;
  final bool showIcon;

  const NextShowLogo({Key? key, this.fontSize = 24, this.showIcon = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          Container(
            width: fontSize * 1.15,
            height: fontSize * 1.15,
            decoration: BoxDecoration(
              color: AppColors.royalBlue,
              borderRadius: BorderRadius.circular(fontSize * 0.28),
            ),
            child: Icon(Icons.event_seat_rounded, color: AppColors.snowWhite, size: fontSize * 0.72),
          ),
          SizedBox(width: fontSize * 0.32),
        ],
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: AppColors.brandGradient,
          ).createShader(bounds),
          child: Text(
            "NextShow",
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }
}
