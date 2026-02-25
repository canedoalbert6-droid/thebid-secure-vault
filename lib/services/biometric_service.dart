import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

 Future<bool> authenticate() async {
  try {
    final bool canCheck = await _auth.canCheckBiometrics;

    if (!canCheck) {
      return false;
    }

    return await _auth.authenticate(
      localizedReason: 'Authenticate to access TheBid Secure Vault',
      biometricOnly: true,
    );
  } catch (e) {
    return false;
  }
}
}