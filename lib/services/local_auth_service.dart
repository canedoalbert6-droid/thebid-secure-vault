import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final bool isSupported = await _auth.isDeviceSupported();
      final bool canCheck = await _auth.canCheckBiometrics;
      final List<BiometricType> available =
          await _auth.getAvailableBiometrics();

      return isSupported && canCheck && available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final bool available = await isBiometricAvailable();

      if (!available) {
        return false;
      }

      return await _auth.authenticate(
        localizedReason: 'Authenticate to access TheBid Secure Vault',
        biometricOnly: true,
      );
    } catch (_) {
      return false;
    }
  }
}