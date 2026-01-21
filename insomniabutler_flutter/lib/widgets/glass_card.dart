import 'package:flutter/material.dart';
import 'dart:ui';
import '../core/theme.dart';

/// Glassmorphic Card Component
/// Provides a frosted glass effect with blur and transparency
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final bool elevated;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.elevated = false,
    this.gradient,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppRadius.lg,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            margin: margin,
            decoration: BoxDecoration(
              color: AppColors.glassBackground,
              gradient: gradient,
              borderRadius: BorderRadius.circular(
                borderRadius ?? AppRadius.lg,
              ),
              border: Border.all(
                color: AppColors.glassBorder,
                width: 1,
              ),
              boxShadow: elevated ? AppShadows.card : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
