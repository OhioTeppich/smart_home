import 'package:equatable/equatable.dart';

class MailboxAccount extends Equatable {
  const MailboxAccount({
    required this.id,
    required this.label,
    required this.host,
    required this.port,
    required this.username,
    required this.appPassword,
    this.useSsl = true,
  });

  final String id;
  final String label;
  final String host;
  final int port;
  final String username;
  final String appPassword;
  final bool useSsl;

  static MailboxAccount? tryCreate({
    required String id,
    required String label,
    required String host,
    required int port,
    required String username,
    required String appPassword,
    bool useSsl = true,
  }) {
    final trimmedLabel = label.trim();
    final trimmedHost = host.trim();
    final trimmedUsername = username.trim();
    if (trimmedLabel.isEmpty ||
        trimmedHost.isEmpty ||
        trimmedUsername.isEmpty ||
        appPassword.isEmpty ||
        port <= 0) {
      return null;
    }
    return MailboxAccount(
      id: id,
      label: trimmedLabel,
      host: trimmedHost,
      port: port,
      username: trimmedUsername,
      appPassword: appPassword,
      useSsl: useSsl,
    );
  }

  MailboxAccount copyWithPassword(String appPassword) => MailboxAccount(
    id: id,
    label: label,
    host: host,
    port: port,
    username: username,
    appPassword: appPassword,
    useSsl: useSsl,
  );

  @override
  List<Object?> get props => [
    id,
    label,
    host,
    port,
    username,
    appPassword,
    useSsl,
  ];
}
