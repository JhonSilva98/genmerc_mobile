import 'package:flutter/material.dart';
import 'package:genmerc_mobile/firebase/banco_dados.dart';
import 'package:genmerc_mobile/tela/login.dart';
import 'package:genmerc_mobile/tela/tela_principal.dart';
import 'package:provider/provider.dart';
import 'package:genmerc_mobile/auth_services/login_provider.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  BancoDadosFirebase bdFirebase = BancoDadosFirebase();
  final TextEditingController _controller = TextEditingController();
  String photoSelect =
      'https://firebasestorage.googleapis.com/v0/b/genmerc-mobile.appspot.com/o/Administrativo%2Fideogram.jpeg?alt=media&token=4d0a8e07-8977-4ed5-9733-872585aab3e9&_gl=1*16v9f5f*_ga*MTQ3OTA0NDM3Ny4xNjk2ODU0MzAx*_ga_CW55HF8NVT*MTY5NjkzNzg0My44OS4xLjE2OTY5Mzc5OTguMi4wLjA.';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage(
                "assets/ideogram.jpeg",
              ), // Substitua pelo caminho da sua imagem
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.5), // Ajuste a opacidade aqui
                BlendMode
                    .dstATop, // Define o modo de mesclagem para mesclar com a cor de fundo
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        leading: IconButton(
            onPressed: () async {
              await authProvider.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
              await bdFirebase.deletePhoto();
            },
            iconSize: 30,
            hoverColor: Colors.white,
            icon: const Icon(Icons.arrow_back)),
        title: Center(
          child: Stack(
            children: [
              // Texto com bordas brancas simuladas
              Text(
                "GENMERC",
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2.0
                    ..color = Colors.white,
                ),
              ),
              // Texto com a cor do texto
              const Text(
                "GENMERC",
                style: TextStyle(
                    fontSize: 32.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold // Cor do texto
                    ),
              ),
            ],
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
                await bdFirebase
                    .getImageFromGallery(authProvider.user!.email.toString());
                if (bdFirebase.pathImage != null) {
                  setState(() {
                    photoSelect = bdFirebase.imageUrl;
                  });
                }
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
                if (_controller.text != '') {
                  await bdFirebase.setDocumentInCollection(
                    authProvider.user!.email.toString(),
                    _controller.text.toString(),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TelaPrincipal()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              child: const Text('Cadastrar'),
            ),
          )
        ],
      ),
    );
  }
}
