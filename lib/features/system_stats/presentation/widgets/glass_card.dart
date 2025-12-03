import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:vaxmanegr/core/constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double height;
  final Color borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.height = 150,
    this.borderColor = AppColors.glassLight,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: height,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.glassLight, AppColors.glassDark],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          // ignore: deprecated_member_use
          borderColor.withOpacity(0.5),
          // ignore: deprecated_member_use
          borderColor.withOpacity(0.2),
        ],
      ),
      child: child,
    );
  }
}
