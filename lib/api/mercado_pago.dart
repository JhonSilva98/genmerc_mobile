import 'dart:convert';
import 'package:genmerc_mobile/firebase/banco_dados.dart';
import 'package:http/http.dart' as http;

class MercadoPagoLink {
  BancoDadosFirebase bdFirebase = BancoDadosFirebase();

  Future<String> criarLinkPagamento(
    double valor,
    String email,
  ) async {
    const String url = 'https://api.mercadopago.com/checkout/preferences';
    final dados = await bdFirebase.getNomeFoto(email);
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': dados['key'], // Substitua pelo seu token do Mercado Pago
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
      // print(response.statusCode);
      throw Exception('Falha ao criar o link de pagamento');
    }
  }

  Future<String> verificarPagamento(String idPagamento) async {
    final String url = 'https://api.mercadopago.com/v1/payments/$idPagamento';
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer TEST-8350097031094089-111014-9d23861858b2443199869d721c239652-210252592',
    };

    final http.Response response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String statusPagamento = responseData['status'];
      if (statusPagamento == 'approved') {
        //O pagamento foi aprovado!
        return 'approved';
      } else if (statusPagamento == 'pending') {
        return 'O pagamento está pendente.';
      } else if (statusPagamento == 'in_process') {
        return 'O pagamento está em processamento.';
      } else if (statusPagamento == 'rejected') {
        return 'O pagamento foi rejeitado.';
      } else if (statusPagamento == 'cancelled') {
        return 'O pagamento foi cancelado.';
      } else {
        return 'O status do pagamento é desconhecido.';
      }
    } else {
      //print(response.statusCode);
      throw Exception('Falha ao verificar o status do pagamento');
    }
  }
}
