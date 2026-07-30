# AGENTS.md

## Projekt

Smart Home ist eine Flutter-Anwendung für die Übersicht und Steuerung eines Smart Homes.

- Flutter-Paket: `smart_home`
- Sichtbarer Produktname: `Smart Home`
- Hauptcode: `lib/`
- Tests: `test/`
- Plattformen: Android, iOS und Web

## Arbeitsweise für KI-Agenten

1. Vor Änderungen zuerst den bestehenden Code, die betroffenen Tests und die relevante Dokumentation lesen. Für einen schnellen Architekturüberblick zuerst `graphify-out/GRAPH_REPORT.md` lesen bzw. `graphify query "<Frage>"` ausführen, falls `graphify-out/` vorhanden ist, statt den gesamten Code manuell zu durchsuchen.
2. Änderungen klein und fachlich fokussiert halten.
3. Bestehende Funktionalität und öffentliche Schnittstellen nicht ohne ausdrücklichen Auftrag ändern.
4. Keine Secrets, Tokens, lokalen SDK-Pfade oder Gerätekonfigurationen committen.
5. Generierte Dateien nicht manuell dauerhaft pflegen, wenn sie durch Flutter oder ein anderes Build-Tool erzeugt werden.
6. Vor dem Abschluss die geänderten Dateien, den Git-Status und passende Tests prüfen.
7. Nach erfolgreicher Prüfung den Git-Workflow automatisch bis zum Push ausführen; nicht auf eine zusätzliche Commit- oder Push-Aufforderung warten.
8. Bei nicht ausgeführten Prüfungen den Grund ausdrücklich nennen und nicht automatisch pushen, wenn dadurch die Fehlerfreiheit nicht beurteilt werden kann.

## Architektur

Die verbindlichen Architekturregeln stehen in [ARCHITECTURE.md](ARCHITECTURE.md).

Zusätzlich existiert ein automatisch gepflegter Wissensgraph in `graphify-out/` (Nodes, Kanten, Community-Struktur des gesamten Repos). Ein Git-Post-Commit-Hook aktualisiert `graph.json` nach jedem Commit automatisch für geänderte Code-Dateien; bei Doku-/Bild-Änderungen `graphify --update` manuell ausführen. Nicht selbst pflegen oder manuell umschreiben.

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
- Jeder abgeschlossene, fehlerfreie Arbeitsauftrag wird als eigener Commit festgehalten und nach `origin/main` gepusht.
- Keine Sammel-Commits über mehrere unabhängige Aufgaben bilden.
- Commit-Nachrichten sind kurz, sachlich und beschreiben die Änderung im Imperativ, zum Beispiel `Add room device controls` oder `Fix energy chart loading`.
- Vor jeder Änderung zuerst `git status --short --branch` prüfen. Bereits vorhandene Änderungen gehören dem Benutzer und dürfen nicht überschrieben, verworfen oder ungefragt mit committed werden.
- Nach der Implementierung nur die zum Auftrag gehörenden Dateien gezielt stagen, niemals blind alle Dateien mit `git add -A`.
- Vor dem Commit den Staging-Inhalt mit `git diff --cached --stat` und `git diff --cached --check` prüfen.
- Vor dem Commit die passende Verifikation ausführen: mindestens `flutter analyze` und `flutter test` bei Dart-/Flutter-Änderungen; bei Plattformänderungen zusätzlich den betroffenen Build.
- Wenn die Prüfungen erfolgreich sind: Commit erstellen, mit `git push origin main` pushen und anschließend mit `git status --short --branch` verifizieren, dass der lokale Branch mit `origin/main` synchron ist.
- Wenn Tests, Analyse oder Build fehlschlagen, bei Merge-Konflikten, fehlender Authentifizierung oder unklaren Fremdänderungen nicht committen und nicht pushen. Fehler und benötigten nächsten Schritt melden.
- Bei nicht ausführbaren Prüfungen nur dann committen, wenn das Risiko begrenzt und die Einschränkung transparent dokumentiert ist; automatisch pushen erst nach ausdrücklicher Freigabe.
- Nicht committen: `android/local.properties`, `.dart_tool/`, `build/`, Flutter-Plugins, IDE-Artefakte, Tokens, lokale Schlüssel und andere maschinen- oder benutzerspezifische Dateien.
- Keine Force-Pushes, History-Rewrites, Branch-Löschungen, Releases oder Änderungen an GitHub-Einstellungen automatisch ausführen.
- Bei großen, riskanten oder fachlich unklaren Änderungen vor Commit und Push Rücksprache halten.

### Standardablauf

```text
Arbeitsbaum prüfen
    ↓
Änderung implementieren
    ↓
Gezielt stagen und Diff prüfen
    ↓
Analyse, Tests und betroffene Builds ausführen
    ↓
Commit mit sachlicher Nachricht erstellen
    ↓
`git push origin main`
    ↓
Remote-Synchronität und Ergebnis prüfen
```

Der Workflow gilt für normale abgeschlossene Entwicklungsaufgaben. Dokumentationsänderungen und kleine Konfigurationsänderungen werden ebenfalls committed und gepusht, sofern keine Prüfung fehlschlägt und keine der Sicherheitsgrenzen greift.

## Kommunikation

Am Ende jeder Aufgabe kurz zusammenfassen:

- welche Dateien oder Bereiche geändert wurden,
- welche Prüfungen erfolgreich waren,
- welche Prüfungen nicht ausgeführt werden konnten,
- welche offenen Risiken oder nächsten Schritte bestehen.
