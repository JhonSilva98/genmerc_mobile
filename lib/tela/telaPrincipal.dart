import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:genmerc_mobile/auth_services/loginProvider.dart';
import 'package:genmerc_mobile/firebase/bancoDados.dart';
import 'package:genmerc_mobile/funcion/buttonScan.dart';
import 'package:genmerc_mobile/tela/login.dart';
import 'package:genmerc_mobile/tela/vendas.dart';
import 'package:genmerc_mobile/widgetPadrao/padrao.dart';
import 'package:provider/provider.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:audioplayers/audioplayers.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  BancoDadosFirebase bdFirebase = BancoDadosFirebase();
  double subtotal = 0.0;

  Widget cardPersonalite(Key key, int index, String nome, double valorUnit,
      String image, double quantidade) {
    double valorFinal = quantidade * valorUnit;
    subtotal += valorFinal;
    return Dismissible(
      key: key,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          listCard.removeWhere((item) => item.key == key);
          subtotal -= valorUnit;
        });
      },
      child: InkWell(
        onLongPress: () async {
          TextEditingController numberController = TextEditingController();

          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Altere a quantidade'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: numberController,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^[\d,]+(\.\d{0,2})?$'),
                        ),
                      ],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                          labelText: 'Altere a quantidade do produto:',
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white, // Cor da borda branca
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(50.0),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors
                                  .white, // Cor da borda branca quando focado
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                          hintStyle: MyWidgetPadrao.myBeautifulTextStyle),
                      validator: (value) {
                        if (value == null || value.toString() == '') {
                          return 'Por favor, insira uma quantidade';
                        }
                        // Você também pode adicionar validações personalizadas aqui, se necessário.
                        return null;
                      },
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Fechar o AlertDialog
                    },
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Aqui você pode acessar o valor do TextFormField:
                      numberController.text =
                          numberController.text.replaceAll(',', '.');
                      final double? parsedNumber =
                          double.tryParse(numberController.text);
                      if (numberController.text.isNotEmpty) {
                        subtotal -= valorFinal;
                        final widgetIndex =
                            listCard.indexWhere((widget) => widget.key == key);

                        if (widgetIndex != -1) {
                          // Substitua o widget com outro widget
                          setState(() {
                            listCard[widgetIndex] = cardPersonalite2(key, index,
                                nome, valorUnit, image, parsedNumber!);
                          });
                        }
                      }
                      // Faça algo com o número (por exemplo, armazená-lo em algum lugar)
                      print('Número inserido: $parsedNumber');

                      Navigator.of(context).pop(); // Fechar o AlertDialog
                    },
                    child: const Text('Adicionar'),
                  ),
                ],
              );
            },
          );
        },
        child: Card(
          elevation: 5,
          child: SizedBox(
            height: 100.0,
            child: Row(
              children: <Widget>[
                Container(
                  height: 100.0,
                  width: 70.0,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                        topLeft: Radius.circular(5)),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        image == ""
                            ? "https://ciclovivo.com.br/wp-content/uploads/2018/10/iStock-536613027-1024x683.jpg"
                            : image,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 2, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '$index - $nome',
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                          child: Container(
                            width: 30,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.teal),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            child: const Text(
                              "3D",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 2),
                          child: SizedBox(
                            width: 260,
                            child: Text(
                              '${quantidade}x $valorUnit',
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 48, 48, 54)),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget cardPersonalite2(Key key, int index, String nome, double valorUnit,
      String image, double quantidade) {
    double valorFinal = quantidade * valorUnit;
    subtotal += valorFinal;
    return Dismissible(
      key: key,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          listCard.removeWhere((item) => item.key == key);
          subtotal -= valorFinal;
        });
      },
      child: SizedBox(
        height: 100,
        width: double.infinity,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          splashColor: const Color.fromARGB(255, 160, 194, 224),
          onLongPress: () async {
            TextEditingController numberController = TextEditingController();
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Altere a quantidade'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: numberController,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^[\d,]+(\.\d{0,2})?$'),
                          ),
                        ],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                            labelText: 'Altere a quantidade do produto:',
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white, // Cor da borda branca
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(50.0),
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors
                                    .white, // Cor da borda branca quando focado
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                            ),
                            hintStyle: MyWidgetPadrao.myBeautifulTextStyle),
                        validator: (value) {
                          if (value == null || value.toString() == '') {
                            return 'Por favor, insira uma quantidade';
                          }
                          // Você também pode adicionar validações personalizadas aqui, se necessário.
                          return null;
                        },
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Fechar o AlertDialog
                      },
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Aqui você pode acessar o valor do TextFormField:
                        numberController.text =
                            numberController.text.replaceAll(',', '.');
                        final double? parsedNumber =
                            double.tryParse(numberController.text);
                        if (numberController.text.isNotEmpty) {
                          subtotal -= valorFinal;
                          final widgetIndex = listCard
                              .indexWhere((widget) => widget.key == key);

                          if (widgetIndex != -1) {
                            // Substitua o widget com outro widget
                            setState(() {
                              listCard[widgetIndex] = cardPersonalite2(key,
                                  index, nome, valorUnit, image, parsedNumber!);
                            });
                          }
                        }
                        // Faça algo com o número (por exemplo, armazená-lo em algum lugar)
                        print('Número inserido: $parsedNumber');

                        Navigator.of(context).pop(); // Fechar o AlertDialog
                      },
                      child: const Text('Adicionar'),
                    ),
                  ],
                );
              },
            );
          },
          child: Card(
            elevation: 8,
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Flexible(
                  flex: 1,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      child: Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.photo_library_outlined);
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Flex(
                    direction: Axis.vertical,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                          ),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              Text(
                                nome,
                                softWrap: false,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                    color: Color.fromARGB(255, 107, 107, 107)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            right: 8,
                            bottom: 8,
                          ),
                          child: Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    '$quantidade x R\$ ${valorUnit.toString().replaceAll('.', ',')} Un.',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Container(
                                    width: 100,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.teal),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Text(
                                      'R\$: ${valorFinal.toString().replaceAll('.', ',')}',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool verAttFotoNome = true;
  List<Widget> listCard = [];
  final player = AudioPlayer();

  Future<void> scanBarcodeNormal(String email, context) async {
    String barcodeScanRes;
    //ButtonScan funcion = ButtonScan(email: email, context: context);
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      if (barcodeScanRes != '-1') {
        await player.play(AssetSource('beep-07a.mp3'));
        final resul = await ButtonScan(email: email, context: context)
            .executarFuncaoBarcode(barcodeScanRes);
        if (resul.isNotEmpty || resul['nome'] != 'error') {
          setState(() {
            listCard.add(
              cardPersonalite2(GlobalKey(), listCard.length, resul['nome'],
                  resul['valorUnit'], resul['image'], 1),
            );
          });
          //_showSnackBar(context);
          await scanBarcodeNormal(email, context);
        }
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
      print('Failed to get platform version.');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user == null) {
      try {
        if (authProvider.user == null) {
          // O usuário não está autenticado, então você pode redirecioná-lo para a tela de login ou outro lugar.
          // Por exemplo:
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
              (Route<dynamic> route) => false,
            );
          });
        }
      } catch (e) {
        print("Exceção ao redirecionar para a tela de login: $e");
      }
    }
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 237, 240),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 160, 194, 224),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage(
                "assets/ideogram.jpeg",
              ), // Substitua pelo caminho da sua imagem
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.15), // Ajuste a opacidade aqui
                BlendMode
                    .dstATop, // Define o modo de mesclagem para mesclar com a cor de fundo
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        title: Center(
          child: FutureBuilder(
            future: verAttFotoNome == true
                ? bdFirebase.getNomeFoto(authProvider.user!.email.toString())
                : null,
            builder: (context, snapshot) {
              Map<String, dynamic>? dados = snapshot.data;
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Mostrar um indicador de carregamento enquanto os dados estão sendo buscados.
              } else if (snapshot.hasError) {
                return const Text("Erro");
              } else {
                verAttFotoNome = false;
                return Center(
                  child: Flex(
                    direction: Axis.vertical,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          // Texto com bordas brancas simuladas
                          Text(
                            "GENMERC",
                            style: TextStyle(
                              fontSize: 32.0,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2.0
                                ..color = Colors.black,
                            ),
                          ),
                          // Texto com a cor do texto
                          const Text(
                            "GENMERC",
                            style: TextStyle(
                                fontSize: 32.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold // Cor do texto
                                ),
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          // Texto com bordas brancas simuladas
                          Text(
                            dados!['nome'],
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2.0
                                ..color = Colors.white,
                            ),
                          ),
                          // Texto com a cor do texto
                          Text(
                            dados['nome'],
                            style: const TextStyle(
                                fontSize: 15.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold // Cor do texto
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      )
                    ],
                  ),
                );
              }
            },
          ),
        ),
        leading: FutureBuilder(
          future: verAttFotoNome == true
              ? bdFirebase.getNomeFoto(authProvider.user!.email.toString())
              : null,
          builder: (context, snapshot) {
            Map<String, dynamic>? dados = snapshot.data;
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Mostrar um indicador de carregamento enquanto os dados estão sendo buscados.
            } else if (snapshot.hasError) {
              return const Text("Erro");
            } else {
              verAttFotoNome = false;
              return Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(dados!['foto']),
                ),
              );
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await authProvider.signOut();
              } catch (e) {
                await MyWidgetPadrao.showErrorDialog(context);
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TelaPrincipal()),
                    (Route<dynamic> route) => false,
                  );
                });
              }
            },
            tooltip: 'Sair',
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: ListView.builder(
                  itemCount: listCard.length, // Número de itens na lista
                  itemBuilder: (BuildContext context, int index) {
                    // Crie um widget para cada item na lista.
                    return listCard[index];
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Divider(
                    height: 10,
                  ),
                  Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width / 3,
                          child: Card(
                            shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  color: Colors.teal,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                                child: FittedBox(
                              fit: BoxFit.cover,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'R\$: ${subtotal.toString().replaceAll('.', ',')}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Colors.green),
                                ),
                              ),
                            )),
                          ),
                        ),
                      ),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () async {
                            DateTime now = DateTime.now();
                            try {
                              if (subtotal > 0) {
                                final ano = now.year;
                                final mes = now.month;
                                final dia = now.day;
                                /*final hora =
                                    '${now.hour}-${now.minute}-${now.second}';
                                final data = now.toLocal();*/
                                DocumentReference<Map<String, dynamic>>
                                    documentReference =
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(
                                          authProvider.user!.email.toString(),
                                        )
                                        .collection("vendas")
                                        .doc("$ano")
                                        .collection("mes")
                                        .doc("$mes")
                                        .collection("dia")
                                        .doc("$dia");
                                final DocumentSnapshot<Map<String, dynamic>>
                                    snapshot = await documentReference.get();
                                if (snapshot.exists) {
                                  final valorSoma = snapshot.data();
                                  double valorSomaindex = double.parse(
                                      valorSoma!["valor"].toString());
                                  double valorSomaFinal =
                                      valorSomaindex + subtotal;
                                  print("o valor é $valorSomaFinal");
                                  await documentReference.set({
                                    "valor": valorSomaFinal,
                                  });
                                } else {
                                  await documentReference.set({
                                    "valor": subtotal,
                                  });
                                }
                                setState(() {
                                  listCard.clear();
                                  subtotal = 0.0;
                                });
                              }
                            } catch (e) {
                              MyWidgetPadrao.showErrorDialog(context);
                            }
                          },
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.green),
                          ),
                          child: const Text(
                            'Finalizar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 100.0, // Defina a largura desejada
        height: 100.0,
        child: FloatingActionButton(
          onPressed: () async {
            try {
              await scanBarcodeNormal(
                  authProvider.user!.email.toString(), context);
            } catch (e) {
              // ignore: use_build_context_synchronously
              await MyWidgetPadrao.showErrorDialog(context);
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                100.0), // Valor alto para tornar o botão redondo
          ), // Ícone do botão
          backgroundColor:
              const Color.fromARGB(255, 98, 156, 206), // Cor de fundo do botão
          elevation: 4.0,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.barcode_reader,
                color: Colors.white,
                size: 30,
              ),
              Icon(
                Icons.qr_code,
                color: Colors.white,
                size: 30,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 70,
        child: BottomAppBar(
          color: const Color.fromARGB(255, 160, 194, 224),
          shape: const CircularNotchedRectangle(),
          clipBehavior: Clip.antiAlias,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                    color: Colors.white,
                    iconSize: 30,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.storage),
                    color: Colors.white,
                    iconSize: 30,
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.account_balance_wallet_outlined),
                    color: Colors.white,
                    iconSize: 30,
                  ),
                  IconButton(
                    onPressed: () async {
                      //await subCollection2.add(dataSubCollectionEmpresa);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Vendas(
                            email: authProvider.user!.email.toString(),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.store_mall_directory_rounded),
                    color: Colors.white,
                    iconSize: 30,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
