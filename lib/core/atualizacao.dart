import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'nuvem.dart';

/// Onde ficam os instaladores: balde público "atualizacoes" do Supabase.
/// Cada plataforma tem a sua pasta com um versao.json (gerado por
/// tool/release/windows.ps1).
const baldeAtualizacoes = 'atualizacoes';
const _urlBalde = '$supabaseUrl/storage/v1/object/public/$baldeAtualizacoes';

class Atualizacao {
  const Atualizacao({
    required this.versao,
    required this.build,
    required this.notas,
    required this.instalador,
    required this.sha256,
  });

  final String versao;
  final int build;
  final String notas;

  /// Nome do arquivo na pasta da plataforma (ex.: Aurora-1.0.1-setup.exe).
  final String instalador;
  final String sha256;

  factory Atualizacao.deJson(Map<String, dynamic> j) => Atualizacao(
        versao: j['versao'] as String,
        build: (j['build'] as num).toInt(),
        notas: (j['notas'] as String?) ?? '',
        instalador: j['instalador'] as String,
        sha256: (j['sha256'] as String).toLowerCase(),
      );
}

/// Há atualização se o build publicado for maior que o deste app.
Atualizacao? novaVersao(Map<String, dynamic> json, int buildAtual) {
  final a = Atualizacao.deJson(json);
  return a.build > buildAtual ? a : null;
}

/// Confere o versao.json e, no Windows, baixa e roda o instalador em silêncio.
/// Só vale para o app instalado (modo release); o de desenvolvimento não se
/// atualiza sozinho.
class Atualizador {
  Atualizador._();
  static final instancia = Atualizador._();

  bool get suportado => kReleaseMode && !kIsWeb && Platform.isWindows;

  /// Versão disponível (nula se o app está em dia ou não conferiu ainda).
  final disponivel = ValueNotifier<Atualizacao?>(null);

  /// Progresso do download, de 0 a 1 (nulo quando não está baixando).
  final progresso = ValueNotifier<double?>(null);

  String versaoAtual = '';

  Future<Atualizacao?> verificar() async {
    if (!suportado) return null;
    try {
      final info = await PackageInfo.fromPlatform();
      versaoAtual = info.version;
      final r = await http
          .get(Uri.parse('$_urlBalde/windows/versao.json?t=${DateTime.now().millisecondsSinceEpoch}'))
          .timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) return null;
      final json = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
      final nova = novaVersao(json, int.tryParse(info.buildNumber) ?? 0);
      disponivel.value = nova;
      debugPrint('Atualização: atual ${info.version}+${info.buildNumber}, publicada ${json['versao']}+${json['build']}');
      return nova;
    } catch (e) {
      debugPrint('Atualização: não conferiu ($e)');
      return null;
    }
  }

  /// Baixa, confere o SHA-256 e entrega ao instalador, que fecha e reabre o app.
  Future<void> aplicar(Atualizacao a) async {
    progresso.value = 0;
    try {
      final pasta = await getTemporaryDirectory();
      final arquivo = File('${pasta.path}${Platform.pathSeparator}${a.instalador}');
      final resposta = await http.Client().send(http.Request('GET', Uri.parse('$_urlBalde/windows/${a.instalador}')));
      if (resposta.statusCode != 200) throw HttpException('download respondeu ${resposta.statusCode}');
      final total = resposta.contentLength ?? 0;
      var recebido = 0;
      final saida = arquivo.openWrite();
      await for (final pedaco in resposta.stream) {
        saida.add(pedaco);
        recebido += pedaco.length;
        if (total > 0) progresso.value = recebido / total;
      }
      await saida.close();

      final soma = sha256.convert(await arquivo.readAsBytes()).toString();
      if (soma != a.sha256) {
        await arquivo.delete();
        throw const FileSystemException('o arquivo baixado não confere (SHA-256)');
      }
      await Process.start(
        arquivo.path,
        ['/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART'],
        mode: ProcessStartMode.detached,
      );
      exit(0);
    } finally {
      progresso.value = null;
    }
  }
}
