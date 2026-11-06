import 'package:flutter/material.dart';

import '../services/cadastro_service.dart';
import 'login_page.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarController = TextEditingController();

  bool _mostrarSenha = false;
  bool _carregando = false;

  final CadastroService _cadastroService = CadastroService();

  final Color roxo = const Color(0xFF6750A4);
  final Color roxoEscuro = const Color(0xFF38265C);

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      await _cadastroService.cadastrar(
        email: _emailController.text,
        senha: _senhaController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta criada com sucesso! Faça login para continuar.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro.toString().replaceFirst('Exception: ', '')),
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

  InputDecoration _decoracao(String rotulo, IconData icone, {Widget? sufixo}) {
    return InputDecoration(
      labelText: rotulo,
      prefixIcon: Icon(icone),
      suffixIcon: sufixo,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
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
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('assets/images/logo.png', height: 95),

                    const SizedBox(height: 30),

                    Text(
                      'Crie sua conta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: roxoEscuro,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Cadastre-se para responder ao questionário e acompanhar seus resultados.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF5E5868),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // E-mail
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: _decoracao('E-mail', Icons.email_outlined),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Informe seu e-mail';
                        }

                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(valor.trim())) {
                          return 'Informe um e-mail válido';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Senha
                    TextFormField(
                      controller: _senhaController,
                      obscureText: !_mostrarSenha,
                      decoration: _decoracao(
                        'Senha',
                        Icons.lock_outline,
                        sufixo: IconButton(
                          icon: Icon(
                            _mostrarSenha
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _mostrarSenha = !_mostrarSenha;
                            });
                          },
                        ),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.isEmpty) {
                          return 'Informe uma senha';
                        }

                        if (valor.length < 8) {
                          return 'A senha deve ter pelo menos 8 caracteres';
                        }

                        if (valor.length > 128) {
                          return 'A senha deve ter no máximo 128 caracteres';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Confirmar senha
                    TextFormField(
                      controller: _confirmarController,
                      obscureText: !_mostrarSenha,
                      decoration: _decoracao(
                        'Confirmar senha',
                        Icons.lock_outline,
                      ),
                      validator: (valor) {
                        if (valor == null || valor.isEmpty) {
                          return 'Confirme sua senha';
                        }

                        if (valor != _senhaController.text) {
                          return 'As senhas não coincidem';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 34),

                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _carregando ? null : _cadastrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: roxo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
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
                                'Criar conta',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'Classificação experimental. Não substitui avaliação profissional.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
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
