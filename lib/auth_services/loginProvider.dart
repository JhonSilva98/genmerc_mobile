import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;

  Future<void> signInWithEmailAndPassword(
      String email, String password, context) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
    } catch (error) {
      if (error.toString() ==
          '[firebase_auth/user-disabled] The user account has been disabled by an administrator.') {
        await _auth.signOut();
        _user = null;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Conta Desativada'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sua conta foi desativada. Por favor, entre em contato com o suporte para obter assistência.',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Fechar o diálogo
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erro nos dados ou conexão'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sua senha ou email são inválidos ou está sem conexão com a internet. Por favor, tente novamente.',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Fechar o diálogo
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
      rethrow;
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }
}
