import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'sessao_expirada_exception.dart';

class HistoricoService {
  final http.Client _client;

  HistoricoService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Map<String, dynamic>>> consultarHistorico({
    required String token,
  }) async {
    final http.Response resposta;

    try {
      // Consultar o histórico do estudante autenticado
      resposta = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/historico'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
    } catch (_) {
      throw Exception(
        'Não foi possível conectar ao servidor. Verifique sua conexão.',
      );
    }

    // Consulta realizada com sucesso
    if (resposta.statusCode == 200) {
      final dados = jsonDecode(resposta.body);

      if (dados is! Map<String, dynamic> || dados['avaliacoes'] is! List) {
        throw Exception('Resposta inesperada da API.');
      }

      final avaliacoes = dados['avaliacoes'] as List;

      return avaliacoes.map((avaliacao) {
        return Map<String, dynamic>.from(avaliacao as Map);
      }).toList();
    }

    // Token inválido ou expirado
    if (resposta.statusCode == 401) {
      throw const SessaoExpiradaException();
    }

    throw Exception(
      'Não foi possível consultar o histórico. '
      'Código: ${resposta.statusCode}',
    );
  }
}
