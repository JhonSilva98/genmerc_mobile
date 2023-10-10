import 'package:flutter/material.dart';
import 'package:genmerc_mobile/tela/tela_principal.dart';

class MyAppTroca extends StatelessWidget {
  const MyAppTroca({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TelaPrincipal(),
    );
  }
}
