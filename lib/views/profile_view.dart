import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
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

    // --- Dynamic Theme Colors ---
    final bgColor = isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0F2F5);
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2C);
    final subTextColor = isDark ? Colors.white54 : Colors.black54;
    final glassColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.6);
    final glassBorder = isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: bgColor,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        color: bgColor,
        child: Stack(
          children: [
            // --- Adaptive Animated Background Orbs ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              top: size.height * 0.05,
              left: isDark ? -50 : -20,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.deepPurpleAccent.withValues(alpha: 0.5) : Colors.blue.withValues(alpha: 0.2),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              bottom: size.height * 0.15,
              right: isDark ? -80 : -40,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.blueAccent.withValues(alpha: 0.4) : Colors.purpleAccent.withValues(alpha: 0.15),
                ),
              ),
            ),

            // --- Main Content ---
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  children: [
                    // --- Header Row ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "My Profile",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: textColor,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: glassColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: glassBorder),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.logout_rounded, color: textColor),
                            onPressed: () async {
                              await authVM.logout();
                              if (context.mounted) {
                                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                              }
                            },
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 35),

                    // --- Adaptive Glass Profile Card ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: double.infinity,
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: glassColor,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: glassBorder, width: 1.5),
                            boxShadow: isDark 
                                ? [] 
                                : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, spreadRadius: 5)],
                          ),
                          child: Column(
                            children: [
                              // Glowing Avatar
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark 
                                          ? Colors.blueAccent.withValues(alpha: 0.5) 
                                          : Colors.blueAccent.withValues(alpha: 0.2),
                                      blurRadius: 25,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: isDark ? const Color(0xFF2D2D44) : Colors.white,
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 50,
                                    color: isDark ? Colors.white : Colors.blueAccent,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    authVM.user?.displayName ?? "User",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit, size: 20, color: subTextColor),
                                    onPressed: () => _showEditNameDialog(context, authVM),
                                  ),
                                ],
                              ),
                              Text(
                                authVM.user?.email ?? "",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: subTextColor,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Premium Member", // Example subtitle
                                style: TextStyle(fontSize: 14, color: subTextColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // --- Settings Section ---
                    _modernTile(
                      icon: Icons.fingerprint_rounded,
                      title: "Biometric Login",
                      value: profileVM.biometricEnabled,
                      isDark: isDark,
                      textColor: textColor,
                      glassColor: glassColor,
                      glassBorder: glassBorder,
                      onChanged: (value) => profileVM.toggleBiometric(value),
                    ),

                    const SizedBox(height: 16),

                    _modernTile(
                      icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      title: "Dark Appearance",
                      value: themeVM.isDark,
                      isDark: isDark,
                      textColor: textColor,
                      glassColor: glassColor,
                      glassBorder: glassBorder,
                      onChanged: (value) => themeVM.toggleTheme(value),
                    ),

                    const Spacer(),

                    // --- Modern Logout Button ---
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white),
                        label: const Text(
                          "Sign Out",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.shade400,
                          shadowColor: Colors.redAccent.withValues(alpha: 0.4),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          await authVM.logout();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, AuthViewModel authVM) {
    final controller = TextEditingController(text: authVM.user?.displayName);
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Edit Name", style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
          content: TextField(
            controller: controller,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: "Enter new name",
              hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  await authVM.updateName(newName);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Refactored to accept theme properties
  Widget _modernTile({
    required IconData icon,
    required String title,
    required bool value,
    required bool isDark,
    required Color textColor,
    required Color glassColor,
    required Color glassBorder,
    required Function(bool) onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: glassColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: glassBorder, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.blueAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isDark ? Colors.white70 : Colors.blueAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: Colors.blueAccent,
            activeTrackColor: Colors.blueAccent.withValues(alpha: 0.3),
            inactiveThumbColor: isDark ? Colors.white54 : Colors.grey.shade400,
            inactiveTrackColor: isDark ? Colors.white24 : Colors.grey.shade200,
            onChanged: onChanged,
          )
        ],
      ),
    );
  }
}
