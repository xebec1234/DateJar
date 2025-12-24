import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId:
        '35587555854-f6gndhtj49achunn8khs6rr0bsjovk1f.apps.googleusercontent.com',
  );

  static Future<String?> signInAndGetIdToken() async {
    try {
      await _googleSignIn.signOut(); // reset cached session
      final account = await _googleSignIn.signIn(); // force picker
      if (account == null) return null;

      final auth = await account.authentication;
      final idToken = auth.idToken;
      final payload = idToken!.split('.')[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      print("Token payload: $decoded");
      print("idToken: ${auth.idToken}"); // DEBUG: must show token
      return auth.idToken;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
