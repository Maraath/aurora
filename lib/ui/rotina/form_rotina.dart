import 'package:drift/drift.dart' show BooleanExpressionOperators, Value;
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/compromissos_repo.dart';
import '../../data/habitos_repo.dart';
import '../../data/lembretes_repo.dart';
import '../../data/tarefas_repo.dart';
import '../formulario.dart';
import '../habitos/form_habito.dart';
import '../lembretes/form_lembrete.dart';
import '../tarefas/form_tarefa.dart';
import 'contexto_form.dart';
import 'form_compromisso.dart';

/// Os quatro tipos da Rotina, cada um com a sua cor fixa.
enum TipoRotina {
  tarefa('Fazer uma vez', 'tarefa', Icons.task_alt_rounded, 'Uma tarefa que termina quando você marca.'),
  habito('Hábito', 'hábito', Icons.donut_large_rounded,
      'Algo que você quer fazer com constância. Conta a sequência de dias.'),
  compromisso('Compromisso', 'compromisso', Icons.event_rounded,
      'Tem dia e hora marcados (e às vezes um lugar). Aparece no Calendário.'),
  lembrete('Lembrete', 'lembrete', Icons.notifications_none_rounded,
      'Só um aviso no dia e na hora que você escolher, sem nada para marcar.');

  const TipoRotina(this.rotulo, this.nome, this.icone, this.dica);
  final String rotulo;

  /// Em minúsculas, para frases ("Converter em hábito").
  final String nome;
  final IconData icone;
  final String dica;

  Color cor(AuroraCores c) => switch (this) {
        tarefa => c.corTarefa,
        habito => c.corHabito,
        compromisso => c.corCompromisso,
        lembrete => c.corLembrete,
      };

  static TipoRotina? de(Object? item) => switch (item) {
        Tarefa() => tarefa,
        Habito() => habito,
        Compromisso() => compromisso,
        Lembrete() => lembrete,
        _ => null,
      };
}

/// Abre o formulário de compromisso novo (no [dia]) ou de edição.
Future<void> abrirFormCompromisso(BuildContext context, {Compromisso? compromisso, DateTime? dia}) =>
    abrirFormRotina(context, tipo: TipoRotina.compromisso, item: compromisso, dia: dia);

/// A folha única da Rotina: os quatro tipos no topo e os campos do escolhido.
/// Ao editar, tocar em outro tipo CONVERTE o item (cria o novo, apaga o antigo,
/// com "Desfazer"). [trocarTipo] falso esconde o seletor (etapa de projeto,
/// lembrete criado por um item).
Future<void> abrirFormRotina(
  BuildContext context, {
  TipoRotina tipo = TipoRotina.tarefa,
  Object? item,
  DateTime? dia,
  TimeOfDay? hora,
  String? projetoInicial,
  bool trocarTipo = true,
}) async {
  final db = AuroraEscopo.de(context).db;
  final metas = await (db.select(db.metas)..where((m) => m.apagadoEm.isNull())).get();
  final projetos = await (db.select(db.projetos)
        ..where((p) => p.apagadoEm.isNull() & p.status.equals('ativo')))
      .get();
  final avisoTarefa = item is Tarefa && await TarefasRepo(db).temLembrete(item.id);
  final avisoHabito = item is Habito &&
      (await (db.select(db.lembretes)
                ..where((l) => l.itemTipo.equals('habito') & l.itemId.equals(item.id) & l.apagadoEm.isNull()))
              .get())
          .isNotEmpty;
  // Dias com compromisso, para o pontinho no calendário da data.
  final hoje = hojeLocal();
  final diasComCompromisso = (await CompromissosRepo(db).carregar())
      .porDia(somarDias(hoje, -62), somarDias(hoje, 400))
      .keys
      .toSet();
  if (!context.mounted) return;
  final avisos = ScaffoldMessenger.maybeOf(context);
  await abrirFolha<void>(
    context,
    (_) => _FormRotina(
      db: db,
      tipoInicial: TipoRotina.de(item) ?? tipo,
      item: item,
      dia: dia,
      hora: hora,
      metas: metas,
      projetos: projetos,
      projetoInicial: projetoInicial,
      avisoTarefa: avisoTarefa,
      avisoHabito: avisoHabito,
      trocarTipo: trocarTipo,
      marcado: diasComCompromisso.contains,
      avisos: avisos,
    ),
  );
}

class _FormRotina extends StatefulWidget {
  const _FormRotina({
    required this.db,
    required this.tipoInicial,
    required this.item,
    required this.dia,
    required this.hora,
    required this.metas,
    required this.projetos,
    required this.projetoInicial,
    required this.avisoTarefa,
    required this.avisoHabito,
    required this.trocarTipo,
    required this.marcado,
    required this.avisos,
  });

  final BancoAurora db;
  final TipoRotina tipoInicial;
  final Object? item;
  final DateTime? dia;
  final TimeOfDay? hora;
  final List<Meta> metas;
  final List<Projeto> projetos;
  final String? projetoInicial;
  final bool avisoTarefa;
  final bool avisoHabito;
  final bool trocarTipo;
  final bool Function(DateTime) marcado;
  final ScaffoldMessengerState? avisos;

  @override
  State<_FormRotina> createState() => _FormRotinaState();
}

class _FormRotinaState extends State<_FormRotina> {
  late TipoRotina _tipo = widget.tipoInicial;
  late final TextEditingController _titulo = TextEditingController(text: _tituloDoItem ?? '');

  String? get _tituloDoItem => switch (widget.item) {
        Tarefa t => t.titulo,
        Habito h => h.nome,
        Compromisso c => c.titulo,
        Lembrete l => l.texto,
        _ => null,
      };

  /// Data e hora do item que está sendo convertido (vão para o tipo novo).
  (DateTime?, TimeOfDay?) get _quandoDoItem {
    TimeOfDay hora(DateTime i) => TimeOfDay(hour: emLocal(i).hour, minute: emLocal(i).minute);
    return switch (widget.item) {
      Tarefa t when t.prazo != null => (dataLocal(t.prazo!), t.prazoTemHora ? hora(t.prazo!) : null),
      Compromisso c => (dataLocal(c.inicio), c.diaInteiro ? null : hora(c.inicio)),
      Lembrete l => (dataLocal(l.quando), hora(l.quando)),
      Habito h when h.horario != null =>
        (null, TimeOfDay(hour: int.parse(h.horario!.split(':')[0]), minute: int.parse(h.horario!.split(':')[1]))),
      _ => (widget.dia, widget.hora),
    };
  }

  bool get _convertendo => widget.item != null && _tipo != widget.tipoInicial;

  @override
  void dispose() {
    _titulo.dispose();
    super.dispose();
  }

  /// O item novo já foi salvo: apaga o antigo e oferece desfazer.
  Future<void> _converter(String novoId) async {
    final antigo = widget.item!;
    final de = widget.tipoInicial, para = _tipo;
    await excluirDaRotina(widget.db, de, _idDe(antigo));
    widget.avisos?.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text('Virou ${para.nome}.'),
      action: SnackBarAction(
        label: 'Desfazer',
        onPressed: () async {
          await restaurarNaRotina(widget.db, de, _idDe(antigo));
          await excluirDaRotina(widget.db, para, novoId);
        },
      ),
    ));
  }

  static String _idDe(Object item) => switch (item) {
        Tarefa t => t.id,
        Habito h => h.id,
        Compromisso c => c.id,
        Lembrete l => l.id,
        _ => throw ArgumentError(item),
      };

  @override
  Widget build(BuildContext context) {
    final (data, hora) = _convertendo || widget.item == null ? _quandoDoItem : (null, null);
    final ctx = ContextoForm(
      cabecalho: widget.trocarTipo
          ? SeletorTipoRotina(
              tipo: _tipo,
              editando: widget.item != null,
              aoEscolher: (t) => setState(() => _tipo = t),
            )
          : null,
      titulo: _titulo,
      data: data,
      hora: hora,
      tituloFolha: _convertendo ? 'Converter em ${_tipo.nome}' : null,
      aoSalvo: _convertendo ? _converter : null,
      marcado: widget.marcado,
    );
    final original = _convertendo ? null : widget.item;
    final db = widget.db;
    return KeyedSubtree(
      key: ValueKey(_tipo),
      child: switch (_tipo) {
        TipoRotina.tarefa => FormTarefa(
            repo: TarefasRepo(db),
            tarefa: original as Tarefa?,
            metas: widget.metas,
            projetos: widget.projetos,
            projetoInicial: widget.projetoInicial,
            avisarInicial: original != null && widget.avisoTarefa,
            contexto: ctx,
          ),
        TipoRotina.habito => FormHabito(
            repo: HabitosRepo(db),
            habito: original as Habito?,
            metas: widget.metas,
            avisarInicial: original != null && widget.avisoHabito,
            contexto: ctx,
          ),
        TipoRotina.compromisso => FormCompromisso(
            repo: CompromissosRepo(db),
            compromisso: original as Compromisso?,
            contexto: ctx,
          ),
        TipoRotina.lembrete => FormLembrete(
            repo: LembretesRepo(db),
            lembrete: original as Lembrete?,
            contexto: ctx,
          ),
      },
    );
  }
}

/// Os quatro tipos lado a lado (2 × 2 em tela estreita), cada um na sua cor,
/// com a explicação do escolhido embaixo.
class SeletorTipoRotina extends StatelessWidget {
  const SeletorTipoRotina({super.key, required this.tipo, required this.aoEscolher, this.editando = false});

  final TipoRotina tipo;
  final ValueChanged<TipoRotina> aoEscolher;
  final bool editando;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    Widget botao(TipoRotina t) {
      final ativo = t == tipo;
      final cor = t.cor(c);
      return Semantics(
        button: true,
        selected: ativo,
        label: 'Tipo: ${t.rotulo}',
        excludeSemantics: true,
        child: Material(
          color: ativo ? Color.alphaBlend(cor.withValues(alpha: 0.16), c.surface2) : c.surface2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: ativo ? cor : c.line, width: ativo ? 1.5 : 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => aoEscolher(t),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(t.icone, size: 22, color: cor),
                  const SizedBox(height: 4),
                  Text(
                    t.rotulo,
                    textAlign: TextAlign.center,
                    style: manrope(12.5, peso: FontWeight.w700, cor: ativo ? c.text : c.muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, box) {
        final colunas = box.maxWidth < 400 ? 2 : 4;
        final largura = (box.maxWidth - 8 * (colunas - 1)) / colunas;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final t in TipoRotina.values) SizedBox(width: largura, child: botao(t))],
            ),
            const SizedBox(height: 8),
            Text(
              editando ? '${tipo.dica} Toque em outro tipo para converter.' : tipo.dica,
              style: manrope(12.5, cor: c.muted, altura: 1.4),
            ),
          ],
        );
      },
    );
  }
}

/// Apaga (marca apagado_em) um item da Rotina pelo tipo.
Future<void> excluirDaRotina(BancoAurora db, TipoRotina tipo, String id) => switch (tipo) {
      TipoRotina.tarefa => TarefasRepo(db).excluir(id),
      TipoRotina.habito => HabitosRepo(db).excluir(id),
      TipoRotina.compromisso => CompromissosRepo(db).excluir(id),
      TipoRotina.lembrete => LembretesRepo(db).excluir(id),
    };

/// Desfaz [excluirDaRotina] (só a linha do item; o aviso ligado volta ao salvar de novo).
Future<void> restaurarNaRotina(BancoAurora db, TipoRotina tipo, String id) async {
  final agora = Value(DateTime.now());
  switch (tipo) {
    case TipoRotina.tarefa:
      await (db.update(db.tarefas)..where((t) => t.id.equals(id)))
          .write(TarefasCompanion(apagadoEm: const Value(null), atualizadoEm: agora));
    case TipoRotina.habito:
      await (db.update(db.habitos)..where((t) => t.id.equals(id)))
          .write(HabitosCompanion(apagadoEm: const Value(null), atualizadoEm: agora));
    case TipoRotina.compromisso:
      await (db.update(db.compromissos)..where((t) => t.id.equals(id)))
          .write(CompromissosCompanion(apagadoEm: const Value(null), atualizadoEm: agora));
    case TipoRotina.lembrete:
      await (db.update(db.lembretes)..where((t) => t.id.equals(id)))
          .write(LembretesCompanion(apagadoEm: const Value(null), atualizadoEm: agora));
  }
}
