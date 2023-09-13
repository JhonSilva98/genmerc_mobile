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
        'foto': imageUrl,
        // Adicione outros campos e valores conforme necessário
      };

      // Use o método `set()` para criar um novo documento na coleção ou substituir um documento existente com os dados especificados
      await documentReference.set(data);

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
      print('não pegou');
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
    } else {
      imageUrl =
          'https://img.freepik.com/vetores-gratis/desenho-de-carrinho-e-construcao-de-loja_138676-2085.jpg?w=2000';
    }
  }

  Future<void> deletePhoto() async {
    await photeRemov!.ref.delete();
  }
}
