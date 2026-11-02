import 'package:flutter/material.dart';
import 'resultado_page.dart';
import '../services/previsao_service.dart';

// Estrutura de cada pergunta
class PerguntaStress {
  final String categoria;
  final String campo;
  final String pergunta;
  final Map<String, int> alternativas;

  const PerguntaStress({
    required this.categoria,
    required this.campo,
    required this.pergunta,
    required this.alternativas,
  });
}

class QuestionarioPage extends StatefulWidget {
  final String token;

  const QuestionarioPage({super.key, required this.token});

  @override
  State<QuestionarioPage> createState() => _QuestionarioPageState();
}

class _QuestionarioPageState extends State<QuestionarioPage> {
  static const Color roxo = Color(0xFF6750A4);
  static const Color roxoEscuro = Color(0xFF38265C);
  static const Color fundo = Color(0xFFF8F6FC);

  int indiceAtual = 0;
  bool _enviando = false;

  final PrevisaoService _previsaoService = PrevisaoService();

  // Armazena as respostas com os nomes esperados pela API
  final Map<String, int> respostas = {};

  final List<PerguntaStress> perguntas = const [
    // FATORES PSICOLÓGICOS
    PerguntaStress(
      categoria: 'Fatores psicológicos',
      campo: 'anxiety_level',
      pergunta: 'Como você avalia seu nível de ansiedade atualmente?',
      alternativas: {
        'Nenhuma': 0,
        'Baixa': 6,
        'Moderada': 11,
        'Alta': 16,
        'Muito alta': 21,
      },
    ),
    PerguntaStress(
      categoria: 'Fatores psicológicos',
      campo: 'depression',
      pergunta: 'Com que intensidade você tem sentido tristeza ou desânimo?',
      alternativas: {
        'Nenhuma': 0,
        'Baixa': 6,
        'Moderada': 12,
        'Alta': 19,
        'Muito alta': 27,
      },
    ),
    PerguntaStress(
      categoria: 'Fatores psicológicos',
      campo: 'self_esteem',
      pergunta: 'Como você avalia sua autoestima?',
      alternativas: {
        'Muito baixa': 0,
        'Baixa': 11,
        'Moderada': 19,
        'Alta': 26,
        'Muito alta': 30,
      },
    ),

    // FATORES FISIOLÓGICOS
    PerguntaStress(
      categoria: 'Fatores fisiológicos',
      campo: 'headache',
      pergunta: 'Com que frequência você sente dores de cabeça?',
      alternativas: {
        'Nunca': 0,
        'Raramente': 1,
        'Às vezes': 2,
        'Frequentemente': 3,
        'Muito frequentemente': 5,
      },
    ),
    PerguntaStress(
      categoria: 'Fatores fisiológicos',
      campo: 'sleep_quality',
      pergunta: 'Como você avalia a qualidade do seu sono?',
      alternativas: {
        'Muito ruim': 0,
        'Ruim': 1,
        'Regular': 3,
        'Boa': 4,
        'Muito boa': 5,
      },
    ),

    // FATORES AMBIENTAIS
    PerguntaStress(
      categoria: 'Fatores ambientais',
      campo: 'noise_level',
      pergunta: 'Qual é o nível de ruído no seu ambiente de estudos?',
      alternativas: {
        'Nenhum': 0,
        'Baixo': 1,
        'Moderado': 2,
        'Alto': 3,
        'Muito alto': 5,
      },
    ),
    PerguntaStress(
      categoria: 'Fatores ambientais',
      campo: 'living_conditions',
      pergunta: 'Como você avalia suas condições de moradia?',
      alternativas: {
        'Muito ruins': 0,
        'Ruins': 1,
        'Regulares': 2,
        'Boas': 3,
        'Muito boas': 5,
      },
    ),
    PerguntaStress(
      categoria: 'Fatores ambientais',
      campo: 'safety',
      pergunta: 'Você se sente seguro nos ambientes que frequenta?',
      alternativas: {
        'Nada seguro': 0,
        'Pouco seguro': 2,
        'Moderadamente seguro': 3,
        'Seguro': 4,
        'Muito seguro': 5,
      },
    ),
    PerguntaStress(
      categoria: 'Fatores ambientais',
      campo: 'basic_needs',
      pergunta: 'Suas necessidades básicas são atendidas?',
      alternativas: {
        'Não são atendidas': 0,
        'Pouco atendidas': 2,
        'Parcialmente atendidas': 3,
        'Atendidas': 4,
        'Totalmente atendidas': 5,
      },
    ),

    // FATORES ACADÊMICOS
    PerguntaStress(
      categoria: 'Fatores acadêmicos',
      campo: 'academic_performance',
      pergunta: 'Como você avalia seu desempenho acadêmico?',
      alternativas: {
        'Muito ruim': 0,
        'Ruim': 1,
        'Regular': 2,
        'Bom': 4,
        'Muito bom': 5,
      },
    ),
    PerguntaStress(
      categoria: 'Fatores acadêmicos',
      campo: 'study_load',
      pergunta: 'Como você avalia sua carga de estudos?',
      alternativas: {
        'Muito baixa': 0,
        'Baixa': 1,
        'Moderada': 2,
        'Alta': 3,
        'Muito alta': 5,
      },
    ),
    PerguntaStress(
      categoria: 'Fatores acadêmicos',
      campo: 'teacher_student_relationship',
      pergunta: 'Como é seu relacionamento com os professores?',
      alternativas: {
        'Muito ruim': 0,
        'Ruim': 1,
        'Regular': 2,
        'Bom': 4,
        'Muito bom': 5,
      },
    ),
    PerguntaStress(
      categoria: 'Fatores acadêmicos',
      campo: 'future_career_concerns',
      pergunta: 'Quanto você se preocupa com sua futura carreira?',
      alternativas: {
        'Nada': 0,
        'Pouco': 1,
        'Moderadamente': 2,
        'Muito': 4,
        'Extremamente': 5,
      },
    ),

    // FATORES SOCIAIS
    PerguntaStress(
      categoria: 'Fatores sociais',
      campo: 'social_support',
      pergunta: 'O quanto você recebe de suporte da sua rede de apoio?',
      alternativas: {'Nenhum': 0, 'Pouco': 1, 'Moderado': 2, 'Muito': 3},
    ),
    PerguntaStress(
      categoria: 'Fatores sociais',
      campo: 'peer_pressure',
      pergunta: 'Quanto você sente de pressão de seus colegas?',
      alternativas: {
        'Nenhuma': 0,
        'Pouca': 1,
        'Moderada': 2,
        'Muita': 4,
        'Extrema': 5,
      },
    ),
    PerguntaStress(
      categoria: 'Fatores sociais',
      campo: 'extracurricular_activities',
      pergunta: 'Quanto suas atividades extracurriculares sobrecarregam você?',
      alternativas: {
        'Nada': 0,
        'Pouco': 2,
        'Moderadamente': 3,
        'Muito': 4,
        'Extremamente': 5,
      },
    ),
    PerguntaStress(
      categoria: 'Fatores sociais',
      campo: 'bullying',
      pergunta: 'Com que frequência você sofre intimidação ou bullying?',
      alternativas: {
        'Nunca': 0,
        'Raramente': 1,
        'Às vezes': 3,
        'Frequentemente': 4,
        'Muito frequentemente': 5,
      },
    ),
  ];

  Future<void> avancar() async {
    if (_enviando) return;

    final pergunta = perguntas[indiceAtual];

    // Verificar se a pergunta foi respondida
    if (!respostas.containsKey(pergunta.campo)) {
      return;
    }

    // Avançar normalmente até a última pergunta
    if (indiceAtual < perguntas.length - 1) {
      setState(() {
        indiceAtual++;
      });
      return;
    }

    // Confirmar que as 17 respostas foram preenchidas
    if (respostas.length != perguntas.length) {
      return;
    }

    // Última pergunta: enviar respostas para a Azure
    setState(() {
      _enviando = true;
    });

    try {
      final resultado = await _previsaoService.classificarEstresse(
        respostas: respostas,
        token: widget.token,
      );

      if (!mounted) return;

      
    // Abrir a tela com o resultado recebido da Azure
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultadoPage(
          resultado: resultado,
        ),
      ),
    );

    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _enviando = false;
        });
      }
    }
  }

  void voltar() {
    if (indiceAtual > 0) {
      setState(() {
        indiceAtual--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pergunta = perguntas[indiceAtual];

    final progresso = (indiceAtual + 1) / perguntas.length;

    final respostaSelecionada = respostas[pergunta.campo];

    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        backgroundColor: fundo,
        foregroundColor: roxoEscuro,
        title: const Text('Questionário'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    pergunta.categoria.toUpperCase(),
                    style: const TextStyle(
                      color: roxo,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Pergunta ${indiceAtual + 1} de ${perguntas.length}',
                    style: const TextStyle(color: Color(0xFF5E5868)),
                  ),

                  const SizedBox(height: 10),

                  LinearProgressIndicator(
                    value: progresso,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                    backgroundColor: const Color(0xFFDDD5EB),
                    color: roxo,
                  ),

                  const SizedBox(height: 35),

                  Text(
                    pergunta.pergunta,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: roxoEscuro,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Expanded(
                    child: ListView(
                      children: pergunta.alternativas.entries.map((
                        alternativa,
                      ) {
                        final selecionada =
                            respostaSelecionada == alternativa.value;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: selecionada
                              ? const Color(0xFFEAE2F6)
                              : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: selecionada
                                  ? roxo
                                  : const Color(0xFFE4DFE8),
                            ),
                          ),
                          child: ListTile(
                            title: Text(alternativa.key),
                            trailing: Icon(
                              selecionada
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: selecionada ? roxo : Colors.grey,
                            ),
                            onTap: () {
                              setState(() {
                                respostas[pergunta.campo] = alternativa.value;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: voltar,
                          child: const Text('Voltar'),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: respostaSelecionada == null || _enviando
                              ? null
                              : avancar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: roxo,
                            foregroundColor: Colors.white,
                          ),
                          child: _enviando
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  indiceAtual == perguntas.length - 1
                                      ? 'Concluir'
                                      : 'Avançar',
                                ),
                        ),
                      ),
                    ],
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
