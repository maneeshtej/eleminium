import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

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

      await _firebaseFirestore.collection('users').doc(user.uid).set({
        'name': user.displayName,
        'email': user.email,
        'photoURL': user.photoURL,
        'lastSignIn': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

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
