import 'package:flutter/material.dart';

import '../services/sessao_expirada_exception.dart';

/// Descarta a sessão em memória e volta para a tela inicial,
/// avisando o usuário de que precisa entrar novamente.
void encerrarSessaoExpirada(BuildContext context) {
  final messenger = ScaffoldMessenger.of(context);

  Navigator.of(context).popUntil((rota) => rota.isFirst);

  messenger.showSnackBar(
    const SnackBar(
      content: Text('Sua sessão expirou. Faça login novamente.'),
      backgroundColor: Colors.red,
    ),
  );
}

/// Se [erro] for uma sessão expirada, encerra a sessão e retorna true.
bool tratarSessaoExpirada(BuildContext context, Object? erro) {
  if (erro is! SessaoExpiradaException) return false;

  // Executa após o frame atual para não navegar durante o build.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) encerrarSessaoExpirada(context);
  });

  return true;
}
