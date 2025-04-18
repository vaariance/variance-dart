/// Utility class for Ethereum address operations
class EthereumAddressUtils {
  /// Shortens an Ethereum address for display
  ///
  /// Takes a full Ethereum address and shortens it to show only the first and last few characters
  /// Default format: 0xABCD...XYZ
  ///
  /// Example:
  /// ```dart
  /// String shortened = EthereumAddressUtils.shortenAddress('0x1234567890abcdef1234567890abcdef12345678');
  /// print(shortened); // Outputs: 0x1234...5678
  /// ```
  static String shortenAddress(
      String address, {
        int prefixLength = 6,
        int suffixLength = 4,
        String separator = '...',
      }) {
    // Handle null, empty or invalid addresses
    if (address == null || address.isEmpty) {
      return '';
    }

    // Clean the address format by removing whitespace
    address = address.trim();

    // If the address is already shorter than the combined length, return it as is
    if (address.length <= prefixLength + suffixLength) {
      return address;
    }

    // Handle different address formats
    String prefix = address.startsWith('0x')
        ? address.substring(0, prefixLength)  // Keep 0x + specified chars
        : address.substring(0, prefixLength); // Just keep specified chars

    String suffix = address.substring(address.length - suffixLength);

    return '$prefix$separator$suffix';
  }

  /// Validates if a string is a valid Ethereum address
  ///
  /// Basic validation for Ethereum address format
  /// - Must be 42 characters long (including 0x)
  /// - Must start with 0x
  /// - Must only contain hexadecimal characters
  static bool isValidAddress(String address) {
    if (address == null || address.isEmpty) {
      return false;
    }

    // Remove any whitespace
    address = address.trim();

    // Check if it starts with 0x and has the correct length
    if (!address.startsWith('0x') || address.length != 42) {
      return false;
    }

    // Check if it only contains hexadecimal characters (after 0x)
    final hexRegExp = RegExp(r'^[0-9a-fA-F]+$');
    return hexRegExp.hasMatch(address.substring(2));
  }

  /// Normalizes an Ethereum address to a standard format
  ///
  /// - Adds 0x prefix if missing
  /// - Converts to lowercase
  /// - Removes whitespace
  static String normalizeAddress(String address) {
    if (address == null || address.isEmpty) {
      return '';
    }

    // Remove any whitespace
    address = address.trim();

    // Add 0x prefix if missing
    if (!address.startsWith('0x')) {
      address = '0x$address';
    }

    // Convert to lowercase
    return address.toLowerCase();
  }

  /// Returns a colored portion of address for display in UI
  ///
  /// Returns a map with 'prefix', 'middle' and 'suffix' parts
  /// for different UI styling (e.g. showing the middle part in a different color)
  static Map<String, String> getColoredAddressParts(
      String address, {
        int prefixLength = 6,
        int suffixLength = 4,
      }) {
    if (address == null || address.isEmpty) {
      return {'prefix': '', 'middle': '', 'suffix': ''};
    }

    address = address.trim();

    if (address.length <= prefixLength + suffixLength) {
      return {'prefix': address, 'middle': '', 'suffix': ''};
    }

    final prefix = address.substring(0, prefixLength);
    final suffix = address.substring(address.length - suffixLength);
    final middle = address.substring(prefixLength, address.length - suffixLength);

    return {
      'prefix': prefix,
      'middle': middle,
      'suffix': suffix,
    };
  }

  /// Generates a checksum address from a normal address
  ///
  /// Implements EIP-55 checksum encoding
  /// This returns a mixed-case address with specific characters capitalized
  /// based on the hash of the address, which provides additional validation
  static String toChecksumAddress(String address) {
    // This would require a crypto library to implement properly
    // For a complete implementation, you would need to:
    // 1. Normalize the address (remove 0x, lowercase)
    // 2. Hash the normalized address using keccak256
    // 3. For each character in the address:
    //    - If the corresponding hex digit in the hash is 8 or higher, uppercase the character
    //    - Otherwise, leave it lowercase
    // 4. Add 0x prefix

    // Example implementation placeholder:
    // TODO: Implement proper EIP-55 checksum
    return address;
  }
}