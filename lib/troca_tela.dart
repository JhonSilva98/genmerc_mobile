import 'package:flutter/material.dart';
import 'package:genmerc_mobile/tela/tela_principal.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'), // Define o idioma para português do Brasil
      ],
      home: const TelaPrincipal(),
    );
  }
}
