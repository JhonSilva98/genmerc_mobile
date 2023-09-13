import 'package:flutter/material.dart';
import 'package:genmerc_mobile/firebase/bancoDados.dart';
import 'package:genmerc_mobile/tela/login.dart';
import 'package:provider/provider.dart';
import 'package:genmerc_mobile/auth_services/loginProvider.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  BancoDadosFirebase bdFirebase = BancoDadosFirebase();
  final TextEditingController _controller = TextEditingController();
  String photoSelect =
      'https://img.freepik.com/vetores-gratis/desenho-de-carrinho-e-construcao-de-loja_138676-2085.jpg?w=2000';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () async {
              await authProvider.signOut();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
              await bdFirebase.deletePhoto();
            },
            icon: const Icon(Icons.arrow_back)),
        title: const Center(
          child: Text(
            'GENMERC',
          ),
        ),
      ),
      body: Flex(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        direction: Axis.vertical,
        children: [
          Flexible(
            child: InkWell(
              onTap: () async {
                await bdFirebase.getImageFromGallery();
                setState(() {
                  photoSelect = bdFirebase.imageUrl;
                });
              },
              child: SizedBox(
                height: MediaQuery.of(context).size.width / 2,
                width: MediaQuery.of(context).size.width / 2,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    photoSelect,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_circle_outline_outlined,
                      size: 50,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                    icon: Icon(Icons.store),
                    labelText: 'Nome',
                    hintText: 'Digite o nome de sua empresa:'),
              ),
            ),
          ),
          Flexible(
            child: ElevatedButton(
              onPressed: () async {
                await bdFirebase.setDocumentInCollection(
                  authProvider.user!.email.toString(),
                  _controller.text.toString(),
                );
              },
              child: const Text('Cadastrar'),
            ),
          )
        ],
      ),
    );
  }
}
