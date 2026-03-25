import 'dart:ui';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../utils/app_theme.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final nameController    = TextEditingController();
  final emailController   = TextEditingController();
  final passController    = TextEditingController();
  final ageController       = TextEditingController();
  final weightController    = TextEditingController();
  final heightController    = TextEditingController();
  final genderController    = TextEditingController();
  final addressController   = TextEditingController();

  final FocusNode nameFocus     = FocusNode();
  final FocusNode emailFocus    = FocusNode();
  final FocusNode passFocus     = FocusNode();
  final FocusNode ageFocus      = FocusNode();
  final FocusNode weightFocus   = FocusNode();
  final FocusNode heightFocus   = FocusNode();
  final FocusNode genderFocus   = FocusNode();
  final FocusNode addressFocus  = FocusNode();

  bool obscure = true;
  Offset mousePos = Offset.zero;
  String? selectedGender;
  bool isDetectingLocation = false;

  Future<void> _detectLocation() async {
    if (!mounted) return;
    setState(() => isDetectingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) _snack(context, 'Location services are disabled.', Colors.redAccent);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) _snack(context, 'Location permissions are denied.', Colors.redAccent);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) _snack(context, 'Location permissions are permanently denied.', Colors.redAccent);
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final street = place.street ?? '';
        final local = place.locality ?? '';
        final admin = place.administrativeArea ?? '';
        final country = place.country ?? '';

        final parts = [street, local, admin, country].where((p) => p.isNotEmpty).toList();
        if (parts.isNotEmpty) {
          addressController.text = parts.join(', ');
          HapticFeedback.lightImpact();
        }
      }
    } catch (e) {
      debugPrint("GPS Location fetch failed: $e");
      if (mounted) _snack(context, 'Failed to detect location. Please type it.', Colors.orangeAccent);
    } finally {
      if (mounted) setState(() => isDetectingLocation = false);
    }
  }

  @override
  void initState() {
    super.initState();
    for (final fn in [nameFocus, emailFocus, passFocus, ageFocus, weightFocus, heightFocus, genderFocus, addressFocus]) fn.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in [nameController, emailController, passController, ageController, weightController, heightController, genderController, addressController]) c.dispose();
    for (final fn in [nameFocus, emailFocus, passFocus, ageFocus, weightFocus, heightFocus, genderFocus, addressFocus]) fn.dispose();
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
            // Back button
            Positioned(
              top: 52, left: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black87, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ).animate().fadeIn().slideX(begin: -0.5, end: 0),
            ),

            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBrand(isDark).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(28),
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
                          _buildField(nameController, nameFocus, 'Full Name', Icons.person_outline_rounded, isDark)
                              .animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),
                          const SizedBox(height: 16),
                          _buildField(emailController, emailFocus, 'Email Address', Icons.alternate_email_rounded, isDark)
                              .animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
                                const SizedBox(height: 16),
                                _buildField(passController, passFocus, 'Password', Icons.lock_outline_rounded, isDark, obscure: obscure,
                                    suffix: IconButton(
                                      icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: isDark ? Colors.white54 : Colors.black45, size: 20),
                                      onPressed: () { HapticFeedback.lightImpact(); setState(() => obscure = !obscure); },
                                    ))
                                    .animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),
                                const SizedBox(height: 16),
                                Row(children: [
                                  Expanded(child: _buildField(ageController, ageFocus, 'Age', Icons.cake_outlined, isDark, type: TextInputType.number)
                                      .animate().fadeIn(delay: 350.ms).slideX(begin: -0.1, end: 0)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildField(weightController, weightFocus, 'Weight', Icons.monitor_weight_outlined, isDark, type: TextInputType.number, suffixText: 'kg')
                                      .animate().fadeIn(delay: 350.ms).slideX(begin: 0.1, end: 0)),
                                ]),
                                const SizedBox(height: 16),
                                Row(children: [
                                  Expanded(child: _buildField(heightController, heightFocus, 'Height', Icons.height_outlined, isDark, type: TextInputType.number, suffixText: 'cm')
                                      .animate().fadeIn(delay: 380.ms).slideX(begin: -0.1, end: 0)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildGenderDropdown(isDark)
                                      .animate().fadeIn(delay: 380.ms).slideX(begin: 0.1, end: 0)),
                                ]),
                                const SizedBox(height: 16),
                                _buildField(
                                  addressController, addressFocus, 'Address', Icons.location_on_outlined, isDark,
                                  suffix: isDetectingLocation
                                      ? Container(margin: const EdgeInsets.all(14), width: 16, height: 16, child: const CircularProgressIndicator(strokeWidth: 2))
                                      : IconButton(
                                          icon: const Icon(Icons.my_location_rounded, size: 20),
                                          color: const Color(0xFF4776E6),
                                          onPressed: _detectLocation,
                                        ),
                                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0),
                                const SizedBox(height: 28),
                                _buildPrimaryButton(
                                  label: 'Create Account',
                                  isLoading: vm.isLoading,
                                  onPressed: () async {
                                    final pw = passController.text.trim();
                                    if (pw.length < 8 || !RegExp(r'(?=.*[A-Z])').hasMatch(pw) || !RegExp(r'(?=.*[0-9])').hasMatch(pw)) {
                                      _snack(context, 'Password must be 8+ chars, 1 uppercase & 1 number.', Colors.redAccent);
                                      return;
                                    }
                                    final ok = await vm.register(
                                      nameController.text.trim(), 
                                      emailController.text.trim(), 
                                      pw,
                                      age: int.tryParse(ageController.text), 
                                      weight: double.tryParse(weightController.text),
                                      height: double.tryParse(heightController.text),
                                      gender: selectedGender,
                                      address: addressController.text.trim(),
                                    );
                                    if (!mounted) return;
                                    if (ok) { 
                                      HapticFeedback.heavyImpact(); 
                                      Navigator.pop(context);
                                      _snack(context, 'Account created! Check your email.', Colors.greenAccent); 
                                    }
                                    else if (vm.errorMessage != null) { HapticFeedback.vibrate(); _snack(context, vm.errorMessage!, Colors.redAccent); }
                                  },
                                ).animate().fadeIn(delay: 450.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                                const SizedBox(height: 28),
                                _buildDivider(isDark).animate().fadeIn(delay: 500.ms),
                                const SizedBox(height: 20),
                                _buildSocialRow(vm, isDark).animate().fadeIn(delay: 600.ms),
                                const SizedBox(height: 20),
                                _buildFooter(context, isDark).animate().fadeIn(delay: 700.ms),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (vm.isLoading) _buildLoadingOverlay(isDark, 'Creating Account...'),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(bool isDark, String message) {
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
                  message,
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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.brandGradient,
        ),
        child: const Icon(Icons.bolt_rounded, size: 40, color: Colors.white),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 0.95, end: 1.05, duration: 2.seconds),
      const SizedBox(height: 14),
      Text('SkyFit Pro', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF1A1C1E), letterSpacing: -1)),
      const SizedBox(height: 5),
      Text('Create your account to get started', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: isDark ? Colors.white54 : Colors.black45, fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _buildField(TextEditingController ctrl, FocusNode fn, String hint, IconData icon, bool isDark, {bool obscure = false, Widget? suffix, TextInputType type = TextInputType.text, String? suffixText}) {
    final focused = fn.hasFocus;
    return AnimatedContainer(
      duration: 250.ms, curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        color: focused ? (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white) : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02)),
        border: Border.all(color: focused ? const Color(0xFF4776E6) : Colors.transparent, width: 1.5),
      ),
      child: TextField(
        controller: ctrl, focusNode: fn, obscureText: obscure, keyboardType: type,
        onTap: () => HapticFeedback.selectionClick(),
        style: GoogleFonts.plusJakartaSans(color: isDark ? Colors.white : Colors.black87, fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: focused ? const Color(0xFF4776E6) : (isDark ? Colors.white38 : Colors.black26), size: 20)
              .animate(target: focused ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 150.ms),
          suffixIcon: suffix,
          suffixText: suffixText,
          suffixStyle: GoogleFonts.plusJakartaSans(color: isDark ? Colors.white38 : Colors.black38, fontSize: 14, fontWeight: FontWeight.w600),
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(color: isDark ? Colors.white30 : Colors.black38, fontSize: 15),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildGenderDropdown(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
      ),
      child: ButtonTheme(
        alignedDropdown: true,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedGender,
            hint: Row(
              children: [
                Icon(Icons.wc_rounded, color: isDark ? Colors.white38 : Colors.black26, size: 20),
                const SizedBox(width: 12),
                Text('Gender', style: GoogleFonts.plusJakartaSans(color: isDark ? Colors.white30 : Colors.black38, fontSize: 15)),
              ],
            ),
            isExpanded: true,
            dropdownColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            icon: Icon(Icons.arrow_drop_down_rounded, color: isDark ? Colors.white38 : Colors.black38),
            style: GoogleFonts.plusJakartaSans(color: isDark ? Colors.white : Colors.black87, fontSize: 15, fontWeight: FontWeight.w500),
            items: ['Male', 'Female'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    Icon(value == 'Male' ? Icons.male_rounded : Icons.female_rounded, color: const Color(0xFF4776E6), size: 20),
                    const SizedBox(width: 12),
                    Text(value),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => selectedGender = val);
            },
          ),
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
    final c = isDark ? Colors.white12 : Colors.black12;
    return Row(children: [
      Expanded(child: Divider(color: c)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('Or register with', style: GoogleFonts.plusJakartaSans(color: isDark ? Colors.white54 : Colors.black45, fontSize: 13, fontWeight: FontWeight.w500))),
      Expanded(child: Divider(color: c)),
    ]);
  }

  Widget _buildSocialRow(AuthViewModel vm, bool isDark) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _socialBtn(icon: Icons.g_mobiledata_rounded, color: isDark ? Colors.white : Colors.black87, iconSize: 34, onPressed: () => vm.googleLogin(isRegistration: true), isDark: isDark),
      const SizedBox(width: 14),
      _socialBtn(icon: Icons.facebook_rounded, color: const Color(0xFF1877F2), onPressed: () => vm.facebookLogin(isRegistration: true), isDark: isDark),
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
      Text('Already have an account?', style: GoogleFonts.plusJakartaSans(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14, fontWeight: FontWeight.w500)),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Sign In', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF4776E6), fontWeight: FontWeight.w700, fontSize: 14)),
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
