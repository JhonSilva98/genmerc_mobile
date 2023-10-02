import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GestaoProdutos extends StatefulWidget {
  final String email;
  const GestaoProdutos({super.key, required this.email});

  @override
  State<GestaoProdutos> createState() => _GestaoProdutosState();
}

class _GestaoProdutosState extends State<GestaoProdutos> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> allDocuments = [];
  List<QueryDocumentSnapshot> filteredDocuments = [];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  ImageProvider _loadImage(String imagePath) {
    if (imagePath.isEmpty || imagePath == '') {
      return const NetworkImage(
          'https://firebasestorage.googleapis.com/v0/b/genmerc-mobile.appspot.com/o/ideogram.jpeg?alt=media&token=b2f40124-eb43-4860-a600-6e3eb43dd6d1&_gl=1*1yyx08k*_ga*MTYxMDM5MTE1NC4xNjkzMzk4MDk0*_ga_CW55HF8NVT*MTY5NTkyODM0OC43NC4xLjE2OTU5MzA0MDcuNDcuMC4w');
    } else {
      return NetworkImage(imagePath);
    }
  }

  void _loadDocuments() async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(widget.email)
        .collection('bancodados')
        .get();
    setState(() {
      allDocuments = querySnapshot.docs;
      filteredDocuments = allDocuments;
    });
  }

  void _filterDocuments(String query) {
    setState(() {
      filteredDocuments = allDocuments.where((document) {
        final title = document['nome'] as String;
        return title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: _filterDocuments,
          decoration: const InputDecoration(
            hintText: 'Pesquisar...',
          ),
        ),
      ),
      body: GridView.builder(
        itemCount: filteredDocuments.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (BuildContext context, int index) {
          final document = filteredDocuments[index];
          return Card(
              elevation: 5,
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ), // Define o raio da borda
                          child: Image.network(
                            document['image'],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                'https://firebasestorage.googleapis.com/v0/b/genmerc-mobile.appspot.com/o/ideogram.jpeg?alt=media&token=b2f40124-eb43-4860-a600-6e3eb43dd6d1&_gl=1*1yyx08k*_ga*MTYxMDM5MTE1NC4xNjkzMzk4MDk0*_ga_CW55HF8NVT*MTY5NTkyODM0OC43NC4xLjE2OTU5MzA0MDcuNDcuMC4w',
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(2, 2),
                                    blurRadius: 5,
                                  ),
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(-2, 2),
                                    blurRadius: 5,
                                  ),
                                ],
                              )),
                        )
                      ],
                    ),
                  ),
                  const Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("data"),
                      Text("data"),
                    ],
                  ))
                ],
              ));
        },
      ),
    );
  }
}

/*ListTile(
              leading: CircleAvatar(
                backgroundImage: _loadImage(document['image'].toString()),
                child: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 5,
                      ),
                      Shadow(
                        color: Colors.red,
                        offset: Offset(-2, 2),
                        blurRadius: 5,
                      ),
                    ],
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ),
              title: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Flexible(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            document['nome'].toString().toUpperCase(),
                            //softWrap: false,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Flexible(
                        flex: 1,
                        child: FittedBox(
                          child: Icon(Icons.edit_square),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              trailing: TextButton(
                onPressed: () {},
                style: const ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(Colors.green)),
                child: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: FittedBox(
                          child: Text(
                            'R\$ ${document['valorUnit'].toString().replaceAll('.', ',')}',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Flexible(
                        flex: 1,
                        child: FittedBox(
                          child: Icon(Icons.edit_square),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),*/
