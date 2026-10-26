import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

/// `window.auroraAudios` do web/index.html (IndexedDB do navegador).
@JS('auroraAudios.gravar')
external JSPromise<JSAny?> _gravar(JSString nome, JSUint8Array bytes);

@JS('auroraAudios.ler')
external JSPromise<JSUint8Array?> _ler(JSString nome);

@JS('auroraAudios.apagar')
external JSPromise<JSAny?> _apagar(JSString nome);

@JS('auroraAudios.existe')
external JSPromise<JSBoolean> _existe(JSString nome);

@JS('auroraAudios.nomes')
external JSPromise<JSString> _nomes();

Future<void> gravarNoNavegador(String nome, Uint8List bytes) => _gravar(nome.toJS, bytes.toJS).toDart;

Future<Uint8List?> lerDoNavegador(String nome) async => (await _ler(nome.toJS).toDart)?.toDart;

Future<void> apagarDoNavegador(String nome) => _apagar(nome.toJS).toDart;

Future<bool> existeNoNavegador(String nome) async => (await _existe(nome.toJS).toDart).toDart;

Future<List<String>> nomesNoNavegador() async => [
  for (final n in jsonDecode((await _nomes().toDart).toDart) as List) '$n',
];
