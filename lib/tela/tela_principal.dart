import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:genmerc_mobile/auth_services/login_provider.dart';
import 'package:genmerc_mobile/firebase/banco_dados.dart';
import 'package:genmerc_mobile/funcion/button_scan.dart';
import 'package:genmerc_mobile/funcion/logic_button.dart';
import 'package:genmerc_mobile/tela/fiado.dart';
import 'package:genmerc_mobile/tela/gestao_produtos.dart';
import 'package:genmerc_mobile/tela/login.dart';
import 'package:genmerc_mobile/tela/vendas.dart';
import 'package:genmerc_mobile/widgetPadrao/padrao.dart';
import 'package:provider/provider.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  Logicbutton logicbutton = Logicbutton();
  BancoDadosFirebase bdFirebase = BancoDadosFirebase();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> allDocuments = [];
  List<QueryDocumentSnapshot> filteredDocuments = [];
  double subtotal = 0.0;
  List listaProdutos = [];
  BuildContext? contextDialog;
  bool verAttFotoNome = true;
  List<Widget> listCard = [];
  final player = AudioPlayer();

  Widget _cardPersonalite(
    Key key,
    int index,
    String nome,
    double valorUnit,
    String image,
    double quantidade,
  ) {
    double valorFinal = double.parse(
      (quantidade * valorUnit).toStringAsFixed(2),
    );
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
          listaProdutos.removeWhere((item) => item['key'] == key);
          if (subtotal > 0) {
            subtotal -= valorFinal;
            if (subtotal < 0) {
              subtotal = 0.0;
            }
          } else {
            subtotal = 0.0;
          }
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
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
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
                              listCard[widgetIndex] = _cardPersonalite(key,
                                  index, nome, valorUnit, image, parsedNumber!);
                              listaProdutos[widgetIndex] = {
                                'nome': nome,
                                'valor': double.parse(
                                  (parsedNumber * valorUnit).toStringAsFixed(2),
                                ),
                                'valorUnit': valorUnit,
                                'key': key
                              };
                            });
                          }
                        }
                        // Faça algo com o número (por exemplo, armazená-lo em algum lugar)

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
                      child: CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const FittedBox(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            CachedNetworkImage(
                          imageUrl:
                              'https://firebasestorage.googleapis.com/v0/b/genmerc-mobile.appspot.com/o/Administrativo%2Fdairy.png?alt=media&token=7c2c92df-11c2-402d-9f63-d6933f213a64&_gl=1*1ajv9ft*_ga*MTQ3OTA0NDM3Ny4xNjk2ODU0MzAx*_ga_CW55HF8NVT*MTY5NzU3MDExOC45NC4xLjE2OTc1NzI0MjEuMzEuMC4w',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const FittedBox(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.photo_library_outlined,
                            size:
                                48, // Defina o tamanho do ícone conforme necessário
                          ),
                        ),
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
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                nome.toUpperCase(),
                                softWrap: false,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Color.fromARGB(255, 107, 107, 107)),
                              ),
                            ),
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
                                    '$quantidade x R\$ ${valorUnit.toStringAsFixed(2).replaceAll('.', ',')} Un.',
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
                                      'R\$: ${valorFinal.toStringAsFixed(2).replaceAll('.', ',')}',
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

  Future<void> _addForSeach(String nome, valorUnit, String image) async {
    final keyGlobal = GlobalKey();
    listaProdutos.add({
      'nome': nome,
      'valor': double.parse(valorUnit.toString()),
      'valorUnit': double.parse(valorUnit.toString()),
      'key': keyGlobal
    });
    setState(() {
      listCard.add(
        _cardPersonalite(
          keyGlobal,
          listCard.length,
          nome,
          double.parse(valorUnit.toString()),
          image,
          1,
        ),
      );
    });
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 10);
    }
  }

  Future<void> _scanBarcodeNormal(String email, context) async {
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
          _addForSeach(resul['nome'], resul['valorUnit'], resul['image']);

          //_showSnackBar(context);
          await _scanBarcodeNormal(email, context);
        }
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  Future<void> _loadDocuments(String email) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(email)
        .collection('bancodados')
        .get();
    setState(() {
      allDocuments = querySnapshot.docs;
      filteredDocuments = allDocuments;
    });
  }

  void _filterDocuments(String query) {
    filteredDocuments = allDocuments.where((document) {
      final title = document['nome'] as String;
      return title.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<void> _logicBUTTONContinuar(
    contextFinal,
    String email,
  ) async {
    if (listCard.isNotEmpty && subtotal > 0) {
      await showDialog(
        context: contextFinal,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Selecione uma opção:'),
            content: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: ElevatedButton(
                    style: const ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll(Colors.white),
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.orangeAccent),
                    ),
                    onPressed: () async {
                      // Ação ao pressionar "Fiado"
                      try {
                        for (var element in listaProdutos) {
                          Map removeMap = element;
                          removeMap.remove('key');

                          int index = listaProdutos.indexOf(element);
                          listaProdutos[index] = removeMap;
                          //listaProdutos[index];
                        }
                        bool verificacao = await MyWidgetPadrao()
                            .showAlertDialogCadastrarFiado(
                          context,
                          email,
                          subtotal,
                          listaProdutos,
                        );
                        if (verificacao) {
                          setState(() {
                            listCard.clear();
                            subtotal = 0.0;
                            listaProdutos.clear();
                          });
                        }
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      } catch (e) {
                        MyWidgetPadrao.showErrorDialog(context);
                      }

                      // Fechar o diálogo
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined),
                        SizedBox(
                          width: 2,
                        ),
                        FittedBox(child: Text('Fiado')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Flexible(
                  child: ElevatedButton(
                    style: const ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll(Colors.white),
                      backgroundColor: MaterialStatePropertyAll(
                        Colors.green,
                      ),
                    ),
                    onPressed: () async {
                      // Ação ao pressionar "Finalizar"
                      DateTime now = DateTime.now();
                      try {
                        if (subtotal > 0) {
                          final ano = now.year;
                          final mes = now.month;
                          final dia = now.day < 10 ? "0${now.day}" : now.day;

                          DocumentReference<Map<String, dynamic>>
                              documentReference = FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(
                                    email,
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
                            double valorSomaindex =
                                double.parse(valorSoma!["valor"].toString());
                            double valorSomaFinal = valorSomaindex + subtotal;

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
                            listaProdutos.clear();
                          });
                          await player.play(
                            AssetSource(
                              'Caixa_Registradora.mp3',
                            ),
                          );
                          ScaffoldMessenger.of(contextFinal).showSnackBar(
                            const SnackBar(
                              content: Text('Compra finalizada'),
                              duration:
                                  Duration(seconds: 2), // Duração da snackbar
                            ),
                          );
                        }
                      } catch (e) {
                        MyWidgetPadrao.showErrorDialog(contextFinal);
                      }
                      if (!context.mounted) return;
                      Navigator.of(context).pop(); // Fechar o diálogo
                    },
                    child: const Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Icon(Icons.store_mall_directory_rounded),
                        ),
                        Flexible(
                          flex: 1,
                          child: SizedBox(
                            width: 5,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: FittedBox(
                            child: Text('Finalizar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> _logicBUTTONSearchPrincipal(
    context,
    String email,
  ) async {
    try {
      await _loadDocuments(
        email,
      );

      TextEditingController controllerSeach = TextEditingController();
      await showDialog(
        context: contextDialog!,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (
              BuildContext context,
              StateSetter setState,
            ) {
              return AlertDialog(
                elevation: 10,
                title: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(25.0), // Borda arredondada
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: controllerSeach,
                    onChanged: (value) {
                      setState(() {
                        _filterDocuments(value);
                      });
                    },
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Pesquisar...',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none, // Remove a borda padrão
                      contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ),
                ),
                content: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Número de colunas
                    mainAxisSpacing: 8.0, // Espaçamento vertical entre os cards
                    crossAxisSpacing:
                        8.0, // Espaçamento horizontal entre os cards
                    childAspectRatio:
                        1.0, // Relação de aspecto para tornar os cards quadrados
                  ),
                  itemCount: filteredDocuments.length,
                  itemBuilder: (context, index) {
                    final document = filteredDocuments[index];
                    //final documentID =
                    //filteredDocuments[index].id;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Card(
                            //surfaceTintColor: Colors.yellow,
                            elevation: 10,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: document['image'],
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const FittedBox(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: FittedBox(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, error, stackTrace) {
                                      return CachedNetworkImage(
                                        imageUrl:
                                            'https://firebasestorage.googleapis.com/v0/b/genmerc-mobile.appspot.com/o/Administrativo%2Fdairy.png?alt=media&token=7c2c92df-11c2-402d-9f63-d6933f213a64&_gl=1*1ajv9ft*_ga*MTQ3OTA0NDM3Ny4xNjk2ODU0MzAx*_ga_CW55HF8NVT*MTY5NzU3MDExOC45NC4xLjE2OTc1NzI0MjEuMzEuMC4w',
                                        fit: BoxFit.contain,
                                        placeholder: (context, url) =>
                                            const FittedBox(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorWidget:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                          Icons.photo_library_outlined,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: InkWell(
                                    onTap: () {
                                      _addForSeach(
                                        document['nome'],
                                        document['valorUnit'],
                                        document['image'],
                                      );
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      decoration: const BoxDecoration(
                                        color: Color(0xff33b17c),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                            100,
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          left: 5,
                                        ),
                                        child: Column(
                                          children: [
                                            const Expanded(
                                              child: Icon(
                                                Icons.add,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Expanded(
                                              child: FittedBox(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 2,
                                                    right: 4,
                                                  ),
                                                  child: Text(
                                                    'R\$ ${double.parse(
                                                      document['valorUnit']
                                                          .toString(),
                                                    ).toStringAsFixed(
                                                          2,
                                                        ).replaceAll('.', ',')}',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Demi',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 8.0,
                              ),
                              child: Text(
                                document['nome'].toString().toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Demi',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("OK"))
                ],
              );
            },
          );
        },
      );
    } catch (erro) {
      MyWidgetPadrao.showErrorDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    contextDialog = context;
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user == null) {
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
    }
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 237, 240),
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 100,
        shadowColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 29, 128, 214),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage(
                "assets/ideogram.jpeg",
              ), // Substitua pelo caminho da sua imagem
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(
                  0.15,
                ), // Ajuste a opacidade aqui
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
                return const FittedBox(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                ); // Mostrar um indicador de carregamento enquanto os dados estão sendo buscados.
              } else if (snapshot.hasError) {
                return const Text(
                  "Erro",
                );
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
              return const FittedBox(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              ); // Mostrar um indicador de carregamento enquanto os dados estão sendo buscados.
            } else if (snapshot.hasError) {
              return const Text("Erro");
            } else {
              verAttFotoNome = false;
              return Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(dados!['foto']),
                  ),
                ),
              );
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await logicbutton.logicButtonLogoff(
                authProvider,
                context,
              );
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
            if (listCard.isNotEmpty)
              Align(
                alignment: Alignment.topCenter,
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        listCard.clear();
                        listaProdutos.clear();
                        subtotal = 0.0;
                      });
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delete_sweep_rounded,
                          color: Colors.red,
                        ),
                        Text(
                          "Limpar tudo",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    )),
              ),
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
                                  'R\$: ${subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
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
                            await _logicBUTTONContinuar(
                              context,
                              authProvider.user!.email.toString(),
                            );
                          },
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.green),
                          ),
                          child: const Text(
                            'Continuar',
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
              await _scanBarcodeNormal(
                authProvider.user!.email.toString(),
                context,
              );
            } catch (e) {
              // ignore: use_build_context_synchronously
              await MyWidgetPadrao.showErrorDialog(context);
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              100.0,
            ), // Valor alto para tornar o botão redondo
          ), // Ícone do botão
          backgroundColor:
              const Color.fromARGB(255, 206, 25, 64), // Cor de fundo do botão
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
          color: const Color.fromARGB(255, 29, 128, 214),
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
                  FittedBox(
                    child: IconButton(
                      onPressed: () async {
                        await _logicBUTTONSearchPrincipal(
                          context,
                          authProvider.user!.email.toString(),
                        );
                      },
                      icon: const Icon(Icons.search),
                      color: Colors.white,
                      iconSize: 30,
                    ),
                  ),
                  FittedBox(
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GestaoProdutos(
                              email: authProvider.user!.email.toString(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.storage),
                      color: Colors.white,
                      iconSize: 30,
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Fiado(
                              email: authProvider.user!.email.toString(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.account_balance_wallet_outlined,
                      ),
                      color: Colors.white,
                      iconSize: 30,
                    ),
                  ),
                  FittedBox(
                    child: IconButton(
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Vendas(
                              email: authProvider.user!.email.toString(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.store_mall_directory_rounded,
                      ),
                      color: Colors.white,
                      iconSize: 30,
                    ),
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
