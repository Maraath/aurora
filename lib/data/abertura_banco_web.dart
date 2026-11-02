import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Na web: SQLite em Wasm, guardado no OPFS/IndexedDB do navegador (web/sqlite3.wasm).
/// Sem cifra: o navegador não tem um cofre onde guardar a chave.
QueryExecutor abrirBancoDoApp(String nome) => driftDatabase(
      name: nome,
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
