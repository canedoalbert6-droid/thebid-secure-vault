import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../utils/app_theme.dart';

class EmailVerificationView extends StatefulWidget {
  const EmailVerificationView({super.key});

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  Timer? _timer;
  Offset mousePos = Offset.zero;

  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (t) async {
      // ⏱️ Stop after 3 minutes to save resources/avoid infinite loops
      if (_startTime != null && DateTime.now().difference(_startTime!).inMinutes >= 3) {
        debugPrint("Email verification check timed out after 3 minutes.");
        t.cancel();
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) { 
        debugPrint("No user found, stopping verification check.");
        t.cancel(); 
        return; 
      }
      
      try {
        await user.reload().timeout(const Duration(seconds: 5));
        debugPrint("User reloaded, verified: ${user.emailVerified}");
        
        if (user.emailVerified) {
          t.cancel();
          if (mounted) {
            debugPrint("Email verified! Navigating to home...");
            await context.read<AuthViewModel>().refreshUser();
            if (mounted) Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } catch (e) {
        debugPrint("Error during email reload check: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM  = context.read<AuthViewModel>();
    final themeVM = context.watch<ThemeViewModel>();
    final isDark  = themeVM.isDark;
    final size    = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: MouseRegion(
        onHover: (e) => setState(() => mousePos = e.localPosition),
        child: Stack(
          children: [
            _buildBackground(size, isDark),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Brand Header ──────────────────────────
                    _buildBrand(isDark).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
                    const SizedBox(height: 36),

                    // ── Glass Card ────────────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(
                          padding: const EdgeInsets.all(36),
                          decoration: AppTheme.glassCard(isDark: isDark, accentColor: const Color(0xFF4776E6)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppTheme.brandGradient,
                                  boxShadow: [BoxShadow(color: const Color(0xFF4776E6).withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))],
                                ),
                                child: const Icon(Icons.mark_email_read_rounded, size: 52, color: Colors.white),
                              )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scaleXY(begin: 0.95, end: 1.05, duration: 2.seconds)
                              .shimmer(duration: 3.seconds, color: Colors.white24),

                              const SizedBox(height: 28),

                              Text('Verify Your Email',
                                style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF1A1C1E)),
                              ).animate().fadeIn(delay: 200.ms),

                              const SizedBox(height: 10),

                              Text("We've sent a verification link to:",
                                style: GoogleFonts.plusJakartaSans(fontSize: 14, color: isDark ? Colors.white54 : Colors.black54, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                              ).animate().fadeIn(delay: 300.ms),

                              const SizedBox(height: 8),

                              Text(
                                FirebaseAuth.instance.currentUser?.email ?? 'your email',
                                style: GoogleFonts.plusJakartaSans(fontSize: 16, color: const Color(0xFF4776E6), fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                              ).animate().fadeIn(delay: 400.ms),

                              const SizedBox(height: 32),

                              // Progress indicator
                              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Color(0xFF4776E6), strokeWidth: 2.5)),
                                const SizedBox(width: 12),
                                Text('Checking automatically…', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: isDark ? Colors.white54 : Colors.black45, fontWeight: FontWeight.w500)),
                              ]).animate().fadeIn(delay: 500.ms),

                              const SizedBox(height: 32),

                              // Resend button
                              Container(
                                width: double.infinity, height: 54,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                  gradient: AppTheme.brandGradient,
                                  boxShadow: [BoxShadow(color: const Color(0xFF4776E6).withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
                                ),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd))),
                                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                  label: Text('Resend Email', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                  onPressed: () async {
                                    HapticFeedback.mediumImpact();
                                    await authVM.resendVerificationEmail();
                                    if (mounted) _snack(context, 'Verification email resent!', AppTheme.easyColor);
                                  },
                                ),
                              ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

                              const SizedBox(height: 12),

                              TextButton(
                                onPressed: () async {
                                  HapticFeedback.lightImpact();
                                  await authVM.logout();
                                  if (mounted) Navigator.pushReplacementNamed(context, '/login');
                                },
                                child: Text('Back to Login', style: GoogleFonts.plusJakartaSans(color: isDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.w600, fontSize: 14)),
                              ).animate().fadeIn(delay: 700.ms),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(Size size, bool isDark) {
    double dx = (mousePos.dx - size.width / 2) / 40;
    double dy = (mousePos.dy - size.height / 2) / 40;
    return Stack(children: [
      AnimatedPositioned(duration: 200.ms, top: size.height * 0.1 + dy, left: size.width * 0.1 + dx,
          child: AppTheme.blob(200, isDark ? const Color(0xFF4776E6).withValues(alpha: 0.18) : const Color(0xFF4776E6).withValues(alpha: 0.1))),
      AnimatedPositioned(duration: 200.ms, bottom: size.height * 0.12 - dy, right: size.width * 0.06 - dx,
          child: AppTheme.blob(240, isDark ? const Color(0xFF8E54E9).withValues(alpha: 0.15) : const Color(0xFF8E54E9).withValues(alpha: 0.08))),
      AnimatedPositioned(duration: 200.ms, top: size.height * 0.5 + dy * 0.5, right: size.width * 0.25 + dx * 0.5,
          child: AppTheme.blob(100, isDark ? Colors.pinkAccent.withValues(alpha: 0.1) : Colors.pinkAccent.withValues(alpha: 0.05))),
    ]);
  }

  Widget _buildBrand(bool isDark) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.brandGradient,
          boxShadow: [BoxShadow(color: const Color(0xFF4776E6).withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: const Icon(Icons.bolt_rounded, size: 44, color: Colors.white),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 0.95, end: 1.05, duration: 2.seconds),
      const SizedBox(height: 16),
      Text('SkyFit Pro', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF1A1C1E), letterSpacing: -1)),
      const SizedBox(height: 6),
      Text('Almost there! Check your inbox', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: isDark ? Colors.white54 : Colors.black45, fontWeight: FontWeight.w500)),
    ]);
  }

  void _snack(BuildContext ctx, String msg, Color color) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500)),
      backgroundColor: color, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
      margin: const EdgeInsets.all(16),
    ));
  }
}
