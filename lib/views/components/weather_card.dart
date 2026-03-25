import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../../utils/app_theme.dart';
import 'tilt_card.dart';

class WeatherCard extends StatelessWidget {
  final WeatherViewModel weatherVM;
  final bool isDark;
  final Color textColor;
  final Color primaryColor;
  final Color secondaryColor;

  const WeatherCard({
    super.key,
    required this.weatherVM,
    required this.isDark,
    required this.textColor,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final w = weatherVM.weather!;
    final cond = w.condition.toLowerCase();

    final IconData weatherIcon = cond.contains('rain') || cond.contains('drizzle')
        ? Icons.water_drop_rounded
        : cond.contains('cloud')
            ? Icons.cloud_rounded
            : cond.contains('snow')
                ? Icons.ac_unit_rounded
                : cond.contains('thunder')
                    ? Icons.bolt_rounded
                    : Icons.wb_sunny_rounded;

    return TiltCard(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: isDark ? 0.3 : 0.18),
                  secondaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: primaryColor.withValues(alpha: 0.25), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.12),
                  blurRadius: 30, offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative orb
                Positioned(
                  right: -24, top: -24,
                  child: AppTheme.blob(120, primaryColor.withValues(alpha: 0.25)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top row: location + icon ──────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(Icons.location_on_rounded, color: primaryColor, size: 14),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    w.description.isNotEmpty ? w.description : 'Current Location',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textColor.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${w.temp.toStringAsFixed(1)}°C',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 52, fontWeight: FontWeight.w900, color: textColor, height: 1),
                                ),
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  w.condition,
                                  style: GoogleFonts.plusJakartaSans(fontSize: 18, color: textColor.withValues(alpha: 0.85), fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.15),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
                          ),
                          child: Icon(weatherIcon, size: 44, color: primaryColor)
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .slideY(begin: -0.05, end: 0.05, duration: 2.seconds),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Bottom stat row ───────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statChip(Icons.water_drop_rounded, '${w.humidity}%', 'Humidity', primaryColor, textColor),
                          _vertDivider(isDark),
                          _statChip(Icons.thermostat_rounded, '${(w.temp * 9 / 5 + 32).toStringAsFixed(0)}°F', 'Feels like', secondaryColor, textColor),
                          _vertDivider(isDark),
                          _statChip(Icons.air_rounded, 'Good', 'Air Quality', AppTheme.easyColor, textColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label, Color color, Color textColor) {
    return Column(children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(height: 3),
      Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: textColor)),
      Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: textColor.withValues(alpha: 0.5), fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _vertDivider(bool isDark) => Container(
    width: 1, height: 40, color: isDark ? Colors.white12 : Colors.black12,
  );
}
