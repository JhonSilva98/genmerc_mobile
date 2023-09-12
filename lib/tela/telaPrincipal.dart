import 'package:flutter/material.dart';
import 'package:genmerc_mobile/auth_services/loginProvider.dart';
import 'package:genmerc_mobile/tela/login.dart';
import 'package:provider/provider.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  Widget cardPersonalite() {
    return Flex(
      direction: Axis.horizontal,
      children: [
        Flexible(
          flex: 6,
          child: SizedBox(
            height: 80,
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Flexible(
                            child: Image.network(
                              'https://www.imagensempng.com.br/wp-content/uploads/2022/01/2442.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const Flexible(
                            child: Flex(
                              direction: Axis.vertical,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  flex: 4,
                                  child: Text(
                                    'Coca-Colallll',
                                    softWrap: false,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Text(
                                    '1x RS: 5,50',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 10),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Flexible(
                      flex: 1,
                      child: Text(
                        'RS: 5,50',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.clear,
              color: Colors.red,
            ),
          ),
        )
      ],
    );
  }

  List<Widget> listCard = [];

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
        title: const Center(
          child: Column(
            children: [
              Text(
                'GENMERC',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Armazem 62',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        leading: const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
                'https://img.freepik.com/vetores-gratis/desenho-de-carrinho-e-construcao-de-loja_138676-2085.jpg?w=2000'),
          ),
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
        children: [
          Flexible(
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
                        child: const Card(
                          child: Center(
                              child: FittedBox(
                            fit: BoxFit.cover,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'RS: 5,50',
                                style: TextStyle(
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
                          )),
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
          onPressed: () {
            setState(() {
              listCard.add(cardPersonalite());
            });
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
