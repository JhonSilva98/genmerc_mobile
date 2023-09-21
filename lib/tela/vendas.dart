import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:genmerc_mobile/widgetPadrao/padrao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_ticket/flutter_ticket.dart';

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
  String obterNomeDoMes(int numeroDoMes) {
    final DateTime data = DateTime(1, numeroDoMes);
    return DateFormat('MMMM', 'pt_BR').format(data);
  }

  String obterNomeDoDiaDaSemana(int ano, int mes, int dia) {
    final DateTime data = DateTime(ano, mes, dia);
    String nomeDoDia = DateFormat('EEEE', 'pt_BR').format(data);
    return nomeDoDia;
  }

  Widget cardPersonalite(String nomeDoDocumento, double dados) {
    return Card(
      elevation: 10,
      shadowColor: Colors.blue,
      color: const Color(0XFF0f172b),
      child: Flex(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //crossAxisAlignment: CrossAxisAlignment.center,
        direction: Axis.vertical,
        children: [
          Expanded(
            flex: 2,
            child: FittedBox(
              child: Text(
                obterNomeDoDiaDaSemana(_ano, _mes, int.parse(nomeDoDocumento)),
                style: const TextStyle(
                    color: Color(0XFFce5355), fontSize: 30, fontFamily: 'Demi'),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: FittedBox(
              child: Text(
                nomeDoDocumento,
                style: const TextStyle(
                    color: Colors.black, fontSize: 50, fontFamily: 'Demi'),
              ),
            ),
          ),
          const Divider(
            color: Colors.black,
          ),
          Expanded(
            flex: 2,
            child: FittedBox(
              child: Text(
                "R\$ ${dados.toString().replaceAll('.', ',')}",
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 25,
                  fontFamily: 'Demi',
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget ticket(String nomeDoDocumento, double dados, String dateNameMes) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 2,
        right: 2,
      ),
      child: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            flex: 1,
            child: Ticket(
              innerRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0)),
              outerRadius: const BorderRadius.all(Radius.circular(10.0)),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, 4.0),
                  blurRadius: 2.0,
                  spreadRadius: 2.0,
                  color: Color.fromRGBO(196, 196, 196, .76),
                )
              ],
              child: Container(
                color: Colors.white,
                width: 300,
                height: 70,
                child: Flex(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  direction: Axis.vertical,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 5,
                            top: 5,
                          ),
                          child: FittedBox(
                            child: Text(
                              dateNameMes,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: FittedBox(
                          child: Text(
                            nomeDoDocumento,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 50,
                                fontFamily: 'Demi'),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Ticket(
              innerRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0)),
              outerRadius: const BorderRadius.all(Radius.circular(10.0)),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, 4),
                  blurRadius: 2.0,
                  spreadRadius: 2.0,
                  color: Color.fromRGBO(196, 196, 196, .76),
                )
              ],
              child: Container(
                color: Colors.white,
                width: 300,
                height: 100,
                child: Flex(
                  direction: Axis.vertical,
                  //mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    //const Divider(),
                    Expanded(
                      flex: 1,
                      child: FittedBox(
                        child: Text(
                          obterNomeDoDiaDaSemana(
                              _ano, _mes, int.parse(nomeDoDocumento)),
                          style: const TextStyle(
                              color: Color(0XFF5e4a9c),
                              fontSize: 30,
                              fontFamily: 'Demi'),
                        ),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      flex: 2,
                      child: FittedBox(
                        child: Text(
                          "R\$ ${dados.toString().replaceAll('.', ',')}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 25,
                            fontFamily: 'Demi',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
                Colors.white.withOpacity(0.15), // Ajuste a opacidade aqui
                BlendMode
                    .dstATop, // Define o modo de mesclagem para mesclar com a cor de fundo
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Center(
          child: Stack(
            children: [
              // Texto com bordas brancas simuladas
              Text(
                "Vendas do Mês",
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
                "Vendas do Mês",
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
            )),
      ),
      body: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
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
                          dateNameMes,
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                  ),
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
                                  backgroundColor:
                                      Colors.white, // Define a forma circular
                                  padding: const EdgeInsets.all(
                                      16.0), // Cor de fundo do botão
                                ),
                                child: Icon(
                                  Icons.navigate_next_rounded,
                                  color: Colors.blue[300],
                                ),
                                onPressed: () async {
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
                                          for (var document
                                              in querySnapshot.docs) {
                                            // Suponha que os valores que você deseja somar estão em um campo chamado "valor"
                                            double valor = double.parse(document[
                                                    'valor']
                                                .toString()); // Use o valor padrão 0.0 se o campo não existir

                                            valorFinal += valor;
                                          }

                                          subtotal = 0.0;
                                          setState(() {
                                            subtotal += valorFinal;
                                            dateNameMes = obterNomeDoMes(_mes);
                                            print(dateNameMes);
                                            whatch = true;
                                          });
                                          FocusScope.of(context).unfocus();
                                          print('A coleção existe.');
                                        } else {
                                          // A coleção não existe ou está vazia.
                                          setState(() {
                                            setState(() {
                                              whatch = false;
                                              subtotal = 0.0;
                                            });
                                          });
                                          MyWidgetPadrao
                                              .showErrorDialogBancoDados(
                                                  context);
                                        }
                                      });
                                    } catch (e) {
                                      MyWidgetPadrao.showErrorDialog(context);
                                    }
                                  }
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
                          "R\$ ${subtotal.toString().replaceAll('.', ',')}",
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
                            "Vendido no mês",
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
                      return const CircularProgressIndicator(); // Exibe um indicador de carregamento enquanto os dados são buscados.
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
                        return ticket(nomeDoDocumento, dados, dateNameMes);
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
