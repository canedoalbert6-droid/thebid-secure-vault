import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class EmailVerificationView extends StatefulWidget {
  const EmailVerificationView({super.key});

  @override
  State<EmailVerificationView> createState() =>
      _EmailVerificationViewState();
}

class _EmailVerificationViewState
    extends State<EmailVerificationView> {

  @override
  void initState() {
    super.initState();
    checkEmailVerified();
  }

  Future<void> checkEmailVerified() async {
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    
    final authVM = context.read<AuthViewModel>();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    
    await currentUser.reload();
    if (!mounted) return;

    if (currentUser.emailVerified) {
      await authVM.refreshUser();
      // 🚀 NO MANUAL NAVIGATION NEEDED
      // AuthWrapper will automatically switch to ProfileView
    } else {
      checkEmailVerified();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.read<AuthViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mark_email_read_rounded,
                  size: 80, color: Colors.blueAccent),
            ),
            const SizedBox(height: 30),
            const Text(
              "Verify Your Email",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "We've sent a verification link to:\n${FirebaseAuth.instance.currentUser?.email}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Colors.blueAccent),
            const SizedBox(height: 40),
            const Text(
              "Didn't receive the email?",
              style: TextStyle(color: Colors.white54),
            ),
            TextButton(
              onPressed: () async {
                await authVM.resendVerificationEmail();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Verification email resent!")),
                  );
                }
              },
              child: const Text(
                "Resend Verification Email",
                style: TextStyle(
                    color: Colors.blueAccent, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () async {
                await authVM.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              child: const Text(
                "Back to Login",
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}