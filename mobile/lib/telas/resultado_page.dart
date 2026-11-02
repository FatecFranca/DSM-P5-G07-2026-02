
import 'package:flutter/material.dart';

class ResultadoPage extends StatelessWidget {
  final Map<String, dynamic> resultado;

  const ResultadoPage({
    super.key,
    required this.resultado,
  });

  static const Color roxo = Color(0xFF6750A4);
  static const Color roxoEscuro = Color(0xFF38265C);
  static const Color fundo = Color(0xFFF8F6FC);

  @override
  Widget build(BuildContext context) {
    final int nivel = resultado['nivel_estresse'] as int;
    final String classificacao =
        resultado['classificacao'] as String;

    final String mensagem = switch (nivel) {
      0 => 'Suas respostas foram classificadas '
          'na faixa de estresse baixo.',
      1 => 'Suas respostas foram classificadas '
          'na faixa de estresse moderado.',
      2 => 'Suas respostas foram classificadas '
          'na faixa de estresse alto.',
      _ => 'Confira o resultado da sua avaliação.',
    };

    final Color corResultado = switch (nivel) {
      0 => const Color(0xFF2E7D5B),
      1 => const Color(0xFFB77719),
      2 => const Color(0xFFC05252),
      _ => roxo,
    };

    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        title: const Text('Resultado'),
        backgroundColor: fundo,
        foregroundColor: roxoEscuro,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 440,
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 90,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Sua avaliação está pronta!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: roxoEscuro,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Image.asset(
                    'assets/images/resultado.png',
                    height: 240,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'NÍVEL DE ESTRESSE',
                          style: TextStyle(
                            color: Color(0xFF5E5868),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Icon(
                          Icons.insights,
                          size: 42,
                          color: corResultado,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          classificacao,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: corResultado,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          mensagem,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Color(0xFF5E5868),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Esta classificação é experimental, '
                    'não representa um diagnóstico e '
                    'não substitui uma avaliação profissional.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
