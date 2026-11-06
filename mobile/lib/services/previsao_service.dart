import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'sessao_expirada_exception.dart';

class PrevisaoService {
  final http.Client _client;

  PrevisaoService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> classificarEstresse({
    required Map<String, int> respostas,
    required String token,
  }) async {
    final http.Response resposta;

    try {
      resposta = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/prever'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(respostas),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw Exception(
        'Não foi possível conectar ao servidor. Verifique sua conexão.',
      );
    }

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
      throw const SessaoExpiradaException();
    }

    if (resposta.statusCode == 422) {
      throw Exception('As respostas do questionário são inválidas.');
    }

    throw Exception(
      'Erro ao classificar o estresse. '
      'Código: ${resposta.statusCode}',
    );
  }
}
