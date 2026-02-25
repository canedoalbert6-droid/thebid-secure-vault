class Validators {
  static bool isValidPassword(String password) {
    final regex =
        RegExp(r'^(?=.*[A-Z])(?=.*[!@#\$&*~]).{8,}$');
    return regex.hasMatch(password);
  }
}