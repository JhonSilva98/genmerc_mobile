import 'dart:convert';
import 'package:genmerc_mobile/firebase/banco_dados.dart';
import 'package:http/http.dart' as http;

BancoDadosFirebase bdFirebase = BancoDadosFirebase();

Future<String> criarLinkPagamento(
  /*String nomeProduto,*/ double valor,
  String email,
) async {
  const String url = 'https://api.mercadopago.com/checkout/preferences';
  final dados = await bdFirebase.getNomeFoto(email);
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization':
        'Bearer TEST-8350097031094089-111014-9d23861858b2443199869d721c239652-210252592', // Substitua pelo seu token do Mercado Pago
  };

  final Map<String, dynamic> requestBody = {
    'items': [
      {
        'title': dados['nome'],
        'quantity': 1,
        'currency_id': 'BRL',
        'unit_price': valor,
      },
    ],
  };

  final http.Response response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(requestBody),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final Map<String, dynamic> responseData = jsonDecode(response.body);
    final String linkPagamento = responseData['init_point'];
    return linkPagamento;
  } else {
    print(response.statusCode);
    throw Exception('Falha ao criar o link de pagamento');
  }
}
