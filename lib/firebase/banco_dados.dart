import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:genmerc_mobile/widgetPadrao/padrao.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

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
            'https://firebasestorage.googleapis.com/v0/b/genmerc-mobile.appspot.com/o/Administrativo%2Fideogram.jpeg?alt=media&token=4d0a8e07-8977-4ed5-9733-872585aab3e9&_gl=1*16v9f5f*_ga*MTQ3OTA0NDM3Ny4xNjk2ODU0MzAx*_ga_CW55HF8NVT*MTY5NjkzNzg0My44OS4xLjE2OTY5Mzc5OTguMi4wLjA.',
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

  Future<void> deleteImageBD(String downloadUrl) async {
    try {
      // Crie uma referência para a imagem no Firebase Storage usando o link de download.
      Reference storageReference =
          FirebaseStorage.instance.refFromURL(downloadUrl);

      // Apague a imagem.
      await storageReference.delete();
    } catch (e) {
      // Capture e ignore qualquer exceção que ocorra durante a exclusão da imagem.
    }
    // Continue com outros processos aqui, pois o erro foi tratado e ignorado.
  }

  //criar dado bd caso nao exista
  Future<void> setDocumentInCollection(String document, String nome) async {
    // Crie uma referência para a coleção e especifique o nome do documento
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('users').doc(document);

    // Crie um mapa com os dados que você deseja adicionar ao documento
    Map<String, dynamic> data = {
      'nome': nome,
      'foto': pathImage == null
          ? 'https://firebasestorage.googleapis.com/v0/b/genmerc-mobile.appspot.com/o/Administrativo%2Fideogram.jpeg?alt=media&token=4d0a8e07-8977-4ed5-9733-872585aab3e9&_gl=1*16v9f5f*_ga*MTQ3OTA0NDM3Ny4xNjk2ODU0MzAx*_ga_CW55HF8NVT*MTY5NjkzNzg0My44OS4xLjE2OTY5Mzc5OTguMi4wLjA.'
          : imageUrl,
      // Adicione outros campos e valores conforme necessário
    };

    // Use o método `set()` para criar um novo documento na coleção ou substituir um documento existente com os dados especificados
    await documentReference.set(data);
  }

  // pegar foto e usando a funcao uploadImageToStorageAndFirestore();
  Future<void> getImageFromGallery(String email) async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Aqui você pode usar a variável 'image' para acessar a imagem selecionada
      // Ela contém informações sobre o arquivo e pode ser usada para exibição ou upload.
      // Por exemplo: File(image.path)
      pathImage = image;
      await uploadImageToStorageAndFirestore(email);
    } else {
      // O usuário cancelou a seleção da imagem
      pathImage = null;
    }
  }

  Future<void> getImageFromCamera(String email) async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      // Aqui você pode usar a variável 'image' para acessar a imagem selecionada
      // Ela contém informações sobre o arquivo e pode ser usada para exibição ou upload.
      // Por exemplo: File(image.path)

      pathImage = image;
      await uploadImageToStorageAndFirestore(email);
    } else {
      // O usuário cancelou a seleção da imagem
      pathImage = null;
    }
  }

  Future<void> addDadosManualmente(
    String email,
    String documentoID,
    String nome,
    double valorUnit,
    String image,
  ) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    if (documentoID.length > 3 || documentoID != '') {
      await firestore
          .collection('users')
          .doc(email)
          .collection('bancodados')
          .doc(documentoID)
          .set({
        'nome': nome,
        'valorUnit': valorUnit,
        'image': image,
      });
    } else {
      await firestore
          .collection('users')
          .doc(email)
          .collection('bancodados')
          .doc()
          .set({
        'nome': nome,
        'valorUnit': valorUnit,
        'image': image,
      });
    }
  }

  Future<XFile?> resizeAndReturnXFile(XFile pickedFile) async {
    // Obtém os bytes da imagem original
    List<int> imageBytes = await pickedFile.readAsBytes();

    // Verifica o tamanho do arquivo da imagem original em bytes
    int fileSizeInBytes = imageBytes.length;

    // Verifica se o tamanho do arquivo é maior que 1 MB (1 MB = 1048576 bytes)
    if (fileSizeInBytes > 1048576) {
      // Converte os bytes em uma imagem
      img.Image originalImage =
          img.decodeImage(Uint8List.fromList(imageBytes))!;

      // Calcula as novas dimensões mantendo 50% da resolução original
      int novaLargura = (originalImage.width * 0.5).round();
      int novaAltura = (originalImage.height * 0.5).round();

      // Redimensiona a imagem
      img.Image resizedImage =
          img.copyResize(originalImage, width: novaLargura, height: novaAltura);

      // Reduz a qualidade da imagem para diminuir o tamanho do arquivo
      List<int> resizedImageBytes = img.encodeJpg(resizedImage,
          quality: 50); // Ajuste o valor da qualidade conforme necessário

      // Cria um novo arquivo temporário com os dados da imagem redimensionada e comprimida
      File resizedFile = File(pickedFile.path);
      await resizedFile.writeAsBytes(resizedImageBytes);

      // Retorna a imagem redimensionada e comprimida como XFile
      return XFile(resizedFile.path);
    } else {
      // Se o arquivo for menor ou igual a 1 MB, retorna a imagem original sem redimensionar
      return pickedFile;
    }
  }

  //enviar a foto firebase e pegar o link
  Future<void> uploadImageToStorageAndFirestore(String email) async {
    if (pathImage != null) {
      pathImage = await resizeAndReturnXFile(pathImage!);
      File file = File(pathImage!.path);

      final foto = await storageReference
          .ref('$email/${DateTime.now().millisecondsSinceEpoch}.jpg')
          .putFile(file);

      // Obter o URL da imagem após o upload
      imageUrl = await foto.ref.getDownloadURL();
      photeRemov = foto;
    }
  }

  Future<void> deletePhoto() async {
    if (imageUrl != '') {
      await photeRemov!.ref.delete();
    }
  }

  Future<void> cadastrarFiado(context, String email, String nome, double valor,
      String telefone, String data, List produto) async {
    var documentReferenceFiado = FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('fiado');

    // Use o método `delete` para apagar o documento
    try {
      await documentReferenceFiado.add({
        'nome': nome,
        'data': data,
        'valor': valor,
        'telefone': telefone,
        'produtos': produto,
      });
    } catch (e) {
      MyWidgetPadrao.showErrorDialog(context);
    }
  }

  Future<void> setVendasDeleteFiadoDoc(
    String email,
    String docFiado,
    double valorDivida,
    context,
  ) async {
    try {
      DateTime data = DateTime.now();
      var documentReference = FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('vendas')
          .doc(data.year.toString())
          .collection('mes')
          .doc(data.month.toString())
          .collection('dia')
          .doc(data.day.toString())
          .get();
      documentReference.then((documentSnapshot) {
        var documentReferenceSet = FirebaseFirestore.instance
            .collection('users')
            .doc(email)
            .collection('vendas')
            .doc(data.year.toString())
            .collection('mes')
            .doc(data.month.toString())
            .collection('dia')
            .doc(data.day.toString());
        if (documentSnapshot.exists) {
          // O documento existe, você pode acessar seus dados assim:
          var dados = documentSnapshot.data();

          // Agora você pode acessar os campos do documento como se fossem um mapa.
          // Por exemplo, se houver um campo chamado "campo1", você pode acessá-lo assim:
          double valor = double.parse(dados!['valor'].toString());

          double newValor = valorDivida + valor;

          // Suponha que 'novoValor' seja o novo valor que você deseja definir no documento.
          var novoValor = {
            'valor': newValor, // Exemplo de outro campo com um novo valor.
          };

          documentReferenceSet.set(novoValor).then((_) {
            // Documento atualizado com sucesso.
          }).catchError((error) {
            // Lidar com erros, se houver algum.
          });
        } else {
          // O documento não existe.
          var novoValor = {
            'valor': valorDivida, // Exemplo de outro campo com um novo valor.
          };

          documentReferenceSet.set(novoValor).then((_) {
            // Documento atualizado com sucesso.
          }).catchError((error) {
            // Lidar com erros, se houver algum.
          });
        }
      }).catchError((error) {
        // Lidar com erros, se houver algum.
      });

      var documentReferenceFiado = FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('fiado')
          .doc(docFiado);

      // Use o método `delete` para apagar o documento
      await documentReferenceFiado.delete();
    } catch (e) {
      MyWidgetPadrao.showErrorDialog(context);
    }
  }

  Future<void> updateReagendar(
    String email,
    String docFiado,
    String data,
    context,
  ) async {
    try {
      var documentReferenceFiado = FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('fiado')
          .doc(docFiado);

      // Use o método `delete` para apagar o documento
      await documentReferenceFiado.update({'data': data});
    } catch (e) {
      MyWidgetPadrao.showErrorDialog(context);
    }
  }

  Future<void> deleteFiado(
    String email,
    String docFiado,
    context,
  ) async {
    try {
      var documentReferenceFiado = FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('fiado')
          .doc(docFiado);

      // Use o método `delete` para apagar o documento
      await documentReferenceFiado.delete();
    } catch (e) {
      MyWidgetPadrao.showErrorDialog(context);
    }
  }

  Future<List<QueryDocumentSnapshot>> catchProducto(String email) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<QueryDocumentSnapshot> allDocuments = [];
    final querySnapshot = await firestore
        .collection('users')
        .doc(email)
        .collection('bancodados')
        .get();
    allDocuments = querySnapshot.docs;
    return allDocuments;
  }
}
