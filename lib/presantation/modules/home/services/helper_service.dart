import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:near_pay_app/data/network/helper_network.dart';
import 'package:url_launcher/url_launcher.dart';



class NearHelperService {
  final NearHelperNetworkClient networkClient;
  static String byteToHex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
  // Define your custom decrypt function
 decrypt( encryptedText,  key) {
  // Implement your decryption logic here
  // For example, a simple XOR decryption:
  List<int> bytes = encryptedText.codeUnits;
  List<int> keyBytes = key.codeUnits;
  List<int> decryptedBytes = List<int>.generate(bytes.length, (i) => bytes[i] ^ keyBytes[i % keyBytes.length]);
  return String.fromCharCodes(decryptedBytes);
}


  NearHelperService(this.networkClient);

  Future<bool> activateTestNetAccountID(String accountId) async {
    final res = await networkClient.postHTTP(
        '/create-account', jsonEncode({"accountId": accountId}));
    return res.isSuccess;
  }

  Future<void> launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }
}
// Define a method named decrypt
String decrypt(String encryptedText, String key) {
  // Implement your decryption logic here
  // For example, a simple XOR decryption:
  List<int> bytes = encryptedText.codeUnits;
  List<int> keyBytes = key.codeUnits;
  List<int> decryptedBytes = List<int>.generate(bytes.length, (i) => bytes[i] ^ keyBytes[i % keyBytes.length]);
  return String.fromCharCodes(decryptedBytes);
}
// Initialize NearHelperService with a NearHelperNetworkClient instance
NearHelperNetworkClient networkClient = NearHelperNetworkClient(baseUrl: '', dio: Dio());
NearHelperService cryptography = NearHelperService(networkClient);

// Call the decrypt method on the cryptography instance



// Call the decrypt method on the instance
String decryptedText = cryptography.decrypt(encryptedText, key);
