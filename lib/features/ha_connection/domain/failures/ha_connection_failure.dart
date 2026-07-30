sealed class HaConnectionFailure {
  const HaConnectionFailure(this.message);

  final String message;
}

class HaConnectionUnreachableFailure extends HaConnectionFailure {
  const HaConnectionUnreachableFailure()
    : super('Home Assistant ist unter dieser Adresse nicht erreichbar.');
}

class HaConnectionUnauthorizedFailure extends HaConnectionFailure {
  const HaConnectionUnauthorizedFailure()
    : super('Zugriffstoken ungültig oder abgelaufen.');
}

class HaConnectionTimedOutFailure extends HaConnectionFailure {
  const HaConnectionTimedOutFailure()
    : super('Zeitüberschreitung bei der Verbindung zu Home Assistant.');
}

class HaConnectionInvalidConfigFailure extends HaConnectionFailure {
  const HaConnectionInvalidConfigFailure()
    : super('Adresse oder Zugriffstoken sind ungültig.');
}

class HaConnectionUnexpectedFailure extends HaConnectionFailure {
  const HaConnectionUnexpectedFailure(super.message);
}
