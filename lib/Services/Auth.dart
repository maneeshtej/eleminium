import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> googleSignIn() async {
    try {
      print("[DEBUG] Initiating Google Sign-In...");
      final googleSignInAccount = await _googleSignIn.signIn();

      if (googleSignInAccount == null) {
        print("[DEBUG] Sign-In cancelled by user.");
        return "cancelled";
      }

      print("[DEBUG] Google account selected: ${googleSignInAccount.email}");

      final googleAuth = await googleSignInAccount.authentication;

      print("[DEBUG] AccessToken: ${googleAuth.accessToken}");
      print("[DEBUG] IDToken: ${googleAuth.idToken}");

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("[DEBUG] Signing in with Firebase using credentials...");

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user == null) {
        print("[ERROR] Firebase user is null after credential sign-in.");
        return "no user";
      }

      print("[DEBUG] Firebase Sign-In successful.");
      print("[DEBUG] UID: ${user.uid}");
      print("[DEBUG] Name: ${user.displayName}");
      print("[DEBUG] Email: ${user.email}");
      print("[DEBUG] Photo URL: ${user.photoURL}");

      return "success";
    } catch (e, stack) {
      print("[ERROR] Exception during Google Sign-In: $e");
      print("[ERROR] Stack trace: $stack");
      return "error: $e";
    }
  }

  Future<String> signOut() async {
    _googleSignIn.signOut();
    return "succes";
  }
}
