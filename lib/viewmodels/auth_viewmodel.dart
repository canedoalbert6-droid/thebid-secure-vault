import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/biometric_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final BiometricService _biometricService = BiometricService();

  User? user;
  bool isLoading = false;
  String? errorMessage;

  AuthViewModel() {
    FirebaseAuth.instance.authStateChanges().listen((User? u) {
      user = u;
      notifyListeners();
    });
  }

  // 🔐 LOGIN WITH BIOMETRICS (MUST BE INSIDE CLASS)
  Future<void> loginWithBiometrics() async {
    try {
      bool authenticated = await _biometricService.authenticate();

      if (!authenticated) return;

      final creds = await _storageService.getCredentials();

      final email = creds['email'];
      final password = creds['password'];

      if (email != null && password != null) {
        await login(email, password);
      } else {
        notifyListeners();
      }
    } catch (e) {
      // Exception suppressed
      notifyListeners();
    } finally {
      // Optional: stop loading if you have a loading state for biometrics
    }
  }

  // 🔑 LOGIN
  Future<void> login(String email, String password) async {
    try {
      errorMessage = null;
      isLoading = true;
      notifyListeners();

      final result = await _authService.login(email, password);

      await result.user!.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;

      if (!updatedUser!.emailVerified) {
        await FirebaseAuth.instance.signOut();
        user = null;
        return;
      }

      await _storageService.saveToken(updatedUser.uid);

      // 🔐 SAVE CREDENTIALS FOR BIOMETRIC LOGIN
      await _storageService.saveCredentials(email, password);

      user = updatedUser;

    } catch (e) {
      errorMessage = "Invalid email or password.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    await FirebaseAuth.instance.currentUser?.reload();
    user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      final result = await _authService.register(email, password);
      await result.user!.updateDisplayName(name);
      
      // Force refresh to ensure name is caught in the state
      await refreshUser();

      await result.user!.sendEmailVerification();
      await _storageService.saveUserId(result.user!.uid);
      return true;
    } catch (e) {
      // Exception suppressed
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> enableBiometricsForUser(String uid) async {
    await _storageService.saveBiometricEnabled(uid, true);
  }

  Future<void> googleLogin() async {
    try {
      isLoading = true;
      notifyListeners();

      final result = await _authService.signInWithGoogle();
      final isNewUser = result.additionalUserInfo?.isNewUser ?? false;
      
      // 🔐 Extra Authentication Step
      bool authenticated = await _biometricService.authenticate();
      
      if (authenticated) {
        if (isNewUser) {
          await result.user!.sendEmailVerification();
        }
        await _storageService.saveToken(result.user!.uid);
        user = result.user;
      } else {
        // Sign out if authentication fails
        await FirebaseAuth.instance.signOut();
        await _authService.googleSignOut();
      }
    } catch (e) {
      // Exception suppressed
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> facebookLogin() async {
    try {
      isLoading = true;
      notifyListeners();

      final result = await _authService.signInWithFacebook();
      await _storageService.saveToken(result.user!.uid);

      user = result.user;
    } catch (e) {
      // Exception suppressed
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    } catch (e) {
      // Exception suppressed
    }
  }

  Future<void> updateName(String newName) async {
    try {
      isLoading = true;
      notifyListeners();
      await FirebaseAuth.instance.currentUser?.updateDisplayName(newName);
      await FirebaseAuth.instance.currentUser?.reload();
      user = FirebaseAuth.instance.currentUser;
    } catch (e) {
      // Exception suppressed
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
  await _authService.googleSignOut(); // 🔥 Google logout
  await FirebaseAuth.instance.signOut();
  user = null;
  notifyListeners();
}
}