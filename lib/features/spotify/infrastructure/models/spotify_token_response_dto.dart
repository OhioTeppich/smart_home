class SpotifyTokenResponseDto {
  const SpotifyTokenResponseDto({
    required this.accessToken,
    required this.expiresIn,
    this.refreshToken,
  });

  factory SpotifyTokenResponseDto.fromJson(Map<String, dynamic> json) =>
      SpotifyTokenResponseDto(
        accessToken: json['access_token'] as String,
        expiresIn: json['expires_in'] as int,
        refreshToken: json['refresh_token'] as String?,
      );

  final String accessToken;
  final int expiresIn;

  /// Spotify does not always rotate the refresh token on a refresh-token
  /// grant — `null` means the caller should keep using the previous one.
  final String? refreshToken;
}
