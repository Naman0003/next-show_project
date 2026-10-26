import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Reusable Glassmorphism helpers and container styles
class GlassDecorations {
  GlassDecorations._();

  static BoxDecoration card({
    double borderRadius = 20.0,
    Color? borderColor,
    Color? backgroundColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.glassSurface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? AppColors.glassBorder,
        width: 1.2,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 16,
          offset: Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration pill({
    Color? borderColor,
    Color? backgroundColor,
  }) {
    return card(
      borderRadius: 100.0,
      borderColor: borderColor,
      backgroundColor: backgroundColor,
    );
  }

  static Widget glassContainer({
    required Widget child,
    double borderRadius = 20.0,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? borderColor,
    Color? backgroundColor,
    double blur = 16.0,
  }) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: card(
              borderRadius: borderRadius,
              borderColor: borderColor,
              backgroundColor: backgroundColor,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
