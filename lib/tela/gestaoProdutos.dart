import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:genmerc_mobile/firebase/bancoDados.dart';
import 'package:genmerc_mobile/funcion/buttonScan.dart';

class GestaoProdutos extends StatefulWidget {
  final String email;
  const GestaoProdutos({super.key, required this.email});

  @override
  State<GestaoProdutos> createState() => _GestaoProdutosState();
}

class _GestaoProdutosState extends State<GestaoProdutos> {
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
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      if (barcodeScanRes != '-1') {
        await player.play(AssetSource('beep-07a.mp3'));
        final resul = await ButtonScan(email: email, context: context)
            .executarFuncaoBarcode(barcodeScanRes);
        if (resul.isNotEmpty || resul['nome'] != 'error') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dados adicionados!'),
              duration: Duration(seconds: 2), // Duração da snackbar
            ),
          );
          _loadDocuments();
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
        itemBuilder: (BuildContext context, int index) {
          final document = filteredDocuments[index];
          final documentID = filteredDocuments[index].id;
          return Card(
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
                              'https://firebasestorage.googleapis.com/v0/b/genmerc-mobile.appspot.com/o/ideogram.jpeg?alt=media&token=b2f40124-eb43-4860-a600-6e3eb43dd6d1&_gl=1*1yyx08k*_ga*MTYxMDM5MTE1NC4xNjkzMzk4MDk0*_ga_CW55HF8NVT*MTY5NTkyODM0OC43NC4xLjE2OTU5MzA0MDcuNDcuMC4w',
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
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
                                              await imagePicker
                                                  .getImageFromGallery(
                                                      widget.email);
                                              String newImage =
                                                  imagePicker.imageUrl;
                                              if (newImage != '') {
                                                try {
                                                  await _firestore
                                                      .collection('users')
                                                      .doc(widget.email)
                                                      .collection('bancodados')
                                                      .doc(documentID)
                                                      .update(
                                                    {'image': newImage},
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
                                                          Navigator.of(context)
                                                              .pop(); // Fechar o dialog
                                                        },
                                                        child: const Text('Ok'),
                                                      ),
                                                    ],
                                                  );
                                                }
                                              }
                                              imagePicker.imageUrl = '';
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
                                              await imagePicker
                                                  .getImageFromCamera(
                                                      widget.email);
                                              String newImage =
                                                  imagePicker.imageUrl;
                                              if (newImage != '') {
                                                try {
                                                  await _firestore
                                                      .collection('users')
                                                      .doc(widget.email)
                                                      .collection('bancodados')
                                                      .doc(documentID)
                                                      .update(
                                                    {'image': newImage},
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
                                                          Navigator.of(context)
                                                              .pop(); // Fechar o dialog
                                                        },
                                                        child: const Text('Ok'),
                                                      ),
                                                    ],
                                                  );
                                                }
                                              }
                                              imagePicker.imageUrl = '';
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
                            Icons.edit,
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
                                    final TextEditingController nameController =
                                        TextEditingController();
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
                                                      TextCapitalization.words,
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
                                    Icons.edit,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              'R\$ ${document['valorUnit'].toString().replaceAll('.', ',')}',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 77, 157, 197)),
                            ),
                            IconButton(
                              onPressed: () async {
                                final TextEditingController numberController =
                                    TextEditingController();

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
                                              decoration: const InputDecoration(
                                                labelText: 'Valor',
                                                border: OutlineInputBorder(),
                                                prefixIcon:
                                                    Icon(Icons.attach_money),
                                              ),
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                  decimal: true),
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .allow(
                                                  RegExp(
                                                      r'^[\d,]+(\.\d{0,2})?$'),
                                                ),
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
                                              String newValor = numberController
                                                  .text
                                                  .toString()
                                                  .replaceAll(',', '.');
                                              try {
                                                await _firestore
                                                    .collection('users')
                                                    .doc(widget.email)
                                                    .collection('bancodados')
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
                                                        Navigator.of(context)
                                                            .pop(); // Fechar o dialog
                                                      },
                                                      child: const Text('Ok'),
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
                                Icons.edit,
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
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.qr_code,
        ),
        onPressed: () async {
          await scanBarcodeNormal(widget.email, context);
        },
      ),
    );
  }
}
