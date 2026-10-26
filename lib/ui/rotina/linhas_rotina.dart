import 'package:flutter/material.dart';

import '../../core/formato.dart';
import '../../core/relogio.dart';
import '../../core/tema.dart';
import '../../data/banco.dart';
import '../../data/compromissos_repo.dart';
import '../../data/lembretes_repo.dart';
import '../componentes.dart';
import 'form_compromisso.dart';

/// Linha de lembrete: o sino (violeta) liga ou desliga o aviso; tocar abre a
/// edição. [toque] é o horário mostrado (o de hoje, na Rotina › Hoje).
class LinhaLembrete extends StatelessWidget {
  const LinhaLembrete({
    super.key,
    required this.visto,
    required this.toque,
    required this.hoje,
    required this.aoAlternar,
    required this.aoEditar,
    this.mostrarDia = false,
  });

  final LembreteVisto visto;
  final DateTime? toque;
  final DateTime hoje;
  final VoidCallback aoAlternar;
  final VoidCallback aoEditar;

  /// Mostra o dia junto da hora (listas de vários dias).
  final bool mostrarDia;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final l = visto.lembrete;
    final momento = emLocal(toque ?? visto.proxima ?? l.quando);
    final passou = !momento.isAfter(agoraLocal());
    final apagado = !l.ativo || passou;
    final dia = DateTime(momento.year, momento.month, momento.day);
    final partes = [
      if (passou && dia == hoje) 'tocou às ${hora(momento)}',
      if (mostrarDia && !(passou && dia == hoje)) rotuloDiaLembrete(dia, hoje).toLowerCase(),
      if (visto.regra != null) visto.regra!.descricao.toLowerCase(),
      if (l.despertar) 'despertador',
      ?visto.ligadoA,
    ];
    return Opacity(
      opacity: apagado ? 0.6 : 1,
      child: Cartao(
        raio: 16,
        padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
        aoTocar: aoEditar,
        child: Row(
          children: [
            IconButton(
              tooltip: l.ativo ? 'Desligar notificação de ${l.texto}' : 'Ligar notificação de ${l.texto}',
              onPressed: aoAlternar,
              icon: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: l.ativo && !passou ? c.corLembrete.withValues(alpha: 0.16) : c.surface2,
                ),
                child: Icon(
                  !l.ativo
                      ? Icons.notifications_off_outlined
                      : (l.despertar ? Icons.alarm_rounded : Icons.notifications_active_outlined),
                  size: 17,
                  color: l.ativo && !passou ? c.corLembrete : c.muted,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.texto, style: manrope(15, peso: FontWeight.w600)),
                  if (partes.isNotEmpty)
                    Text(partes.join(' · '), style: manrope(12, cor: c.muted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(hora(momento), style: sora(14, cor: c.muted)),
          ],
        ),
      ),
    );
  }
}

/// Linha de compromisso: borda turquesa à esquerda; destaque enquanto acontece
/// ("Agora · até 14:00") e quanto falta para começar ("em 2 h 10 min").
class LinhaCompromisso extends StatelessWidget {
  const LinhaCompromisso({
    super.key,
    required this.ocorrencia,
    required this.agora,
    required this.aoEditar,
    this.mostrarEstado = true,
  });

  final OcorrenciaCompromisso ocorrencia;
  final DateTime agora;
  final VoidCallback aoEditar;

  /// "Agora" / "em X" / "Terminou" (só faz sentido para hoje).
  final bool mostrarEstado;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final o = ocorrencia;
    final cor = c.corCompromisso;
    final andamento = mostrarEstado && o.emAndamento(agora);
    final terminou = mostrarEstado && o.terminou(agora);
    final Compromisso comp = o.compromisso;
    final estado = !mostrarEstado
        ? null
        : andamento
            ? (o.diaInteiro || o.fim == null ? 'Agora' : 'Agora · até ${hora(emLocal(o.fim!))}')
            : terminou
                ? 'Terminou'
                : (o.diaInteiro ? null : faltaPara(o.inicio.difference(agora)));
    final aviso = comp.avisoAntesMin == null
        ? null
        : avisosCompromisso.firstWhere((a) => a.$1 == comp.avisoAntesMin, orElse: () => (null, '')).$2;
    final partes = [
      if (comp.local != null) comp.local!,
      if (o.regra != null) o.regra!.descricao.toLowerCase(),
      if (aviso != null && aviso.isNotEmpty) 'aviso ${aviso.toLowerCase()}',
    ];
    return Semantics(
      label: 'Compromisso ${comp.titulo}',
      button: true,
      child: Opacity(
        opacity: terminou ? 0.6 : 1,
        child: Cartao(
          raio: 16,
          padding: EdgeInsets.zero,
          aoTocar: aoEditar,
          cor: andamento ? Color.alphaBlend(cor.withValues(alpha: 0.12), c.surface) : null,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: cor,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: cor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(o.diaInteiro ? Icons.celebration_rounded : Icons.event_rounded,
                              size: 17, color: cor),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(comp.titulo, style: manrope(15, peso: FontWeight.w600)),
                              if (estado != null)
                                Text(estado,
                                    style: manrope(12, peso: FontWeight.w700, cor: andamento ? cor : c.accent)),
                              if (partes.isNotEmpty)
                                Text(partes.join(' · '), style: manrope(12, cor: c.muted)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(o.diaInteiro ? 'Dia todo' : hora(emLocal(o.inicio)), style: sora(14, cor: c.muted)),
                            if (!o.diaInteiro && o.fim != null)
                              Text(hora(emLocal(o.fim!)), style: manrope(11, cor: c.muted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "em 25 min", "em 2 h 10 min", "em 3 dias".
String faltaPara(Duration d) {
  final min = d.inMinutes;
  if (min < 1) return 'agora';
  if (min < 60) return 'em $min min';
  if (min < 24 * 60) {
    final h = min ~/ 60, m = min % 60;
    return m == 0 ? 'em $h h' : 'em $h h $m min';
  }
  final dias = (min / (24 * 60)).round();
  return dias == 1 ? 'amanhã' : 'em $dias dias';
}
