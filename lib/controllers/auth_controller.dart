import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final _auth   = FirebaseAuth.instance;
  final _google = GoogleSignIn();

  /// Only fires for Google sign‑in.
  final firebaseUser = Rxn<User>();

  /// Tracks pure‑local “guest mode.”
  final isGuest = false.obs;

  bool get isLoggedIn     => firebaseUser.value != null;
  bool get isPlayingGuest => isGuest.value;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  /// Google SSO
  Future<void> signInWithGoogle() async {
    final acct = await _google.signIn();
    if (acct == null) return;
    final auth = await acct.authentication;
    final cred = GoogleAuthProvider.credential(
        idToken: auth.idToken, accessToken: auth.accessToken);
    await _auth.signInWithCredential(cred);
    isGuest.value = false;
  }

  /// **NEW**: Local guest sign‑up
  Future<void> signUpAsGuest(String name) async {
    final prefs = Get.find<SharedPreferences>();
    await prefs.setString('guest_name', name);
    isGuest.value = true;
    // ensure any Firebase user is signed out
    if (_auth.currentUser != null) {
      await _auth.signOut();
      await _google.signOut();
    }
  }

  /// Retrieves the stored guest name, or null.
  String? get guestName => Get.find<SharedPreferences>().getString('guest_name');

  /// Sign out both modes
  Future<void> signOut() async {
    if (isGuest.value) {
      isGuest.value = false;
    } else if (firebaseUser.value != null) {
      await _google.signOut();
      await _auth.signOut();
    }
  }
}
