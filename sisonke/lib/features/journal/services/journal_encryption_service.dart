import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class JournalEncryptionService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _keyAlias = 'journal_encryption_key';
  static const String _version = 'v2';
  static const String _macKeyContext = 'sisonke-journal-mac-v2';

  Key? _key;
  final _legacyIv = IV.fromLength(16);

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
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(_key!, mode: AESMode.cbc));
    final ciphertext = encrypter.encrypt(text, iv: iv).base64;
    final encodedIv = iv.base64;
    final payload = '$_version.$encodedIv.$ciphertext';
    final mac = _mac(payload);
    return '$payload.${base64Encode(mac)}';
  }

  Future<String> decrypt(String base64Text) async {
    await _initKey();
    final parts = base64Text.split('.');
    if (parts.length == 4 && parts[0] == _version) {
      final payload = parts.sublist(0, 3).join('.');
      final expectedMac = _mac(payload);
      final receivedMac = base64Decode(parts[3]);
      if (!_constantTimeEquals(expectedMac, receivedMac)) {
        throw const FormatException('Journal entry authentication failed.');
      }

      final iv = IV(base64Decode(parts[1]));
      final encrypter = Encrypter(AES(_key!, mode: AESMode.cbc));
      return encrypter.decrypt64(parts[2], iv: iv);
    }

    // Entries written before v2 used a fixed IV. Keep this fallback so users
    // can still read existing journals; all newly written entries use v2.
    final encrypter = Encrypter(AES(_key!, mode: AESMode.cbc));
    return encrypter.decrypt64(base64Text, iv: _legacyIv);
  }

  List<int> _mac(String payload) {
    final macKey = sha256.convert([
      ..._key!.bytes,
      ...utf8.encode(_macKeyContext),
    ]).bytes;
    return Hmac(sha256, macKey).convert(utf8.encode(payload)).bytes;
  }

  bool _constantTimeEquals(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    var difference = 0;
    for (var index = 0; index < left.length; index++) {
      difference |= left[index] ^ right[index];
    }
    return difference == 0;
  }
}
