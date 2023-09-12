import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(userCredential.user!.email);
    } catch (e) {
      print("Erro ao fazer login: $e");
      return;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
