import 'package:flutter/material.dart';

import 'questionario_page.dart';
import 'historico_page.dart';
import 'dashboard_page.dart';


class HomePage extends StatelessWidget {
  final String token;

  const HomePage({super.key, required this.token});

  static const Color roxo = Color(0xFF6750A4);
  static const Color roxoEscuro = Color(0xFF38265C);
  static const Color fundo = Color(0xFFF8F6FC);


  // Pede confirmação e encerra a sessão: o token vive apenas neste widget,
  // então ao voltar para a tela inicial ele é descartado.
  Future<void> _confirmarSaida(BuildContext context) async {
    final sair = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Você precisará fazer login novamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (sair == true && context.mounted) {
      Navigator.of(context).popUntil((rota) => rota.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,

      appBar: AppBar(
        backgroundColor: fundo,
        automaticallyImplyLeading: false,
        title: const Text(
          'Stress Scan',
          style: TextStyle(color: roxoEscuro, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout, color: roxoEscuro),
            onPressed: () => _confirmarSaida(context),
          ),
        ],
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  // Identidade visual
                  Image.asset(
                    'assets/images/logo.png',
                    height: 90,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Olá, estudante!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: roxoEscuro,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Como está seu bem-estar hoje?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Color(0xFF5E5868)),
                  ),

                  const SizedBox(height: 25),

                  // Ilustração
                  Image.asset(
                    'assets/images/questionario.png',
                    height: 190,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 30),

                  // Questionário
                  _botaoMenu(
                    context,
                    icone: Icons.edit_note,
                    titulo: 'Responder questionário',
                    descricao: 'Descubra sua classificação de estresse',
                    aoClicar: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuestionarioPage(token: token),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),


                  // Resultados
                  _botaoMenu(
                    context,
                    icone: Icons.insights,
                    titulo: 'Meus resultados',
                    descricao: 'Acompanhe suas classificações de estresse',
                    aoClicar: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardPage(
                            token: token,
                          ),
                        ),
                      );
                    },
                  ),


                  const SizedBox(height: 14),

                  // Histórico
                  _botaoMenu(
                    context,
                    icone: Icons.history,
                    titulo: 'Meu histórico',
                    descricao: 'Consulte suas avaliações anteriores',
                    aoClicar: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoricoPage(token: token),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Classificação experimental. '
                    'Não substitui avaliação profissional.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _botaoMenu(
    BuildContext context, {
    required IconData icone,
    required String titulo,
    required String descricao,
    required VoidCallback aoClicar,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: aoClicar,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(icone, color: roxo, size: 32),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: roxoEscuro,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        descricao,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5E5868),
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.chevron_right, color: roxo),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
