class ProxyValidator {
  static String? validate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri == null) {
      return 'Invalid proxy URL';
    }

    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'socks5') {
      return 'Proxy scheme must be http:// or socks5://';
    }

    if (uri.host.isEmpty) {
      return 'Proxy host is required';
    }

    if (uri.port <= 0) {
      return 'Proxy port is required';
    }

    return null;
  }
}


