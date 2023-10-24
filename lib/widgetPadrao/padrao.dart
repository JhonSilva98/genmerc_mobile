import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ticket/flutter_ticket.dart';
import 'package:genmerc_mobile/firebase/banco_dados.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:google_places_autocomplete_text_field/model/prediction.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MyWidgetPadrao {
  final player = AudioPlayer();
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
    fontWeight: FontWeight.bold, // Peso da fonte (negrito)
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

  static showErrorDialogBancoDados(
    BuildContext context,
  ) async {
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

  String obterNomeDoMes(
    int numeroDoMes,
  ) {
    final DateTime data = DateTime(1, numeroDoMes);
    return DateFormat('MMMM', 'pt_BR').format(data);
  }

  String obterNomeDoDiaDaSemana(
    int ano,
    int mes,
    int dia,
  ) {
    final DateTime data = DateTime(ano, mes, dia);
    String nomeDoDia = DateFormat('EEEE', 'pt_BR').format(data);
    return nomeDoDia;
  }

  Map<String, dynamic> colorEtiqueta(
    String dataVencimento,
  ) {
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

  Future<Widget> cardPersonalite(
      String nome,
      String data,
      double valor,
      numero,
      context,
      String email,
      String docFiado,
      var listaProdutos,
      String endereco,
      String dataCompra) async {
    return InkWell(
      onLongPress: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmação de Pagamento'),
              content: const Text('Já realizou o pagamento?'),
              actions: <Widget>[
                Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: IconButton(
                        onPressed: () async {
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Apagar'),
                                  content: const Text(
                                      "Você deseja apagar esse fiado?"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Fechar o dialog
                                      },
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      style: const ButtonStyle(
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.red)),
                                      onPressed: () async {
                                        try {
                                          await BancoDadosFirebase()
                                              .deleteFiado(
                                            email,
                                            docFiado,
                                            context,
                                          );
                                          if (!context.mounted) return;
                                          Navigator.of(context).pop();
                                          if (!context.mounted) return;
                                          Navigator.of(context).pop();
                                        } catch (e) {
                                          MyWidgetPadrao.showErrorDialog(
                                            context,
                                          );
                                        }
                                      },
                                      child: const Text(
                                        "Apagar",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              });
                        },
                        icon: const Icon(
                          Icons.delete_rounded,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Flexible(
                      flex: 3,
                      child: ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.orange),
                            foregroundColor:
                                MaterialStatePropertyAll(Colors.white)),
                        onPressed: () async {
                          if (!context.mounted) return;
                          Navigator.of(context).pop();

                          final DateFormat dateFormat =
                              DateFormat('dd/MM/yyyy');
                          TextEditingController dataController =
                              TextEditingController();
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  title: const Text('Reagendamento'),
                                  content: TextFormField(
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Data a pagar (dd/MM/yyyy)',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(
                                        Icons.calendar_month_outlined,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                    ),
                                    keyboardType: TextInputType.datetime,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    onTap: () async {
                                      final DateTime currentDate =
                                          DateTime.now();
                                      final DateTime lastDate = currentDate
                                          .add(const Duration(days: 5 * 365));
                                      final date = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: lastDate);
                                      final getDateController =
                                          '${date!.day.toString().length < 2 ? '0${date.day.toString()}' : date.day.toString()}/${date.month.toString().length < 2 ? '0${date.month.toString()}' : date.month.toString()}/${date.year}';

                                      dataController.text = getDateController;
                                    },
                                    controller: dataController,
                                    validator: (value) {
                                      try {
                                        if (value == null || value.isEmpty) {
                                          return 'Campo obrigatório';
                                        }

                                        dateFormat.parseStrict(
                                            value); // Tenta fazer o parse da data
                                        return null; // A data é válida
                                      } catch (e) {
                                        return 'Data inválida';
                                      }
                                    },
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                        onPressed: () {
                                          if (!context.mounted) return;
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Cancelar")),
                                    ElevatedButton(
                                        onPressed: () async {
                                          if (dataController.text.isNotEmpty) {
                                            String dataFinal =
                                                converterDataBrasileira(
                                                    dataController.text);
                                            try {
                                              await BancoDadosFirebase()
                                                  .updateReagendar(
                                                      email,
                                                      docFiado,
                                                      dataFinal,
                                                      context);
                                              if (!context.mounted) return;
                                              Navigator.of(context).pop();
                                            } catch (e) {
                                              await showErrorDialog(context);
                                            }
                                          }
                                        },
                                        child: const Text("Reagendar")),
                                  ]);
                            },
                          );
                        },
                        child: const FittedBox(
                          fit: BoxFit.cover,
                          child: Text(
                            'Reagendar',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Flexible(
                      flex: 2,
                      child: ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.green),
                            foregroundColor:
                                MaterialStatePropertyAll(Colors.white)),
                        onPressed: () async {
                          // Adicione a lógica a ser executada quando o usuário selecionar "Pago" aqui
                          await BancoDadosFirebase().setVendasDeleteFiadoDoc(
                            email,
                            docFiado,
                            valor,
                            context,
                          );
                          await player.play(
                            AssetSource(
                              'Caixa_Registradora.mp3',
                            ),
                          );
                          if (!context.mounted) return;
                          Navigator.of(context).pop(); // Fecha o AlertDialog
                        },
                        child: const FittedBox(
                          child: Text('Pago'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
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
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                        left: 5,
                        top: 5,
                      ),
                      child: FittedBox(
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Color.fromARGB(230, 158, 158, 158),
                        ),
                      ),
                    ),
                    Container(
                      // Cor da etiqueta
                      decoration: BoxDecoration(
                        color: colorEtiqueta(data)['cor'],
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16), // Espaçamento da etiqueta
                      child: FittedBox(
                        child: Text(
                          colorEtiqueta(data)['nome'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10.0,
                  ),
                  child: FittedBox(
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
            const Flexible(
              child: Divider(
                color: Colors.black,
              ),
            ),
            Expanded(
              flex: 2,
              child: FittedBox(
                child: Text(
                  "R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    fontFamily: 'Demi',
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0XFF2962ff),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: IconButton(
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    "Lista de compras feita na data ${converterData(dataCompra)}",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  content: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    height: MediaQuery.of(context)
                                        .size
                                        .width, // Defina uma altura apropriada
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(8),
                                      shrinkWrap: true,
                                      itemCount: listaProdutos.length,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ListTile(
                                              title: Text(
                                                listaProdutos[index]['nome'],
                                              ),
                                              subtitle: Text(
                                                "Quantidade: ${(double.parse(listaProdutos[index]['valor'].toString()) / double.parse(listaProdutos[index]['valorUnit'].toString())).toStringAsFixed(2).replaceAll('.', ',') == 'NaN' ? 0 : (double.parse(listaProdutos[index]['valor'].toString()) / double.parse(listaProdutos[index]['valorUnit'].toString())).toStringAsFixed(2).replaceAll('.', ',')} ",
                                              ),
                                              trailing: Text(
                                                'R\$ ${listaProdutos[index]['valor'].toStringAsFixed(2).replaceAll('.', ',')}',
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const Divider()
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.description_sharp,
                            color: Colors.white,
                          ),
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
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: IconButton(
                          onPressed: () async {
                            await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Endereço"),
                                    content: TextField(
                                      maxLines: null,
                                      controller:
                                          TextEditingController(text: endereco),
                                      readOnly: true,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Demi',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text("Cancelar")),
                                      ElevatedButton(
                                          onPressed: () async {
                                            await openGoogleMaps(
                                              endereco,
                                            );
                                            if (!context.mounted) return;
                                            Navigator.of(context).pop();
                                          },
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.place_outlined,
                                              ),
                                              Text("Navegar")
                                            ],
                                          ))
                                    ],
                                  );
                                });
                          },
                          icon: const Icon(
                            Icons.place,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: IconButton(
                          onPressed: () async {
                            await abrirWhatsApp(
                              numero,
                              nome,
                              valor,
                              listaProdutos,
                              dataCompra,
                            );
                          },
                          icon: const Icon(
                            Icons.message,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                          "R\$ ${dados.toStringAsFixed(2).replaceAll('.', ',')}",
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

  Future<void> fazerChamada(
    String numero,
  ) async {
    final urlChamada = 'tel:$numero';

    if (await canLaunchUrlString(urlChamada)) {
      await launchUrlString(urlChamada);
    } else {
      throw 'Não foi possível fazer a chamada.';
    }
  }

  Future<void> abrirWhatsApp(String numero, String nome, double valor, produtos,
      String dataCompra) async {
    String listProdutos = '';
    for (var contact in produtos) {
      listProdutos +=
          '- ${contact['nome']}, ${(double.parse(contact['valor'].toString()) / double.parse(contact['valorUnit'].toString())).toStringAsFixed(1)}x, R\$ ${double.parse(contact['valor'].toString()).toStringAsFixed(2).replaceAll('.', ',')}\n';
    }
    final mensagem =
        'Olá $nome, tudo bom? Apenas relembrando sobre a compra aqui no mercadinho no data de ${converterData(dataCompra)} no valor de R\$ ${valor.toStringAsFixed(2).replaceAll(".", ",")}.\n\n - *Lista de compras* -\n$listProdutos\n Aguardo o pagamento conforme combinado. Obrigado.';

    final urlWhatsApp =
        'https://api.whatsapp.com/send?phone=$numero&text=$mensagem';

    if (await canLaunchUrlString(urlWhatsApp)) {
      await launchUrlString(urlWhatsApp);
    } else {
      throw 'Não foi possível abrir o WhatsApp.';
    }
  }

  Future<void> openGoogleMaps(String address) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
    if (await canLaunchUrlString(googleMapsUrl)) {
      await launchUrlString(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  String converterData(
    String dataAmericana,
  ) {
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

  String converterDataBrasileira(
    String dataBrasileira,
  ) {
    // Divida a data brasileira em partes
    List<String> partes = dataBrasileira.split('/');

    // Verifique se há três partes (ano, mês, dia)
    if (partes.length == 3) {
      String dia = partes[0];
      String mes = partes[1];
      String ano = partes[2];

      // Formate a data no formato brasileiro (DIA/MÊS/ANO)
      return '$ano-$mes-$dia';
    }

    // Se a conversão falhar, retorne a data original
    return dataBrasileira;
  }

  Future<ProgressDialog> progressDialog(
    BuildContext context,
  ) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(
        message: 'Carregando...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: const FittedBox(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        ),
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

  Future<bool> showAlertDialogCadastrarFiado(
      BuildContext context, String email, double valor, List produto) async {
    bool verificacao = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
        TextEditingController nomeController = TextEditingController();
        TextEditingController telefoneController = TextEditingController();
        TextEditingController dataController = TextEditingController();
        TextEditingController controllerPlace = TextEditingController();
        TextEditingController dataCompraController = TextEditingController();

        final GlobalKey<FormState> formKey = GlobalKey<FormState>();

        return AlertDialog(
          title: const Text('Cadastrar Fiado'),
          content: Form(
            key: formKey,
            child: ListView(
              //keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: nomeController,
                  keyboardType: TextInputType.name,
                  //focusNode: focusNode,
                  decoration: const InputDecoration(
                      labelText: 'Nome', icon: Icon(Icons.abc)),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, insira o nome.';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: telefoneController,
                  maxLength: 11,
                  keyboardType: TextInputType.number,
                  //focusNode: focusNode,
                  decoration: const InputDecoration(
                    icon: Icon(
                      Icons.phone,
                    ),
                    labelText: 'Telefone',
                    prefixText: '+55 ',
                  ),
                  validator: (value) {
                    if (value!.isEmpty || value.length != 11) {
                      return 'Por favor, insira um número de telefone válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                GooglePlacesAutoCompleteTextFormField(
                  textEditingController: controllerPlace,
                  googleAPIKey: 'AIzaSyCOBgJqSi69QIjkxSQyV9lbK5Zir_c5z-0',
                  keyboardType: TextInputType.streetAddress,
                  predictionsStyle:
                      const TextStyle(fontWeight: FontWeight.bold),
                  inputDecoration: const InputDecoration(
                    icon: Icon(
                      Icons.maps_home_work,
                      size: 20,
                    ),
                    labelText: 'Endereço',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, digite um endereço!';
                    }
                    return null;
                  },
                  // proxyURL: _yourProxyURL, //
                  maxLines: 1,
                  overlayContainer: (child) => Material(
                    elevation: 1.0,
                    color: const Color.fromARGB(255, 115, 172, 238),
                    borderRadius: BorderRadius.circular(12),
                    child: child,
                  ),
                  getPlaceDetailWithLatLng: (prediction) {
                    print('placeDetails${prediction.lng}');
                  },
                  itmClick: (Prediction prediction) =>
                      controllerPlace.text = prediction.description!,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  readOnly: true,
                  onTap: () async {
                    final DateTime currentDate = DateTime.now();
                    final DateTime lastDate =
                        currentDate.add(const Duration(days: 5 * 365));
                    final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: lastDate);
                    final getDateController =
                        '${date!.day.toString().length < 2 ? '0${date.day.toString()}' : date.day.toString()}/${date.month.toString().length < 2 ? '0${date.month.toString()}' : date.month.toString()}/${date.year}';

                    dataCompraController.text = getDateController;
                  },
                  controller: dataCompraController,
                  decoration: const InputDecoration(
                      labelText: 'Data da compra (dd/MM/yyyy)',
                      icon: Icon(
                        Icons.date_range_rounded,
                      )),
                  keyboardType: TextInputType.datetime,
                  //focusNode: focusNode,
                  validator: (value) {
                    try {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }

                      dateFormat
                          .parseStrict(value); // Tenta fazer o parse da data
                      return null; // A data é válida
                    } catch (e) {
                      return 'Data inválida';
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  readOnly: true,
                  onTap: () async {
                    final DateTime currentDate = DateTime.now();
                    final DateTime lastDate =
                        currentDate.add(const Duration(days: 5 * 365));
                    final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: lastDate);
                    final getDateController =
                        '${date!.day.toString().length < 2 ? '0${date.day.toString()}' : date.day.toString()}/${date.month.toString().length < 2 ? '0${date.month.toString()}' : date.month.toString()}/${date.year}';

                    dataController.text = getDateController;
                  },
                  controller: dataController,
                  decoration: const InputDecoration(
                      labelText: 'Data a pagar (dd/MM/yyyy)',
                      icon: Icon(
                        Icons.date_range_rounded,
                      )),
                  keyboardType: TextInputType.datetime,
                  //focusNode: focusNode,
                  validator: (value) {
                    try {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }

                      dateFormat
                          .parseStrict(value); // Tenta fazer o parse da data
                      return null; // A data é válida
                    } catch (e) {
                      return 'Data inválida';
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                verificacao = false;
                Navigator.of(context).pop(); // Fecha o AlertDialog
              },
            ),
            TextButton(
              child: const Text('Cadastrar'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // Validação passou, faça algo com os dados
                  String nome = nomeController.text;
                  String telefone = '+55${telefoneController.text}';
                  String endereco = controllerPlace.text;
                  String data = converterDataBrasileira(dataController.text);
                  String dataCompra =
                      converterDataBrasileira(dataCompraController.text);

                  // Faça algo com os dados, por exemplo, adicione-os ao Firestore
                  // Lembre-se de adicionar a lógica de validação e armazenamento dos dados aqui
                  await BancoDadosFirebase().cadastrarFiado(
                    context,
                    email.toString(),
                    nome,
                    valor,
                    telefone,
                    data,
                    produto,
                    endereco,
                    dataCompra,
                  );
                  verificacao = true;
                  if (!context.mounted) return;
                  Navigator.of(context).pop(); // Fecha o AlertDialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fiado cadastrado'),
                      duration: Duration(seconds: 2), // Duração da snackbar
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
    return verificacao;
  }
}
