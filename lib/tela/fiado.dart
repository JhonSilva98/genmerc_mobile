import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:genmerc_mobile/widgetPadrao/padrao.dart';
import 'package:intl/date_symbol_data_local.dart';

class Fiado extends StatefulWidget {
  final String email;
  const Fiado({super.key, required this.email});

  @override
  State<Fiado> createState() => _FiadoState();
}

class _FiadoState extends State<Fiado> {
  MyWidgetPadrao cardPersonalite = MyWidgetPadrao();
  BuildContext? contextPrincipal;

  Future<Widget> cardWidget(
    String nome,
    String data,
    double valor,
    String telefone,
    context,
    String email,
    String nomeDoDocumento,
    var listProdutos,
    String endereco,
    String dataCompra,
    String complemento,
  ) async {
    await initializeDateFormatting('pt_BR');
    return await cardPersonalite.cardPersonalite(
      nome,
      data,
      valor,
      telefone,
      context,
      email,
      nomeDoDocumento,
      listProdutos,
      endereco,
      dataCompra,
      complemento,
    );
  }

  @override
  Widget build(BuildContext context) {
    contextPrincipal = context;

    return Scaffold(
      appBar: AppBar(
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
        centerTitle: true,
        actions: const [
          SizedBox(
            width: 20,
          )
        ],
        title: Center(
          child: Stack(
            children: [
              // Texto com bordas brancas simuladas
              Text(
                "Fiado",
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Demi',
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2.0
                    ..color = Colors.black,
                ),
              ),
              // Texto com a cor do texto
              const Text(
                "Fiado",
                style: TextStyle(
                    fontSize: 32.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold, // Cor do texto
                    fontFamily: 'Demi'),
              ),
            ],
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.email)
            .collection('fiado')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const FittedBox(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            ); // Exibe um indicador de carregamento enquanto os dados são buscados.
          }

          final docs = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Número de colunas desejado
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              try {
                final documento = docs[index];
                final nomeDoDocumento = documento.id;
                final catchDados = documento.data();
                final valor = double.parse(catchDados["valor"].toString());

                return FutureBuilder(
                    future: cardWidget(
                      catchDados["nome"].toString(),
                      catchDados["data"].toString(),
                      valor,
                      catchDados["telefone"].toString(),
                      context,
                      widget.email,
                      nomeDoDocumento,
                      catchDados['produtos'],
                      catchDados['endereco'],
                      catchDados['dataCompra'],
                      catchDados['complemento'],
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const FittedBox(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Erro: ${snapshot.error}');
                      } else {
                        // Retorna o widget resultante da função cardWidget
                        return snapshot.data ?? const SizedBox();
                      }
                    });
              } catch (e) {
                MyWidgetPadrao.showErrorDialog(context);
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
