import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../utils/app_theme.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passFocus = FocusNode();
  bool obscure = true;
  Offset mousePos = Offset.zero;

  @override
  void initState() {
    super.initState();
    emailFocus.addListener(() => setState(() {}));
    passFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    emailFocus.dispose();
    passFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final themeVM = context.watch<ThemeViewModel>();
    final size = MediaQuery.of(context).size;
    final isDark = themeVM.isDark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: MouseRegion(
        onHover: (e) => setState(() => mousePos = e.localPosition),
        child: Stack(
          children: [
            _buildBackground(size, isDark),
            Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBrand(isDark)
                        .animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTextField(controller: emailController, focusNode: emailFocus, hint: 'Email Address', icon: Icons.alternate_email_rounded, isDark: isDark)
                              .animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
                                const SizedBox(height: 20),
                                _buildTextField(controller: passController, focusNode: passFocus, hint: 'Password', icon: Icons.lock_outline_rounded, obscure: obscure, isDark: isDark,
                                    suffix: IconButton(
                                      icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: isDark ? Colors.white54 : Colors.black45, size: 20),
                                      onPressed: () { HapticFeedback.lightImpact(); setState(() => obscure = !obscure); },
                                    ))
                                    .animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Text('Forgot Password?', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF4776E6), fontWeight: FontWeight.w600, fontSize: 13)),
                                  ),
                                ).animate().fadeIn(delay: 400.ms),
                                const SizedBox(height: 20),
                                _buildPrimaryButton(
                                  label: 'Sign In',
                                  isLoading: vm.isLoading,
                                  onPressed: () async {
                                    FocusScope.of(context).unfocus();
                                    await vm.login(emailController.text.trim(), passController.text.trim());
                                    if (!mounted) return;
                                    if (vm.errorMessage != null) { HapticFeedback.vibrate(); _snack(context, vm.errorMessage!, Colors.redAccent); }
                                    else if (vm.user != null) HapticFeedback.heavyImpact();
                                  },
                                ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                                const SizedBox(height: 28),
                                _buildDivider(isDark).animate().fadeIn(delay: 600.ms),
                                const SizedBox(height: 20),
                                _buildSocialRow(vm, isDark).animate().fadeIn(delay: 700.ms),
                                const SizedBox(height: 20),
                                _buildFooter(context, isDark).animate().fadeIn(delay: 800.ms),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
            if (vm.isLoading) _buildLoadingOverlay(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(bool isDark) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    color: Color(0xFF4776E6),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Authenticating...',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ).animate().scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), curve: Curves.easeOutBack).fadeIn(),
        ),
      ),
    );
  }

  Widget _buildBackground(Size size, bool isDark) {
    return Stack(
      children: [
        _floatingIcon(Icons.monitor_heart_rounded, size.width * 0.1, size.height * 0.15, size, isDark, 4.seconds),
        _floatingIcon(Icons.directions_run_rounded, size.width * 0.8, size.height * 0.1, size, isDark, 5.seconds),
        _floatingIcon(Icons.wb_sunny_rounded, size.width * 0.75, size.height * 0.5, size, isDark, 6.seconds),
        _floatingIcon(Icons.water_drop_rounded, size.width * 0.15, size.height * 0.7, size, isDark, 4.5.seconds),
        _floatingIcon(Icons.fitness_center_rounded, size.width * 0.8, size.height * 0.85, size, isDark, 5.5.seconds),
        _floatingIcon(Icons.cloud_rounded, size.width * 0.5, size.height * 0.05, size, isDark, 5.seconds),
      ],
    );
  }

  Widget _floatingIcon(IconData icon, double left, double top, Size size, bool isDark, Duration duration) {
    double dx = (mousePos.dx - size.width / 2) / 30;
    double dy = (mousePos.dy - size.height / 2) / 30;

    return AnimatedPositioned(
      duration: 200.ms,
      left: left + dx,
      top: top + dy,
      child: Icon(icon, size: 80, color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06))
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: -15, end: 15, duration: duration, curve: Curves.easeInOut)
          .rotate(begin: -0.05, end: 0.05, duration: duration * 1.2),
    );
  }

  Widget _buildBrand(bool isDark) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.brandGradient,
        ),
        child: const Icon(Icons.bolt_rounded, size: 44, color: Colors.white),
      ).animate(onPlay: (c) => c.repeat(reverse: true))
       .scaleXY(begin: 0.95, end: 1.05, duration: 2.seconds),
      const SizedBox(height: 16),
      Text('SkyFit Pro', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF1A1C1E), letterSpacing: -1)),
      const SizedBox(height: 6),
      Text('Sign in to continue your journey', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: isDark ? Colors.white54 : Colors.black45, fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _buildTextField({required TextEditingController controller, required FocusNode focusNode, required String hint, required IconData icon, required bool isDark, bool obscure = false, Widget? suffix}) {
    final focused = focusNode.hasFocus;
    return AnimatedContainer(
      duration: 250.ms, curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        color: focused ? (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white) : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02)),
        border: Border.all(color: focused ? const Color(0xFF4776E6) : Colors.transparent, width: 1.5),
      ),
      child: TextField(
        controller: controller, focusNode: focusNode, obscureText: obscure,
        onTap: () => HapticFeedback.selectionClick(),
        style: GoogleFonts.plusJakartaSans(color: isDark ? Colors.white : Colors.black87, fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: focused ? const Color(0xFF4776E6) : (isDark ? Colors.white38 : Colors.black26), size: 20)
              .animate(target: focused ? 1 : 0)
              .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 150.ms),
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(color: isDark ? Colors.white30 : Colors.black38, fontSize: 15),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({required String label, required bool isLoading, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity, height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        gradient: AppTheme.brandGradient,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd))),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    final divColor = isDark ? Colors.white12 : Colors.black12;
    return Row(children: [
      Expanded(child: Divider(color: divColor)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('Or continue with', style: GoogleFonts.plusJakartaSans(color: isDark ? Colors.white54 : Colors.black45, fontSize: 13, fontWeight: FontWeight.w500))),
      Expanded(child: Divider(color: divColor)),
    ]);
  }

  Widget _buildSocialRow(AuthViewModel vm, bool isDark) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (vm.shouldShowBiometric) ...[
        _socialBtn(icon: Icons.fingerprint_rounded, color: AppTheme.easyColor, onPressed: () => vm.loginWithBiometrics(), isDark: isDark),
        const SizedBox(width: 14),
      ],
      _socialBtn(icon: Icons.g_mobiledata_rounded, color: isDark ? Colors.white : Colors.black87, iconSize: 34, onPressed: () => vm.googleLogin(), isDark: isDark),
      const SizedBox(width: 14),
      _socialBtn(icon: Icons.facebook_rounded, color: const Color(0xFF1877F2), onPressed: () => vm.facebookLogin(), isDark: isDark),
    ]);
  }

  Widget _socialBtn({required IconData icon, required Color color, required VoidCallback onPressed, required bool isDark, double iconSize = 26}) {
    return InkWell(
      onTap: onPressed, borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        width: 62, height: 62,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
        ),
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('New here?', style: GoogleFonts.plusJakartaSans(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14, fontWeight: FontWeight.w500)),
      TextButton(
        onPressed: () => Navigator.pushNamed(context, '/register'),
        child: Text('Create Account', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF4776E6), fontWeight: FontWeight.w700, fontSize: 14)),
      ),
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
