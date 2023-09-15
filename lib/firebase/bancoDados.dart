import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BancoDadosFirebase {
  FirebaseStorage storageReference = FirebaseStorage.instance;
  final ImagePicker picker = ImagePicker();
  XFile? pathImage;
  String imageUrl = '';
  TaskSnapshot? photeRemov;

  Future<Map<String, dynamic>> getNomeFoto(String documentId) async {
    try {
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('users')
          .doc(documentId)
          .get();

      // O documento existe, você pode acessar os dados dentro dele
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      //String nome = data['nome'];
      //String fotoUrl = data['foto'];
      return data;

      // Faça o que você precisa com o nome e a foto aqui
    } catch (e) {
      return {
        'nome': 'genmarc',
        'foto':
            'https://img.freepik.com/vetores-gratis/desenho-de-carrinho-e-construcao-de-loja_138676-2085.jpg?w=2000',
      };
    }
  }

  // Função para verificar a existência de um documento
  Future<bool> isDocumentExist(String documentId) async {
    final DocumentSnapshot document = await FirebaseFirestore.instance
        .collection('users') // Substitua 'users' pelo nome da sua coleção
        .doc(
            documentId) // Substitua 'documentId' pelo ID do documento que deseja verificar
        .get();

    // Verifique se o documento existe ou não
    return document.exists;
  }

  //criar dado bd caso nao exista
  Future<void> setDocumentInCollection(String document, String nome) async {
    try {
      // Crie uma referência para a coleção e especifique o nome do documento
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('users').doc(document);

      // Crie um mapa com os dados que você deseja adicionar ao documento
      Map<String, dynamic> data = {
        'nome': nome,
        'foto': pathImage == null
            ? 'https://img.freepik.com/vetores-gratis/desenho-de-carrinho-e-construcao-de-loja_138676-2085.jpg?w=2000'
            : imageUrl,
        // Adicione outros campos e valores conforme necessário
      };

      // Use o método `set()` para criar um novo documento na coleção ou substituir um documento existente com os dados especificados
      await documentReference.set(data);

      // Subcoleção 1
      CollectionReference subCollection1 =
          documentReference.collection('fiado');
      Map<String, dynamic> dataSubCollection1 = {
        'campo1': 'valor1',
        'campo2': 'valor2',
        // Adicione outros campos e valores conforme necessário para a primeira subcoleção
      };
      await subCollection1.add(dataSubCollection1);

// Subcoleção 2
      CollectionReference subCollection2 =
          documentReference.collection('empresa');
      Map<String, dynamic> dataSubCollection2 = {
        'campo3': 'valor3',
        'campo4': 'valor4',
        // Adicione outros campos e valores conforme necessário para a segunda subcoleção
      };
      await subCollection2.add(dataSubCollection2);

// Subcoleção 3
      CollectionReference subCollection3 =
          documentReference.collection('bancodados');
      Map<String, dynamic> dataSubCollection3 = {
        'campo5': 'valor5',
        'campo6': 'valor6',
        // Adicione outros campos e valores conforme necessário para a terceira subcoleção
      };
      await subCollection3.add(dataSubCollection3);

      print('Documento criado ou atualizado com sucesso.');
    } catch (e) {
      print('Erro ao criar ou atualizar o documento: $e');
    }
  }

  // pegar foto e usando a funcao uploadImageToStorageAndFirestore();
  Future<void> getImageFromGallery() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Aqui você pode usar a variável 'image' para acessar a imagem selecionada
      // Ela contém informações sobre o arquivo e pode ser usada para exibição ou upload.
      // Por exemplo: File(image.path)
      pathImage = image;
      print('pegou');
    } else {
      // O usuário cancelou a seleção da imagem
      pathImage = null;
    }
    await uploadImageToStorageAndFirestore();
  }

  //enviar a foto firebase e pegar o link
  Future<void> uploadImageToStorageAndFirestore() async {
    if (pathImage != null) {
      File file = File(pathImage!.path);
      try {
        final foto = await storageReference
            .ref('${DateTime.now().millisecondsSinceEpoch}.jpg')
            .putFile(file);

        // Obter o URL da imagem após o upload
        imageUrl = await foto.ref.getDownloadURL();
        photeRemov = foto;
      } catch (e) {
        print('O erro foi $e');
      }
    }
  }

  Future<void> deletePhoto() async {
    if (imageUrl != '') {
      await photeRemov!.ref.delete();
    }
  }
}
