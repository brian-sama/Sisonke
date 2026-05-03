import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisonke/core/services/local_database_service.dart';
import 'package:sisonke/core/services/security_service.dart';

final securityServiceProvider = Provider<SecurityService>((ref) {
  return SecurityService();
});

final localDatabaseServiceProvider = Provider<LocalDatabaseService>((ref) {
  throw UnimplementedError('LocalDatabaseService must be overridden in main.dart');
});
