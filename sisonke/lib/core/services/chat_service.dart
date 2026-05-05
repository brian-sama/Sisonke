import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:sisonke/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

class ChatService {
  io.Socket? _socket;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _dashboardController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _caseUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  Stream<Map<String, dynamic>> get dashboardUpdates =>
      _dashboardController.stream;
  Stream<Map<String, dynamic>> get caseUpdates => _caseUpdateController.stream;

  void connect(String token) {
    final baseUrl = AppConstants.apiBaseUrl.replaceAll('/api', '');
    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      print('Socket connected');
    });

    _socket!.on('new_message', (data) {
      _messageController.add(Map<String, dynamic>.from(data));
    });

    for (final event in [
      'case:created',
      'case:assigned',
      'case:accepted',
      'case:message',
      'case:status_changed',
      'case:escalated',
      'callback:requested',
      'voice_note:uploaded',
    ]) {
      _socket!.on(event, (data) {
        _caseUpdateController.add({
          'event': event,
          ...Map<String, dynamic>.from(data as Map),
        });
      });
    }

    _socket!.on('dashboard:update', (data) {
      _dashboardController.add(Map<String, dynamic>.from(data));
    });

    _socket!.onDisconnect((_) => print('Socket disconnected'));
    _socket!.onError((err) => print('Socket error: $err'));
  }

  void joinCase(String caseId) {
    _socket?.emit('join_case', caseId);
  }

  void leaveCase(String caseId) {
    _socket?.emit('leave_case', caseId);
  }

  void sendMessage(String caseId, String content) {
    _socket?.emit('send_message', {'caseId': caseId, 'content': content});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
