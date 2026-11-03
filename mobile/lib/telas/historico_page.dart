
import 'package:flutter/material.dart';

import '../services/historico_service.dart';

class HistoricoPage extends StatefulWidget {
  final String token;

  const HistoricoPage({
    super.key,
    required this.token,
  });

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  static const Color roxo = Color(0xFF6750A4);
  static const Color roxoEscuro = Color(0xFF38265C);
  static const Color fundo = Color(0xFFF8F6FC);

  final HistoricoService _historicoService = HistoricoService();

  late Future<List<Map<String, dynamic>>> _historico;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  void _carregarHistorico() {
    _historico = _historicoService.consultarHistorico(
      token: widget.token,
    );
  }

  void _atualizar() {
    setState(() {
      _carregarHistorico();
    });
  }

  String _formatarData(String? dataIso) {
    if (dataIso == null) return 'Data indisponível';

    final data = DateTime.tryParse(dataIso)?.toLocal();

    if (data == null) return 'Data indisponível';

    String doisDigitos(int valor) =>
        valor.toString().padLeft(2, '0');

    return '${doisDigitos(data.day)}/'
        '${doisDigitos(data.month)}/'
        '${data.year} às '
        '${doisDigitos(data.hour)}:'
        '${doisDigitos(data.minute)}';
  }

  Color _corNivel(int nivel) {
    switch (nivel) {
      case 0:
        return const Color(0xFF2E7D5B);
      case 1:
        return const Color(0xFFB77719);
      case 2:
        return const Color(0xFFC05252);
      default:
        return roxo;
    }
  }

  Widget _cartaoAvaliacao(Map<String, dynamic> avaliacao) {
    final nivel = avaliacao['nivel_estresse'] as int? ?? -1;
    final classificacao =
        avaliacao['classificacao']?.toString() ??
        'Classificação indisponível';

    final data = _formatarData(
      avaliacao['criado_em']?.toString(),
    );

    final cor = _corNivel(nivel);

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF5E5868),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5E5868),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Icon(Icons.insights, color: cor, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    classificacao,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: cor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Classe $nivel',
              style: const TextStyle(
                color: Color(0xFF5E5868),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        title: const Text('Meu histórico'),
        backgroundColor: fundo,
        foregroundColor: roxoEscuro,
        actions: [
          IconButton(
            tooltip: 'Atualizar histórico',
            onPressed: _atualizar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 85,
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Suas avaliações',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: roxoEscuro,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Acompanhe seus resultados anteriores.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF5E5868),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _historico,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: roxo,
                                  size: 40,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Não foi possível carregar o histórico.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _atualizar,
                                  child: const Text('Tentar novamente'),
                                ),
                              ],
                            ),
                          );
                        }

                        final avaliacoes = snapshot.data ?? [];

                        if (avaliacoes.isEmpty) {
                          return const Center(
                            child: Text(
                              'Você ainda não possui avaliações.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF5E5868),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: avaliacoes.length,
                          itemBuilder: (context, index) {
                            return _cartaoAvaliacao(
                              avaliacoes[index],
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Resultados experimentais. '
                    'Não substituem avaliação profissional.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
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
