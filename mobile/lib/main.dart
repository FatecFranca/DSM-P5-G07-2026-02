
import 'package:flutter/material.dart';
import 'telas/login_page.dart';

void main() {
  runApp(const StressScanApp());
}

class StressScanApp extends StatelessWidget {
  const StressScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stress Scan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
        ),
        useMaterial3: true,
      ),
      home: const TelaBoasVindas(),
    );
  }
}

class TelaBoasVindas extends StatelessWidget {
  const TelaBoasVindas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logotipo
                    Image.asset(
                      'assets/images/logo.png',
                      height: 110,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 28),

                    // Imagem de boas-vindas
                    Image.asset(
                      'assets/images/bemvindo.png',
                      height: 260,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Bem-vindo ao Stress Scan!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF38265C),
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Um espaço para conhecer melhor seus níveis de estresse e acompanhar seu bem-estar durante a vida universitária.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Color(0xFF5E5868),
                      ),
                    ),

                    const SizedBox(height: 38),

                    // Botão Entrar
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF6750A4),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Entrar',
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Botão Criar conta
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TelaProvisoria(
                                    titulo: 'Criar conta',
                                  ),
                            ),
                          );
                        },
                        child: const Text(
                          'Criar conta',
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Classificação experimental. Não substitui avaliação profissional.',
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
      ),
    );
  }
}

// Tela temporária para testar a navegação.
class TelaProvisoria extends StatelessWidget {
  final String titulo;

  const TelaProvisoria({
    super.key,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
      ),
      body: Center(
        child: Text(
          'Tela de $titulo - próxima etapa',
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
