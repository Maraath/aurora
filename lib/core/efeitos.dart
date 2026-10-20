import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../data/banco.dart';

/// Efeitos visuais (Conta › Efeitos visuais, por aparelho). "Leves" tira o que
/// mais pesa na placa de vídeo: o desfoque dos vidros (barra, folhas, atalhos)
/// e o cintilar do céu. Na web não há cache de camadas: cada quadro redesenha a
/// tela inteira, desfoque incluído, e no iPhone XR isso não cabia em 16 ms.
enum ModoEfeitos {
  /// Mede o aparelho na 1ª abertura (só na web) e escolhe.
  automatico('Automático'),
  completos('Completos'),
  leves('Leves');

  const ModoEfeitos(this.rotulo);
  final String rotulo;

  static const chave = 'efeitos';

  /// Resultado da medição do automático ('leves' ou 'completos'). O "v2" descarta
  /// a medição antiga, que contava só o processador e deixava o XR em "completos".
  static const chaveMedido = 'efeitos_medido_v2';

  /// Quadros por segundo medidos (para mostrar em Conta).
  static const chaveFps = 'efeitos_fps';

  static Future<ModoEfeitos> ler(BancoAurora db) async =>
      values.asNameMap()[await db.preferencia(chave)] ?? automatico;
}

/// O que está ligado agora.
@immutable
class EstadoEfeitos {
  const EstadoEfeitos({this.leves = false, this.cintilar = true});

  /// Sem desfoque nos vidros.
  final bool leves;

  /// Estrelas piscando. Na web só em "Completos": cada cintilar redesenha a tela
  /// inteira (15 vezes por segundo, mesmo parado).
  final bool cintilar;

  @override
  bool operator ==(Object other) => other is EstadoEfeitos && other.leves == leves && other.cintilar == cintilar;

  @override
  int get hashCode => Object.hash(leves, cintilar);
}

class Efeitos {
  Efeitos._();

  /// As telas leem por [EscopoEfeitos].
  static final estado = ValueNotifier<EstadoEfeitos>(const EstadoEfeitos());

  /// Mediana do intervalo entre quadros acima disso (abaixo de ~55 por segundo) = aparelho lento.
  static const limiteMs = 18.0;

  static ModoEfeitos _modo = ModoEfeitos.automatico;
  static ModoEfeitos get modo => _modo;

  /// Última medição (quadros por segundo), nula se ainda não mediu.
  static final fpsMedido = ValueNotifier<int?>(null);

  static Future<void> iniciar(BancoAurora db) async {
    _modo = await ModoEfeitos.ler(db);
    final medido = await db.preferencia(ModoEfeitos.chaveMedido);
    fpsMedido.value = int.tryParse(await db.preferencia(ModoEfeitos.chaveFps) ?? '');
    _aplicar(medido);
    if (_modo == ModoEfeitos.automatico && (medido ?? '').isEmpty && kIsWeb) _medir(db);
  }

  static Future<void> escolher(BancoAurora db, ModoEfeitos modo) async {
    _modo = modo;
    await db.salvarPreferencia(ModoEfeitos.chave, modo.name);
    if (modo == ModoEfeitos.automatico) {
      // Escolher o automático de novo mede de novo (com os efeitos ligados).
      await db.salvarPreferencia(ModoEfeitos.chaveMedido, '');
      _aplicar(null);
      if (kIsWeb) _medir(db, espera: const Duration(seconds: 1));
    } else {
      _aplicar(await db.preferencia(ModoEfeitos.chaveMedido));
    }
  }

  static void _aplicar(String? medido) {
    final leves = switch (_modo) {
      ModoEfeitos.completos => false,
      ModoEfeitos.leves => true,
      ModoEfeitos.automatico => medido == 'leves',
    };
    estado.value = EstadoEfeitos(
      leves: leves,
      cintilar: !leves && (!kIsWeb || _modo == ModoEfeitos.completos),
    );
  }

  static bool _medindo = false;

  /// Pede quadros seguidos por ~1,5 s e mede o intervalo real entre eles. Na
  /// web cada quadro redesenha a tela toda (céu, cartões, desfoque), então o
  /// intervalo mostra o que a placa de vídeo aguenta: se ela não termina a
  /// tempo, o navegador atrasa o quadro seguinte. Começa [espera] depois da
  /// abertura, com a tela assentada. Se o app sair da tela, tenta na próxima.
  static void _medir(BancoAurora db, {Duration espera = const Duration(seconds: 4)}) {
    if (_medindo) return;
    _medindo = true;
    Timer(espera, () {
      final marcas = <Duration>[];
      final agendador = SchedulerBinding.instance;
      void quadro(Duration instante) {
        final vida = agendador.lifecycleState;
        if (vida != null && vida != AppLifecycleState.resumed) {
          _medindo = false;
          return;
        }
        marcas.add(instante);
        if (marcas.length <= 90) {
          agendador.scheduleFrameCallback(quadro);
          agendador.scheduleFrame();
          return;
        }
        _medindo = false;
        final intervalos = [
          for (var i = 1; i < marcas.length; i++) (marcas[i] - marcas[i - 1]).inMicroseconds / 1000,
        ]..sort();
        final mediana = intervalos[intervalos.length ~/ 2];
        final fps = (1000 / mediana).round().clamp(1, 240);
        final lento = deveSerLeve(intervalos);
        debugPrint('Efeitos: ${mediana.toStringAsFixed(1)} ms por quadro ($fps/s) → ${lento ? 'leves' : 'completos'}');
        fpsMedido.value = fps;
        db.salvarPreferencia(ModoEfeitos.chaveFps, '$fps');
        db.salvarPreferencia(ModoEfeitos.chaveMedido, lento ? 'leves' : 'completos');
        if (_modo == ModoEfeitos.automatico) _aplicar(lento ? 'leves' : 'completos');
      }

      agendador.scheduleFrameCallback(quadro);
      agendador.scheduleFrame();
    });
  }

  /// [intervalos]: tempo entre quadros seguidos em ms, em ordem crescente.
  @visibleForTesting
  static bool deveSerLeve(List<double> intervalos) =>
      intervalos.isNotEmpty && intervalos[intervalos.length ~/ 2] > limiteMs;
}

/// Leva [Efeitos.estado] às telas: quem lê por aqui é remontado quando muda.
/// Sem escopo acima (testes), efeitos completos.
class EscopoEfeitos extends InheritedNotifier<ValueNotifier<EstadoEfeitos>> {
  EscopoEfeitos({super.key, required super.child}) : super(notifier: Efeitos.estado);

  static EstadoEfeitos _de(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EscopoEfeitos>()?.notifier?.value ?? const EstadoEfeitos();

  static bool leves(BuildContext context) => _de(context).leves;

  static bool cintilar(BuildContext context) => _de(context).cintilar;
}
