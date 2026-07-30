# AGENTS.md

## Projekt

Smart Home ist eine Flutter-Anwendung für die Übersicht und Steuerung eines Smart Homes.

- Flutter-Paket: `smart_home`
- Sichtbarer Produktname: `Smart Home`
- Hauptcode: `lib/`
- Tests: `test/`
- Plattformen: Android, iOS und Web

## Arbeitsweise für KI-Agenten

1. Vor Änderungen zuerst den bestehenden Code, die betroffenen Tests und die relevante Dokumentation lesen.
2. Änderungen klein und fachlich fokussiert halten.
3. Bestehende Funktionalität und öffentliche Schnittstellen nicht ohne ausdrücklichen Auftrag ändern.
4. Keine Secrets, Tokens, lokalen SDK-Pfade oder Gerätekonfigurationen committen.
5. Generierte Dateien nicht manuell dauerhaft pflegen, wenn sie durch Flutter oder ein anderes Build-Tool erzeugt werden.
6. Vor dem Abschluss die geänderten Dateien, den Git-Status und passende Tests prüfen.
7. Bei nicht ausgeführten Prüfungen den Grund ausdrücklich nennen.

## Architektur

Die verbindlichen Architekturregeln stehen in [ARCHITECTURE.md](ARCHITECTURE.md).

Grundregeln:

- `lib/main.dart` bleibt der minimale Prozesseinstieg.
- `lib/app.dart` ist der Composition Root und verdrahtet die Anwendung.
- Globale Shell- und Navigationslogik gehört nach `lib/app/`.
- Feature-Code gehört nach `lib/features/{feature}/` und wird nach Domain, Application, Infrastructure und Presentation getrennt.
- Domain-Code darf keine Flutter-, API-, Datenbank- oder Infrastrukturabhängigkeiten importieren.
- Infrastruktur implementiert Domain-Repository-Verträge und kapselt externe Quellen.
- Feature-übergreifende direkte Abhängigkeiten vermeiden.
- Neuen Code an den vorhandenen Stil und die bestehende Struktur anpassen; keine umfassenden Refactorings als Nebenwirkung einer kleinen Änderung.

## Namens- und UI-Regeln

- Dart-Dateien und technische Bezeichner verwenden `snake_case`.
- Dart-Klassen und Enums verwenden `PascalCase`.
- Variablen und Methoden verwenden `camelCase`.
- Der sichtbare Produktname lautet immer `Smart Home`.
- Das Flutter-Paket und technische Projektbezeichner lauten `smart_home`.
- Die bestehenden UI-Texte sind deutsch; neue sichtbare Texte daher auf Deutsch formulieren, sofern keine Produktanforderung etwas anderes vorgibt.

## Verifikation

Nach Änderungen an Dart-Code möglichst ausführen:

```powershell
flutter pub get
flutter analyze
flutter test
```

Bei Änderungen an einer bestimmten Plattform zusätzlich den passenden Build prüfen, zum Beispiel:

```powershell
flutter build web
flutter build apk --debug
```

Wenn Flutter-Kommandos wegen der lokalen Umgebung nicht ausführbar sind, stattdessen mindestens Imports, Namensreferenzen, Konfigurationen und den Git-Diff statisch prüfen.

## Git und GitHub

- Standardbranch: `main`
- Remote: `origin`
- Repository: `OhioTeppich/smart_home`
- Commits sollen eine kurze, sachliche Beschreibung enthalten.
- Vor dem Commit `git status` und die gestagten Dateien prüfen.
- Nicht committen: `android/local.properties`, `.dart_tool/`, `build/`, Flutter-Plugins, IDE-Artefakte, Tokens und lokale Schlüssel.
- Keine externen Pushes, Releases oder Änderungen an GitHub-Einstellungen ohne ausdrücklichen Auftrag.

## Kommunikation

Am Ende jeder Aufgabe kurz zusammenfassen:

- welche Dateien oder Bereiche geändert wurden,
- welche Prüfungen erfolgreich waren,
- welche Prüfungen nicht ausgeführt werden konnten,
- welche offenen Risiken oder nächsten Schritte bestehen.
