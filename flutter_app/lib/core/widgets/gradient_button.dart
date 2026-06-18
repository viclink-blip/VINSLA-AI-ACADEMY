import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final Gradient gradient;
  final Widget? icon;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.height    = 52,
    this.gradient  = AppColors.heroGradient,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient:     onPressed == null ? null : gradient,
          color:        onPressed == null ? Colors.grey.shade700 : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: onPressed == null ? [] : [
            BoxShadow(color: AppColors.brandPurple.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Center(
          child: isLoading
            ? const SizedBox(width: 24, height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
        ),
      ),
    );
  }
}
