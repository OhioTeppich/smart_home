sealed class SpotifyFailure {
  const SpotifyFailure(this.message);

  final String message;
}

class SpotifyUnauthenticatedFailure extends SpotifyFailure {
  const SpotifyUnauthenticatedFailure()
    : super('Spotify-Verbindung abgelaufen. Bitte erneut verbinden.');
}

class SpotifyAuthCancelledFailure extends SpotifyFailure {
  const SpotifyAuthCancelledFailure()
    : super('Anmeldung bei Spotify wurde abgebrochen.');
}

class SpotifyNetworkFailure extends SpotifyFailure {
  const SpotifyNetworkFailure()
    : super('Spotify ist derzeit nicht erreichbar.');
}

class SpotifyInvalidConfigFailure extends SpotifyFailure {
  const SpotifyInvalidConfigFailure()
    : super('Client-ID oder Redirect-URI sind ungültig.');
}

class SpotifyNoActiveDeviceFailure extends SpotifyFailure {
  const SpotifyNoActiveDeviceFailure()
    : super('Kein aktives Wiedergabegerät gefunden.');
}

class SpotifyPremiumRequiredFailure extends SpotifyFailure {
  const SpotifyPremiumRequiredFailure()
    : super('Steuerung erfordert Spotify Premium.');
}

class SpotifyUnexpectedFailure extends SpotifyFailure {
  const SpotifyUnexpectedFailure(super.message);
}
