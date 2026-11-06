/// Lançada quando a API responde 401 (token ausente, inválido ou expirado).
class SessaoExpiradaException implements Exception {
  final String mensagem;

  const SessaoExpiradaException([
    this.mensagem = 'Sua sessão expirou. Faça login novamente.',
  ]);

  @override
  String toString() => mensagem;
}
