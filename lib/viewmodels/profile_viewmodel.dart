import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/storage_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final StorageService _storage = StorageService();

  bool biometricEnabled = false;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> loadBiometric() async {
    if (_uid == null) return;

    biometricEnabled =
        await _storage.isBiometricEnabled(_uid!);

    notifyListeners();
  }

  Future<void> toggleBiometric(bool value) async {
    if (_uid == null) return;

    biometricEnabled = value;

    await _storage.saveBiometricEnabled(_uid!, value);

    notifyListeners();
  }
}