# AGENTS.md

## Projekt

Smart Home: Flutter-App für Übersicht und Steuerung Smart Home.

- Flutter-Paket: `smart_home`
- Sichtbarer Produktname: `Smart Home`
- Hauptcode: `lib/`
- Tests: `test/`
- Plattformen: Android, iOS, Web

## Arbeitsweise für KI-Agenten

1. Vor Änderungen: bestehenden Code, betroffene Tests, relevante Doku lesen. Für schnellen Architekturüberblick zuerst `graphify-out/GRAPH_REPORT.md` lesen bzw. `graphify query "<Frage>"` ausführen, falls `graphify-out/` vorhanden — statt Code manuell durchsuchen.
2. Änderungen klein, fachlich fokussiert halten.
3. Bestehende Funktionalität, öffentliche Schnittstellen nicht ändern ohne ausdrücklichen Auftrag.
4. Keine Secrets, Tokens, lokale SDK-Pfade, Gerätekonfigurationen committen.
5. Generierte Dateien nicht manuell pflegen, wenn durch Flutter oder anderes Build-Tool erzeugt.
6. Vor Abschluss: geänderte Dateien, Git-Status, passende Tests prüfen.
7. Nach erfolgreicher Prüfung: Git-Workflow automatisch bis Push ausführen; nicht auf zusätzliche Commit-/Push-Aufforderung warten.
8. Bei nicht ausgeführten Prüfungen: Grund nennen, nicht automatisch pushen, wenn Fehlerfreiheit dadurch nicht beurteilbar.

## Architektur

Verbindliche Architekturregeln: [ARCHITECTURE.md](ARCHITECTURE.md).

Zusätzlich: automatisch gepflegter Wissensgraph in `graphify-out/` (Nodes, Kanten, Community-Struktur ganzes Repo). Git-Post-Commit-Hook aktualisiert `graph.json` nach jedem Commit automatisch für geänderte Code-Dateien; bei Doku-/Bild-Änderungen `graphify --update` manuell ausführen. Nicht selbst pflegen oder manuell umschreiben.

Grundregeln:

- `lib/main.dart` bleibt minimaler Prozesseinstieg.
- `lib/app.dart`: Composition Root, verdrahtet Anwendung.
- Globale Shell-/Navigationslogik gehört nach `lib/app/`.
- Feature-Code gehört nach `lib/features/{feature}/`, getrennt nach Domain, Application, Infrastructure, Presentation.
- Domain-Code: keine Flutter-, API-, Datenbank- oder Infrastrukturabhängigkeiten importieren.
- Infrastruktur implementiert Domain-Repository-Verträge, kapselt externe Quellen.
- Feature-übergreifende direkte Abhängigkeiten vermeiden.
- Neuen Code an vorhandenen Stil/Struktur anpassen; keine umfassenden Refactorings als Nebenwirkung kleiner Änderung.

## Namens- und UI-Regeln

- Dart-Dateien, technische Bezeichner: `snake_case`.
- Dart-Klassen, Enums: `PascalCase`.
- Variablen, Methoden: `camelCase`.
- Sichtbarer Produktname immer `Smart Home`.
- Flutter-Paket, technische Projektbezeichner: `smart_home`.
- Bestehende UI-Texte deutsch; neue sichtbare Texte daher deutsch formulieren, sofern keine Produktanforderung anders vorgibt.

## Verifikation

Nach Änderungen an Dart-Code möglichst ausführen:

```powershell
flutter pub get
flutter analyze
flutter test
```

Bei Änderungen an bestimmter Plattform zusätzlich passenden Build prüfen, zum Beispiel:

```powershell
flutter build web
flutter build apk --debug
```

Wenn Flutter-Kommandos wegen lokaler Umgebung nicht ausführbar: stattdessen mindestens Imports, Namensreferenzen, Konfigurationen, Git-Diff statisch prüfen.

## Git und GitHub

- Standardbranch: `main`
- Remote: `origin`
- Repository: `OhioTeppich/smart_home`
- Jeder abgeschlossene, fehlerfreie Arbeitsauftrag: eigener Commit, gepusht nach `origin/main`.
- Keine Sammel-Commits über mehrere unabhängige Aufgaben.
- Commit-Nachrichten kurz, sachlich, Imperativ, zum Beispiel `Add room device controls` oder `Fix energy chart loading`.
- Vor jeder Änderung: `git status --short --branch` prüfen. Vorhandene Änderungen gehören Benutzer — nicht überschreiben, verwerfen oder ungefragt mitcommitten.
- Nach Implementierung: nur zum Auftrag gehörende Dateien gezielt stagen, nie blind `git add -A`.
- Vor Commit: Staging-Inhalt mit `git diff --cached --stat` und `git diff --cached --check` prüfen.
- Vor Commit: passende Verifikation ausführen — mindestens `flutter analyze` und `flutter test` bei Dart-/Flutter-Änderungen; bei Plattformänderungen zusätzlich betroffenen Build.
- Bei Erfolg: Commit erstellen, `git push origin main`, danach mit `git status --short --branch` verifizieren, lokaler Branch synchron mit `origin/main`.
- Bei fehlgeschlagenen Tests, Analyse oder Build, Merge-Konflikten, fehlender Authentifizierung oder unklaren Fremdänderungen: nicht committen, nicht pushen. Fehler und nächsten Schritt melden.
- Bei nicht ausführbaren Prüfungen: nur committen wenn Risiko begrenzt, Einschränkung transparent dokumentiert; automatisch pushen erst nach ausdrücklicher Freigabe.
- Nicht committen: `android/local.properties`, `.dart_tool/`, `build/`, Flutter-Plugins, IDE-Artefakte, Tokens, lokale Schlüssel, andere maschinen-/benutzerspezifische Dateien.
- Keine Force-Pushes, History-Rewrites, Branch-Löschungen, Releases oder GitHub-Einstellungsänderungen automatisch ausführen.
- Bei großen, riskanten oder fachlich unklaren Änderungen: vor Commit/Push Rücksprache halten.

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

Workflow gilt für normale abgeschlossene Entwicklungsaufgaben. Dokumentationsänderungen, kleine Konfigurationsänderungen: ebenfalls committed und gepusht, sofern keine Prüfung fehlschlägt und keine Sicherheitsgrenze greift.

## Kommunikation

Am Ende jeder Aufgabe kurz zusammenfassen:

- welche Dateien/Bereiche geändert,
- welche Prüfungen erfolgreich,
- welche Prüfungen nicht ausführbar,
- welche offenen Risiken oder nächsten Schritte.