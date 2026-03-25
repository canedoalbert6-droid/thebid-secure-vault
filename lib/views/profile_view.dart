import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../utils/app_theme.dart';
import 'components/tilt_card.dart';
import 'components/bento_item.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Offset mousePos = Offset.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadBiometric();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final profileVM = context.watch<ProfileViewModel>();
    final themeVM = context.watch<ThemeViewModel>();
    
    final size = MediaQuery.of(context).size;
    final isDark = themeVM.isDark;

    final primaryColor = const Color(0xFF4776E6);
    final secondaryColor = const Color(0xFF8E54E9);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1C1E);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: MouseRegion(
        onHover: (event) => setState(() => mousePos = event.localPosition),
        child: Stack(
          children: [
            _buildAnimatedBackground(size, isDark, primaryColor, secondaryColor),
            
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header ────────────────────────────────────────
                    _buildHeader(textColor, isDark, primaryColor, themeVM, authVM).animate().fadeIn().slideY(begin: -0.15, end: 0),
                    const SizedBox(height: 24),
                    
                    // ── Profile Main Card ──────────────────────────────
                    _buildProfileCard(authVM, isDark, primaryColor, textColor)
                        .animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    // ── Bento Grid Stats ──────────────────────────────
                    _buildBentoStats(authVM, isDark, textColor, primaryColor)
                        .animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 32),
                    
                    // ── Settings ──────────────────────────────────────
                    Text(
                      "Settings & Preferences",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ).animate().fadeIn(delay: 350.ms),
                    
                    const SizedBox(height: 16),
                    
                    _buildSettingsTile(
                      icon: Icons.fingerprint_rounded,
                      title: "Biometric Authentication",
                      subtitle: "Fast and secure sign in",
                      value: profileVM.biometricEnabled,
                      isDark: isDark,
                      primaryColor: primaryColor,
                      textColor: textColor,
                      onChanged: (value) async {
                        await profileVM.toggleBiometric(value);
                        await authVM.checkBiometricAvailability();
                      },
                    ).animate().fadeIn(delay: 450.ms).slideX(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    _buildSettingsTile(
                      icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      title: "App Theme",
                      subtitle: isDark ? "Dark Appearance" : "Light Appearance",
                      value: themeVM.isDark,
                      isDark: isDark,
                      primaryColor: primaryColor,
                      textColor: textColor,
                      onChanged: (value) => themeVM.toggleTheme(value),
                    ).animate().fadeIn(delay: 550.ms).slideX(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 32),
                    
                    // ── Logout ────────────────────────────────────────
                    _buildLogoutButton(authVM, isDark)
                        .animate().fadeIn(delay: 650.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(Size size, bool isDark, Color primary, Color secondary) {
    double dx = (mousePos.dx - size.width / 2) / 50;
    double dy = (mousePos.dy - size.height / 2) / 50;

    return Stack(
      children: [
        AnimatedPositioned(
          duration: 200.ms,
          top: size.height * 0.05 + dy,
          left: size.width * 0.1 + dx,
          child: AppTheme.blob(250, isDark ? primary.withValues(alpha: 0.12) : primary.withValues(alpha: 0.06))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 0.9, end: 1.1, duration: 4.seconds),
        ),
        AnimatedPositioned(
          duration: 200.ms,
          bottom: size.height * 0.1 - dy,
          right: size.width * 0.05 - dx,
          child: AppTheme.blob(300, isDark ? secondary.withValues(alpha: 0.10) : secondary.withValues(alpha: 0.05))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 1.1, end: 0.9, duration: 5.seconds),
        ),
      ],
    );
  }

  void _showSettingsSheet(BuildContext context, themeVM, authVM, bool isDark, Color primaryColor, Color textColor) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text('Settings', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: textColor)),
              const SizedBox(height: 24),

              // Edit Profile
              _settingsRow(
                icon: Icons.edit_outlined,
                label: 'Edit Profile',
                subtitle: 'Update your name, bio & photo',
                color: primaryColor,
                isDark: isDark,
                textColor: textColor,
                onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/edit-profile'); },
              ),
              const SizedBox(height: 12),

              // Theme toggle
              _settingsRow(
                icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                label: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                subtitle: 'Change the app appearance',
                color: const Color(0xFF8E54E9),
                isDark: isDark,
                textColor: textColor,
                onTap: () { themeVM.toggleTheme(!isDark); },
              ),
              const SizedBox(height: 12),

              // Change Password
              _settingsRow(
                icon: Icons.lock_outline_rounded,
                label: 'Change Password',
                subtitle: 'Update your login credentials',
                color: Colors.orangeAccent,
                isDark: isDark,
                textColor: textColor,
                onTap: () {
                  Navigator.pop(context);
                  _showChangePasswordDialog(context, authVM, isDark, primaryColor, textColor);
                },
              ),
              const SizedBox(height: 12),

              // Sign Out
              _settingsRow(
                icon: Icons.logout_rounded,
                label: 'Sign Out',
                subtitle: 'Log out of your account',
                color: Colors.redAccent,
                isDark: isDark,
                textColor: textColor,
                onTap: () { Navigator.pop(context); authVM.signOut(); },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _settingsRow({required IconData icon, required String label, required String subtitle, required Color color, required bool isDark, required Color textColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onTap(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: textColor)),
                Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38)),
              ],
            )),
            Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white30 : Colors.black26),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, authVM, bool isDark, Color primaryColor, Color textColor) {
    final newPassCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Change Password', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: textColor)),
        content: TextField(
          controller: newPassCtrl,
          obscureText: true,
          style: GoogleFonts.plusJakartaSans(color: textColor),
          decoration: InputDecoration(
            hintText: 'New password',
            hintStyle: GoogleFonts.plusJakartaSans(color: isDark ? Colors.white38 : Colors.black38),
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: isDark ? Colors.white54 : Colors.black54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              if (newPassCtrl.text.length >= 8) {
                await authVM.changePassword(newPassCtrl.text.trim());
                if (context.mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated!'))); }
              }
            },
            child: Text('Update', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color textColor, bool isDark, Color primaryColor, themeVM, authVM) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Profile",
              style: GoogleFonts.plusJakartaSans(fontSize: 30, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -1),
            ),
            const SizedBox(height: 2),
            Text(
              "Manage identity & metrics",
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: isDark ? Colors.white54 : Colors.black45, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showSettingsSheet(context, themeVM, authVM, isDark, primaryColor, textColor),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
            ),
            child: Icon(Icons.settings_rounded, color: primaryColor, size: 24),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).rotate(begin: -0.02, end: 0.02, duration: 4.seconds),
        ),
      ],
    );
  }

  Widget _buildProfileCard(AuthViewModel authVM, bool isDark, Color primaryColor, Color textColor) {
    return TiltCard(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: AppTheme.glassCard(isDark: isDark, accentColor: primaryColor),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.brandGradient,
                  ),
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                    backgroundImage: authVM.userModel?.profilePicture != null 
                        ? NetworkImage(authVM.userModel!.profilePicture!) 
                        : null,
                    child: authVM.userModel?.profilePicture == null 
                        ? Icon(Icons.person_rounded, size: 46, color: primaryColor)
                        : null,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(gradient: AppTheme.brandGradient, shape: BoxShape.circle),
                  child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              authVM.user?.displayName ?? "SkyFit Athlete",
              style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.5),
            ),
            const SizedBox(height: 4),
            Text(
              authVM.user?.email ?? "Not logged in",
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 140,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Navigator.pushNamed(context, '/edit-profile');
                },
                child: Text(
                  "Edit Profile",
                  style: GoogleFonts.plusJakartaSans(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoStats(AuthViewModel authVM, bool isDark, Color textColor, Color primaryColor) {
    final u = authVM.userModel;
    if (u == null) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: BentoItem(
                  title: 'Workouts',
                  icon: Icons.fitness_center_rounded,
                  color: primaryColor,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${u.workoutsCompleted}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w900, color: textColor),
                          ),
                          Text('Total', style: AppTheme.bodySm(isDark)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: BentoItem(
                  title: 'Streak',
                  icon: Icons.local_fire_department_rounded,
                  color: Colors.orangeAccent,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${u.currentStreak}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w900, color: textColor),
                          ),
                          Text('Days', style: AppTheme.bodySm(isDark)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: BentoItem(
                  title: 'Weight',
                  icon: Icons.monitor_weight_outlined,
                  color: Colors.blueAccent,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${u.weight ?? "--"}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w900, color: textColor),
                          ),
                          const SizedBox(width: 4),
                          Text('kg', style: AppTheme.bodySm(isDark)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: BentoItem(
                  title: 'Height',
                  icon: Icons.height_outlined,
                  color: Colors.greenAccent,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${u.height ?? "--"}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w900, color: textColor),
                          ),
                          const SizedBox(width: 4),
                          Text('cm', style: AppTheme.bodySm(isDark)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool isDark,
    required Color primaryColor,
    required Color textColor,
    required Function(bool) onChanged,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: 250.ms,
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()..scale(isHovered ? 1.02 : 1.0),
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.glassCard(isDark: isDark, accentColor: isHovered ? primaryColor : Colors.transparent),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Icon(icon, color: primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: textColor)),
                      Text(subtitle, style: AppTheme.bodySm(isDark)),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: value,
                  activeColor: primaryColor,
                  activeTrackColor: primaryColor.withValues(alpha: 0.3),
                  inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
                  onChanged: (val) {
                    HapticFeedback.lightImpact();
                    onChanged(val);
                  },
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildLogoutButton(AuthViewModel authVM, bool isDark) {
    return TiltCard(
      tiltSensitivity: 0.02,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          color: Colors.redAccent.withValues(alpha: isDark ? 0.15 : 0.1),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: TextButton.icon(
          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
          label: Text("Sign Out", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.redAccent)),
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
          ),
          onPressed: () async {
            HapticFeedback.heavyImpact();
            await authVM.logout();
            if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
        ),
      ),
    );
  }
}

