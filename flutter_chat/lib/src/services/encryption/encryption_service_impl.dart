import 'package:flutter_chat/src/services/encryption/encryption_service.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService implements IEncryptionService {
  final Encrypter _encrypter;
  final _initialVector = IV.fromLength(16);

  EncryptionService(this._encrypter);

  @override
  String decrypt(String encryptedText) {
    final encrypted = Encrypted.fromBase64(encryptedText);
    return _encrypter.decrypt(encrypted, iv: _initialVector);
  }

  @override
  String encrypt(String text) {
    return _encrypter.encrypt(text, iv: _initialVector).base64;
  }
}