import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:typed_data';

class JournalEncryptionService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _keyAlias = 'journal_encryption_key';
  
  Key? _key;
  final _iv = IV.fromLength(16);

  Future<void> _initKey() async {
    if (_key != null) return;
    
    String? storedKey = await _storage.read(key: _keyAlias);
    if (storedKey == null) {
      final newKey = Key.fromSecureRandom(32);
      await _storage.write(key: _keyAlias, value: base64Encode(newKey.bytes));
      _key = newKey;
    } else {
      _key = Key(base64Decode(storedKey));
    }
  }

  Future<String> encrypt(String text) async {
    await _initKey();
    final encrypter = Encrypter(AES(_key!));
    final encrypted = encrypter.encrypt(text, iv: _iv);
    return encrypted.base64;
  }

  Future<String> decrypt(String base64Text) async {
    await _initKey();
    final encrypter = Encrypter(AES(_key!));
    final decrypted = encrypter.decrypt64(base64Text, iv: _iv);
    return decrypted;
  }
}
