import 'package:drift/drift.dart';

import 'banco.dart';

/// Carrega um resumo e recarrega sempre que alguma das [tabelas] mudar.
Stream<T> observar<T>(
  BancoAurora db,
  List<TableInfo<Table, Object?>> tabelas,
  Future<T> Function() carregar,
) async* {
  yield await carregar();
  await for (final _ in db.tableUpdates(TableUpdateQuery.onAllTables(tabelas))) {
    yield await carregar();
  }
}
