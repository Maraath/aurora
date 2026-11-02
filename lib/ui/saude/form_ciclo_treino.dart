import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/saude_repo.dart';
import '../formulario.dart';
import 'biblioteca_ui.dart';

/// Abre a folha de configuração ou criação do Treino Intercalado (Ciclo rotativo).
Future<void> abrirFormCicloTreino(BuildContext context, {QuadroSaude? quadro}) async {
  final db = AuroraEscopo.de(context).db;
  final repo = SaudeRepo(db);
  final q = quadro ?? await repo.carregar();
  if (!context.mounted) return;
  return abrirFolha<void>(context, (_) => _FormCicloTreino(repo: repo, quadro: q));
}

class _ItemExercicioRapido {
  _ItemExercicioRapido({String nome = '', int series = 3, int reps = 10, double? carga})
      : nome = TextEditingController(text: nome),
        series = TextEditingController(text: '$series'),
        reps = TextEditingController(text: '$reps'),
        carga = TextEditingController(text: carga == null ? '' : numero(carga));

  final TextEditingController nome;
  final TextEditingController series;
  final TextEditingController reps;
  final TextEditingController carga;
  String? midia;
  String? grupo;
  String? nomeDaBiblioteca;

  String? get midiaValida => nome.text.trim() == nomeDaBiblioteca ? midia : null;

  void dispose() {
    nome.dispose();
    series.dispose();
    reps.dispose();
    carga.dispose();
  }
}

class _DiaConfig {
  _DiaConfig({
    required this.dia,
    this.isDescanso = false,
    this.treinoId,
    String nome = '',
    String foco = '',
    List<_ItemExercicioRapido>? exercicios,
  })  : nome = TextEditingController(text: nome),
        foco = TextEditingController(text: foco),
        exercicios = exercicios ?? [_ItemExercicioRapido()];

  int dia;
  bool isDescanso;
  String? treinoId; // Se selecionou um treino existente
  final TextEditingController nome;
  final TextEditingController foco;
  final List<_ItemExercicioRapido> exercicios;

  void dispose() {
    nome.dispose();
    foco.dispose();
    for (final e in exercicios) {
      e.dispose();
    }
  }
}

class _FormCicloTreino extends StatefulWidget {
  const _FormCicloTreino({required this.repo, required this.quadro});
  final SaudeRepo repo;
  final QuadroSaude quadro;

  @override
  State<_FormCicloTreino> createState() => _FormCicloTreinoState();
}

class _FormCicloTreinoState extends State<_FormCicloTreino> {
  late bool _ativo;
  late int _diaAtualHoje;
  late final List<_DiaConfig> _dias;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final ciclo = widget.quadro.ciclo;
    _ativo = ciclo?.ativo ?? true;
    _diaAtualHoje = ciclo != null && ciclo.passos.isNotEmpty ? ciclo.numeroDia(hojeLocal()) : 1;

    if (ciclo != null && ciclo.passos.isNotEmpty) {
      _dias = [
        for (var i = 0; i < ciclo.passos.length; i++)
          _criarDiaDePasso(ciclo.passos[i], i + 1),
      ];
    } else {
      // Cria padrão inicial clássico como o usuário exemplificou:
      // Dia 1: Peito, tríceps e ombro
      // Dia 2: Costas, bíceps e ombro
      // Dia 3: Perna e ombro
      // Dia 4: Descanso
      final treinosExistentes = widget.quadro.treinos;
      if (treinosExistentes.isNotEmpty) {
        _dias = [
          for (var i = 0; i < treinosExistentes.length; i++)
            _DiaConfig(
              dia: i + 1,
              treinoId: treinosExistentes[i].treino.id,
              nome: treinosExistentes[i].treino.nome,
              foco: treinosExistentes[i].treino.foco ?? '',
            ),
          _DiaConfig(
            dia: treinosExistentes.length + 1,
            isDescanso: true,
            nome: 'Descanso',
            foco: 'Recuperação muscular',
          ),
        ];
      } else {
        _dias = [
          _DiaConfig(
            dia: 1,
            nome: 'Treino A',
            foco: 'Peito, tríceps e ombro',
            exercicios: [
              _ItemExercicioRapido(nome: 'Supino reto', series: 4, reps: 10),
              _ItemExercicioRapido(nome: 'Tríceps corda', series: 3, reps: 12),
              _ItemExercicioRapido(nome: 'Elevação lateral', series: 3, reps: 12),
            ],
          ),
          _DiaConfig(
            dia: 2,
            nome: 'Treino B',
            foco: 'Costas, bíceps e ombro',
            exercicios: [
              _ItemExercicioRapido(nome: 'Puxada frontal', series: 4, reps: 10),
              _ItemExercicioRapido(nome: 'Rosca direta', series: 3, reps: 10),
              _ItemExercicioRapido(nome: 'Crucifixo invertido', series: 3, reps: 12),
            ],
          ),
          _DiaConfig(
            dia: 3,
            nome: 'Treino C',
            foco: 'Perna e ombro',
            exercicios: [
              _ItemExercicioRapido(nome: 'Agachamento', series: 4, reps: 10),
              _ItemExercicioRapido(nome: 'Leg press', series: 3, reps: 12),
              _ItemExercicioRapido(nome: 'Desenvolvimento ombro', series: 3, reps: 10),
            ],
          ),
          _DiaConfig(
            dia: 4,
            isDescanso: true,
            nome: 'Descanso',
            foco: 'Recuperação muscular',
          ),
        ];
      }
    }
  }

  _DiaConfig _criarDiaDePasso(PassoCiclo passo, int diaNum) {
    TreinoCompleto? tExistente;
    if (passo.treinoId != null) {
      tExistente = widget.quadro.treinos.where((x) => x.treino.id == passo.treinoId).firstOrNull;
    }
    return _DiaConfig(
      dia: diaNum,
      isDescanso: passo.isDescanso,
      treinoId: passo.treinoId,
      nome: tExistente?.treino.nome ?? passo.nome ?? (passo.isDescanso ? 'Descanso' : 'Treino $diaNum'),
      foco: tExistente?.treino.foco ?? passo.foco ?? (passo.isDescanso ? 'Recuperação muscular' : ''),
    );
  }

  @override
  void dispose() {
    for (final d in _dias) {
      d.dispose();
    }
    super.dispose();
  }

  void _reordenarDias() {
    for (var i = 0; i < _dias.length; i++) {
      _dias[i].dia = i + 1;
    }
    if (_diaAtualHoje > _dias.length) {
      _diaAtualHoje = _dias.length;
    }
  }

  void _adicionarDia({required bool descanso}) {
    setState(() {
      final proxDia = _dias.length + 1;
      _dias.add(
        _DiaConfig(
          dia: proxDia,
          isDescanso: descanso,
          nome: descanso ? 'Descanso' : 'Treino ${String.fromCharCode(64 + proxDia)}',
          foco: descanso ? 'Recuperação muscular' : '',
        ),
      );
    });
  }

  void _removerDia(int index) {
    if (_dias.length <= 2) {
      setState(() => _erro = 'O ciclo precisa de pelo menos 2 dias.');
      return;
    }
    setState(() {
      final r = _dias.removeAt(index);
      r.dispose();
      _reordenarDias();
    });
  }

  Future<void> _salvar() async {
    if (_dias.isEmpty) {
      setState(() => _erro = 'Adicione ao menos um dia ao ciclo.');
      return;
    }

    // Salva ou cria os treinos dos dias que não tiverem treino existente
    final passos = <PassoCiclo>[];
    for (var i = 0; i < _dias.length; i++) {
      final d = _dias[i];
      final diaNum = i + 1;
      if (d.isDescanso) {
        passos.add(PassoCiclo(
          dia: diaNum,
          nome: d.nome.text.trim().isEmpty ? 'Descanso' : d.nome.text.trim(),
          foco: d.foco.text.trim().isEmpty ? 'Recuperação muscular' : d.foco.text.trim(),
        ));
      } else {
        String? finalTreinoId = d.treinoId;
        final nome = d.nome.text.trim().isEmpty ? 'Treino $diaNum' : d.nome.text.trim();
        final foco = d.foco.text.trim().isEmpty ? null : d.foco.text.trim();

        if (finalTreinoId == null) {
          // Cria o treino novo na ficha
          final itensValidos = [
            for (final ex in d.exercicios)
              if (ex.nome.text.trim().isNotEmpty)
                (
                  nome: ex.nome.text.trim(),
                  series: (int.tryParse(ex.series.text.trim()) ?? 3).clamp(1, 20),
                  repeticoes: (int.tryParse(ex.reps.text.trim()) ?? 10).clamp(1, 100),
                  cargaInicial: lerNumero(ex.carga.text),
                ),
          ];

          // Se não preencheu exercícios específicos, coloca 1 padrão para a ficha
          final listaSalvar = itensValidos.isNotEmpty
              ? itensValidos
              : [(nome: 'Exercício principal', series: 3, repeticoes: 10, cargaInicial: null)];

          finalTreinoId = await widget.repo.salvarTreino(
            TreinosCompanion.insert(
              nome: nome,
              foco: foco != null ? Value(foco) : const Value.absent(),
              diasSemana: const Value(0), // Sem dia fixo na semana, pois é cíclico
            ),
            listaSalvar,
          );
        }

        passos.add(PassoCiclo(
          dia: diaNum,
          treinoId: finalTreinoId,
          nome: nome,
          foco: foco,
        ));
      }
    }

    // Calcula dataInicio de forma que hoje corresponda ao _diaAtualHoje selecionado
    final hoje = hojeLocal();
    final diaAlvo = _diaAtualHoje.clamp(1, passos.length);
    final dataInicio = DateTime(hoje.year, hoje.month, hoje.day).subtract(Duration(days: diaAlvo - 1));

    final ciclo = CicloTreino(
      ativo: _ativo,
      dataInicio: dataInicio,
      passos: passos,
    );

    await widget.repo.salvarCiclo(ciclo);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _desativar() async {
    await widget.repo.desativarCiclo();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Folha(
      titulo: 'Treino intercalado (ciclo)',
      textoSalvar: 'Salvar treino intercalado',
      aoSalvar: _salvar,
      aoExcluir: widget.quadro.ciclo != null && widget.quadro.ciclo!.ativo ? _desativar : null,
      campos: [
        // Descrição e status
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.line),
          ),
          child: Row(
            children: [
              Icon(Icons.autorenew_rounded, color: c.teal, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ciclo rotativo de treinos', style: manrope(15, peso: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      'Os treinos e descansos se revezam em ordem contínua, independente do dia da semana.',
                      style: manrope(12, cor: c.muted, altura: 1.3),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _ativo,
                activeThumbColor: c.teal,
                onChanged: (v) => setState(() => _ativo = v),
              ),
            ],
          ),
        ),

        // Qual dia do ciclo é hoje
        Campo(
          rotulo: 'Qual dia do ciclo é hoje?',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _dias.length; i++) ...[
                ChoiceChip(
                  selected: _diaAtualHoje == i + 1,
                  onSelected: (sel) {
                    if (sel) setState(() => _diaAtualHoje = i + 1);
                  },
                  label: Text('Dia ${i + 1} (${_dias[i].isDescanso ? 'Descanso' : _dias[i].nome.text.trim().ifEmpty('Treino')})'),
                  labelStyle: manrope(
                    12,
                    peso: _diaAtualHoje == i + 1 ? FontWeight.w700 : FontWeight.w500,
                    cor: _diaAtualHoje == i + 1 ? Colors.white : c.text,
                  ),
                  selectedColor: c.accent,
                  backgroundColor: c.bg,
                ),
              ],
            ],
          ),
        ),

        // Lista de dias do ciclo
        Campo(
          rotulo: 'Dias da sequência',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _dias.length; i++) _cardDia(c, i),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: c.line),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _adicionarDia(descanso: false),
                      icon: Icon(Icons.fitness_center_rounded, size: 18, color: c.teal),
                      label: Text('+ Dia de treino', style: manrope(13, peso: FontWeight.w700, cor: c.teal)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: c.line),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _adicionarDia(descanso: true),
                      icon: Icon(Icons.bedtime_outlined, size: 18, color: c.accent),
                      label: Text('+ Dia de descanso', style: manrope(13, peso: FontWeight.w700, cor: c.accent)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Resumo do ciclo em texto
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Resumo do ciclo:', style: manrope(13, peso: FontWeight.w700)),
              const SizedBox(height: 4),
              for (var i = 0; i < _dias.length; i++)
                Text(
                  '• Dia ${i + 1}: ${_dias[i].isDescanso ? 'Descanso 💤' : '${_dias[i].nome.text.trim().ifEmpty('Treino')} ${_dias[i].foco.text.trim().isNotEmpty ? '(${_dias[i].foco.text.trim()})' : ''}'}',
                  style: manrope(12, cor: c.text, altura: 1.3),
                ),
              Text(
                '• Dia ${_dias.length + 1}: Repete o Dia 1 sucessivamente 🔄',
                style: manrope(12, peso: FontWeight.w600, cor: c.teal, altura: 1.4),
              ),
            ],
          ),
        ),

        if (_erro != null) Text(_erro!, style: manrope(13, peso: FontWeight.w600, cor: c.bad)),
      ],
    );
  }

  Widget _cardDia(AuroraCores c, int index) {
    final d = _dias[index];
    final treinosExistentes = widget.quadro.treinos;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: d.dia == _diaAtualHoje ? c.accent : c.line, width: d.dia == _diaAtualHoje ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: d.dia == _diaAtualHoje ? c.accent : c.line,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Dia ${d.dia}${d.dia == _diaAtualHoje ? ' · Hoje' : ''}',
                  style: manrope(12, peso: FontWeight.w700, cor: d.dia == _diaAtualHoje ? Colors.white : c.text),
                ),
              ),
              const Spacer(),
              // Botão alternador Treino / Descanso
              InkWell(
                onTap: () {
                  setState(() {
                    d.isDescanso = !d.isDescanso;
                    if (d.isDescanso) {
                      d.nome.text = 'Descanso';
                      d.foco.text = 'Recuperação muscular';
                    } else {
                      d.nome.text = 'Treino ${d.dia}';
                      d.foco.text = '';
                    }
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: d.isDescanso ? c.accent.withValues(alpha: 0.15) : c.teal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        d.isDescanso ? Icons.bedtime_rounded : Icons.fitness_center_rounded,
                        size: 14,
                        color: d.isDescanso ? c.accent : c.teal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        d.isDescanso ? 'Descanso' : 'Treino',
                        style: manrope(12, peso: FontWeight.w700, cor: d.isDescanso ? c.accent : c.teal),
                      ),
                    ],
                  ),
                ),
              ),
              if (_dias.length > 2) ...[
                const SizedBox(width: 6),
                IconButton(
                  tooltip: 'Remover dia do ciclo',
                  icon: Icon(Icons.close_rounded, size: 18, color: c.muted),
                  onPressed: () => _removerDia(index),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          if (d.isDescanso) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.nights_stay_rounded, color: c.accent, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Dia reservado para descanso e recuperação dos músculos.',
                        style: manrope(12, cor: c.muted)),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Se existirem treinos na ficha, dá a opção de vincular a um existente
            if (treinosExistentes.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      initialValue: d.treinoId,
                      dropdownColor: c.surface,
                      decoration: InputDecoration(
                        labelText: 'Vincular a treino da ficha',
                        labelStyle: manrope(12, cor: c.muted),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.line)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.line)),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('+ Criar novo para este dia')),
                        for (final t in treinosExistentes)
                          DropdownMenuItem(
                            value: t.treino.id,
                            child: Text(t.titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                      ],
                      onChanged: (selId) {
                        setState(() {
                          d.treinoId = selId;
                          if (selId != null) {
                            final selecionado = treinosExistentes.where((t) => t.treino.id == selId).firstOrNull;
                            if (selecionado != null) {
                              d.nome.text = selecionado.treino.nome;
                              d.foco.text = selecionado.treino.foco ?? '';
                            }
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Se for treino novo (ou para ver o nome e foco)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CampoTexto(
                    controle: d.nome,
                    dica: 'Nome (ex.: Treino A)',
                    aoMudar: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: CampoTexto(
                    controle: d.foco,
                    dica: 'Foco (ex.: Peito, tríceps e ombro)',
                    aoMudar: (_) => setState(() {}),
                  ),
                ),
              ],
            ),

            if (d.treinoId == null) ...[
              const SizedBox(height: 8),
              // Exercícios rápidos deste dia se for treino novo
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var eIdx = 0; eIdx < d.exercicios.length; eIdx++)
                    _linhaExercicioRapido(c, d, eIdx),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => setState(() => d.exercicios.add(_ItemExercicioRapido())),
                      icon: Icon(Icons.add_rounded, size: 16, color: c.teal),
                      label: Text('+ Exercício', style: manrope(12, peso: FontWeight.w700, cor: c.teal)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _linhaExercicioRapido(AuroraCores c, _DiaConfig d, int eIdx) {
    final ex = d.exercicios[eIdx];
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: CampoTexto(
              controle: ex.nome,
              dica: 'Exercício (ex: Supino)',
              aoMudar: (_) => setState(() {}),
            ),
          ),
          IconButton(
            tooltip: 'Buscar na biblioteca',
            icon: Icon(
              ex.midiaValida != null ? Icons.play_circle_rounded : Icons.video_library_outlined,
              size: 18,
              color: ex.midiaValida != null ? c.teal : c.accent,
            ),
            onPressed: () async {
              final item = await escolherDaBiblioteca(context, busca: ex.nome.text.trim());
              if (item != null && mounted) {
                setState(() {
                  ex.nome.text = item.nome;
                  ex.midia = item.arquivo;
                  ex.grupo = item.grupo;
                  ex.nomeDaBiblioteca = item.nome;
                });
              }
            },
          ),
          SizedBox(
            width: 44,
            child: CampoTexto(controle: ex.series, dica: '3', numerico: true),
          ),
          const SizedBox(width: 4),
          Text('x', style: manrope(11, cor: c.muted)),
          const SizedBox(width: 4),
          SizedBox(
            width: 44,
            child: CampoTexto(controle: ex.reps, dica: '10', numerico: true),
          ),
          if (d.exercicios.length > 1) ...[
            IconButton(
              icon: Icon(Icons.close_rounded, size: 16, color: c.muted),
              onPressed: () {
                final removido = d.exercicios.removeAt(eIdx);
                setState(() {});
                removido.dispose();
              },
            ),
          ],
        ],
      ),
    );
  }
}

extension on String {
  String ifEmpty(String defaultValue) => trim().isEmpty ? defaultValue : this;
}
