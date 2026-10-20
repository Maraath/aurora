import 'dart:js_interop';

/// `window.auroraAvisos` do web/index.html.
@JS('auroraAvisos.estado')
external JSPromise<JSString> _estado();

@JS('auroraAvisos.ativar')
external JSPromise<JSString?> _ativar(JSString chave);

@JS('auroraAvisos.inscricao')
external JSPromise<JSString?> _inscricao();

@JS('auroraAvisos.desativar')
external JSPromise<JSString?> _desativar();

@JS('auroraAvisos.aparelho')
external JSString _aparelho();

/// 'instalar' (iPhone fora da tela de início), 'sem-suporte', 'negado', 'desligado' ou 'ativo'.
Future<String> estadoNoNavegador() async {
  try {
    return (await _estado().toDart).toDart;
  } catch (_) {
    return 'sem-suporte'; // index.html antigo
  }
}

/// Pede a permissão e inscreve o aparelho. Devolve a inscrição (JSON) ou nulo se
/// a pessoa recusou. Tem de ser chamada direto no toque, sem espera antes.
Future<String?> ativarNoNavegador(String chavePublica) async => (await _ativar(chavePublica.toJS).toDart)?.toDart;

Future<String?> inscricaoNoNavegador() async {
  try {
    return (await _inscricao().toDart)?.toDart;
  } catch (_) {
    return null;
  }
}

/// Cancela a inscrição do aparelho e devolve a que existia (para apagar no servidor).
Future<String?> desativarNoNavegador() async => (await _desativar().toDart)?.toDart;

String nomeDoAparelho() {
  try {
    return _aparelho().toDart;
  } catch (_) {
    return 'Navegador';
  }
}
