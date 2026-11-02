
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class PrevisaoService {
  Future<Map<String, dynamic>> classificarEstresse({
    required Map<String, int> respostas,
    required String token,
  }) async {
    final resposta = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/prever'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(respostas),
    ).timeout(const Duration(seconds: 30));

    if (resposta.statusCode == 200) {
      final dados = jsonDecode(resposta.body);

      if (dados is! Map<String, dynamic> ||
          dados['nivel_estresse'] is! int ||
          dados['classificacao'] is! String) {
        throw Exception('Resposta inesperada da API.');
      }

      return dados;
    }

    if (resposta.statusCode == 401) {
      throw Exception(
        'Sua sessão expirou. Faça login novamente.',
      );
    }

    if (resposta.statusCode == 422) {
      throw Exception(
        'As respostas do questionário são inválidas.',
      );
    }

    throw Exception(
      'Erro ao classificar o estresse. '
      'Código: ${resposta.statusCode}',
    );
  }
}
