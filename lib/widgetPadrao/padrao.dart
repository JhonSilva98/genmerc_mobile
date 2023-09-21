import 'package:flutter/material.dart';
import 'package:flutter_ticket/flutter_ticket.dart';
import 'package:genmerc_mobile/firebase/bancoDados.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:url_launcher/url_launcher_string.dart';

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

  String obterNomeDoMes(int numeroDoMes) {
    final DateTime data = DateTime(1, numeroDoMes);
    return DateFormat('MMMM', 'pt_BR').format(data);
  }

  String obterNomeDoDiaDaSemana(int ano, int mes, int dia) {
    final DateTime data = DateTime(ano, mes, dia);
    String nomeDoDia = DateFormat('EEEE', 'pt_BR').format(data);
    return nomeDoDia;
  }

  Map<String, dynamic> colorEtiqueta(String dataVencimento) {
    DateTime data = DateTime.now();

    DateTime dataComparar = DateTime.parse(dataVencimento);

    Map<String, dynamic> mapColorText = {};

    if (data.isBefore(dataComparar)) {
      mapColorText.addAll({'nome': 'Em dias', 'cor': Colors.green});
      return mapColorText;
    } else if (data.year == dataComparar.year &&
        data.day == dataComparar.day &&
        data.month == dataComparar.month) {
      mapColorText.addAll({'nome': 'Vence Hoje', 'cor': Colors.orange});
      return mapColorText;
    } else if (data.isAfter(dataComparar)) {
      mapColorText.addAll({'nome': 'Vencido', 'cor': Colors.red});

      return mapColorText;
    }

    // Caso as datas sejam diferentes e nenhum dos blocos anteriores seja atendido
    // Você pode tratar isso de acordo com a sua lógica
    mapColorText.addAll({'nome': 'Sem Status', 'cor': Colors.grey});
    return mapColorText;
  }

  Widget cardPersonalite(String nome, String data, double valor, numero,
      context, String email, String docFiado) {
    return InkWell(
      onLongPress: () async {
        await BancoDadosFirebase()
            .setVendasDeleteFiadoDoc(email, docFiado, valor, context);
      },
      borderRadius: BorderRadius.circular(10),
      child: Card(
        elevation: 10,
        shadowColor: Colors.blue,
        color: Colors.white,
        child: Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.vertical,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                // Cor da etiqueta
                decoration: BoxDecoration(
                  color: colorEtiqueta(data)['cor'],
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10)),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 16), // Espaçamento da etiqueta
                child: Text(
                  colorEtiqueta(data)['nome'],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 2.0,
                  ),
                  child: Text(
                    nome,
                    style: const TextStyle(
                      color: Color(0XFFce5355),
                      fontSize: 25,
                      fontFamily: 'Demi',
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Pagar dia \n${converterData(data)}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 50,
                      fontFamily: 'Demi',
                    ),
                  ),
                ),
              ),
            ),
            const Divider(
              color: Colors.black,
            ),
            Expanded(
              flex: 2,
              child: FittedBox(
                child: Text(
                  "R\$ ${valor.toString().replaceAll('.', ',')}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 25,
                    fontFamily: 'Demi',
                  ),
                ),
              ),
            ),
            const Divider(
              color: Colors.black,
            ),
            Expanded(
                flex: 2,
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.description_sharp),
                        ),
                      ),
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: IconButton(
                          onPressed: () async {
                            await fazerChamada(numero);
                          },
                          icon: const Icon(
                            Icons.phone,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: IconButton(
                          onPressed: () async {
                            await abrirWhatsApp(numero, nome, valor);
                          },
                          icon: const Icon(Icons.message),
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget ticket(
      String nomeDoDocumento, double dados, String dateNameMes, ano, mes) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 2,
        right: 2,
      ),
      child: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            flex: 1,
            child: Ticket(
              innerRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0)),
              outerRadius: const BorderRadius.all(Radius.circular(10.0)),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, 4.0),
                  blurRadius: 2.0,
                  spreadRadius: 2.0,
                  color: Color.fromRGBO(196, 196, 196, .76),
                )
              ],
              child: Container(
                color: Colors.white,
                width: 300,
                height: 70,
                child: Flex(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  direction: Axis.vertical,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 5,
                            top: 5,
                          ),
                          child: FittedBox(
                            child: Text(
                              dateNameMes,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: FittedBox(
                          child: Text(
                            nomeDoDocumento,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 50,
                                fontFamily: 'Demi'),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Ticket(
              innerRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0)),
              outerRadius: const BorderRadius.all(Radius.circular(10.0)),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, 4),
                  blurRadius: 2.0,
                  spreadRadius: 2.0,
                  color: Color.fromRGBO(196, 196, 196, .76),
                )
              ],
              child: Container(
                color: Colors.white,
                width: 300,
                height: 100,
                child: Flex(
                  direction: Axis.vertical,
                  //mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    //const Divider(),
                    Expanded(
                      flex: 1,
                      child: FittedBox(
                        child: Text(
                          obterNomeDoDiaDaSemana(
                              ano, mes, int.parse(nomeDoDocumento)),
                          style: const TextStyle(
                              color: Color(0XFF5e4a9c),
                              fontSize: 30,
                              fontFamily: 'Demi'),
                        ),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      flex: 2,
                      child: FittedBox(
                        child: Text(
                          "R\$ ${dados.toString().replaceAll('.', ',')}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 25,
                            fontFamily: 'Demi',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<ProgressDialog> progress(context) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(
        message: 'Carregando...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: const CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: const TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: const TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
    return progressDialog;
  }

  Future<void> fazerChamada(String numero) async {
    final urlChamada = 'tel:$numero';

    if (await canLaunchUrlString(urlChamada)) {
      await launchUrlString(urlChamada);
    } else {
      throw 'Não foi possível fazer a chamada.';
    }
  }

  Future<void> abrirWhatsApp(String numero, String nome, double valor) async {
    final mensagem =
        'Olá $nome, tudo bom? Apenas relembrando sobre a compra aqui no mercadinho no valor de R\$ ${valor.toString().replaceAll(".", ",")}. Aguardo o pagamento conforme combinado. Obrigado.';
    final urlWhatsApp =
        'https://api.whatsapp.com/send?phone=$numero&text=$mensagem';

    if (await canLaunchUrlString(urlWhatsApp)) {
      await launchUrlString(urlWhatsApp);
    } else {
      throw 'Não foi possível abrir o WhatsApp.';
    }
  }

  String converterData(String dataAmericana) {
    // Divida a data americana em partes
    List<String> partes = dataAmericana.split('-');

    // Verifique se há três partes (ano, mês, dia)
    if (partes.length == 3) {
      String ano = partes[0];
      String mes = partes[1];
      String dia = partes[2];

      // Formate a data no formato brasileiro (DIA/MÊS/ANO)
      return '$dia/$mes/$ano';
    }

    // Se a conversão falhar, retorne a data original
    return dataAmericana;
  }
}
