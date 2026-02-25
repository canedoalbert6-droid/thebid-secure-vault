import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../utils/validators.dart';
import 'email_verification_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> with SingleTickerProviderStateMixin {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passController;
  late final TextEditingController confirmController;

  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passFocus = FocusNode();
  final FocusNode confirmFocus = FocusNode();

  bool obscure1 = true;
  bool obscure2 = true;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passController = TextEditingController();
    confirmController = TextEditingController();

    // Rebuild when focus changes to update the UI borders
    nameFocus.addListener(() => setState(() {}));
    emailFocus.addListener(() => setState(() {}));
    passFocus.addListener(() => setState(() {}));
    confirmFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    confirmController.dispose();
    nameFocus.dispose();
    emailFocus.dispose();
    passFocus.dispose();
    confirmFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final themeVM = context.watch<ThemeViewModel>();
    final size = MediaQuery.of(context).size;
    final isDark = themeVM.isDark;

    // --- Dynamic Theme Colors ---
    final bgColor = isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0F2F5);
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2C);
    final glassColor = isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6);
    final glassBorder = isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.05);

    final isPassStrong = Validators.isValidPassword(passController.text);
    final hasPassInput = passController.text.isNotEmpty;

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
              top: size.height * 0.1,
              right: isDark ? -50 : -20,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.purpleAccent.withOpacity(0.5) : Colors.blueAccent.withOpacity(0.2),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              bottom: size.height * 0.15,
              left: isDark ? -80 : -40,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.deepPurpleAccent.withOpacity(0.4) : Colors.purpleAccent.withOpacity(0.15),
                ),
              ),
            ),

            // --- Main Content ---
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: glassColor,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: glassBorder, width: 1.5),
                        boxShadow: isDark 
                            ? [] 
                            : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, spreadRadius: 5)],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // --- Header ---
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.1) : Colors.blueAccent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_add_rounded, 
                              size: 50, 
                              color: isDark ? Colors.white : Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Sign up to get started",
                            style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.black54),
                          ),
                          const SizedBox(height: 30),

                          // --- Name Field ---
                          _buildTextField(
                            controller: nameController,
                            focusNode: nameFocus,
                            hint: "Full Name",
                            icon: Icons.person_rounded,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16),

                          // --- Email Field ---
                          _buildTextField(
                            controller: emailController,
                            focusNode: emailFocus,
                            hint: "Email",
                            icon: Icons.email_rounded,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16),

                          // --- Password Field ---
                          _buildTextField(
                            controller: passController,
                            focusNode: passFocus,
                            hint: "Password",
                            icon: Icons.lock_rounded,
                            obscure: obscure1,
                            isDark: isDark,
                            onChanged: (_) => setState(() {}),
                            suffix: IconButton(
                              icon: Icon(
                                obscure1 ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                              onPressed: () => setState(() => obscure1 = !obscure1),
                            ),
                          ),
                          
                          // --- Modern Password Strength Indicator ---
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: hasPassInput
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 10, left: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isPassStrong ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                                          size: 16,
                                          color: isPassStrong ? Colors.greenAccent.shade400 : Colors.orangeAccent,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            isPassStrong 
                                                ? "Strong password" 
                                                : "Must be 8+ chars, uppercase & special char",
                                            style: TextStyle(
                                              color: isPassStrong ? Colors.greenAccent.shade400 : Colors.orangeAccent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 16),

                          // --- Confirm Password Field ---
                          _buildTextField(
                            controller: confirmController,
                            focusNode: confirmFocus,
                            hint: "Confirm Password",
                            icon: Icons.lock_reset_rounded,
                            obscure: obscure2,
                            isDark: isDark,
                            suffix: IconButton(
                              icon: Icon(
                                obscure2 ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                              onPressed: () => setState(() => obscure2 = !obscure2),
                            ),
                          ),
                          const SizedBox(height: 25),

                          // --- Animated Register Button ---
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: vm.isLoading ? 55 : double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.blueAccent,
                                shadowColor: Colors.blueAccent.withOpacity(0.5),
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(vm.isLoading ? 30 : 16),
                                ),
                              ),
                              onPressed: vm.isLoading
                                  ? null
                                  : () async {
                                      FocusScope.of(context).unfocus();

                                      if (passController.text != confirmController.text) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Passwords do not match."), backgroundColor: Colors.redAccent),
                                        );
                                        return;
                                      }

                                      if (!isPassStrong) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Please enter a stronger password."), backgroundColor: Colors.orangeAccent),
                                        );
                                        return;
                                      }

                                      // 🔥 REGISTER FIRST
                                      final success = await vm.register(
                                        nameController.text.trim(),
                                        emailController.text.trim(),
                                        passController.text.trim(),
                                      );

                                      if (success && context.mounted) {
                                        // Modern themed dialog
                                        final enable = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            title: Text(
                                              "Enable Biometric Login?",
                                              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                            ),
                                            content: Text(
                                              "Would you like to use fingerprint login for faster access next time?",
                                              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: Text("No Thanks", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blueAccent,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                ),
                                                onPressed: () => Navigator.pop(context, true),
                                                child: const Text("Yes, Enable", style: TextStyle(color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (enable == true && vm.user != null) {
                                          await vm.enableBiometricsForUser(vm.user!.uid);
                                        }

                                        if (context.mounted) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (_) => const EmailVerificationView()),
                                          );
                                        }
                                      }
                                    },
                              child: vm.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : const Text(
                                      "Sign Up",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // --- Login Redirect ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Already have an account?", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Sign In", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Refactored TextField with Focus States & Theme Support
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool obscure = false,
    Widget? suffix,
    void Function(String)? onChanged,
  }) {
    bool isFocused = focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused ? Colors.blueAccent : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: isFocused
            ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 10, spreadRadius: 1)]
            : [],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscure,
        onChanged: onChanged,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: isFocused ? Colors.blueAccent : (isDark ? Colors.white54 : Colors.black45)),
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          filled: true,
          fillColor: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.03),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}