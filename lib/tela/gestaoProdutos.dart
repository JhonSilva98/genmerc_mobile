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
      body: ListView.builder(
        itemCount: filteredDocuments.length,
        itemBuilder: (BuildContext context, int index) {
          final document = filteredDocuments[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: _loadImage(document['image'].toString()),
              child: Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ),
            ),
            title: Text(document['nome'] as String),
            subtitle: Text('O valor é ${document['valorUnit']}'),
          );
        },
      ),
    );
  }
}
