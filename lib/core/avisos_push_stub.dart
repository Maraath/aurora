/// Fora da web os avisos são agendados no próprio aparelho (Notificador).
Future<String> estadoNoNavegador() async => 'sem-suporte';

Future<String?> ativarNoNavegador(String chavePublica) async => null;

Future<String?> inscricaoNoNavegador() async => null;

Future<String?> desativarNoNavegador() async => null;

String nomeDoAparelho() => '';
