import 'package:flutter/material.dart';

import '../../core/nuvem.dart';
import '../../core/tema.dart';
import '../../data/anotacoes_repo.dart';
import '../../data/banco.dart';
import '../../data/fotos/cofre.dart';
import '../../data/shape_repo.dart';
import '../componentes.dart';

/// Conta › Fotos: onde guardar as fotos do usuário (Shape hoje; perfil e
/// outras depois), quanto espaço ocupam aqui e "Limpar cache de fotos".
class SecaoFotos extends StatefulWidget {
  const SecaoFotos({super.key, required this.db, this.repo});
  final BancoAurora db;

  /// Nos testes: repositório com pasta temporária e nuvem falsa.
  final ShapeRepo? repo;

  @override
  State<SecaoFotos> createState() => _SecaoFotosState();
}

class _SecaoFotosState extends State<SecaoFotos> {
  late final ShapeRepo _repo = widget.repo ?? ShapeRepo(widget.db);
  CofreFotos get _cofre => _repo.cofre;
  int? _espaco;
  bool _lido = false;
  String? _aviso;

  @override
  void initState() {
    super.initState();
    _medir();
  }

  Future<void> _medir() async {
    int? espaco;
    try {
      espaco = await _cofre.espacoOcupado();
    } catch (e) {
      debugPrint('Fotos: não medi o espaço: $e'); // sem pasta do app (ex.: testes)
    }
    if (!mounted) return;
    setState(() {
      _espaco = espaco;
      _lido = true;
    });
  }

  Future<void> _limparCache() async {
    final ok = await perguntarFotos(
      context,
      titulo: 'Limpar cache de fotos?',
      texto: 'Apaga deste aparelho só as cópias das fotos que estão na nuvem; elas baixam de novo quando você '
          'abrir. Fotos que existem só aqui não são tocadas.',
      sim: 'Limpar',
      nao: 'Cancelar',
    );
    if (ok != true) return;
    final liberado = await _cofre.limparCache([
      for (final f in await _repo.fotosAtivas()) f.ref,
      for (final a in await AnotacoesRepo(widget.db, cofreFotos: _cofre).fotosAtivas()) a.refFoto,
    ]);
    await _medir();
    if (mounted) {
      setState(() => _aviso = liberado == 0
          ? 'Nada para limpar: nenhuma foto daqui tem cópia na nuvem.'
          : 'Cache limpo: ${tamanhoLegivel(liberado)} liberados.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    if (!_lido) return const SizedBox.shrink();
    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('FOTOS', style: rotulo(c.accent)),
          const SizedBox(height: 6),
          Text('Onde guardar minhas fotos', style: sora(16)),
          const SizedBox(height: 4),
          Text(
            'Vale para as fotos de evolução do corpo (Shape) e para as fotos e os áudios das anotações. '
            'Antes de guardar, toda foto é reduzida e perde a localização e os outros dados ocultos.',
            style: manrope(13, cor: c.muted, altura: 1.5),
          ),
          const SizedBox(height: 14),
          SeletorModoFotos(repo: _repo, aoMudar: _medir),
          const SizedBox(height: 16),
          Divider(color: c.line, height: 1),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: Text('Espaço das fotos neste aparelho', style: manrope(14, peso: FontWeight.w600)),
            ),
            Text(_espaco == null ? '…' : tamanhoLegivel(_espaco!), style: manrope(14, peso: FontWeight.w700)),
          ]),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: BotaoPilula(texto: 'Limpar cache de fotos', principal: false, aoTocar: _limparCache),
          ),
          if (_aviso != null) ...[
            const SizedBox(height: 12),
            Text(_aviso!, style: manrope(13, peso: FontWeight.w600, cor: c.teal, altura: 1.4)),
          ],
        ],
      ),
    );
  }
}

/// "Só neste aparelho" / "Sincronizar com a nuvem", com o aviso de cada modo e
/// as perguntas ao trocar (enviar as que já existem; apagar ou manter as da
/// nuvem). Usado em Conta › Fotos e no Shape, perto de onde as fotos entram.
/// [compacto]: textos curtos, para caber no cartão do check-in.
class SeletorModoFotos extends StatefulWidget {
  const SeletorModoFotos({super.key, required this.repo, this.compacto = false, this.aoMudar});
  final ShapeRepo repo;
  final bool compacto;

  /// Depois de trocar de modo (ex.: Conta mede o espaço de novo).
  final VoidCallback? aoMudar;

  @override
  State<SeletorModoFotos> createState() => _SeletorModoFotosState();
}

class _SeletorModoFotosState extends State<SeletorModoFotos> {
  ShapeRepo get _repo => widget.repo;
  CofreFotos get _cofre => _repo.cofre;
  ModoFotos? _modo;
  String? _aviso;

  @override
  void initState() {
    super.initState();
    _ler();
  }

  Future<void> _ler() async {
    final modo = await _cofre.modo();
    if (mounted) setState(() => _modo = modo);
  }

  Future<void> _escolher(ModoFotos novo) async {
    if (novo == _modo) return;
    setState(() => _aviso = null);
    if (novo == ModoFotos.nuvem) {
      await _paraNuvem();
    } else {
      await _paraAparelho();
    }
    await _ler();
    widget.aoMudar?.call();
  }

  /// "Só neste aparelho" → "Sincronizar": exige conta; oferece enviar as
  /// fotos que já existem, com progresso.
  Future<void> _paraNuvem() async {
    if (_cofre.armazem == null) {
      setState(() => _aviso = widget.compacto
          ? 'Entre na sua conta (em Conta) para sincronizar as fotos.'
          : 'Entre na sua conta (acima) para sincronizar as fotos.');
      return;
    }
    await _cofre.definirModo(ModoFotos.nuvem);
    final existentes = await _repo.paraEnviar();
    if (!mounted) return;
    if (existentes.isEmpty) {
      setState(() => _aviso = 'As próximas fotos vão para a nuvem e aparecem nos seus outros aparelhos.');
      return;
    }
    final n = existentes.length;
    final enviar = await perguntarFotos(
      context,
      titulo: 'Enviar as fotos que já estão aqui?',
      texto: 'Você tem $n ${n == 1 ? 'foto' : 'fotos'} só neste aparelho. Enviar agora para a nuvem, para '
          'aparecerem nos outros aparelhos? As próximas fotos já vão sozinhas.',
      sim: 'Enviar $n ${n == 1 ? 'foto' : 'fotos'}',
      nao: 'Só as novas',
    );
    if (enviar != true || !mounted) {
      setState(() => _aviso = 'As próximas fotos vão para a nuvem. As que já estavam aqui continuam só aqui.');
      return;
    }
    final falhas = await _comProgresso(context, 'Enviando fotos', existentes, _repo.enviarParaNuvem);
    if (!mounted) return;
    setState(() => _aviso = falhas == 0
        ? 'Pronto: ${n == 1 ? 'a foto foi enviada' : 'as $n fotos foram enviadas'} para a nuvem.'
        : '$falhas de $n não subiram (sem conexão?). Elas sobem sozinhas na próxima sincronização.');
    if (falhas > 0) {
      for (final f in await _repo.paraEnviar()) {
        await _cofre.marcarParaEnviar(f.id);
      }
    }
  }

  /// "Sincronizar" → "Só neste aparelho": avisa o risco e pergunta o que fazer
  /// com as cópias que já estão na nuvem.
  Future<void> _paraAparelho() async {
    final naNuvem = [for (final f in await _repo.fotosAtivas()) if (f.naNuvem) f];
    if (!mounted) return;
    final n = naNuvem.length;
    final escolha = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final c = ctx.cores;
        return AlertDialog(
          backgroundColor: c.surface,
          title: Text('Guardar só neste aparelho?', style: sora(18)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const AvisoRiscoFotos(),
              if (n > 0) ...[
                const SizedBox(height: 12),
                Text(
                  '$n ${n == 1 ? 'foto já está' : 'fotos já estão'} na nuvem. Apagar as cópias de lá ou mantê-las? '
                  'Antes de apagar, o Aurora guarda uma cópia de cada uma aqui.',
                  style: manrope(14, cor: c.text, altura: 1.5),
                ),
              ],
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            if (n > 0) ...[
              TextButton(onPressed: () => Navigator.pop(ctx, 'manter'), child: const Text('Manter na nuvem')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'apagar'),
                child: Text('Apagar da nuvem', style: TextStyle(color: c.bad)),
              ),
            ] else
              TextButton(onPressed: () => Navigator.pop(ctx, 'manter'), child: const Text('Guardar só aqui')),
          ],
        );
      },
    );
    if (escolha == null || !mounted) return;
    await _cofre.definirModo(ModoFotos.aparelho);
    for (final id in await _cofre.pendentesEnviar()) {
      await _cofre.esquecerEnvio(id);
    }
    if (!mounted) return;
    if (escolha == 'manter') {
      setState(() => _aviso = n > 0
          ? 'As fotos novas ficam só aqui. As que já estavam na nuvem continuam lá.'
          : 'As fotos ficam só neste aparelho.');
      return;
    }
    final falhas = await _comProgresso(context, 'Tirando fotos da nuvem', naNuvem, (f) async {
      if (!await _repo.tirarDaNuvem(f)) throw StateError('sem cópia local');
    });
    if (!mounted) return;
    setState(() => _aviso = falhas == 0
        ? 'Pronto: as fotos saíram da nuvem e ficam só aqui.'
        : '$falhas de $n continuam na nuvem: não deu para baixar uma cópia (sem conexão?). Tente de novo depois.');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final modo = _modo;
    if (modo == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Segmentos<ModoFotos>(
          opcoes: ModoFotos.values,
          selecionado: modo,
          rotulo: (m) => widget.compacto ? (m == ModoFotos.aparelho ? 'Só neste aparelho' : 'Na nuvem') : m.rotulo,
          aoEscolher: _escolher,
        ),
        const SizedBox(height: 10),
        if (modo == ModoFotos.aparelho)
          AvisoRiscoFotos(compacto: widget.compacto)
        else
          Text(
            widget.compacto
                ? 'Sobem para um espaço privado da sua conta e aparecem nos seus outros aparelhos.'
                : 'As fotos sobem para um espaço privado da sua conta (só você acessa) e aparecem nos seus outros '
                    'aparelhos. Em cada foto também dá para escolher, em vez disso, guardá-la só aqui.',
            style: manrope(widget.compacto ? 12 : 13, cor: c.muted, altura: 1.45),
          ),
        if (_aviso != null) ...[
          const SizedBox(height: 10),
          Text(_aviso!, style: manrope(13, peso: FontWeight.w600, cor: c.teal, altura: 1.4)),
        ],
      ],
    );
  }
}

/// O aviso do modo "Só neste aparelho".
class AvisoRiscoFotos extends StatelessWidget {
  const AvisoRiscoFotos({super.key, this.compacto = false});
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Container(
      padding: EdgeInsets.all(compacto ? 10 : 12),
      decoration: BoxDecoration(
        color: c.warn.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.warn.withValues(alpha: 0.35)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.warning_amber_rounded, color: c.warn, size: compacto ? 18 : 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            compacto
                ? 'Não aparecem nos outros aparelhos e se perdem se o app for desinstalado ou o aparelho for trocado.'
                : 'As fotos ficam só neste aparelho: não aparecem nos outros e se perdem se o app for desinstalado '
                    'ou se o aparelho for perdido ou trocado.',
            style: manrope(compacto ? 12 : 13, cor: c.text, altura: 1.45),
          ),
        ),
      ]),
    );
  }
}

Future<bool?> perguntarFotos(
  BuildContext context, {
  required String titulo,
  required String texto,
  required String sim,
  required String nao,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) {
      final c = ctx.cores;
      return AlertDialog(
        backgroundColor: c.surface,
        title: Text(titulo, style: sora(18)),
        content: Text(texto, style: manrope(14, cor: c.text, altura: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(nao)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(sim)),
        ],
      );
    },
  );
}

/// Roda [acao] em cada foto mostrando "3 de 12"; devolve quantas falharam.
Future<int> _comProgresso(
  BuildContext context,
  String titulo,
  List<FotoShape> fotos,
  Future<void> Function(FotoShape) acao,
) async {
  final feitas = ValueNotifier(0);
  final navegador = Navigator.of(context, rootNavigator: true);
  var falhas = 0;
  final dialogo = showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: ctx.cores.surface,
        title: Text(titulo, style: sora(18)),
        content: ValueListenableBuilder<int>(
          valueListenable: feitas,
          builder: (ctx, n, _) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            LinearProgressIndicator(value: fotos.isEmpty ? 1 : n / fotos.length, minHeight: 6, borderRadius: BorderRadius.circular(3)),
            const SizedBox(height: 10),
            Text('$n de ${fotos.length}', style: manrope(13, cor: ctx.cores.muted)),
          ]),
        ),
      ),
    ),
  );
  for (final f in fotos) {
    try {
      await acao(f);
    } catch (e) {
      debugPrint('Fotos: ${f.id}: ${mensagemDeErro(e)}');
      falhas++;
    }
    feitas.value++;
  }
  if (navegador.mounted) navegador.pop();
  await dialogo;
  feitas.dispose();
  return falhas;
}
