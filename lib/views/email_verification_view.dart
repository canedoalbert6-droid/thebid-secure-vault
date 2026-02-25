import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    await FirebaseAuth.instance.currentUser?.reload();

    if (FirebaseAuth.instance.currentUser!.emailVerified) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/profile');
      }
    } else {
      checkEmailVerified();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mark_email_read,
                size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              "Verification Email Sent\nPlease check your inbox.",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}