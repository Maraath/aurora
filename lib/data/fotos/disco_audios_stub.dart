import 'dart:typed_data';

/// Fora da web os áudios ficam em arquivos (DiscoAudiosArquivos).
Future<void> gravarNoNavegador(String nome, Uint8List bytes) => throw UnsupportedError('só na web');

Future<Uint8List?> lerDoNavegador(String nome) => throw UnsupportedError('só na web');

Future<void> apagarDoNavegador(String nome) => throw UnsupportedError('só na web');

Future<bool> existeNoNavegador(String nome) => throw UnsupportedError('só na web');

Future<List<String>> nomesNoNavegador() => throw UnsupportedError('só na web');
