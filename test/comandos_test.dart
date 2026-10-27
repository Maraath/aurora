import 'package:aurora/core/comandos.dart';
import 'package:aurora/core/recorrencia.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Sexta-feira, 16/10/2026, 16:00.
  final hoje = DateTime(2026, 10, 16);
  final agora = DateTime(2026, 10, 16, 16);
  Comando? ler(String t) => interpretar(t, hoje: hoje, agora: agora);

  group('dinheiro', () {
    test('gastei 35 no mercado', () {
      final c = ler('Gastei 35 no mercado') as CmdDinheiro;
      expect(c.centavos, 3500);
      expect(c.descricao, 'Mercado');
      expect(c.categoria, 'Mercado');
      expect(c.dia, hoje);
      expect(c.entrada, isFalse);
    });

    test('valores com vírgula, milhar e R\$', () {
      expect((ler('gastei R\$ 35,90 com uber') as CmdDinheiro).centavos, 3590);
      expect((ler('paguei 1.250,00 de aluguel') as CmdDinheiro).centavos, 125000);
      expect((ler('gastei 12.5 reais na padaria') as CmdDinheiro).centavos, 1250);
    });

    test('categoria e descrição', () {
      final c = ler('gastei 35,90 com uber') as CmdDinheiro;
      expect(c.descricao, 'Uber');
      expect(c.categoria, 'Transporte');
      expect((ler('paguei 89 da conta de luz') as CmdDinheiro).categoria, 'Moradia');
      expect((ler('comprei 40 na farmácia') as CmdDinheiro).categoria, 'Saúde');
      expect((ler('gastei 20') as CmdDinheiro).descricao, 'Gasto');
    });

    test('ontem', () {
      final c = ler('gastei 50 no restaurante ontem') as CmdDinheiro;
      expect(c.dia, DateTime(2026, 10, 15));
      expect(c.descricao, 'Restaurante');
      expect(c.categoria, 'Alimentação fora');
    });

    test('categorias novas', () {
      expect((ler('gastei 30 no ifood') as CmdDinheiro).categoria, 'Alimentação fora');
      expect((ler('paguei 50 de netflix') as CmdDinheiro).categoria, 'Assinaturas e planos');
      expect((ler('gastei 80 na academia') as CmdDinheiro).categoria, 'Academia e suplementos');
      expect((ler('paguei 100 do ipva') as CmdDinheiro).categoria, 'Carro',
          reason: 'IPVA é custo do carro, não imposto genérico');
      expect((ler('paguei 100 do darf') as CmdDinheiro).categoria, 'Impostos e taxas');
      expect((ler('paguei 30 na ração do pet') as CmdDinheiro).categoria, 'Pets');
      expect((ler('gastei 120 no hotel') as CmdDinheiro).categoria, 'Viagem');
      expect((ler('paguei 200 do seguro do carro') as CmdDinheiro).categoria, 'Carro');
      expect((ler('gastei 50 no presente') as CmdDinheiro).categoria, 'Presentes e doações');
      expect((ler('gastei 200 no tênis') as CmdDinheiro).categoria, 'Compras');
      expect((ler('gastei 200 na educação') as CmdDinheiro).categoria, 'Estudos');
      expect((ler('gastei 200 no mercado livre') as CmdDinheiro).categoria, 'Compras');
      expect((ler('gastei 20 no cinema') as CmdDinheiro).categoria, 'Lazer');
    });

    test('entrada', () {
      final c = ler('recebi 500 do freela') as CmdDinheiro;
      expect(c.entrada, isTrue);
      expect(c.categoria, 'Freela');
      expect(c.descricao, 'Freela');
      expect((ler('recebi 100 de reembolso') as CmdDinheiro).categoria, 'Reembolso');
      expect((ler('recebi 50 de juros') as CmdDinheiro).categoria, 'Rendimentos');
      expect((ler('recebi 300 de aluguel') as CmdDinheiro).categoria, 'Rendimentos');
      expect((ler('recebi 500 de salário') as CmdDinheiro).categoria, 'Salário');
    });
  });

  group('lembrete', () {
    test('amanhã às 10h, como no protótipo', () {
      final c = ler('Me lembra de ligar pro dentista amanhã às 10h') as CmdLembrete;
      expect(c.texto, 'Ligar pro dentista');
      expect(c.dia, DateTime(2026, 10, 17));
      expect((c.hora, c.minuto), (10, 0));
      expect(c.regra, isNull);
    });

    test('sem dia: hoje se o horário ainda vem, senão amanhã', () {
      final hojeMais = ler('lembrar de tomar remédio às 20:30') as CmdLembrete;
      expect(hojeMais.dia, hoje);
      expect((hojeMais.hora, hojeMais.minuto), (20, 30));
      final jaPassou = ler('lembre-me de beber água às 10') as CmdLembrete;
      expect(jaPassou.dia, DateTime(2026, 10, 17));
      final semHora = ler('lembrar de comprar pão') as CmdLembrete;
      expect(semHora.dia, DateTime(2026, 10, 17));
      expect(semHora.hora, 9);
    });

    test('todo dia 11 vira regra mensal', () {
      final c = ler('me lembra de pagar a faculdade todo dia 11') as CmdLembrete;
      expect(c.texto, 'Pagar a faculdade');
      expect(c.regra, const Regra.mensal(11));
      expect(c.dia, DateTime(2026, 11, 11));
    });

    test('toda segunda e quarta à noite', () {
      final c = ler('lembrar de ir à academia toda segunda e quarta à noite') as CmdLembrete;
      expect(c.texto, 'Ir à academia');
      expect(c.regra, const Regra.semanal(1 | 4));
      expect(c.hora, 20);
      expect(c.dia, DateTime(2026, 10, 19));
    });

    test('todo dia de manhã', () {
      final c = ler('me avisa de tomar vitamina todo dia de manhã') as CmdLembrete;
      expect(c.regra, const Regra.diaria());
      expect(c.hora, 9);
      expect(c.dia, DateTime(2026, 10, 17));
    });

    test('dia da semana e data', () {
      expect((ler('lembrar de levar o carro na segunda') as CmdLembrete).dia, DateTime(2026, 10, 19));
      expect((ler('lembrar de levar o carro na sexta') as CmdLembrete).dia, DateTime(2026, 10, 23));
      expect((ler('lembrar do aniversário da mãe dia 3') as CmdLembrete).dia, DateTime(2026, 11, 3));
      final c = ler('lembrar de renovar CNH em 20/12 às 8 da noite') as CmdLembrete;
      expect(c.dia, DateTime(2026, 12, 20));
      expect(c.hora, 20);
      expect(c.texto, 'Renovar CNH');
    });
  });

  group('tarefa', () {
    test('com e sem data', () {
      final a = ler('tarefa: revisar currículo') as CmdTarefa;
      expect(a.titulo, 'Revisar currículo');
      expect(a.dia, isNull);
      final b = ler('adiciona tarefa de mandar e-mail pro RH amanhã às 14h') as CmdTarefa;
      expect(b.titulo, 'Mandar e-mail pro RH');
      expect(b.dia, DateTime(2026, 10, 17));
      expect(b.hora, 14);
    });
  });

  group('hábito e medidas', () {
    test('fiz o cardio', () {
      expect((ler('Fiz o cardio') as CmdHabito).nome, 'cardio');
      expect((ler('já fiz meu estudo de hoje') as CmdHabito).nome, 'estudo');
      expect((ler('marca beber água como feito') as CmdHabito).nome, 'beber água');
    });

    test('pesei 74,5', () {
      final c = ler('pesei 74,5') as CmdMedida;
      expect((c.tipo, c.valor, c.unidade), ('Peso', 74.5, 'kg'));
      final b = ler('braço 37,5 cm') as CmdMedida;
      expect((b.tipo, b.valor, b.unidade), ('Braço', 37.5, 'cm'));
      expect((ler('minha cintura deu 82') as CmdMedida).tipo, 'Cintura');
    });
  });

  group('comida', () {
    test('gramas, porções e refeição', () {
      final a = ler('Comi 200 g de frango no almoço') as CmdComida;
      expect((a.nome, a.gramas, a.porcoes, a.refeicao), ('frango', 200.0, null, 'almoco'));
      final b = ler('comi 2 ovos') as CmdComida;
      expect((b.nome, b.gramas, b.porcoes, b.refeicao), ('ovos', null, 2.0, null));
      final c = ler('almocei 150g de arroz branco') as CmdComida;
      expect((c.nome, c.gramas, c.refeicao), ('arroz branco', 150.0, 'almoco'));
      final d = ler('comi no café 1,5 pão francês') as CmdComida;
      expect((d.nome, d.porcoes, d.refeicao), ('pão francês', 1.5, 'cafe'));
      final e = ler('bebi 300 ml de leite no jantar') as CmdComida;
      expect((e.nome, e.gramas, e.refeicao), ('leite', 300.0, 'jantar'));
    });

    test('sem quantidade não é comando de comida', () {
      expect(ler('comi muito hoje'), isNull);
    });
  });

  group('resumos e fila', () {
    test('perguntas locais', () {
      expect(ler('Resumo do meu dia'), isA<CmdResumoDia>());
      expect(ler('Como estão meus gastos?'), isA<CmdResumoFinancas>());
      expect(ler('quanto gastei esse mês?'), isA<CmdResumoFinancas>());
    });

    test('o resto vai para a IA', () {
      expect(ler('me sugere um treino de pernas'), isNull);
      expect(ler('qual a capital da Austrália?'), isNull);
      expect(ler(''), isNull);
    });
  });
}
