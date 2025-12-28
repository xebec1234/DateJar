import 'package:google_sign_in/google_sign_in.dart';

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
  
      return auth.idToken;
    } catch (e) {
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
