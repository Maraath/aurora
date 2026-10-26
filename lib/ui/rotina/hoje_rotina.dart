import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/compromissos_repo.dart';
import '../../data/habitos_repo.dart';
import '../../data/lembretes_repo.dart';
import '../../data/rotina_repo.dart';
import '../../data/tarefas_repo.dart';
import '../componentes.dart';
import '../habitos/linha_habito.dart';
import '../tarefas/linha_tarefa.dart';
import 'form_rotina.dart';
import 'linhas_rotina.dart';
import 'todos_lembretes.dart';

/// A partir desta largura as 4 colunas ficam lado a lado.
const larguraColunasRotina = 900.0;

/// Filtro da lista única (tela estreita).
enum _Filtro {
  tudo('Tudo'),
  compromissos('Compromissos'),
  fazer('Fazer'),
  habitos('Hábitos'),
  lembretes('Lembretes');

  const _Filtro(this.rotulo);
  final String rotulo;
}

/// Rotina › Hoje: resumo do dia e as quatro colunas (Compromissos, Fazer,
/// Hábitos, Lembretes), cada uma na cor do seu tipo.
class HojeRotina extends StatefulWidget {
  const HojeRotina({super.key, required this.verCalendario});

  final VoidCallback verCalendario;

  @override
  State<HojeRotina> createState() => _HojeRotinaState();
}

class _HojeRotinaState extends State<HojeRotina> {
  RotinaRepo? _repo;
  Stream<QuadroRotina>? _quadro;
  var _filtro = _Filtro.tudo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = AuroraEscopo.de(context).db;
    if (_repo?.db != db) {
      _repo = RotinaRepo(db);
      _quadro = _repo!.observarQuadro();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuadroRotina>(
      stream: _quadro,
      builder: (context, snap) {
        if (snap.hasError) return Text('Não consegui ler a rotina: ${snap.error}');
        final q = snap.data;
        if (q == null) return const SizedBox(height: 200);
        return _conteudo(context, q);
      },
    );
  }

  Widget _conteudo(BuildContext context, QuadroRotina q) {
    final agora = agoraLocal();
    final hoje = dataLocal(agora);
    final db = _repo!.db;
    final d = _DadosHoje(q, hoje, agora);

    final colunas = <_Filtro, Widget>{
      _Filtro.compromissos: _Coluna(
        titulo: 'Compromissos',
        icone: Icons.event_rounded,
        cor: context.cores.corCompromisso,
        descricao: 'Com dia e hora marcados',
        contador: '${d.compromissos.length} hoje',
        vazio: 'Nenhum compromisso hoje.',
        filhos: [
          for (final o in d.compromissos)
            LinhaCompromisso(
              ocorrencia: o,
              agora: agora,
              aoEditar: () => abrirFormCompromisso(context, compromisso: o.compromisso),
            ),
        ],
        rodape: [
          _BotaoColuna(
            icone: Icons.calendar_month_rounded,
            texto: 'Ver no calendário',
            aoTocar: widget.verCalendario,
          ),
        ],
        aoAdicionar: () => abrirFormRotina(context, tipo: TipoRotina.compromisso),
      ),
      _Filtro.fazer: _Coluna(
        titulo: 'Fazer',
        icone: Icons.check_box_outlined,
        cor: context.cores.corTarefa,
        descricao: 'Coisas que terminam',
        contador: '${d.fazerFeitas}/${d.fazer.length}',
        progresso: d.fazer.isEmpty ? null : d.fazerFeitas / d.fazer.length,
        vazio: 'Nada atrasado nem para hoje.',
        filhos: [
          for (final o in d.fazer)
            LinhaTarefa(
              ocorrencia: o,
              hoje: hoje,
              aoAlternar: () => TarefasRepo(db).alternar(o, !o.feita),
              aoEditar: () => abrirFormRotina(context, item: o.tarefa),
            ),
        ],
        aoAdicionar: () => abrirFormRotina(context, tipo: TipoRotina.tarefa),
      ),
      _Filtro.habitos: _Coluna(
        titulo: 'Hábitos',
        icone: Icons.donut_large_rounded,
        cor: context.cores.corHabito,
        descricao: 'O que você repete para construir',
        contador: '${d.habitosFeitos}/${d.habitos.length}',
        progresso: d.habitos.isEmpty ? null : d.habitosFeitos / d.habitos.length,
        vazio: 'Nenhum hábito para hoje.',
        filhos: [
          for (final h in d.habitos)
            LinhaHabito(
              habito: h,
              feito: q.habitos.feito(h.id, hoje),
              detalhe: detalheHabito(h, sequencia: q.habitos.sequencia(h, hoje)),
              aoAlternar: () => HabitosRepo(db).alternar(h.id, hoje, !q.habitos.feito(h.id, hoje)),
              aoEditar: () => abrirFormRotina(context, item: h),
            ),
        ],
        aoAdicionar: () => abrirFormRotina(context, tipo: TipoRotina.habito),
      ),
      _Filtro.lembretes: _Coluna(
        titulo: 'Lembretes',
        icone: Icons.notifications_none_rounded,
        cor: context.cores.corLembrete,
        descricao: 'Só para não esquecer',
        contador: '${d.lembretesATocar} a tocar',
        vazio: 'Nenhum lembrete hoje.',
        filhos: [
          for (final l in d.lembretes)
            LinhaLembrete(
              visto: l.visto,
              toque: l.toque,
              hoje: hoje,
              aoAlternar: () => LembretesRepo(db).alternarAtivo(l.lembrete.id, !l.lembrete.ativo),
              aoEditar: () => abrirFormRotina(context, item: l.lembrete),
            ),
        ],
        rodape: [
          _BotaoColuna(
            icone: Icons.list_rounded,
            texto: 'Todos os lembretes',
            aoTocar: () => abrirTodosLembretes(context),
          ),
        ],
        aoAdicionar: () => abrirFormRotina(context, tipo: TipoRotina.lembrete),
      ),
    };

    return LayoutBuilder(
      builder: (context, box) {
        final largo = box.maxWidth >= larguraColunasRotina;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Cabecalho(hoje: hoje),
            const SizedBox(height: 16),
            _Resumo(dados: d),
            const SizedBox(height: 18),
            if (largo)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (i, col) in colunas.values.indexed) ...[
                    if (i > 0) const SizedBox(width: 14),
                    Expanded(child: col),
                  ],
                ],
              )
            else ...[
              _Filtros(atual: _filtro, aoEscolher: (f) => setState(() => _filtro = f)),
              const SizedBox(height: 12),
              if (_filtro == _Filtro.tudo)
                ..._listaUnica(context, d, colunas)
              else
                colunas[_filtro]!,
            ],
          ],
        );
      },
    );
  }

  /// Tela estreita, "Tudo": atrasadas no topo e o resto do dia por horário.
  List<Widget> _listaUnica(BuildContext context, _DadosHoje d, Map<_Filtro, Widget> colunas) {
    final db = _repo!.db;
    final hoje = d.hoje;
    final itens = <(DateTime?, int, Widget)>[];
    for (final o in d.compromissos) {
      itens.add((
        o.diaInteiro ? null : o.inicio,
        0,
        LinhaCompromisso(
          ocorrencia: o,
          agora: d.agora,
          aoEditar: () => abrirFormCompromisso(context, compromisso: o.compromisso),
        ),
      ));
    }
    for (final o in d.fazer) {
      itens.add((
        o.atrasada ? DateTime(0) : (o.horario == null ? null : o.momento),
        1,
        LinhaTarefa(
          ocorrencia: o,
          hoje: hoje,
          aoAlternar: () => TarefasRepo(db).alternar(o, !o.feita),
          aoEditar: () => abrirFormRotina(context, item: o.tarefa),
        ),
      ));
    }
    for (final h in d.habitos) {
      final p = h.horario?.split(':');
      itens.add((
        p == null ? null : instanteLocal(hoje, int.parse(p[0]), int.parse(p[1])),
        2,
        LinhaHabito(
          habito: h,
          feito: d.q.habitos.feito(h.id, hoje),
          detalhe: detalheHabito(h, sequencia: d.q.habitos.sequencia(h, hoje)),
          aoAlternar: () => HabitosRepo(db).alternar(h.id, hoje, !d.q.habitos.feito(h.id, hoje)),
          aoEditar: () => abrirFormRotina(context, item: h),
        ),
      ));
    }
    for (final l in d.lembretes) {
      itens.add((
        l.toque,
        3,
        LinhaLembrete(
          visto: l.visto,
          toque: l.toque,
          hoje: hoje,
          aoAlternar: () => LembretesRepo(db).alternarAtivo(l.lembrete.id, !l.lembrete.ativo),
          aoEditar: () => abrirFormRotina(context, item: l.lembrete),
        ),
      ));
    }
    // Sem horário vai para o fim; empate fica na ordem dos tipos.
    itens.sort((a, b) {
      final (ma, ta, _) = a;
      final (mb, tb, _) = b;
      if ((ma == null) != (mb == null)) return ma == null ? 1 : -1;
      final c = ma == null ? 0 : ma.compareTo(mb!);
      return c != 0 ? c : ta.compareTo(tb);
    });
    if (itens.isEmpty) return const [Vazio('Nada para hoje. Toque em Novo para criar.')];
    return [
      for (final (_, _, w) in itens) Padding(padding: const EdgeInsets.only(bottom: 8), child: w),
    ];
  }
}

/// O que a aba mostra, calculado uma vez por quadro.
class _DadosHoje {
  _DadosHoje(this.q, this.hoje, this.agora)
      : compromissos = q.compromissos.doDia(hoje),
        fazer = q.fazer(hoje),
        habitos = q.habitos.doDia(hoje),
        lembretes = q.lembretesDoDia(hoje);

  final QuadroRotina q;
  final DateTime hoje;
  final DateTime agora;
  final List<OcorrenciaCompromisso> compromissos;
  final List<OcorrenciaTarefa> fazer;
  final List<Habito> habitos;
  final List<LembreteDoDia> lembretes;

  int get fazerFeitas => fazer.where((o) => o.feita).length;
  int get habitosFeitos => habitos.where((h) => q.habitos.feito(h.id, hoje)).length;
  int get atrasadas => fazer.where((o) => o.atrasada).length;
  int get lembretesATocar => lembretes.where((l) => l.lembrete.ativo && l.toque.isAfter(agora)).length;

  OcorrenciaCompromisso? get compromissoAgora => compromissos.where((o) => o.emAndamento(agora)).firstOrNull;
  OcorrenciaCompromisso? get proximoCompromisso =>
      compromissos.where((o) => !o.diaInteiro && o.inicio.isAfter(agora)).firstOrNull;

  /// Maior sequência entre os hábitos de hoje.
  (Habito, int)? get melhorSequencia {
    (Habito, int)? melhor;
    for (final h in habitos) {
      final s = q.habitos.sequencia(h, hoje);
      if (s >= 2 && (melhor == null || s > melhor.$2)) melhor = (h, s);
    }
    return melhor;
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.hoje});
  final DateTime hoje;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hoje', style: sora(24)),
              Text('${DateFormat('EEEE', 'pt_BR').format(hoje).capitalizar()}, ${diaMesLongo(hoje)}',
                  style: manrope(13, cor: c.muted)),
            ],
          ),
        ),
        BotaoNovoRotina(aoTocar: () => abrirFormRotina(context)),
      ],
    );
  }
}

/// "+ Novo" da Rotina: abre a folha única no tipo tarefa.
class BotaoNovoRotina extends StatelessWidget {
  const BotaoNovoRotina({super.key, required this.aoTocar});
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Semantics(
      button: true,
      label: 'Novo na rotina',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(gradient: c.gradiente),
          child: InkWell(
            onTap: aoTocar,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add_rounded, size: 20, color: c.noAccent),
                const SizedBox(width: 6),
                Text('Novo', style: manrope(14, peso: FontWeight.w700, cor: c.noAccent)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _Resumo extends StatelessWidget {
  const _Resumo({required this.dados});
  final _DadosHoje dados;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final d = dados;
    final total = d.fazer.length + d.habitos.length;
    final feitos = d.fazerFeitas + d.habitosFeitos;
    final agora = d.compromissoAgora;
    final proximo = d.proximoCompromisso;
    final seq = d.melhorSequencia;
    final faltam = total - feitos;
    return Cartao(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: total == 0 ? 0 : feitos / total,
                    strokeWidth: 5,
                    strokeCap: StrokeCap.round,
                    backgroundColor: c.surface2,
                    color: c.corHabito,
                  ),
                ),
                Text('$feitos/$total', style: sora(13)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(total == 0 ? 'Dia livre' : '$feitos de $total feitos hoje', style: sora(16)),
                Text(
                  total == 0
                      ? 'Nada para marcar hoje.'
                      : faltam == 0
                          ? 'Tudo feito. Bom trabalho!'
                          : '${saudacao(d.agora)}! ${faltam == 1 ? 'Falta 1 coisa' : 'Faltam $faltam coisas'} para fechar o dia.',
                  style: manrope(13, cor: c.muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (agora != null)
                      _Chip(
                        icone: Icons.event_rounded,
                        cor: c.corCompromisso,
                        texto: agora.diaInteiro || agora.fim == null
                            ? 'Hoje: ${agora.compromisso.titulo}'
                            : 'Agora: ${agora.compromisso.titulo} até ${hora(emLocal(agora.fim!))}',
                      ),
                    if (proximo != null)
                      _Chip(
                        icone: Icons.event_outlined,
                        cor: c.corCompromisso,
                        texto: 'Depois: ${proximo.compromisso.titulo} às ${hora(emLocal(proximo.inicio))}',
                      ),
                    if (d.atrasadas > 0)
                      _Chip(
                        icone: Icons.schedule_rounded,
                        cor: c.bad,
                        texto: d.atrasadas == 1 ? '1 atrasada' : '${d.atrasadas} atrasadas',
                      ),
                    if (seq != null)
                      _Chip(
                        icone: Icons.local_fire_department_rounded,
                        cor: c.warn,
                        texto: '${seq.$1.nome}: ${seq.$2} seguidos',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icone, required this.cor, required this.texto});
  final IconData icone;
  final Color cor;
  final String texto;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(color: cor.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icone, size: 14, color: cor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(texto,
                overflow: TextOverflow.ellipsis, style: manrope(12, peso: FontWeight.w700, cor: cor)),
          ),
        ]),
      );
}

/// Uma coluna da aba Hoje: cabeçalho na cor do tipo, barra de progresso
/// (quando faz sentido), os itens e "Adicionar".
class _Coluna extends StatelessWidget {
  const _Coluna({
    required this.titulo,
    required this.icone,
    required this.cor,
    required this.descricao,
    required this.contador,
    required this.vazio,
    required this.filhos,
    required this.aoAdicionar,
    this.progresso,
    this.rodape = const [],
  });

  final String titulo;
  final IconData icone;
  final Color cor;
  final String descricao;
  final String contador;
  final String vazio;
  final List<Widget> filhos;
  final VoidCallback aoAdicionar;
  final double? progresso;
  final List<Widget> rodape;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Cartao(
      padding: const EdgeInsets.all(12),
      sombra: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Icon(icone, size: 20, color: cor),
            const SizedBox(width: 8),
            Expanded(child: Text(titulo, style: sora(15))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(999)),
              child: Text(contador, style: manrope(12, peso: FontWeight.w700, cor: c.muted)),
            ),
          ]),
          const SizedBox(height: 2),
          Text(descricao, style: manrope(12, cor: c.muted)),
          if (progresso != null) ...[
            const SizedBox(height: 10),
            BarraProgresso(fracao: progresso!, cor: cor),
          ],
          const SizedBox(height: 12),
          if (filhos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(vazio, textAlign: TextAlign.center, style: manrope(13, cor: c.muted)),
            ),
          for (final f in filhos) Padding(padding: const EdgeInsets.only(bottom: 8), child: f),
          for (final r in rodape) Padding(padding: const EdgeInsets.only(bottom: 8), child: r),
          _BotaoColuna(icone: Icons.add_rounded, texto: 'Adicionar', aoTocar: aoAdicionar, rotulo: 'Adicionar em $titulo'),
        ],
      ),
    );
  }
}

class _BotaoColuna extends StatelessWidget {
  const _BotaoColuna({required this.icone, required this.texto, required this.aoTocar, this.rotulo});
  final IconData icone;
  final String texto;
  final VoidCallback aoTocar;
  final String? rotulo;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Semantics(
      button: true,
      label: rotulo ?? texto,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: c.line)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: SizedBox(
            height: 40,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icone, size: 18, color: c.muted),
              const SizedBox(width: 6),
              Flexible(
                child: Text(texto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: manrope(13, peso: FontWeight.w600, cor: c.muted)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Filtros extends StatelessWidget {
  const _Filtros({required this.atual, required this.aoEscolher});
  final _Filtro atual;
  final ValueChanged<_Filtro> aoEscolher;

  @override
  Widget build(BuildContext context) => SubAbas<_Filtro>(
        opcoes: _Filtro.values,
        selecionado: atual,
        rotulo: (f) => f.rotulo,
        aoEscolher: aoEscolher,
      );
}

extension on String {
  String capitalizar() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}
