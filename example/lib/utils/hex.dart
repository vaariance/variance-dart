import 'dart:typed_data';

/// Utility class for hex conversions
class HexUtils {
  /// Convert a hex string to bytes
  static Uint8List hexToBytes(String hex) {
    hex = hex.startsWith('0x') ? hex.substring(2) : hex;
    var result = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      result.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(result);
  }

  /// Shorten a hash for display
  static String shortenHash(String hash) {
    if (hash.length <= 10) return hash;
    return '${hash.substring(0, 6)}...${hash.substring(hash.length - 4)}';
  }
}