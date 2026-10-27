import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/objetivos_repo.dart';
import '../../data/visao_repo.dart';
import '../componentes.dart';
import '../icone_ia.dart';
import '../shell.dart';
import '../vidro.dart';
import 'foco.dart';

/// Visão em blocos (direção "Bento Noturno", 27/10/2026): em foco grande à
/// esquerda, "a seguir" e os números do dia à direita; embaixo, a linha do dia
/// e, ao lado, semana e painel das áreas. Em telas médias os blocos viram
/// pares; no celular, uma coluna só.
class VisaoPage extends StatefulWidget {
  const VisaoPage({
    super.key,
    required this.ir,
    required this.irRotina,
    this.aoBuscar,
  });

  final ValueChanged<Secao> ir;
  final ValueChanged<AbaRotina> irRotina;

  /// Abre a busca em tudo (Ctrl+K). Nulo = o campo não aparece no cabeçalho.
  final VoidCallback? aoBuscar;

  @override
  State<VisaoPage> createState() => _VisaoPageState();
}

class _VisaoPageState extends State<VisaoPage> {
  VisaoRepo? _repo;
  Stream<ResumoVisao>? _resumo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (_repo?.db != db) {
      _repo = VisaoRepo(db);
      _resumo = _repo!.observarResumo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ResumoVisao>(
      stream: _resumo,
      builder: (context, snap) {
        if (snap.hasError) {
          return Text('Não consegui ler os dados: ${snap.error}');
        }
        final r = snap.data;
        if (r == null) return const SizedBox(height: 200);
        return _Conteudo(
          resumo: r,
          repo: _repo!,
          ir: widget.ir,
          irRotina: widget.irRotina,
          aoBuscar: widget.aoBuscar,
        );
      },
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({
    required this.resumo,
    required this.repo,
    required this.ir,
    required this.irRotina,
    this.aoBuscar,
  });

  final ResumoVisao resumo;
  final VisaoRepo repo;
  final ValueChanged<Secao> ir;
  final ValueChanged<AbaRotina> irRotina;
  final VoidCallback? aoBuscar;

  @override
  Widget build(BuildContext context) {
    final agora = agoraLocal();
    final feitos = resumo.linha.where((i) => i.feito).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Cabecalho(resumo: resumo, agora: agora, aoBuscar: aoBuscar, ir: ir),
        const SizedBox(height: Espaco.md),
        LayoutBuilder(
          builder: (context, box) {
            final largura = box.maxWidth;
            final foco = _CartaoFoco(
              itens: _itensFoco(resumo),
              feitos: feitos,
              total: resumo.linha.length,
              estreito: largura < 520,
            );
            final seguir = _CartaoASeguir(
              item: _proximo(resumo.linha, agora),
              agora: agora,
            );
            final numeros = _CartaoNumeros(
              feitosTarefas: resumo.linha
                  .where((i) => i.tipo == TipoItemLinha.tarefa && i.feito)
                  .length,
              totalTarefas: resumo.linha
                  .where((i) => i.tipo == TipoItemLinha.tarefa)
                  .length,
              feitosHabitos: resumo.habitosFeitos,
              totalHabitos: resumo.habitos.length,
              objetivo: resumo.objetivo,
              aPagarCentavos: resumo.aPagarCentavos,
              contasAPagar: resumo.contasAPagar,
              ir: ir,
            );
            final dia = _CartaoLinhaDoDia(
              itens: resumo.linha,
              repo: repo,
              irRotina: irRotina,
              maximo: largura >= 940 ? 5 : 4,
            );
            final semana = _CartaoSemana(
              dias: resumo.semana,
              insight: resumo.insights.isEmpty ? null : resumo.insights.first,
              irRotina: irRotina,
            );
            final painel = _CartaoAreas(
              resumo: resumo,
              ir: ir,
              irRotina: irRotina,
              emLinha: largura >= 940,
            );

            if (largura >= 940) {
              return Column(
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 7, child: foco),
                        const SizedBox(width: Espaco.md - 2),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              Expanded(child: seguir),
                              const SizedBox(height: Espaco.md - 2),
                              Expanded(child: numeros),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Espaco.md - 2),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 7, child: dia),
                        const SizedBox(width: Espaco.md - 2),
                        Expanded(flex: 5, child: semana),
                      ],
                    ),
                  ),
                  const SizedBox(height: Espaco.md - 2),
                  painel,
                ],
              );
            }
            if (largura >= 640) {
              return Column(
                children: [
                  foco,
                  const SizedBox(height: Espaco.md - 2),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: seguir),
                        const SizedBox(width: Espaco.md - 2),
                        Expanded(child: numeros),
                      ],
                    ),
                  ),
                  const SizedBox(height: Espaco.md - 2),
                  dia,
                  const SizedBox(height: Espaco.md - 2),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: semana),
                        const SizedBox(width: Espaco.md - 2),
                        Expanded(child: painel),
                      ],
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [
                foco,
                const SizedBox(height: Espaco.sm + 4),
                seguir,
                const SizedBox(height: Espaco.sm + 4),
                numeros,
                const SizedBox(height: Espaco.sm + 4),
                dia,
                const SizedBox(height: Espaco.sm + 4),
                semana,
                const SizedBox(height: Espaco.sm + 4),
                painel,
              ],
            );
          },
        ),
      ],
    );
  }

  List<ItemFoco> _itensFoco(ResumoVisao r) {
    final agora = agoraLocal();
    return [
      for (final o in r.compromissosHoje)
        if (!o.terminou(agora))
          ItemFoco(
            o.compromisso.titulo,
            o.emAndamento(agora)
                ? 'Agora · Compromisso'
                : (o.diaInteiro
                      ? 'Hoje · Compromisso'
                      : 'Hoje às ${hora(emLocal(o.inicio))} · Compromisso'),
          ),
      for (final h in r.habitos)
        if (!h.feito) ItemFoco(h.habito.nome, 'Para hoje · Hábitos'),
      for (final o in r.tarefasHoje)
        ItemFoco(
          o.tarefa.titulo,
          o.momento != null && o.horario != null
              ? 'Hoje às ${hora(emLocal(o.momento!))} · Tarefas'
              : 'Para hoje · Tarefas',
        ),
    ];
  }
}

/// Cabeçalho: data em caixa alta, saudação grande com o nome na cor da marca e,
/// no computador, o campo de busca sempre à vista.
class _Cabecalho extends StatelessWidget {
  const _Cabecalho({
    required this.resumo,
    required this.agora,
    required this.aoBuscar,
    required this.ir,
  });

  final ResumoVisao resumo;
  final DateTime agora;
  final VoidCallback? aoBuscar;
  final ValueChanged<Secao> ir;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final desktop = MediaQuery.sizeOf(context).width >= larguraDesktop;
    final nome = resumo.nome;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${dataCabecalho(agora)} · ${hora(agora)}',
                style: manrope(
                  11,
                  peso: FontWeight.w700,
                  cor: c.muted,
                  espaco: 1.5,
                ),
              ),
              const SizedBox(height: Espaco.sm),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: nome.isEmpty
                          ? saudacao(agora)
                          : '${saudacao(agora)}, ',
                    ),
                    if (nome.isNotEmpty)
                      TextSpan(
                        text: nome,
                        style: TextStyle(color: c.accent),
                      ),
                  ],
                ),
                style: sora(31, altura: 1.08, espaco: -.8),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (desktop && aoBuscar != null) ...[
          const SizedBox(width: Espaco.md),
          _CampoBusca(aoTocar: aoBuscar!),
          const SizedBox(width: Espaco.sm + 2),
          BotaoRedondo(
            icone: iconeIa,
            dica: 'Abrir a Aurora (assistente)',
            aoTocar: () => ir(Secao.assistente),
          ),
        ],
      ],
    );
  }
}

/// Campo que só parece campo: abre a busca em tudo (Ctrl+K) ao toque.
class _CampoBusca extends StatelessWidget {
  const _CampoBusca({required this.aoTocar});
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final cantos = BorderRadius.circular(13);
    return Semantics(
      button: true,
      label: 'Buscar em tudo',
      child: Material(
        color: Theme.of(context).brightness == Brightness.dark
            ? c.surface.withValues(alpha: 0.55)
            : c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: cantos,
          side: BorderSide(color: c.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 250),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 11, 12, 11),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_rounded, size: 19, color: c.muted),
                  const SizedBox(width: Espaco.sm + 1),
                  Text('Buscar em tudo', style: manrope(13, cor: c.muted)),
                  const SizedBox(width: Espaco.lg),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: c.line),
                    ),
                    child: Text(
                      'Ctrl K',
                      style: manrope(
                        10.5,
                        peso: FontWeight.w700,
                        cor: c.muted,
                        espaco: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cartão comum dos blocos da grade.
class _Bloco extends StatelessWidget {
  const _Bloco({required this.child, this.aoTocar});

  final Widget child;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) => Cartao(
    padding: const EdgeInsets.all(16),
    aoTocar: aoTocar,
    raio: 22,
    child: child,
  );
}

/// Cartão do "em foco": fundo com lavagem de aurora e fio de luz no topo.
class _CartaoDestaque extends StatelessWidget {
  const _CartaoDestaque({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final raio = BorderRadius.circular(24);
    return Vidro(
      raio: raio,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0, 0.55, 1],
                    colors: [
                      c.gradIni.withValues(alpha: 0.11),
                      c.gradFim.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1.6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    c.gradIni,
                    c.teal,
                    c.violeta,
                    c.violeta.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.32, 0.66, 1],
                ),
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }
}

/// "Em foco agora": um item por vez, fila do que vem depois e o anel do dia.
class _CartaoFoco extends StatelessWidget {
  const _CartaoFoco({
    required this.itens,
    required this.feitos,
    required this.total,
    required this.estreito,
  });

  final List<ItemFoco> itens;
  final int feitos;
  final int total;

  /// Tela estreita (celular): o anel sobe para a linha do rótulo.
  final bool estreito;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return ListenableBuilder(
      listenable: ControleFoco.instancia,
      builder: (context, _) {
        final foco = ControleFoco.instancia;
        final n = itens.length;
        final indice = n == 0 ? 0 : foco.indice % n;
        final item = n == 0
            ? const ItemFoco('Tudo em dia', 'Nada pendente para hoje.')
            : itens[indice];
        final depois = n > 1 ? itens[(indice + 1) % n] : null;
        final ainda = n > 2 ? itens[(indice + 2) % n] : null;
        // Sem LayoutBuilder aqui: o cartão vive dentro de um IntrinsicHeight
        // (a grade) e ele não sabe medir tamanho intrínseco.
        final anel = _Anel(
          fracao: total == 0 ? 0 : feitos / total,
          tamanho: estreito ? 62 : 76,
          espessura: 6,
          gradiente: true,
          centro: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$feitos/$total',
                style: sora(estreito ? 13.5 : 16, espaco: -.3),
              ),
              Text(
                'feitos',
                style: manrope(
                  8.5,
                  peso: FontWeight.w800,
                  cor: c.muted,
                  espaco: 1,
                ),
              ),
            ],
          ),
        );
        final rotulo = _RotuloPonto('Em foco agora', cor: c.accent);
        final corpo = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!estreito) ...[rotulo, const SizedBox(height: Espaco.sm + 2)],
            Text(
              item.titulo,
              style: sora(estreito ? 23 : 26, altura: 1.15, espaco: -.5),
            ),
            const SizedBox(height: 6),
            Text(item.detalhe, style: manrope(13.5, cor: c.muted)),
            const SizedBox(height: Espaco.md + 2),
            Wrap(
              spacing: Espaco.sm + 2,
              runSpacing: Espaco.sm + 2,
              children: [
                BotaoPilula(texto: foco.rotulo, aoTocar: foco.alternar),
                if (n > 1)
                  BotaoPilula(
                    texto: 'Focar em outra',
                    principal: false,
                    aoTocar: foco.proximo,
                  ),
              ],
            ),
          ],
        );
        final rodape = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: Espaco.lg),
            _BarraDegrade(fracao: n == 0 ? 1 : (indice + 1) / n),
            const SizedBox(height: Espaco.sm),
            Text(
              '${n == 0 ? 0 : indice + 1} de $n do foco',
              style: manrope(11.5, peso: FontWeight.w700, cor: c.muted),
            ),
            if (depois != null) ...[
              const SizedBox(height: Espaco.md),
              Divider(height: 1, color: c.line.withValues(alpha: 0.55)),
              const SizedBox(height: Espaco.md - 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _MiniFoco(rotulo: 'Depois do foco', item: depois),
                  ),
                  if (ainda != null) ...[
                    const SizedBox(width: Espaco.md),
                    Expanded(
                      child: _MiniFoco(rotulo: 'Ainda hoje', item: ainda),
                    ),
                  ],
                ],
              ),
            ],
          ],
        );
        final Widget conteudo = estreito
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: rotulo,
                        ),
                      ),
                      anel,
                    ],
                  ),
                  const SizedBox(height: Espaco.sm + 4),
                  corpo,
                  rodape,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: corpo),
                      const SizedBox(width: Espaco.md),
                      anel,
                    ],
                  ),
                  rodape,
                ],
              );
        return _CartaoDestaque(child: conteudo);
      },
    );
  }
}

class _MiniFoco extends StatelessWidget {
  const _MiniFoco({required this.rotulo, required this.item});
  final String rotulo;
  final ItemFoco item;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo.toUpperCase(),
          style: manrope(9, peso: FontWeight.w800, cor: c.muted, espaco: 1.3),
        ),
        const SizedBox(height: 6),
        Text(
          item.titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: manrope(13, peso: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          item.detalhe,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: manrope(11.5, cor: c.muted),
        ),
      ],
    );
  }
}

/// "A seguir": o próximo item do dia com a hora grande.
class _CartaoASeguir extends StatelessWidget {
  const _CartaoASeguir({required this.item, required this.agora});
  final ItemLinha? item;
  final DateTime agora;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final i = item;
    if (i == null) {
      return _Bloco(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Rotulo('A seguir'),
            const SizedBox(height: Espaco.md),
            Text('Nada mais hoje', style: sora(22, espaco: -.4)),
            const SizedBox(height: 4),
            Text(
              'O dia está livre daqui para frente.',
              style: manrope(12.5, cor: c.muted),
            ),
          ],
        ),
      );
    }
    final (rotulo, cor) = _tipo(c, i.tipo);
    final quando = _quando(i, agora);
    return _Bloco(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Rotulo('A seguir'),
          const SizedBox(height: Espaco.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                i.hora == null ? 'Hoje' : hora(emLocal(i.hora!)),
                style: sora(i.hora == null ? 26 : 34, espaco: -1.4),
              ),
              const Spacer(),
              if (quando != null) _EtiquetaTipo(quando, cor: c.teal),
            ],
          ),
          const SizedBox(height: Espaco.sm + 2),
          Text(
            i.titulo,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: manrope(15, peso: FontWeight.w700),
          ),
          const SizedBox(height: Espaco.sm),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(shape: BoxShape.circle, color: cor),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  i.atrasado ? '$rotulo · atrasada' : rotulo,
                  style: manrope(
                    11.5,
                    peso: FontWeight.w700,
                    cor: i.atrasado ? c.bad : c.muted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Hoje em números": anéis de tarefas, hábitos e objetivo (quando há).
class _CartaoNumeros extends StatelessWidget {
  const _CartaoNumeros({
    required this.feitosTarefas,
    required this.totalTarefas,
    required this.feitosHabitos,
    required this.totalHabitos,
    required this.objetivo,
    required this.aPagarCentavos,
    required this.contasAPagar,
    required this.ir,
  });

  final int feitosTarefas;
  final int totalTarefas;
  final int feitosHabitos;
  final int totalHabitos;
  final Objetivo? objetivo;
  final int aPagarCentavos;
  final int contasAPagar;
  final ValueChanged<Secao> ir;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final o = objetivo;
    final fracaoObjetivo = o == null ? null : _fracaoObjetivo(o);
    return _Bloco(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Rotulo('Hoje em números'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Espaco.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AnelNumero(
                  rotulo: 'Tarefas',
                  valor: '$feitosTarefas/$totalTarefas',
                  fracao: totalTarefas == 0 ? 0 : feitosTarefas / totalTarefas,
                  cor: c.corTarefa,
                ),
                _AnelNumero(
                  rotulo: 'Hábitos',
                  valor: '$feitosHabitos/$totalHabitos',
                  fracao: totalHabitos == 0 ? 0 : feitosHabitos / totalHabitos,
                  cor: c.corHabito,
                ),
                if (o != null && fracaoObjetivo != null)
                  _AnelNumero(
                    rotulo: 'Objetivo',
                    valor: '${(fracaoObjetivo * 100).round()}%',
                    fracao: fracaoObjetivo,
                    cor: c.teal,
                  ),
              ],
            ),
          ),
          if (aPagarCentavos > 0)
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => ir(Secao.financas),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 15,
                        color: c.muted,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          '${reais(aPagarCentavos)} a pagar · $contasAPagar ${contasAPagar == 1 ? 'conta' : 'contas'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: manrope(
                            11.5,
                            peso: FontWeight.w600,
                            cor: c.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Progresso do objetivo: 0 quando o alvo é o próprio início.
  static double? _fracaoObjetivo(Objetivo o) {
    final faixa = o.valorAlvo - o.valorInicial;
    if (faixa == 0) return null;
    return ((o.valorAtual - o.valorInicial) / faixa).clamp(0.0, 1.0);
  }
}

class _AnelNumero extends StatelessWidget {
  const _AnelNumero({
    required this.rotulo,
    required this.valor,
    required this.fracao,
    required this.cor,
  });

  final String rotulo;
  final String valor;
  final double fracao;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Anel(
          fracao: fracao,
          tamanho: 56,
          espessura: 5,
          cor: cor,
          centro: Text(valor, style: sora(12.5, espaco: -.3)),
        ),
        const SizedBox(height: 7),
        Text(
          rotulo.toUpperCase(),
          style: manrope(8.5, peso: FontWeight.w800, cor: c.muted, espaco: 1),
        ),
      ],
    );
  }
}

/// Linha do dia compacta: hora, ponto do tipo, título e o tipo à direita.
class _CartaoLinhaDoDia extends StatelessWidget {
  const _CartaoLinhaDoDia({
    required this.itens,
    required this.repo,
    required this.irRotina,
    required this.maximo,
  });

  final List<ItemLinha> itens;
  final VisaoRepo repo;
  final ValueChanged<AbaRotina> irRotina;
  final int maximo;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final agora = agoraLocal();
    final visiveis = itens.take(maximo).toList();
    final restantes = itens.length - visiveis.length;
    // O item de agora: o primeiro pendente que já começou (ou o primeiro pendente).
    ItemLinha? atual;
    for (final i in itens) {
      if (i.feito) continue;
      if (i.hora != null && i.hora!.isAfter(agora)) continue;
      atual = i;
      break;
    }

    final lista = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < visiveis.length; i++) ...[
          if (i > 0) Divider(height: 1, color: c.line.withValues(alpha: 0.45)),
          _LinhaItem(
            item: visiveis[i],
            destaque: identical(visiveis[i], atual),
            aoTocar: visiveis[i].habitoId == null
                ? null
                : () => repo.alternarHabito(
                    visiveis[i].habitoId!,
                    !visiveis[i].feito,
                  ),
          ),
        ],
      ],
    );

    final feitos = itens.where((i) => i.feito).length;

    return _Bloco(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Linha do dia', style: sora(19, espaco: -.4)),
                  ),
                  _LinkAcao(
                    texto: 'Ver calendário',
                    aoTocar: () => irRotina(AbaRotina.calendario),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Tudo o que é de hoje, na ordem do relógio.',
                style: manrope(12, cor: c.muted),
              ),
              const SizedBox(height: Espaco.sm + 2),
              if (itens.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Espaco.md),
                  child: Row(
                    children: [
                      Icon(Icons.wb_twilight_rounded, size: 18, color: c.muted),
                      const SizedBox(width: Espaco.sm + 2),
                      Expanded(
                        child: Text(
                          'Dia livre: nada marcado para hoje.',
                          style: manrope(13, cor: c.muted),
                        ),
                      ),
                    ],
                  ),
                )
              else
                lista,
            ],
          ),
          if (itens.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: Espaco.sm),
              child: Row(
                children: [
                  Text(
                    '$feitos de ${itens.length} feitos',
                    style: manrope(11.5, peso: FontWeight.w700, cor: c.muted),
                  ),
                  if (restantes > 0) ...[
                    const SizedBox(width: Espaco.sm),
                    Expanded(
                      child: Text(
                        '· e mais $restantes ${restantes == 1 ? 'item' : 'itens'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: manrope(
                          11.5,
                          peso: FontWeight.w600,
                          cor: c.muted,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LinhaItem extends StatelessWidget {
  const _LinhaItem({required this.item, required this.destaque, this.aoTocar});

  final ItemLinha item;
  final bool destaque;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final (rotulo, cor) = _tipo(c, item.tipo);
    final titulo = item.feito
        ? manrope(13.5, peso: FontWeight.w500, cor: c.muted, altura: 1.2)
        : manrope(
            13.5,
            peso: FontWeight.w600,
            cor: item.atrasado ? c.bad : (destaque ? c.accent : c.text),
            altura: 1.2,
          );
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 9, 4, 9),
          decoration: destaque
              ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      c.accent.withValues(alpha: 0.11),
                      c.accent.withValues(alpha: 0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: Stack(
            children: [
              // Marca do "agora": barra fina à esquerda, sem deslocar a linha.
              if (destaque)
                Positioned(
                  left: 0,
                  top: 2,
                  bottom: 2,
                  child: Container(
                    width: 2.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [c.gradIni, c.gradFim],
                      ),
                    ),
                  ),
                ),
              Row(
                children: [
                  SizedBox(
                    width: 46,
                    child: Text(
                      item.hora == null ? 'Dia' : hora(emLocal(item.hora!)),
                      style: manrope(
                        11.5,
                        peso: FontWeight.w700,
                        cor: destaque ? c.accent : c.muted,
                        espaco: 0.2,
                      ),
                    ),
                  ),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.feito ? cor.withValues(alpha: 0.45) : cor,
                      boxShadow: destaque
                          ? [
                              BoxShadow(
                                color: cor.withValues(alpha: 0.55),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: Espaco.sm + 4),
                  Expanded(
                    child: Text(
                      item.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titulo.copyWith(
                        decoration: item.feito
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: c.muted.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: Espaco.sm),
                  Text(
                    rotulo.toUpperCase(),
                    style: manrope(
                      8.5,
                      peso: FontWeight.w800,
                      cor: c.muted,
                      espaco: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Semana em barras, com o dia de hoje em degradê e um insight embaixo.
class _CartaoSemana extends StatelessWidget {
  const _CartaoSemana({
    required this.dias,
    required this.insight,
    required this.irRotina,
  });

  final List<DiaSemana> dias;
  final String? insight;
  final ValueChanged<AbaRotina> irRotina;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final maior = dias.fold<int>(0, (m, d) => d.total > m ? d.total : m);
    final vazio = maior == 0;
    final fim = dias.isEmpty ? null : dias.last.dia;
    return _Bloco(
      aoTocar: () => irRotina(AbaRotina.calendario),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(child: Text('Semana', style: sora(19, espaco: -.4))),
              if (dias.isNotEmpty && fim != null)
                Text(
                  '${diaMesCurto(dias.first.dia)} – ${diaMesCurto(fim)}',
                  style: manrope(11, peso: FontWeight.w700, cor: c.muted),
                ),
            ],
          ),
          if (vazio) ...[
            // Semana sem compromissos, tarefas, lembretes nem contas: um gráfico
            // de sete zeros pareceria quebrado.
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Espaco.md),
              child: Row(
                children: [
                  Icon(Icons.nights_stay_rounded, size: 17, color: c.muted),
                  const SizedBox(width: Espaco.sm + 2),
                  Expanded(
                    child: Text(
                      'Nada marcado nesta semana.',
                      style: manrope(12.5, cor: c.muted),
                    ),
                  ),
                ],
              ),
            ),
            if (insight != null) _LinhaInsight(texto: insight!),
          ] else ...[
            SizedBox(
              height: 84,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < dias.length; i++)
                    Expanded(
                      child: Column(
                        children: [
                          // A barra fica no espaço que sobra do rótulo: com texto
                          // grande ela encolhe em vez de estourar a coluna.
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: 14,
                                height: 10 + 44 * dias[i].total / maior,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  gradient: i == 0 && dias[i].total > 0
                                      ? LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [c.gradIni, c.gradFim],
                                        )
                                      : null,
                                  color: i == 0 && dias[i].total > 0
                                      ? null
                                      : c.line,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            i == 0
                                ? 'Hoje'
                                : _primeiraMaiuscula(
                                    DateFormat(
                                      'EEE',
                                      'pt_BR',
                                    ).format(dias[i].dia).replaceAll('.', ''),
                                  ),
                            maxLines: 1,
                            style: manrope(
                              9,
                              peso: FontWeight.w800,
                              cor: i == 0 ? c.accent : c.muted,
                              espaco: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (insight != null) _LinhaInsight(texto: insight!),
          ],
        ],
      ),
    );
  }

  static String _primeiraMaiuscula(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/// Linha curta de insight (ponto turquesa + frase).
class _LinhaInsight extends StatelessWidget {
  const _LinhaInsight({required this.texto});
  final String texto;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Row(
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(shape: BoxShape.circle, color: c.teal),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            texto,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: manrope(11.5, cor: c.muted, altura: 1.35),
          ),
        ),
      ],
    );
  }
}

/// Painel das áreas: quatro blocos pequenos, numa linha (tela larga) ou 2 x 2.
class _CartaoAreas extends StatelessWidget {
  const _CartaoAreas({
    required this.resumo,
    required this.ir,
    required this.irRotina,
    this.emLinha = false,
  });

  final ResumoVisao resumo;
  final ValueChanged<Secao> ir;
  final ValueChanged<AbaRotina> irRotina;

  /// Tela larga: a faixa ocupa a largura toda e os blocos ficam lado a lado.
  final bool emLinha;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final o = resumo.objetivo;
    final agora = agoraLocal();
    final atrasadas = resumo.tarefasAtrasadas;

    final blocos = [
      _MiniArea(
        rotulo: 'Tarefas',
        valor: atrasadas > 0
            ? '$atrasadas ${atrasadas == 1 ? 'atrasada' : 'atrasadas'}'
            : 'em dia',
        cor: atrasadas > 0 ? c.bad : null,
        aoTocar: () => irRotina(AbaRotina.hoje),
      ),
      _MiniArea(
        rotulo: 'Hábitos',
        valor: '${resumo.habitosFeitos} de ${resumo.habitos.length}',
        aoTocar: () => irRotina(AbaRotina.habitos),
      ),
      _MiniArea(
        rotulo: nomeDoMes(agora),
        valor: reais(resumo.aPagarCentavos),
        aoTocar: () => ir(Secao.financas),
      ),
      _MiniArea(
        rotulo: 'Objetivo',
        valor: o == null ? '—' : valorMeta(o.valorAtual, o.unidade),
        aoTocar: () => ir(Secao.objetivos),
      ),
    ];

    Widget par(Widget a, Widget b) => Padding(
      padding: const EdgeInsets.only(top: Espaco.sm),
      child: Row(
        children: [
          Expanded(child: a),
          const SizedBox(width: Espaco.sm),
          Expanded(child: b),
        ],
      ),
    );

    return _Bloco(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Painel das áreas', style: sora(19, espaco: -.4)),
              ),
              Text(
                'abrir',
                style: manrope(11, peso: FontWeight.w700, cor: c.muted),
              ),
            ],
          ),
          if (emLinha)
            Padding(
              padding: const EdgeInsets.only(top: Espaco.sm + 2),
              child: Row(
                children: [
                  for (var i = 0; i < blocos.length; i++) ...[
                    if (i > 0) const SizedBox(width: Espaco.sm),
                    Expanded(child: blocos[i]),
                  ],
                ],
              ),
            )
          else ...[
            par(blocos[0], blocos[1]),
            par(blocos[2], blocos[3]),
          ],
        ],
      ),
    );
  }
}

class _MiniArea extends StatelessWidget {
  const _MiniArea({
    required this.rotulo,
    required this.valor,
    required this.aoTocar,
    this.cor,
  });

  final String rotulo;
  final String valor;
  final VoidCallback aoTocar;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.line.withValues(alpha: 0.7)),
            color: Colors.white.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark ? 0.03 : 0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rotulo.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: manrope(
                  8.5,
                  peso: FontWeight.w800,
                  cor: c.muted,
                  espaco: 1.1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                valor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: sora(16, cor: cor, espaco: -.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rótulo pequeno em caixa alta com um ponto de cor (marca do "em foco").
class _RotuloPonto extends StatelessWidget {
  const _RotuloPonto(this.texto, {required this.cor});
  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cor,
            boxShadow: [
              BoxShadow(color: cor.withValues(alpha: 0.5), blurRadius: 8),
            ],
          ),
        ),
        const SizedBox(width: Espaco.sm),
        Text(
          texto.toUpperCase(),
          style: manrope(9, peso: FontWeight.w800, cor: cor, espaco: 1.4),
        ),
      ],
    );
  }
}

/// Rótulo pequeno em caixa alta (título de bloco).
class _Rotulo extends StatelessWidget {
  const _Rotulo(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Text(
    texto.toUpperCase(),
    style: manrope(
      9,
      peso: FontWeight.w800,
      cor: context.cores.muted,
      espaco: 1.4,
    ),
  );
}

/// Ação de texto com seta ("Ver calendário →").
class _LinkAcao extends StatelessWidget {
  const _LinkAcao({required this.texto, required this.aoTocar});
  final String texto;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                texto,
                style: manrope(11.5, peso: FontWeight.w700, cor: c.accent),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 14, color: c.accent),
            ],
          ),
        ),
      ),
    );
  }
}

/// Etiqueta pequena e arredondada ("em 4 h", "atrasada").
class _EtiquetaTipo extends StatelessWidget {
  const _EtiquetaTipo(this.texto, {required this.cor});
  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(999),
      color: cor.withValues(alpha: 0.12),
      border: Border.all(color: cor.withValues(alpha: 0.32)),
    ),
    child: Text(
      texto,
      style: manrope(10.5, peso: FontWeight.w800, cor: cor),
    ),
  );
}

/// Barra fina com o degradê da marca.
class _BarraDegrade extends StatelessWidget {
  const _BarraDegrade({required this.fracao});
  final double fracao;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 5,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: c.surface2)),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fracao.clamp(0.0, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [c.gradIni, c.gradFim]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Anel de progresso desenhado à mão (arco com ponta arredondada).
class _Anel extends StatelessWidget {
  const _Anel({
    required this.fracao,
    required this.tamanho,
    required this.espessura,
    this.cor,
    this.gradiente = false,
    this.centro,
  });

  final double fracao;
  final double tamanho;
  final double espessura;
  final Color? cor;
  final bool gradiente;
  final Widget? centro;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: tamanho,
      child: CustomPaint(
        painter: _PintorAnel(
          fracao: fracao,
          espessura: espessura,
          cor: cor,
          gradiente: gradiente,
          cores: context.cores,
        ),
        child: centro == null ? null : Center(child: centro),
      ),
    );
  }
}

class _PintorAnel extends CustomPainter {
  _PintorAnel({
    required this.fracao,
    required this.espessura,
    required this.cores,
    this.cor,
    this.gradiente = false,
  });

  final double fracao;
  final double espessura;
  final AuroraCores cores;
  final Color? cor;
  final bool gradiente;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final raio = (size.shortestSide - espessura) / 2;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = espessura
      ..color = cores.line.withValues(alpha: 0.65);
    canvas.drawCircle(centro, raio, base);

    final f = fracao.clamp(0.0, 1.0);
    if (f <= 0) return;
    final arco = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = espessura
      ..strokeCap = StrokeCap.round;
    if (gradiente) {
      arco.shader = SweepGradient(
        colors: [cores.gradIni, cores.teal, cores.gradFim, cores.gradIni],
        stops: const [0, 0.35, 0.62, 1],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: centro, radius: raio));
    } else {
      arco.color = cor ?? cores.accent;
    }
    canvas.drawArc(
      Rect.fromCircle(center: centro, radius: raio),
      -math.pi / 2,
      2 * math.pi * f,
      false,
      arco,
    );
  }

  @override
  bool shouldRepaint(_PintorAnel antigo) =>
      antigo.fracao != fracao ||
      antigo.espessura != espessura ||
      antigo.cor != cor ||
      antigo.gradiente != gradiente ||
      antigo.cores != cores;
}

/// Próximo item pendente: o primeiro com hora ainda por vir; se não houver,
/// o primeiro pendente do dia.
ItemLinha? _proximo(List<ItemLinha> linha, DateTime agora) {
  for (final i in linha) {
    if (i.feito || i.hora == null) continue;
    if (i.hora!.isAfter(agora)) return i;
  }
  for (final i in linha) {
    if (!i.feito) return i;
  }
  return null;
}

/// "em 4 h", "em 20 min" ou nulo quando o horário já passou.
String? _quando(ItemLinha item, DateTime agora) {
  final h = item.hora;
  if (h == null) return null;
  final d = h.difference(agora);
  if (d.isNegative) return null;
  if (d.inMinutes < 60) return 'em ${math.max(1, d.inMinutes)} min';
  if (d.inHours < 24) return 'em ${d.inHours} h';
  return 'amanhã';
}

/// Rótulo e cor fixos de cada tipo da Rotina (magenta só para atrasado).
(String, Color) _tipo(AuroraCores c, TipoItemLinha tipo) => switch (tipo) {
  TipoItemLinha.compromisso => ('Compromisso', c.corCompromisso),
  TipoItemLinha.tarefa => ('Tarefa', c.corTarefa),
  TipoItemLinha.lembrete => ('Lembrete', c.corLembrete),
  TipoItemLinha.conta => ('Conta', c.accentFill),
  TipoItemLinha.habito => ('Hábito', c.corHabito),
};
