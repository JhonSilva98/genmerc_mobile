import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:genmerc_mobile/api/seach_images.dart';
import 'package:genmerc_mobile/firebase/banco_dados.dart';
import 'package:genmerc_mobile/funcion/button_scan.dart';
import 'package:genmerc_mobile/widgetPadrao/padrao.dart';

class GestaoProdutos extends StatefulWidget {
  final String email;
  const GestaoProdutos({
    super.key,
    required this.email,
  });

  @override
  State<GestaoProdutos> createState() => _GestaoProdutosState();
}

class _GestaoProdutosState extends State<GestaoProdutos> {
  BuildContext? contextPrincipal;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> allDocuments = [];
  List<QueryDocumentSnapshot> filteredDocuments = [];
  BancoDadosFirebase imagePicker = BancoDadosFirebase();
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  void _loadDocuments() async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(widget.email)
        .collection('bancodados')
        .get();
    setState(() {
      allDocuments = querySnapshot.docs;
      filteredDocuments = allDocuments;
    });
  }

  void _filterDocuments(String query) {
    setState(() {
      filteredDocuments = allDocuments.where((document) {
        final title = document['nome'] as String;
        return title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> scanBarcodeNormal(String email, context) async {
    String barcodeScanRes;
    //ButtonScan funcion = ButtonScan(email: email, context: context);
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancelar', true, ScanMode.BARCODE);
      if (barcodeScanRes != '-1') {
        await player.play(AssetSource('beep-07a.mp3'));
        final resul = await ButtonScan(email: email, context: context)
            .executarFuncaoBarcode(barcodeScanRes);
        if (resul.isNotEmpty || resul['nome'] != 'error') {
          _loadDocuments();
          //_showSnackBar(context);
          await scanBarcodeNormal(email, context);
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

  @override
  Widget build(BuildContext context) {
    contextPrincipal = context;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: _filterDocuments,
          decoration: const InputDecoration(
            hintText: 'Pesquisar...',
          ),
        ),
      ),
      body: GridView.builder(
        itemCount: filteredDocuments.length,
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          final document = filteredDocuments[index];
          final documentID = filteredDocuments[index].id;
          return InkWell(
            borderRadius: BorderRadius.circular(10),
            splashColor: Colors.redAccent,
            onLongPress: () async {
              await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Apagar'),
                      content: const Text("Você deseja apagar esse dado?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Fechar o dialog
                          },
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.red)),
                          onPressed: () async {
                            // Implemente a lógica de alterar o nome aqui

                            await BancoDadosFirebase().deleteImageBD(
                              document['image'],
                            );
                            try {
                              await _firestore
                                  .collection('users')
                                  .doc(widget.email)
                                  .collection('bancodados')
                                  .doc(documentID)
                                  .delete();
                              _loadDocuments();
                            } catch (e) {
                              MyWidgetPadrao.showErrorDialog(context);
                            }

                            // Faça algo com o novo nome
                            Navigator.of(context).pop(); // Fechar o dialog
                          },
                          child: const Text(
                            'Apagar',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  });
            },
            child: Card(
              elevation: 5,
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ), // Define o raio da borda
                          child: Image.network(
                            document['image'],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                'https://firebasestorage.googleapis.com/v0/b/genmerc-mobile.appspot.com/o/Administrativo%2Fdairy.png?alt=media&token=7c2c92df-11c2-402d-9f63-d6933f213a64&_gl=1*1ajv9ft*_ga*MTQ3OTA0NDM3Ny4xNjk2ODU0MzAx*_ga_CW55HF8NVT*MTY5NzU3MDExOC45NC4xLjE2OTc1NzI0MjEuMzEuMC4w',
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.photo_library_outlined,
                                ),
                              );
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            onPressed: () async {
                              await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Escolher uma Imagem'),
                                      content: Flex(
                                        direction: Axis.horizontal,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Flexible(
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                // Lógica para selecionar uma imagem da galeria
                                                try {
                                                  await imagePicker
                                                      .getImageFromGallery(
                                                          widget.email);
                                                  String newImage =
                                                      imagePicker.imageUrl;
                                                  if (newImage != '') {
                                                    final progressDialogFinal =
                                                        await MyWidgetPadrao()
                                                            .progressDialog(
                                                                context);
                                                    await progressDialogFinal
                                                        .show();
                                                    await imagePicker
                                                        .deleteImageBD(
                                                      document['image'],
                                                    );

                                                    await _firestore
                                                        .collection('users')
                                                        .doc(widget.email)
                                                        .collection(
                                                            'bancodados')
                                                        .doc(documentID)
                                                        .update(
                                                      {'image': newImage},
                                                    );
                                                    _loadDocuments();
                                                    progressDialogFinal.hide();
                                                  }
                                                  imagePicker.imageUrl = '';
                                                } catch (e) {
                                                  AlertDialog(
                                                    title: const Text('Erro'),
                                                    content: const Text(
                                                        'Erro ao acessar banco de dados'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(); // Fechar o dialog
                                                        },
                                                        child: const Text('Ok'),
                                                      ),
                                                    ],
                                                  );
                                                }
                                                if (!context.mounted) return;
                                                Navigator.of(context)
                                                    .pop(); // Fechar o dialog
                                              },
                                              child: const Flex(
                                                direction: Axis.horizontal,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Flexible(
                                                    flex: 1,
                                                    child: FittedBox(
                                                      child: Icon(
                                                        Icons.photo,
                                                      ),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    flex: 3,
                                                    child: FittedBox(
                                                      child: Text('Galeria',
                                                          softWrap: false),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Flexible(
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                // Lógica para capturar uma imagem da câmera
                                                try {
                                                  await imagePicker
                                                      .getImageFromCamera(
                                                          widget.email);
                                                  String newImage =
                                                      imagePicker.imageUrl;
                                                  if (newImage != '') {
                                                    final progressDialogFinal =
                                                        await MyWidgetPadrao()
                                                            .progressDialog(
                                                                context);
                                                    await progressDialogFinal
                                                        .show();
                                                    await _firestore
                                                        .collection('users')
                                                        .doc(widget.email)
                                                        .collection(
                                                            'bancodados')
                                                        .doc(documentID)
                                                        .update(
                                                      {'image': newImage},
                                                    );
                                                    _loadDocuments();
                                                    progressDialogFinal.hide();
                                                  }
                                                  imagePicker.imageUrl = '';
                                                } catch (e) {
                                                  AlertDialog(
                                                    title: const Text('Erro'),
                                                    content: const Text(
                                                        'Erro ao acessar banco de dados'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(); // Fechar o dialog
                                                        },
                                                        child: const Text('Ok'),
                                                      ),
                                                    ],
                                                  );
                                                }
                                                if (!context.mounted) return;
                                                Navigator.of(context)
                                                    .pop(); // Fechar o dialog
                                              },
                                              child: const Flex(
                                                direction: Axis.horizontal,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Flexible(
                                                    flex: 1,
                                                    child: FittedBox(
                                                      child: Icon(Icons
                                                          .camera_alt_rounded),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    flex: 3,
                                                    child: FittedBox(
                                                      child: Text('Câmera',
                                                          softWrap: false),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Fechar o dialog
                                          },
                                          child: const Text('Cancelar'),
                                        ),
                                      ],
                                    );
                                  });
                            },
                            icon: const Icon(
                              Icons.edit_square,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(2, 2),
                                  blurRadius: 5,
                                ),
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(-2, 2),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      document['nome'].toString().toUpperCase(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      softWrap: false,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    onPressed: () async {
                                      final TextEditingController
                                          nameController =
                                          TextEditingController(
                                        text: document['nome']
                                            .toString()
                                            .toUpperCase(),
                                      );

                                      await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Alterar Nome'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  TextFormField(
                                                    controller: nameController,
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText: 'Nome',
                                                      border:
                                                          OutlineInputBorder(),
                                                      prefixIcon: Icon(
                                                        Icons.abc,
                                                      ),
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 16.0,
                                                    ),
                                                    keyboardType:
                                                        TextInputType.text,
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .words,
                                                    validator: (value) {
                                                      if (value!.isEmpty) {
                                                        return 'Por favor, insira um nome válido.';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ],
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Fechar o dialog
                                                  },
                                                  child: const Text('Cancelar'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    // Implemente a lógica de alterar o nome aqui
                                                    String newName =
                                                        nameController.text;
                                                    try {
                                                      await _firestore
                                                          .collection('users')
                                                          .doc(widget.email)
                                                          .collection(
                                                              'bancodados')
                                                          .doc(documentID)
                                                          .update(
                                                        {'nome': newName},
                                                      );
                                                      _loadDocuments();
                                                    } catch (e) {
                                                      AlertDialog(
                                                        title:
                                                            const Text('Erro'),
                                                        content: const Text(
                                                            'Erro ao acessar banco de dados'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(); // Fechar o dialog
                                                            },
                                                            child: const Text(
                                                                'Ok'),
                                                          ),
                                                        ],
                                                      );
                                                    }

                                                    // Faça algo com o novo nome
                                                    Navigator.of(context)
                                                        .pop(); // Fechar o dialog
                                                  },
                                                  child: const Text('Alterar'),
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                    icon: const Icon(
                                      Icons.edit_square,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black,
                                          offset: Offset(2, 2),
                                          blurRadius: 5,
                                        ),
                                        Shadow(
                                          color: Colors.black,
                                          offset: Offset(-2, 2),
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 2,
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'R\$ ${document['valorUnit'].toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final TextEditingController
                                        numberController =
                                        TextEditingController(
                                      text: document['valorUnit']
                                          .toStringAsFixed(2)
                                          .replaceAll('.', ','),
                                    );

                                    await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Alterar Valor'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                TextFormField(
                                                  controller: numberController,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Valor',
                                                    border:
                                                        OutlineInputBorder(),
                                                    prefixIcon: Icon(
                                                        Icons.attach_money),
                                                  ),
                                                  keyboardType:
                                                      const TextInputType
                                                          .numberWithOptions(
                                                          decimal: true),
                                                  inputFormatters: <TextInputFormatter>[
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(
                                                            r'^\d+\.?\d{0,2}')),
                                                  ],
                                                  style: const TextStyle(
                                                      fontSize: 16.0),
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'Por favor, insira um número válido.';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Fechar o dialog
                                                },
                                                child: const Text('Cancelar'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  // Implemente a lógica de alterar o nome aqui
                                                  double newValor =
                                                      double.parse(
                                                          numberController.text
                                                              .toString()
                                                              .replaceAll(
                                                                  ',', '.'));
                                                  try {
                                                    await _firestore
                                                        .collection('users')
                                                        .doc(widget.email)
                                                        .collection(
                                                            'bancodados')
                                                        .doc(documentID)
                                                        .update(
                                                      {'valorUnit': newValor},
                                                    );
                                                    _loadDocuments();
                                                  } catch (e) {
                                                    AlertDialog(
                                                      title: const Text('Erro'),
                                                      content: const Text(
                                                          'Erro ao acessar banco de dados'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // Fechar o dialog
                                                          },
                                                          child:
                                                              const Text('Ok'),
                                                        ),
                                                      ],
                                                    );
                                                  }

                                                  // Faça algo com o novo nome
                                                  if (!context.mounted) return;
                                                  Navigator.of(context)
                                                      .pop(); // Fechar o dialog
                                                },
                                                child: const Text('Alterar'),
                                              ),
                                            ],
                                          );
                                        });
                                  },
                                  icon: const Icon(
                                    Icons.edit_square,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        offset: Offset(2, 2),
                                        blurRadius: 5,
                                      ),
                                      Shadow(
                                        color: Colors.black,
                                        offset: Offset(-2, 2),
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.menu,
        ),
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Selecione uma opção:'),
                content: SizedBox(
                  height: 100,
                  child: Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        20.0,
                                      ), // Definindo as bordas redondas
                                    ),
                                  ),
                                  foregroundColor:
                                      const MaterialStatePropertyAll(
                                          Colors.white),
                                  backgroundColor:
                                      const MaterialStatePropertyAll(
                                    Colors.blueGrey,
                                  ),
                                ),
                                onPressed: () async {
                                  // Ação ao pressionar "Manual"
                                  final GlobalKey<FormState> formKey =
                                      GlobalKey<FormState>();
                                  String documentoID = '';
                                  String nome = '';
                                  double valorUnit = 0.0;
                                  String image = '';

                                  await showDialog<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Cadastrar Produto'),
                                        content: SingleChildScrollView(
                                          child: Form(
                                            key: formKey,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                TextFormField(
                                                  decoration:
                                                      const InputDecoration(
                                                          icon: Icon(
                                                            Icons
                                                                .barcode_reader,
                                                          ),
                                                          labelText:
                                                              'Codigo de barras'),
                                                  onSaved: (value) {
                                                    documentoID = value!;
                                                  },
                                                ),
                                                TextFormField(
                                                  decoration:
                                                      const InputDecoration(
                                                          icon: Icon(
                                                            Icons.abc_rounded,
                                                          ),
                                                          labelText:
                                                              'Produto *'),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Por favor, insira o nome do Produto';
                                                    }
                                                    return null;
                                                  },
                                                  onSaved: (value) {
                                                    nome = value!;
                                                  },
                                                ),
                                                TextFormField(
                                                  decoration:
                                                      const InputDecoration(
                                                          icon: Icon(
                                                            Icons.attach_money,
                                                          ),
                                                          labelText:
                                                              'Valor Unitário *'),
                                                  keyboardType:
                                                      const TextInputType
                                                          .numberWithOptions(
                                                    decimal: true,
                                                  ),
                                                  inputFormatters: <TextInputFormatter>[
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(
                                                            r'^\d+\.?\d{0,2}')),
                                                  ],
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Por favor, insira o Valor Unitário';
                                                    }
                                                    return null;
                                                  },
                                                  onSaved: (value) {
                                                    valorUnit =
                                                        double.parse(value!);
                                                  },
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              try {
                                                if (formKey.currentState!
                                                    .validate()) {
                                                  final progressDialogFinal =
                                                      await MyWidgetPadrao()
                                                          .progressDialog(
                                                              context);
                                                  await progressDialogFinal
                                                      .show();
                                                  formKey.currentState!.save();
                                                  image =
                                                      await ImageUploaderService()
                                                          .searchAndUploadImage(
                                                    'imagens: ${nome.toString()}',
                                                    widget.email,
                                                  );

                                                  // Lógica para cadastrar o produto com os dados fornecidos
                                                  await BancoDadosFirebase()
                                                      .addDadosManualmente(
                                                    widget.email,
                                                    documentoID,
                                                    nome,
                                                    valorUnit,
                                                    image,
                                                  );
                                                  _loadDocuments();
                                                  progressDialogFinal.hide();
                                                  if (!context.mounted) return;
                                                  Navigator.of(context).pop();
                                                }
                                              } catch (e) {
                                                MyWidgetPadrao.showErrorDialog(
                                                    context);
                                                Navigator.of(context).pop();
                                              }
                                            },
                                            child: const Text('Cadastrar'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Icon(
                                  Icons.abc_rounded,
                                  size: 50,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Expanded(
                              flex: 1,
                              child: Text(
                                'Manualmente',
                                style: TextStyle(
                                  fontFamily: 'Demi',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        20.0,
                                      ), // Definindo as bordas redondas
                                    ),
                                  ),
                                  foregroundColor:
                                      const MaterialStatePropertyAll(
                                          Colors.white),
                                  backgroundColor:
                                      const MaterialStatePropertyAll(
                                    Colors.green,
                                  ),
                                ),
                                onPressed: () async {
                                  // Ação ao pressionar "Finalizar"
                                  Navigator.of(context).pop();
                                  try {
                                    await scanBarcodeNormal(
                                        widget.email, contextPrincipal!);
                                  } catch (e) {
                                    MyWidgetPadrao.showErrorDialog(
                                        contextPrincipal!);
                                  }
                                },
                                child: const Icon(
                                  Icons.qr_code,
                                  size: 50,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Expanded(
                              flex: 1,
                              child: Text(
                                'Cod. de barras',
                                style: TextStyle(
                                  fontFamily: 'Demi',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
