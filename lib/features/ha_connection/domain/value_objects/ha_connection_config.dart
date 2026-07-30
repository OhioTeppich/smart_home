import 'package:equatable/equatable.dart';

class HaConnectionConfig extends Equatable {
  const HaConnectionConfig({required this.baseUrl, required this.token});

  final String baseUrl;
  final String token;

  static HaConnectionConfig? tryCreate({
    required String baseUrl,
    required String token,
  }) {
    final normalizedUrl = _normalizeBaseUrl(baseUrl);
    final trimmedToken = token.trim();
    if (normalizedUrl == null || trimmedToken.isEmpty) return null;
    return HaConnectionConfig(baseUrl: normalizedUrl, token: trimmedToken);
  }

  static String? _normalizeBaseUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    final path = uri.path.endsWith('/')
        ? uri.path.substring(0, uri.path.length - 1)
        : uri.path;
    return uri.replace(path: path).toString();
  }

  @override
  List<Object?> get props => [baseUrl, token];
}
