import 'package:flutter/material.dart';

class MyWidgetPadrao {
  static TextStyle myBeautifulTextStyle = const TextStyle(
    color: Colors.white, // Cor do texto
    fontSize: 50.0, // Tamanho da fonte
    fontWeight: FontWeight.bold, // Peso da fonte (negrito)
    letterSpacing: 1.2, // Espaçamento entre caracteres
    wordSpacing: 2.0, // Espaçamento entre palavras
    shadows: [
      Shadow(
        color: Colors.black,
        offset: Offset(2, 2),
        blurRadius: 3,
      ),
    ], // Sombreamento do texto
  );
  static TextStyle myBeautifulTextStyleBlack = const TextStyle(
    color: Colors.blue, // Cor do texto
    //fontSize: 50.0, // Tamanho da fonte
    fontWeight: FontWeight.bold, // Peso da fonte (negrito)
    //letterSpacing: 1.2, // Espaçamento entre caracteres
    //wordSpacing: 2.0, // Espaçamento entre palavras
    shadows: [
      Shadow(
        color: Colors.white,
        offset: Offset(2, 2),
        blurRadius: 3,
      ),
    ], // Sombreamento do texto
  );
  static showErrorDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Erro"),
          content: const Text(
              "Ocorreu um erro ao processar sua solicitação, verifique a sua conexão ou entre em contato com o ADM."),
          actions: [
            TextButton(
              child: const Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static showErrorDialogBancoDados(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Erro"),
          content: const Text("Não possui dados desse mês e ano"),
          actions: [
            TextButton(
              child: const Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
