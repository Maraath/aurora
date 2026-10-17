import 'package:flutter/material.dart';

import '../core/formato.dart';
import '../core/recorrencia.dart';
import '../core/recorrencia.dart' as rec show diasUteis;
import '../core/tema.dart';

/// Abre uma folha de formulário (de baixo para cima), como no protótipo.
Future<T?> abrirFolha<T>(BuildContext context, Widget Function(BuildContext) construtor) {
  final c = context.cores;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: c.surface,
    barrierColor: const Color(0x99020610),
    constraints: const BoxConstraints(maxWidth: 560),
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      side: BorderSide(color: c.line),
    ),
    builder: construtor,
  );
}

/// Esqueleto da folha: alça, título, "Cancelar", corpo rolável e botão salvar.
class Folha extends StatelessWidget {
  const Folha({
    super.key,
    required this.titulo,
    required this.campos,
    required this.textoSalvar,
    required this.aoSalvar,
    this.aoExcluir,
  });

  final String titulo;
  final List<Widget> campos;
  final String textoSalvar;
  final VoidCallback aoSalvar;
  final VoidCallback? aoExcluir;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final teclado = MediaQuery.viewInsetsOf(context).bottom;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
      child: Padding(
        padding: EdgeInsets.only(bottom: teclado),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: c.line, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text(titulo, style: sora(20))),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
                    child: Text('Cancelar',
                        style: manrope(14, peso: FontWeight.w700, cor: c.muted)),
                  ),
                ],
              ),
              for (final campo in campos) ...[const SizedBox(height: 16), campo],
              const SizedBox(height: 20),
              Material(
                color: Colors.transparent,
                shape: const StadiumBorder(),
                clipBehavior: Clip.antiAlias,
                child: Ink(
                  decoration: BoxDecoration(gradient: c.gradiente),
                  child: InkWell(
                    onTap: aoSalvar,
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      child: Text(textoSalvar,
                          style: manrope(16, peso: FontWeight.w700, cor: c.noAccent)),
                    ),
                  ),
                ),
              ),
              if (aoExcluir != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: aoExcluir,
                  style: TextButton.styleFrom(minimumSize: const Size(44, 48)),
                  child: Text('Excluir', style: manrope(15, peso: FontWeight.w700, cor: c.bad)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Rótulo + conteúdo de um campo.
class Campo extends StatelessWidget {
  const Campo({super.key, required this.rotulo, required this.child, this.acao});
  final String rotulo;
  final Widget child;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Expanded(child: Text(rotulo, style: manrope(12, peso: FontWeight.w700, cor: c.muted))),
          ?acao,
        ]),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.controle,
    required this.dica,
    this.erro,
    this.autofoco = false,
    this.numerico = false,
    this.decimal = false,
    this.aoMudar,
    this.senha = false,
    this.email = false,
  });

  /// Esconde o texto (campo de senha).
  final bool senha;

  /// Teclado de e-mail, sem maiúscula automática.
  final bool email;

  final TextEditingController controle;
  final String dica;
  final String? erro;
  final bool autofoco;
  final bool numerico;

  /// Teclado numérico com vírgula ("74,5").
  final bool decimal;
  final ValueChanged<String>? aoMudar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    OutlineInputBorder borda(Color cor) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cor, width: 1.5),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controle,
          autofocus: autofoco,
          onChanged: aoMudar,
          keyboardType: decimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : (numerico
                  ? TextInputType.number
                  : (email ? TextInputType.emailAddress : TextInputType.text)),
          textCapitalization:
              senha || email ? TextCapitalization.none : TextCapitalization.sentences,
          obscureText: senha,
          autocorrect: !(senha || email),
          enableSuggestions: !(senha || email),
          style: manrope(16, cor: c.text),
          cursorColor: c.accent,
          decoration: InputDecoration(
            hintText: dica,
            hintStyle: manrope(16, cor: c.muted),
            filled: true,
            fillColor: c.bg,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: borda(erro != null ? c.bad : c.line),
            focusedBorder: borda(erro != null ? c.bad : c.accent),
          ),
        ),
        if (erro != null) ...[
          const SizedBox(height: 6),
          Text(erro!, style: manrope(12, peso: FontWeight.w600, cor: c.bad)),
        ],
      ],
    );
  }
}

/// Valor em reais: "R$" à esquerda e número grande, como no protótipo.
class CampoValor extends StatelessWidget {
  const CampoValor({super.key, required this.controle, this.cor, this.aoMudar});

  final TextEditingController controle;
  final Color? cor;
  final ValueChanged<String>? aoMudar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.line),
      ),
      child: Row(
        children: [
          Text(r'R$', style: sora(18, cor: c.muted)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controle,
              onChanged: aoMudar,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: sora(24, cor: cor ?? c.text),
              cursorColor: c.accent,
              decoration: InputDecoration(
                hintText: '0,00',
                hintStyle: sora(24, cor: c.muted),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Opção em pílula. Com [cor], a seleção usa só a borda/texto naquela cor
/// (prioridades); sem cor, fundo azul suave.
class OpcaoChip extends StatelessWidget {
  const OpcaoChip({
    super.key,
    required this.texto,
    required this.selecionado,
    required this.aoTocar,
    this.cor,
    this.dica,
    this.quadrado = false,
  });

  final String texto;
  final bool selecionado;
  final VoidCallback aoTocar;
  final Color? cor;
  final String? dica;
  final bool quadrado;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final destaque = cor ?? c.accent;
    return Semantics(
      selected: selecionado,
      button: true,
      child: Material(
        color: selecionado && cor == null ? c.accentSoft : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(quadrado ? 14 : 20),
          side: BorderSide(color: selecionado ? destaque : c.line, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: Container(
            constraints: BoxConstraints(minHeight: dica != null ? 56 : (quadrado ? 44 : 40)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(texto,
                    textAlign: TextAlign.center,
                    style: manrope(13, peso: FontWeight.w700, cor: selecionado ? destaque : c.text)),
                if (dica != null)
                  Text(dica!, style: manrope(11, peso: FontWeight.w500, cor: c.muted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opções em linha que quebram (Hoje / Amanhã / Sem data...).
class GrupoChips<T> extends StatelessWidget {
  const GrupoChips({
    super.key,
    required this.opcoes,
    required this.selecionado,
    required this.rotulo,
    required this.aoEscolher,
  });

  final List<T> opcoes;
  final T selecionado;
  final String Function(T) rotulo;
  final ValueChanged<T> aoEscolher;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final o in opcoes)
            OpcaoChip(texto: rotulo(o), selecionado: o == selecionado, aoTocar: () => aoEscolher(o)),
        ],
      );
}

/// Opções em grade de colunas iguais (prioridade, tipo de hábito).
class GradeChips extends StatelessWidget {
  const GradeChips({super.key, required this.filhos});
  final List<Widget> filhos;

  // IntrinsicHeight: dentro de uma área rolável a altura é infinita, e
  // "stretch" sozinho quebraria o layout. Assim todos ficam com a altura do maior.
  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < filhos.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: filhos[i]),
            ],
          ],
        ),
      );
}

/// "Me avisar" com interruptor verde-água.
class LinhaInterruptor extends StatelessWidget {
  const LinhaInterruptor({
    super.key,
    required this.titulo,
    required this.detalhe,
    required this.valor,
    required this.aoMudar,
  });

  final String titulo;
  final String detalhe;
  final bool valor;
  final ValueChanged<bool> aoMudar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Material(
      color: c.bg,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => aoMudar(!valor),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: manrope(14, peso: FontWeight.w600)),
                    Text(detalhe, style: manrope(12, cor: c.muted)),
                  ],
                ),
              ),
              Switch(
                value: valor,
                onChanged: aoMudar,
                activeThumbColor: Colors.white,
                activeTrackColor: c.teal,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: c.line,
                trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botão que mostra o horário escolhido e abre o relógio. [opcional] permite limpar.
class CampoHorario extends StatelessWidget {
  const CampoHorario({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.aoMudar,
    this.opcional = true,
  });

  final String rotulo;
  final TimeOfDay? valor;
  final ValueChanged<TimeOfDay?> aoMudar;
  final bool opcional;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Row(
      children: [
        Text(rotulo, style: manrope(13, cor: c.muted)),
        const SizedBox(width: 10),
        Material(
          color: c.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: c.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () async {
              final escolhido = await showTimePicker(
                context: context,
                initialTime: valor ?? const TimeOfDay(hour: 9, minute: 0),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                  child: child!,
                ),
              );
              if (escolhido != null) aoMudar(escolhido);
            },
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              child: Text(
                valor == null ? '--:--' : horaDe(valor!.hour, valor!.minute),
                style: manrope(15, peso: FontWeight.w600, cor: valor == null ? c.muted : c.text),
              ),
            ),
          ),
        ),
        if (opcional && valor != null)
          IconButton(
            tooltip: 'Tirar horário',
            onPressed: () => aoMudar(null),
            icon: Icon(Icons.close_rounded, size: 18, color: c.muted),
          ),
      ],
    );
  }
}

/// Sete botões redondos (S T Q Q S S D) com bits de segunda a domingo.
class SeletorDias extends StatelessWidget {
  const SeletorDias({super.key, required this.dias, required this.aoMudar});
  final int dias;
  final ValueChanged<int> aoMudar;

  static const _letras = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
  static const _nomes = ['segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado', 'domingo'];

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Row(
      children: [
        for (var i = 0; i < 7; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Semantics(
              label: _nomes[i],
              selected: dias & (1 << i) != 0,
              button: true,
              excludeSemantics: true,
              child: Material(
                color: dias & (1 << i) != 0 ? c.accentFill : Colors.transparent,
                shape: StadiumBorder(
                  side: BorderSide(color: dias & (1 << i) != 0 ? c.accent : c.line, width: 1.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => aoMudar(dias ^ (1 << i)),
                  child: SizedBox(
                    height: 44,
                    child: Center(
                      child: Text(_letras[i],
                          style: manrope(13,
                              peso: FontWeight.w700,
                              cor: dias & (1 << i) != 0 ? c.noAccent : c.text)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Escolha de data: Hoje, Amanhã, outra data (calendário) e, opcionalmente, Sem data.
class EscolhaData extends StatelessWidget {
  const EscolhaData({
    super.key,
    required this.data,
    required this.hoje,
    required this.aoMudar,
    this.permiteSemData = true,
  });

  final DateTime? data;
  final DateTime hoje;
  final ValueChanged<DateTime?> aoMudar;
  final bool permiteSemData;

  @override
  Widget build(BuildContext context) {
    final amanha = hoje.add(const Duration(days: 1));
    final outra = data != null && data != hoje && data != amanha;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OpcaoChip(texto: 'Hoje', selecionado: data == hoje, aoTocar: () => aoMudar(hoje)),
        OpcaoChip(texto: 'Amanhã', selecionado: data == amanha, aoTocar: () => aoMudar(amanha)),
        OpcaoChip(
          texto: outra ? diaSemanaCurto(data!) : 'Outra data',
          selecionado: outra,
          aoTocar: () async {
            final escolhida = await showDatePicker(
              context: context,
              initialDate: data ?? hoje,
              firstDate: DateTime(hoje.year - 1),
              lastDate: DateTime(hoje.year + 5),
              locale: const Locale('pt', 'BR'),
            );
            if (escolhida != null) {
              aoMudar(DateTime(escolhida.year, escolhida.month, escolhida.day));
            }
          },
        ),
        if (permiteSemData)
          OpcaoChip(texto: 'Sem data', selecionado: data == null, aoTocar: () => aoMudar(null)),
      ],
    );
  }
}

/// Opções de repetição dos formulários de tarefa e lembrete.
enum OpcaoRepeticao {
  nao('Não repete'),
  todoDia('Todo dia'),
  diasUteis('Dias úteis'),
  todaSemana('Toda semana'),
  todoMes('Todo mês'),
  personalizada('Personalizada');

  const OpcaoRepeticao(this.rotulo);
  final String rotulo;

  static const padrao = [nao, todoDia, diasUteis, todaSemana, todoMes];

  /// Regra a partir da data inicial (a semana e o dia do mês vêm dela).
  Regra? regra(DateTime inicio, Regra? atual) => switch (this) {
        nao => null,
        todoDia => const Regra.diaria(),
        diasUteis => const Regra.semanal(rec.diasUteis),
        todaSemana => Regra.semanal(bitDoDiaDaSemana(inicio)),
        todoMes => Regra.mensal(inicio.day),
        personalizada => atual,
      };

  static OpcaoRepeticao de(Regra? r) {
    if (r == null) return nao;
    if (r.intervalo == 1) {
      if (r.frequencia == Frequencia.diaria) return todoDia;
      if (r.frequencia == Frequencia.mensal) return todoMes;
      if (r.dias == rec.diasUteis) return OpcaoRepeticao.diasUteis;
      if (r.dias != 0 && r.dias & (r.dias - 1) == 0) return todaSemana; // um dia só
    }
    return personalizada;
  }
}
