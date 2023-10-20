import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:genmerc_mobile/api/seach_images.dart';
import 'package:genmerc_mobile/auth_services/login_provider.dart';
import 'package:genmerc_mobile/firebase/banco_dados.dart';
import 'package:genmerc_mobile/funcion/button_scan.dart';
import 'package:genmerc_mobile/tela/cadastro.dart';
import 'package:genmerc_mobile/tela/tela_principal.dart';
import 'package:genmerc_mobile/widgetPadrao/padrao.dart';
//import 'package:provider/provider.dart';

class Logicbutton {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  BancoDadosFirebase imagePicker = BancoDadosFirebase();
  final player = AudioPlayer();
  Future<void> logicButtonLogin(context, String controllerEmail,
      String controllerSenha, AuthProvider authProviderprime) async {
    final authProvider = authProviderprime;

    final progressDialogFinal = await MyWidgetPadrao().progressDialog(context);
    await progressDialogFinal.show();
    try {
      await authProvider.signInWithEmailAndPassword(
        controllerEmail,
        controllerSenha,
      );
    } catch (error) {
      progressDialogFinal.hide();
      if (error.toString() ==
          '[firebase_auth/user-disabled] The user account has been disabled by an administrator.') {
        await authProvider.signOut();
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Conta Desativada'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sua conta foi desativada. Por favor, entre em contato com o suporte para obter assistência.',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Fechar o diálogo
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erro nos dados ou conexão'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sua senha ou email são inválidos ou está sem conexão com a internet. Por favor, tente novamente.',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Fechar o diálogo
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
      rethrow;
    }
    try {
      if (authProvider.user != null) {
        BancoDadosFirebase bdfirebase = BancoDadosFirebase();
        if (await bdfirebase.isDocumentExist(
          authProvider.user!.email.toString(),
        )) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const TelaPrincipal()),
            (Route<dynamic> route) => false,
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Cadastro()),
          );
        }
      }
    } catch (e) {
      MyWidgetPadrao.showErrorDialog(context);
    }
  }

  Future<void> logicButtonLogoff(
    AuthProvider authProviderFinal,
    context,
  ) async {
    AuthProvider authProvider = authProviderFinal;
    try {
      await authProvider.signOut();
    } catch (e) {
      await MyWidgetPadrao.showErrorDialog(context);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const TelaPrincipal()),
          (Route<dynamic> route) => false,
        );
      });
    }
  }

  Future<void> logicButtonDeleteBD(
    String image,
    String email,
    String documentID,
    context,
  ) async {
    try {
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
                      backgroundColor: MaterialStatePropertyAll(Colors.red)),
                  onPressed: () async {
                    // Implemente a lógica e apagar aqui
                    await BancoDadosFirebase().deleteImageBD(
                      image,
                    );
                    await _firestore
                        .collection('users')
                        .doc(email)
                        .collection('bancodados')
                        .doc(documentID)
                        .delete();
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
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
    } catch (e) {
      MyWidgetPadrao.showErrorDialog(context);
      Navigator.of(context).pop(); // Fechar o dialog
    }
  }

  Future<void> logicButtonChangeImageBD(
    contextFinal,
    String email,
    String image,
    String documentID,
  ) async {
    await showDialog(
        context: contextFinal,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Escolher uma Imagem'),
            content: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Lógica para selecionar uma imagem da galeria
                      try {
                        await imagePicker.getImageFromGallery(email);
                        String newImage = imagePicker.imageUrl;
                        if (newImage != '') {
                          final progressDialogFinal = await MyWidgetPadrao()
                              .progressDialog(contextFinal);
                          await progressDialogFinal.show();
                          await imagePicker.deleteImageBD(
                            image,
                          );

                          await _firestore
                              .collection('users')
                              .doc(email)
                              .collection('bancodados')
                              .doc(documentID)
                              .update(
                            {'image': newImage},
                          );
                          //_loadDocuments();
                          progressDialogFinal.hide();
                        }
                        imagePicker.imageUrl = '';
                      } catch (e) {
                        AlertDialog(
                          title: const Text('Erro'),
                          content: const Text('Erro ao acessar banco de dados'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Fechar o dialog
                              },
                              child: const Text('Ok'),
                            ),
                          ],
                        );
                      }
                      if (!context.mounted) return;
                      Navigator.of(context).pop(); // Fechar o dialog
                    },
                    child: const Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            child: Text('Galeria', softWrap: false),
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
                        await imagePicker.getImageFromCamera(email);
                        String newImage = imagePicker.imageUrl;
                        if (newImage != '') {
                          final progressDialogFinal = await MyWidgetPadrao()
                              .progressDialog(contextFinal);
                          await progressDialogFinal.show();
                          await _firestore
                              .collection('users')
                              .doc(email)
                              .collection('bancodados')
                              .doc(documentID)
                              .update(
                            {'image': newImage},
                          );
                          progressDialogFinal.hide();
                        }
                        imagePicker.imageUrl = '';
                      } catch (e) {
                        AlertDialog(
                          title: const Text('Erro'),
                          content: const Text('Erro ao acessar banco de dados'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Fechar o dialog
                              },
                              child: const Text('Ok'),
                            ),
                          ],
                        );
                      }
                      if (!context.mounted) return;
                      Navigator.of(context).pop(); // Fechar o dialog
                    },
                    child: const Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 1,
                          child: FittedBox(
                            child: Icon(Icons.camera_alt_rounded),
                          ),
                        ),
                        Flexible(
                          flex: 3,
                          child: FittedBox(
                            child: Text('Câmera', softWrap: false),
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
                  Navigator.of(context).pop(); // Fechar o dialog
                },
                child: const Text('Cancelar'),
              ),
            ],
          );
        });
  }

  Future<void> logicButtonChangeNameBD(
    contextFinal,
    String nome,
    String email,
    String documentID,
  ) async {
    final TextEditingController nameController = TextEditingController(
      text: nome.toUpperCase(),
    );

    await showDialog(
        context: contextFinal,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Alterar Nome'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.abc,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
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
                  Navigator.of(context).pop(); // Fechar o dialog
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Implemente a lógica de alterar o nome aqui
                  String newName = nameController.text;
                  try {
                    await _firestore
                        .collection('users')
                        .doc(email)
                        .collection('bancodados')
                        .doc(documentID)
                        .update(
                      {'nome': newName},
                    );
                  } catch (e) {
                    AlertDialog(
                      title: const Text('Erro'),
                      content: const Text('Erro ao acessar banco de dados'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Fechar o dialog
                          },
                          child: const Text('Ok'),
                        ),
                      ],
                    );
                  }

                  // Faça algo com o novo nome
                  if (!context.mounted) return;
                  Navigator.of(context).pop(); // Fechar o dialog
                },
                child: const Text('Alterar'),
              ),
            ],
          );
        });
  }

  Future<void> logicButtonChangeValueBD(
      contextFinal, double valorUnit, String email, String documentID) async {
    final TextEditingController numberController = TextEditingController(
      text: valorUnit.toStringAsFixed(2).replaceAll('.', ','),
    );

    await showDialog(
        context: contextFinal,
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
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  style: const TextStyle(fontSize: 16.0),
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
                  Navigator.of(context).pop(); // Fechar o dialog
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Implemente a lógica de alterar o nome aqui
                  double newValor = double.parse(double.parse(
                    numberController.text.toString().replaceAll(',', '.'),
                  ).toStringAsFixed(2));
                  try {
                    await _firestore
                        .collection('users')
                        .doc(email)
                        .collection('bancodados')
                        .doc(documentID)
                        .update(
                      {'valorUnit': newValor},
                    );
                  } catch (e) {
                    MyWidgetPadrao.showErrorDialog(
                      contextFinal,
                    );
                  }

                  // Faça algo com o novo nome
                  if (!context.mounted) return;
                  Navigator.of(context).pop(); // Fechar o dialog
                },
                child: const Text('Alterar'),
              ),
            ],
          );
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
          //_showSnackBar(context);
          await scanBarcodeNormal(email, context);
        }
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
  }

  Future<void> logicButtonCadastrarProdutosBD(
    contextFinal,
    String email,
  ) async {
    await showDialog(
      context: contextFinal,
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
                                const MaterialStatePropertyAll(Colors.white),
                            backgroundColor: const MaterialStatePropertyAll(
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
                                            decoration: const InputDecoration(
                                                icon: Icon(
                                                  Icons.barcode_reader,
                                                ),
                                                labelText: 'Codigo de barras'),
                                            onSaved: (value) {
                                              documentoID = value!;
                                            },
                                          ),
                                          TextFormField(
                                            decoration: const InputDecoration(
                                                icon: Icon(
                                                  Icons.abc_rounded,
                                                ),
                                                labelText: 'Produto *'),
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
                                            decoration: const InputDecoration(
                                                icon: Icon(
                                                  Icons.attach_money,
                                                ),
                                                labelText: 'Valor Unitário *'),
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
                                              decimal: true,
                                            ),
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'^\d+\.?\d{0,2}')),
                                            ],
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Por favor, insira o Valor Unitário';
                                              }
                                              return null;
                                            },
                                            onSaved: (value) {
                                              valorUnit = double.parse(value!);
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
                                                    .progressDialog(context);
                                            await progressDialogFinal.show();
                                            formKey.currentState!.save();
                                            image = await ImageUploaderService()
                                                .searchAndUploadImage(
                                              'imagens: ${nome.toString()}',
                                              email,
                                            );

                                            // Lógica para cadastrar o produto com os dados fornecidos
                                            await BancoDadosFirebase()
                                                .addDadosManualmente(
                                              email,
                                              documentoID,
                                              nome,
                                              valorUnit,
                                              image,
                                            );

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
                                const MaterialStatePropertyAll(Colors.white),
                            backgroundColor: const MaterialStatePropertyAll(
                              Colors.green,
                            ),
                          ),
                          onPressed: () async {
                            // Ação ao pressionar "Finalizar"
                            Navigator.of(context).pop();
                            try {
                              await scanBarcodeNormal(email, contextFinal);
                            } catch (e) {
                              MyWidgetPadrao.showErrorDialog(contextFinal);
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
  }
}
