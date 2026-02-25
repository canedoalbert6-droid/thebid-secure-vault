import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential> register(
      String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> login(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    await _googleSignIn.signOut(); // force chooser

    final GoogleSignInAccount? googleUser =
        await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception("Google login cancelled");
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  Future<void> googleSignOut() async {
    await _googleSignIn.signOut();
  }

  Future<UserCredential> signInWithFacebook() async {
    final result = await FacebookAuth.instance.login();

    if (result.status != LoginStatus.success) {
      throw Exception("Facebook login failed");
    }

    final credential = FacebookAuthProvider.credential(
      result.accessToken!.tokenString,
    );

    return await _auth.signInWithCredential(credential);
  }
}