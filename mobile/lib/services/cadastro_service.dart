import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class CadastroService {
  final http.Client _client;

  CadastroService({http.Client? client}) : _client = client ?? http.Client();

  Future<void> cadastrar({
    required String email,
    required String senha,
  }) async {
    final http.Response resposta;

    try {
      resposta = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/cadastro'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email.trim(), 'senha': senha}),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw Exception(
        'Não foi possível conectar ao servidor. Verifique sua conexão.',
      );
    }

    if (resposta.statusCode == 201) {
      return;
    }

    if (resposta.statusCode == 409) {
      throw Exception('Este e-mail já está cadastrado.');
    }

    if (resposta.statusCode == 422) {
      throw Exception('Verifique os dados informados.');
    }

    throw Exception(
      'Não foi possível criar a conta. Código: ${resposta.statusCode}',
    );
  }
}
