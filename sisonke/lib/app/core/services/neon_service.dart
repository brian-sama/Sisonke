import 'package:postgres/postgres.dart';
import 'package:sisonke/app/core/constants/config.dart';

class NeonService {
  Connection? _connection;

  Future<void> connect() async {
    if (_connection != null) return;

    _connection = await Connection.openFromUrl(Config.neonConnectionString);
  }

  Connection getConnection() {
    if (_connection == null) {
      throw Exception('Connection not initialized. Call connect() first.');
    }
    return _connection!;
  }

  Future<void> setAuthUid(String? uid) async {
    if (_connection == null) await connect();
    if (uid != null) {
      await _connection!.execute("SET LOCAL auth.uid = '$uid'");
    } else {
      await _connection!.execute("SET LOCAL auth.uid = NULL");
    }
  }

  Future<List<Map<String, dynamic>>> query(String sql, {Map<String, dynamic>? substitutionValues}) async {
    if (_connection == null) await connect();
    final results = await _connection!.execute(
      Sql.named(sql),
      parameters: substitutionValues,
    );
    return results.map((row) => row.toColumnMap()).toList();
  }

  Future<void> execute(String sql, {Map<String, dynamic>? substitutionValues}) async {
    if (_connection == null) await connect();
    await _connection!.execute(
      Sql.named(sql),
      parameters: substitutionValues,
    );
  }

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}
