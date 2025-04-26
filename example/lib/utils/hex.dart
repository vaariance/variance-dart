/// Utility class for hex conversions
extension HexUtils on String {
  /// Shorten a hash for display
  String shortenHash() {
    if (length <= 10) return this;
    return '${substring(0, 6)}...${substring(length - 4)}';
  }
}
