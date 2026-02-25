import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/profile_view.dart';
import 'views/email_verification_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()..loadTheme()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeVM = context.watch<ThemeViewModel>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secure Auth',
      theme: themeVM.isDark ? ThemeData.dark() : ThemeData.light(),
      home: const AuthWrapper(),
      routes: {
        '/login': (_) => const LoginView(),
        '/register': (_) => const RegisterView(),
        '/profile': (_) => const ProfileView(),
        '/verify': (_) => const EmailVerificationView(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    if (authVM.user == null) {
      return const LoginView();
    }

    if (authVM.user!.isAnonymous) {
      return const LoginView();
    }

    if (!authVM.user!.emailVerified) {
      return const EmailVerificationView();
    }

    return const ProfileView();
  }
}

