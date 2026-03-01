import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  // =========================
  // 🔐 AUTH DATA
  // =========================

  Future<void> saveUserId(String uid) async {
    await _storage.write(key: 'user_id', value: uid);
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // =========================
  // 🔐 BIOMETRIC FLAG
  // =========================

  Future<void> saveBiometricEnabled(
      String uid, bool enabled) async {
    await _storage.write(
      key: 'biometric_$uid',
      value: enabled.toString(),
    );
    // Also save a global flag for the login screen
    await _storage.write(key: 'global_biometric_enabled', value: enabled.toString());
  }

  Future<bool> isGlobalBiometricEnabled() async {
    final value = await _storage.read(key: 'global_biometric_enabled');
    return value == 'true';
  }

  Future<bool> isBiometricEnabled(String uid) async {
    final value =
        await _storage.read(key: 'biometric_$uid');
    return value == 'true';
  }

  // =========================
  // 🔐 BIOMETRIC CREDENTIALS
  // =========================

  Future<void> saveCredentials(
      String email, String password) async {
    await _storage.write(key: 'bio_email', value: email);
    await _storage.write(key: 'bio_password', value: password);
  }

  Future<Map<String, String?>> getCredentials() async {
    final email = await _storage.read(key: 'bio_email');
    final password = await _storage.read(key: 'bio_password');

    return {
      'email': email,
      'password': password,
    };
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: 'bio_email');
    await _storage.delete(key: 'bio_password');
  }

  // =========================
  // 🎨 THEME MODE
  // =========================

  Future<void> setDarkMode(bool value) async {
    await _storage.write(
      key: 'dark_mode',
      value: value.toString(),
    );
  }

  Future<bool> isDarkMode() async {
    final value =
        await _storage.read(key: 'dark_mode');
    return value == 'true';
  }
}