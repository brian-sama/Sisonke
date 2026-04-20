import 'package:postgres/postgres.dart';
import 'package:sisonke/app/core/constants/config.dart';

class NeonService {
  PostgreSQLConnection? _connection;

  Future<void> connect() async {
    if (_connection != null) return;

    final uri = Uri.parse(Config.neonConnectionString);
    _connection = PostgreSQLConnection(
      uri.host,
      uri.port,
      uri.pathSegments.isNotEmpty ? uri.pathSegments.first : 'neondb',
      username: uri.userInfo.split(':').first,
      password: uri.userInfo.split(':').last,
      useSSL: true,
    );

    await _connection!.open();
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
    final results = await _connection!.mappedResultsQuery(sql, substitutionValues: substitutionValues);
    return results.map((row) => row.values.first).toList();
  }

  Future<void> execute(String sql, {Map<String, dynamic>? substitutionValues}) async {
    if (_connection == null) await connect();
    await _connection!.execute(sql, substitutionValues: substitutionValues);
  }

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}