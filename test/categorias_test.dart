import 'package:aurora/core/categorias.dart';
import 'package:aurora/core/comandos.dart';
import 'package:aurora/data/financas_repo.dart';
import 'package:aurora/data/graficos_financas.dart';
import 'package:aurora/ui/financas/categorias_visual.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toda categoria oferecida tem ícone e cor nos dois temas', () {
    for (final c in [...categoriasDeSaida, ...categoriasDeEntrada]) {
      expect(categoriaTemVisual(c.nome), isTrue, reason: c.nome);
    }
    for (final nome in categoriasLegado) {
      expect(categoriaTemVisual(nome), isTrue, reason: 'legado: $nome');
    }
  });

  test('não há categoria repetida dentro de cada tipo', () {
    final saida = <String>{};
    for (final c in categoriasDeSaida) {
      expect(saida.add(c.nome), isTrue, reason: 'repetida em saída: ${c.nome}');
    }
    final entrada = <String>{};
    for (final c in categoriasDeEntrada) {
      expect(entrada.add(c.nome), isTrue, reason: 'repetida em entrada: ${c.nome}');
    }
  });

  test('cada apelido leva à própria categoria', () {
    for (final c in categoriasDeSaida) {
      for (final apelido in c.apelidos) {
        expect(categoriaGasto(apelido), c.nome, reason: '$apelido → ${c.nome}');
      }
    }
    for (final c in categoriasDeEntrada) {
      for (final apelido in c.apelidos) {
        expect(categoriaEntrada(apelido), c.nome, reason: '$apelido → ${c.nome}');
      }
    }
  });

  test('frases que antes caíam em Lazer ou Serviços', () {
    expect(categoriaGasto('gastei 50 no restaurante'), 'Alimentação fora');
    expect(categoriaGasto('pedi um lanche no ifood'), 'Alimentação fora');
    expect(categoriaGasto('paguei a conta de celular'), 'Assinaturas e planos');
    expect(categoriaGasto('gastei 200 no mercado livre'), 'Compras');
    expect(categoriaGasto('paguei a passagem aérea'), 'Viagem');
    expect(categoriaGasto('paguei o plano de saúde'), 'Saúde');
    expect(categoriaGasto('gastei 30 na barbearia'), 'Cuidados pessoais');
    expect(categoriaGasto('paguei a lavanderia'), 'Serviços');
    expect(categoriaGasto('conserto do celular'), 'Serviços');
  });

  test('toda categoria tem grupo, e todo grupo tem ícone e cor', () {
    for (final c in categoriasDeSaida) {
      final g = grupoDaCategoria[c.nome];
      expect(g, isNotNull, reason: 'sem grupo: ${c.nome}');
      expect(gruposDeGasto, contains(g), reason: 'grupo desconhecido: ${c.nome}');
      expect(grupoTemVisual(g!), isTrue, reason: 'grupo sem visual: $g');
    }
    for (final nome in categoriasLegado) {
      expect(grupoDaCategoria[nome], isNotNull, reason: 'legado sem grupo: $nome');
    }
    expect(grupoDe('Categoria que não existe'), 'Outros');
  });

  test('agruparCategorias soma por grupo, do maior para o menor', () {
    final cats = agruparCategorias(const [
      CategoriaGasto('Mercado', 10000),
      CategoriaGasto('Alimentação fora', 5000),
      CategoriaGasto('Carro', 20000),
      CategoriaGasto('Outros', 1000),
    ]);
    expect(cats.map((c) => c.nome), ['Transporte', 'Alimentação', 'Outros']);
    expect(cats.first.centavos, 20000);
    expect(cats[1].centavos, 15000);
  });

  test('o que é do carro não se espalha por Transporte e Impostos', () {
    expect(categoriaGasto('gastei 250 de gasolina'), 'Carro');
    expect(categoriaGasto('paguei o estacionamento'), 'Carro');
    expect(categoriaGasto('paguei o pedágio'), 'Carro');
    expect(categoriaGasto('paguei o IPVA'), 'Carro');
    expect(categoriaGasto('gastei 400 de pneu'), 'Carro');
    expect(categoriaGasto('paguei o seguro do carro'), 'Carro');
    expect(categoriaGasto('gastei 25 no uber'), 'Transporte');
    // "seguro de vida" continua em Saúde, mesmo com Carro tendo "seguro".
    expect(categoriaGasto('paguei o seguro de vida'), 'Saúde');
    // "internet" é plano, não aluguel.
    expect(categoriaGasto('paguei a internet'), 'Assinaturas e planos');
  });

  test('aporte em investimento e dívida têm categoria própria', () {
    expect(categoriaGasto('apliquei 1000 no tesouro'), 'Investimentos');
    expect(categoriaGasto('gastei 500 no CDB'), 'Investimentos');
    expect(categoriaGasto('paguei o financiamento do carro'), 'Dívidas e juros');
    expect(categoriaGasto('gastei 300 de juros do cartão'), 'Dívidas e juros');
    // Do lado da entrada, "juros" e "investimento" continuam sendo Rendimentos.
    expect(categoriaEntrada('recebi juros da poupança'), 'Rendimentos');
    expect(categoriaEntrada('rendimento do CDB'), 'Rendimentos');
  });
}
