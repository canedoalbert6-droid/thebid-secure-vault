import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../services/storage_service.dart';
import '../services/local_auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final StorageService _storageService = StorageService();
  final LocalAuthService _localAuthService = LocalAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? user;
  UserModel? userModel;
  bool isLoading = false;
  bool shouldShowBiometric = false;
  String? errorMessage;
  int _biometricFailures = 0;

  AuthViewModel() {
    _initAuth();
    checkBiometricAvailability();
  }

  void _initAuth() {
    FirebaseAuth.instance.authStateChanges().listen((User? u) async {
      debugPrint("Auth state changed: user is ${u?.email ?? 'signed out'}");
      
      // If we already have a user and the new state is null, just sign out
      if (user != null && u == null) {
        user = null;
        userModel = null;
        isLoading = false;
        notifyListeners();
        return;
      }

      user = u;
      if (u != null) {
        isLoading = true;
        notifyListeners();
        
        debugPrint("Loading profile for ${u.uid}");
        userModel = await _firestoreService.getUserProfile(u.uid);
        debugPrint("Profile loaded: ${userModel?.displayName ?? 'No Model'}");
        
        isLoading = false;
        notifyListeners();
      } else {
        userModel = null;
        isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> checkBiometricAvailability() async {
    final hasCreds = await _storageService.getCredentials();
    final authType = await _storageService.getAuthType();
    final isEnabled = await _storageService.isGlobalBiometricEnabled();
    final hasHardware = await _localAuthService.isBiometricAvailable();

    bool hasAuthMethod = false;
    if (authType == 'email') {
      hasAuthMethod = hasCreds['email'] != null && hasCreds['password'] != null;
    } else if (authType == 'google' || authType == 'facebook') {
      hasAuthMethod = true; // Social login doesn't need stored password
    }

    shouldShowBiometric = hasAuthMethod && isEnabled && hasHardware;
    notifyListeners();
  }

  // 🔐 LOGIN WITH BIOMETRICS (MUST BE INSIDE CLASS)
  Future<void> loginWithBiometrics() async {
    try {
      errorMessage = null;
      bool authenticated = await _localAuthService.authenticate();

      if (!authenticated) {
        _biometricFailures++;
        if (_biometricFailures >= 3) {
          shouldShowBiometric = false;
          errorMessage = "Too many failed attempts. Please use password.";
        } else {
          errorMessage = "Biometric authentication failed. (${3 - _biometricFailures} attempts left)";
        }
        notifyListeners();
        return;
      }
      
      _biometricFailures = 0; // Reset on success

      final authType = await _storageService.getAuthType();

      if (authType == 'google') {
        await googleLogin();
      } else if (authType == 'facebook') {
        await facebookLogin();
      } else if (authType == 'email') {
        final creds = await _storageService.getCredentials();
        final email = creds['email'];
        final password = creds['password'];

        if (email != null && password != null) {
          await login(email, password);
        } else {
          errorMessage = "No stored credentials found for biometrics.";
          notifyListeners();
        }
      } else {
        errorMessage = "No biometric auth method set.";
        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  // 🔑 CHANGE PASSWORD
  Future<void> changePassword(String newPassword) async {
    try {
      await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  // 🔑 REGISTER
  Future<void> login(String email, String password) async {
    try {
      errorMessage = null;
      isLoading = true;
      notifyListeners();

      final result = await _authRepository.login(email, password);

      await result.user!.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;

      if (updatedUser != null) {
        await _storageService.saveToken(updatedUser.uid);
        // 🔐 SAVE CREDENTIALS FOR BIOMETRIC LOGIN
        await _storageService.saveCredentials(email, password);
        await _storageService.saveAuthType('email');
        user = updatedUser;
        userModel = await _firestoreService.getUserProfile(updatedUser.uid);
        await checkBiometricAvailability();
      }

    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          errorMessage = "Incorrect password. Please try again.";
          break;
        case 'user-not-found':
          errorMessage = "No account found with this email.";
          break;
        case 'invalid-email':
          errorMessage = "The email address is not valid.";
          break;
        case 'user-disabled':
          errorMessage = "This account has been disabled.";
          break;
        default:
          errorMessage = e.message ?? "An unknown error occurred.";
      }
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
    if (user != null) {
      userModel = await _firestoreService.getUserProfile(user!.uid);
    } else {
      userModel = null;
    }
    notifyListeners();
  }

  Future<void> logWorkout() async {
    if (user != null) {
      await _firestoreService.logWorkoutCompletion(user!.uid);
      await refreshUser(); // Update the local user model to show new stats instantly
    }
  }

  Future<bool> register(String name, String email, String password, {int? age, double? weight, double? height, String? gender, String? address}) async {
    try {
      errorMessage = null;
      isLoading = true;
      notifyListeners();

      debugPrint("Starting registration for $email");
      final result = await _authRepository.register(email, password).timeout(const Duration(seconds: 20));
      debugPrint("Firebase Auth registration successful");

      if (result.user != null) {
        // Step 1: Update Display Name
        try {
          await result.user!.updateDisplayName(name).timeout(const Duration(seconds: 5));
          debugPrint("Display name updated");
        } catch (e) {
          debugPrint("Display name update failed: $e");
        }
        
        // Step 2: Send Email Verification
        try {
          await result.user!.sendEmailVerification().timeout(const Duration(seconds: 10));
          debugPrint("Verification email sent");
        } catch (e) {
          debugPrint("Verification email send failed: $e");
        }

        // Step 3: Local Storage
        try {
          await _storageService.saveUserId(result.user!.uid).timeout(const Duration(seconds: 5));
          await _storageService.saveCredentials(email, password).timeout(const Duration(seconds: 5));
          await _storageService.saveAuthType('email').timeout(const Duration(seconds: 5));
          debugPrint("Auth data saved to Secure Storage");
        } catch (e) {
          debugPrint("Local storage save failed: $e");
        }
        
        // Step 4: Firestore Profile
        try {
          final userModel = UserModel(
            uid: result.user!.uid,
            email: email,
            displayName: name,
            age: age,
            weight: weight,
            height: height,
            gender: gender,
            address: address,
          );
          debugPrint("Creating Firestore profile...");
          await _firestoreService.createUserProfile(userModel);
          debugPrint("Firestore profile created");
        } catch (e) {
          debugPrint("Firestore profile creation failed: $e");
        }

        // Step 5: Refresh User State
        try {
          await refreshUser().timeout(const Duration(seconds: 10));
          await checkBiometricAvailability().timeout(const Duration(seconds: 5));
          debugPrint("Registration complete");
        } catch (e) {
          debugPrint("User refresh failed: $e");
        }
      }
      
      return true;
    } on FirebaseAuthException catch (e) {
      if (FirebaseAuth.instance.currentUser != null) {
        debugPrint("Secondary FirebaseAuthException ignored: ${e.code}");
        return true;
      }
      debugPrint("FirebaseAuthException during registration: ${e.code} - ${e.message}");
      errorMessage = e.message ?? "Registration failed.";
      return false;
    } catch (e) {
      debugPrint("Unexpected error during registration: $e");
      if (FirebaseAuth.instance.currentUser != null) {
        debugPrint("Secondary registration step failed: $e");
        return true;
      }
      errorMessage = "An error occurred during registration. Details: $e";
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

  Future<void> googleLogin({bool isRegistration = false}) async {
    try {
      errorMessage = null;
      isLoading = true;
      notifyListeners();

      final result = await _authRepository.signInWithGoogle();
      final isNewUser = result.additionalUserInfo?.isNewUser ?? false;

      if (isRegistration && !isNewUser) {
        await logout();
        errorMessage = "The account already exists.";
        return;
      }

      if (isNewUser) {
        await result.user!.sendEmailVerification();
        // Create an empty profile for google user
        final userModel = UserModel(
          uid: result.user!.uid,
          email: result.user!.email ?? '',
          displayName: result.user!.displayName ?? '',
        );
        await _firestoreService.createUserProfile(userModel);
      }
      await _storageService.saveToken(result.user!.uid);
      await _storageService.saveAuthType('google');
      user = result.user;
      userModel = await _firestoreService.getUserProfile(result.user!.uid);
      await checkBiometricAvailability();
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
    } on PlatformException catch (e) {
      if (e.code == 'network_error' ||
          (e.message ?? '').contains('ApiException: 7')) {
        errorMessage =
            "Google sign-in failed because of a network connection problem. Please check your internet and try again.";
      } else {
        errorMessage = e.message ?? "Google sign-in failed.";
      }
    } catch (e) {
      errorMessage = "Google sign-in failed. Please try again.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> facebookLogin({bool isRegistration = false}) async {
    try {
      errorMessage = null;
      isLoading = true;
      notifyListeners();

      final result = await _authRepository.signInWithFacebook();
      final isNewUser = result.additionalUserInfo?.isNewUser ?? false;

      if (isRegistration && !isNewUser) {
        await logout();
        errorMessage = "The account already exists.";
        return;
      }

      if (isNewUser) {
        final userModel = UserModel(
          uid: result.user!.uid,
          email: result.user!.email ?? '',
          displayName: result.user!.displayName ?? '',
        );
        await _firestoreService.createUserProfile(userModel);
      }

      await _storageService.saveToken(result.user!.uid);
      await _storageService.saveAuthType('facebook');
      user = result.user;
      userModel = await _firestoreService.getUserProfile(result.user!.uid);
      await checkBiometricAvailability();
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
  await _authRepository.googleSignOut(); // 🔥 Google logout
  await FirebaseAuth.instance.signOut();
  user = null;
  userModel = null;
  await checkBiometricAvailability();
  notifyListeners();
}
}