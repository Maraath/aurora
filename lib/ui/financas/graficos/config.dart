import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/tema.dart';
import '../../../data/banco.dart';

/// Tipos de gráfico que um cartão pode oferecer no seletor.
enum TipoGrafico {
  rosca('Rosca', Icons.donut_large_rounded),
  pizza('Pizza', Icons.pie_chart_rounded),
  barras('Barras', Icons.bar_chart_rounded),
  barrasDeitadas('Barras', Icons.align_horizontal_left_rounded),
  blocos('Blocos', Icons.grid_view_rounded),
  radar('Radar', Icons.radar_rounded),
  linhas('Linhas', Icons.show_chart_rounded),
  area('Área', Icons.area_chart_rounded),
  velas('Velas', Icons.candlestick_chart_rounded),
  empilhadas('Barras empilhadas', Icons.stacked_bar_chart_rounded),
  acumulada('Linha acumulada', Icons.trending_up_rounded),
  projecao('Linha com projeção', Icons.timeline_rounded);

  const TipoGrafico(this.rotulo, this.icone);
  final String rotulo;
  final IconData icone;
}

enum PainelFin { resumo, analise }

/// Os cartões dos painéis de Finanças. [tipos] vazio = cartão sem seletor; o
/// primeiro tipo é o padrão.
enum CartaoFin {
  // Resumo (o mês).
  resumo(PainelFin.resumo, 'Saldo, receitas e despesas'),
  contas(PainelFin.resumo, 'Contas a pagar e a receber'),
  fluxoDinheiro(PainelFin.resumo, 'Fluxo do dinheiro no mês'),
  categorias(PainelFin.resumo, 'Despesas por categoria', tipos: [
    TipoGrafico.rosca,
    TipoGrafico.pizza,
    TipoGrafico.barrasDeitadas,
    TipoGrafico.blocos,
    TipoGrafico.radar,
  ], meia: true),
  gastoDia(PainelFin.resumo, 'Gasto por dia e projeção', tipos: [TipoGrafico.barras, TipoGrafico.acumulada], meia: true),
  fluxoCaixa(PainelFin.resumo, 'Fluxo de caixa',
      tipos: [TipoGrafico.barras, TipoGrafico.linhas, TipoGrafico.area, TipoGrafico.velas],
      meia: true),
  recentes(PainelFin.resumo, 'Transações recentes', tipos: [], meia: true),
  // Análise (vários meses).
  gastoMes(PainelFin.analise, 'Gasto no mês'),
  leituras(PainelFin.analise, 'Leituras do período'),
  trajetoria(PainelFin.analise, 'Trajetória do saldo',
      tipos: [TipoGrafico.projecao, TipoGrafico.area, TipoGrafico.velas],
      meia: true),
  categoriasTempo(PainelFin.analise, 'Categorias no tempo',
      tipos: [TipoGrafico.area, TipoGrafico.linhas, TipoGrafico.empilhadas],
      meia: true),
  mapaCalor(PainelFin.analise, 'Mapa de calor do gasto', tipos: [], meia: true),
  rigidez(PainelFin.analise, 'Fixo × parcelas × variável', tipos: [TipoGrafico.empilhadas, TipoGrafico.rosca],
      meia: true),
  paraOndeFoi(PainelFin.analise, 'Para onde foi'),
  maiores(PainelFin.analise, 'Maiores gastos');

  const CartaoFin(this.painel, this.rotulo, {this.tipos = const [], this.meia = false});
  final PainelFin painel;
  final String rotulo;
  final List<TipoGrafico> tipos;

  /// Em tela larga, divide a linha com o cartão vizinho de meia largura.
  final bool meia;

  static List<CartaoFin> doPainel(PainelFin p) => values.where((c) => c.painel == p).toList();
  static CartaoFin? deNome(String n) => values.where((c) => c.name == n).firstOrNull;
}

/// Ordem, cartões escondidos e tipo escolhido de cada cartão. Fica nas
/// preferências deste aparelho (`financas_painel`, não sincroniza).
class ConfigPainel {
  ConfigPainel({required this.ordem, required this.ocultos, required this.tipos});

  factory ConfigPainel.padrao() => ConfigPainel(
        ordem: {for (final p in PainelFin.values) p: CartaoFin.doPainel(p)},
        ocultos: {},
        tipos: {},
      );

  final Map<PainelFin, List<CartaoFin>> ordem;
  final Set<CartaoFin> ocultos;
  final Map<CartaoFin, TipoGrafico> tipos;

  TipoGrafico? tipoDe(CartaoFin c) {
    final t = tipos[c];
    return t != null && c.tipos.contains(t) ? t : c.tipos.firstOrNull;
  }

  /// Cartões visíveis do painel, na ordem escolhida.
  List<CartaoFin> visiveis(PainelFin p) => ordem[p]!.where((c) => !ocultos.contains(c)).toList();

  ConfigPainel copiar() => ConfigPainel(
        ordem: {for (final e in ordem.entries) e.key: [...e.value]},
        ocultos: {...ocultos},
        tipos: {...tipos},
      );

  String paraJson() => jsonEncode({
        'ordem': {for (final e in ordem.entries) e.key.name: [for (final c in e.value) c.name]},
        'ocultos': [for (final c in ocultos) c.name],
        'tipos': {for (final e in tipos.entries) e.key.name: e.value.name},
      });

  /// Lê o JSON salvo; cartões novos (de versões futuras) entram no fim e
  /// nomes desconhecidos são ignorados.
  static ConfigPainel deJson(String? texto) {
    final padrao = ConfigPainel.padrao();
    if (texto == null) return padrao;
    try {
      final j = jsonDecode(texto) as Map<String, dynamic>;
      final ordem = <PainelFin, List<CartaoFin>>{};
      for (final p in PainelFin.values) {
        final salvos = [
          for (final n in (j['ordem']?[p.name] as List? ?? const []))
            if (CartaoFin.deNome('$n') case final c? when c.painel == p) c,
        ];
        ordem[p] = [...salvos, ...CartaoFin.doPainel(p).where((c) => !salvos.contains(c))];
      }
      return ConfigPainel(
        ordem: ordem,
        ocultos: {for (final n in (j['ocultos'] as List? ?? const [])) ?CartaoFin.deNome('$n')},
        tipos: {
          for (final e in (j['tipos'] as Map? ?? const {}).entries)
            if ((CartaoFin.deNome('${e.key}'), TipoGrafico.values.where((t) => t.name == '${e.value}').firstOrNull)
                case (final c?, final t?))
              c: t,
        },
      );
    } catch (_) {
      return padrao;
    }
  }
}

/// A configuração dos painéis, carregada uma vez e avisando quem desenha.
class PreferenciasPainel extends ChangeNotifier {
  PreferenciasPainel(this.db) {
    _carregar();
  }

  final BancoAurora db;
  static const chave = 'financas_painel';
  ConfigPainel _config = ConfigPainel.padrao();
  ConfigPainel get config => _config;

  Future<void> _carregar() async {
    _config = ConfigPainel.deJson(await db.preferencia(chave));
    notifyListeners();
  }

  Future<void> salvar(ConfigPainel nova) async {
    _config = nova;
    notifyListeners();
    await db.salvarPreferencia(chave, nova.paraJson());
  }

  Future<void> escolherTipo(CartaoFin c, TipoGrafico t) {
    final nova = _config.copiar()..tipos[c] = t;
    return salvar(nova);
  }
}

/// Seletor pequeno de tipo no canto de um cartão: um botão de ícone por tipo
/// aceito, com o nome do tipo na dica.
class SeletorTipo extends StatelessWidget {
  const SeletorTipo({super.key, required this.tipos, required this.atual, required this.aoEscolher});
  final List<TipoGrafico> tipos;
  final TipoGrafico atual;
  final ValueChanged<TipoGrafico> aoEscolher;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.surface2.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.line),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (final t in tipos)
          Tooltip(
            message: t.rotulo,
            child: Semantics(
              button: true,
              selected: t == atual,
              label: 'Gráfico: ${t.rotulo}',
              child: InkWell(
                onTap: () => aoEscolher(t),
                borderRadius: BorderRadius.circular(9),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 30,
                  height: 28,
                  decoration: BoxDecoration(
                    color: t == atual ? c.accentSoft : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(t.icone, size: 16, color: t == atual ? c.accent : c.muted),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

/// Paleta das séries dos gráficos (cores da aurora), na ordem de uso.
List<Color> paletaGraficos(BuildContext context) {
  final c = context.cores;
  return [c.accent, c.violeta, c.teal, c.warn, c.bad, c.gradFim, c.muted];
}

/// Eixo: "R$ 1,2 mil" em vez de "R$ 1.234,00".
String reaisCurto(double reaisValor) {
  final negativo = reaisValor < 0;
  final v = reaisValor.abs();
  final texto = v >= 1000
      ? 'R\$ ${(v / 1000).toStringAsFixed(v < 10000 ? 1 : 0).replaceAll('.', ',')} mil'
      : 'R\$ ${v.round()}';
  return negativo ? '−$texto' : texto;
}
