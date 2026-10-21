import 'dart:convert';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
    this.url,
  });

  final String versao;
  final int build;
  final String notas;

  /// Nome do arquivo na pasta da plataforma (ex.: Aurora-1.0.1-setup.exe).
  final String instalador;
  final String sha256;

  /// Endereço completo do instalador (GitHub Releases, desde a 1.10.1). Sem ele,
  /// baixa da pasta da plataforma no balde, como as versões antigas.
  final String? url;

  /// No Android há um APK por arquitetura ("abis": {"arm64-v8a": {instalador,
  /// sha256}, …}); [abis] é a lista do aparelho, da preferida para a última.
  static Atualizacao? deJson(Map<String, dynamic> j, {List<String>? abis}) {
    var arquivo = j;
    if (abis != null) {
      final porAbi = (j['abis'] as Map<String, dynamic>?) ?? const {};
      final abi = abis.where(porAbi.containsKey).firstOrNull;
      if (abi == null) return null;
      arquivo = porAbi[abi] as Map<String, dynamic>;
    }
    return Atualizacao(
      versao: j['versao'] as String,
      build: (j['build'] as num).toInt(),
      notas: (j['notas'] as String?) ?? '',
      instalador: arquivo['instalador'] as String,
      sha256: (arquivo['sha256'] as String).toLowerCase(),
      url: _soHttps(arquivo['url']),
    );
  }

  static String? _soHttps(Object? url) {
    final uri = url is String ? Uri.tryParse(url) : null;
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty ? url as String : null;
  }
}

/// Há atualização se o build publicado for maior que o deste app. No Android
/// com APK por arquitetura, o Flutter soma 1000 × arquitetura ao versionCode,
/// por isso só contam os 3 últimos dígitos.
Atualizacao? novaVersao(Map<String, dynamic> json, int buildAtual, {List<String>? abis}) {
  final a = Atualizacao.deJson(json, abis: abis);
  if (abis != null) buildAtual %= 1000;
  return a != null && a.build > buildAtual ? a : null;
}

/// Pedido de permissão do Android ("instalar apps desconhecidos") em aberto.
class PermissaoInstalar implements Exception {
  const PermissaoInstalar();
  @override
  String toString() => 'Permita que o Aurora instale atualizações e toque em "Atualizar agora" de novo.';
}

/// Confere o versao.json da plataforma e aplica a versão nova: no Windows roda
/// o instalador em silêncio (ele fecha e reabre o app); no Android abre o
/// instalador do sistema com o APK baixado. Só vale para o app instalado
/// (modo release); o de desenvolvimento não se atualiza sozinho.
class Atualizador {
  Atualizador._();
  static final instancia = Atualizador._();

  static const _canal = MethodChannel('aurora/atualizacao');

  bool get suportado => kReleaseMode && !kIsWeb && (Platform.isWindows || Platform.isAndroid);

  String get _pasta => Platform.isAndroid ? 'android' : 'windows';

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
          .get(Uri.parse('$_urlBalde/$_pasta/versao.json?t=${DateTime.now().millisecondsSinceEpoch}'))
          .timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) return null;
      final json = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
      final abis = Platform.isAndroid ? (await _canal.invokeListMethod<String>('abis')) ?? const <String>[] : null;
      final nova = novaVersao(json, int.tryParse(info.buildNumber) ?? 0, abis: abis);
      disponivel.value = nova;
      debugPrint('Atualização: atual ${info.version}+${info.buildNumber}, publicada ${json['versao']}+${json['build']}');
      return nova;
    } catch (e) {
      debugPrint('Atualização: não conferiu ($e)');
      return null;
    }
  }

  /// Baixa, confere o SHA-256 e entrega ao instalador.
  Future<void> aplicar(Atualizacao a) async {
    if (Platform.isAndroid && !(await _canal.invokeMethod<bool>('podeInstalar') ?? false)) {
      await _canal.invokeMethod<void>('pedirPermissao');
      throw const PermissaoInstalar();
    }
    progresso.value = 0;
    try {
      final arquivo = await _baixar(a);
      if (Platform.isAndroid) {
        await _canal.invokeMethod<void>('instalar', {'caminho': arquivo.path});
        return;
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

  Future<File> _baixar(Atualizacao a) async {
    final pasta = await getTemporaryDirectory();
    final arquivo = File('${pasta.path}${Platform.pathSeparator}${a.instalador}');
    // O GitHub responde com redirecionamento para o arquivo; o http segue sozinho.
    final endereco = a.url ?? '$_urlBalde/$_pasta/${a.instalador}';
    final resposta = await http.Client().send(http.Request('GET', Uri.parse(endereco)));
    if (resposta.statusCode != 200) throw HttpException('download respondeu ${resposta.statusCode}');
    final total = resposta.contentLength ?? 0;
    var recebido = 0;
    final saida = arquivo.openWrite();
    final resumo = AccumulatorSink<Digest>();
    final hash = sha256.startChunkedConversion(resumo);
    await for (final pedaco in resposta.stream) {
      saida.add(pedaco);
      hash.add(pedaco);
      recebido += pedaco.length;
      if (total > 0) progresso.value = recebido / total;
    }
    await saida.close();
    hash.close();
    if (resumo.events.single.toString() != a.sha256) {
      await arquivo.delete();
      throw const FileSystemException('o arquivo baixado não confere (SHA-256)');
    }
    return arquivo;
  }
}
