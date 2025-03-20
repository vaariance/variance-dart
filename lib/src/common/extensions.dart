part of '../../variance_dart.dart';

extension U8a on Uint8List {
  Uint8List padToNBytes(int n, {String direction = 'left'}) {
    if (length > n) {
      throw ArgumentError('Uint8List length exceeds $n bytes.');
    }
    if (length == n) {
      return this;
    }
    final padded = Uint8List(n);
    if (direction == 'right') {
      padded.setRange(0, length, this);
    } else {
      padded.setRange(n - length, n, this);
    }
    return padded;
  }
}
