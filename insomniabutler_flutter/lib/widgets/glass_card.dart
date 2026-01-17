import 'package:flutter/material.dart';
import 'dart:ui';
import '../core/theme.dart';

/// Glassmorphic Card Component
/// Provides a frosted glass effect with blur and transparency
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? borderRadius;
  final bool elevated;
  final Gradient? gradient;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.elevated = false,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? AppBorderRadius.xxl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: gradient ??
                LinearGradient(
                  colors: elevated
                      ? [AppColors.glassBgElevated, AppColors.glassBg]
                      : [AppColors.glassBg, AppColors.glassBg.withOpacity(0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            borderRadius: BorderRadius.circular(borderRadius ?? AppBorderRadius.xxl),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1,
            ),
            boxShadow: AppShadows.glassShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}
