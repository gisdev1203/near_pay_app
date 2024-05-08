// ignore_for_file: implementation_imports, avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:js';
import 'dart:typed_data';
import 'package:flutter/src/widgets/framework.dart';
import 'package:near_pay_app/appstate_container.dart';
import 'package:near_pay_app/core/models/vault.dart';
import 'package:near_pay_app/presantation/modules/home/services/helper_service.dart';
import 'package:near_pay_app/presantation/ui/password_lock_screen.dart';

import 'package:near_pay_app/service_locator.dart';

import 'package:pointycastle/api.dart' show ParametersWithIV, KeyParameter;
import 'package:pointycastle/stream/salsa20.dart';
// Define a method named decrypt
String decrypt(String encryptedText, String key) {
  // Implement your decryption logic here
  // For example, a simple XOR decryption:
  List<int> bytes = encryptedText.codeUnits;
  List<int> keyBytes = key.codeUnits;
  List<int> decryptedBytes = List<int>.generate(bytes.length, (i) => bytes[i] ^ keyBytes[i % keyBytes.length]);
  return String.fromCharCodes(decryptedBytes);
}


/// Encryption using Salsa20 from pointycastle
class Salsa20Encryptor {
  final ParametersWithIV<KeyParameter> _params;
  final Salsa20Engine _cipher = Salsa20Engine();

  Salsa20Encryptor(String key, String iv)
      : _params = ParametersWithIV<KeyParameter>(
            KeyParameter(Uint8List.fromList(utf8.encode(key))),
            Uint8List.fromList(utf8.encode(iv)));

  String encrypt(String plainText) {
    _cipher
      ..reset()
      ..init(true, _params);

    final input = Uint8List.fromList(utf8.encode(plainText));
    final output = _cipher.process(input);

    return bytesToHex(output);
  }

  String decrypt(String cipherText) {
    _cipher
      ..reset()
      ..init(false, _params);

    final input = hexToBytes(cipherText);
    final output = _cipher.process(input);

    return utf8.decode(output);
  }
}

// Byte dizisini hex formatına dönüştüren fonksiyon
String bytesToHex(List<int> bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

// Hex formatındaki bir dizesi byte dizisine dönüştüren fonksiyon
List<int> hexToBytes(String hexString) {
  return List.generate(hexString.length ~/ 2,
      (index) => int.parse(hexString.substring(index * 2, index * 2 + 2), radix: 16));
}

// Örnek kullanımı
void exampleUsage() async {
  // Seed'i şifreli olarak al
  String decryptedSeed = NearHelperService.byteToHex(
      NearHelperService.decrypt(
          await sl.get<Vault>().getSeed(), const AppPasswordLockScreen() as String) as List<int>);

  // Session key ile şifrele
  List<int> sessionKey = (await sl.get<Vault>().getSessionKey()) as List<int>;
  Salsa20Encryptor encryptor = Salsa20Encryptor(sessionKey as String, "your_iv_here");
  String encryptedSeed = encryptor.encrypt(decryptedSeed);

  // Şifreli veriyi state'e kaydet
  StateContainer.of(context as BuildContext)?.setEncryptedSecret(encryptedSeed);
}
