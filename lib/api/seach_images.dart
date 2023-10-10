import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class ImageUploaderService {
  //----------------para aprender-------------
  //https://rptwsthi.medium.com/using-google-custom-search-api-bbb2fb080585
  //---------------------------------------------
  /*final String apiKey =
      'AIzaSyCOBgJqSi69QIjkxSQyV9lbK5Zir_c5z-0';*/ // Substitua pela sua chave de API do Google

  Future<String> searchAndUploadImage(String query, String email) async {
    String linkFinala = '';
    String imageUrlFinal = '';
    String textoSemEspacos = query.replaceAll(' ', '');
    final url =
        'https://www.googleapis.com/customsearch/v1?q=$textoSemEspacos&key=AIzaSyCOBgJqSi69QIjkxSQyV9lbK5Zir_c5z-0&cx=23c6de77b49344894';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.containsKey('items')) {
        final items = data['items'] as List<dynamic>;
        if (items.isNotEmpty) {
          final firstResult = items[0];
          try {
            final pagemap = firstResult['pagemap'] as Map<String, dynamic>;
            if (pagemap.containsKey('product') && pagemap.isNotEmpty) {
              final product = pagemap['product'] as List<dynamic>;
              final productoinicial = product[0] as Map<String, dynamic>;
              if (productoinicial.containsKey('image')) {
                final imageFinal = productoinicial['image'] ?? '';
                linkFinala = imageFinal;
              } else {
                return '';
              }
            } else if (pagemap.containsKey('metatags') && pagemap.isNotEmpty) {
              final metatags = pagemap['metatags'] as List<dynamic>;
              final metatagsinicial = metatags[0] as Map<String, dynamic>;
              if (metatagsinicial.containsKey('og:image')) {
                final imageFinal = metatagsinicial['og:image'] ?? '';
                linkFinala = imageFinal;
              } else {
                return '';
              }
            } else {
              return '';
            }
          } catch (e) {
            return '';
          }
        } else {
          return '';
        }
      } else {
        return '';
      }
    } else {
      return '';
    }
    final responseFinal = await http.get(Uri.parse(linkFinala));

    if (responseFinal.statusCode == 200) {
      final imageBytes = responseFinal.bodyBytes;

      // Inicialize o Firebase (certifique-se de que o Firebase já esteja configurado no seu projeto)
      await Firebase.initializeApp();

      // Obtenha uma referência para o Firebase Storage
      final storage = FirebaseStorage.instance;
      //final storageRef = storage.ref().child('$query.jpg');
      //final foto = await storage.ref().putData(imageBytes);
      final storageRef = storage
          .ref()
          .child('$email/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Faça o upload da imagem para o Firebase Storage
      await storageRef.putData(imageBytes);

      imageUrlFinal = await storageRef.getDownloadURL();

      return imageUrlFinal;
    } else {
      return '';
    }
  }

  //Your API key Pexels API: 9NsA29l5o9bTaKRLF69VCv1x1TjI1wEOuzhGzBJv10bZ5IQUAV5kVoGc
}
