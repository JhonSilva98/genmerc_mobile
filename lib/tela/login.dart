import 'package:flutter/material.dart';
import 'package:genmerc_mobile/auth_services/login_provider.dart';
import 'package:genmerc_mobile/firebase/banco_dados.dart';
import 'package:genmerc_mobile/tela/cadastro.dart';
import 'package:genmerc_mobile/tela/tela_principal.dart';
import 'package:genmerc_mobile/widgetPadrao/padrao.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerSenha = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0XFF272938),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Container(
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
            Flex(
              direction: Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const Text(
                            'Gen',
                            style: TextStyle(
                                color: Color(0xFF009bda),
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Container(
                            height: 60,
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF009bda),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Merc',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Flex(
                    direction: Axis.vertical,
                    children: [
                      Flexible(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView(
                          children: [
                            TextFormField(
                              controller: _controllerEmail,
                              autocorrect: false,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                icon: const Icon(
                                  Icons.email,
                                  color: Colors.white, // Cor do ícone
                                ),
                                labelText: 'E-mail',
                                hintText: 'Digite seu E-mail',
                                labelStyle: const TextStyle(
                                  color: Colors.white, // Cor do texto da label
                                ),
                                hintStyle: const TextStyle(
                                  color: Colors.white, // Cor do texto do hint
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Colors.white, // Cor da borda
                                    width: 2.0, // Largura da borda
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Colors
                                        .white, // Cor da borda quando em foco
                                    width:
                                        2.0, // Largura da borda quando em foco
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: _controllerSenha,
                              autocorrect: false,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                              ),
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true,
                              obscuringCharacter: '•',
                              decoration: InputDecoration(
                                icon: const Icon(
                                  Icons.key,
                                  color: Colors.white, // Cor do ícone
                                ),
                                labelText: 'Senha',
                                hintText: 'Digite sua senha',
                                labelStyle: const TextStyle(
                                  color: Colors.white, // Cor do texto da label
                                ),
                                hintStyle: const TextStyle(
                                  color: Colors.white, // Cor do texto do hint
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Colors.white, // Cor da borda
                                    width: 2.0, // Largura da borda
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Colors
                                        .white, // Cor da borda quando em foco
                                    width:
                                        2.0, // Largura da borda quando em foco
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: ElevatedButton(
                      onPressed: () async {
                        final progressDialogFinal =
                            await MyWidgetPadrao().progressDialog(context);
                        await progressDialogFinal.show();
                        try {
                          await authProvider.signInWithEmailAndPassword(
                            _controllerEmail.text.toString(),
                            _controllerSenha.text.toString(),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  title:
                                      const Text('Erro nos dados ou conexão'),
                                  content: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                            BancoDadosFirebase bdfirebase =
                                BancoDadosFirebase();
                            if (await bdfirebase.isDocumentExist(
                              authProvider.user!.email.toString(),
                            )) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const TelaPrincipal()),
                                (Route<dynamic> route) => false,
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Cadastro()),
                              );
                            }
                          }
                        } catch (e) {
                          MyWidgetPadrao.showErrorDialog(context);
                        }
                      },
                      child: const Text('ENTRAR')),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
