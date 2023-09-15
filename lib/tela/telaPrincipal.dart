import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genmerc_mobile/auth_services/loginProvider.dart';
import 'package:genmerc_mobile/firebase/bancoDados.dart';
import 'package:genmerc_mobile/funcion/buttonScan.dart';
import 'package:genmerc_mobile/tela/login.dart';
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

  Widget cardPersonalite(
      Key key, int index, String nome, double valorUnit, String image) {
    subtotal += valorUnit;
    return Flex(
      key: key,
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SizedBox(
            height: 80,
            width: double.infinity,
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Image.network(
                            image,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.photo_library_outlined);
                            },
                          ),
                          const Divider(
                            height: 10,
                          ),
                          Expanded(
                            child: Flex(
                              direction: Axis.vertical,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  flex: 4,
                                  child: Text(
                                    '$index $nome',
                                    softWrap: false,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Text(
                                    '1x $valorUnit',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 10),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'R\$: $valorUnit',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              listCard.removeWhere((item) => item.key == key);
              subtotal -= valorUnit;
            });
          },
          icon: const Icon(
            Icons.clear,
            color: Colors.red,
            size: 20,
          ),
        )
      ],
    );
  }

  Widget cardPersonalite2(
      Key key, int index, String nome, double valorUnit, String image) {
    subtotal += valorUnit;
    return Flex(
      key: key,
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SizedBox(
            height: 80,
            width: double.infinity,
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                        height: MediaQuery.of(context).size.width / 5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
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
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  Text(
                                    '$index - $nome',
                                    softWrap: false,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Flex(
                                direction: Axis.horizontal,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      '1x $valorUnit',
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 10),
                                    ),
                                  ),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Text(
                                        'R\$: $valorUnit',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
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
        ),
        IconButton(
          onPressed: () {
            setState(() {
              listCard.removeWhere((item) => item.key == key);
              subtotal -= valorUnit;
            });
          },
          icon: const Icon(
            Icons.clear,
            color: Colors.red,
            size: 20,
          ),
        )
      ],
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
        if (resul.isNotEmpty) {
          setState(() {
            listCard.add(
              cardPersonalite2(
                GlobalKey(),
                listCard.length,
                resul['nome'],
                resul['valorUnit'],
                resul['image'],
              ),
            );
          });
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
        }
      } catch (e) {
        print("Exceção ao redirecionar para a tela de login: $e");
      }
    }
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 237, 240),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 160, 194, 224),
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
                return Column(
                  children: [
                    const Text(
                      'GENMERC',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      dados!['nome'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
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
              await authProvider.signOut();
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
      body: Flex(
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
                          child: Center(
                              child: FittedBox(
                            fit: BoxFit.cover,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'R\$: $subtotal',
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
                        onPressed: () {},
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
      floatingActionButton: SizedBox(
        width: 100.0, // Defina a largura desejada
        height: 100.0,
        child: FloatingActionButton(
          onPressed: () async {
            await scanBarcodeNormal(
                authProvider.user!.email.toString(), context);
            print(authProvider.user!.email.toString());
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
                    onPressed: () {},
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
