import 'package:chat/src/services/encryption/encryption_service_impl.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late EncryptionService encryptionService;

  setUp(() {
    final encrypter = Encrypter(AES(Key.fromLength(32)));
    encryptionService = EncryptionService(encrypter);
  });

  test("it encrypts plain text", () {
    const text = "this is a test message";

    final base64 = RegExp(
        r'^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{4})$');

    final encrypted = encryptionService.encrypt(text);

    expect(base64.hasMatch(encrypted), true);
  });

  test("it decrypts encrypted text", () {
    const text = "this is a test message";

    final encrypted = encryptionService.encrypt(text);
    final decrypted = encryptionService.decrypt(encrypted);

    expect(decrypted, text);
  });
}