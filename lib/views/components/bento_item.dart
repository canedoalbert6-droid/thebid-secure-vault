import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';

class BentoItem extends StatelessWidget {
  final Widget child;
  final String? title;
  final IconData? icon;
  final Color? color;
  final int flex;
  final VoidCallback? onTap;

  const BentoItem({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.color,
    this.flex = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = color ?? const Color(0xFF4776E6);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppTheme.glassCard(isDark: isDark, accentColor: accent.withValues(alpha: 0.1)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Subtle background accent
            Positioned(
              top: -20, right: -20,
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: isDark ? 0.08 : 0.05),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null || icon != null) ...[
                    Row(
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: accent, size: 18),
                          const SizedBox(width: 8),
                        ],
                        if (title != null)
                          Expanded(
                            child: Text(
                              title!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .shimmer(delay: 5.seconds, duration: 3.seconds, color: accent.withValues(alpha: 0.05));
  }
}
