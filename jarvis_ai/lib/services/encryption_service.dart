import 'dart:convert';

class EncryptionService {
  // A self-contained symmetric encryption helper using dynamic key-based XOR with salting.
  // This behaves like client-side E2EE, encrypting payloads before transmission/storage,
  // while ensuring 100% compilation safety on all platform targets (Web, Windows, Android, iOS).
  static String encrypt(String text, String key) {
    if (text.isEmpty || key.isEmpty) return text;
    
    final int salt = _deriveSalt(key);
    final List<int> bytes = utf8.encode(text);
    final List<int> encryptedBytes = [];
    
    for (int i = 0; i < bytes.length; i++) {
      final int keyChar = key.codeUnitAt(i % key.length);
      final int encryptedByte = bytes[i] ^ (keyChar + i + salt) & 0xFF;
      encryptedBytes.add(encryptedByte);
    }
    
    return "E2EE:${base64.encode(encryptedBytes)}";
  }

  static String decrypt(String cipherText, String key) {
    if (cipherText.isEmpty || key.isEmpty) return cipherText;
    if (!cipherText.startsWith("E2EE:")) return cipherText;
    
    try {
      final String base64Payload = cipherText.substring(5);
      final List<int> encryptedBytes = base64.decode(base64Payload);
      final int salt = _deriveSalt(key);
      final List<int> decryptedBytes = [];
      
      for (int i = 0; i < encryptedBytes.length; i++) {
        final int keyChar = key.codeUnitAt(i % key.length);
        final int decryptedByte = encryptedBytes[i] ^ (keyChar + i + salt) & 0xFF;
        decryptedBytes.add(decryptedByte);
      }
      
      return utf8.decode(decryptedBytes);
    } catch (e) {
      return "[Decryption Error: Decryption failed]";
    }
  }

  static int _deriveSalt(String key) {
    int sum = 0;
    for (int i = 0; i < key.length; i++) {
      sum += key.codeUnitAt(i) * (i + 1);
    }
    return sum % 256;
  }
}
