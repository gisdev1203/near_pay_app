import 'dart:math';

class RandomUtil {
  static String generateEncryptionSecret(int length) {
    String result = ""; // Resulting passcode
    String chars = "abcdefghijklmnopqrstuvwxyz0123456789!?&+\\-'."; // Characters a passcode may contain
    var rng = Random.secure();
    for (int i = 0; i < length; i ++) {
      result += chars[rng.nextInt(chars.length)];
    }
    return result;
  }
}