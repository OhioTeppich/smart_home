sealed class HaClientException implements Exception {
  const HaClientException(this.message);

  final String message;

  @override
  String toString() => message;
}

class HaConnectionException extends HaClientException {
  const HaConnectionException([
    super.message = 'Home Assistant ist nicht erreichbar.',
  ]);
}

class HaAuthException extends HaClientException {
  const HaAuthException([
    super.message = 'Zugriffstoken ungültig oder abgelaufen.',
  ]);
}

class HaTimeoutException extends HaClientException {
  const HaTimeoutException([
    super.message = 'Zeitüberschreitung bei der Verbindung zu Home Assistant.',
  ]);
}

class HaProtocolException extends HaClientException {
  const HaProtocolException(super.message);
}
