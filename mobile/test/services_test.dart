import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:stress_scan/services/auth_service.dart';
import 'package:stress_scan/services/cadastro_service.dart';
import 'package:stress_scan/services/historico_service.dart';
import 'package:stress_scan/services/previsao_service.dart';
import 'package:stress_scan/services/sessao_expirada_exception.dart';

MockClient _resposta(int status, [Object? corpo]) => MockClient(
      (_) async => http.Response(
        corpo == null ? '' : jsonEncode(corpo),
        status,
        headers: {'content-type': 'application/json'},
      ),
    );

MockClient _semRede() =>
    MockClient((_) async => throw http.ClientException('sem rede'));

MockClient _timeout() =>
    MockClient((_) async => throw TimeoutException('demorou'));

void main() {
  group('AuthService (login)', () {
    test('retorna o token em caso de sucesso', () async {
      final s = AuthService(client: _resposta(200, {'access_token': 'abc'}));
      expect(await s.fazerLogin(email: 'a@a.com', senha: '12345678'), 'abc');
    });

    test('401 -> e-mail ou senha incorretos', () {
      final s = AuthService(client: _resposta(401, {'detail': 'x'}));
      expect(
        s.fazerLogin(email: 'a@a.com', senha: 'x'),
        throwsA(predicate((e) => e.toString().contains('incorretos'))),
      );
    });

    test('200 sem token -> erro', () {
      final s = AuthService(client: _resposta(200, {}));
      expect(s.fazerLogin(email: 'a@a.com', senha: 'x'), throwsException);
    });

    test('rede fora do ar -> mensagem amigável', () {
      final s = AuthService(client: _semRede());
      expect(
        s.fazerLogin(email: 'a@a.com', senha: 'x'),
        throwsA(predicate((e) => e.toString().contains('conectar'))),
      );
    });

    test('timeout -> mensagem amigável', () {
      final s = AuthService(client: _timeout());
      expect(
        s.fazerLogin(email: 'a@a.com', senha: 'x'),
        throwsA(predicate((e) => e.toString().contains('demorou'))),
      );
    });

    test('500 -> inclui o código', () {
      final s = AuthService(client: _resposta(500));
      expect(
        s.fazerLogin(email: 'a@a.com', senha: 'x'),
        throwsA(predicate((e) => e.toString().contains('500'))),
      );
    });
  });

  group('CadastroService', () {
    test('201 conclui sem erro', () async {
      final s = CadastroService(client: _resposta(201, {'ok': true}));
      await s.cadastrar(email: 'a@a.com', senha: '12345678');
    });

    test('409 -> e-mail duplicado', () {
      final s = CadastroService(client: _resposta(409, {'detail': 'x'}));
      expect(
        s.cadastrar(email: 'a@a.com', senha: '12345678'),
        throwsA(predicate((e) => e.toString().contains('já está cadastrado'))),
      );
    });

    test('422 -> dados inválidos', () {
      final s = CadastroService(client: _resposta(422, {'detail': []}));
      expect(
        s.cadastrar(email: 'a@a.com', senha: '12345678'),
        throwsA(predicate((e) => e.toString().contains('Verifique'))),
      );
    });

    test('rede fora do ar -> mensagem amigável', () {
      final s = CadastroService(client: _semRede());
      expect(
        s.cadastrar(email: 'a@a.com', senha: '12345678'),
        throwsA(predicate((e) => e.toString().contains('conectar'))),
      );
    });

    test('envia o e-mail sem espaços', () async {
      late Map<String, dynamic> corpo;
      final client = MockClient((req) async {
        corpo = jsonDecode(req.body) as Map<String, dynamic>;
        return http.Response('{}', 201);
      });
      await CadastroService(client: client)
          .cadastrar(email: '  a@a.com ', senha: '12345678');
      expect(corpo['email'], 'a@a.com');
    });
  });

  group('HistoricoService', () {
    test('200 retorna a lista de avaliações', () async {
      final s = HistoricoService(
        client: _resposta(200, {
          'avaliacoes': [
            {'nivel_estresse': 1, 'classificacao': 'Estresse moderado'},
          ],
        }),
      );
      final lista = await s.consultarHistorico(token: 't');
      expect(lista, hasLength(1));
      expect(lista.first['nivel_estresse'], 1);
    });

    test('envia o token no header Authorization', () async {
      String? header;
      final client = MockClient((req) async {
        header = req.headers['Authorization'];
        return http.Response(jsonEncode({'avaliacoes': []}), 200);
      });
      await HistoricoService(client: client).consultarHistorico(token: 'xyz');
      expect(header, 'Bearer xyz');
    });

    test('401 -> SessaoExpiradaException', () {
      final s = HistoricoService(client: _resposta(401, {'detail': 'x'}));
      expect(
        s.consultarHistorico(token: 'ruim'),
        throwsA(isA<SessaoExpiradaException>()),
      );
    });

    test('resposta fora do formato -> erro', () {
      final s = HistoricoService(client: _resposta(200, {'foo': 1}));
      expect(s.consultarHistorico(token: 't'), throwsException);
    });

    test('500 -> erro com código, sem sessão expirada', () {
      final s = HistoricoService(client: _resposta(500));
      expect(
        s.consultarHistorico(token: 't'),
        throwsA(allOf(
          isNot(isA<SessaoExpiradaException>()),
          predicate((e) => e.toString().contains('500')),
        )),
      );
    });

    test('rede fora do ar -> mensagem amigável', () {
      final s = HistoricoService(client: _semRede());
      expect(
        s.consultarHistorico(token: 't'),
        throwsA(predicate((e) => e.toString().contains('conectar'))),
      );
    });
  });

  group('PrevisaoService', () {
    const respostas = {'anxiety_level': 5};

    test('200 retorna o resultado', () async {
      final s = PrevisaoService(
        client: _resposta(200, {
          'nivel_estresse': 2,
          'classificacao': 'Estresse alto',
        }),
      );
      final r =
          await s.classificarEstresse(respostas: respostas, token: 't');
      expect(r['nivel_estresse'], 2);
    });

    test('401 -> SessaoExpiradaException', () {
      final s = PrevisaoService(client: _resposta(401, {'detail': 'x'}));
      expect(
        s.classificarEstresse(respostas: respostas, token: 'ruim'),
        throwsA(isA<SessaoExpiradaException>()),
      );
    });

    test('422 -> respostas inválidas', () {
      final s = PrevisaoService(client: _resposta(422, {'detail': []}));
      expect(
        s.classificarEstresse(respostas: respostas, token: 't'),
        throwsA(predicate((e) => e.toString().contains('inválidas'))),
      );
    });

    test('resposta sem campos esperados -> erro', () {
      final s = PrevisaoService(client: _resposta(200, {'nivel_estresse': 'x'}));
      expect(
        s.classificarEstresse(respostas: respostas, token: 't'),
        throwsException,
      );
    });

    test('timeout -> mensagem amigável', () {
      final s = PrevisaoService(client: _timeout());
      expect(
        s.classificarEstresse(respostas: respostas, token: 't'),
        throwsA(predicate((e) => e.toString().contains('conectar'))),
      );
    });
  });
}
