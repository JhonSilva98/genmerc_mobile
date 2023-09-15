import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:genmerc_mobile/api/consumerProductor.dart';
import 'package:genmerc_mobile/widgetPadrao/padrao.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class ButtonScan {
  FirebaseFirestore documentSnapshot = FirebaseFirestore.instance;
  MyGetProductor product = MyGetProductor();

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

                        await collectionAdd.set({
                          'nome':
                              (produtos.productName ?? 'sem nome').toString(),
                          'image': (produtos.imageFrontUrl ?? '').toString(),
                          'valorUnit': double.parse(controllervalor.text),
                        });

                        Navigator.of(context).pop();
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
          mapii.addAll({
            'nome': (produtos.productName ?? 'sem nome').toString(),
            'valorUnit': double.parse(controllervalor.text),
            'image': (produtos.imageFrontUrl ?? '').toString(),
          });
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

                        await collectionAdd.set({
                          'nome': controllerNome.text,
                          'image': '',
                          'valorUnit': double.parse(controllervalor.text),
                        });

                        Navigator.of(context).pop();
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
          mapii.addAll({
            'nome': controllerNome.text,
            'valorUnit': double.parse(controllervalor.text),
            'image': '',
          });
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

  /*Future<void> addBancoFiredart(String cod, context) async {
//aqui vai pegar os nomes dos documentos
    List<String> listNomesDocuments = await getListidDocuments();
    List<String> listNomesDocumentsVenda = await getListidDocumentsVenda();
//aqui vai fazer as verificaçoes se existe ou dados na API
    MyGetProductor getProdutosAPI = MyGetProductor();

    if (!listNomesDocumentsVenda.contains(cod)) {
      var produto = await getProdutosAPI.getProduct(cod);
      if (produto != null) {
        if (listNomesDocuments.contains(cod)) {
          print('Contem na lista');
          var document = await ref.document(cod).get();
          String productName = document['nome'];
          var numberConvert = document['valorUnit'];
          double numm = numberConvert.toDouble();
          TextEditingController controllerQTD0 = TextEditingController(
            text: "1",
          );
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Adicione'),
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: controllerQTD0,
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
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                          labelText: 'Digite a quantidade do produto:',
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
                          hintStyle: MyWidgetPadrao.myBeautifulTextStyleBlack),
                    ),
                    const Text(
                      'Adicione a quantidade!',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Fechar',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (controllerQTD0.text.isNotEmpty) {
                        controllerQTD0.text =
                            controllerQTD0.text.replaceAll(',', '.');
                        double sub = double.parse(controllerQTD0.text) * numm;
                        await venda.document(cod).create({
                          'cod': cod,
                          'nome': productName,
                          'valorUnit': numm,
                          'quantidade': double.parse(controllerQTD0.text),
                          'subtotal': sub
                        });
                        Navigator.of(context).pop();
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
          print('NÃO TEM NEM NOME NEM NADA mas tem na API');

          TextEditingController controllervalor = TextEditingController();
          TextEditingController controllerQTD = TextEditingController(
            text: "1",
          );
          String? nome = produto.productName;
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Adicione'),
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                          fontSize: 50,
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
                    Flexible(
                      child: TextFormField(
                        controller: controllerQTD,
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
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                            labelText: 'Digite a quantidade do produto:',
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
                    },
                    child: const Text(
                      'Fechar',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (controllervalor.text.isNotEmpty &&
                          controllerQTD.text.isNotEmpty) {
                        controllervalor.text =
                            controllervalor.text.replaceAll(',', '.');
                        controllerQTD.text =
                            controllerQTD.text.replaceAll(',', '.');
                        String newNome = nome!;
                        ref.document(cod).create({
                          'cod': cod,
                          'nome': newNome,
                          'valorUnit': double.parse(controllervalor.text),
                        });
                        double sub = double.parse(controllervalor.text) *
                            double.parse(controllerQTD.text);
                        venda.document(cod).create({
                          'cod': cod,
                          'nome': newNome,
                          'valorUnit': double.parse(controllervalor.text),
                          'quantidade': double.parse(controllerQTD.text),
                          'subtotal': sub
                        });
                        Navigator.of(context).pop();
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
      } else {
        print('NÃO TEM NEM NOME NEM NADA');
        if (listNomesDocuments.contains(cod)) {
          print('Contem na lista');
          var document = await ref.document(cod).get();
          String productName = document['nome'];
          var numberConvert = document['valorUnit'];
          double numm = numberConvert.toDouble();
          TextEditingController controllerQTD0 = TextEditingController(
            text: "1",
          );
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Adicione'),
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: controllerQTD0,
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
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                          labelText: 'Digite a quantidade do produto:',
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
                          hintStyle: MyWidgetPadrao.myBeautifulTextStyleBlack),
                    ),
                    const Text(
                      'Adicione a quantidade!',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Fechar',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (controllerQTD0.text.isNotEmpty) {
                        controllerQTD0.text =
                            controllerQTD0.text.replaceAll(',', '.');
                        double sub = double.parse(controllerQTD0.text) * numm;
                        await venda.document(cod).create({
                          'cod': cod,
                          'nome': productName,
                          'valorUnit': numm,
                          'quantidade': double.parse(controllerQTD0.text),
                          'subtotal': sub
                        });
                        Navigator.of(context).pop();
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
          TextEditingController controllerQTD = TextEditingController(
            text: "1",
          );
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
                    Flexible(
                      child: TextFormField(
                        controller: controllerQTD,
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
                            labelText: 'Digite a quantidade do produto:',
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
                    },
                    child: const Text(
                      'Fechar',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (controllerNome.text.isNotEmpty &&
                          controllervalor.text.isNotEmpty &&
                          controllerQTD.text.isNotEmpty) {
                        controllervalor.text =
                            controllervalor.text.replaceAll(',', '.');
                        controllerQTD.text =
                            controllerQTD.text.replaceAll(',', '.');

                        ref.document(cod).create({
                          'cod': cod,
                          'nome': controllerNome.text,
                          'valorUnit': double.parse(controllervalor.text),
                        });
                        double sub = double.parse(controllervalor.text) *
                            double.parse(controllerQTD.text);
                        venda.document(cod).create({
                          'cod': cod,
                          'nome': controllerNome.text,
                          'valorUnit': double.parse(controllervalor.text),
                          'quantidade': double.parse(controllerQTD.text),
                          'subtotal': sub
                        });
                        Navigator.of(context).pop();
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
    } else {
      TextEditingController controllerQTD0 = TextEditingController(
        text: "1",
      );
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Adicione'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: TextFormField(
                    controller: controllerQTD0,
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
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                        labelText: 'Digite a quantidade do produto:',
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
                        hintStyle: MyWidgetPadrao.myBeautifulTextStyleBlack),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Esse item ja existe altere a quantidade!',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Fechar',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (controllerQTD0.text.isNotEmpty) {
                    controllerQTD0.text =
                        controllerQTD0.text.replaceAll(',', '.');

                    double newQTD = double.tryParse(controllerQTD0.text) ?? 1.0;

                    var doc = await venda.document(cod).get();

                    var numberConvert = doc['valorUnit'];
                    double numm = numberConvert.toDouble();

                    var numberqtd = doc['quantidade'];
                    double qtdAtual = numberqtd.toDouble();

                    double newQTDSoma = newQTD + qtdAtual;

                    double sub = newQTDSoma * numm;
                    await venda.document(cod).update({
                      'quantidade': newQTDSoma,
                      'subtotal': sub,
                    });
                    Navigator.of(context).pop();
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
  }*/

