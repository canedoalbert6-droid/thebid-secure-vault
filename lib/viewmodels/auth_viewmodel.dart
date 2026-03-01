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
  bool shouldShowBiometric = false;
  String? errorMessage;

  AuthViewModel() {
    FirebaseAuth.instance.authStateChanges().listen((User? u) {
      user = u;
      notifyListeners();
    });
    checkBiometricAvailability();
  }

  Future<void> checkBiometricAvailability() async {
    final hasCreds = await _storageService.getCredentials();
    final isEnabled = await _storageService.isGlobalBiometricEnabled();
    shouldShowBiometric = hasCreds['email'] != null && hasCreds['password'] != null && isEnabled;
    notifyListeners();
  }

  // 🔐 LOGIN WITH BIOMETRICS (MUST BE INSIDE CLASS)
  Future<void> loginWithBiometrics() async {
    try {
      errorMessage = null;
      bool authenticated = await _biometricService.authenticate();

      if (!authenticated) {
        errorMessage = "Biometric authentication failed.";
        notifyListeners();
        return;
      }

      final creds = await _storageService.getCredentials();

      final email = creds['email'];
      final password = creds['password'];

      if (email != null && password != null) {
        await login(email, password);
      } else {
        errorMessage = "No stored credentials found for biometrics.";
        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
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

      if (updatedUser != null) {
        await _storageService.saveToken(updatedUser.uid);
        // 🔐 SAVE CREDENTIALS FOR BIOMETRIC LOGIN
        await _storageService.saveCredentials(email, password);
        user = updatedUser;
        await checkBiometricAvailability();
      }

    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? "An unknown error occurred.";
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
      errorMessage = null;
      isLoading = true;
      notifyListeners();

      final result = await _authService.register(email, password);
      await result.user!.updateDisplayName(name);
      
      // Force refresh to ensure name is caught in the state
      await refreshUser();

      await result.user!.sendEmailVerification();
      await _storageService.saveUserId(result.user!.uid);
      
      // 🔐 SAVE CREDENTIALS FOR BIOMETRIC LOGIN
      await _storageService.saveCredentials(email, password);
      
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? "Registration failed.";
      return false;
    } catch (e) {
      errorMessage = "An error occurred during registration.";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> enableBiometricsForUser(String uid) async {
    await _storageService.saveBiometricEnabled(uid, true);
    await checkBiometricAvailability();
  }

  Future<void> googleLogin() async {
    try {
      errorMessage = null;
      isLoading = true;
      notifyListeners();

      final result = await _authService.signInWithGoogle();
      final isNewUser = result.additionalUserInfo?.isNewUser ?? false;
      
      // 🔐 Extra Authentication Step (Optional: can be removed if annoying)
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
        errorMessage = "Biometric verification failed after Google login.";
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> facebookLogin() async {
    try {
      errorMessage = null;
      isLoading = true;
      notifyListeners();

      final result = await _authService.signInWithFacebook();
      await _storageService.saveToken(result.user!.uid);

      user = result.user;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      errorMessage = null;
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      errorMessage = "Failed to resend verification email.";
      notifyListeners();
    }
  }

  Future<void> updateName(String newName) async {
    try {
      errorMessage = null;
      isLoading = true;
      notifyListeners();
      await FirebaseAuth.instance.currentUser?.updateDisplayName(newName);
      await FirebaseAuth.instance.currentUser?.reload();
      user = FirebaseAuth.instance.currentUser;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = "Failed to update name.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
  await _authService.googleSignOut(); // 🔥 Google logout
  await FirebaseAuth.instance.signOut();
  user = null;
  await checkBiometricAvailability();
  notifyListeners();
}
}