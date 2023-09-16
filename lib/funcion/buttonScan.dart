import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:genmerc_mobile/api/consumerProductor.dart';
import 'package:genmerc_mobile/api/seachImages.dart';
import 'package:genmerc_mobile/widgetPadrao/padrao.dart';

class ButtonScan {
  FirebaseFirestore documentSnapshot = FirebaseFirestore.instance;
  MyGetProductor product = MyGetProductor();
  ImageUploaderService seachImage = ImageUploaderService();

  String recentCod = '';
  String email;
  BuildContext context;

  //--------------------------------

  //--------------------------------

  ButtonScan({
    required this.email,
    required this.context, // A função onPressed é obrigatória
  });

  /*Future<void> executarFuncaoBarcode(
    String cod,
  ) async {
    BdFiredart dados = BdFiredart();
    await dados.addBancoFiredart(cod, context);
  }*/

  Future<Map<String, dynamic>> executarFuncaoBarcode(
      String barcodeScanRes) async {
    // Product? product = await MyGetProductor().getProduct(barcodeScanRes);
    final produtos = await product.getProduct(barcodeScanRes);

    Map<String, dynamic> mapii = {};
    final documentExist = documentSnapshot
        .collection('users')
        .doc(email)
        .collection('bancodados')
        .doc(barcodeScanRes)
        .get();
    DocumentReference collectionAdd = documentSnapshot
        .collection('users')
        .doc(email)
        .collection('bancodados')
        .doc(barcodeScanRes);
    await documentExist.then((value) async {
      if (value.exists) {
        // O documento existe
        print('documento existe');
        Map<String, dynamic> data = value.data() as Map<String, dynamic>;
        final nome = data['nome'].toString();
        var numberConvert = data['valorUnit'];
        double numm = numberConvert.toDouble();
        final valorUnit = numm;
        final image = (data['image'] ?? '').toString();
        //print(' dados recuperador $nome $valorUnit $image');

        mapii.addAll({
          'nome': nome,
          'valorUnit': valorUnit,
          'image': image,
        });
        print('entrou $mapii');
        // Faça algo com os dados
      } else {
        // O documento não existe no bd

        if (produtos != null) {
          TextEditingController controllervalor = TextEditingController();
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Adicione'),
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: TextFormField(
                        controller: controllervalor,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^[\d,]+(\.\d{0,2})?$'),
                          ),
                        ],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                            labelText: 'Digite o valor do produto:',
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
                            hintStyle:
                                MyWidgetPadrao.myBeautifulTextStyleBlack),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Adicione os dados inexistentes',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      mapii = mapii;
                    },
                    child: const Text(
                      'Fechar',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (controllervalor.text.isNotEmpty) {
                        controllervalor.text =
                            controllervalor.text.replaceAll(',', '.');
                        final imagePesquisada =
                            await seachImage.searchAndUploadImage(
                                "imagens: ${produtos.productName.toString()}");

                        mapii.addAll({
                          'nome':
                              (produtos.productName ?? 'sem nome').toString(),
                          'valorUnit': double.parse(controllervalor.text),
                          'image': (produtos.imageFrontUrl ?? imagePesquisada)
                              .toString(),
                        });

                        Navigator.of(context).pop();
                        await collectionAdd.set({
                          'nome':
                              (produtos.productName ?? 'sem nome').toString(),
                          'image': (produtos.imageFrontUrl ?? imagePesquisada)
                              .toString(),
                          'valorUnit': double.parse(controllervalor.text),
                        });
                      }
                    },
                    child: const Text('Adicionar'),
                  ),
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                backgroundColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              );
            },
          );
        } else {
          TextEditingController controllerNome = TextEditingController();
          TextEditingController controllervalor = TextEditingController();
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Adicione'),
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: TextFormField(
                        controller: controllerNome,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                            labelText: 'Digite o nome do produto',
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
                            hintStyle:
                                MyWidgetPadrao.myBeautifulTextStyleBlack),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      child: TextFormField(
                        controller: controllervalor,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^[\d,]+(\.\d{0,2})?$'),
                          ),
                        ],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                            labelText: 'Digite o valor do produto:',
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
                            hintStyle:
                                MyWidgetPadrao.myBeautifulTextStyleBlack),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Adicione os dados inexistentes',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      mapii = mapii;
                    },
                    child: const Text(
                      'Fechar',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (controllerNome.text.isNotEmpty &&
                          controllervalor.text.isNotEmpty) {
                        controllervalor.text =
                            controllervalor.text.replaceAll(',', '.');
                        final imagePesquisada =
                            await seachImage.searchAndUploadImage(
                                "imagens: ${controllerNome.text}");

                        mapii.addAll({
                          'nome': controllerNome.text,
                          'valorUnit': double.parse(controllervalor.text),
                          'image': imagePesquisada,
                        });

                        Navigator.of(context).pop();
                        await collectionAdd.set({
                          'nome': controllerNome.text,
                          'image': imagePesquisada,
                          'valorUnit': double.parse(controllervalor.text),
                        });
                      }
                    },
                    child: const Text('Adicionar'),
                  ),
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                backgroundColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              );
            },
          );
        }
      }
    }).catchError((error) {
      // Trate os erros aqui
      mapii.addAll({
        'nome': 'error',
        'valorUnit': 0.0,
        'image': 'error',
      });
      print("Erro ao buscar o documento: $error");
    });
    print('Ultimo $mapii');
    return mapii;
  }
}
