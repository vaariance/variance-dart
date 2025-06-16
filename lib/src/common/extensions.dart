part of '../../variance_dart.dart';

RegExp _ipv4Maybe = RegExp(r'^(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)$');
RegExp _ipv6 = RegExp(
  r'^::|^::1|^([a-fA-F0-9]{1,4}::?){1,7}([a-fA-F0-9]{1,4})$',
);

bool isFQDN(String str, Map<String, Object> options) {
  final parts = str.split('.');
  if (options['require_tld'] as bool) {
    var tld = parts.removeLast();
    if (parts.isEmpty || !RegExp(r'^[a-z]{2,}$').hasMatch(tld)) {
      return false;
    }
  }

  for (final part in parts) {
    if (options['allow_underscores'] as bool) {
      if (part.contains('__')) {
        return false;
      }
    }
    if (!RegExp(r'^[a-z\\u00a1-\\uffff0-9-]+$').hasMatch(part)) {
      return false;
    }
    if (part[0] == '-' ||
        part[part.length - 1] == '-' ||
        part.contains('---')) {
      return false;
    }
  }
  return true;
}

bool isIP(String str, [Object? version]) {
  assert(version == null || version is String || version is int);
  version = version.toString();
  if (version == 'null') {
    return isIP(str, 4) || isIP(str, 6);
  } else if (version == '4') {
    if (!_ipv4Maybe.hasMatch(str)) {
      return false;
    }
    var parts = str.split('.');
    parts.sort((a, b) => int.parse(a) - int.parse(b));
    return int.parse(parts[3]) <= 255;
  }
  return version == '6' && _ipv6.hasMatch(str);
}

String? _shift(List<String> elements) {
  if (elements.isEmpty) return null;
  return elements.removeAt(0);
}

extension StringExtension on String? {
  bool isURL() {
    var str = this;
    if (str == null ||
        str.isEmpty ||
        str.length > 2083 ||
        str.indexOf('mailto:') == 0) {
      return false;
    }

    final Map<String, Object> options = {
      'protocols': ['http', 'https', 'ftp'],
      'require_tld': true,
      'require_protocol': false,
      'allow_underscores': false,
    };

    var split = str.split('://');
    if (split.length > 1) {
      final protocol = _shift(split);
      final protocols = options['protocols'] as List<String>;
      if (!protocols.contains(protocol)) {
        return false;
      }
    } else if (options['require_protocol'] == true) {
      return false;
    }
    str = split.join('://');

    // check hash
    split = str.split('#');
    str = _shift(split);
    final hash = split.join('#');
    if (hash.isNotEmpty && RegExp(r'\s').hasMatch(hash)) {
      return false;
    }

    // check query params
    split = str?.split('?') ?? [];
    str = _shift(split);
    final query = split.join('?');
    if (query != "" && RegExp(r'\s').hasMatch(query)) {
      return false;
    }

    // check path
    split = str?.split('/') ?? [];
    str = _shift(split);
    final path = split.join('/');
    if (path != "" && RegExp(r'\s').hasMatch(path)) {
      return false;
    }

    // check auth type urls
    split = str?.split('@') ?? [];
    if (split.length > 1) {
      final auth = _shift(split);
      if (auth != null && auth.contains(':')) {
        // final auth = auth.split(':');
        final parts = auth.split(':');
        final user = _shift(parts);
        if (user == null || !RegExp(r'^\S+$').hasMatch(user)) {
          return false;
        }
        final pass = parts.join(':');
        if (!RegExp(r'^\S*$').hasMatch(pass)) {
          return false;
        }
      }
    }

    // check hostname
    final hostname = split.join('@');
    split = hostname.split(':');
    final host = _shift(split);
    if (split.isNotEmpty) {
      final portStr = split.join(':');
      final port = int.tryParse(portStr, radix: 10);
      if (!RegExp(r'^[0-9]+$').hasMatch(portStr) ||
          port == null ||
          port <= 0 ||
          port > 65535) {
        return false;
      }
    }

    if (host == null ||
        !isIP(host) && !isFQDN(host, options) && host != 'localhost') {
      return false;
    }

    return true;
  }

  /// Executes the given [fn] with the non-null string value as its argument and returns the result.
  /// If the string is null, returns null without executing [fn].
  ///
  /// Example:
  /// ```dart
  /// String? name = 'John';
  /// int? length = name.let((it) => it.length); // Returns 4
  ///
  /// String? nullName = null;
  /// int? nullLength = nullName.let((it) => it.length); // Returns null
  /// ```
  T? let<T>(T Function(String) fn) {
    if (this == null) return null;
    return fn(this!);
  }
}
