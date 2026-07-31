import 'package:equatable/equatable.dart';

class SpotifyAuthConfig extends Equatable {
  const SpotifyAuthConfig({required this.clientId, required this.redirectUri});

  final String clientId;
  final String redirectUri;

  static SpotifyAuthConfig? tryCreate({
    required String clientId,
    required String redirectUri,
  }) {
    final trimmedClientId = clientId.trim();
    final uri = Uri.tryParse(redirectUri.trim());
    if (trimmedClientId.isEmpty ||
        uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    return SpotifyAuthConfig(
      clientId: trimmedClientId,
      redirectUri: uri.toString(),
    );
  }

  @override
  List<Object?> get props => [clientId, redirectUri];
}
