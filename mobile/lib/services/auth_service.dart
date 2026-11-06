
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class AuthService {
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> fazerLogin({
    required String email,
    required String senha,
  }) async {
    try {
      final resposta = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'senha': senha,
        }),
      ).timeout(const Duration(seconds: 15));

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);

        final token = dados['access_token'];

        if (token is! String || token.isEmpty) {
          throw Exception('Token não recebido da API.');
        }

        return token;
      }

      if (resposta.statusCode == 401) {
        throw Exception('E-mail ou senha incorretos.');
      }

      if (resposta.statusCode == 422) {
        throw Exception('Verifique os dados informados.');
      }

      throw Exception(
        'Não foi possível realizar o login. '
        'Código: ${resposta.statusCode}',
      );
    } on TimeoutException {
      throw Exception('O servidor demorou para responder. Tente novamente.');
    } on http.ClientException {
      throw Exception(
        'Não foi possível conectar ao servidor. Verifique sua conexão.',
      );
    }
  }
}
