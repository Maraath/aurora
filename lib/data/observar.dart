import 'dart:async';

import 'package:drift/drift.dart';

import '../core/relogio.dart';
import 'banco.dart';

/// Carrega um resumo e recarrega sempre que alguma das [tabelas] mudar ou o
/// fuso do aparelho mudar (o "hoje" e os horários dependem dele). As cargas
/// saem uma de cada vez, na ordem dos avisos.
Stream<T> observar<T>(
  BancoAurora db,
  List<TableInfo<Table, Object?>> tabelas,
  Future<T> Function() carregar,
) async* {
  yield await carregar();
  final sinais = StreamController<void>();
  final tabelasMudaram = db.tableUpdates(TableUpdateQuery.onAllTables(tabelas)).listen((_) => sinais.add(null));
  final fusoTrocou = fusoMudou.listen((_) => sinais.add(null));
  try {
    await for (final _ in sinais.stream) {
      yield await carregar();
    }
  } finally {
    // Sem esperar: quem fecha a tela não precisa aguardar o banco soltar a
    // escuta, e o close() de um canal sem ouvinte nunca terminaria.
    unawaited(tabelasMudaram.cancel());
    unawaited(fusoTrocou.cancel());
    unawaited(sinais.close());
  }
}
