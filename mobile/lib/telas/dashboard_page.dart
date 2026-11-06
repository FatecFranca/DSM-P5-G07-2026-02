
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../services/historico_service.dart';
import '../utils/sessao.dart';

class DashboardPage extends StatefulWidget {
  final String token;

  const DashboardPage({
    super.key,
    required this.token,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color roxo = Color(0xFF6750A4);
  static const Color roxoEscuro = Color(0xFF38265C);
  static const Color fundo = Color(0xFFF8F6FC);

  final HistoricoService _service = HistoricoService();

  late Future<List<Map<String, dynamic>>> _historico;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    _historico = _service.consultarHistorico(
      token: widget.token,
    );
  }

  void _atualizar() {
    setState(_carregar);
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

  String _nomeNivel(int nivel) {
    switch (nivel) {
      case 0:
        return 'Estresse baixo';
      case 1:
        return 'Estresse moderado';
      case 2:
        return 'Estresse alto';
      default:
        return 'Indisponível';
    }
  }

  Widget _cartaoResumo({
    required String titulo,
    required String valor,
    required Color cor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                color: Color(0xFF5E5868),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              valor,
              style: TextStyle(
                color: cor,
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legenda(String nome, Color cor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 11,
          width: 11,
          decoration: BoxDecoration(
            color: cor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          nome,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Widget _montarDashboard(
    List<Map<String, dynamic>> avaliacoes,
  ) {
    if (avaliacoes.isEmpty) {
      return const Center(
        child: Text(
          'Você ainda não possui avaliações.\n'
          'Responda ao questionário para começar!',
          textAlign: TextAlign.center,
        ),
      );
    }

    // A API retorna da mais recente para a mais antiga.
    final ultima = avaliacoes.first;
    final nivelAtual =
        ultima['nivel_estresse'] as int? ?? -1;

    // Gráfico da mais antiga para a mais recente.
    final ultimasDez = avaliacoes
        .take(10)
        .toList()
        .reversed
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 85,
              ),

              const SizedBox(height: 24),

              const Text(
                'Meus resultados',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: roxoEscuro,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Acompanhe suas classificações de estresse.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF5E5868),
                ),
              ),

              const SizedBox(height: 30),

              // Resumo
              Row(
                children: [
                  _cartaoResumo(
                    titulo: 'Última avaliação',
                    valor: _nomeNivel(nivelAtual),
                    cor: _corNivel(nivelAtual),
                  ),
                  const SizedBox(width: 12),
                  _cartaoResumo(
                    titulo: 'Avaliações exibidas',
                    valor: '${avaliacoes.length}',
                    cor: roxoEscuro,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Gráfico
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Evolução das classificações',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: roxoEscuro,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Últimas 10 avaliações, em ordem cronológica',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5E5868),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      height: 240,
                      child: BarChart(
                        BarChartData(
                          minY: 0,
                          maxY: 3.5,
                          alignment:
                              BarChartAlignment.spaceAround,

                          barTouchData: BarTouchData(
                            enabled: false,
                          ),

                          gridData: const FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                          ),

                          borderData: FlBorderData(
                            show: false,
                          ),

                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false),
                            ),

                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 72,
                                interval: 1,
                                getTitlesWidget:
                                    (value, meta) {
                                  final texto = switch (value) {
                                    1 => 'Baixo',
                                    2 => 'Moderado',
                                    3 => 'Alto',
                                    _ => '',
                                  };

                                  return Text(
                                    texto,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF5E5868),
                                    ),
                                  );
                                },
                              ),
                            ),

                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval: 1,
                                getTitlesWidget:
                                    (value, meta) {
                                  final indice = value.toInt();

                                  if (indice < 0 ||
                                      indice >= ultimasDez.length ||
                                      value != indice.toDouble()) {
                                    return const SizedBox.shrink();
                                  }

                                  return Text(
                                    '${indice + 1}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF5E5868),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          barGroups: List.generate(
                            ultimasDez.length,
                            (indice) {
                              final nivel =
                                  ultimasDez[indice]
                                          ['nivel_estresse']
                                      as int;

                              return BarChartGroupData(
                                x: indice,
                                barRods: [
                                  BarChartRodData(
                                    // Deslocamento visual:
                                    // 0=baixo -> 1
                                    // 1=moderado -> 2
                                    // 2=alto -> 3
                                    toY: (nivel + 1).toDouble(),
                                    width: 19,
                                    color: _corNivel(nivel),
                                    borderRadius:
                                        BorderRadius.circular(5),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _legenda(
                          'Baixo',
                          _corNivel(0),
                        ),
                        _legenda(
                          'Moderado',
                          _corNivel(1),
                        ),
                        _legenda(
                          'Alto',
                          _corNivel(2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'O gráfico mostra categorias de classificação, '
                'não uma medida clínica contínua de estresse.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF5E5868),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        title: const Text('Meus resultados'),
        backgroundColor: fundo,
        foregroundColor: roxoEscuro,
        actions: [
          IconButton(
            tooltip: 'Atualizar resultados',
            onPressed: _atualizar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
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
              if (tratarSessaoExpirada(context, snapshot.error)) {
                return const SizedBox.shrink();
              }

              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Não foi possível carregar os resultados.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _atualizar,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            return _montarDashboard(snapshot.data ?? []);
          },
        ),
      ),
    );
  }
}
