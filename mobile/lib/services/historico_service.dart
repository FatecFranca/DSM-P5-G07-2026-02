
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class HistoricoService {
  Future<List<Map<String, dynamic>>> consultarHistorico({
    required String token,
  }) async {
    // Consultar o histórico do estudante autenticado
    final resposta = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/historico'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));

    // Consulta realizada com sucesso
    if (resposta.statusCode == 200) {
      final dados = jsonDecode(resposta.body);

      if (dados is! Map<String, dynamic> ||
          dados['avaliacoes'] is! List) {
        throw Exception('Resposta inesperada da API.');
      }

      final avaliacoes = dados['avaliacoes'] as List;

      return avaliacoes.map((avaliacao) {
        return Map<String, dynamic>.from(avaliacao as Map);
      }).toList();
    }

    // Token inválido ou expirado
    if (resposta.statusCode == 401) {
      throw Exception(
        'Sua sessão expirou. Faça login novamente.',
      );
    }

    throw Exception(
      'Não foi possível consultar o histórico. '
      'Código: ${resposta.statusCode}',
    );
  }
}
