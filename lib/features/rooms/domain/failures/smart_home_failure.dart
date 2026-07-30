sealed class SmartHomeFailure {
  const SmartHomeFailure(this.message);

  final String message;
}

class SmartHomeUnconfiguredFailure extends SmartHomeFailure {
  const SmartHomeUnconfiguredFailure()
    : super('Keine Home Assistant-Verbindung konfiguriert.');
}

class SmartHomeConnectionFailure extends SmartHomeFailure {
  const SmartHomeConnectionFailure()
    : super('Home Assistant ist gerade nicht erreichbar.');
}

class SmartHomeUnauthorizedFailure extends SmartHomeFailure {
  const SmartHomeUnauthorizedFailure()
    : super('Zugriffstoken ungültig oder abgelaufen.');
}

class SmartHomeUnexpectedFailure extends SmartHomeFailure {
  const SmartHomeUnexpectedFailure(super.message);
}
