
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _mostrarSenha = false;
  bool _carregando = false;

  final AuthService _authService = AuthService();

  final Color roxo = const Color(0xFF6750A4);
  final Color roxoEscuro = const Color(0xFF38265C);

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  
Future<void> _entrar() async {
  // Validar os campos do formulário
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _carregando = true;
  });

  try {
    // Enviar e-mail e senha para a API Azure
    final token = await _authService.fazerLogin(
      email: _emailController.text,
      senha: _senhaController.text,
    );

    if (!mounted) return;

        // Login realizado: direcionar para a Home
        if (token.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(token: token),
            ),
          );
        }
  } catch (erro) {
    if (!mounted) return;

    // Exibir mensagem de erro
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          erro.toString().replaceFirst('Exception: ', ''),
        ),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _carregando = false;
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6FC),
        elevation: 0,
        foregroundColor: roxoEscuro,
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,

                  children: [
                    // Logotipo
                    Image.asset(
                      'assets/images/logo.png',
                      height: 105,
                    ),

                    const SizedBox(height: 35),

                    Text(
                      'Bem-vindo de volta!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: roxoEscuro,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Entre na sua conta para continuar acompanhando seu bem-estar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF5E5868),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 42),

                    // Campo e-mail
                    TextFormField(
                      controller: _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      autofillHints: const [
                        AutofillHints.email,
                      ],

                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),

                      validator: (valor) {
                        if (valor == null ||
                            valor.trim().isEmpty) {
                          return 'Informe seu e-mail';
                        }

                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(valor.trim())) {
                          return 'Informe um e-mail válido';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Campo senha
                    TextFormField(
                      controller: _senhaController,
                      obscureText: !_mostrarSenha,

                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),

                        suffixIcon: IconButton(
                          icon: Icon(
                            _mostrarSenha
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),

                          onPressed: () {
                            setState(() {
                              _mostrarSenha =
                                  !_mostrarSenha;
                            });
                          },
                        ),

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),

                      validator: (valor) {
                        if (valor == null ||
                            valor.isEmpty) {
                          return 'Informe sua senha';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 34),

                    // Botão Entrar
                    SizedBox(
                      height: 55,

                      child: ElevatedButton(
                        onPressed: _carregando ? null : _entrar,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: roxo,
                          foregroundColor: Colors.white,

                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(30),
                          ),
                        ),

                        child: _carregando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Entrar',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Text(
                      'Stress Scan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: roxoEscuro,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Seu bem-estar também faz parte da sua jornada acadêmica.',
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
