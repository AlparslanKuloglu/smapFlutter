import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static const String webClientId =
      '435249384881-c42fcnbktq2kde7qhovrsgsgjgreber4.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;

    await _googleSignIn.initialize(serverClientId: webClientId);

    _initialized = true;
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      await _init();

      final GoogleSignInAccount account = await _googleSignIn.authenticate();

      final auth = account.authentication;

      print(account.email);
      print(auth.idToken);

      return account;
    } on GoogleSignInException catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
