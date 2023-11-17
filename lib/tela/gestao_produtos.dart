import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:genmerc_mobile/firebase/banco_dados.dart';
import 'package:genmerc_mobile/funcion/button_scan.dart';
import 'package:genmerc_mobile/funcion/logic_button.dart';

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
  Logicbutton logicbutton = Logicbutton();
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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[300],
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
        toolbarHeight: 100,
        shadowColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.0), // Borda arredondada
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            onChanged: _filterDocuments,
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
        centerTitle: true,
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
              await logicbutton.logicButtonDeleteBD(
                document['image'],
                widget.email,
                documentID,
                context,
              );
              _loadDocuments();
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
                          child: CachedNetworkImage(
                            imageUrl: document['image'],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const FittedBox(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, error, stackTrace) {
                              return CachedNetworkImage(
                                imageUrl:
                                    'https://firebasestorage.googleapis.com/v0/b/genmerc-mobile.appspot.com/o/Administrativo%2Fdairy.png?alt=media&token=7c2c92df-11c2-402d-9f63-d6933f213a64&_gl=1*1ajv9ft*_ga*MTQ3OTA0NDM3Ny4xNjk2ODU0MzAx*_ga_CW55HF8NVT*MTY5NzU3MDExOC45NC4xLjE2OTc1NzI0MjEuMzEuMC4w',
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                                placeholder: (context, url) => const FittedBox(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, error, stackTrace) =>
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
                              await logicbutton.logicButtonChangeImageBD(
                                context,
                                widget.email,
                                document['image'],
                                documentID,
                              );
                              _loadDocuments();
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
                                      await logicbutton.logicButtonChangeNameBD(
                                        context,
                                        document['nome'],
                                        widget.email,
                                        documentID,
                                      );
                                      _loadDocuments();
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
                                    await logicbutton.logicButtonChangeValueBD(
                                      context,
                                      double.parse(
                                        document['valorUnit'].toString(),
                                      ),
                                      widget.email,
                                      documentID,
                                    );
                                    _loadDocuments();
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
          await logicbutton.logicButtonCadastrarProdutosBD(
            context,
            widget.email,
          );
          _loadDocuments();
        },
      ),
    );
  }
}
