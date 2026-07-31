sealed class ParcelTrackingFailure {
  const ParcelTrackingFailure(this.message);

  final String message;
}

class ParcelProviderUnreachableFailure extends ParcelTrackingFailure {
  const ParcelProviderUnreachableFailure()
    : super('Sendungsverfolgung ist derzeit nicht erreichbar.');
}

class ParcelProviderUnauthorizedFailure extends ParcelTrackingFailure {
  const ParcelProviderUnauthorizedFailure()
    : super('API-Key für die Sendungsverfolgung ist ungültig.');
}

class ParcelProviderApiKeyMissingFailure extends ParcelTrackingFailure {
  const ParcelProviderApiKeyMissingFailure()
    : super('Kein API-Key für die Sendungsverfolgung hinterlegt.');
}

class ParcelRateLimitedFailure extends ParcelTrackingFailure {
  const ParcelRateLimitedFailure()
    : super('Zu viele Anfragen an die Sendungsverfolgung. Später erneut versuchen.');
}

class ParcelUnexpectedFailure extends ParcelTrackingFailure {
  const ParcelUnexpectedFailure(super.message);
}

class MailboxConnectionFailure extends ParcelTrackingFailure {
  MailboxConnectionFailure(String accountLabel)
    : super('Postfach "$accountLabel" ist nicht erreichbar.');
}

class MailboxAuthFailure extends ParcelTrackingFailure {
  MailboxAuthFailure(String accountLabel)
    : super('Anmeldung bei "$accountLabel" fehlgeschlagen.');
}
