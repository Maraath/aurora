import 'package:aurora/core/sons.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Sons possui valores padrão calibrados e acessíveis', () {
    final sons = Sons.instancia;
    expect(sons.volume.value, equals(0.5));
    expect(Sons.volumePadrao, inInclusiveRange(0.4, 0.6));
    expect(sons.ativo.value, isTrue);
  });

  test('EfeitoSonoro possui os 6 eventos essenciais com arquivos definidos', () {
    expect(EfeitoSonoro.values.length, equals(6));
    expect(EfeitoSonoro.iniciarFoco.arquivo, equals('sons/iniciar_foco.wav'));
    expect(EfeitoSonoro.finalizarFoco.arquivo, equals('sons/finalizar_foco.wav'));
    expect(EfeitoSonoro.concluirItem.arquivo, equals('sons/concluir_item.wav'));
    expect(EfeitoSonoro.concluirTreino.arquivo, equals('sons/concluir_treino.wav'));
    expect(EfeitoSonoro.concluirEtapa.arquivo, equals('sons/concluir_etapa.wav'));
    expect(EfeitoSonoro.concluirObjetivo.arquivo, equals('sons/concluir_objetivo.wav'));
  });

  test('Alternar e definirVolume respeitam limites e estado', () async {
    final sons = Sons.instancia;

    await sons.definirVolume(0.75);
    expect(sons.volume.value, equals(0.75));

    await sons.definirVolume(1.5); // Deve fazer clamp em 1.0
    expect(sons.volume.value, equals(1.0));

    await sons.definirVolume(-0.2); // Deve fazer clamp em 0.0
    expect(sons.volume.value, equals(0.0));

    await sons.alternar(false);
    expect(sons.ativo.value, isFalse);

    // Tocar com som desativado deve retornar silenciosamente sem erros
    await sons.tocar(EfeitoSonoro.concluirItem);

    await sons.alternar(true);
    expect(sons.ativo.value, isTrue);
    await sons.definirVolume(0.5);
  });
}
