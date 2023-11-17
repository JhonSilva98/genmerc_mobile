import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genmerc_mobile/widgetPadrao/padrao.dart';
import 'package:intl/date_symbol_data_local.dart';

class Vendas extends StatefulWidget {
  final String email;
  const Vendas({super.key, required this.email});

  @override
  State<Vendas> createState() => _VendasState();
}

class _VendasState extends State<Vendas> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _mes = 0;
  int _ano = 0;
  bool whatch = false;
  double subtotal = 0.0;
  String dateNameMes = "";
  MyWidgetPadrao funcionWidget = MyWidgetPadrao();
  @override
  void initState() {
    super.initState();
    logicInit(context);
  }

  Future<void> logicInit(contextFinal) async {
    final dat = DateTime.now();
    _mes = dat.month;
    _ano = dat.year;
    try {
      initializeDateFormatting('pt_BR');
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.email)
          .collection('vendas')
          .doc("$_ano")
          .collection('mes')
          .doc('$_mes')
          .collection('dia')
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          // A coleção existe e possui pelo menos um documento.
          double valorFinal = 0.0;

          // Iterar pelos documentos e somar os valores ao subtotal
          for (var document in querySnapshot.docs) {
            // Suponha que os valores que você deseja somar estão em um campo chamado "valor"
            double valor = double.parse(document['valor']
                .toString()); // Use o valor padrão 0.0 se o campo não existir

            valorFinal += valor;
          }

          subtotal = 0.0;
          setState(() {
            subtotal += valorFinal;
            dateNameMes = funcionWidget.obterNomeDoMes(_mes);
            whatch = true;
          });
          FocusScope.of(contextFinal).unfocus();
        } else {
          // A coleção não existe ou está vazia.
          setState(() {
            setState(() {
              whatch = false;
              subtotal = 0.0;
            });
          });
          MyWidgetPadrao.showErrorDialogBancoDados(contextFinal);
        }
      });
    } catch (e) {
      MyWidgetPadrao.showErrorDialog(contextFinal);
    }
  }

  Future<void> logicBUTTONSearch(contextFinal) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Faça algo com os valores dos números inteiros.

      try {
        await initializeDateFormatting('pt_BR');
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.email)
            .collection('vendas')
            .doc("$_ano")
            .collection('mes')
            .doc('$_mes')
            .collection('dia')
            .get()
            .then((QuerySnapshot querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            // A coleção existe e possui pelo menos um documento.
            double valorFinal = 0.0;

            // Iterar pelos documentos e somar os valores ao subtotal
            for (var document in querySnapshot.docs) {
              // Suponha que os valores que você deseja somar estão em um campo chamado "valor"
              double valor = double.parse(document['valor']
                  .toString()); // Use o valor padrão 0.0 se o campo não existir

              valorFinal += valor;
            }

            subtotal = 0.0;
            setState(() {
              subtotal += valorFinal;
              dateNameMes = funcionWidget.obterNomeDoMes(_mes);
              whatch = true;
            });
            FocusScope.of(contextFinal).unfocus();
          } else {
            // A coleção não existe ou está vazia.
            setState(() {
              setState(() {
                whatch = false;
                subtotal = 0.0;
              });
            });
            MyWidgetPadrao.showErrorDialogBancoDados(contextFinal);
          }
        });
      } catch (e) {
        MyWidgetPadrao.showErrorDialog(contextFinal);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                "Vendas no Mês",
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
                "Vendas no Mês",
                style: TextStyle(
                  fontSize: 32.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold, // Cor do texto
                  fontFamily: 'Demi',
                ),
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
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 15.0,
                            offset: Offset(0.0, 0.75),
                          ),
                        ],
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromARGB(255, 70, 160, 233),
                            Color.fromARGB(255, 42, 194, 194)
                          ],
                        ),
                      ),
                      width: double.infinity,
                      child: Flex(
                        direction: Axis.vertical,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (whatch)
                            Flexible(
                              flex: 1,
                              child: FittedBox(
                                child: Text(
                                  dateNameMes.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          const Flexible(
                            flex: 1,
                            child: SizedBox(
                              height: 10,
                            ),
                          ),
                          Flexible(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                              ),
                              child: Form(
                                key: _formKey,
                                child: Flex(
                                  direction: Axis.horizontal,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        maxLength:
                                            2, // Define o número máximo de caracteres permitidos
                                        maxLengthEnforcement: MaxLengthEnforcement
                                            .enforced, // Garante que o limite seja aplicado
                                        scrollPadding: const EdgeInsets.all(8),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 30,
                                        ),
                                        decoration: const InputDecoration(
                                          labelStyle: TextStyle(
                                            fontSize: 20,
                                          ),
                                          labelText: 'Mês',
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                          ),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.never,
                                          contentPadding: EdgeInsets.only(
                                            left: 8,
                                            bottom: 16.0,
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                        // Define o teclado para números
                                        validator: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Por favor, insira o primeiro número.';
                                          }
                                          if (int.tryParse(value) == null) {
                                            return 'Por favor, insira um número válido.';
                                          }
                                          return null;
                                        },
                                        onSaved: (String? value) {
                                          _mes = int.parse(value!);
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        maxLength:
                                            4, // Define o número máximo de caracteres permitidos
                                        maxLengthEnforcement: MaxLengthEnforcement
                                            .enforced, // Garante que o limite seja aplicado
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 30,
                                        ),
                                        decoration: const InputDecoration(
                                          labelStyle: TextStyle(
                                            fontSize: 20,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                10.0,
                                              ),
                                            ),
                                          ),
                                          labelText: 'Ano',
                                          filled: true,
                                          fillColor: Colors.white,
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.never,
                                          contentPadding: EdgeInsets.only(
                                            left: 8,
                                            bottom: 16.0,
                                          ),
                                        ),
                                        keyboardType: TextInputType
                                            .number, // Define o teclado para números
                                        validator: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Por favor, insira o segundo número.';
                                          }
                                          if (int.tryParse(value) == null) {
                                            return 'Por favor, insira um número válido.';
                                          }
                                          return null;
                                        },
                                        onSaved: (String? value) {
                                          _ano = int.parse(value!);
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: const CircleBorder(),
                                          backgroundColor: Colors
                                              .white, // Define a forma circular
                                          padding: const EdgeInsets.all(
                                            16.0,
                                          ), // Cor de fundo do botão
                                        ),
                                        child: Icon(
                                          Icons.navigate_next_rounded,
                                          color: Colors.blue[300],
                                        ),
                                        onPressed: () async {
                                          await logicBUTTONSearch(context);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Flexible(
                            flex: 1,
                            child: SizedBox(
                              height: 10,
                            ),
                          ),
                          if (whatch)
                            Flexible(
                              flex: 2,
                              child: FittedBox(
                                child: Text(
                                  "R\$ ${subtotal.toStringAsFixed(2).replaceAll('.', ',')}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Demi",
                                  ),
                                ),
                              ),
                            ),
                          if (whatch)
                            const Flexible(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: FittedBox(
                                  child: Text(
                                    "Receita do mês",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Demi",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (whatch)
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.email)
                              .collection('vendas')
                              .doc("$_ano")
                              .collection('mes')
                              .doc('$_mes')
                              .collection('dia')
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
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4, // Número de colunas desejado
                              ),
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final documento = docs[index];
                                final nomeDoDocumento = documento.id;
                                final catchDados = documento.data();
                                final dados = double.parse(
                                  catchDados["valor"].toString(),
                                );
                                return funcionWidget.ticket(
                                  nomeDoDocumento,
                                  dados,
                                  dateNameMes,
                                  _ano,
                                  _mes,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
