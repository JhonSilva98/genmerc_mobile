import 'package:flutter/material.dart';
import 'package:genmerc_mobile/auth_services/keystore.dart';
import 'package:genmerc_mobile/auth_services/login_provider.dart';
import 'package:genmerc_mobile/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:genmerc_mobile/troca_tela.dart';
import 'package:provider/provider.dart';
import 'firebase/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    Map map = await SecureStorage().getCredentials();

    if (map['email'] == null || map['password'] == null) {
      runApp(
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
          child: const MyApp(),
        ),
      );
    } else if (map.containsKey('email') && map.containsKey('password')) {
      var authProvider =
          AuthProvider(); // Sua classe AuthProvider com Firebase Auth e Provider
      await authProvider.signInWithEmailAndPassword(map['email'],
          map['password']); // Use as credenciais salvas localmente, se existirem
      runApp(
        ChangeNotifierProvider(
          create: (context) => authProvider,
          child: const MyAppTroca(),
        ),
      );
    } else {
      runApp(
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
          child: const MyApp(),
        ),
      );
    }
  } catch (erro) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => AuthProvider(),
        child: const MyApp(),
      ),
    );
  }
}
